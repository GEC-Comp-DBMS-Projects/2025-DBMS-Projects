package routes

import (
	"backend/controllers"
	"backend/middleware"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/mongo"
)

func SetupRoutes(router *gin.Engine, client *mongo.Client) {
	db := client.Database("campusNestDB")

	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "message": "Server is running"})
	})

	studentController := controllers.NewStudentController(db)
	tpoController := controllers.NewTPOController(db)
	authController := controllers.NewAuthController(db, studentController, tpoController)
	dashboardController := controllers.NewDashboardController(db)
	jobController := controllers.NewJobController(db)
	adminController := controllers.NewAdminController(db)
	companyController := controllers.NewCompanyController(db)

	api := router.Group("/api/v1")
	{
		public := api.Group("/auth")
		{
			public.POST("/login", authController.Login)
		}
		studentRoutes := api.Group("/student")
		studentRoutes.Use(middleware.AuthMiddleware("student"))
		{
			studentRoutes.GET("/jobs", jobController.GetAvailableJobs)
			studentRoutes.GET("/jobs/:jobId", jobController.GetJobById)
			studentRoutes.GET("/applications", studentController.GetMyApplications)
			studentRoutes.GET("/applications/:applicationId", studentController.GetApplicationDetails)
			studentRoutes.POST("/jobs/:jobId/apply", jobController.ApplyForJob)
			studentRoutes.GET("/notifications", studentController.GetMyNotifications)
		}
		tpoRoutes := api.Group("/tpo")
		tpoRoutes.Use(middleware.AuthMiddleware("tpo"))
		{
			tpoRoutes.GET("/analytics", dashboardController.GetTPOAnalyticsDashboard)
			tpoRoutes.GET("/companies", companyController.GetAllCompanies)
			tpoRoutes.POST("/drives", dashboardController.CreateDrive)
			tpoRoutes.POST("/reports", dashboardController.GenerateReport)
			tpoRoutes.GET("/drives", dashboardController.GetAllDrives)
			tpoRoutes.GET("/drives/:driveId", dashboardController.GetDriveDetails)
			tpoRoutes.GET("/drives/:driveId/applications", dashboardController.GetDriveApplications)
			tpoRoutes.PUT("/drives/:driveId/status", dashboardController.UpdateDriveStatus)
			tpoRoutes.GET("/analytics/company-placements", dashboardController.GetCompanyWisePlacements)
			tpoRoutes.GET("/analytics/salary", dashboardController.GetSalaryAnalytics)
			tpoRoutes.GET("/analytics/trends", dashboardController.GetPlacementTrends)
			tpoRoutes.GET("/reports/export", dashboardController.ExportReport)
			tpoRoutes.POST("/notifications", dashboardController.SendNotification)
			tpoRoutes.POST("/notifications/preview", dashboardController.PreviewNotification)
			tpoRoutes.GET("/notifications", dashboardController.GetNotificationHistory)
			tpoRoutes.GET("/students/search", dashboardController.SearchStudents)
			tpoRoutes.GET("/students", tpoController.GetStudentsInDepartment)
		}

		recruiterRoutes := api.Group("/rec")
		recruiterRoutes.Use(middleware.AuthMiddleware("rec"))
		{
			recruiterRoutes.GET("/candidates", dashboardController.GetRecruiterCandidates)
			recruiterRoutes.GET("/resumes/download-all", dashboardController.DownloadAllResumes)
			recruiterRoutes.GET("/job-drives", dashboardController.GetCompanyJobDrives)
			recruiterRoutes.GET("/job-drives/:jobId", dashboardController.GetJobDriveDetails)
			recruiterRoutes.GET("/job-drives/:jobId/students/:studentId", dashboardController.GetStudentDetailsForJobDrive)
			recruiterRoutes.PUT("/job-drives/:jobId/students/status", dashboardController.UpdateStudentApplicationStatus)
			recruiterRoutes.GET("/notifications", dashboardController.GetRecruiterNotifications)
			recruiterRoutes.GET("/stats", dashboardController.GetRecStats)
		}
		protected := api.Group("/")
		protected.Use(middleware.AuthMiddleware("student", "tpo", "admin", "rec"))
		{
			protected.GET("/profile/:role", authController.GetProfileByRole)
			protected.GET("/dashboard/:role", dashboardController.GetDashboardByRole)
			protected.PUT("/profile/:role", dashboardController.UpdateSkills)
		}

		adminRoutes := api.Group("/admin")
		adminRoutes.Use(middleware.AuthMiddleware("admin"))
		{
			adminRoutes.GET("/students", adminController.GetStudents)
			adminRoutes.POST("/student", adminController.AddStudent)
			adminRoutes.POST("/students/upload-csv", adminController.AddStudentsBatch)
			adminRoutes.GET("/tpos", adminController.GetAllTPOs)
			adminRoutes.POST("/tpo", adminController.AddTPO)
			adminRoutes.GET("/companies", companyController.GetAllCompanies)
			adminRoutes.POST("/company", companyController.AddCompanyWithRecruiters)
			adminRoutes.POST("/company/:id/recruiter", companyController.AddRecruiterToCompany)
			adminRoutes.POST("/announcements", adminController.SendAnnouncement)
			adminRoutes.GET("/analytics/placements", adminController.GetPlacementStats)
			adminRoutes.GET("/analytics/companies", adminController.GetCompanyAnalytics)
			adminRoutes.POST("/drives", adminController.CreateJobDrive)
			adminRoutes.GET("/drives", adminController.GetAllDrives)
			adminRoutes.GET("/drives/:driveId", adminController.GetDriveDetails)
			adminRoutes.GET("/drives/:driveId/applications", adminController.GetDriveApplications)
			adminRoutes.GET("/reports/export", adminController.ExportReport)
		}

	}
}
