const db = require("../config/db");

// Helper: Check if current time is before allowed mark time
const mealTimes = {
  breakfast: "08:00",
  lunch: "13:15",
  dinner: "20:00",
};

const canMarkMeal = (meal) => {
  const now = new Date();
  const [hours, minutes] = mealTimes[meal].split(":");
  const deadline = new Date();
  deadline.setHours(parseInt(hours), parseInt(minutes), 0, 0);
  return now <= deadline;
};

function getLocalDateString(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`; // ✅ local YYYY-MM-DD
}


// ✅ Get today's attendance
exports.getTodayAttendance = async (req, res) => {
  const user_id = req.user.id;
 const today = getLocalDateString(); 

  try {
    const [rows] = await db.query(
      "SELECT breakfast, lunch, dinner FROM attendance WHERE user_id=? AND date=?",
      [user_id, today]
    );

    if (rows.length === 0) {
      return res.json({ breakfast: 0, lunch: 0, dinner: 0 });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// ✅ Mark attendance
exports.markAttendance = async (req, res) => {
  const user_id = req.user.id;
  const { meal, amount } = req.body;  // ✅ frontend sends amount
  console.log("➡️ Received from frontend:", { meal, amount });
  const today = getLocalDateString();

  if (!["breakfast", "lunch", "dinner"].includes(meal)) {
    return res.status(400).json({ error: "Invalid meal" });
  }

  if (!canMarkMeal(meal)) {
    return res.status(403).json({ error: `Attendance for ${meal} is closed` });
  }

  try {
    // ✅ Check existing attendance record
    const [rows] = await db.query(
      "SELECT * FROM attendance WHERE user_id=? AND date=?",
      [user_id, today]
    );

    if (rows.length === 0) {
      await db.query(
        `INSERT INTO attendance (user_id, date, ${meal}) VALUES (?, ?, 1)`,
        [user_id, today]
      );
    } else {
      await db.query(
        `UPDATE attendance SET ${meal}=1 WHERE user_id=? AND date=?`,
        [user_id, today]
      );
    }
    
    console.log("💰 Adding expense:", { user_id, meal, amount });

    // ✅ INSERT into expense table
    if (amount && amount > 0) {
      await db.query(
        `INSERT INTO expenses (user_id, item_name, price, category) VALUES (?, ?, ?, 'Regular Meals')`,
        [user_id, `${meal.charAt(0).toUpperCase() + meal.slice(1)} Meal`, amount]
      );
      console.log("✅ Expense added successfully!");
    }
    

    res.json({ message: `${meal} attendance marked successfully`, expenseAdded: true });
  } catch (err) {
    console.error("Error marking attendance:", err);
    res.status(500).json({ error: "Server error" });
  }
};


// ✅ Weekly attendance (0-3 scale, aligned Monday → Sunday)
exports.getWeeklyAttendance = async (req, res) => {
  const user_id = req.user.id;
  const today = new Date();

  // Find Monday of this week
  const dayOfWeek = today.getDay(); // Sunday=0, Monday=1, ..., Saturday=6
  const monday = new Date(today);
  monday.setDate(today.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));

  const startDate = monday.toISOString().split("T")[0];

  // Sunday of this week
  const sunday = new Date(monday);
  sunday.setDate(monday.getDate() + 6);
  const endDate = sunday.toISOString().split("T")[0];

  try {
    const [rows] = await db.query(
      "SELECT breakfast, lunch, dinner, date FROM attendance WHERE user_id=? AND date BETWEEN ? AND ? ORDER BY date ASC",
      [user_id, startDate, endDate]
    );

    // Build Monday → Sunday data
    const weeklyData = [];
    for (let d = new Date(monday); d <= sunday; d.setDate(d.getDate() + 1)) {
          const dateStr = getLocalDateString(d);
          const record = rows.find((r) => getLocalDateString(r.date) === dateStr);

      if (record) {
        weeklyData.push(record.breakfast + record.lunch + record.dinner);
      } else {
        weeklyData.push(0);
      }
    }

    res.json({ weeklyData }); // Always 7 elements: Monday → Sunday
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};


// Get today's meal with items
exports.getTodayMeal = async (req, res) => {
  try {
    const dayOfWeek = new Date()
      .toLocaleString("en-US", { weekday: "long" })
      .toLowerCase();

    const [rows] = await db.query(
      `
      SELECT 
        m.meal_type, 
        f.name, 
        f.price, 
        f.image_url   -- ✅ add this line
      FROM weekly_menu wm
      JOIN meals m ON wm.meal_id = m.meal_id
      JOIN menu_items mi ON mi.menu_id = wm.menu_id
      JOIN food_items f ON f.food_id = mi.food_id
      WHERE wm.day_of_week = ?
      `,
      [dayOfWeek]
    );

    const mealItems = { breakfast: [], lunch: [], dinner: [] };

    rows.forEach((row) => {
      mealItems[row.meal_type].push({
        name: row.name,
        price: row.price,
        image_url: row.image_url, // ✅ include it in JSON
      });
    });

    res.json({ mealItems });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch today's meals" });
  }
};


