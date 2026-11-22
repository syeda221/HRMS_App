import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/admin_dashboard_model.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  AdminDashboardModel? _dashboardData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdminDashboardModel? get dashboardData => _dashboardData;

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
}
