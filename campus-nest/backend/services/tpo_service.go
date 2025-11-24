package services

import (
	"context"
	"time"

	"backend/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type TPOServiceImpl struct {
	userCollection    *mongo.Collection
	jobCollection     *mongo.Collection
	companyCollection *mongo.Collection
}

func NewTPOService(db *mongo.Database) TPOService {
	return &TPOServiceImpl{
		userCollection:    db.Collection("users"),
		jobCollection:     db.Collection("jobs"),
		companyCollection: db.Collection("companies"),
	}
}

func (ts *TPOServiceImpl) GetTPOProfile(tpoID primitive.ObjectID) (*TPOProfileResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	var tpo models.User
	err := ts.userCollection.FindOne(ctx, bson.M{"_id": tpoID, "role": "tpo"}).Decode(&tpo)
	if err != nil {
		return nil, err
	}


	studentCount, _ := ts.userCollection.CountDocuments(ctx, bson.M{
		"role":       "student",
		"department": tpo.Department,
	})


	jobCount, _ := ts.jobCollection.CountDocuments(ctx, bson.M{
		"posted_by": tpoID,
	})


	companyCount, _ := ts.companyCollection.CountDocuments(ctx, bson.M{})

	return &TPOProfileResponse{
		Profile: &UserProfile{
			ID:             tpo.ID,
			FirstName:      tpo.FirstName,
			LastName:       tpo.LastName,
			Email:          tpo.Email,
			Role:           tpo.Role,
			Gender:         tpo.Gender,
			Department:     tpo.Department,
			Qualifications: tpo.Qualifications,
			CreatedAt:      tpo.CreatedAt.Format(time.RFC3339),
			UpdatedAt:      tpo.UpdatedAt.Format(time.RFC3339),
		},
		TotalStudents:      studentCount,
		ActualDrives:       jobCount,
		CompaniesOnboarded: companyCount,
	}, nil
}

func (ts *TPOServiceImpl) GetStudentsInDepartment(tpoID primitive.ObjectID, searchQuery string) (*StudentsResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()


	var tpo models.User
	err := ts.userCollection.FindOne(ctx, bson.M{"_id": tpoID, "role": "tpo"}).Decode(&tpo)
	if err != nil {
		return nil, err
	}


	query := bson.M{
		"role": "student",
	}


	if tpo.Department != nil && *tpo.Department != "" {
		query["department"] = *tpo.Department
	}


	if searchQuery != "" {
		query["$or"] = []bson.M{
			{"firstName": bson.M{"$regex": searchQuery, "$options": "i"}},
			{"lastName": bson.M{"$regex": searchQuery, "$options": "i"}},
			{"rollNumber": bson.M{"$regex": searchQuery, "$options": "i"}},
		}
	}


	cursor, err := ts.userCollection.Find(ctx, query)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var students []models.User
	if err = cursor.All(ctx, &students); err != nil {
		return nil, err
	}


	placedCount := 0
	unplacedCount := 0
	studentData := make([]*StudentInfo, len(students))

	for i, student := range students {

		placementStatus := "Unplaced"
		if student.PlacementStatus != nil && *student.PlacementStatus != "" {
			placementStatus = *student.PlacementStatus
		}


		if placementStatus == "Placed" {
			placedCount++
		} else {
			unplacedCount++
		}

		studentData[i] = &StudentInfo{
			ID:              student.ID,
			FirstName:       student.FirstName,
			LastName:        student.LastName,
			Email:           student.Email,
			RollNumber:      student.RollNumber,
			Department:      student.Department,
			CGPA:            student.CGPA,
			PlacementStatus: placementStatus,
			Skills:          student.Skills,
		}
	}


	totalStudents := len(students)
	placementRate := 0.0
	if totalStudents > 0 {
		placementRate = float64(placedCount) / float64(totalStudents) * 100
	}

	return &StudentsResponse{
		Students: studentData,
		Statistics: &PlacementStats{
			TotalStudents:    totalStudents,
			PlacedStudents:   placedCount,
			UnplacedStudents: unplacedCount,
			PlacementRate:    placementRate,
		},
	}, nil
}
