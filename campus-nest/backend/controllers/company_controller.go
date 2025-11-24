package controllers

import (
	"backend/models"
	"backend/services"
	"net/http"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type CompanyController struct {
	companyService services.CompanyService
}

func NewCompanyController(db *mongo.Database) *CompanyController {
	return &CompanyController{
		companyService: services.NewCompanyService(db),
	}
}

func (cc *CompanyController) GetAllCompanies(c *gin.Context) {
	companies, err := cc.companyService.GetAllCompanies()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch companies", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"companies": companies})
}

func (cc *CompanyController) AddCompanyWithRecruiters(c *gin.Context) {
	var req struct {
		Name        string `json:"name"`
		Website     string `json:"website"`
		Industry    string `json:"industry"`
		Description string `json:"description"`
		Recruiters  []struct {
			FirstName string `json:"firstName"`
			LastName  string `json:"lastName"`
			Email     string `json:"email"`
			Password  string `json:"password"`
		} `json:"recruiters"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request", "details": err.Error()})
		return
	}
	if len(req.Recruiters) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "At least one recruiter required"})
		return
	}

	company := &models.Company{
		Name:        req.Name,
		Website:     req.Website,
		Industry:    req.Industry,
		Description: req.Description,
	}
	companyID, err := cc.companyService.CreateCompany(company)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create company", "details": err.Error()})
		return
	}

	recruiterIDs := []string{}
	for _, r := range req.Recruiters {
		recruiter := map[string]interface{}{
			"firstName": r.FirstName,
			"lastName":  r.LastName,
			"email":     r.Email,
			"password":  r.Password,
			"role":      "rec",
			"companyId": companyID.Hex(),
		}
		err := cc.companyService.AddRecruiterToCompany(*companyID, recruiter)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add recruiter", "details": err.Error()})
			return
		}
		recruiterIDs = append(recruiterIDs, r.Email)
	}
	c.JSON(http.StatusOK, gin.H{"companyId": companyID.Hex(), "recruiters": recruiterIDs})
}

func (cc *CompanyController) AddRecruiterToCompany(c *gin.Context) {
	companyIDHex := c.Param("id")
	companyID, err := primitive.ObjectIDFromHex(companyIDHex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid company ID"})
		return
	}
	var req struct {
		FirstName string `json:"firstName"`
		LastName  string `json:"lastName"`
		Email     string `json:"email"`
		Password  string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request", "details": err.Error()})
		return
	}
	recruiter := map[string]interface{}{
		"firstName": req.FirstName,
		"lastName":  req.LastName,
		"email":     req.Email,
		"password":  req.Password,
		"role":      "rec",
		"companyId": companyID.Hex(),
	}
	err = cc.companyService.AddRecruiterToCompany(companyID, recruiter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add recruiter", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Recruiter added", "email": req.Email})
}
