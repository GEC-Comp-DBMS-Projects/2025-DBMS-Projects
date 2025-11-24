package services

import (
	"backend/models"
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type JobServiceImpl struct {
	jobCollection         *mongo.Collection
	userCollection        *mongo.Collection
	applicationCollection *mongo.Collection
}

func NewJobService(db *mongo.Database) JobService {
	return &JobServiceImpl{
		jobCollection:         db.Collection("jobs"),
		userCollection:        db.Collection("users"),
		applicationCollection: db.Collection("applications"),
	}
}

func (js *JobServiceImpl) GetAvailableJobs(page, limit int) ([]*JobResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	skip := (page - 1) * limit


	findOptions := options.Find()
	findOptions.SetSkip(int64(skip))
	findOptions.SetLimit(int64(limit))
	findOptions.SetSort(bson.D{{Key: "createdAt", Value: -1}})

	cursor, err := js.jobCollection.Find(ctx, bson.M{}, findOptions)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var jobs []*JobResponse
	for cursor.Next(ctx) {
		var job models.Job
		if err := cursor.Decode(&job); err != nil {
			continue
		}

		jobs = append(jobs, &JobResponse{
			ID:                  job.ID,
			Position:            job.Position,
			CompanyName:         job.CompanyName.Name,
			Description:         job.Description,
			Requirements:        job.Eligibility.Skills,
			Salary:              nil,
			Location:            job.Location,
			JobType:             job.Status,
			ApplicationDeadline: job.ApplicationDeadline.Format(time.RFC3339),
			PostedBy:            job.PostedBy,
			CreatedAt:           job.CreatedAt.Format(time.RFC3339),
		})
	}

	return jobs, nil
}

func (js *JobServiceImpl) GetJobByID(jobID primitive.ObjectID) (*JobResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var job models.Job
	err := js.jobCollection.FindOne(ctx, bson.M{"_id": jobID}).Decode(&job)
	if err != nil {
		return nil, err
	}

	return &JobResponse{
		ID:                  job.ID,
		Position:            job.Position,
		CompanyName:         job.CompanyName.Name,
		Description:         job.Description,
		Requirements:        job.Eligibility.Skills,
		Salary:              nil,
		Location:            job.Location,
		JobType:             job.Status,
		ApplicationDeadline: job.ApplicationDeadline.Format(time.RFC3339),
		PostedBy:            job.PostedBy,
		CreatedAt:           job.CreatedAt.Format(time.RFC3339),
	}, nil
}

func (js *JobServiceImpl) ApplyForJob(studentID, jobID primitive.ObjectID, resumeID primitive.ObjectID) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	count, _ := js.applicationCollection.CountDocuments(ctx, bson.M{
		"student_id": studentID,
		"job_id":     jobID,
	})
	if count > 0 {
		return mongo.ErrNoDocuments
	}


	application := models.Application{
		ID:        primitive.NewObjectID(),
		StudentID: studentID,
		JobID:     jobID,
		ResumeID:  resumeID,
		AppliedOn: time.Now(),
		UpdatedOn: time.Now(),
		Status:    "applied",
	}

	_, err := js.applicationCollection.InsertOne(ctx, application)
	return err
}

func (js *JobServiceImpl) CreateJob(job *models.Job) (*primitive.ObjectID, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	job.ID = primitive.NewObjectID()
	job.CreatedAt = time.Now()

	result, err := js.jobCollection.InsertOne(ctx, job)
	if err != nil {
		return nil, err
	}

	insertedID := result.InsertedID.(primitive.ObjectID)
	return &insertedID, nil
}
