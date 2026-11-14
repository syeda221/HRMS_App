import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../attendance/providers/attendance_provider.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  void _loadReport() {
    final monthStr = DateFormat('yyyy-MM').format(_currentMonth);
    context.read<AttendanceProvider>().fetchReport(monthStr);
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final report = attendance.monthlyReport;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _loadReport(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Switcher Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hero Attendance Rate Circular Card (Matching Stitch "Attendance Reports")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  children: [
                    const Text(
                      'Overall Attendance Rate',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 18),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: (report?.attendanceRate ?? 0) / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentLime),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${report?.attendanceRate ?? 0}%',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      (report?.attendanceRate ?? 0) >= 90
                          ? '🌟 Excellent punctuality this month!'
                          : '⚡ Keep an eye on attendance punctuality.',
                      style: const TextStyle(
                        color: AppColors.accentLime,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Breakdown Title
              const Text(
                'Attendance Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // 4-Metric Breakdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        MetricCard(
                          title: 'Present Days',
                          value: '${report?.presentDays ?? 0}',
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.statusPresent,
                          iconBg: AppColors.statusPresentBg,
                          subtitle: 'Full presence recorded',
                        ),
                        const SizedBox(height: 12),
                        MetricCard(
                          title: 'Absent Days',
                          value: '${report?.absentDays ?? 0}',
                          icon: Icons.cancel_rounded,
                          iconColor: AppColors.statusAbsent,
                          iconBg: AppColors.statusAbsentBg,
                          subtitle: 'Unmarked / Leave taken',
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
                          value: '${report?.lateDays ?? 0}',
                          icon: Icons.schedule_rounded,
                          iconColor: AppColors.statusLate,
                          iconBg: AppColors.statusLateBg,
                          subtitle: 'Arrived after 09:05 AM',
                        ),
                        const SizedBox(height: 12),
                        MetricCard(
                          title: 'Holidays & Off',
                          value: '${report?.holidays ?? 0}',
                          icon: Icons.beach_access_rounded,
                          iconColor: AppColors.statusHoliday,
                          iconBg: AppColors.statusHolidayBg,
                          subtitle: 'Weekends & company off',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Total Hours Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentLimeLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.timer_outlined, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Working Hours',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Avg: ${report?.averageHoursPerDay ?? 0.0} hrs/day',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${report?.totalHours ?? 0.0} hrs',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // room for floating nav
            ],
          ),
        ),
      ),
    );
  }
}
