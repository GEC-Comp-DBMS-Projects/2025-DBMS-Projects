  const bcrypt = require("bcryptjs");
  const jwt = require("jsonwebtoken");
  const db = require("../config/db");
  const {sendOtpEmail} = require("../utils/mailer");

  const SECRET_KEY = process.env.SECRET_KEY || "your_secret_key";

  // Generate 4-digit OTP
  const generateOtp = () => Math.floor(1000 + Math.random() * 9000).toString();

  // In-memory OTP store { email: { otp, expiresAt } }
  const otpStore = new Map();

  /**
   * 1️⃣ Request Email Verification
   * - Checks if email exists in allowed_students
   * - Generates OTP and stores in memory with expiry
   * - Sends OTP via email
   */
  exports.verifyEmail = async (req, res) => {
    const { email } = req.body;

    if (!email) return res.status(400).json({ error: "Email is required" });

    try {
      // Check if email is allowed
      const [allowed] = await db.query(
        "SELECT * FROM allowed_students WHERE email=?",
        [email]
      );

      if (allowed.length === 0) {
        return res
          .status(403)
          .json({ error: "Email not allowed. Contact admin." });
      }

      const otp = generateOtp();
      const expiresAt = Date.now() + 5 * 60 * 1000; // 5 mins

      // Save OTP in memory
      otpStore.set(email, { otp, expiresAt });

      // Send OTP via email
      await sendOtpEmail(email, otp);

      res.json({ message: "✅ OTP sent to your email" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Server error" });
    }
  };

  /**
   * 2️⃣ Verify OTP
   * - Checks if OTP is valid & not expired
   * - Marks student as registered
   */
  exports.verifyOtp = async (req, res) => {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ error: "Email and OTP are required" });
    }

    try {
      const record = otpStore.get(email);

      if (!record || record.otp !== otp) {
        return res.status(400).json({ error: "Invalid OTP" });
      }

      if (Date.now() > record.expiresAt) {
        otpStore.delete(email); // cleanup expired OTP
        return res.status(400).json({ error: "OTP expired" });
      }

      // OTP verified, delete from store
      otpStore.delete(email);

      // Mark email as registered in allowed_students
      await db.query("UPDATE allowed_students SET is_registered=true WHERE email=?", [
        email,
      ]);

      res.json({ message: "✅ Email verified successfully!" });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Verification failed" });
    }
  };

  /**
   * 3️⃣ Signup
   * - Only works if email is verified in allowed_students
   * - Hashes password and inserts user
   */
  exports.signup = async (req, res) => {
    const { full_name, email, password } = req.body;

    if (!full_name || !email || !password) {
      return res.status(400).json({ error: "All fields are required" });
    }

    try {
      // Check if email is verified in allowed_students
      const [allowed] = await db.query(
        "SELECT * FROM allowed_students WHERE email=? AND is_registered=true",
        [email]
      );

      if (allowed.length === 0) {
        return res.status(403).json({ error: "Email not verified" });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Save user
      await db.query(
        "INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)",
        [full_name, email, hashedPassword]
      );

      res.json({ message: "✅ User registered successfully!" });
    } catch (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res.status(400).json({ error: "Email already exists" });
      }
      console.error(err);
      res.status(500).json({ error: "Database error" });
    }
  };


  // ✅ Login
  // ✅ Promise-based mysql2 usage and correct PK field
  exports.login = async (req, res) => {
    console.log("Login request body:", req.body);
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    try {
      // ✅ Use promise style
      const [results] = await db.query("SELECT * FROM users WHERE email = ?", [email]);

      if (results.length === 0) {
        console.log("User not found");
        return res.status(400).json({ error: "User not found" });
      }

      const user = results[0];
      console.log("User found:", user.full_name);

      const isMatch = await bcrypt.compare(password, user.password);
      console.log("Password match:", isMatch);

      if (!isMatch) {
        return res.status(400).json({ error: "Invalid password" });
      }

      // ✅ Use correct column name
      const token = jwt.sign({ id: user.user_id }, SECRET_KEY, { expiresIn: "1h" });

      return res.json({
        message: "✅ Login successful!",
        token,
        user: {
            id: user.user_id,
            full_name: user.full_name,
          }
,
      });
    } catch (err) {
      console.error("Login error:", err);
      return res.status(500).json({ error: "Internal server error" });
    }
  };


exports.profile = async (req, res) => {
  try {
    const [results] = await db.query(
      "SELECT user_id, full_name, email, created_at FROM users WHERE user_id = ?",
      [req.user.id]
    );

    if (results.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const user = results[0];

    res.json({
      user: {
        id: user.user_id,              // Student ID
        full_name: user.full_name,
        email: user.email,
        join_date: user.created_at,    // Member since
      },
    });
  } catch (err) {
    console.error("❌ Profile fetch error:", err);
    res.status(500).json({ error: "Server error" });
  }
};
