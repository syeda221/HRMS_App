import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../views/admin_dashboard_screen.dart';

class AdminNavigationShell extends StatefulWidget {
  const AdminNavigationShell({super.key});

  @override
  State<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends State<AdminNavigationShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildPlaceholderTab(String title, IconData icon, String subtitle) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [BoxShadow(color: Color(0x0A063B2B), blurRadius: 16, offset: Offset(0, 4))],
                ),
                child: Icon(icon, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminDashboardScreen(onNavigateTab: _onTabTapped),
      _buildPlaceholderTab(
        'Staff Directory',
        Icons.badge_rounded,
        'Manage and register staff members with dynamic QR codes.',
      ),
      _buildPlaceholderTab(
        'Attendance Monitor',
        Icons.fact_check_rounded,
        'View live attendance sheets, filter by date, and make manual corrections.',
      ),
      _buildPlaceholderTab(
        'Payroll & Salaries',
        Icons.payments_rounded,
        'Generate monthly staff payroll based on punctuality and attendance.',
      ),
      _buildPlaceholderTab(
        'Shifts & Settings',
        Icons.tune_rounded,
        'Configure office shifts, grace periods, and geofence locations.',
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),

          // Floating Island Pill Navigation Bar (Matching Stitch Design)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40042F23),
                      blurRadius: 28,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
                    _buildNavItem(1, Icons.badge_rounded, 'Staff'),
                    _buildNavItem(2, Icons.fact_check_rounded, 'Monitor'),
                    _buildNavItem(3, Icons.payments_rounded, 'Payroll'),
                    _buildNavItem(4, Icons.tune_rounded, 'More'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLime : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x59B8E83D),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : Colors.white60,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
