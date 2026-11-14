import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attendance = context.watch<AttendanceProvider>();
    final user = auth.user;
    final dashboard = attendance.dashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => attendance.fetchDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: User Greeting & Avatar (Matching Stitch "Staff Home")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null
                              ? const Icon(Icons.person, color: Colors.white, size: 26)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.name ?? 'Alex'} 👋',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${user?.designation ?? 'Staff Member'} • ${user?.employeeCode ?? 'EMP-1042'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                      onPressed: () => attendance.fetchDashboard(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Hero Check-In / Check-Out Card (Verdant Precision Deep Forest Container)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30063B2B),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dashboard?.serverDate ?? 'Today',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dashboard?.serverTime ?? '--:--',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(
                            status: dashboard?.today.status ?? 'not_marked',
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            fontSize: 12,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Check In / Check Out stats row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.login_rounded, size: 14, color: AppColors.accentLime),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Check In',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dashboard?.today.checkIn ?? '--:--',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.15)),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.logout_rounded, size: 14, color: AppColors.accentLime),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Check Out',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dashboard?.today.checkOut ?? '--:--',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.15)),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.accentLime),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total Hours',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dashboard != null && dashboard.today.totalHours > 0
                                      ? '${dashboard.today.totalHours} hrs'
                                      : '--',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Dynamic Action CTA Button
                      if (dashboard?.today.canCheckIn == true)
                        CustomButton(
                          text: 'Scan QR to Check In',
                          variant: ButtonVariant.accent,
                          icon: Icons.qr_code_scanner_rounded,
                          onPressed: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(2); // Switch to Scan Tab
                            }
                          },
                        )
                      else if (dashboard?.today.canCheckOut == true)
                        CustomButton(
                          text: 'Scan QR to Check Out',
                          variant: ButtonVariant.accent,
                          icon: Icons.logout_rounded,
                          onPressed: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(2); // Switch to Scan Tab
                            }
                          },
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Attendance Completed for Today 🎉',
                              style: TextStyle(
                                color: AppColors.accentLime,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Shift & Office Timings Policy Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08063B2B),
                        blurRadius: 14,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLimeLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.schedule_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dashboard?.shiftPolicy.shiftName ?? 'General Day Shift',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    dashboard?.shiftPolicy.workDays ?? 'Mon - Fri',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${dashboard?.shiftPolicy.requiredDailyHours ?? 8.0}h / day',
                              style: const TextStyle(
                                color: AppColors.accentLime,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.login_rounded, size: 12, color: AppColors.textSecondary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Office Hours',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dashboard?.shiftPolicy.shiftHours ?? '09:00 AM - 06:00 PM',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.statusLateBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.statusLate.withOpacity(0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.statusLate),
                                      SizedBox(width: 4),
                                      Text(
                                        'Late After',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.statusLate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dashboard?.shiftPolicy.lateThreshold ?? '09:15 AM',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.statusLate,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Grace period: ${dashboard?.shiftPolicy.gracePeriodMins ?? 15} mins. Minimum daily required work: ${dashboard?.shiftPolicy.requiredDailyHours ?? 8.0} hrs.',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section Header: Monthly Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'This Month Summary',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(3); // Reports tab
                      },
                      child: const Text('View Report', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4-Card Summary (Present, Late, Absent, Total Hours)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          MetricCard(
                            title: 'Present Days',
                            value: '${dashboard?.monthlySummary.presentDays ?? 0}',
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: AppColors.statusPresent,
                            iconBg: AppColors.statusPresentBg,
                            subtitle: 'On-time & verified',
                          ),
                          const SizedBox(height: 12),
                          MetricCard(
                            title: 'Absent Days',
                            value: '${dashboard?.monthlySummary.absentDays ?? 0}',
                            icon: Icons.cancel_outlined,
                            iconColor: AppColors.statusAbsent,
                            iconBg: AppColors.statusAbsentBg,
                            subtitle: 'Leaves taken',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          MetricCard(
                            title: 'Late Days',
                            value: '${dashboard?.monthlySummary.lateDays ?? 0}',
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.statusLate,
                            iconBg: AppColors.statusLateBg,
                            subtitle: 'After 09:05 AM',
                          ),
                          const SizedBox(height: 12),
                          MetricCard(
                            title: 'Total Hours',
                            value: '${dashboard?.monthlySummary.totalHours ?? 0.0}',
                            icon: Icons.timelapse_rounded,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.accentLimeLight,
                            subtitle: 'Working logged',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // padding for floating nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
