const express = require("express");
const router = express.Router();
const adminController = require("../controllers/adminController");

// 📩 Invite students
router.post("/api/admin/invite-student", adminController.inviteStudent);

// 📢 Announcements
router.get("/announcements", adminController.getAnnouncements);
router.post("/announcements", adminController.createAnnouncement);
router.put("/announcements/:id", adminController.updateAnnouncement);
router.delete("/announcements/:id", adminController.deleteAnnouncement);

// 🍽️ Menu Management
router.get("/api/admin/menu/:day", adminController.getMenuByDay);
router.post("/api/admin/menu/:menuId", adminController.updateMenuItems);
// 📋 Fetch today's present students
router.get("/api/admin/attendance/today-students", adminController.getTodayPresentStudents);
// 📧 Fetch today's email sent status
router.get("/api/admin/attendance/email-status", adminController.getEmailSentStatus);
    

module.exports = router;
