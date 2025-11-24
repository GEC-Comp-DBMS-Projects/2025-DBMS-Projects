package services

import (
	"go.mongodb.org/mongo-driver/mongo"
)


type ServiceManager struct {
	AuthService      AuthService
	UserService      UserService
	StudentService   StudentService
	TPOService       TPOService
	JobService       JobService
	DashboardService DashboardService
	CompanyService   CompanyService
}


func NewServiceManager(db *mongo.Database) *ServiceManager {
	return &ServiceManager{
		AuthService:      NewAuthService(db),
		UserService:      NewUserService(db),
		StudentService:   NewStudentService(db),
		TPOService:       NewTPOService(db),
		JobService:       NewJobService(db),
		DashboardService: NewDashboardService(db),
		CompanyService:   NewCompanyService(db),
	}
}


func (sm *ServiceManager) GetAuthService() AuthService {
	return sm.AuthService
}


func (sm *ServiceManager) GetUserService() UserService {
	return sm.UserService
}


func (sm *ServiceManager) GetStudentService() StudentService {
	return sm.StudentService
}


func (sm *ServiceManager) GetTPOService() TPOService {
	return sm.TPOService
}


func (sm *ServiceManager) GetJobService() JobService {
	return sm.JobService
}


func (sm *ServiceManager) GetDashboardService() DashboardService {
	return sm.DashboardService
}


func (sm *ServiceManager) GetCompanyService() CompanyService {
	return sm.CompanyService
}
