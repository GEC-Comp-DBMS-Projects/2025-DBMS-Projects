package models

import (
	"time"
	"go.mongodb.org/mongo-driver/bson/primitive"
)
type Application struct {
	ID primitive.ObjectID `bson:"_id,omitempty"`
	JobID primitive.ObjectID `bson:"job_id"`
	StudentID primitive.ObjectID `bson:"student_id"`
	ResumeID primitive.ObjectID `bson:"resume_id,omitempty"`
	Status string `bson:"status"`
	AppliedOn time.Time `bson:"applied_on"`
	UpdatedOn time.Time `bson:"updated_on"`
	Remarks string `bson:"remarks,omitempty"`
}
