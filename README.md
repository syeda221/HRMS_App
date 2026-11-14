# QR Attendance & Human Resource Management System (HRMS)

A full-stack, contactless staff attendance and workforce management system built with Flutter and Laravel. This solution provides real-time attendance tracking via dynamic QR verification, shift schedule enforcement, punctuality analytics, and automated payroll calculations.

---

## Table of Contents
1. Project Overview
2. Core Capabilities and Use Cases
3. Architecture and Technology Stack
4. Monorepo Directory Structure
5. System Prerequisites
6. Backend Setup (Laravel 12 & MySQL)
7. Frontend Setup (Flutter)
8. Default Demo Credentials
9. API Endpoints Reference
10. License

---

## 1. Project Overview
This project addresses manual attendance logging errors, buddy-punching, and administrative overhead in corporate environments. Staff members authenticate through mobile devices or web browsers, scan an office-specific QR code displayed at corporate entrances or front desks, and record verified check-ins and check-outs.

The system automatically enforces office shift timings, calculates grace periods (15-minute tolerance), tracks total logged working hours, and provides monthly punctuality reports.

---

## 2. Core Capabilities and Use Cases

### Staff Member Portal
- Secure Authentication: Sign in via corporate email or assigned Employee Code (e.g., EMP-1042).
- Dynamic Dashboard: Real-time status cards showing today's attendance badge, check-in time, check-out time, total daily hours, and month-to-date metrics.
- Working Schedule & Policy Display: In-app visibility into shift hours (09:00 AM to 06:00 PM), late threshold (09:15 AM), and required daily hours (8.0 hrs/day).
- QR Verification: Integrated camera scanner for physical devices and simulated test scanner for desktop and emulator environments.
- Monthly Attendance Calendar: Interactive visual calendar with status-based color indicators (Present, Late, Absent, Holiday).
- Comprehensive Reports: Visual attendance score gauge, punctuality ratings, and monthly breakdown tables.
- Employee Profile: Department, designation, joining date, and self-service password management.

### Administration Panel
- Centralized Dashboard: Live headcounts for total staff, on-duty personnel, late arrivals, and absent members.
- Staff Directory: Employee roster with search filters, department categorizations, and account lifecycle controls.
- Shift & Timings Management: Custom shift creation with configurable start/end times, grace periods, and required daily hours.
- Master Attendance Register: Comprehensive log filterable by date, department, and status, with administrative manual correction capabilities.
- Payroll & Salary Processing: Base salary structures, automated deductions based on late arrivals or unexcused absences, and net pay computation.
- Office QR Poster Management: Generation, rotation, and printing of encrypted office lobby QR codes.

---

## 3. Architecture and Technology Stack

### Client Layer (Frontend)
- Framework: Flutter 3.x (Dart)
- State Management: Provider
- Networking: Dio HTTP client with custom authorization interceptors
- Local Storage: SharedPreferences
- Design System: Google Labs Stitch "Verdant Precision" theme (Forest Green #063B2B, Electric Lime #B8E83D, Slate White surfaces)
- Platform Targets: Android, iOS, Web (Chrome), Windows Desktop

### Application Layer (Backend)
- Framework: Laravel 12 (PHP 8.2+)
- Authentication: Laravel Sanctum (Bearer Token)
- Architecture: RESTful JSON APIs with Model-View-Controller (MVC) separation
- Security: Cross-Origin Resource Sharing (CORS) middleware, hashed credentials (Bcrypt), and QR secret verification

### Database Layer
- Engine: MySQL 8.x (InnoDB)
- Schema Management: Laravel database migrations with foreign key constraints
- Data Seeding: Automated generation of realistic 25-day staff attendance histories

---

## 4. Monorepo Directory Structure

```text
hrms_fullstack/
|
|-- backend/                       # Laravel 12 REST API Project
|   |-- app/
|   |   |-- Http/Controllers/Api/  # Auth, Attendance, Profile, and Admin controllers
|   |   |-- Models/                # User, Department, Designation, Attendance, Shift, Salary
|   |-- bootstrap/
|   |   |-- app.php                # Application routing and middleware configuration
|   |-- config/
|   |   |-- cors.php               # CORS policy for Flutter client communication
|   |   |-- sanctum.php            # API token configurations
|   |-- database/
|   |   |-- migrations/            # Database schema definitions
|   |   |-- seeders/               # 25-day attendance and demo staff seeders
|   |-- routes/
|   |   |-- api.php                # Public and Sanctum-protected endpoints
|   |-- .env.example               # Backend environment template
|   |-- composer.json              # PHP dependencies
|
|-- frontend/                      # Flutter Cross-Platform Application
|   |-- lib/
|   |   |-- core/
|   |   |   |-- constants/         # AppColors, ApiEndpoints, assets
|   |   |   |-- network/           # ApiClient and Dio configuration
|   |   |   |-- theme/             # Typography and component styling
|   |   |   |-- utils/             # SharedPreferences storage wrapper
|   |   |-- features/
|   |   |   |-- attendance/        # Calendar and history views and models
|   |   |   |-- auth/              # Login screen, user model, and AuthProvider
|   |   |   |-- dashboard/         # Staff dashboard, shift policy cards, metrics
|   |   |   |-- navigation/        # Floating bottom navigation shell
|   |   |   |-- profile/           # Staff profile and password update views
|   |   |   |-- reports/           # Attendance analytics and monthly breakdown
|   |   |   |-- scanner/           # QR camera scanner and mock test scanner
|   |   |-- shared/
|   |   |   |-- widgets/           # MetricCard, CustomButton, StatusBadge
|   |   |-- main.dart              # MultiProvider initialization and entry point
|   |-- pubspec.yaml               # Flutter dependencies
|
|-- README.md                      # Primary project documentation
```

---

## 5. System Prerequisites
Ensure the following tools are installed on your workstation:
- PHP 8.2 or higher
- Composer 2.x
- MySQL Server 8.x or MariaDB (via XAMPP or standalone service)
- Flutter SDK 3.13+
- Git CLI
- Google Chrome (for web testing) or an Android device (for physical testing)

---

## 6. Backend Setup (Laravel 12 & MySQL)

### Step 1: Open the Backend Directory
```bash
cd backend
```

### Step 2: Install PHP Dependencies
```bash
composer install --no-dev
```

### Step 3: Configure Environment Variables
Create a `.env` file from the example:
```bash
copy .env.example .env
php artisan key:generate
```

Verify your database credentials inside `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=hrms_attendance
DB_USERNAME=root
DB_PASSWORD=
```

### Step 4: Run Migrations and Seeders
Create the database and seed the 25-day historical records:
```bash
php artisan migrate:fresh --seed
```

### Step 5: Start the API Server
Bind the server to all network interfaces so physical devices on the local Wi-Fi can connect:
```bash
php artisan serve --host=0.0.0.0 --port=8000
```
The API server will listen on `http://127.0.0.1:8000`.

---

## 7. Frontend Setup (Flutter)

### Step 1: Open the Frontend Directory
In a separate terminal window:
```bash
cd frontend
```

### Step 2: Install Flutter Packages
```bash
flutter pub get
```

### Step 3: Launch the Application

#### Running on Web (Google Chrome):
```bash
flutter run -d chrome
```
*Tip: Press F12 in Chrome and select a mobile viewport (such as iPhone 14 Pro or Pixel 7) for the authentic mobile interface.*

#### Running on a Physical Android Device:
1. Connect your smartphone via USB with USB Debugging enabled in Developer Options.
2. Verify detection:
   ```bash
   flutter devices
   ```
3. Execute:
   ```bash
   flutter run
   ```
4. In the app's Login screen, click the Settings icon and specify your computer's local Wi-Fi IP (e.g., `http://192.168.1.100:8000/api`).

---

## 8. Default Demo Credentials

### Staff Member Account
- Email: `staff@company.com`
- Employee Code: `EMP-1042`
- Password: `password123`
- Department: Engineering
- Designation: Senior Flutter Engineer

### Administrator Account
- Email: `admin@company.com`
- Password: `admin123`

### Office QR Secret
- Payload Token: `STITCH-OFFICE-HQ-2026`

---

## 9. API Endpoints Reference

### Authentication
- `POST /api/staff/login` - Authenticate staff credentials and retrieve Sanctum bearer token.
- `POST /api/staff/logout` - Revoke current user authentication token.

### Staff Attendance
- `GET /api/staff/dashboard` - Retrieve today's status, monthly totals, and shift timing rules.
- `POST /api/staff/attendance/scan` - Process office QR payload for check-in or check-out.
- `GET /api/staff/attendance/calendar` - Fetch monthly attendance status matrix.
- `GET /api/staff/attendance/history` - Retrieve chronological attendance logs with pagination.
- `GET /api/staff/attendance/report` - Calculate monthly attendance rate and punctuality breakdown.

### Staff Profile
- `GET /api/staff/profile` - Retrieve employee profile and shift details.
- `PUT /api/staff/change-password` - Update staff account password.

---

## 10. License
This software is developed for commercial enterprise attendance management. All rights reserved.
