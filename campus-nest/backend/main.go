package main

import (
	"context"

	"log"
	"os"

	"backend/config"
	"backend/routes"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)
func main() {
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}
	client, err := config.ConnectDB()
	if err != nil {
		log.Fatal("Error connecting to database:", err)
	}
	defer func() {
		if err = client.Disconnect(context.TODO()); err != nil {
			log.Fatal("Error disconnecting from database:", err)
		}
	}()
	log.Println("Database connection established successfully")

	if os.Getenv("GIN_MODE") == "" {
		gin.SetMode(gin.ReleaseMode)
	}
	r := gin.Default()
	cors_config := cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: false,
	}
	r.Use(cors.New(cors_config))
	routes.SetupRoutes(r, client)
	port := "8080"
	if p := os.Getenv("PORT"); p != "" {
		port = p
	}
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Error starting server:", err)
	}
	log.Printf("Server started on port %s", port)
}
