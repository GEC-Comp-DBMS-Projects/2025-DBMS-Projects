package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Education struct {
	Degree      string      `bson:"degree,omitempty" json:"degree,omitempty"`
	Institution string      `bson:"institution,omitempty" json:"institution,omitempty"`
	Year        string      `bson:"year,omitempty" json:"year,omitempty"`
	GPA         interface{} `bson:"gpa,omitempty" json:"gpa,omitempty"`
}

type ParsedResume struct {
	Contact   string      `bson:"contact,omitempty" json:"contact,omitempty"`
	Education []Education `bson:"education,omitempty" json:"education,omitempty"`
	Skills    []string    `bson:"skills,omitempty" json:"skills,omitempty"`
}

type Resume struct {
	ID         primitive.ObjectID `bson:"_id,omitempty" json:"id,omitempty"`
	StudentID  primitive.ObjectID `bson:"student_id" json:"student_id"`
	ResumeName string             `bson:"resume_name,omitempty" json:"resume_name,omitempty"`
	FileURL    string             `bson:"file_url" json:"file_url"`
	OCRText    string             `bson:"ocr_text,omitempty" json:"ocr_text,omitempty"`
	ParsedData ParsedResume       `bson:"parsed_data" json:"parsed_data"`
	UploadedAt time.Time          `bson:"uploaded_at" json:"uploaded_at"`
}
