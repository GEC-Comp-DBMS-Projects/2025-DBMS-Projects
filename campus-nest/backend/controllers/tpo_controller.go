package controllers

import (
	"context"
	"net/http"
	"time"

	"backend/models"
	"backend/services"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type TPOController struct {
	UserCollection    *mongo.Collection
	JobCollection     *mongo.Collection
	CompanyCollection *mongo.Collection


	tpoService     services.TPOService
	userService    services.UserService
	jobService     services.JobService
	companyService services.CompanyService
}

func NewTPOController(db *mongo.Database) *TPOController {
	return &TPOController{
		UserCollection:    db.Collection("users"),
		JobCollection:     db.Collection("jobs"),
		CompanyCollection: db.Collection("companies"),


		tpoService:     services.NewTPOService(db),
		userService:    services.NewUserService(db),
		jobService:     services.NewJobService(db),
		companyService: services.NewCompanyService(db),
	}
}

func (tc *TPOController) GetMyProfile(c *gin.Context) {

	userIDStr, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	tpoID, err := primitive.ObjectIDFromHex(userIDStr.(string))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user ID"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	var tpo models.User
	err = tc.UserCollection.FindOne(ctx, bson.M{"_id": tpoID, "role": "tpo"}).Decode(&tpo)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "TPO not found"})
		return
	}


	studentCount, _ := tc.UserCollection.CountDocuments(ctx, bson.M{
		"role":       "student",
		"department": tpo.Department,
	})


	jobCount, _ := tc.JobCollection.CountDocuments(ctx, bson.M{
		"posted_by": tpoID,
	})


	companyCount, _ := tc.CompanyCollection.CountDocuments(ctx, bson.M{})


	c.JSON(http.StatusOK, gin.H{
		"profile": gin.H{
			"id":             tpo.ID,
			"firstName":      tpo.FirstName,
			"lastName":       tpo.LastName,
			"email":          tpo.Email,
			"role":           tpo.Role,
			"gender":         tpo.Gender,
			"department":     tpo.Department,
			"qualifications": tpo.Qualifications,
			"createdAt":      tpo.CreatedAt,
			"updatedAt":      tpo.UpdatedAt,
		},
		"totalStudents":      studentCount,
		"actualDrives":       jobCount,
		"companiesOnboarded": companyCount,
	})
}

func (tc *TPOController) GetStudentsInDepartment(c *gin.Context) {

	userIDStr, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	tpoID, err := primitive.ObjectIDFromHex(userIDStr.(string))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user ID"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	var tpo models.User
	err = tc.UserCollection.FindOne(ctx, bson.M{"_id": tpoID, "role": "tpo"}).Decode(&tpo)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "TPO not found"})
		return
	}


	query := bson.M{
		"role": "student",
	}


	if tpo.Department == nil || *tpo.Department == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "TPO department not set; cannot fetch students"})
		return
	}
	query["department"] = *tpo.Department


	search := c.Query("search")
	if search != "" {

		query["$or"] = []bson.M{
			{"firstName": bson.M{"$regex": search, "$options": "i"}},
			{"lastName": bson.M{"$regex": search, "$options": "i"}},
			{"rollNumber": bson.M{"$regex": search, "$options": "i"}},
		}
	}


	cursor, err := tc.UserCollection.Find(ctx, query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch students"})
		return
	}
	defer cursor.Close(ctx)


	var rawStudents []bson.M
	if err = cursor.All(ctx, &rawStudents); err != nil {
		println("DEBUG: Error decoding raw students:", err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode students", "details": err.Error()})
		return
	}


	placedCount := 0
	unplacedCount := 0
	studentData := make([]gin.H, 0, len(rawStudents))

	for _, rawStudent := range rawStudents {

		placementStatus := "Unplaced"
		if status, ok := rawStudent["placedStatus"].(string); ok && status != "" {
			placementStatus = status
		}


		if placementStatus == "Placed" {
			placedCount++
		} else {
			unplacedCount++
		}


		var skills []string
		if skillsData, ok := rawStudent["skills"].(primitive.A); ok {
			for _, skill := range skillsData {
				if skillStr, ok := skill.(string); ok {
					skills = append(skills, skillStr)
				}
			}
		}

		studentData = append(studentData, gin.H{
			"id":              rawStudent["_id"],
			"firstName":       rawStudent["firstName"],
			"lastName":        rawStudent["lastName"],
			"email":           rawStudent["email"],
			"rollNumber":      rawStudent["rollNumber"],
			"department":      rawStudent["department"],
			"cgpa":            rawStudent["cgpa"],
			"placementStatus": placementStatus,
			"skills":          skills,
		})
	}


	totalStudents := len(rawStudents)
	placementRate := 0.0
	if totalStudents > 0 {
		placementRate = float64(placedCount) / float64(totalStudents) * 100
	}


	c.JSON(http.StatusOK, gin.H{
		"students": studentData,
		"statistics": gin.H{
			"totalStudents":    totalStudents,
			"placedStudents":   placedCount,
			"unplacedStudents": unplacedCount,
			"placementRate":    placementRate,
		},
	})
}
