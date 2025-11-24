package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Eligibility struct {
	MinCGPA        float64  `bson:"min_cgpa,omitempty" json:"min_cgpa"`
	Course         []string `bson:"course,omitempty" json:"course"`
	Skills         []string `bson:"skills,omitempty" json:"skills"`
	Batch          []int    `bson:"batch,omitempty" json:"batch"`
	GraduationYear int      `bson:"graduation_year,omitempty" json:"graduation_year"`
	MaxBacklogs    int      `bson:"max_backlogs,omitempty" json:"max_backlogs"`
}
type EmbeddedCompany struct {
	CompanyID primitive.ObjectID `bson:"companyId,omitempty" json:"companyId"`
	Name      string             `bson:"name" json:"name"`
}
type Job struct {
	ID                  primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	CompanyName         EmbeddedCompany    `bson:"company_name" json:"company_name"`
	Position            string             `bson:"position" json:"position"`
	Description         string             `bson:"description" json:"description"`
	PostedBy            primitive.ObjectID `bson:"posted_by,omitempty" json:"posted_by"`
	CreatedAt           time.Time          `bson:"created_at" json:"created_at"`
	Eligibility         Eligibility        `bson:"eligibility" json:"eligibility"`
	SalaryRange         string             `bson:"salary_range,omitempty" json:"salary_range"`
	ApplicationDeadline time.Time          `bson:"application_deadline" json:"application_deadline"`
	Location            string             `bson:"location,omitempty" json:"location"`
	Status              string             `bson:"status,omitempty" json:"status"`
}
