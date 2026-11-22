import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/admin_dashboard_model.dart';
import '../models/staff_directory_model.dart';
import '../models/shift_model.dart';
import '../models/attendance_monitor_model.dart';
import '../models/payroll_model.dart';
import '../models/office_qr_model.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // 1. Dashboard
  AdminDashboardModel? _dashboardData;
  AdminDashboardModel? get dashboardData => _dashboardData;

  // 2. Staff Directory
  StaffDirectoryResponse? _staffDirectory;
  StaffDirectoryResponse? get staffDirectory => _staffDirectory;

  // 3. Shifts
  List<ShiftModel> _shifts = [];
  List<ShiftModel> get shifts => _shifts;

  // 4. Attendance Monitor
  AttendanceMonitorResponse? _attendanceMonitor;
  AttendanceMonitorResponse? get attendanceMonitor => _attendanceMonitor;
  String _selectedMonitorDate = DateTime.now().toIso8601String().substring(0, 10);
  String _selectedMonitorStatus = 'all';
  String get selectedMonitorDate => _selectedMonitorDate;
  String get selectedMonitorStatus => _selectedMonitorStatus;

  // 5. Payroll
  PayrollResponse? _payrollData;
  PayrollResponse? get payrollData => _payrollData;
  String _selectedPayrollMonth = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
  String get selectedPayrollMonth => _selectedPayrollMonth;

  // 6. Office QR & Geofence
  OfficeQrModel? _officeQr;
  OfficeQrModel? get officeQr => _officeQr;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.adminDashboard);
      if (response.statusCode == 200 && response.data['success'] == true) {
        _dashboardData = AdminDashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load admin metrics.';
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Staff Directory
  // ---------------------------------------------------------------------------
  Future<void> loadStaff({String? search, int? departmentId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (departmentId != null) queryParams['department_id'] = departmentId;

      final response = await ApiClient.dio.get(
        ApiEndpoints.adminStaff,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        _staffDirectory = StaffDirectoryResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load staff directory.';
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStaff(Map<String, dynamic> staffData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.adminStaff,
        data: staffData,
      );

      if (response.statusCode == 201 && response.data['status'] == true) {
        await loadStaff();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to add staff.';
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Shifts
  // ---------------------------------------------------------------------------
  Future<void> loadShifts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.adminShifts);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final list = (response.data['data']['shifts'] as List? ?? []);
        _shifts = list.map((s) => ShiftModel.fromJson(s as Map<String, dynamic>)).toList();
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load shifts.';
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveShift(Map<String, dynamic> shiftData, {int? id}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = id == null
          ? await ApiClient.dio.post(ApiEndpoints.adminShifts, data: shiftData)
          : await ApiClient.dio.put(ApiEndpoints.adminShiftDetail(id), data: shiftData);

      if (response.data['status'] == true) {
        await loadShifts();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to save shift.';
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Attendance Monitor & Manual Override
  // ---------------------------------------------------------------------------
  Future<void> loadAttendanceMonitor({String? date, String? status}) async {
    if (date != null) _selectedMonitorDate = date;
    if (status != null) _selectedMonitorStatus = status;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.adminAttendances,
        queryParameters: {
          'date': _selectedMonitorDate,
          'status': _selectedMonitorStatus,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        _attendanceMonitor = AttendanceMonitorResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load attendance monitor.';
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> overrideAttendance(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.adminAttendanceOverride,
        data: data,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        await loadAttendanceMonitor(date: _selectedMonitorDate, status: _selectedMonitorStatus);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to correct attendance.';
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Payroll & Salaries
  // ---------------------------------------------------------------------------
  Future<void> loadPayroll({String? month}) async {
    if (month != null) _selectedPayrollMonth = month;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.adminPayrolls,
        queryParameters: {'month': _selectedPayrollMonth},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        _payrollData = PayrollResponse.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load payroll.';
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generatePayroll({String? month}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.adminPayrollGenerate,
        data: {'month': month ?? _selectedPayrollMonth},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        await loadPayroll(month: month ?? _selectedPayrollMonth);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to run payroll.';
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePayrollStatus(int id, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.patch(
        ApiEndpoints.adminPayrollStatus(id),
        data: {'status': status},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        await loadPayroll(month: _selectedPayrollMonth);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to update status.';
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Office QR & Geofence
  // ---------------------------------------------------------------------------
  Future<void> loadOfficeQr() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.adminOfficeQr);
      if (response.statusCode == 200 && response.data['status'] == true) {
        _officeQr = OfficeQrModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load Office QR.';
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> regenerateOfficeQr() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(ApiEndpoints.adminOfficeQrRegenerate);
      if (response.statusCode == 200 && response.data['status'] == true) {
        _officeQr = OfficeQrModel.fromJson(response.data['data'] as Map<String, dynamic>);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to regenerate QR.';
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGeofence(int radiusMeters) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.adminOfficeQrGeofence,
        data: {'radius_meters': radiusMeters},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        await loadOfficeQr();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to update geofence.';
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
