package services

import (
	"backend/models"
	"context"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type CompanyServiceImpl struct {
	companyCollection *mongo.Collection
	userCollection    *mongo.Collection
}

func NewCompanyService(db *mongo.Database) CompanyService {
	return &CompanyServiceImpl{
		companyCollection: db.Collection("companies"),
		userCollection:    db.Collection("users"),
	}

}

func (cs *CompanyServiceImpl) GetAllCompanies() ([]*models.Company, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cursor, err := cs.companyCollection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var companies []*models.Company
	if err = cursor.All(ctx, &companies); err != nil {
		return nil, err
	}

	return companies, nil
}

func (cs *CompanyServiceImpl) GetCompanyByID(companyID primitive.ObjectID) (*models.Company, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var company models.Company
	err := cs.companyCollection.FindOne(ctx, bson.M{"_id": companyID}).Decode(&company)
	if err != nil {
		return nil, err
	}

	return &company, nil
}

func (cs *CompanyServiceImpl) CreateCompany(company *models.Company) (*primitive.ObjectID, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	company.ID = primitive.NewObjectID()

	result, err := cs.companyCollection.InsertOne(ctx, company)
	if err != nil {
		return nil, err
	}

	insertedID := result.InsertedID.(primitive.ObjectID)
	return &insertedID, nil
}


func (cs *CompanyServiceImpl) AddRecruiterToCompany(companyID primitive.ObjectID, recruiter map[string]interface{}) error {
	recruiter["companyId"] = companyID
	recruiter["role"] = "rec"
	_, err := cs.userCollection.InsertOne(context.TODO(), recruiter)
	return err
}
