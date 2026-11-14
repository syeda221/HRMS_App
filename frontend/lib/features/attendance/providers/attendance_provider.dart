import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../dashboard/models/dashboard_data.dart';
import '../models/attendance_model.dart';
import '../../reports/models/report_model.dart';

class AttendanceProvider extends ChangeNotifier {
  DashboardData? _dashboard;
  bool _isLoadingDashboard = false;

  List<AttendanceDay> _calendarDays = [];
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  bool _isLoadingCalendar = false;

  List<HistoryItem> _historyItems = [];
  bool _isLoadingHistory = false;
  int _historyPage = 1;
  int _historyLastPage = 1;

  MonthlyReport? _monthlyReport;
  bool _isLoadingReport = false;

  String? _errorMessage;

  DashboardData? get dashboard => _dashboard;
  bool get isLoadingDashboard => _isLoadingDashboard;

  List<AttendanceDay> get calendarDays => _calendarDays;
  String get selectedMonth => _selectedMonth;
  bool get isLoadingCalendar => _isLoadingCalendar;

  List<HistoryItem> get historyItems => _historyItems;
  bool get isLoadingHistory => _isLoadingHistory;

  MonthlyReport? get monthlyReport => _monthlyReport;
  bool get isLoadingReport => _isLoadingReport;

  String? get errorMessage => _errorMessage;

  // 1. Fetch Dashboard
  Future<void> fetchDashboard() async {
    _isLoadingDashboard = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.dashboard);
      if (response.data['success'] == true) {
        _dashboard = DashboardData.fromJson(response.data['data']);
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  // 2. Submit QR Scan
  Future<Map<String, dynamic>> scanQr(String qrToken, [String? note]) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.scan,
        data: {
          'qr_token': qrToken.trim(),
          if (note != null) 'note': note,
        },
      );

      // Refresh dashboard on success
      if (response.data['success'] == true) {
        await fetchDashboard();
      }

      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Scanned successfully',
        'type': response.data['type'] ?? 'check_in',
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiClient.getErrorMessage(e),
      };
    }
  }

  // 3. Fetch Calendar
  Future<void> fetchCalendar([String? month]) async {
    _isLoadingCalendar = true;
    _selectedMonth = month ?? _selectedMonth;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.calendar,
        queryParameters: {'month': _selectedMonth},
      );

      if (response.data['success'] == true) {
        final daysList = response.data['data']['days'] as List;
        _calendarDays = daysList.map((d) => AttendanceDay.fromJson(d)).toList();
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoadingCalendar = false;
      notifyListeners();
    }
  }

  // 4. Fetch History
  Future<void> fetchHistory({bool refresh = false}) async {
    if (refresh) {
      _historyPage = 1;
      _historyItems.clear();
    }

    _isLoadingHistory = true;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.history,
        queryParameters: {'page': _historyPage},
      );

      if (response.data['success'] == true) {
        final list = response.data['data'] as List;
        final items = list.map((i) => HistoryItem.fromJson(i)).toList();

        if (refresh) {
          _historyItems = items;
        } else {
          _historyItems.addAll(items);
        }

        _historyLastPage = response.data['meta']['last_page'] ?? 1;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // 5. Fetch Monthly Report
  Future<void> fetchReport([String? month]) async {
    _isLoadingReport = true;
    final targetMonth = month ?? _selectedMonth;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.report,
        queryParameters: {'month': targetMonth},
      );

      if (response.data['success'] == true) {
        _monthlyReport = MonthlyReport.fromJson(response.data['data']);
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
    } finally {
      _isLoadingReport = false;
      notifyListeners();
    }
  }
}
