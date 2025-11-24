import 'dotenv/config';
import express from 'express';
import bodyParser from 'body-parser';
import mysql from 'mysql2';
import cors from 'cors';
import nodemailer from 'nodemailer';
import bcrypt from 'bcryptjs';
import authRoutes from './routes/authRoutes.js';
import dashboardRoutes from './routes/dashboardRoutes.js';
import menuRoutes from './routes/menuRoutes.js';
import feedbackRoutes from './routes/feedbackRoutes.js';
// import profileRoutes from './routes/profileRoutes.js';

const app = express();
app.use(express.json());
app.use(cors());
app.use(bodyParser.json());

const db = mysql.createPool({
  host: 'localhost',
  user: 'messmate',
  password: 'MessMate123!',
  database: 'hostel_db',
});

db.getConnection((err, connection) => {
  if (err) {
    console.error('MySQL connection failed:', err);
  } else {
    console.log('Connected to MySQL Database');
    connection.release();
  }
});
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'messmateofficiall@gmail.com',
    pass: 'nuqg igyl ekpp dlbq',
  },
});

const generatePassword = (length = 8) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  return Array.from({ length }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
};

app.use('/', authRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/', menuRoutes);
app.use('/feedback', feedbackRoutes);

app.post('/api/admin/invite-student', async (req, res) => {
  try {
    const { full_name, email } = req.body;
    if (!full_name || !email) {
      return res.status(400).json({ message: 'Name and Email required' });
    }

    const password = generatePassword();
    const hashedPassword = await bcrypt.hash(password, 10);

    await db.promise().execute(
      'INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)',
      [full_name, email, hashedPassword]
    );

    await db.promise().execute(
      'INSERT INTO allowed_students (email, is_registered) VALUES (?, 0)',
      [email]
    );

    await transporter.sendMail({
      from: 'MessMate Admin <messmateofficiall@gmail.com>',
      to: email,
      subject: 'Your MessMate Login Credentials',
      text: `Hi ${full_name},\n\nYou’ve been invited to MessMate.\n\nEmail: ${email}\nPassword: ${password}\n\nPlease change your password after logging in.\n\n- MessMate Admin`,
    });

    res.status(200).json({ message: 'Invitation sent successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to invite student', error });
  }
});

app.get('/announcements', (req, res) => {
  db.query('SELECT * FROM announcements ORDER BY created_at DESC', (err, result) => {
    if (err) return res.status(500).json({ message: 'DB Error', error: err });
    res.json(result);
  });
});

app.post('/announcements', (req, res) => {
  const { title, content } = req.body;
  db.query('INSERT INTO announcements (title, content) VALUES (?, ?)', [title, content], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ id: result.insertId, title, content });
  });
});

app.put('/announcements/:id', (req, res) => {
  const { id } = req.params;
  const { title, content } = req.body;
  db.query('UPDATE announcements SET title=?, content=? WHERE id=?', [title, content, id], (err) => {
    if (err) return res.status(500).json(err);
    res.json({ id, title, content });
  });
});

app.delete('/announcements/:id', (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM announcements WHERE id=?', [id], (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Deleted' });
  });
});

app.get("/api/admin/menu/:day", async (req, res) => {
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
    const [rows] = await db.promise().execute(query, [day]);
    const menu = { breakfast: [], lunch: [], dinner: [] };
    rows.forEach(row => {
      if (row.food_id) {
        menu[row.meal_type].push({
          food_id: row.food_id,
          name: row.name,
          price: row.price,
          menu_id: row.menu_id
        });
      }
    });

    const [foodItems] = await db.promise().execute("SELECT food_id, name, price FROM food_items");

    res.json({ menu, foodItems });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch menu" });
  }
});


app.post("/api/admin/menu/:menuId", async (req, res) => {
  const { menuId } = req.params;
  const { foodIds } = req.body;
  if (!menuId || !Array.isArray(foodIds)) {
    return res.status(400).json({ error: "Invalid menuId or foodIds" });
  }

  try {
    await db.promise().execute("DELETE FROM menu_items WHERE menu_id = ?", [menuId]);
    const validFoodIds = foodIds.filter(id => id != null && !isNaN(id));
    if (validFoodIds.length > 0) {
      const insertPromises = validFoodIds.map(id =>
        db.promise().execute(
          "INSERT INTO menu_items (menu_id, food_id) VALUES (?, ?)",
          [Number(menuId), Number(id)]
        )
      );
      await Promise.all(insertPromises);
    }
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update menu", details: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});