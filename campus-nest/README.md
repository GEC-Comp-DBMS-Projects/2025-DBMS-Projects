# Campus Placement Management System

A comprehensive full-stack placement management system designed for colleges to streamline the recruitment process. The system facilitates communication between students, TPO (Training and Placement Officers), administrators, and recruiters.

## 🏗️ Architecture Overview

### Backend (Deployed on Render)
- **Go 1.23** + Gin Framework v1.10.1: RESTful API server
- **MongoDB v1.17**: Database for users, jobs, applications, companies
- **JWT Authentication**: Role-based access control (jwt/v5)
- **Deployment**: https://campusnest-backend-lkue.onrender.com

### Frontend
1. **Flutter Mobile App** (`/frontend`) - Mobile interface for students and TPO
2. **Next.js Web App** (`/web`) - Admin and recruiter dashboard
3. **ML Service** (`/ML`) - Resume parsing and analysis (Python/Flask)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.8.1+ / Dart SDK 3.8.1+)
- Node.js (20+) & npm
- Git

### 1. Clone Repository
```bash
git clone https://github.com/D-Justin-Dsouza/DBMS_Project.git
cd DBMS_Project
```

### 2. Run Flutter Mobile App

```bash
cd frontend
flutter pub get
flutter run
```

**For Android Emulator:**
```bash
flutter emulators --launch <emulator_id>
flutter run
```

**For iOS Simulator (macOS only):**
```bash
open -a Simulator
flutter run
```

**For Chrome (Web):**
```bash
flutter run -d chrome
```

### 3. Run Next.js Web App

```bash
cd web
npm install
npm run dev
```

Access at: `http://localhost:3000`

---

## 👥 Sample User Credentials

### Admin Login
```
Email: teslin.j@admin.com
Password: password123
```
**Access:** Full system control, analytics, student management, company management

### TPO (Training & Placement Officer) Login
```
Email: frank.w@tpo.com
Password: password123
```
**Access:** Department-wise student management, job drive creation, placement analytics

### Student Login
```
Email:bob.w@student.com
Password: password123
```
**Access:** Job applications, resume upload, notifications, application tracking

### Recruiter Login
```
Email: karen.h@innovateinc.com
Password: recruiter123
```
**Access:** View candidates, shortlist students, manage applications, download resumes

---

## 📱 Features by Role

### 🎓 Student Features
- View available job drives
- Apply for jobs with resume
- Track application status
- Receive notifications
- Update skills and profile
- View placement statistics

### 👨‍💼 TPO Features
- Create and manage job drives
- View department-wise placement stats
- Send notifications to students
- Search and filter students
- Generate placement reports
- Manage drive applications

### 🏢 Recruiter Features
- View eligible candidates
- Download resumes in bulk
- Update application status
- Manage company job drives
- View candidate details
- Shortlist/reject candidates

### ⚙️ Admin Features
- Manage all students (add single/bulk via CSV)
- Manage companies and recruiters
- Create job drives
- View college-wide analytics
- Export comprehensive reports
- Send announcements to all

---

## 🗂️ Project Structure

```
DBMS_Project/
├── backend/                # Go/Gin REST API
│   ├── controllers/       # HTTP handlers
│   ├── models/           # Data models
│   ├── services/         # Business logic
│   ├── routes/           # API routes
│   ├── middleware/       # Auth middleware
│   └── config/           # Database config
│
├── frontend/             # Flutter mobile app
│   ├── lib/
│   │   ├── screens/      # UI screens
│   │   ├── student_screens/
│   │   ├── tpo_screens/
│   │   └── admin/
│   └── assets/           # Images & resources
│
├── web/                  # Next.js 15.2 web app
│   ├── app/              # Next.js app directory
│   ├── components/       # React 19 components
│   └── public/           # Static assets
│
├── ML/                   # Python ML service
│   ├── main.py          # Flask API
│   ├── models/          # ML models
│   └── requirements.txt
│
└── README.md            # This file
```

---

## 🔌 API Endpoints (Backend)

### Authentication
```
POST /auth/login - Login with email/password
```

### Student Routes
```
GET  /student/jobs - View available jobs
POST /student/jobs/:jobId/apply - Apply for job
GET  /student/applications - My applications
GET  /student/notifications - View notifications
```

### TPO Routes
```
POST /tpo/drives - Create job drive
GET  /tpo/drives - List all drives
GET  /tpo/analytics - Placement analytics
POST /tpo/notifications - Send notifications
GET  /tpo/students - Department students
```

### Admin Routes
```
POST /admin/student - Add single student
POST /admin/students/upload-csv - Bulk upload via CSV
GET  /admin/students - List all students
POST /admin/drives - Create job drive
GET  /admin/drives - List all drives
GET  /admin/analytics/placements - Placement stats
GET  /admin/analytics/companies - Company analytics
GET  /admin/companies - List all companies
POST /admin/company - Add company with recruiters
```

### Recruiter Routes
```
GET  /rec/candidates - View eligible candidates
GET  /rec/job-drives - Company job drives
PUT  /rec/job-drives/:jobId/students/status - Update application status
GET  /rec/resumes/download-all - Download all resumes
```

---

## 🛠️ Development (Local Backend Setup)

If you want to run the backend locally:

### Prerequisites
- Go 1.23+
- MongoDB (local or Atlas)

### Steps
```bash
cd backend

# Set environment variables
export MONGODB_URI="mongodb://localhost:27017/campusNestDB"
export JWT_SECRET="your-secret-key-here"

# Install dependencies
go mod download

# Run server
go run main.go
```

Server runs on: `http://localhost:8080`

---

## 📊 Database Collections

- **users** - Students, TPOs, Admins, Recruiters
- **jobs** - Job postings/drives
- **applications** - Student applications
- **companies** - Registered companies
- **resumes** - Uploaded resume files

---

## 🎨 Tech Stack

### Backend
- **Go 1.23** + Gin v1.10.1
- **MongoDB Driver v1.17**
- **JWT v5** (golang-jwt/jwt)
- **Bcrypt** (golang.org/x/crypto)
- **CORS** (gin-contrib/cors v1.7.6)

### Mobile Frontend (Flutter)
- **Flutter SDK 3.8.1** / Dart 3.8.1
- **http v0.13.5** (API calls)
- **shared_preferences v2.2.2** (Local storage)
- **google_fonts v4.0.4**
- **file_picker v8.0.6** (Resume upload)
- **fl_chart v0.68.0** (Charts)

### Web Frontend
- **Next.js 15.2.3** (React 19)
- **TypeScript 5**
- **Tailwind CSS 4**
- **Recharts v3.3.0** (Data visualization)
- **Lucide React v0.548** (Icons)
- **jsPDF v3.0.3** (PDF generation)

### ML Service
- **Python 3.13** + Flask 3.1.2
- **PyMuPDF v1.26.5** (PDF parsing)
- **Groq v0.32.0** (LLM API)
- **PyMongo v4.15.3**
- **Gunicorn v23.0.0** (WSGI server)

---

## 📝 Adding Students via CSV

### Sample CSV Format
```csv
firstName,lastName,email,rollNumber,department,gender,cgpa,skills,placedStatus
John,Doe,john.doe@college.edu,CS2021001,Computer Science,Male,8.5,Python;Java;React,Not Placed
Jane,Smith,jane.smith@college.edu,IT2021045,Information Technology,Female,9.2,JavaScript;SQL,Placed
```

### Upload Steps
1. Login as Admin
2. Navigate to Students → Upload CSV
3. Upload CSV to Cloudinary/file hosting
4. Use API: `POST /api/v1/admin/students/upload-csv`
   ```json
   {
     "csvUrl": "https://your-file-url.com/students.csv"
   }
   ```

**Default Password:** All uploaded students get password `password123`

---

## 🔐 Security Features

- JWT-based authentication
- Role-based access control (Student/TPO/Admin/Recruiter)
- Password hashing with Bcrypt
- Protected API routes with middleware
- Token expiration (72 hours)


