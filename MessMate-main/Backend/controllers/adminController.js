const db = require("../config/db");
const bcrypt = require("bcryptjs");
const { sendInviteEmail,sendMealAttendanceEmail } = require("../utils/mailer");

// 🔐 Generate random password
const generatePassword = (length = 8) => {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  return Array.from({ length }, () => chars[Math.floor(Math.random() * chars.length)]).join("");
};

// ✅ Invite student (send email + insert in DB)
exports.inviteStudent = async (req, res) => {
  try {
    const { full_name, email } = req.body;
    if (!full_name || !email)
      return res.status(400).json({ message: "Name and Email required" });

    const password = generatePassword();
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert new user
    await db.execute(
      "INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)",
      [full_name, email, hashedPassword]
    );

    // Add to allowed students
    await db.execute(
      "INSERT INTO allowed_students (email, is_registered) VALUES (?, 0)",
      [email]
    );

    // Send invitation email
    await sendInviteEmail(email, full_name, email, password);
    res.status(200).json({ message: "Invitation sent successfully" });
  } catch (error) {
    if (error.code === "ER_DUP_ENTRY") {
      console.warn(`⚠️ Student with email ${req.body.email} already exists`);
      return res.status(409).json({ message: `Student with email ${req.body.email} already exists` });
    }
    console.error("❌ Error inviting student:", error);
    res.status(500).json({ message: "Failed to invite student", error });
  }
};


// ✅ Get all announcements
exports.getAnnouncements = async (req, res) => {
  try {
    const [rows] = await db.execute("SELECT * FROM announcements ORDER BY created_at DESC");
    res.json(rows);
  } catch (err) {
    console.error("❌ Error fetching announcements:", err);
    res.status(500).json({ message: "DB Error", error: err });
  }
};

// ✅ Create new announcement
exports.createAnnouncement = async (req, res) => {
  try {
    const { title, content } = req.body;
    if (!title || !content)
      return res.status(400).json({ message: "Title and content are required" });

    const [result] = await db.execute(
      "INSERT INTO announcements (title, content) VALUES (?, ?)",
      [title, content]
    );

    const newAnnouncement = { id: result.insertId, title, content, created_at: new Date() };
    res.json(newAnnouncement);
  } catch (err) {
    console.error("❌ Error creating announcement:", err);
    res.status(500).json({ message: "Failed to create announcement", error: err });
  }
};

// ✅ Update an announcement
exports.updateAnnouncement = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content } = req.body;

    await db.execute(
      "UPDATE announcements SET title = ?, content = ? WHERE id = ?",
      [title, content, id]
    );

    res.json({ id, title, content });
  } catch (err) {
    console.error("❌ Error updating announcement:", err);
    res.status(500).json({ message: "Failed to update announcement", error: err });
  }
};

// ✅ Delete an announcement
exports.deleteAnnouncement = async (req, res) => {
  try {
    const { id } = req.params;
    await db.execute("DELETE FROM announcements WHERE id = ?", [id]);
    res.json({ message: "Announcement deleted successfully" });
  } catch (err) {
    console.error("❌ Error deleting announcement:", err);
    res.status(500).json({ message: "Failed to delete announcement", error: err });
  }
};

// ✅ Get menu by day
exports.getMenuByDay = async (req, res) => {
  const { day } = req.params;
  const query = `
    SELECT wm.menu_id, m.meal_type, fi.food_id, fi.name, fi.price
    FROM weekly_menu wm
    JOIN meals m ON wm.meal_id = m.meal_id
    LEFT JOIN menu_items mi ON mi.menu_id = wm.menu_id
    LEFT JOIN food_items fi ON fi.food_id = mi.food_id
    WHERE wm.day_of_week = ?
    ORDER BY m.meal_type, fi.name
  `;

  try {
    const [rows] = await db.execute(query, [day]);
    const menu = { breakfast: [], lunch: [], dinner: [] };

    rows.forEach(row => {
      if (row.food_id) {
        menu[row.meal_type].push({
          food_id: row.food_id,
          name: row.name,
          price: row.price,
          menu_id: row.menu_id,
        });
      }
    });

    const [foodItems] = await db.execute("SELECT food_id, name, price FROM food_items");
    res.json({ menu, foodItems });
  } catch (err) {
    console.error("❌ Error fetching menu:", err);
    res.status(500).json({ error: "Failed to fetch menu" });
  }
};

// ✅ Update menu items
exports.updateMenuItems = async (req, res) => {
  const { menuId } = req.params;
  const { foodIds } = req.body;

  if (!menuId || !Array.isArray(foodIds))
    return res.status(400).json({ error: "Invalid menuId or foodIds" });

  try {
    await db.execute("DELETE FROM menu_items WHERE menu_id = ?", [menuId]);
    const validFoodIds = foodIds.filter(id => id != null && !isNaN(id));

    if (validFoodIds.length > 0) {
      const insertPromises = validFoodIds.map(id =>
        db.execute("INSERT INTO menu_items (menu_id, food_id) VALUES (?, ?)", [menuId, id])
      );
      await Promise.all(insertPromises);
    }

    res.json({ success: true });
  } catch (err) {
    console.error("❌ Error updating menu items:", err);
    res.status(500).json({ error: "Failed to update menu", details: err.message });
  }
};



// ✅ Get all students present today for each meal
exports.getTodayPresentStudents = async (req, res) => {
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, "0");
  const day = String(today.getDate()).padStart(2, "0");
  const todayStr = `${year}-${month}-${day}`; // YYYY-MM-DD

  try {
    const [rows] = await db.execute(
      `SELECT u.full_name, u.email, a.breakfast, a.lunch, a.dinner
       FROM attendance a
       JOIN users u ON a.user_id = u.user_id
       WHERE a.date = ?`,
      [todayStr]
    );

    // Filter students per meal
    const breakfast = rows.filter(r => r.breakfast === 1);
    const lunch = rows.filter(r => r.lunch === 1);
    const dinner = rows.filter(r => r.dinner === 1);

    res.json({ breakfast, lunch, dinner });
  } catch (err) {
    console.error("❌ Error fetching today's attendance:", err);
    res.status(500).json({ error: "Failed to fetch today's attendance" });
  }
};

// ✅ Get email sent status for today
exports.getEmailSentStatus = async (req, res) => {
  const today = getLocalDateString();

  try {
    const [rows] = await db.execute(
      "SELECT breakfast_sent, lunch_sent, dinner_sent FROM attendance_email_status WHERE date = ?",
      [today]
    );

    const status = rows.length
      ? rows[0]
      : { breakfast_sent: 0, lunch_sent: 0, dinner_sent: 0 };

    res.json({
      breakfast: status.breakfast_sent === 1,
      lunch: status.lunch_sent === 1,
      dinner: status.dinner_sent === 1,
    });
  } catch (err) {
    console.error("❌ Error fetching email status:", err);
    res.status(500).json({ error: "Failed to fetch email status" });
  }
};



// Hardcoded meal deadlines
const mealTimes = {
  breakfast: "08:00",
  lunch: "13:15",
  dinner: "22:00",
};

// Hardcoded kitchen staff email  
const KITCHEN_EMAIL = "sunnycardoso750@gmail.com";

// Helper to format current date as YYYY-MM-DD
function getLocalDateString(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

// ✅ Send meal attendance email automatically
// ✅ Send meal attendance email automatically
async function sendMealEmail(meal) {
  const today = getLocalDateString();

  try {
    const [rows] = await db.execute(
      `SELECT u.full_name, u.email
       FROM attendance a
       JOIN users u ON a.user_id = u.user_id
       WHERE a.date = ? AND a.${meal} = 1`,
      [today]
    );

    const count = rows.length;

    if (count > 0) {
     // const studentNames = rows.map(s => s.full_name).join(", ");
      await sendMealAttendanceEmail(KITCHEN_EMAIL, meal, count);
      console.log(`✅ ${meal} attendance email sent to kitchen`);

      // ✅ Mark email as sent in DB
      await db.execute(
        `INSERT INTO attendance_email_status (date, ${meal}_sent)
         VALUES (?, 1)
         ON DUPLICATE KEY UPDATE ${meal}_sent = 1`,
        [today]
      );
    } else {
      console.log(`ℹ️ No students for ${meal} today`);
    }
  } catch (err) {
    console.error(`❌ Error sending ${meal} attendance email:`, err);
  }
}


// ✅ Schedule emails at meal deadlines
function scheduleMealEmails() {
  Object.entries(mealTimes).forEach(([meal, time]) => {
    const [hours, minutes] = time.split(":").map(Number);
    const now = new Date();
    const target = new Date();
    target.setHours(hours, minutes, 0, 0);

    let delay = target.getTime() - now.getTime();
    if (delay < 0) {
      // If time already passed today, skip
      console.log(`⏭️ ${meal} deadline already passed today`);
      return;
    }

    setTimeout(async function sendAndReschedule() {
      await sendMealEmail(meal);
      // Schedule next day
      setTimeout(sendAndReschedule, 24 * 60 * 60 * 1000);
    }, delay);

    console.log(`⏱️ ${meal} email scheduled at ${time}`);
  });
}

// Start scheduler when server starts
scheduleMealEmails();
