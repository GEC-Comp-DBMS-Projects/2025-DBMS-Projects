const express = require("express");
const router = express.Router();
const { verifyToken } = require("../middleware/authMiddleware");
const {getTodayAttendance,markAttendance,getWeeklyAttendance,getTodayMeal} = require("../controllers/dashboardController");


// Get today's attendance
router.get("/attendance/today", verifyToken, getTodayAttendance);

// Mark attendance for a meal
router.post("/attendance/mark", verifyToken, markAttendance);

// Get weekly attendance for chart
router.get("/weekly-attendance", verifyToken, getWeeklyAttendance);

// Fetch today's meal items
router.get("/today-meal", verifyToken, getTodayMeal);



module.exports = router;
