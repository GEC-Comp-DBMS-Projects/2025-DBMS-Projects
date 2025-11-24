    const express = require("express");
    const router = express.Router();
    const { signup, login, profile, verifyEmail, verifyOtp } = require("../controllers/authController");
    const { verifyToken } = require("../middleware/authMiddleware");
  
    // Routes
 
    router.post("/verifyEmail", verifyEmail);
    router.post("/verifyOtp", verifyOtp);
    router.post("/signup", signup);
    router.post("/login", login);
    router.get("/profile", verifyToken, profile);

    module.exports = router;
