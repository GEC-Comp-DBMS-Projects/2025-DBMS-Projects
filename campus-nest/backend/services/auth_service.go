package services

import (
	"context"
	"errors"
	"os"
	"time"

	"backend/models"

	"github.com/golang-jwt/jwt/v5"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
)

type AuthServiceImpl struct {
	userCollection *mongo.Collection
}

func NewAuthService(db *mongo.Database) AuthService {
	return &AuthServiceImpl{
		userCollection: db.Collection("users"),
	}
}

func (as *AuthServiceImpl) Login(email, password string) (*LoginResponse, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	var user models.User
	err := as.userCollection.FindOne(ctx, bson.M{"email": email}).Decode(&user)
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":  user.ID.Hex(),
		"role": user.Role,
		"exp":  time.Now().Add(time.Hour * 72).Unix(),
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if err != nil {
		return nil, errors.New("could not generate token")
	}

	return &LoginResponse{
		Token: tokenString,
		User: &UserInfo{
			ID:        user.ID,
			FirstName: user.FirstName,
			Email:     user.Email,
			Role:      user.Role,
		},
	}, nil
}

func (as *AuthServiceImpl) ValidateToken(token string) (*TokenClaims, error) {


	return nil, errors.New("not implemented")
}
