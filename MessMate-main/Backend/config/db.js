  // const mysql = require("mysql2");

  // const db = mysql.createConnection({
  //   host: process.env.DB_HOST,
  //   user: process.env.DB_USER,
  //   password: process.env.DB_PASS,
  //   database: process.env.DB_NAME,
  // });

  // db.connect((err) => {
  //   if (err) {
  //     console.error("❌ Database connection failed:", err);
  //     return;
  //   }
  //   console.log("✅ Connected to MySQL Database");
  // });

  // module.exports = db.promise();



const mysql = require("mysql2");
require("dotenv").config();

const db = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,        // Aiven port
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: false       // Simple SSL setup for Aiven free plan
  },
  waitForConnections: true,
  connectionLimit: 10,
});

db.getConnection((err, connection) => {
  if (err) {
    console.error("❌ Database connection failed:", err.message);
  } else {
    console.log("✅ Connected to Aiven MySQL Database");
    connection.release();
  }
});

module.exports = db.promise();

