package controllers

import (
	"context"
	"log"
	"net/http"
	"time"

	"backend/models"
	"backend/services"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)


type StudentController struct {
	UserCollection        *mongo.Collection
	ResumeCollection      *mongo.Collection
	ApplicationCollection *mongo.Collection


	studentService services.StudentService
	userService    services.UserService
}

type ApplicationDetails struct {
	ID          primitive.ObjectID `bson:"_id" json:"id"`
	StudentID   primitive.ObjectID `bson:"student_id" json:"studentId"`
	AppliedOn   time.Time          `bson:"applied_on" json:"appliedOn"`
	Status      string             `bson:"status" json:"status"`
	CompanyName string             `json:"companyName"`
	Role        string             `json:"role"`
}


func NewStudentController(db *mongo.Database) *StudentController {
	return &StudentController{
		UserCollection:        db.Collection("users"),
		ResumeCollection:      db.Collection("resumes"),
		ApplicationCollection: db.Collection("applications"),


		studentService: services.NewStudentService(db),
		userService:    services.NewUserService(db),
	}
}



func (sc *StudentController) GetMyProfile(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	userIDHex, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Could not retrieve user ID from token"})
		return
	}

	objectID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID format"})
		return
	}

	var user models.User
	err = sc.UserCollection.FindOne(ctx, bson.M{"_id": objectID}).Decode(&user)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User profile not found"})
		return
	}

	var resumesList []gin.H


	log.Printf("DEBUG: User %s has %d resume IDs: %v", user.Email, len(user.ActiveResumeID), user.ActiveResumeID)


	if len(user.ActiveResumeID) > 0 {
		log.Printf("DEBUG: Querying resumes collection for IDs: %v", user.ActiveResumeID)


		cursor, err := sc.ResumeCollection.Find(ctx, bson.M{"_id": bson.M{"$in": user.ActiveResumeID}})
		if err == nil {
			var rawDocs []bson.M
			if err = cursor.All(ctx, &rawDocs); err == nil {
				log.Printf("DEBUG: Found %d raw documents in database", len(rawDocs))
				for i, doc := range rawDocs {
					log.Printf("DEBUG: Raw document %d: %+v", i, doc)
				}
			} else {
				log.Printf("DEBUG: Error decoding raw docs: %v", err)
			}
		}


		cursor2, err := sc.ResumeCollection.Find(ctx, bson.M{"_id": bson.M{"$in": user.ActiveResumeID}})
		if err == nil {
			var fetched []models.Resume
			if err = cursor2.All(ctx, &fetched); err == nil {
				log.Printf("DEBUG: Fetched %d resumes from database", len(fetched))
				for i, r := range fetched {
					log.Printf("DEBUG: Resume %d: ID=%v, FileURL=%s, Skills=%v", i, r.ID, r.FileURL, r.ParsedData.Skills)
				}


				resumeMap := make(map[primitive.ObjectID]models.Resume)
				for _, r := range fetched {
					resumeMap[r.ID] = r
				}


				for _, rid := range user.ActiveResumeID {
					if r, ok := resumeMap[rid]; ok {
						resumesList = append(resumesList, gin.H{
							"id":         r.ID,
							"ResumeName": r.ResumeName,
							"fileURL":    r.FileURL,
							"uploadedAt": r.UploadedAt,
							"skills":     r.ParsedData.Skills,
						})
					} else {
						log.Printf("DEBUG: Resume ID %s not found in fetched resumes", rid.Hex())
					}
				}
			} else {
				log.Printf("DEBUG: Error decoding resumes: %v", err)
			}
		} else {
			log.Printf("DEBUG: Error finding resumes: %v", err)
		}
	} else {
		log.Printf("DEBUG: User has no resume IDs in activeResumeId array")
	}

	log.Printf("DEBUG: Returning %d resumes to client", len(resumesList))

	c.JSON(http.StatusOK, gin.H{
		"id":         user.ID,
		"firstName":  user.FirstName,
		"lastName":   user.LastName,
		"email":      user.Email,
		"role":       user.Role,
		"department": user.Department,
		"cgpa":       user.CGPA,
		"skills":     user.Skills,
		"rollNumber": user.RollNumber,
		"resumes":    resumesList,
	})
}


func (sc *StudentController) GetMyApplications(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	studentID, _ := primitive.ObjectIDFromHex(userIDHex.(string))


	pipeline := mongo.Pipeline{

		{{Key: "$match", Value: bson.D{{Key: "student_id", Value: studentID}}}},

		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "jobs"},
			{Key: "localField", Value: "job_id"},
			{Key: "foreignField", Value: "_id"},
			{Key: "as", Value: "jobDetails"},
		}}},

		{{Key: "$unwind", Value: "$jobDetails"}},

		{{Key: "$project", Value: bson.D{
			{Key: "_id", Value: 1},
			{Key: "student_id", Value: 1},
			{Key: "applied_on", Value: 1},
			{Key: "status", Value: 1},
			{Key: "companyName", Value: "$jobDetails.company_name.name"},
			{Key: "role", Value: "$jobDetails.position"},
		}}},
	}

	cursor, err := sc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch applications"})
		return
	}

	var results []ApplicationDetails
	if err = cursor.All(ctx, &results); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode application data"})
		return
	}

	c.JSON(http.StatusOK, results)
}


func (sc *StudentController) GetApplicationDetails(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	studentID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}


	applicationID := c.Param("applicationId")
	applicationObjectID, err := primitive.ObjectIDFromHex(applicationID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid application ID"})
		return
	}


	pipeline := mongo.Pipeline{

		{{Key: "$match", Value: bson.D{
			{Key: "_id", Value: applicationObjectID},
			{Key: "student_id", Value: studentID},
		}}},

		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "jobs"},
			{Key: "localField", Value: "job_id"},
			{Key: "foreignField", Value: "_id"},
			{Key: "as", Value: "jobDetails"},
		}}},
		{{Key: "$unwind", Value: "$jobDetails"}},

		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "users"},
			{Key: "localField", Value: "student_id"},
			{Key: "foreignField", Value: "_id"},
			{Key: "as", Value: "studentDetails"},
		}}},
		{{Key: "$unwind", Value: "$studentDetails"}},

		{{Key: "$lookup", Value: bson.D{
			{Key: "from", Value: "resumes"},
			{Key: "localField", Value: "resume_id"},
			{Key: "foreignField", Value: "_id"},
			{Key: "as", Value: "resumes"},
		}}},

		{{Key: "$project", Value: bson.D{
			{Key: "_id", Value: 1},
			{Key: "status", Value: 1},
			{Key: "applied_on", Value: 1},
			{Key: "updated_on", Value: 1},
			{Key: "remarks", Value: 1},

			{Key: "student", Value: bson.D{
				{Key: "_id", Value: "$studentDetails._id"},
				{Key: "firstName", Value: "$studentDetails.firstName"},
				{Key: "lastName", Value: "$studentDetails.lastName"},
				{Key: "email", Value: "$studentDetails.email"},
				{Key: "phone", Value: "$studentDetails.phone"},
				{Key: "department", Value: "$studentDetails.department"},
				{Key: "year", Value: "$studentDetails.year"},
				{Key: "cgpa", Value: "$studentDetails.cgpa"},
				{Key: "skills", Value: "$studentDetails.skills"},
				{Key: "enrollmentNo", Value: "$studentDetails.enrollmentNo"},
			}},

			{Key: "job", Value: bson.D{
				{Key: "_id", Value: "$jobDetails._id"},
				{Key: "position", Value: "$jobDetails.position"},
				{Key: "companyName", Value: "$jobDetails.company_name.name"},
				{Key: "companyId", Value: "$jobDetails.company_name.companyId"},
				{Key: "jobType", Value: "$jobDetails.job_type"},
				{Key: "location", Value: "$jobDetails.location"},
				{Key: "description", Value: "$jobDetails.description"},
				{Key: "salary", Value: "$jobDetails.salary"},
				{Key: "applicationDeadline", Value: "$jobDetails.application_deadline"},
				{Key: "eligibilityCriteria", Value: "$jobDetails.eligibility_criteria"},
				{Key: "requiredSkills", Value: "$jobDetails.required_skills"},
				{Key: "createdAt", Value: "$jobDetails.created_at"},
			}},

			{Key: "resumes", Value: bson.D{
				{Key: "$map", Value: bson.D{
					{Key: "input", Value: "$resumes"},
					{Key: "as", Value: "resume"},
					{Key: "in", Value: bson.D{
						{Key: "_id", Value: "$$resume._id"},
						{Key: "fileName", Value: "$$resume.file_name"},
						{Key: "fileUrl", Value: "$$resume.file_url"},
						{Key: "uploadedAt", Value: "$$resume.uploaded_at"},
					}},
				}},
			}},
		}}},
	}

	cursor, err := sc.ApplicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch application details"})
		return
	}

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode application data"})
		return
	}

	if len(results) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Application not found or you don't have access"})
		return
	}

	c.JSON(http.StatusOK, results[0])
}


func (sc *StudentController) GetMyNotifications(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	userIDHex, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	studentID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}


	var user models.User
	err = sc.UserCollection.FindOne(ctx, bson.M{
		"_id":  studentID,
		"role": "student",
	}).Decode(&user)

	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "Student not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch notifications"})
		return
	}


	notifications := user.Notifications
	if notifications == nil {
		notifications = []models.Notification{}
	}

	c.JSON(http.StatusOK, gin.H{
		"notifications": notifications,
		"count":         len(notifications),
	})



	go func(uid primitive.ObjectID) {
		ctxUp, cancelUp := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancelUp()


		filter := bson.M{"_id": uid, "role": "student"}


		update := bson.M{"$set": bson.M{"notifications.$[elem].isRead": true}}

		opts := options.Update().SetArrayFilters(options.ArrayFilters{Filters: []interface{}{bson.M{"elem.isRead": false}}})

		res, err := sc.UserCollection.UpdateOne(ctxUp, filter, update, opts)
		if err != nil {
			log.Printf("Failed to mark notifications read for user %s: %v", uid.Hex(), err)
			return
		}
		if res.MatchedCount == 0 {
			log.Printf("No matching student document found when marking notifications read for user %s", uid.Hex())
			return
		}
		log.Printf("Marked %d notification(s) as read for user %s", res.ModifiedCount, uid.Hex())
	}(studentID)
}
