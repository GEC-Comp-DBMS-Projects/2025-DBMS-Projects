import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import pool from './config/db.js';
import hardwareRoutes from './routes/hardwareRoutes.js';
import ramRoutes from "./routes/ramRoutes.js";
import motherboardRoutes from "./routes/motherboardRoutes.js";
import storageRoutes from "./routes/storageRoutes.js";
import recommendRoute from './routes/recommend.js';
import hardwareRoutes2 from "./routes/hardwareRoutes2.js";
import adminRoutes from "./routes/adminRoutes.js";
import aiRecommendRoute from "./routes/aiRecommend.js";
import addAdminRoutes from "./routes/addAdminRoutes.js";

import buildsRouter from "./routes/web/build.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/hardware', hardwareRoutes);
app.use('/api/recommend', recommendRoute);
app.use("/api/hardware/ram", ramRoutes);
app.use("/api/hardware/motherboard", motherboardRoutes);
app.use("/api/hardware/storage", storageRoutes);

app.use("/admin", adminRoutes);
app.use("/admin", hardwareRoutes2);
app.use("/add-admin", addAdminRoutes);

app.use("/api/ai-recommend", aiRecommendRoute);

app.use(express.json({ limit: '1mb' }));
app.use('/api/builds', buildsRouter);

const testDBConnection = async () => {
  try {
    const [rows] = await pool.query('SELECT NOW() AS now');
    console.log('✅ Database connected successfully at:', rows[0].now);
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1);
  }
};

const PORT = process.env.PORT || 5000;

testDBConnection().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
  });
});
