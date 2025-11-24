package services

import (
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type DashboardServiceImpl struct {

}

func NewDashboardService(db interface{}) DashboardService {
	return &DashboardServiceImpl{

	}
}

func (ds *DashboardServiceImpl) GetStudentDashboard(studentID primitive.ObjectID) (*StudentDashboardResponse, error) {


	return &StudentDashboardResponse{
		WelcomeMessage: "Welcome, Student!",
		Stats:          gin.H{"message": "Dashboard data"},
	}, nil
}

func (ds *DashboardServiceImpl) GetTPODashboard(tpoID primitive.ObjectID) (*TPODashboardResponse, error) {

	return &TPODashboardResponse{
		WelcomeMessage: "Welcome, TPO!",
		Stats:          gin.H{"message": "Dashboard data"},
	}, nil
}

func (ds *DashboardServiceImpl) GetRecruiterDashboard(recruiterID primitive.ObjectID) (*RecruiterDashboardResponse, error) {

	return &RecruiterDashboardResponse{
		WelcomeMessage: "Welcome, Recruiter!",
		Stats:          gin.H{"message": "Dashboard data"},
	}, nil
}
