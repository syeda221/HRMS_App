import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/views/login_screen.dart';
import '../models/admin_dashboard_model.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AdminDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  void _showKioskModal(AdminDashboardModel data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.accentLimeLight, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.locationName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const Text('Official Office Lobby QR Payload', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x0A063B2B), blurRadius: 18, offset: Offset(0, 6))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentLime, width: 2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded, size: 70, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(
                            data.officeQrSecret,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Employees scan this code to Check-in & Check-out', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close QR Terminal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final user = context.watch<AuthProvider>().user;
    final data = adminProv.dashboardData;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => adminProv.loadDashboard(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Top Custom App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Color(0x2E063B2B), blurRadius: 8, offset: Offset(0, 2))],
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.accentLime, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'ADMIN PORTAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4D6700),
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                'Admin Dashboard',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textPrimary),
                              onPressed: () => adminProv.loadDashboard(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            offset: const Offset(0, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                            onSelected: (val) {
                              if (val == 'logout') {
                                context.read<AuthProvider>().logout();
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                enabled: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user?.name ?? 'Admin Director', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    Text(user?.email ?? 'admin@company.com', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout_rounded, size: 18, color: AppColors.statusAbsent),
                                    SizedBox(width: 8),
                                    Text('Sign Out', style: TextStyle(color: AppColors.statusAbsent, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Loading / Error or Content
              if (adminProv.isLoading && data == null)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (adminProv.errorMessage != null && data == null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.statusAbsent),
                          const SizedBox(height: 12),
                          Text(adminProv.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            onPressed: () => adminProv.loadDashboard(),
                            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Greeting & Live Pulse Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: AppColors.accentLime, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  data?.terminalName ?? 'HQ Terminal 01 • Live',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4D6700), letterSpacing: 0.5),
                                ),
                              ],
                            ),
                            Text(
                              data?.serverDate ?? 'Nov 22, 2026',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Good Morning, Admin',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    children: [
                                      const TextSpan(text: 'Active Workforce: '),
                                      TextSpan(
                                        text: '${data?.workforcePercent ?? 0}%',
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: ' across ${data?.shiftsCount ?? 2} shifts'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: const [
                                  Icon(Icons.wifi_rounded, size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text('Syncing', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 3. Primary Action Banner: Kiosk Scanner Launcher (Matching Stitch)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(color: Color(0x40063B2B), blurRadius: 24, offset: Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLime,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                        const SizedBox(width: 6),
                                        const Text('LIVE MODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Icon(Icons.sensors_rounded, color: AppColors.accentLime, size: 16),
                                      SizedBox(width: 4),
                                      Text('Dual Cam Ready', style: TextStyle(fontSize: 11, color: Color(0xFF76A691), fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Open Reception Kiosk Scanner',
                                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Fast dynamic QR check-in & NFC reader',
                                          style: TextStyle(color: Color(0xFF76A691), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLime,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [BoxShadow(color: Color(0x66B8E83D), blurRadius: 12, offset: Offset(0, 4))],
                                    ),
                                    child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 26),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentLime,
                                  foregroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.fullscreen_rounded, size: 20),
                                label: const Text('Launch Fullscreen Kiosk / View QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                onPressed: () {
                                  if (data != null) _showKioskModal(data);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 4. Key Metrics 3-Card Grid (Matching Stitch)
                        Row(
                          children: [
                            // Total Staff
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
                                          child: const Icon(Icons.groups_rounded, size: 16, color: AppColors.primary),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.accentLimeLight, borderRadius: BorderRadius.circular(10)),
                                          child: const Text('+2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${data?.totalStaff ?? 0}',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text('Total Staff', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Present Today
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: AppColors.statusPresentBg, borderRadius: BorderRadius.circular(8)),
                                          child: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.statusPresent),
                                        ),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(color: AppColors.accentLime, shape: BoxShape.circle),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${data?.presentToday ?? 0}',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${data?.workforcePercent ?? 0}% Present',
                                      style: const TextStyle(fontSize: 10, color: AppColors.statusPresent, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Late / Absent
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: AppColors.statusAbsentBg, borderRadius: BorderRadius.circular(8)),
                                          child: const Icon(Icons.schedule_rounded, size: 16, color: AppColors.statusAbsent),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.statusAbsentBg, borderRadius: BorderRadius.circular(10)),
                                          child: Text('${data?.lateToday ?? 0} Late', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.statusAbsent)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.statusAbsent, letterSpacing: -0.5),
                                        children: [
                                          TextSpan(text: '${data?.lateToday ?? 0}'),
                                          TextSpan(text: ' / ${data?.absentToday ?? 0}', style: const TextStyle(fontSize: 14, color: AppColors.textTertiary, fontWeight: FontWeight.normal)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text('Late • Absent', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 5. Real-Time Attendance Gauge & Shift Breakdown (Matching Stitch)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                            boxShadow: const [BoxShadow(color: Color(0x06063B2B), blurRadius: 14, offset: Offset(0, 3))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text("Today's Live Attendance", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      Text('Combined day progress across shifts', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                                    child: const Text('Real-Time', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Circular Progress Ring Indicator
                                  SizedBox(
                                    width: 88,
                                    height: 88,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 1.0,
                                          strokeWidth: 8,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.border),
                                        ),
                                        CircularProgressIndicator(
                                          value: (data?.onTimeRate ?? 0) / 100,
                                          strokeWidth: 8,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${data?.onTimeRate.round() ?? 0}%',
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: -0.5),
                                            ),
                                            const Text('On-Time', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Shift Progress Breakdown Bars
                                  Expanded(
                                    child: Column(
                                      children: [
                                        if (data?.shiftBreakdown != null)
                                          for (var shift in data!.shiftBreakdown) ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    shift.timingLabel,
                                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  '${shift.presentCount}/${shift.totalCount}',
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: shift.totalCount > 0 ? (shift.presentCount / shift.totalCount) : 0,
                                                minHeight: 6,
                                                backgroundColor: AppColors.surfaceMuted,
                                                valueColor: AlwaysStoppedAnimation<Color>(shift.id == 1 ? AppColors.primary : AppColors.accentLime),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                                const SizedBox(width: 4),
                                                Text('${data?.onTimeCount ?? 0} On-time', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                            const SizedBox(width: 12),
                                            Row(
                                              children: [
                                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.statusAbsent, shape: BoxShape.circle)),
                                                const SizedBox(width: 4),
                                                Text('${data?.lateToday ?? 0} Late', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 6. Quick Management Shortcuts (2x2 Grid)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Quick Management', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('Admin Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4D6700))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // 1. Add Staff
                            Expanded(
                              child: _buildShortcutCard(
                                icon: Icons.person_add_rounded,
                                iconColor: AppColors.accentLime,
                                iconBg: AppColors.primary,
                                title: 'Add Staff',
                                subtitle: 'Register dynamic QR',
                                onTap: () {
                                  if (widget.onNavigateTab != null) widget.onNavigateTab!(1); // Staff Tab
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // 2. Shifts & Grace
                            Expanded(
                              child: _buildShortcutCard(
                                icon: Icons.schedule_rounded,
                                iconColor: AppColors.primary,
                                iconBg: AppColors.surfaceMuted,
                                title: 'Shifts & Grace',
                                subtitle: '9AM - 6PM • 15m grace',
                                onTap: () {
                                  if (widget.onNavigateTab != null) widget.onNavigateTab!(4); // Shifts Tab
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // 3. Audit Sheet
                            Expanded(
                              child: _buildShortcutCard(
                                icon: Icons.event_note_rounded,
                                iconColor: AppColors.primary,
                                iconBg: AppColors.accentLimeLight,
                                title: 'Audit Sheet',
                                subtitle: 'Attendance Monitor',
                                onTap: () {
                                  if (widget.onNavigateTab != null) widget.onNavigateTab!(2); // Attendance Monitor Tab
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // 4. Run Payroll
                            Expanded(
                              child: _buildShortcutCard(
                                icon: Icons.payments_rounded,
                                iconColor: AppColors.primary,
                                iconBg: AppColors.accentLime,
                                title: 'Run Payroll',
                                subtitle: 'Cycle Ready',
                                onTap: () {
                                  if (widget.onNavigateTab != null) widget.onNavigateTab!(3); // Payroll Tab
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // 7. Live Activity Stream (Recent Check-ins)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Recent Check-ins', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                                        child: const Text('Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                    onPressed: () {
                                      if (widget.onNavigateTab != null) widget.onNavigateTab!(2);
                                    },
                                    child: Row(
                                      children: const [
                                        Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4D6700))),
                                        Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF4D6700)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (data?.recentCheckins != null && data!.recentCheckins.isNotEmpty)
                                for (var item in data.recentCheckins) ...[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundImage: item.avatarUrl != null ? NetworkImage(item.avatarUrl!) : null,
                                          backgroundColor: AppColors.primary,
                                          child: item.avatarUrl == null
                                              ? Text(item.name.isNotEmpty ? item.name[0] : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                                    child: Text(item.employeeCode, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(item.note, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(item.timeFormatted, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textPrimary)),
                                            const SizedBox(height: 2),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: item.status == 'late' ? AppColors.statusLateBg : AppColors.statusPresentBg,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.statusLabel,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.status == 'late' ? AppColors.statusLate : AppColors.statusPresent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              else
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text('No attendance scans recorded yet today.', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 8. Spatial Security / Geofence Card (Matching Stitch)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.location_on_rounded, color: AppColors.accentLime, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('SPATIAL SECURITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4D6700), letterSpacing: 0.8)),
                                        const SizedBox(width: 6),
                                        Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.accentLime, shape: BoxShape.circle)),
                                        const SizedBox(width: 4),
                                        const Text('Active', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Geofencing locked to ${data?.geofenceRadius ?? 150}m radius • ${data?.locationName ?? 'HQ Main Campus'}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 110), // Bottom padding for floating island nav
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x06063B2B), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
