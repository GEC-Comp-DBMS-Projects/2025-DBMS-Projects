package controllers

import (
	"context"
	"net/http"
	"os"
	"time"

	"backend/models"
	"backend/services"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
)

type AuthController struct {
	UserCollection    *mongo.Collection
	StudentController *StudentController 
	TPOController     *TPOController

	authService    services.AuthService
	userService    services.UserService
	studentService services.StudentService
	tpoService     services.TPOService
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

func NewAuthController(db *mongo.Database, sc *StudentController, tc *TPOController) *AuthController {
	return &AuthController{
		UserCollection:    db.Collection("users"),
		StudentController: sc,
		TPOController:     tc,

		authService:    services.NewAuthService(db),
		userService:    services.NewUserService(db),
		studentService: services.NewStudentService(db),
		tpoService:     services.NewTPOService(db),
	}
}

func (ac *AuthController) Login(c *gin.Context) {
	var req LoginRequest
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request format"})
		return
	}

	var user models.User
	err := ac.UserCollection.FindOne(ctx, bson.M{"email": req.Email}).Decode(&user)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":  user.ID.Hex(),
		"role": user.Role,
		"exp":  time.Now().Add(time.Hour * 72).Unix(),
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user": gin.H{
			"id":        user.ID,
			"firstName": user.FirstName,
			"email":     user.Email,
			"role":      user.Role,
		},
	})
}

func (ac *AuthController) GetProfileByRole(c *gin.Context) {
	roleFromURL := c.Param("role")
	roleFromToken, exists := c.Get("userRole")
	if !exists || roleFromURL != roleFromToken.(string) {
		c.JSON(http.StatusForbidden, gin.H{"error": "You are not authorized to access this role's data"})
		return
	}

	switch roleFromURL {
	case "student":
		ac.StudentController.GetMyProfile(c)
	case "tpo":
		ac.TPOController.GetMyProfile(c)
	case "rec":
		ac.getRecruiterProfile(c)
	case "admin":
		ac.getAdminProfile(c)
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid role specified"})
	}
}
func (ac *AuthController) getRecruiterProfile(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	recruiterID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var recruiter models.User
	err = ac.UserCollection.FindOne(ctx, bson.M{"_id": recruiterID}).Decode(&recruiter)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Recruiter not found"})
		return
	}

	profile := gin.H{
		"id":        recruiter.ID,
		"firstName": recruiter.FirstName,
		"lastName":  recruiter.LastName,
		"email":     recruiter.Email,
		"role":      recruiter.Role,
		"createdAt": recruiter.CreatedAt,
		"updatedAt": recruiter.UpdatedAt,
	}

	if recruiter.Gender != nil {
		profile["gender"] = *recruiter.Gender
	}
	if recruiter.CompanyID != nil {
		profile["companyId"] = *recruiter.CompanyID

		companyCollection := ac.UserCollection.Database().Collection("companies")
		var company models.Company
		err = companyCollection.FindOne(ctx, bson.M{"_id": *recruiter.CompanyID}).Decode(&company)
		if err == nil {
			profile["company"] = gin.H{
				"id":          company.ID,
				"name":        company.Name,
				"description": company.Description,
				"industry":    company.Industry,
				"website":     company.Website,
			}
		} else {
			profile["company"] = gin.H{
				"id":      *recruiter.CompanyID,
				"name":    "Company Not Found",
				"message": "Company details not found. Please contact admin.",
			}
		}
	} else {
		profile["company"] = nil
		profile["message"] = "No company associated. Please contact admin to associate your account with a company."
	}

	jobCollection := ac.UserCollection.Database().Collection("jobs")
	applicationCollection := ac.UserCollection.Database().Collection("applications")

	totalJobs := int64(0)
	if recruiter.CompanyID != nil {
		totalJobs, _ = jobCollection.CountDocuments(ctx, bson.M{"company_name.companyId": *recruiter.CompanyID})
	}

	totalApplications := int64(0)
	shortlistedCount := int64(0)

	if recruiter.CompanyID != nil {
		jobCursor, err := jobCollection.Find(ctx, bson.M{"company_name.companyId": *recruiter.CompanyID})
		if err == nil {
			var jobs []models.Job
			jobCursor.All(ctx, &jobs)

			if len(jobs) > 0 {
				var jobIDs []primitive.ObjectID
				for _, job := range jobs {
					jobIDs = append(jobIDs, job.ID)
				}

				totalApplications, _ = applicationCollection.CountDocuments(ctx, bson.M{"job_id": bson.M{"$in": jobIDs}})

				shortlistedCount, _ = applicationCollection.CountDocuments(ctx, bson.M{
					"job_id": bson.M{"$in": jobIDs},
					"status": "shortlisted",
				})
			}
		}
	}

	profile["totalJobPostings"] = totalJobs
	profile["totalApplications"] = totalApplications
	profile["shortlistedCount"] = shortlistedCount

	c.JSON(http.StatusOK, gin.H{
		"user": profile,
	})
}

func (ac *AuthController) getAdminProfile(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	userIDHex, _ := c.Get("userID")
	adminID, err := primitive.ObjectIDFromHex(userIDHex.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	var admin models.User
	err = ac.UserCollection.FindOne(ctx, bson.M{"_id": adminID}).Decode(&admin)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Admin user not found"})
		return
	}

	profile := gin.H{
		"id":        admin.ID,
		"firstName": admin.FirstName,
		"lastName":  admin.LastName,
		"email":     admin.Email,
		"role":      admin.Role,
		"createdAt": admin.CreatedAt,
		"updatedAt": admin.UpdatedAt,
	}

	if admin.Gender != nil {
		profile["gender"] = *admin.Gender
	}

	userCollection := ac.UserCollection.Database().Collection("users")
	applicationCollection := ac.UserCollection.Database().Collection("applications")
	companyCollection := ac.UserCollection.Database().Collection("companies")

	studentsCount, _ := userCollection.CountDocuments(ctx, bson.M{"role": "student"})

	companiesCount, _ := companyCollection.CountDocuments(ctx, bson.M{})

	applicationsCount, _ := applicationCollection.CountDocuments(ctx, bson.M{})

	shortlistedCount, _ := applicationCollection.CountDocuments(ctx, bson.M{"status": "shortlisted"})
	selectedCount, _ := applicationCollection.CountDocuments(ctx, bson.M{"status": "selected"})
	interviewedCount, _ := applicationCollection.CountDocuments(ctx, bson.M{"status": "interviewed"})

	summary := gin.H{
		"students":     studentsCount,
		"companies":    companiesCount,
		"applications": applicationsCount,
		"shortlisted":  shortlistedCount,
		"selected":     selectedCount,
		"interviewed":  interviewedCount,
	}

	c.JSON(http.StatusOK, gin.H{"user": profile, "summary": summary})
}
