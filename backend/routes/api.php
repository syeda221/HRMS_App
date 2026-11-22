<?php

use App\Http\Controllers\Api\StaffAuthController;
use App\Http\Controllers\Api\StaffAttendanceController;
use App\Http\Controllers\Api\StaffProfileController;
use App\Http\Controllers\Api\AdminDashboardController;
use App\Http\Controllers\Api\AdminStaffController;
use App\Http\Controllers\Api\AdminShiftController;
use App\Http\Controllers\Api\AdminAttendanceController;
use App\Http\Controllers\Api\AdminPayrollController;
use App\Http\Controllers\Api\AdminOfficeQrController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Staff Member Attendance APIs
|--------------------------------------------------------------------------
*/

// Public Authentication
Route::post('/staff/login', [StaffAuthController::class, 'login']);

// Protected Staff Routes
Route::middleware('auth:sanctum')->prefix('staff')->group(function () {
    Route::post('/logout', [StaffAuthController::class, 'logout']);

    // Dashboard
    Route::get('/dashboard', [StaffAttendanceController::class, 'dashboard']);

    // QR Scan (Check In / Check Out)
    Route::post('/attendance/scan', [StaffAttendanceController::class, 'scan']);

    // Calendar
    Route::get('/attendance/calendar', [StaffAttendanceController::class, 'calendar']);

    // History
    Route::get('/attendance/history', [StaffAttendanceController::class, 'history']);

    // Reports
    Route::get('/attendance/report', [StaffAttendanceController::class, 'report']);

    // Profile
    Route::get('/profile', [StaffProfileController::class, 'profile']);
    Route::put('/change-password', [StaffProfileController::class, 'changePassword']);
});

/*
|--------------------------------------------------------------------------
| Protected Admin Routes
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->prefix('admin')->group(function () {
    // 1. Admin Dashboard
    Route::get('/dashboard', [AdminDashboardController::class, 'dashboard']);

    // 2. Staff Management & Digital Badge
    Route::get('/staff', [AdminStaffController::class, 'index']);
    Route::post('/staff', [AdminStaffController::class, 'store']);
    Route::get('/staff/{id}', [AdminStaffController::class, 'show']);
    Route::put('/staff/{id}', [AdminStaffController::class, 'update']);

    // 3. Shifts & Timings Management
    Route::get('/shifts', [AdminShiftController::class, 'index']);
    Route::post('/shifts', [AdminShiftController::class, 'store']);
    Route::put('/shifts/{id}', [AdminShiftController::class, 'update']);
    Route::delete('/shifts/{id}', [AdminShiftController::class, 'destroy']);

    // 4. All Staff Attendance Monitor & Manual Override
    Route::get('/attendances', [AdminAttendanceController::class, 'index']);
    Route::post('/attendances/override', [AdminAttendanceController::class, 'override']);

    // 5. Payroll & Salaries
    Route::get('/payrolls', [AdminPayrollController::class, 'index']);
    Route::post('/payrolls/generate', [AdminPayrollController::class, 'generate']);
    Route::patch('/payrolls/{id}/status', [AdminPayrollController::class, 'updateStatus']);

    // 6. Office QR Code Management & Spatial Geofence
    Route::get('/office-qr', [AdminOfficeQrController::class, 'getOfficeQr']);
    Route::post('/office-qr/regenerate', [AdminOfficeQrController::class, 'regenerate']);
    Route::post('/office-qr/geofence', [AdminOfficeQrController::class, 'updateGeofence']);
});
