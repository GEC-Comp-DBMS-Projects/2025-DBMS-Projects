package services

import (
	"context"
	"time"

	"backend/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type StudentServiceImpl struct {
	userCollection        *mongo.Collection
	resumeCollection      *mongo.Collection
	applicationCollection *mongo.Collection
}

func NewStudentService(db *mongo.Database) StudentService {
	return &StudentServiceImpl{
		userCollection:        db.Collection("users"),
		resumeCollection:      db.Collection("resumes"),
		applicationCollection: db.Collection("applications"),
	}
}

func (ss *StudentServiceImpl) GetStudentProfile(studentID primitive.ObjectID) (*StudentProfileResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user models.User
	err := ss.userCollection.FindOne(ctx, bson.M{"_id": studentID}).Decode(&user)
	if err != nil {
		return nil, err
	}

	var skills []string
	var resumeLink string


	if len(user.ActiveResumeID) > 0 {
		var resume models.Resume
		err = ss.resumeCollection.FindOne(ctx, bson.M{"_id": user.ActiveResumeID[0]}).Decode(&resume)
		if err == nil {
			resumeLink = resume.FileURL
			skills = resume.ParsedData.Skills
		}
	}

	if skills == nil {
		skills = user.Skills
	}

	return &StudentProfileResponse{
		ID:         user.ID,
		FirstName:  user.FirstName,
		LastName:   user.LastName,
		Email:      user.Email,
		Role:       user.Role,
		Department: user.Department,
		CGPA:       user.CGPA,
		Skills:     skills,
		RollNumber: user.RollNumber,
		ResumeLink: resumeLink,
	}, nil
}

func (ss *StudentServiceImpl) GetStudentApplications(studentID primitive.ObjectID) ([]*ApplicationResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

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

	cursor, err := ss.applicationCollection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var applications []*ApplicationResponse
	for cursor.Next(ctx) {
		var app struct {
			ID          primitive.ObjectID `bson:"_id"`
			StudentID   primitive.ObjectID `bson:"student_id"`
			AppliedOn   time.Time          `bson:"applied_on"`
			Status      string             `bson:"status"`
			CompanyName string             `bson:"companyName"`
			Role        string             `bson:"role"`
		}
		if err := cursor.Decode(&app); err != nil {
			continue
		}
		applications = append(applications, &ApplicationResponse{
			ID:          app.ID,
			StudentID:   app.StudentID,
			AppliedOn:   app.AppliedOn.Format(time.RFC3339),
			Status:      app.Status,
			CompanyName: app.CompanyName,
			Role:        app.Role,
		})
	}

	return applications, nil
}

func (ss *StudentServiceImpl) UpdateStudentSkills(studentID primitive.ObjectID, skills []string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err := ss.userCollection.UpdateOne(
		ctx,
		bson.M{"_id": studentID},
		bson.M{"$set": bson.M{"skills": skills, "updatedAt": time.Now()}},
	)
	return err
}
