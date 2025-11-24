package controllers

import (
	"backend/models"
	"backend/services"
	"context"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/crypto/bcrypt"
)

type AdminController struct {
	adminService          services.AdminService
	JobCollection         *mongo.Collection
	CompanyCollection     *mongo.Collection
	ApplicationCollection *mongo.Collection
}

func (ac *AdminController) ExportReport(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c.Request.Context(), 20*time.Second)
	defer cancel()

	placementStats, err := ac.adminService.GetPlacementStats()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get placement stats", "details": err.Error()})
		return
	}

	companyAnalytics, err := ac.adminService.GetCompanyAnalytics()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get company analytics", "details": err.Error()})
		return
	}

	jobsCol := ac.adminService.(*services.AdminServiceImpl).UserCollection().Database().Collection("jobs")
	jobCursor, err := jobsCol.Find(ctx, bson.M{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch job postings", "details": err.Error()})
		return
	}

	jobRolesOffered := make(map[string]int)             
	jobRolesByCompany := make(map[string]map[string]int) 
	totalJobPostings := 0

	for jobCursor.Next(ctx) {
		var job bson.M
		if err := jobCursor.Decode(&job); err != nil {
			continue
		}

		position := ""
		companyName := ""

		if v, ok := job["position"].(string); ok {
			position = v
			jobRolesOffered[position]++
		}

		if companyData, ok := job["company_name"].(bson.M); ok {
			if name, ok := companyData["name"].(string); ok {
				companyName = name
			}
		} else if companyData, ok := job["company_name"].(map[string]interface{}); ok {
			if name, ok := companyData["name"].(string); ok {
				companyName = name
			}
		}

		if companyName != "" && position != "" {
			if jobRolesByCompany[companyName] == nil {
				jobRolesByCompany[companyName] = make(map[string]int)
			}
			jobRolesByCompany[companyName][position]++
		}

		totalJobPostings++
	}
	jobCursor.Close(ctx)

	studentsByDept := make(map[string][]gin.H)
	filter := bson.M{"role": "student"}

	cursor, err := ac.adminService.(*services.AdminServiceImpl).UserCollection().Find(ctx, filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch students", "details": err.Error()})
		return
	}
	defer cursor.Close(ctx)

	totalStudents := 0
	placedCount := 0
	unplacedCount := 0
	cgpaSum := 0.0
	cgpaCount := 0
	genderCount := make(map[string]int)
	skillsFrequency := make(map[string]int)
	companyHires := make(map[string]int)
	roleDistribution := make(map[string]int)
	salaryRanges := make(map[string]int)

	for cursor.Next(ctx) {
		var s bson.M
		if err := cursor.Decode(&s); err != nil {
			continue
		}

		dept := "Unknown"
		if d, ok := s["department"].(string); ok && d != "" {
			dept = d
		} else if dptr, ok := s["department"].(*string); ok && dptr != nil {
			dept = *dptr
		}

		firstName := ""
		lastName := ""
		email := ""
		rollNumber := ""
		placedStatus := "Unplaced"
		company := ""
		role := ""
		salary := ""
		cgpa := 0.0
		gender := ""

		if v, ok := s["firstName"].(string); ok {
			firstName = v
		}
		if v, ok := s["lastName"].(string); ok {
			lastName = v
		}
		if v, ok := s["email"].(string); ok {
			email = v
		}
		if v, ok := s["rollNumber"].(string); ok {
			rollNumber = v
		}
		if v, ok := s["placedStatus"].(string); ok {
			placedStatus = v
		}
		if v, ok := s["gender"].(string); ok {
			gender = v
			genderCount[gender]++
		}
		if v, ok := s["cgpa"].(float64); ok {
			cgpa = v
			cgpaSum += v
			cgpaCount++
		} else if v, ok := s["cgpa"].(int); ok {
			cgpa = float64(v)
			cgpaSum += cgpa
			cgpaCount++
		}

		if skills, ok := s["skills"].([]interface{}); ok {
			for _, skill := range skills {
				if skillStr, ok := skill.(string); ok {
					skillsFrequency[skillStr]++
				}
			}
		} else if skills, ok := s["skills"].([]string); ok {
			for _, skill := range skills {
				skillsFrequency[skill]++
			}
		}

		if placedStatus == "Placed" {
			placedCount++
			if v, ok := s["company"].(string); ok {
				company = v
				companyHires[company]++
			}
			if v, ok := s["role"].(string); ok {
				role = v
				roleDistribution[role]++
			}
			if v, ok := s["salary"].(string); ok {
				salary = v
				var salaryNum float64
				fmt.Sscanf(salary, "%f", &salaryNum)
				if salaryNum < 10 {
					salaryRanges["<10 LPA"]++
				} else if salaryNum < 15 {
					salaryRanges["10-15 LPA"]++
				} else if salaryNum < 20 {
					salaryRanges["15-20 LPA"]++
				} else if salaryNum >= 20 {
					salaryRanges["20+ LPA"]++
				}
			} else if v, ok := s["salary"].(float64); ok {
				salary = fmt.Sprintf("%.2f", v)
				if v < 10 {
					salaryRanges["<10 LPA"]++
				} else if v < 15 {
					salaryRanges["10-15 LPA"]++
				} else if v < 20 {
					salaryRanges["15-20 LPA"]++
				} else if v >= 20 {
					salaryRanges["20+ LPA"]++
				}
			} else if v, ok := s["salary"].(int); ok {
				salary = fmt.Sprintf("%d", v)
				if v < 10 {
					salaryRanges["<10 LPA"]++
				} else if v < 15 {
					salaryRanges["10-15 LPA"]++
				} else if v < 20 {
					salaryRanges["15-20 LPA"]++
				} else if v >= 20 {
					salaryRanges["20+ LPA"]++
				}
			}
		} else {
			unplacedCount++
		}

		studentData := gin.H{
			"id":           s["_id"],
			"firstName":    firstName,
			"lastName":     lastName,
			"name":         firstName + " " + lastName,
			"email":        email,
			"rollNumber":   rollNumber,
			"placedStatus": placedStatus,
			"company":      company,
			"role":         role,
			"salary":       salary,
			"cgpa":         cgpa,
			"department":   dept,
			"gender":       gender,
		}

		studentsByDept[dept] = append(studentsByDept[dept], studentData)
		totalStudents++
	}

	deptSummary := make([]gin.H, 0)
	for dept, students := range studentsByDept {
		deptPlaced := 0
		deptUnplaced := 0
		deptCgpaSum := 0.0
		deptCgpaCount := 0

		for _, student := range students {
			if status, ok := student["placedStatus"].(string); ok && status == "Placed" {
				deptPlaced++
			} else {
				deptUnplaced++
			}
			if cgpa, ok := student["cgpa"].(float64); ok && cgpa > 0 {
				deptCgpaSum += cgpa
				deptCgpaCount++
			}
		}

		placementRate := 0.0
		if len(students) > 0 {
			placementRate = float64(deptPlaced) / float64(len(students)) * 100
		}

		avgCgpa := 0.0
		if deptCgpaCount > 0 {
			avgCgpa = deptCgpaSum / float64(deptCgpaCount)
		}

		deptSummary = append(deptSummary, gin.H{
			"department":    dept,
			"totalStudents": len(students),
			"placed":        deptPlaced,
			"unplaced":      deptUnplaced,
			"placementRate": placementRate,
			"averageCGPA":   avgCgpa,
		})
	}

	genderData := make([]gin.H, 0)
	for gender, count := range genderCount {
		genderData = append(genderData, gin.H{
			"gender": gender,
			"count":  count,
		})
	}

	type skillCount struct {
		skill string
		count int
	}
	skillsArray := make([]skillCount, 0)
	for skill, count := range skillsFrequency {
		skillsArray = append(skillsArray, skillCount{skill, count})
	}
	for i := 0; i < len(skillsArray)-1; i++ {
		for j := i + 1; j < len(skillsArray); j++ {
			if skillsArray[j].count > skillsArray[i].count {
				skillsArray[i], skillsArray[j] = skillsArray[j], skillsArray[i]
			}
		}
	}
	topSkills := make([]gin.H, 0)
	limit := 10
	if len(skillsArray) < limit {
		limit = len(skillsArray)
	}
	for i := 0; i < limit; i++ {
		topSkills = append(topSkills, gin.H{
			"skill": skillsArray[i].skill,
			"count": skillsArray[i].count,
		})
	}

	topCompanies := make([]gin.H, 0)
	for company, count := range companyHires {
		topCompanies = append(topCompanies, gin.H{
			"company": company,
			"hires":   count,
		})
	}

	roleData := make([]gin.H, 0)
	for role, count := range roleDistribution {
		roleData = append(roleData, gin.H{
			"role":  role,
			"count": count,
		})
	}

	jobRolesData := make([]gin.H, 0)
	for role, count := range jobRolesOffered {
		jobRolesData = append(jobRolesData, gin.H{
			"role":  role,
			"count": count,
		})
	}

	for i := 0; i < len(jobRolesData)-1; i++ {
		for j := i + 1; j < len(jobRolesData); j++ {
			if jobRolesData[j]["count"].(int) > jobRolesData[i]["count"].(int) {
				jobRolesData[i], jobRolesData[j] = jobRolesData[j], jobRolesData[i]
			}
		}
	}

	topJobRoles := jobRolesData
	if len(topJobRoles) > 10 {
		topJobRoles = jobRolesData[:10]
	}

	type companyRoleStats struct {
		company   string
		roleCount int
		roles     []gin.H
	}
	companyRoleList := make([]companyRoleStats, 0)
	for company, roles := range jobRolesByCompany {
		rolesList := make([]gin.H, 0)
		for role, count := range roles {
			rolesList = append(rolesList, gin.H{
				"role":  role,
				"count": count,
			})
		}
		companyRoleList = append(companyRoleList, companyRoleStats{
			company:   company,
			roleCount: len(roles),
			roles:     rolesList,
		})
	}

	for i := 0; i < len(companyRoleList)-1; i++ {
		for j := i + 1; j < len(companyRoleList); j++ {
			if companyRoleList[j].roleCount > companyRoleList[i].roleCount {
				companyRoleList[i], companyRoleList[j] = companyRoleList[j], companyRoleList[i]
			}
		}
	}

	topCompaniesByRoles := make([]gin.H, 0)
	companyLimit := 5
	if len(companyRoleList) < companyLimit {
		companyLimit = len(companyRoleList)
	}
	for i := 0; i < companyLimit; i++ {
		topCompaniesByRoles = append(topCompaniesByRoles, gin.H{
			"company":   companyRoleList[i].company,
			"roleCount": companyRoleList[i].roleCount,
			"roles":     companyRoleList[i].roles,
		})
	}

	salaryData := make([]gin.H, 0)
	for salRange, count := range salaryRanges {
		salaryData = append(salaryData, gin.H{
			"range": salRange,
			"count": count,
		})
	}

	avgCgpa := 0.0
	if cgpaCount > 0 {
		avgCgpa = cgpaSum / float64(cgpaCount)
	}

	response := gin.H{
		"reportTitle":      "College Placement & Company Analytics Report",
		"generatedAt":      time.Now(),
		"placementStats":   placementStats,
		"companyAnalytics": companyAnalytics,
		"summary": gin.H{
			"totalStudents": totalStudents,
			"placed":        placedCount,
			"unplaced":      unplacedCount,
			"placementRate": func() float64 {
				if totalStudents > 0 {
					return float64(placedCount) / float64(totalStudents) * 100
				}
				return 0.0
			}(),
			"averageCGPA":      avgCgpa,
			"totalJobPostings": totalJobPostings,
		},
		"departmentSummary":    deptSummary,
		"studentsByDepartment": studentsByDept,
		"charts": gin.H{
			"genderDistribution":          genderData,
			"topSkills":                   topSkills,
			"topCompanies":                topCompanies,
			"roleDistribution":            roleData, 
			"salaryDistribution":          salaryData,
			"placementByDepartment":       deptSummary,        
			"jobRolesOffered":             topJobRoles,
			"topCompaniesByRoleDiversity": topCompaniesByRoles,
		},
		"roleAnalysis": gin.H{
			"placedStudentRoles": gin.H{
				"description": "Breakdown of roles students have been placed into",
				"data":        roleData,
				"total":       len(roleDistribution),
			},
			"companyJobRoles": gin.H{
				"description": "Most common job roles companies are offering",
				"data":        topJobRoles,
				"total":       len(jobRolesOffered),
			},
			"roleGap": gin.H{
				"description":  "Analysis of role demand vs placement",
				"rolesOffered": len(jobRolesOffered),
				"rolesPlaced":  len(roleDistribution),
			},
		},
	}

	c.JSON(http.StatusOK, response)
}

func NewAdminController(db *mongo.Database) *AdminController {
	return &AdminController{
		adminService:          services.NewAdminService(db),
		JobCollection:         db.Collection("jobs"),
		CompanyCollection:     db.Collection("companies"),
		ApplicationCollection: db.Collection("applications"),
	}
}

func (ac *AdminController) AddStudent(c *gin.Context) {
	var studentData map[string]interface{}
	if err := c.ShouldBindJSON(&studentData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request", "details": err.Error()})
		return
	}
	err := ac.adminService.AddStudent(studentData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add student", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Student added successfully"})
}

func (ac *AdminController) AddStudentsBatch(c *gin.Context) {
	var req struct {
		CSVUrl string `json:"csvUrl"`
	}
	if err := c.ShouldBindJSON(&req); err != nil || req.CSVUrl == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing or invalid csvUrl"})
		return
	}
	err := ac.adminService.AddStudentsBatch(req.CSVUrl)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add students batch", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Batch of students added successfully"})
}

func (ac *AdminController) SendAnnouncement(c *gin.Context) {
	var req struct {
		Subject string `json:"subject" binding:"required"`
		Message string `json:"message" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing or invalid subject/message"})
		return
	}
	if req.Subject == "" || req.Message == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Both subject and message are required"})
		return
	}
	err := ac.adminService.SendAnnouncement(req.Subject, req.Message, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send announcement", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Announcement sent to all students and TPOs"})
}

func (ac *AdminController) GetPlacementStats(c *gin.Context) {
	
	filters := map[string]string{}
	if v := c.Query("from"); v != "" {
		filters["from"] = v
	}
	if v := c.Query("to"); v != "" {
		filters["to"] = v
	}
	if v := c.Query("department"); v != "" {
		filters["department"] = v
	}
	if v := c.Query("interval"); v != "" {
		filters["interval"] = v
	}
	if v := c.Query("limit"); v != "" {
		filters["limit"] = v
	}
	if v := c.Query("drives"); v != "" {
		filters["drives"] = v
	}

	if impl, ok := ac.adminService.(*services.AdminServiceImpl); ok {
		stats, err := impl.GetPlacementStatsWithFilters(filters)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get placement stats", "details": err.Error()})
			return
		}
		c.JSON(http.StatusOK, stats)
		return
	}
	stats, err := ac.adminService.GetPlacementStats()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get placement stats", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"stats": stats})
}
func (ac *AdminController) GetCompanyAnalytics(c *gin.Context) {
	filters := map[string]string{}
	if v := c.Query("from"); v != "" {
		filters["from"] = v
	}
	if v := c.Query("to"); v != "" {
		filters["to"] = v
	}
	if v := c.Query("limit"); v != "" {
		filters["limit"] = v
	}

	if impl, ok := ac.adminService.(*services.AdminServiceImpl); ok {
		analytics, err := impl.GetCompanyAnalyticsWithFilters(filters)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get company analytics", "details": err.Error()})
			return
		}
		c.JSON(http.StatusOK, analytics)
		return
	}
	analytics, err := ac.adminService.GetCompanyAnalytics()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get company analytics", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"analytics": analytics})
}
func (ac *AdminController) CreateJobDrive(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	adminID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Admin ID"})
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
		err = ac.CompanyCollection.FindOne(ctx, bson.M{"_id": job.CompanyName.CompanyID}).Decode(&company)
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
	job.PostedBy = adminID
	job.CreatedAt = time.Now()
	job.Status = "open"

	
	_, err = ac.JobCollection.InsertOne(ctx, job)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create drive"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Drive created successfully",
		"driveId": job.ID,
	})
}


func (ac *AdminController) GetAllDrives(c *gin.Context) {
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

	cursor, err := ac.JobCollection.Aggregate(ctx, pipeline)
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


func (ac *AdminController) GetDriveDetails(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	driveID := c.Param("driveId")
	objectID, err := primitive.ObjectIDFromHex(driveID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid drive ID"})
		return
	}

	
	var drive models.Job
	err = ac.JobCollection.FindOne(ctx, bson.M{"_id": objectID}).Decode(&drive)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Drive not found"})
		return
	}

	
	cursor, err := ac.ApplicationCollection.Find(ctx, bson.M{"job_id": objectID})
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


func (ac *AdminController) GetDriveApplications(c *gin.Context) {
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

	cursor, err := ac.ApplicationCollection.Aggregate(ctx, pipeline)
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

func (ac *AdminController) GetStudents(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c.Request.Context(), 10*time.Second)
	defer cancel()

	filter := make(map[string]interface{})
	filter["role"] = "student"

	if dept := c.Query("department"); dept != "" {
		filter["department"] = dept
	}
	if status := c.Query("placedStatus"); status != "" {
		filter["placedStatus"] = status
	}

	search := c.Query("search")
	if search != "" {
		filter["$or"] = []map[string]interface{}{
			{"firstName": map[string]interface{}{"$regex": search, "$options": "i"}},
			{"lastName": map[string]interface{}{"$regex": search, "$options": "i"}},
			{"rollNumber": map[string]interface{}{"$regex": search, "$options": "i"}},
			{"email": map[string]interface{}{"$regex": search, "$options": "i"}},
		}
	}

	limit := int64(0)
	page := int64(0)
	if l := c.Query("limit"); l != "" {
		if v, err := strconv.ParseInt(l, 10, 64); err == nil {
			limit = v
		}
	}
	if p := c.Query("page"); p != "" {
		if v, err := strconv.ParseInt(p, 10, 64); err == nil {
			page = v
		}
	}

	userCol := ac.adminService.(*services.AdminServiceImpl).UserCollection()
	var cursor *mongo.Cursor
	var err error
	if limit > 0 {
		opts := options.Find().SetLimit(limit).SetSkip(page * limit)
		cursor, err = userCol.Find(ctx, filter, opts)
	} else {
		cursor, err = userCol.Find(ctx, filter)
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch students", "details": err.Error()})
		return
	}
	defer cursor.Close(ctx)

	var rawStudents []bson.M
	if err := cursor.All(ctx, &rawStudents); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode students", "details": err.Error()})
		return
	}

	total := len(rawStudents)
	placed := 0
	shortlisted := 0
	interviewed := 0

	studentsOut := make([]gin.H, 0, total)
	for _, s := range rawStudents {
		ps := "Unplaced"
		if p, ok := s["placedStatus"].(string); ok && p != "" {
			ps = p
		}
		if ps == "Placed" {
			placed++
		}
		if v, ok := s["shortlistedCount"].(int); ok && v > 0 {
			shortlisted += v
		}
		if v, ok := s["interviewedCount"].(int); ok && v > 0 {
			interviewed += v
		}

		studentsOut = append(studentsOut, gin.H{
			"id":           s["_id"],
			"firstName":    s["firstName"],
			"lastName":     s["lastName"],
			"email":        s["email"],
			"rollNumber":   s["rollNumber"],
			"department":   s["department"],
			"placedStatus": ps,
		})
	}

	companyCount, _ := ac.adminService.(*services.AdminServiceImpl).UserCollection().Database().Collection("companies").CountDocuments(ctx, bson.M{})
	applicationCount, _ := ac.adminService.(*services.AdminServiceImpl).UserCollection().Database().Collection("applications").CountDocuments(ctx, bson.M{})

	c.JSON(http.StatusOK, gin.H{
		"students": studentsOut,
		"statistics": gin.H{
			"totalReturned": total,
			"placed":        placed,
			"shortlisted":   shortlisted,
			"interviewed":   interviewed,
			"companies":     companyCount,
			"applications":  applicationCount,
		},
	})
}

func (ac *AdminController) GetAllTPOs(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	filter := bson.M{"role": "tpo"}

	if dept := c.Query("department"); dept != "" {
		filter["department"] = dept
	}

	search := c.Query("search")
	if search != "" {
		filter["$or"] = []bson.M{
			{"firstName": bson.M{"$regex": search, "$options": "i"}},
			{"lastName": bson.M{"$regex": search, "$options": "i"}},
			{"email": bson.M{"$regex": search, "$options": "i"}},
		}
	}

	userCol := ac.adminService.(*services.AdminServiceImpl).UserCollection()
	cursor, err := userCol.Find(ctx, filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch TPOs", "details": err.Error()})
		return
	}
	defer cursor.Close(ctx)

	var tpos []gin.H
	for cursor.Next(ctx) {
		var tpo models.User
		if err := cursor.Decode(&tpo); err != nil {
			continue
		}

		studentCount := int64(0)
		if tpo.Department != nil {
			studentCount, _ = userCol.CountDocuments(ctx, bson.M{
				"role":       "student",
				"department": *tpo.Department,
			})
		}

		tpos = append(tpos, gin.H{
			"id":             tpo.ID,
			"firstName":      tpo.FirstName,
			"lastName":       tpo.LastName,
			"email":          tpo.Email,
			"department":     tpo.Department,
			"gender":         tpo.Gender,
			"qualifications": tpo.Qualifications,
			"createdAt":      tpo.CreatedAt,
			"studentCount":   studentCount,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"tpos":  tpos,
		"total": len(tpos),
	})
}

func (ac *AdminController) AddTPO(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var req struct {
		FirstName      string          `json:"firstName" binding:"required"`
		LastName       string          `json:"lastName" binding:"required"`
		Email          string          `json:"email" binding:"required,email"`
		Password       string          `json:"password" binding:"required,min=6"`
		Department     string          `json:"department" binding:"required"`
		Gender         *string         `json:"gender"`
		Qualifications []models.Qualification `json:"qualifications"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	userCol := ac.adminService.(*services.AdminServiceImpl).UserCollection()
	existingUser, _ := userCol.CountDocuments(ctx, bson.M{"email": req.Email})
	if existingUser > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "Email already exists"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	newTPO := models.User{
		ID:             primitive.NewObjectID(),
		FirstName:      req.FirstName,
		LastName:       req.LastName,
		Email:          req.Email,
		PasswordHash:   string(hashedPassword),
		Role:           "tpo",
		Department:     &req.Department,
		Gender:         req.Gender,
		Qualifications: req.Qualifications,
		CreatedAt:      time.Now(),
		UpdatedAt:      time.Now(),
		Notifications:  []models.Notification{},
	}

	_, err = userCol.InsertOne(ctx, newTPO)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create TPO", "details": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "TPO created successfully",
		"tpo": gin.H{
			"id":         newTPO.ID,
			"firstName":  newTPO.FirstName,
			"lastName":   newTPO.LastName,
			"email":      newTPO.Email,
			"department": newTPO.Department,
		},
	})
}
