package controllers

import (
	"backend/models"
	"backend/services"
	"context"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)


type JobController struct {
	JobCollection         *mongo.Collection
	UserCollection        *mongo.Collection
	ApplicationCollection *mongo.Collection


	jobService     services.JobService
	userService    services.UserService
	studentService services.StudentService
}


func NewJobController(db *mongo.Database) *JobController {
	return &JobController{
		JobCollection:         db.Collection("jobs"),
		UserCollection:        db.Collection("users"),
		ApplicationCollection: db.Collection("applications"),


		jobService:     services.NewJobService(db),
		userService:    services.NewUserService(db),
		studentService: services.NewStudentService(db),
	}
}


func (jc *JobController) GetAvailableJobs(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	studentID, _ := primitive.ObjectIDFromHex(userIDHex.(string))


	appliedJobsCursor, err := jc.ApplicationCollection.Find(ctx, bson.M{"student_id": studentID})
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


	filter := bson.M{"status": "open"}




	eligibleOnly, _ := strconv.ParseBool(c.Query("eligibleOnly"))
	if eligibleOnly {
		var user models.User
		if err := jc.UserCollection.FindOne(ctx, bson.M{"_id": studentID}).Decode(&user); err == nil {

			if user.CGPA != nil {
				filter["eligibility.min_cgpa"] = bson.M{"$lte": *user.CGPA}
			}
			if user.Department != nil {
				filter["eligibility.course"] = bson.M{"$in": []string{*user.Department}}
			}

		}
	}


	if industry := c.Query("industry"); industry != "" {



	}


	if location := c.Query("location"); location != "" {
		filter["location"] = location
	}


	if search := c.Query("search"); search != "" {

		filter["position"] = bson.M{"$regex": search, "$options": "i"}
	}


	cursor, err := jc.JobCollection.Find(ctx, filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch available jobs"})
		return
	}

	var jobs []models.Job
	if err = cursor.All(ctx, &jobs); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode jobs"})
		return
	}


	appliedJobsMap := make(map[primitive.ObjectID]bool)
	for _, jobID := range appliedJobIDs {
		appliedJobsMap[jobID] = true
	}


	var jobsWithStatus []gin.H
	for _, job := range jobs {
		hasApplied := appliedJobsMap[job.ID]
		jobsWithStatus = append(jobsWithStatus, gin.H{
			"job":         job,
			"has_applied": hasApplied,
		})
	}


	c.JSON(http.StatusOK, jobsWithStatus)
}
func (jc *JobController) GetJobById(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	jobIDHex := c.Param("jobId")
	jobID, err := primitive.ObjectIDFromHex(jobIDHex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job ID format"})
		return
	}


	userIDHex, _ := c.Get("userID")
	studentID, _ := primitive.ObjectIDFromHex(userIDHex.(string))


	count, err := jc.ApplicationCollection.CountDocuments(ctx, bson.M{"student_id": studentID, "job_id": jobID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check application status"})
		return
	}
	hasApplied := count > 0

	var job models.Job
	if err := jc.JobCollection.FindOne(ctx, bson.M{"_id": jobID}).Decode(&job); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Job not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"job":         job,
		"has_applied": hasApplied,
	})
}
func (jc *JobController) ApplyForJob(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()


	userIDHex, _ := c.Get("userID")
	studentID, _ := primitive.ObjectIDFromHex(userIDHex.(string))

	jobIDHex := c.Param("jobId")
	jobID, err := primitive.ObjectIDFromHex(jobIDHex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job ID format"})
		return
	}


	var reqBody struct {
		ResumeID string `json:"resume_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "resume_id is required in request body"})
		return
	}

	resumeID, err := primitive.ObjectIDFromHex(reqBody.ResumeID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid resume_id format"})
		return
	}


	count, err := jc.ApplicationCollection.CountDocuments(ctx, bson.M{"student_id": studentID, "job_id": jobID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check existing applications"})
		return
	}
	if count > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "You have already applied for this job"})
		return
	}


	var user models.User
	if err := jc.UserCollection.FindOne(ctx, bson.M{"_id": studentID}).Decode(&user); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Could not find your user profile"})
		return
	}


	resumeExists := false
	for _, rid := range user.ActiveResumeID {
		if rid == resumeID {
			resumeExists = true
			break
		}
	}
	if !resumeExists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "The provided resume does not belong to you"})
		return
	}


	newApplication := models.Application{
		ID:        primitive.NewObjectID(),
		JobID:     jobID,
		StudentID: studentID,
		ResumeID:  resumeID,
		Status:    "applied",
		AppliedOn: time.Now(),
	}


	_, err = jc.ApplicationCollection.InsertOne(ctx, newApplication)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to submit application"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Application submitted successfully"})
}
