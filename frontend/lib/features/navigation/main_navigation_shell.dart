import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/floating_nav_bar.dart';
import '../attendance/views/attendance_calendar_screen.dart';
import '../dashboard/views/dashboard_screen.dart';
import '../profile/views/profile_screen.dart';
import '../reports/views/monthly_report_screen.dart';
import '../scanner/views/qr_scanner_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelect(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateTab: _onTabSelect),
      const AttendanceCalendarScreen(),
      QrScannerScreen(onNavigateTab: _onTabSelect),
      const MonthlyReportScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          // Floating Bottom Navigation Bar (Suspended Island)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabSelect,
            ),
          ),
        ],
      ),
    );
  }
}
