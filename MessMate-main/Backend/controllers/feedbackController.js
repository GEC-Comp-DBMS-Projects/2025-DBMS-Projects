const db = require("../config/db");

// ✅ Submit feedback
exports.submitFeedback = async (req, res) => {
  try {
    const userId = req.user.id; // From JWT
    const { category, stars, comment } = req.body;

    // Validation
    if (!category || !stars || !comment) {
      return res.status(400).json({ error: "All fields are required" });
    }

    // Insert feedback
    const [result] = await db.query(
      "INSERT INTO feedback (user_id, category, stars, comment) VALUES (?, ?, ?, ?)",
      [userId, category, stars, comment]
    );

    res.json({ 
      message: "✅ Feedback submitted successfully", 
      feedback_id: result.insertId 
    });
  } catch (err) {
    console.error("❌ Feedback submit error:", err);
    res.status(500).json({ error: "Server error" });
  }
};

// ✅ Get user's feedback
exports.getUserFeedback = async (req, res) => {
  try {
    const userId = req.user.id;

    const [rows] = await db.query(
      "SELECT feedback_id, category, stars, comment, status, created_at FROM feedback WHERE user_id = ? ORDER BY created_at DESC LIMIT 5",
      [userId]
    );

    res.json({ feedback: rows });
  } catch (err) {
    console.error("❌ Fetch feedback error:", err);
    res.status(500).json({ error: "Server error" });
  }
};


// controllers/feedbackController.js

// Get all pending feedback (for admin)
exports.getPendingFeedback = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT f.feedback_id, f.user_id, u.full_name as user, f.category, f.stars, f.comment, f.status, f.created_at FROM feedback f JOIN users u ON f.user_id = u.user_id WHERE f.status = 'Pending' ORDER BY f.created_at DESC"
    );
    res.json({ feedback: rows });
  } catch (err) {
    console.error("❌ Fetch pending feedback error:", err);
    res.status(500).json({ error: "Server error" });
  }
};



// ✅ Update feedback status (for admin)
exports.updateFeedbackStatus = async (req, res) => {
  try {
    const { feedback_id } = req.params;
    const { status } = req.body;

    if (!status || !["Pending", "Reviewed"].includes(status)) {
      return res.status(400).json({ error: "Invalid status" });
    }

    await db.query(
      "UPDATE feedback SET status = ? WHERE feedback_id = ?",
      [status, feedback_id]
    );

    res.json({ message: "Feedback status updated successfully" });
  } catch (err) {
    console.error("❌ Update feedback status error:", err);
    res.status(500).json({ error: "Server error" });
  }
};
