const express = require('express');
const cors = require('cors');
const { Sequelize, DataTypes, Model } = require('sequelize');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const twilio = require('twilio');
const multer = require('multer');
const { spawn } = require('child_process');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

const sequelize = new Sequelize(
  process.env.DB_NAME || 'DBMS',
  process.env.DB_USER || 'root',
  process.env.DB_PASSWORD || '',
  {
    host: process.env.DB_HOST || 'localhost',
    dialect: 'mysql',
    port: process.env.DB_PORT || 3306,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    logging: process.env.NODE_ENV === 'development' ? console.log : false
  }
);

const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✓ Connected to MySQL database successfully.');
    return true;
  } catch (error) {
    console.error('✗ Unable to connect to MySQL database:', error.message);
    return false;
  }
};

class User extends Model {

  comparePassword(password) {
    return bcrypt.compareSync(password, this.password);
  }
}

User.init({
  username: {
    type: DataTypes.STRING,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false
  }
}, {
  sequelize,
  modelName: 'User',
  tableName: 'users',
  hooks: {
    beforeCreate: async (user) => {
      if (user.password) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    }
  }
});

class Form16Detail extends Model {}

Form16Detail.init({
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },

  date_uploaded: {
    type: DataTypes.DATEONLY,
    allowNull: false
  }
}, {
  sequelize,
  modelName: 'Form16Detail',
  tableName: 'form16_details'
});

const otpStore = new Map();

const emailTransporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  }
});

const twilioClient = process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN
  ? twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN)
  : null;

function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function sendEmailOTP(email, otp) {
  try {

    if (!process.env.EMAIL_USER || !process.env.EMAIL_PASSWORD) {
      console.log(`📧 EMAIL OTP for ${email}: ${otp}`);
      console.log('⚠️  Email not sent (credentials not configured). Check console for OTP.');
      return true;
    }

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'FinCore - Email Verification OTP',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #00d4d4;">FinCore Email Verification</h2>
          <p>Your verification code is:</p>
          <h1 style="background: #f0f0f0; padding: 20px; text-align: center; letter-spacing: 5px; color: #1a1f2e;">
            ${otp}
          </h1>
          <p>This code will expire in 10 minutes.</p>
          <p>If you didn't request this code, please ignore this email.</p>
        </div>
      `
    };

    await emailTransporter.sendMail(mailOptions);
    console.log(`✓ Email OTP sent to ${email}`);
    return true;
  } catch (error) {
    console.error('✗ Error sending email OTP:', error.message);

    console.log(`📧 EMAIL OTP for ${email}: ${otp}`);
    return true;
  }
}

async function sendPhoneOTP(phone, otp) {
  try {

    if (!twilioClient || !process.env.TWILIO_PHONE_NUMBER) {
      console.log(`📱 SMS OTP for ${phone}: ${otp}`);
      console.log('⚠️  SMS not sent (Twilio not configured). Check console for OTP.');
      return true;
    }

    await twilioClient.messages.create({
      body: `Your FinCore verification code is: ${otp}. Valid for 10 minutes.`,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: `+91${phone}`
    });
    console.log(`✓ SMS OTP sent to ${phone}`);
    return true;
  } catch (error) {
    console.error('✗ Error sending SMS OTP:', error.message);

    console.log(`📱 SMS OTP for ${phone}: ${otp}`);
    return true;
  }
}

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type']
}));
app.use(express.json());

app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'Backend server is working!',
    timestamp: new Date().toISOString()
  });
});

app.post('/api/auth/send-otp', async (req, res) => {
  try {
    const { email, phone } = req.body;

    if (!email || !phone) {
      return res.status(400).json({ error: 'Email and phone are required' });
    }

    const emailOTP = generateOTP();
    const phoneOTP = generateOTP();

    const otpData = {
      emailOTP,
      phoneOTP,
      expiresAt: Date.now() + 10 * 60 * 1000
    };
    
    otpStore.set(email, otpData);

    await Promise.all([
      sendEmailOTP(email, emailOTP),
      sendPhoneOTP(phone, phoneOTP)
    ]);

    console.log(`✓ OTPs sent to ${email} and ${phone}`);
    res.json({ message: 'OTP sent successfully' });
  } catch (error) {
    console.error('✗ Send OTP error:', error.message);
    res.status(500).json({ error: 'Error sending OTP' });
  }
});

app.post('/api/auth/verify-otp', async (req, res) => {
  try {
    const { email, phone, emailOTP, phoneOTP } = req.body;

    if (!email || !emailOTP || !phoneOTP) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const storedData = otpStore.get(email);

    if (!storedData) {
      return res.status(400).json({ error: 'OTP not found or expired. Please request a new one.' });
    }

    if (Date.now() > storedData.expiresAt) {
      otpStore.delete(email);
      return res.status(400).json({ error: 'OTP expired. Please request a new one.' });
    }

    if (storedData.emailOTP !== emailOTP) {
      return res.status(400).json({ error: 'Invalid email OTP' });
    }

    if (storedData.phoneOTP !== phoneOTP) {
      return res.status(400).json({ error: 'Invalid phone OTP' });
    }

    otpStore.delete(email);
    
    console.log(`✓ OTP verified for ${email}`);
    res.json({ message: 'OTP verified successfully' });
  } catch (error) {
    console.error('✗ Verify OTP error:', error.message);
    res.status(500).json({ error: 'Error verifying OTP' });
  }
});

app.post('/api/auth/signup', async (req, res) => {
  try {
    console.log('Received signup request:', { ...req.body, password: '***' });
    const { username, email, phone, password } = req.body;

    if (!username || !email || !phone || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    const existingUser = await User.findOne({ where: { email } });
    
    if (existingUser) {
      return res.status(400).json({ error: 'This email is already registered' });
    }

    const existingPhone = await User.findOne({ where: { phone } });
    
    if (existingPhone) {
      return res.status(400).json({ error: 'This phone number is already registered' });
    }

    const user = await User.create({ username, email, phone, password });
    console.log('✓ User created successfully:', user.email);

    res.status(201).json({ 
      message: 'User registered successfully',
      user: { 
        username: user.username, 
        email: user.email,
        phone: user.phone
      }
    });
  } catch (error) {
    console.error('✗ Signup error:', error.message);
    res.status(500).json({ error: 'Error registering user' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    console.log('Received login request:', { email: req.body.email, password: '***' });
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findOne({ where: { email } });
    
    if (!user) {
      return res.status(401).json({ error: 'No account found with this email' });
    }

    const isMatch = user.comparePassword(password);
    
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    console.log('✓ Login successful for:', user.email);

    res.json({ 
      message: 'Login successful', 
      user: { 
        username: user.username, 
        email: user.email,
        phone: user.phone
      }
    });
  } catch (error) {
    console.error('✗ Login error:', error.message);
    res.status(500).json({ error: 'Error logging in' });
  }
});

app.post('/api/auth/check-email', async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const existingUser = await User.findOne({ where: { email } });
    res.json({ isAvailable: !existingUser });
  } catch (error) {
    console.error('✗ Check-email error:', error.message);
    res.status(500).json({ error: 'Error checking email' });
  }
});

const upload = multer({ dest: 'uploads/' });

app.post('/api/upload-form16', upload.single('form16'), async (req, res) => {
  try {
    const user_id = req.body.user_id;
    const pdfPath = req.file.path;

    const python = spawn('python', ['backend/extract_form16.py', pdfPath]);
    let dataString = '';
    python.stdout.on('data', (data) => { dataString += data.toString(); });
    python.stderr.on('data', (data) => { console.error('Python error:', data.toString()); });
    python.on('close', async (code) => {
      try {
        const details = JSON.parse(dataString);
        details.user_id = user_id;
        details.date_uploaded = new Date().toISOString().slice(0, 10);
        await Form16Detail.create(details);
        res.json({ message: 'Form16 details extracted and saved', details });
      } catch (err) {
        console.error('Extract/DB error:', err);
        res.status(500).json({ error: 'Failed to extract or save details' });
      }
    });
  } catch (error) {
    console.error('Upload error:', error.message);
    res.status(500).json({ error: 'Error uploading Form16' });
  }
});

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

const startServer = async () => {
  try {

    const dbConnected = await testConnection();
    
    if (!dbConnected) {
      console.log('⚠ Warning: Database connection failed. Server starting anyway...');
    }

    await sequelize.sync({ 
      alter: process.env.NODE_ENV === 'development',
      force: false
    });
    console.log('✓ Database synchronized successfully');

    const os = require('os');
    const networkInterfaces = os.networkInterfaces();
    let localIP = 'localhost';
    
    Object.keys(networkInterfaces).forEach((interfaceName) => {
      networkInterfaces[interfaceName].forEach((iface) => {
        if (iface.family === 'IPv4' && !iface.internal) {
          localIP = iface.address;
        }
      });
    });

    app.listen(port, '0.0.0.0', () => {
      console.log('\n' + '='.repeat(50));
      console.log('🚀 FINCORE BACKEND SERVER STARTED');
      console.log('='.repeat(50));
      console.log(`📍 Local:    http:
      console.log(`📍 Network:  http:
      console.log(`📍 API Base: http:
      console.log('='.repeat(50));
      console.log('Available endpoints:');
      console.log(`  GET  /api/test`);
      console.log(`  POST /api/auth/send-otp`);
      console.log(`  POST /api/auth/verify-otp`);
      console.log(`  POST /api/auth/signup`);
      console.log(`  POST /api/auth/login`);
      console.log(`  POST /api/auth/check-email`);
      console.log(`  POST /api/upload-form16`);
      console.log('='.repeat(50));
      console.log('Press Ctrl+C to stop the server\n');
    });
  } catch (error) {
    console.error('✗ Failed to start server:', error.message);
    process.exit(1);
  }
};

startServer();

process.on('SIGINT', async () => {
  console.log('\n\nShutting down gracefully...');
  await sequelize.close();
  console.log('Database connection closed.');
  process.exit(0);
});