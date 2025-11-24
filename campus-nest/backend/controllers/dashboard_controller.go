package controllers

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"strconv"
	"time"

	"backend/models"
	"backend/services"

	"strings"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)


type DashboardController struct {
	UserCollection        *mongo.Collection
	ApplicationCollection *mongo.Collection
	JobCollection         *mongo.Collection
	ResumeCollection      *mongo.Collection
	CompanyCollection     *mongo.Collection


	dashboardService services.DashboardService
	userService      services.UserService
	jobService       services.JobService
	companyService   services.CompanyService
	studentService   services.StudentService
	tpoService       services.TPOService
}


type UpdateSkillsRequest struct {
	Skills []string `json:"skills" binding:"required"`
}


func NewDashboardController(db *mongo.Database) *DashboardController {
	return &DashboardController{
		UserCollection:        db.Collection("users"),
		ApplicationCollection: db.Collection("applications"),
		JobCollection:         db.Collection("jobs"),
		ResumeCollection:      db.Collection("resumes"),
		CompanyCollection:     db.Collection("companies"),


		dashboardService: services.NewDashboardService(db),
		userService:      services.NewUserService(db),
		jobService:       services.NewJobService(db),
		companyService:   services.NewCompanyService(db),
		studentService:   services.NewStudentService(db),
		tpoService:       services.NewTPOService(db),
	}
}


func (dc *DashboardController) GetDashboardByRole(c *gin.Context) {


	roleFromToken, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"error": "Role not found in token"})
		return
	}


	switch roleFromToken {
	case "student":
		dc.getStudentDashboard(c)
	case "tpo":
		dc.getTpoDashboard(c)
	case "rec":
		dc.getRecruiterDashboard(c)
	case "admin":
		dc.getAdminDashboard(c)
	default:
		c.JSON(http.StatusForbidden, gin.H{"error": "Dashboard not available for this role"})
	}
}




func (dc *DashboardController)getAdminDashboard(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	adminID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}


	var admin models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": adminID}).Decode(&admin)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Admin not found"})
		return
	}


	totalStudents, _ := dc.UserCollection.CountDocuments(ctx, bson.M{"role": "student"})
	totalCompanies, _ := dc.UserCollection.Database().Collection("companies").CountDocuments(ctx, bson.M{})
	totalJobs, _ := dc.JobCollection.CountDocuments(ctx, bson.M{})
	totalApplications, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{})
	placedStudents, _ := dc.UserCollection.CountDocuments(ctx, bson.M{"role": "student", "placedStatus": "Placed"})
	activeJobs, _ := dc.JobCollection.CountDocuments(ctx, bson.M{"status": "open"})

	c.JSON(http.StatusOK, gin.H{
		"admin": gin.H{
			"id":        admin.ID,
			"firstName": admin.FirstName,
			"lastName":  admin.LastName,
			"email":     admin.Email,
			"role":      admin.Role,
		},
		"stats": gin.H{
			"totalStudents":      totalStudents,
			"placedStudents":     placedStudents,
			"totalCompanies":     totalCompanies,
			"totalJobs":          totalJobs,
			"activeJobs":         activeJobs,
			"totalApplications":  totalApplications,
		},
	})
}


func (dc *DashboardController) getStudentDashboard(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	studentID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}


	appliedCount, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"student_id": studentID})
	shortlistedCount, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"student_id": studentID, "status": "shortlisted"})
	offeredCount, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"student_id": studentID, "status": "offered"})
	summary := gin.H{"applied": appliedCount, "shortlisted": shortlistedCount, "offered": offeredCount}


	deadlineFilter := bson.M{"status": "open", "application_deadline": bson.M{"$gt": time.Now()}}
	deadlineOpts := options.Find().SetSort(bson.D{{Key: "application_deadline", Value: 1}}).SetLimit(3)
	cursor, err := dc.JobCollection.Find(ctx, deadlineFilter, deadlineOpts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch upcoming deadlines"})
		return
	}
	var deadlines []models.Job
	if err = cursor.All(ctx, &deadlines); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode deadlines"})
		return
	}


	if deadlines == nil {
		deadlines = []models.Job{}
	}


	var user models.User
	if err := dc.UserCollection.FindOne(ctx, bson.M{"_id": studentID}).Decode(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not retrieve user data for recommendations"})
		return
	}

	var skills []string

	if len(user.ActiveResumeID) > 0 {
		var resume models.Resume
		if err := dc.ResumeCollection.FindOne(ctx, bson.M{"_id": user.ActiveResumeID[0]}).Decode(&resume); err == nil {
			skills = resume.ParsedData.Skills

			if skills == nil {
				skills = []string{}
			}
		}
	}

	if skills == nil {
		skills = user.Skills
		if skills == nil {
			skills = []string{}
		}
	}


	if len(user.Skills) > 0 {

		skillsMap := make(map[string]bool)
		for _, skill := range skills {
			skillsMap[skill] = true
		}
		for _, skill := range user.Skills {
			if !skillsMap[skill] {
				skills = append(skills, skill)
			}
		}
	}


	appliedJobsCursor, err := dc.ApplicationCollection.Find(ctx, bson.M{"student_id": studentID}, options.Find().SetProjection(bson.M{"job_id": 1}))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch applied jobs"})
		return
	}
	var appliedJobs []struct {
		JobID primitive.ObjectID `bson:"job_id"`
	}
	if err = appliedJobsCursor.All(ctx, &appliedJobs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode applied jobs"})
		return
	}


	appliedJobIDs := make([]primitive.ObjectID, len(appliedJobs))
	for i, app := range appliedJobs {
		appliedJobIDs[i] = app.JobID
	}

	recFilter := bson.M{"status": "open"}

	if len(appliedJobIDs) > 0 {
		recFilter["_id"] = bson.M{"$nin": appliedJobIDs}
	}
	if user.Department != nil {
		recFilter["eligibility.course"] = bson.M{"$in": []string{*user.Department}}
	}
	if len(skills) > 0 {
		recFilter["eligibility.skills"] = bson.M{"$in": skills}
	}
	if user.CGPA != nil {
		recFilter["eligibility.min_cgpa"] = bson.M{"$lte": *user.CGPA}
	}

	recOpts := options.Find().SetLimit(3)
	cursor, err = dc.JobCollection.Find(ctx, recFilter, recOpts)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch recommended jobs"})
		return
	}
	var recommendations []models.Job
	if err = cursor.All(ctx, &recommendations); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode recommendations"})
		return
	}


	if recommendations == nil {
		recommendations = []models.Job{}
	}

	userName := user.FirstName + " " + user.LastName

	c.JSON(http.StatusOK, gin.H{
		"summary":         summary,
		"deadlines":       deadlines,
		"recommendations": recommendations,
		"userName":        userName,
	})
}

func (dc *DashboardController) getTpoDashboard(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()


	totalStudents, err := dc.UserCollection.CountDocuments(ctx, bson.M{"role": "student"})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch total students count"})
		return
	}


	activeDrives, err := dc.JobCollection.CountDocuments(ctx, bson.M{"status": "open"})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch active drives count"})
		return
	}


	companiesOnboarded, err := dc.CompanyCollection.CountDocuments(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch companies count"})
		return
	}


	totalApplications, err := dc.ApplicationCollection.CountDocuments(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch total applications"})
		return
	}

	shortlistedApplications, err := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"status": "shortlisted"})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch shortlisted applications"})
		return
	}

	offersReleased, err := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"status": "selected"})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch offers released"})
		return
	}


	pipeline := []bson.M{
		{
			"$lookup": bson.M{
				"from":         "applications",
				"localField":   "_id",
				"foreignField": "student_id",
				"as":           "applications",
			},
		},
		{
			"$addFields": bson.M{
				"hasOffer": bson.M{
					"$gt": []interface{}{
						bson.M{
							"$size": bson.M{
								"$filter": bson.M{
									"input": "$applications",
									"cond":  bson.M{"$eq": []interface{}{"$$this.status", "selected"}},
								},
							},
						},
						0,
					},
				},
			},
		},
		{
			"$group": bson.M{
				"_id":           "$department",
				"totalStudents": bson.M{"$sum": 1},
				"placedStudents": bson.M{
					"$sum": bson.M{
						"$cond": []interface{}{"$hasOffer", 1, 0},
					},
				},
			},
		},
		{
			"$addFields": bson.M{
				"placementRate": bson.M{
					"$round": []interface{}{
						bson.M{
							"$multiply": []interface{}{
								bson.M{"$divide": []interface{}{"$placedStudents", "$totalStudents"}},
								100,
							},
						},
						1,
					},
				},
			},
		},
		{
			"$sort": bson.M{"placementRate": -1},
		},
	}

	cursor, err := dc.UserCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to calculate placement rates"})
		return
	}

	var placementRates []bson.M
	if err = cursor.All(ctx, &placementRates); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode placement rates"})
		return
	}


	var departmentWisePlacement []gin.H
	for _, rate := range placementRates {
		if rate["_id"] != nil {
			departmentWisePlacement = append(departmentWisePlacement, gin.H{
				"department":     rate["_id"],
				"totalStudents":  rate["totalStudents"],
				"placedStudents": rate["placedStudents"],
				"placementRate":  rate["placementRate"],
			})
		}
	}


	recentActivitiesPipeline := []bson.M{
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "job_id",
				"foreignField": "_id",
				"as":           "job",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": "$job",
		},
		{
			"$sort": bson.M{"applied_on": -1},
		},
		{
			"$limit": 5,
		},
		{
			"$project": bson.M{
				"studentName": bson.M{"$concat": []interface{}{"$student.firstName", " ", "$student.lastName"}},
				"companyName": "$job.company_name.name",
				"position":    "$job.position",
				"status":      "$status",
				"appliedOn":   "$applied_on",
			},
		},
	}

	recentCursor, err := dc.ApplicationCollection.Aggregate(ctx, recentActivitiesPipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch recent activities"})
		return
	}

	var recentActivities []bson.M
	if err = recentCursor.All(ctx, &recentActivities); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode recent activities"})
		return
	}


	c.JSON(http.StatusOK, gin.H{
		"overview": gin.H{
			"totalStudents":      totalStudents,
			"activeDrives":       activeDrives,
			"companiesOnboarded": companiesOnboarded,
		},
		"applicationStats": gin.H{
			"totalApplications":   totalApplications,
			"shortlistedStudents": shortlistedApplications,
			"offersReleased":      offersReleased,
		},
		"placementRateByDepartment": departmentWisePlacement,
		"recentActivities":          recentActivities,
	})
}

func (dc *DashboardController) getRecruiterDashboard(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}


	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}


	if recruiter.CompanyID == nil {
		c.JSON(http.StatusOK, gin.H{
			"company": nil,
			"overview": gin.H{
				"totalJobDrives":    0,
				"activeJobDrives":   0,
				"totalApplications": 0,
				"totalShortlisted":  0,
				"totalRejected":     0,
			},
			"recentJobDrives": []gin.H{},
			"recruiterName":   recruiter.FirstName + " " + recruiter.LastName,
			"message":         "No company associated. Please contact admin to associate your account with a company.",
		})
		return
	}


	var company models.Company
	err = dc.CompanyCollection.FindOne(ctx, bson.M{"_id": *recruiter.CompanyID}).Decode(&company)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"company": gin.H{
				"id":   *recruiter.CompanyID,
				"name": "Company Not Found",
			},
			"overview": gin.H{
				"totalJobDrives":    0,
				"activeJobDrives":   0,
				"totalApplications": 0,
				"totalShortlisted":  0,
				"totalRejected":     0,
			},
			"recentJobDrives": []gin.H{},
			"recruiterName":   recruiter.FirstName + " " + recruiter.LastName,
			"message":         "Company details not found. Please contact admin.",
		})
		return
	}


	jobDrives, err := dc.JobCollection.Find(ctx, bson.M{"company_name.companyId": *recruiter.CompanyID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch job drives"})
		return
	}

	var jobs []models.Job
	if err = jobDrives.All(ctx, &jobs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode job drives"})
		return
	}


	var jobIDs []primitive.ObjectID
	for _, job := range jobs {
		jobIDs = append(jobIDs, job.ID)
	}


	totalJobDrives := len(jobs)
	activeJobDrives := 0
	totalApplications := int64(0)
	totalShortlisted := int64(0)
	totalRejected := int64(0)


	for _, job := range jobs {
		if job.Status == "open" {
			activeJobDrives++
		}
	}


	if len(jobIDs) > 0 {

		totalApplications, err = dc.ApplicationCollection.CountDocuments(ctx, bson.M{"job_id": bson.M{"$in": jobIDs}})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch total applications"})
			return
		}


		totalShortlisted, err = dc.ApplicationCollection.CountDocuments(ctx, bson.M{
			"job_id": bson.M{"$in": jobIDs},
			"status": "shortlisted",
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch shortlisted applications"})
			return
		}


		totalRejected, err = dc.ApplicationCollection.CountDocuments(ctx, bson.M{
			"job_id": bson.M{"$in": jobIDs},
			"status": "rejected",
		})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rejected applications"})
			return
		}
	}


	pipeline := []bson.M{
		{
			"$match": bson.M{"company_name.companyId": *recruiter.CompanyID},
		},
		{
			"$lookup": bson.M{
				"from":         "applications",
				"localField":   "_id",
				"foreignField": "job_id",
				"as":           "applications",
			},
		},
		{
			"$addFields": bson.M{
				"totalApplications": bson.M{"$size": "$applications"},
				"shortlistedCount": bson.M{
					"$size": bson.M{
						"$filter": bson.M{
							"input": "$applications",
							"cond":  bson.M{"$eq": []interface{}{"$$this.status", "shortlisted"}},
						},
					},
				},
				"rejectedCount": bson.M{
					"$size": bson.M{
						"$filter": bson.M{
							"input": "$applications",
							"cond":  bson.M{"$eq": []interface{}{"$$this.status", "rejected"}},
						},
					},
				},
				"selectedCount": bson.M{
					"$size": bson.M{
						"$filter": bson.M{
							"input": "$applications",
							"cond":  bson.M{"$eq": []interface{}{"$$this.status", "selected"}},
						},
					},
				},
			},
		},
		{
			"$project": bson.M{
				"_id":                  1,
				"position":             1,
				"status":               1,
				"created_at":           1,
				"application_deadline": 1,
				"salary_range":         1,
				"totalApplications":    1,
				"shortlistedCount":     1,
				"rejectedCount":        1,
				"selectedCount":        1,
			},
		},
		{
			"$sort": bson.M{"created_at": -1},
		},
		{
			"$limit": 5,
		},
	}

	cursor, err := dc.JobCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch job drive details"})
		return
	}

	var recentJobDrives []bson.M
	if err = cursor.All(ctx, &recentJobDrives); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode job drive details"})
		return
	}


	c.JSON(http.StatusOK, gin.H{
		"company": gin.H{
			"id":          company.ID,
			"name":        company.Name,
			"industry":    company.Industry,
			"description": company.Description,
			"website":     company.Website,
		},
		"overview": gin.H{
			"totalJobDrives":    totalJobDrives,
			"activeJobDrives":   activeJobDrives,
			"totalApplications": totalApplications,
			"totalShortlisted":  totalShortlisted,
			"totalRejected":     totalRejected,
		},
		"recentJobDrives": recentJobDrives,
		"recruiterName":   recruiter.FirstName + " " + recruiter.LastName,
	})
}
func (dc *DashboardController) UpdateSkills(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	studentID, _ := primitive.ObjectIDFromHex(userIDHex.(string))


	var req UpdateSkillsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}


	update := bson.M{
		"$set": bson.M{
			"skills": req.Skills,
		},
	}


	_, err := dc.UserCollection.UpdateByID(ctx, studentID, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update skills in the database"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Skills updated successfully", "skills": req.Skills})
}


func (dc *DashboardController) CreateDrive(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	tpoID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid TPO ID"})
		return
	}

	var job models.Job
	if err := c.ShouldBindJSON(&job); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}




	if job.Position == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Position is required"})
		return
	}
	if job.CompanyName.Name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Company name is required"})
		return
	}
	if job.Description == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Job description is required"})
		return
	}


	if !job.CompanyName.CompanyID.IsZero() {
		var company models.Company
		err = dc.CompanyCollection.FindOne(ctx, bson.M{"_id": job.CompanyName.CompanyID}).Decode(&company)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid company ID - company not found"})
			return
		}
	}


	if job.ApplicationDeadline.Before(time.Now()) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Application deadline must be in the future"})
		return
	}


	if job.Eligibility.MinCGPA < 0 || job.Eligibility.MinCGPA > 10 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Minimum CGPA must be between 0 and 10"})
		return
	}


	if job.Eligibility.GraduationYear != 0 {
		currentYear := time.Now().Year()
		if job.Eligibility.GraduationYear < currentYear || job.Eligibility.GraduationYear > currentYear+10 {
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Graduation year must be between %d and %d", currentYear, currentYear+10)})
			return
		}
	}


	if job.Eligibility.MaxBacklogs < 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Maximum backlogs cannot be negative"})
		return
	}


	if job.Location == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Job location is required"})
		return
	}


	job.ID = primitive.NewObjectID()
	job.PostedBy = tpoID
	job.CreatedAt = time.Now()
	job.Status = "open"


	_, err = dc.JobCollection.InsertOne(ctx, job)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create drive"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Drive created successfully",
		"driveId": job.ID,
	})
}


func (dc *DashboardController) SendNotification(c *gin.Context) {
	type NotificationRequest struct {
		Subject    string   `json:"subject" binding:"required"`
		Message    string   `json:"message" binding:"required"`
		StudentIDs []string `json:"studentIds" binding:"required"`
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	var req NotificationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}


	if len(req.StudentIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "At least one student ID must be provided"})
		return
	}


	var studentObjectIDs []primitive.ObjectID
	for _, idStr := range req.StudentIDs {
		objectID, err := primitive.ObjectIDFromHex(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid student ID format: " + idStr})
			return
		}
		studentObjectIDs = append(studentObjectIDs, objectID)
	}


	notification := models.Notification{
		ID:        primitive.NewObjectID(),
		Subject:   req.Subject,
		Message:   req.Message,
		IsRead:    false,
		CreatedAt: time.Now(),
	}


	filter := bson.M{
		"_id":  bson.M{"$in": studentObjectIDs},
		"role": "student",
	}


	update := bson.M{
		"$push": bson.M{
			"notifications": notification,
		},
	}

	result, err := dc.UserCollection.UpdateMany(ctx, filter, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send notifications"})
		return
	}


	if result.ModifiedCount != int64(len(req.StudentIDs)) {
		c.JSON(http.StatusPartialContent, gin.H{
			"message":         "Notification sent with warnings",
			"recipientsCount": result.ModifiedCount,
			"requestedCount":  len(req.StudentIDs),
			"notificationId":  notification.ID,
			"warning":         "Some student IDs were not found or are not students",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":         "Notification sent successfully",
		"recipientsCount": result.ModifiedCount,
		"notificationId":  notification.ID,
	})
}


func (dc *DashboardController) GenerateReport(c *gin.Context) {
	type ReportRequest struct {
		ReportType string `json:"reportType" binding:"required"`
		Department string `json:"department,omitempty"`
		StartDate  string `json:"startDate,omitempty"`
		EndDate    string `json:"endDate,omitempty"`
	}

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	var req ReportRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	switch req.ReportType {
	case "placement":
		dc.generatePlacementReport(c, ctx, req)
	case "applications":
		dc.generateApplicationReport(c, ctx, req)
	case "companies":
		dc.generateCompanyReport(c, ctx, req)
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid report type"})
	}
}



func (dc *DashboardController) generatePlacementReport(c *gin.Context, ctx context.Context, req struct {
	ReportType string `json:"reportType" binding:"required"`
	Department string `json:"department,omitempty"`
	StartDate  string `json:"startDate,omitempty"`
	EndDate    string `json:"endDate,omitempty"`
}) {

	pipeline := []bson.M{
		{
			"$lookup": bson.M{
				"from":         "applications",
				"localField":   "_id",
				"foreignField": "student_id",
				"as":           "applications",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "applications.job_id",
				"foreignField": "_id",
				"as":           "jobs",
			},
		},
		{
			"$addFields": bson.M{
				"placedApplications": bson.M{
					"$filter": bson.M{
						"input": "$applications",
						"cond":  bson.M{"$eq": []interface{}{"$$this.status", "selected"}},
					},
				},
			},
		},
		{
			"$addFields": bson.M{
				"isPlaced": bson.M{"$gt": []interface{}{bson.M{"$size": "$placedApplications"}, 0}},
			},
		},
	}


	if req.Department != "" {
		pipeline = append([]bson.M{
			{"$match": bson.M{"role": "student", "department": req.Department}},
		}, pipeline...)
	} else {
		pipeline = append([]bson.M{
			{"$match": bson.M{"role": "student"}},
		}, pipeline...)
	}

	cursor, err := dc.UserCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate placement report"})
		return
	}

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode placement report"})
		return
	}


	totalStudents := len(results)
	placedStudents := 0
	var placedStudentsList []gin.H

	for _, student := range results {
		if isPlaced, ok := student["isPlaced"].(bool); ok && isPlaced {
			placedStudents++
			placedStudentsList = append(placedStudentsList, gin.H{
				"name":       student["firstName"].(string) + " " + student["lastName"].(string),
				"email":      student["email"],
				"department": student["department"],
				"cgpa":       student["cgpa"],
			})
		}
	}

	placementRate := 0.0
	if totalStudents > 0 {
		placementRate = float64(placedStudents) / float64(totalStudents) * 100
	}

	c.JSON(http.StatusOK, gin.H{
		"reportType":         "placement",
		"department":         req.Department,
		"totalStudents":      totalStudents,
		"placedStudents":     placedStudents,
		"placementRate":      placementRate,
		"placedStudentsList": placedStudentsList,
		"generatedAt":        time.Now(),
	})
}

func (dc *DashboardController) generateApplicationReport(c *gin.Context, ctx context.Context, req struct {
	ReportType string `json:"reportType" binding:"required"`
	Department string `json:"department,omitempty"`
	StartDate  string `json:"startDate,omitempty"`
	EndDate    string `json:"endDate,omitempty"`
}) {
	pipeline := []bson.M{
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "job_id",
				"foreignField": "_id",
				"as":           "job",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": "$job",
		},
	}


	if req.StartDate != "" && req.EndDate != "" {
		startDate, _ := time.Parse("2006-01-02", req.StartDate)
		endDate, _ := time.Parse("2006-01-02", req.EndDate)

		pipeline = append(pipeline, bson.M{
			"$match": bson.M{
				"applied_on": bson.M{
					"$gte": startDate,
					"$lte": endDate,
				},
			},
		})
	}


	if req.Department != "" {
		pipeline = append(pipeline, bson.M{
			"$match": bson.M{"student.department": req.Department},
		})
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate application report"})
		return
	}

	var applications []bson.M
	if err = cursor.All(ctx, &applications); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode application report"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"reportType":        "applications",
		"department":        req.Department,
		"totalApplications": len(applications),
		"applications":      applications,
		"generatedAt":       time.Now(),
	})
}

func (dc *DashboardController) generateCompanyReport(c *gin.Context, ctx context.Context, req struct {
	ReportType string `json:"reportType" binding:"required"`
	Department string `json:"department,omitempty"`
	StartDate  string `json:"startDate,omitempty"`
	EndDate    string `json:"endDate,omitempty"`
}) {
	pipeline := []bson.M{
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "_id",
				"foreignField": "company_name.companyId",
				"as":           "jobs",
			},
		},
		{
			"$addFields": bson.M{
				"totalJobs": bson.M{"$size": "$jobs"},
				"activeJobs": bson.M{
					"$size": bson.M{
						"$filter": bson.M{
							"input": "$jobs",
							"cond":  bson.M{"$eq": []interface{}{"$$this.status", "open"}},
						},
					},
				},
			},
		},
	}

	cursor, err := dc.CompanyCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate company report"})
		return
	}

	var companies []bson.M
	if err = cursor.All(ctx, &companies); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode company report"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"reportType":     "companies",
		"totalCompanies": len(companies),
		"companies":      companies,
		"generatedAt":    time.Now(),
	})
}




func (dc *DashboardController) GetAllDrives(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	pipeline := []bson.M{
		{
			"$lookup": bson.M{
				"from":         "applications",
				"localField":   "_id",
				"foreignField": "job_id",
				"as":           "applications",
			},
		},
		{
			"$addFields": bson.M{
				"applicantCount": bson.M{"$size": "$applications"},
			},
		},
		{
			"$sort": bson.M{"created_at": -1},
		},
	}

	cursor, err := dc.JobCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch drives"})
		return
	}

	var drives []bson.M
	if err = cursor.All(ctx, &drives); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode drives"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"drives": drives,
		"total":  len(drives),
	})
}


func (dc *DashboardController) GetDriveDetails(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	driveID := c.Param("driveId")
	objectID, err := primitive.ObjectIDFromHex(driveID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid drive ID"})
		return
	}


	var drive models.Job
	err = dc.JobCollection.FindOne(ctx, bson.M{"_id": objectID}).Decode(&drive)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Drive not found"})
		return
	}


	cursor, err := dc.ApplicationCollection.Find(ctx, bson.M{"job_id": objectID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch applications"})
		return
	}

	var applications []models.Application
	if err = cursor.All(ctx, &applications); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode applications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"drive":        drive,
		"applications": applications,
		"stats": gin.H{
			"totalApplications": len(applications),
			"applied":           len(applications),
		},
	})
}


func (dc *DashboardController) GetDriveApplications(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	driveID := c.Param("driveId")
	objectID, err := primitive.ObjectIDFromHex(driveID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid drive ID"})
		return
	}


	pipeline := []bson.M{
		{
			"$match": bson.M{"job_id": objectID},
		},
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "resumes",
				"localField":   "resume_id",
				"foreignField": "_id",
				"as":           "resume",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": bson.M{
				"path":                       "$resume",
				"preserveNullAndEmptyArrays": true,
			},
		},
		{
			"$project": bson.M{
				"_id":        1,
				"status":     1,
				"applied_on": 1,
				"remarks":    1,
				"student": bson.M{
					"_id":        "$student._id",
					"firstName":  "$student.firstName",
					"lastName":   "$student.lastName",
					"email":      "$student.email",
					"department": "$student.department",
					"cgpa":       "$student.cgpa",
					"skills":     "$student.skills",
				},
				"resume": bson.M{
					"_id":      "$resume._id",
					"file_url": "$resume.file_url",
				},
			},
		},
		{
			"$sort": bson.M{"applied_on": -1},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch applications"})
		return
	}

	var applications []bson.M
	if err = cursor.All(ctx, &applications); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode applications"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"applications": applications,
		"total":        len(applications),
	})
}


func (dc *DashboardController) UpdateDriveStatus(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	driveID := c.Param("driveId")
	objectID, err := primitive.ObjectIDFromHex(driveID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid drive ID"})
		return
	}

	type StatusUpdate struct {
		Status string `json:"status" binding:"required"`
	}

	var req StatusUpdate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}


	if req.Status != "open" && req.Status != "closed" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status must be 'open' or 'closed'"})
		return
	}


	update := bson.M{
		"$set": bson.M{
			"status": req.Status,
		},
	}

	result, err := dc.JobCollection.UpdateByID(ctx, objectID, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update drive status"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Drive not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Drive status updated successfully",
		"status":  req.Status,
	})
}




func (dc *DashboardController) GetCompanyWisePlacements(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	pipeline := []bson.M{
		{
			"$match": bson.M{"status": "selected"},
		},
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "job_id",
				"foreignField": "_id",
				"as":           "job",
			},
		},
		{
			"$unwind": "$job",
		},
		{
			"$group": bson.M{
				"_id":            "$job.company_name.name",
				"placementCount": bson.M{"$sum": 1},
				"positions":      bson.M{"$addToSet": "$job.position"},
				"salaryRanges":   bson.M{"$addToSet": "$job.salary_range"},
			},
		},
		{
			"$sort": bson.M{"placementCount": -1},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch company-wise placements"})
		return
	}

	var placements []bson.M
	if err = cursor.All(ctx, &placements); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode placements"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"companyWisePlacements": placements,
		"totalCompanies":        len(placements),
		"generatedAt":           time.Now(),
	})
}


func (dc *DashboardController) GetSalaryAnalytics(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	pipeline := []bson.M{
		{
			"$match": bson.M{"status": "selected"},
		},
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "job_id",
				"foreignField": "_id",
				"as":           "job",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": "$job",
		},
		{
			"$addFields": bson.M{
				"salaryAmount": bson.M{
					"$toDouble": bson.M{
						"$arrayElemAt": []interface{}{
							bson.M{
								"$split": []interface{}{"$job.salary_range", " "},
							},
							0,
						},
					},
				},
			},
		},
		{
			"$group": bson.M{
				"_id": "$student.department",
				"averageSalary": bson.M{
					"$avg": "$salaryAmount",
				},
				"maxSalary": bson.M{
					"$max": "$salaryAmount",
				},
				"minSalary": bson.M{
					"$min": "$salaryAmount",
				},
				"placementCount": bson.M{"$sum": 1},
			},
		},
		{
			"$sort": bson.M{"averageSalary": -1},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch salary analytics"})
		return
	}

	var salaryData []bson.M
	if err = cursor.All(ctx, &salaryData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode salary data"})
		return
	}


	mockSalaryData := []gin.H{
		{"department": "CS", "averageSalary": "XXX,XXX", "placementCount": 20},
		{"department": "ME", "averageSalary": "XYY,YYY", "placementCount": 15},
		{"department": "EE", "averageSalary": "XZZ,ZZZ", "placementCount": 12},
	}

	c.JSON(http.StatusOK, gin.H{
		"salaryByDepartment": mockSalaryData,
		"actualData":         salaryData,
		"generatedAt":        time.Now(),
	})
}


func (dc *DashboardController) GetPlacementTrends(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()


	pipeline := []bson.M{
		{
			"$match": bson.M{"status": "selected"},
		},
		{
			"$group": bson.M{
				"_id": bson.M{
					"year":  bson.M{"$year": "$applied_on"},
					"month": bson.M{"$month": "$applied_on"},
				},
				"placementCount": bson.M{"$sum": 1},
			},
		},
		{
			"$sort": bson.M{"_id.year": 1, "_id.month": 1},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch placement trends"})
		return
	}

	var trends []bson.M
	if err = cursor.All(ctx, &trends); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode trends"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"placementTrends": trends,
		"generatedAt":     time.Now(),
	})
}


func (dc *DashboardController) ExportReport(c *gin.Context) {
	reportType := c.Query("type")
	format := c.Query("format")

	if reportType == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Report type is required"})
		return
	}

	if format == "" {
		format = "pdf"
	}


	c.JSON(http.StatusOK, gin.H{
		"message":     "Report export initiated",
		"reportType":  reportType,
		"format":      format,
		"downloadUrl": "/api/v1/tpo/reports/download/" + reportType + "." + format,
		"generatedAt": time.Now(),
	})
}





func (dc *DashboardController) PreviewNotification(c *gin.Context) {
	type PreviewRequest struct {
		Subject    string   `json:"subject" binding:"required"`
		Message    string   `json:"message" binding:"required"`
		StudentIDs []string `json:"studentIds" binding:"required"`
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var req PreviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}


	if len(req.StudentIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "At least one student ID must be provided"})
		return
	}


	var studentObjectIDs []primitive.ObjectID
	for _, idStr := range req.StudentIDs {
		objectID, err := primitive.ObjectIDFromHex(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid student ID format: " + idStr})
			return
		}
		studentObjectIDs = append(studentObjectIDs, objectID)
	}


	filter := bson.M{
		"_id":  bson.M{"$in": studentObjectIDs},
		"role": "student",
	}


	recipientCount, err := dc.UserCollection.CountDocuments(ctx, filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to count recipients"})
		return
	}


	cursor, err := dc.UserCollection.Find(ctx, filter, options.Find().SetProjection(bson.M{
		"firstName":  1,
		"lastName":   1,
		"email":      1,
		"rollNumber": 1,
		"department": 1,
	}))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch student details"})
		return
	}

	var students []bson.M
	if err = cursor.All(ctx, &students); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode student details"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"preview": gin.H{
			"subject":           req.Subject,
			"message":           req.Message,
			"recipientCount":    recipientCount,
			"requestedCount":    len(req.StudentIDs),
			"students":          students,
			"estimatedDelivery": "Immediate",
		},
	})
}


func (dc *DashboardController) GetNotificationHistory(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()



	pipeline := []bson.M{
		{
			"$match": bson.M{"role": "student"},
		},
		{
			"$unwind": "$notifications",
		},
		{
			"$group": bson.M{
				"_id":     "$notifications._id",
				"subject": bson.M{"$first": "$notifications.subject"},
				"message": bson.M{"$first": "$notifications.message"},
				"sentAt":  bson.M{"$first": "$notifications.createdAt"},
				"recipients": bson.M{
					"$push": bson.M{
						"studentId":  "$_id",
						"name":       bson.M{"$concat": []interface{}{"$firstName", " ", "$lastName"}},
						"email":      "$email",
						"department": "$department",
						"isRead":     "$notifications.isRead",
					},
				},
				"recipientCount": bson.M{"$sum": 1},
			},
		},
		{
			"$sort": bson.M{"sentAt": -1},
		},
		{
			"$limit": 50,
		},
	}

	cursor, err := dc.UserCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch notification history"})
		return
	}

	var notificationHistory []bson.M
	if err = cursor.All(ctx, &notificationHistory); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode notification history"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"notifications": notificationHistory,
		"total":         len(notificationHistory),
	})
}




func (dc *DashboardController) GetRecruiterCandidates(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}


	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusOK, gin.H{
			"candidates":       []gin.H{},
			"total":            0,
			"message":          "No company associated. Please contact admin to associate your account with a company.",
			"jobPosition":      "",
			"totalShortlisted": 0,
		})
		return
	}


	jobCursor, err := dc.JobCollection.Find(ctx, bson.M{"company_name.companyId": *recruiter.CompanyID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch company jobs"})
		return
	}

	var jobs []models.Job
	if err = jobCursor.All(ctx, &jobs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode jobs"})
		return
	}


	var jobIDs []primitive.ObjectID
	for _, job := range jobs {
		jobIDs = append(jobIDs, job.ID)
	}

	if len(jobIDs) == 0 {
		c.JSON(http.StatusOK, gin.H{
			"candidates": []gin.H{},
			"total":      0,
			"message":    "No candidates found for your company",
		})
		return
	}


	pipeline := []bson.M{
		{
			"$match": bson.M{
				"job_id": bson.M{"$in": jobIDs},
				"status": "shortlisted",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "job_id",
				"foreignField": "_id",
				"as":           "job",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "resumes",
				"localField":   "resume_id",
				"foreignField": "_id",
				"as":           "resume",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": "$job",
		},
		{
			"$unwind": bson.M{
				"path":                       "$resume",
				"preserveNullAndEmptyArrays": true,
			},
		},
		{
			"$project": bson.M{
				"_id": 1,
				"student": bson.M{
					"name":       bson.M{"$concat": []interface{}{"$student.firstName", " ", "$student.lastName"}},
					"email":      "$student.email",
					"department": "$student.department",
					"cgpa":       "$student.cgpa",
					"skills":     "$student.skills",
				},
				"job": bson.M{
					"position": "$job.position",
					"title":    "$job.position",
				},
				"resume": bson.M{
					"file_url": "$resume.file_url",
				},
				"appliedOn": "$applied_on",
			},
		},
		{
			"$sort": bson.M{"appliedOn": -1},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch candidates"})
		return
	}

	var candidates []bson.M
	if err = cursor.All(ctx, &candidates); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode candidates"})
		return
	}


	mockCandidates := []gin.H{
		{
			"studentName": "Priya Sharma",
			"department":  "CS",
			"gpa":         9.2,
			"keySkills":   "Python, ML, AWS",
			"resumeUrl":   "/api/v1/resumes/download/resume1.pdf",
		},
		{
			"studentName": "Rahul Verma",
			"department":  "IT",
			"gpa":         8.8,
			"keySkills":   "Java, SQL, JS",
			"resumeUrl":   "/api/v1/resumes/download/resume2.pdf",
		},
		{
			"studentName": "Anjali Singh",
			"department":  "CS",
			"gpa":         8.5,
			"keySkills":   "C++, DS, Algo",
			"resumeUrl":   "/api/v1/resumes/download/resume3.pdf",
		},
	}

	c.JSON(http.StatusOK, gin.H{
		"candidates":       mockCandidates,
		"actualData":       candidates,
		"total":            len(mockCandidates),
		"jobPosition":      "Software Engineer",
		"totalShortlisted": 15,
	})
}


func (dc *DashboardController) DownloadAllResumes(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}

	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusOK, gin.H{
			"message":        "No company associated. Cannot generate resume zip file.",
			"downloadUrl":    "",
			"fileSize":       "0 MB",
			"candidateCount": 0,
			"note":           "Please contact admin to associate your account with a company.",
		})
		return
	}




	c.JSON(http.StatusOK, gin.H{
		"message":        "Resume zip file generation initiated",
		"downloadUrl":    "/api/v1/recruiter/resumes/download/shortlisted_candidates.zip",
		"fileSize":       "2.5 MB",
		"candidateCount": 15,
		"expiresAt":      time.Now().Add(24 * time.Hour),
	})
}


func (dc *DashboardController) GetCompanyJobDrives(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}

	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusOK, gin.H{
			"jobDrives": []gin.H{},
			"total":     0,
			"message":   "No company associated. Please contact admin to associate your account with a company.",
		})
		return
	}


	pipeline := []bson.M{
		{
			"$match": bson.M{"company_name.companyId": *recruiter.CompanyID},
		},
		{
			"$lookup": bson.M{
				"from":         "applications",
				"localField":   "_id",
				"foreignField": "job_id",
				"as":           "applications",
			},
		},
		{
			"$addFields": bson.M{
				"totalApplications": bson.M{"$size": "$applications"},
				"shortlistedCount": bson.M{
					"$size": bson.M{
						"$filter": bson.M{
							"input": "$applications",
							"cond":  bson.M{"$eq": []interface{}{"$$this.status", "shortlisted"}},
						},
					},
				},
				"selectedCount": bson.M{
					"$size": bson.M{
						"$filter": bson.M{
							"input": "$applications",
							"cond":  bson.M{"$eq": []interface{}{"$$this.status", "selected"}},
						},
					},
				},
			},
		},
		{
			"$sort": bson.M{"created_at": -1},
		},
	}

	cursor, err := dc.JobCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch company job drives"})
		return
	}

	var jobDrives []bson.M
	if err = cursor.All(ctx, &jobDrives); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode job drives"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"jobDrives": jobDrives,
		"total":     len(jobDrives),
	})
}


func (dc *DashboardController) SearchStudents(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	searchQuery := c.Query("q")
	department := c.Query("department")
	limit := c.DefaultQuery("limit", "20")


	limitInt := 20
	if l, err := strconv.Atoi(limit); err == nil && l > 0 && l <= 100 {
		limitInt = l
	}


	filter := bson.M{"role": "student"}


	if searchQuery != "" {

		searchRegex := bson.M{"$regex": searchQuery, "$options": "i"}
		filter["$or"] = []bson.M{
			{"firstName": searchRegex},
			{"lastName": searchRegex},
			{"email": searchRegex},
			{"rollNumber": searchRegex},
		}
	}


	if department != "" {
		filter["department"] = department
	}


	fmt.Printf("SearchStudents filter: %+v\n", filter)


	totalStudents, err := dc.UserCollection.CountDocuments(ctx, bson.M{"role": "student"})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to count students",
			"details": err.Error(),
		})
		return
	}
	fmt.Printf("Total students in database: %d\n", totalStudents)


	findOptions := options.Find().
		SetLimit(int64(limitInt)).
		SetProjection(bson.M{
			"_id":        1,
			"firstName":  1,
			"lastName":   1,
			"email":      1,
			"rollNumber": 1,
			"department": 1,
			"cgpa":       1,
		}).
		SetSort(bson.D{
			{Key: "firstName", Value: 1},
			{Key: "lastName", Value: 1},
		})

	cursor, err := dc.UserCollection.Find(ctx, filter, findOptions)
	if err != nil {

		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to search students",
			"details": err.Error(),
			"filter":  filter,
		})
		return
	}

	var students []bson.M
	if err = cursor.All(ctx, &students); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode student results"})
		return
	}


	totalCount, err := dc.UserCollection.CountDocuments(ctx, filter)
	if err != nil {
		totalCount = int64(len(students))
	}

	c.JSON(http.StatusOK, gin.H{
		"students":    students,
		"total":       totalCount,
		"limit":       limitInt,
		"hasMore":     totalCount > int64(len(students)),
		"searchQuery": searchQuery,
		"department":  department,
	})
}




func (dc *DashboardController) GetJobDriveDetails(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}


	jobDriveID := c.Param("jobId")
	jobDriveObjectID, err := primitive.ObjectIDFromHex(jobDriveID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job drive ID"})
		return
	}


	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusOK, gin.H{
			"jobDrive":   nil,
			"candidates": []gin.H{},
			"message":    "No company associated. Please contact admin.",
		})
		return
	}


	var jobDrive models.Job
	err = dc.JobCollection.FindOne(ctx, bson.M{
		"_id":                    jobDriveObjectID,
		"company_name.companyId": *recruiter.CompanyID,
	}).Decode(&jobDrive)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Job drive not found or not accessible"})
		return
	}


	pipeline := []bson.M{
		{
			"$match": bson.M{"job_id": jobDriveObjectID},
		},
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "resumes",
				"localField":   "resume_id",
				"foreignField": "_id",
				"as":           "resume",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": bson.M{
				"path":                       "$resume",
				"preserveNullAndEmptyArrays": true,
			},
		},
		{
			"$project": bson.M{
				"_id":        1,
				"status":     1,
				"applied_on": 1,
				"remarks":    1,
				"student": bson.M{
					"_id":             "$student._id",
					"firstName":       "$student.firstName",
					"lastName":        "$student.lastName",
					"email":           "$student.email",
					"rollNumber":      "$student.rollNumber",
					"department":      "$student.department",
					"cgpa":            "$student.cgpa",
					"skills":          "$student.skills",
					"placementStatus": "$student.placedStatus",
					"gender":          "$student.gender",
				},
				"resume": bson.M{
					"_id":      "$resume._id",
					"file_url": "$resume.file_url",
				},
			},
		},
		{
			"$sort": bson.M{"applied_on": -1},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch job drive applications"})
		return
	}

	var applications []bson.M
	if err = cursor.All(ctx, &applications); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode applications"})
		return
	}


	totalApplications := len(applications)
	statusCounts := map[string]int{
		"applied":     0,
		"shortlisted": 0,
		"rejected":    0,
		"selected":    0,
		"interviewed": 0,
	}

	for _, app := range applications {
		if status, ok := app["status"].(string); ok {
			statusCounts[status]++
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"jobDrive": gin.H{
			"_id":                  jobDrive.ID,
			"position":             jobDrive.Position,
			"company":              jobDrive.CompanyName,
			"description":          jobDrive.Description,
			"salary_range":         jobDrive.SalaryRange,
			"location":             jobDrive.Location,
			"application_deadline": jobDrive.ApplicationDeadline,
			"status":               jobDrive.Status,
			"created_at":           jobDrive.CreatedAt,
			"eligibility":          jobDrive.Eligibility,
		},
		"statistics": gin.H{
			"totalApplications": totalApplications,
			"applied":           statusCounts["applied"],
			"shortlisted":       statusCounts["shortlisted"],
			"rejected":          statusCounts["rejected"],
			"selected":          statusCounts["selected"],
			"interviewed":       statusCounts["interviewed"],
		},
		"candidates": applications,
	})
}


func (dc *DashboardController) GetStudentDetailsForJobDrive(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}


	jobDriveID := c.Param("jobId")
	studentID := c.Param("studentId")

	jobDriveObjectID, err := primitive.ObjectIDFromHex(jobDriveID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job drive ID"})
		return
	}

	studentObjectID, err := primitive.ObjectIDFromHex(studentID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid student ID"})
		return
	}


	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusOK, gin.H{
			"student": nil,
			"message": "No company associated. Please contact admin.",
		})
		return
	}


	var jobDrive models.Job
	err = dc.JobCollection.FindOne(ctx, bson.M{
		"_id":                    jobDriveObjectID,
		"company_name.companyId": *recruiter.CompanyID,
	}).Decode(&jobDrive)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Job drive not found or not accessible"})
		return
	}


	pipeline := []bson.M{
		{
			"$match": bson.M{
				"job_id":     jobDriveObjectID,
				"student_id": studentObjectID,
			},
		},
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "resumes",
				"localField":   "resume_id",
				"foreignField": "_id",
				"as":           "resume",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": bson.M{
				"path":                       "$resume",
				"preserveNullAndEmptyArrays": true,
			},
		},
		{
			"$project": bson.M{
				"application": bson.M{
					"_id":        "$_id",
					"status":     "$status",
					"applied_on": "$applied_on",
					"remarks":    "$remarks",
				},
				"student": bson.M{
					"_id":             "$student._id",
					"firstName":       "$student.firstName",
					"lastName":        "$student.lastName",
					"email":           "$student.email",
					"rollNumber":      "$student.rollNumber",
					"department":      "$student.department",
					"cgpa":            "$student.cgpa",
					"skills":          "$student.skills",
					"placementStatus": "$student.placedStatus",
					"gender":          "$student.gender",
					"createdAt":       "$student.createdAt",
				},
				"resume": bson.M{
					"_id":        "$resume._id",
					"file_url":   "$resume.file_url",
					"parsedData": "$resume.parsedData",
				},
			},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch student details"})
		return
	}

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode student details"})
		return
	}

	if len(results) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Student application not found for this job drive"})
		return
	}

	studentData := results[0]





	c.JSON(http.StatusOK, gin.H{
		"jobDrive": gin.H{
			"_id":      jobDrive.ID,
			"position": jobDrive.Position,
			"company":  jobDrive.CompanyName,
		},
		"studentDetails": studentData,
	})
}


func (dc *DashboardController) UpdateStudentPlacementStatus(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}


	studentID := c.Param("studentId")
	studentObjectID, err := primitive.ObjectIDFromHex(studentID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid student ID"})
		return
	}


	type ApplicationStatusUpdate struct {
		Status  string `json:"status" binding:"required"`
		JobID   string `json:"jobId" binding:"required"`
		Remarks string `json:"remarks,omitempty"`
	}

	var req ApplicationStatusUpdate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}


	jobObjectID, err := primitive.ObjectIDFromHex(req.JobID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job ID"})
		return
	}


	validStatuses := []string{"applied", "shortlisted", "selected", "rejected", "interviewed"}
	isValidStatus := false
	for _, status := range validStatuses {
		if req.Status == status {
			isValidStatus = true
			break
		}
	}

	if !isValidStatus {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":         "Invalid application status",
			"validStatuses": validStatuses,
		})
		return
	}


	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No company associated. Cannot update application status."})
		return
	}


	var job models.Job
	err = dc.JobCollection.FindOne(ctx, bson.M{
		"_id":                    jobObjectID,
		"company_name.companyId": *recruiter.CompanyID,
	}).Decode(&job)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Job not found or not accessible"})
		return
	}


	var application models.Application
	err = dc.ApplicationCollection.FindOne(ctx, bson.M{
		"job_id":     jobObjectID,
		"student_id": studentObjectID,
	}).Decode(&application)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Application not found"})
		return
	}


	update := bson.M{
		"$set": bson.M{
			"status":     req.Status,
			"updated_on": time.Now(),
			"remarks":    req.Remarks,
		},
	}

	result, err := dc.ApplicationCollection.UpdateByID(ctx, application.ID, update)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update application status"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Application not found"})
		return
	}


	pipeline := []bson.M{
		{
			"$match": bson.M{"_id": application.ID},
		},
		{
			"$lookup": bson.M{
				"from":         "users",
				"localField":   "student_id",
				"foreignField": "_id",
				"as":           "student",
			},
		},
		{
			"$lookup": bson.M{
				"from":         "jobs",
				"localField":   "job_id",
				"foreignField": "_id",
				"as":           "job",
			},
		},
		{
			"$unwind": "$student",
		},
		{
			"$unwind": "$job",
		},
		{
			"$project": bson.M{
				"_id":        1,
				"status":     1,
				"updated_on": 1,
				"remarks":    1,
				"student": bson.M{
					"_id":       "$student._id",
					"firstName": "$student.firstName",
					"lastName":  "$student.lastName",
					"email":     "$student.email",
				},
				"job": bson.M{
					"_id":      "$job._id",
					"position": "$job.position",
					"company":  "$job.company_name",
				},
			},
		},
	}

	cursor, err := dc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch updated application data"})
		return
	}

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode updated application"})
		return
	}

	var updatedApplication bson.M
	if len(results) > 0 {
		updatedApplication = results[0]
	}

	c.JSON(http.StatusOK, gin.H{
		"message":     "Application status updated successfully",
		"application": updatedApplication,
		"updatedBy": gin.H{
			"recruiterId":   recruiter.ID,
			"recruiterName": recruiter.FirstName + " " + recruiter.LastName,
			"company":       recruiter.CompanyID,
		},
	})
}


func (dc *DashboardController) UpdateStudentApplicationStatus(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}


	jobID := c.Param("jobId")
	jobObjectID, err := primitive.ObjectIDFromHex(jobID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job ID"})
		return
	}




	type StudentStatusUpdate struct {
		StudentID string `json:"studentId" binding:"required"`
		Status    string `json:"status" binding:"required"`
		Remarks   string `json:"remarks,omitempty"`
	}

	type BulkStatusUpdateRequest struct {
		Updates []StudentStatusUpdate `json:"updates" binding:"required"`
	}

	var req BulkStatusUpdateRequest


	bodyBytes, err := c.GetRawData()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body", "details": err.Error()})
		return
	}


	if err := json.Unmarshal(bodyBytes, &req); err != nil {

		var compact []struct {
			ID      string `json:"id"`
			Status  string `json:"status"`
			Remarks string `json:"remarks,omitempty"`
		}
		if err2 := json.Unmarshal(bodyBytes, &compact); err2 != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format", "details": err.Error()})
			return
		}

		for _, v := range compact {

			normalized := strings.ToLower(v.Status)
			req.Updates = append(req.Updates, StudentStatusUpdate{StudentID: v.ID, Status: normalized, Remarks: v.Remarks})
		}
	} else {

		for i := range req.Updates {
			req.Updates[i].Status = strings.ToLower(req.Updates[i].Status)
		}
	}

	if len(req.Updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "At least one student update is required"})
		return
	}


	validStatuses := []string{"applied", "shortlisted", "selected", "rejected", "interviewed"}
	for _, update := range req.Updates {
		isValidStatus := false
		for _, status := range validStatuses {
			if update.Status == status {
				isValidStatus = true
				break
			}
		}
		if !isValidStatus {
			c.JSON(http.StatusBadRequest, gin.H{
				"error":         "Invalid application status: " + update.Status,
				"validStatuses": validStatuses,
			})
			return
		}
	}


	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No company associated. Cannot update application status."})
		return
	}


	var job models.Job
	err = dc.JobCollection.FindOne(ctx, bson.M{
		"_id":                    jobObjectID,
		"company_name.companyId": *recruiter.CompanyID,
	}).Decode(&job)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Job not found or not accessible"})
		return
	}


	successCount := 0
	failedCount := 0
	var updateResults []gin.H


	statusGroups := make(map[string][]primitive.ObjectID)

	for _, update := range req.Updates {
		studentObjectID, err := primitive.ObjectIDFromHex(update.StudentID)
		if err != nil {
			failedCount++
			updateResults = append(updateResults, gin.H{
				"studentId": update.StudentID,
				"status":    "failed",
				"error":     "Invalid student ID",
			})
			continue
		}


		filter := bson.M{
			"job_id":     jobObjectID,
			"student_id": studentObjectID,
		}

		updateDoc := bson.M{
			"$set": bson.M{
				"status":     update.Status,
				"updated_on": time.Now(),
			},
		}

		result, err := dc.ApplicationCollection.UpdateOne(ctx, filter, updateDoc)
		if err != nil || result.MatchedCount == 0 {
			failedCount++
			updateResults = append(updateResults, gin.H{
				"studentId": update.StudentID,
				"status":    "failed",
				"error":     "Application not found or update failed",
			})
			continue
		}

		successCount++
		updateResults = append(updateResults, gin.H{
			"studentId": update.StudentID,
			"status":    "success",
			"newStatus": update.Status,
		})


		if statusGroups[update.Status] == nil {
			statusGroups[update.Status] = []primitive.ObjectID{}
		}
		statusGroups[update.Status] = append(statusGroups[update.Status], studentObjectID)
	}


	notificationsSent := 0
	companyName := job.CompanyName.Name
	position := job.Position

	for status, studentIDs := range statusGroups {
		var notification models.Notification


		switch status {
		case "shortlisted":
			notification = models.Notification{
				ID:        primitive.NewObjectID(),
				Subject:   "Congratulations! You've been shortlisted",
				Message:   fmt.Sprintf("Great news! Your application for the position of %s at %s has been shortlisted. You will be contacted soon for the next round of the selection process. Please keep your phone and email accessible.", position, companyName),
				IsRead:    false,
				CreatedAt: time.Now(),
			}
		case "selected":
			notification = models.Notification{
				ID:        primitive.NewObjectID(),
				Subject:   "ðŸŽ‰ Congratulations! You've been selected",
				Message:   fmt.Sprintf("Congratulations! We are pleased to inform you that you have been selected for the position of %s at %s. Our HR team will contact you shortly with the offer letter and next steps. Well done!", position, companyName),
				IsRead:    false,
				CreatedAt: time.Now(),
			}
		case "rejected":
			notification = models.Notification{
				ID:        primitive.NewObjectID(),
				Subject:   "Application Status Update",
				Message:   fmt.Sprintf("Thank you for your interest in the position of %s at %s. After careful consideration, we regret to inform you that we are unable to proceed with your application at this time. We encourage you to apply for other suitable positions. Best wishes for your career!", position, companyName),
				IsRead:    false,
				CreatedAt: time.Now(),
			}
		case "interviewed":
			notification = models.Notification{
				ID:        primitive.NewObjectID(),
				Subject:   "Interview Scheduled",
				Message:   fmt.Sprintf("Your interview for the position of %s at %s has been scheduled. Please check your email for detailed information about the interview date, time, and venue. Prepare well and good luck!", position, companyName),
				IsRead:    false,
				CreatedAt: time.Now(),
			}
		default:

			continue
		}


		filter := bson.M{
			"_id":  bson.M{"$in": studentIDs},
			"role": "student",
		}

		updateDoc := bson.M{
			"$push": bson.M{
				"notifications": notification,
			},
		}

		result, err := dc.UserCollection.UpdateMany(ctx, filter, updateDoc)
		if err == nil {
			notificationsSent += int(result.ModifiedCount)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message":           "Bulk status update completed",
		"totalUpdates":      len(req.Updates),
		"successCount":      successCount,
		"failedCount":       failedCount,
		"notificationsSent": notificationsSent,
		"results":           updateResults,
		"job": gin.H{
			"id":       job.ID,
			"position": job.Position,
			"company":  companyName,
		},
		"updatedBy": gin.H{
			"recruiterId":   recruiter.ID,
			"recruiterName": recruiter.FirstName + " " + recruiter.LastName,
		},
	})
}


func (dc *DashboardController) GetRecruiterNotifications(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	userIDHex, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}


	var recruiter models.User
	err = dc.UserCollection.FindOne(ctx, bson.M{
		"_id":  recruiterID,
		"role": "rec",
	}).Decode(&recruiter)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch notifications"})
		return
	}


	notifications := recruiter.Notifications
	if notifications == nil {
		notifications = []models.Notification{}
	}

	c.JSON(http.StatusOK, gin.H{
		"notifications": notifications,
		"count":         len(notifications),
		"recruiter": gin.H{
			"id":      recruiter.ID,
			"name":    recruiter.FirstName + " " + recruiter.LastName,
			"company": recruiter.CompanyID,
		},
	})
}


func (dc *DashboardController) GetRecStats(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid recruiter ID"})
		return
	}

	var recruiter models.User
	if err := dc.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	if recruiter.CompanyID == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No company associated"})
		return
	}

	companyId := *recruiter.CompanyID



	jobCursor, err := dc.JobCollection.Find(ctx, bson.M{"company_name.companyId": companyId})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch jobs"})
		return
	}
	var jobs []models.Job
	if err := jobCursor.All(ctx, &jobs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode jobs"})
		return
	}
	var jobIDs []primitive.ObjectID
	for _, j := range jobs {
		jobIDs = append(jobIDs, j.ID)
	}


	quality := gin.H{"cgpaBands": []gin.H{}, "topDepartments": []gin.H{}}
	funnel := gin.H{}
	availability := gin.H{}
	skillFit := []gin.H{}

	applicationVelocity := []gin.H{}
	pipelineAging := gin.H{}
	var resumeRecency gin.H

	if len(jobIDs) > 0 {

		qPipeline := []bson.M{
			{"$match": bson.M{"job_id": bson.M{"$in": jobIDs}}},
			{"$lookup": bson.M{"from": "users", "localField": "student_id", "foreignField": "_id", "as": "student"}},
			{"$unwind": "$student"},
			{"$project": bson.M{"cgpa": "$student.cgpa", "department": "$student.department"}},
			{"$group": bson.M{"_id": "$department", "count": bson.M{"$sum": 1}}},
			{"$sort": bson.M{"count": -1}},
			{"$limit": 5},
		}
		cur, err := dc.ApplicationCollection.Aggregate(ctx, qPipeline)
		if err == nil {
			var deps []bson.M
			if err := cur.All(ctx, &deps); err == nil {
				var tops []gin.H
				for _, d := range deps {
					tops = append(tops, gin.H{"department": d["_id"], "count": d["count"]})
				}
				quality["topDepartments"] = tops
			}
		}


		cgpaPipeline := []bson.M{
			{"$match": bson.M{"job_id": bson.M{"$in": jobIDs}}},
			{"$lookup": bson.M{"from": "users", "localField": "student_id", "foreignField": "_id", "as": "student"}},
			{"$unwind": "$student"},
			{"$project": bson.M{"cgpa": "$student.cgpa"}},
			{"$bucket": bson.M{"groupBy": "$cgpa", "boundaries": []interface{}{0, 6.0, 7.5, 8.5, 10}, "default": "Unknown", "output": bson.M{"count": bson.M{"$sum": 1}}}},
		}
		cur2, err := dc.ApplicationCollection.Aggregate(ctx, cgpaPipeline)
		if err == nil {
			var bands []bson.M
			if err := cur2.All(ctx, &bands); err == nil {
				var out []gin.H
				for _, b := range bands {
					out = append(out, gin.H{"band": b["_id"], "count": b["count"]})
				}
				quality["cgpaBands"] = out
			}
		}


		funnelPipeline := []bson.M{
			{"$match": bson.M{"job_id": bson.M{"$in": jobIDs}}},
			{"$group": bson.M{"_id": "$status", "count": bson.M{"$sum": 1}}},
		}
		cur3, err := dc.ApplicationCollection.Aggregate(ctx, funnelPipeline)
		if err == nil {
			var groups []bson.M
			if err := cur3.All(ctx, &groups); err == nil {

				totalApplications := int64(0)
				counts := map[string]int64{}
				for _, g := range groups {
					status := "unknown"
					if s, ok := g["_id"].(string); ok {
						status = s
					}
					var cntInt int64
					if cnt, ok := g["count"].(int32); ok {
						cntInt = int64(cnt)
					} else if cnt64, ok := g["count"].(int64); ok {
						cntInt = cnt64
					}
					counts[status] = cntInt
					totalApplications += cntInt
				}

				var funnelArr []gin.H
				for _, st := range []string{"applied", "shortlisted", "interviewed", "selected", "rejected"} {
					cnt := counts[st]
					pct := 0.0
					if totalApplications > 0 {
						pct = (float64(cnt) / float64(totalApplications)) * 100.0
					}
					funnelArr = append(funnelArr, gin.H{"status": st, "count": cnt, "percent": math.Round(pct*100) / 100})
				}
				funnel = gin.H{"total": totalApplications, "series": funnelArr}
			}
		}


		availPipeline := []bson.M{
			{"$match": bson.M{"job_id": bson.M{"$in": jobIDs}}},
			{"$lookup": bson.M{"from": "users", "localField": "student_id", "foreignField": "_id", "as": "student"}},
			{"$unwind": "$student"},
			{"$group": bson.M{"_id": "$student.placedStatus", "count": bson.M{"$sum": 1}}},
		}
		cur4, err := dc.ApplicationCollection.Aggregate(ctx, availPipeline)
		if err == nil {
			var av []bson.M
			if err := cur4.All(ctx, &av); err == nil {
				for _, v := range av {
					key := "unknown"
					if k, ok := v["_id"].(string); ok && k != "" {
						key = k
					}
					if cnt, ok := v["count"].(int32); ok {
						availability[key] = cnt
					} else if cnt64, ok := v["count"].(int64); ok {
						availability[key] = cnt64
					}
				}
			}
		}



		skillPipeline := []bson.M{
			{"$match": bson.M{"company_name.companyId": companyId}},
			{"$project": bson.M{"skills": "$eligibility.skills"}},
			{"$unwind": "$skills"},
			{"$group": bson.M{"_id": "$skills", "jobsRequesting": bson.M{"$sum": 1}}},
			{"$sort": bson.M{"jobsRequesting": -1}},
			{"$limit": 5},
		}
		cur5, err := dc.JobCollection.Aggregate(ctx, skillPipeline)
		if err == nil {
			var skills []bson.M
			if err := cur5.All(ctx, &skills); err == nil {
				for _, s := range skills {
					skillName := ""
					if sn, ok := s["_id"].(string); ok {
						skillName = sn
					}
					jobsReq := int64(0)
					if jr, ok := s["jobsRequesting"].(int32); ok {
						jobsReq = int64(jr)
					} else if jr64, ok := s["jobsRequesting"].(int64); ok {
						jobsReq = jr64
					}


					jobMatchCursor, _ := dc.JobCollection.Find(ctx, bson.M{"company_name.companyId": companyId, "eligibility.skills": skillName})
					var skillJobs []models.Job
					var skillJobIDs []primitive.ObjectID
					if jobMatchCursor != nil {
						_ = jobMatchCursor.All(ctx, &skillJobs)
						for _, sj := range skillJobs {
							skillJobIDs = append(skillJobIDs, sj.ID)
						}
					}
					applicantsApplied := int64(0)
					if len(skillJobIDs) > 0 {
						cnt, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"job_id": bson.M{"$in": skillJobIDs}})
						applicantsApplied = cnt
					}

					appMatch := []bson.M{
						{"$match": bson.M{"job_id": bson.M{"$in": jobIDs}}},
						{"$lookup": bson.M{"from": "users", "localField": "student_id", "foreignField": "_id", "as": "student"}},
						{"$unwind": "$student"},
						{"$match": bson.M{"student.skills": skillName}},
						{"$group": bson.M{"_id": nil, "count": bson.M{"$sum": 1}}},
					}
					curA, err := dc.ApplicationCollection.Aggregate(ctx, appMatch)
					applicantsHaving := int64(0)
					if err == nil {
						var arr []bson.M
						if err := curA.All(ctx, &arr); err == nil && len(arr) > 0 {
							if cval, ok := arr[0]["count"].(int32); ok {
								applicantsHaving = int64(cval)
							} else if c64, ok := arr[0]["count"].(int64); ok {
								applicantsHaving = c64
							}
						}
					}
					matchRate := 0.0
					if applicantsApplied > 0 {
						matchRate = float64(applicantsHaving) / float64(applicantsApplied)
					}
					skillFit = append(skillFit, gin.H{"skill": skillName, "jobsRequesting": jobsReq, "applicantsApplied": applicantsApplied, "applicantsHavingSkill": applicantsHaving, "matchRate": math.Round(matchRate*10000) / 100})
				}
			}
		}


		velPipeline := []bson.M{
			{"$match": bson.M{"job_id": bson.M{"$in": jobIDs}}},
			{"$project": bson.M{"day": bson.M{"$dateToString": bson.M{"format": "%Y-%m-%d", "date": "$applied_on"}}}},
			{"$group": bson.M{"_id": "$day", "count": bson.M{"$sum": 1}}},
			{"$sort": bson.M{"_id": -1}},
			{"$limit": 7},
		}
		curV, err := dc.ApplicationCollection.Aggregate(ctx, velPipeline)
		if err == nil {
			var rows []bson.M
			if err := curV.All(ctx, &rows); err == nil {
				for i := len(rows) - 1; i >= 0; i-- {
					r := rows[i]
					day := ""
					if d, ok := r["_id"].(string); ok {
						day = d
					}
					cnt := int64(0)
					if v, ok := r["count"].(int32); ok {
						cnt = int64(v)
					} else if v64, ok := r["count"].(int64); ok {
						cnt = v64
					}
					applicationVelocity = append(applicationVelocity, gin.H{"date": day, "count": cnt})
				}
			}
		}


		now := time.Now()
		cut7 := now.Add(-7 * 24 * time.Hour)
		cut14 := now.Add(-14 * 24 * time.Hour)
		cut30 := now.Add(-30 * 24 * time.Hour)
		terminal := []string{"selected", "rejected"}

		filterBase := bson.M{"job_id": bson.M{"$in": jobIDs}, "status": bson.M{"$nin": terminal}}

		f30 := bson.M{"updated_on": bson.M{"$lt": cut30}}
		cnt30, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"$and": []bson.M{filterBase, f30}})

		f14 := bson.M{"updated_on": bson.M{"$lt": cut14}}
		cnt14, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"$and": []bson.M{filterBase, f14}})

		f7 := bson.M{"updated_on": bson.M{"$lt": cut7}}
		cnt7, _ := dc.ApplicationCollection.CountDocuments(ctx, bson.M{"$and": []bson.M{filterBase, f7}})

		pipelineAging = gin.H{"stale7": cnt7, "stale14": cnt14, "stale30": cnt30}


		distinctRes, _ := dc.ApplicationCollection.Distinct(ctx, "resume_id", bson.M{"job_id": bson.M{"$in": jobIDs}})
		var resumeIDs []primitive.ObjectID
		for _, id := range distinctRes {
			if oid, ok := id.(primitive.ObjectID); ok {
				resumeIDs = append(resumeIDs, oid)
			}
		}
		totalResumes := int64(len(resumeIDs))
		parsedComplete := int64(0)
		recentUploads := []gin.H{}
		if totalResumes > 0 {
			parsedComplete, _ = dc.ResumeCollection.CountDocuments(ctx, bson.M{"_id": bson.M{"$in": resumeIDs}, "parsedData.skills": bson.M{"$exists": true, "$ne": []interface{}{}}})

			seven := time.Now().Add(-7 * 24 * time.Hour)
			recentPipeline := []bson.M{
				{"$match": bson.M{"_id": bson.M{"$in": resumeIDs}, "created_at": bson.M{"$gte": seven}}},
				{"$project": bson.M{"day": bson.M{"$dateToString": bson.M{"format": "%Y-%m-%d", "date": "$created_at"}}}},
				{"$group": bson.M{"_id": "$day", "count": bson.M{"$sum": 1}}},
				{"$sort": bson.M{"_id": 1}},
			}
			curR, err := dc.ResumeCollection.Aggregate(ctx, recentPipeline)
			if err == nil {
				var rows []bson.M
				if err := curR.All(ctx, &rows); err == nil {
					for _, r := range rows {
						day := ""
						if d, ok := r["_id"].(string); ok {
							day = d
						}
						cnt := int64(0)
						if v, ok := r["count"].(int32); ok {
							cnt = int64(v)
						} else if v64, ok := r["count"].(int64); ok {
							cnt = v64
						}
						recentUploads = append(recentUploads, gin.H{"date": day, "count": cnt})
					}
				}
			}
		}
		resumeRecency := gin.H{"totalResumes": totalResumes, "parsedComplete": parsedComplete, "parsedCompletePct": 0.0, "recentUploads": recentUploads}
		if totalResumes > 0 {
			resumeRecency["parsedCompletePct"] = (float64(parsedComplete) / float64(totalResumes)) * 100.0
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"cgpaBands":           quality["cgpaBands"],
		"topDepartments":      quality["topDepartments"],
		"skillFit":            skillFit,
		"funnel":              funnel,
		"applicationVelocity": applicationVelocity,
		"pipelineAging":       pipelineAging,
		"resumeRecency":       resumeRecency,
	})
}


func (dc *DashboardController) GetTPOAnalyticsDashboard(c *gin.Context) {
	ctx := context.TODO()


	deptPipeline := []bson.M{
		{"$match": bson.M{"role": "student"}},
		{"$group": bson.M{
			"_id":      "$department",
			"total":    bson.M{"$sum": 1},
			"placed":   bson.M{"$sum": bson.M{"$cond": []interface{}{bson.M{"$eq": []interface{}{"$placedStatus", "Placed"}}, 1, 0}}},
			"unplaced": bson.M{"$sum": bson.M{"$cond": []interface{}{bson.M{"$ne": []interface{}{"$placedStatus", "Placed"}}, 1, 0}}},
		}},
		{"$project": bson.M{
			"department":    "$_id",
			"total":         1,
			"placed":        1,
			"unplaced":      1,
			"placementRate": bson.M{"$cond": []interface{}{bson.M{"$eq": []interface{}{"$total", 0}}, 0, bson.M{"$multiply": []interface{}{bson.M{"$divide": []interface{}{"$placed", "$total"}}, 100}}}},
		}},
	}
	cur, err := dc.UserCollection.Aggregate(ctx, deptPipeline)
	departments := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &departments)
	}


	companyPipeline := []bson.M{
		{"$match": bson.M{"role": "student", "placedStatus": "Placed", "company": bson.M{"$exists": true, "$ne": ""}}},
		{"$group": bson.M{"_id": "$company", "count": bson.M{"$sum": 1}}},
		{"$sort": bson.M{"count": -1}},
	}
	cur, err = dc.UserCollection.Aggregate(ctx, companyPipeline)
	companies := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &companies)
	}


	jobDrivePipeline := []bson.M{
		{"$group": bson.M{
			"_id":       "$department",
			"jobDrives": bson.M{"$sum": 1},
		}},
	}
	cur, err = dc.JobCollection.Aggregate(ctx, jobDrivePipeline)
	jobDrives := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &jobDrives)
	}


	salaryPipeline := []bson.M{
		{"$match": bson.M{"role": "student", "placedStatus": "Placed", "salary": bson.M{"$exists": true, "$ne": ""}}},
		{"$group": bson.M{
			"_id":       nil,
			"minSalary": bson.M{"$min": "$salary"},
			"maxSalary": bson.M{"$max": "$salary"},
			"avgSalary": bson.M{"$avg": "$salary"},
		}},
	}
	cur, err = dc.UserCollection.Aggregate(ctx, salaryPipeline)
	salaryStats := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &salaryStats)
	}


	batchPipeline := []bson.M{
		{"$match": bson.M{"role": "student"}},
		{"$group": bson.M{
			"_id":    "$graduationYear",
			"total":  bson.M{"$sum": 1},
			"placed": bson.M{"$sum": bson.M{"$cond": []interface{}{bson.M{"$eq": []interface{}{"$placedStatus", "Placed"}}, 1, 0}}},
		}},
		{"$sort": bson.M{"_id": 1}},
	}
	cur, err = dc.UserCollection.Aggregate(ctx, batchPipeline)
	batchTrends := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &batchTrends)
	}


	skillsPipeline := []bson.M{
		{"$match": bson.M{"role": "student", "placedStatus": "Placed", "skills": bson.M{"$exists": true, "$ne": []interface{}{}}}},
		{"$unwind": "$skills"},
		{"$group": bson.M{"_id": "$skills", "count": bson.M{"$sum": 1}}},
		{"$sort": bson.M{"count": -1}},
		{"$limit": 10},
	}
	cur, err = dc.UserCollection.Aggregate(ctx, skillsPipeline)
	topSkills := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &topSkills)
	}


	appSuccessPipeline := []bson.M{
		{"$group": bson.M{
			"_id":          "$department",
			"applications": bson.M{"$sum": 1},
			"placed":       bson.M{"$sum": bson.M{"$cond": []interface{}{bson.M{"$eq": []interface{}{"$placedStatus", "Placed"}}, 1, 0}}},
		}},
	}
	cur, err = dc.UserCollection.Aggregate(ctx, appSuccessPipeline)
	appSuccess := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &appSuccess)
	}


	genderPipeline := []bson.M{
		{"$match": bson.M{"role": "student", "placedStatus": "Placed", "gender": bson.M{"$exists": true, "$ne": ""}}},
		{"$group": bson.M{"_id": "$gender", "count": bson.M{"$sum": 1}}},
	}
	cur, err = dc.UserCollection.Aggregate(ctx, genderPipeline)
	genderStats := []bson.M{}
	if err == nil {
		_ = cur.All(ctx, &genderStats)
	}



	placementTimeline := gin.H{"averageDaysToPlacement": nil}

	c.JSON(200, gin.H{
		"departments":        departments,
		"companies":          companies,
		"jobDrives":          jobDrives,
		"salaryStats":        salaryStats,
		"batchTrends":        batchTrends,
		"topSkills":          topSkills,
		"applicationSuccess": appSuccess,
		"genderStats":        genderStats,
		"placementTimeline":  placementTimeline,
	})
}
