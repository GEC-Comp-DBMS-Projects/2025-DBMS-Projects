package services

import (
	"backend/models"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
)


type AuthService interface {
	Login(email, password string) (*LoginResponse, error)
	ValidateToken(token string) (*TokenClaims, error)
}


type UserService interface {
	GetUserByID(userID primitive.ObjectID) (*models.User, error)
	GetUserByEmail(email string) (*models.User, error)
	UpdateUser(userID primitive.ObjectID, updates map[string]interface{}) error
}


type StudentService interface {
	GetStudentProfile(studentID primitive.ObjectID) (*StudentProfileResponse, error)
	GetStudentApplications(studentID primitive.ObjectID) ([]*ApplicationResponse, error)
	UpdateStudentSkills(studentID primitive.ObjectID, skills []string) error
}


type TPOService interface {
	GetTPOProfile(tpoID primitive.ObjectID) (*TPOProfileResponse, error)
	GetStudentsInDepartment(tpoID primitive.ObjectID, searchQuery string) (*StudentsResponse, error)
}


type JobService interface {
	GetAvailableJobs(page, limit int) ([]*JobResponse, error)
	GetJobByID(jobID primitive.ObjectID) (*JobResponse, error)
	ApplyForJob(studentID, jobID primitive.ObjectID, resumeID primitive.ObjectID) error
	CreateJob(job *models.Job) (*primitive.ObjectID, error)
}


type DashboardService interface {
	GetStudentDashboard(studentID primitive.ObjectID) (*StudentDashboardResponse, error)
	GetTPODashboard(tpoID primitive.ObjectID) (*TPODashboardResponse, error)
	GetRecruiterDashboard(recruiterID primitive.ObjectID) (*RecruiterDashboardResponse, error)
}


type CompanyService interface {
	GetAllCompanies() ([]*models.Company, error)
	GetCompanyByID(companyID primitive.ObjectID) (*models.Company, error)
	CreateCompany(company *models.Company) (*primitive.ObjectID, error)
	AddRecruiterToCompany(companyID primitive.ObjectID, recruiter map[string]interface{}) error
}


type LoginResponse struct {
	Token string    `json:"token"`
	User  *UserInfo `json:"user"`
}

type UserInfo struct {
	ID        primitive.ObjectID `json:"id"`
	FirstName string             `json:"firstName"`
	Email     string             `json:"email"`
	Role      string             `json:"role"`
}

type TokenClaims struct {
	UserID string `json:"sub"`
	Role   string `json:"role"`
	Exp    int64  `json:"exp"`
}

type StudentProfileResponse struct {
	ID         primitive.ObjectID `json:"id"`
	FirstName  string             `json:"firstName"`
	LastName   string             `json:"lastName"`
	Email      string             `json:"email"`
	Role       string             `json:"role"`
	Department *string            `json:"department"`
	CGPA       *float64           `json:"cgpa"`
	Skills     []string           `json:"skills"`
	RollNumber *string            `json:"rollNumber"`
	ResumeLink string             `json:"resumeLink"`
}

type ApplicationResponse struct {
	ID          primitive.ObjectID `json:"id"`
	StudentID   primitive.ObjectID `json:"studentId"`
	AppliedOn   string             `json:"appliedOn"`
	Status      string             `json:"status"`
	CompanyName string             `json:"companyName"`
	Role        string             `json:"role"`
}

type TPOProfileResponse struct {
	Profile            *UserProfile `json:"profile"`
	TotalStudents      int64        `json:"totalStudents"`
	ActualDrives       int64        `json:"actualDrives"`
	CompaniesOnboarded int64        `json:"companiesOnboarded"`
}

type UserProfile struct {
	ID             primitive.ObjectID     `json:"id"`
	FirstName      string                 `json:"firstName"`
	LastName       string                 `json:"lastName"`
	Email          string                 `json:"email"`
	Role           string                 `json:"role"`
	Gender         *string                `json:"gender"`
	Department     *string                `json:"department"`
	Qualifications []models.Qualification `json:"qualifications"`
	CreatedAt      string                 `json:"createdAt"`
	UpdatedAt      string                 `json:"updatedAt"`
}

type StudentsResponse struct {
	Students   []*StudentInfo  `json:"students"`
	Statistics *PlacementStats `json:"statistics"`
}

type StudentInfo struct {
	ID              primitive.ObjectID `json:"id"`
	FirstName       string             `json:"firstName"`
	LastName        string             `json:"lastName"`
	Email           string             `json:"email"`
	RollNumber      *string            `json:"rollNumber"`
	Department      *string            `json:"department"`
	CGPA            *float64           `json:"cgpa"`
	PlacementStatus string             `json:"placementStatus"`
	Skills          []string           `json:"skills"`
}

type PlacementStats struct {
	TotalStudents    int     `json:"totalStudents"`
	PlacedStudents   int     `json:"placedStudents"`
	UnplacedStudents int     `json:"unplacedStudents"`
	PlacementRate    float64 `json:"placementRate"`
}

type JobResponse struct {
	ID                  primitive.ObjectID `json:"id"`
	Position            string             `json:"position"`
	CompanyName         string             `json:"companyName"`
	Description         string             `json:"description"`
	Requirements        []string           `json:"requirements"`
	Salary              *float64           `json:"salary"`
	Location            string             `json:"location"`
	JobType             string             `json:"jobType"`
	ApplicationDeadline string             `json:"applicationDeadline"`
	PostedBy            primitive.ObjectID `json:"postedBy"`
	CreatedAt           string             `json:"createdAt"`
}

type StudentDashboardResponse struct {

	WelcomeMessage string `json:"welcomeMessage"`
	Stats          gin.H  `json:"stats"`
}

type TPODashboardResponse struct {

	WelcomeMessage string `json:"welcomeMessage"`
	Stats          gin.H  `json:"stats"`
}

type RecruiterDashboardResponse struct {

	WelcomeMessage string `json:"welcomeMessage"`
	Stats          gin.H  `json:"stats"`
}
