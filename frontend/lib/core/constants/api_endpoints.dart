import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Automatically choose localhost according to platform
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  static String baseUrl = defaultBaseUrl;

  // Staff Authentication
  static String get login => '$baseUrl/staff/login';
  static String get logout => '$baseUrl/staff/logout';

  // Staff Attendance
  static String get dashboard => '$baseUrl/staff/dashboard';
  static String get scan => '$baseUrl/staff/attendance/scan';
  static String get calendar => '$baseUrl/staff/attendance/calendar';
  static String get history => '$baseUrl/staff/attendance/history';
  static String get report => '$baseUrl/staff/attendance/report';

  // Staff Profile
  static String get profile => '$baseUrl/staff/profile';
  static String get changePassword => '$baseUrl/staff/change-password';

  // Admin Endpoints
  static String get adminDashboard => '$baseUrl/admin/dashboard';
  static String get adminStaff => '$baseUrl/admin/staff';
  static String adminStaffDetail(int id) => '$baseUrl/admin/staff/$id';
  static String get adminShifts => '$baseUrl/admin/shifts';
  static String adminShiftDetail(int id) => '$baseUrl/admin/shifts/$id';
  static String get adminAttendances => '$baseUrl/admin/attendances';
  static String get adminAttendanceOverride => '$baseUrl/admin/attendances/override';
  static String get adminPayrolls => '$baseUrl/admin/payrolls';
  static String get adminPayrollGenerate => '$baseUrl/admin/payrolls/generate';
  static String adminPayrollStatus(int id) => '$baseUrl/admin/payrolls/$id/status';
  static String get adminOfficeQr => '$baseUrl/admin/office-qr';
  static String get adminOfficeQrRegenerate => '$baseUrl/admin/office-qr/regenerate';
  static String get adminOfficeQrGeofence => '$baseUrl/admin/office-qr/geofence';
}
