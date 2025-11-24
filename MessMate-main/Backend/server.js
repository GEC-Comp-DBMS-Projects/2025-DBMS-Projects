  require("dotenv").config();
  const express = require("express");
  const cors = require("cors");
  const authRoutes = require("./routes/authRoutes");
  const dashboardRoutes = require("./routes/dashboardRoutes");
  const expenseRoutes = require("./routes/expenseRoutes");
  const menuRoutes = require("./routes/menuRoutes");
  // const profileRoutes = require("./routes/profileRoutes");
  const feedbackRoutes = require("./routes/feedbackRoutes");
  const adminRoutes = require("./routes/adminRoutes");

  const app = express();
  app.use(express.json());
  app.use(cors());

  // ✅ Routes
  app.use("/", authRoutes);
  app.use("/dashboard", dashboardRoutes);
  app.use("/", menuRoutes);
  app.use("/feedback", feedbackRoutes);
  app.use("/",adminRoutes);
  app.use("/expense", expenseRoutes);

  // app.use("/", profileRoutes);
  // ✅ Start Server
  const PORT = process.env.PORT || 5000;
  app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
