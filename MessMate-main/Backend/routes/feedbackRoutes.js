const express = require("express");
const router = express.Router();
const { submitFeedback, getUserFeedback ,getPendingFeedback,updateFeedbackStatus} = require("../controllers/feedbackController");
const { verifyToken } = require("../middleware/authMiddleware");

// ✅ Routes
router.post("/submitFeedback", verifyToken, submitFeedback);
router.get("/getUserFeedback", verifyToken, getUserFeedback);
router.get("/getPendingFeedback",getPendingFeedback);
router.post("/updateStatus/:feedback_id", updateFeedbackStatus);

module.exports = router;
