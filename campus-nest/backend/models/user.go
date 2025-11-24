package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type User struct {
	ID              primitive.ObjectID `bson:"_id,omitempty"`
	FirstName       string             `bson:"firstName"`
	LastName        string             `bson:"lastName"`
	Email           string             `bson:"email"`
	PasswordHash    string             `bson:"passwordHash"`
	Role            string             `bson:"role"`
	CreatedAt       time.Time          `bson:"createdAt"`
	UpdatedAt       time.Time          `bson:"updatedAt"`
	Gender          *string            `bson:"gender,omitempty"`
	Department      *string            `bson:"department,omitempty"`
	PlacementStatus *string            `bson:"placedStatus,omitempty" default:"Placed"`

	RollNumber *string  `bson:"rollNumber,omitempty"`
	CGPA       *float64 `bson:"cgpa,omitempty"`
	ActiveResumeID []primitive.ObjectID `bson:"activeResumeId,omitempty" json:"activeResumeId,omitempty"`
	Skills         []string             `bson:"skills,omitempty"`
	Notifications  []Notification       `bson:"notifications,omitempty"`
	Qualifications []Qualification `bson:"qualifications,omitempty" json:"qualifications,omitempty"`
	CompanyID *primitive.ObjectID `bson:"companyId,omitempty"`
}
type Notification struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Subject   string             `bson:"subject" json:"subject"`
	Message   string             `bson:"message" json:"message"`
	IsRead    bool               `bson:"isRead" json:"isRead"`
	CreatedAt time.Time          `bson:"createdAt" json:"createdAt"`
}
type Qualification struct {
	Title       string `bson:"title" json:"title"`
	Description string `bson:"description" json:"description"`
}
