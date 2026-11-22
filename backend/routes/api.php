<?php

use App\Http\Controllers\Api\StaffAuthController;
use App\Http\Controllers\Api\StaffAttendanceController;
use App\Http\Controllers\Api\StaffProfileController;
use App\Http\Controllers\Api\AdminDashboardController;
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

// Protected Admin Routes
Route::middleware('auth:sanctum')->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'dashboard']);
});
