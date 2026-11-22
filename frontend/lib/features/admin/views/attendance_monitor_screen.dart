import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/attendance_monitor_model.dart';
import '../providers/admin_provider.dart';

class AttendanceMonitorScreen extends StatefulWidget {
  const AttendanceMonitorScreen({super.key});

  @override
  State<AttendanceMonitorScreen> createState() => _AttendanceMonitorScreenState();
}

class _AttendanceMonitorScreenState extends State<AttendanceMonitorScreen> {
  DateTime _currentDate = DateTime.now();
  String _activeFilter = 'all'; // all, present, late, absent

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
    context.read<AdminProvider>().loadAttendanceMonitor(
          date: dateStr,
          status: _activeFilter,
        );
  }

  void _changeDate(int daysDelta) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: daysDelta));
    });
    _loadData();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF063B2B),
              onPrimary: Color(0xFFB8E83D),
              surface: Colors.white,
              onSurface: Color(0xFF002418),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _currentDate = picked;
      });
      _loadData();
    }
  }

  void _showOverrideModal({AttendanceMonitorRecord? record}) {
    final provider = context.read<AdminProvider>();
    final dir = provider.staffDirectory;
    int? selectedUserId = record?.userId;
    String selectedStatus = record?.status ?? 'present';
    final checkInCtrl = TextEditingController(text: record?.checkIn != '--:--' ? record?.checkIn : '09:00');
    final checkOutCtrl = TextEditingController(text: record?.checkOut != '--:--' ? record?.checkOut : '18:00');
    final noteCtrl = TextEditingController(text: record?.note ?? 'Manual Admin Verification');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF063B2B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.build_circle, color: Color(0xFFB8E83D), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual Attendance Override',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                          ),
                          Text('Direct punch correction with audit memo', style: TextStyle(fontSize: 12, color: Color(0xFF717974))),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Staff Select
                  const Text('Employee *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (record != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text('${record.name} (${record.employeeCode})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(record.designation, style: const TextStyle(fontSize: 12, color: Color(0xFF717974))),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      value: selectedUserId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: const Text('Select Employee to Override'),
                      items: (dir?.employees ?? []).map((e) {
                        return DropdownMenuItem<int>(
                          value: e.id,
                          child: Text('${e.name} (${e.employeeCode})'),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedUserId = val),
                    ),
                  const SizedBox(height: 14),

                  // Status Selector Pills
                  const Text('Set Attendance Status *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusOption(
                        label: 'Present',
                        value: 'present',
                        isSelected: selectedStatus == 'present',
                        color: const Color(0xFF4D6700),
                        onTap: () => setModalState(() => selectedStatus = 'present'),
                      ),
                      const SizedBox(width: 6),
                      _buildStatusOption(
                        label: 'Late',
                        value: 'late',
                        isSelected: selectedStatus == 'late',
                        color: const Color(0xFFE28A00),
                        onTap: () => setModalState(() => selectedStatus = 'late'),
                      ),
                      const SizedBox(width: 6),
                      _buildStatusOption(
                        label: 'Absent',
                        value: 'absent',
                        isSelected: selectedStatus == 'absent',
                        color: const Color(0xFFBA1A1A),
                        onTap: () => setModalState(() => selectedStatus = 'absent'),
                      ),
                      const SizedBox(width: 6),
                      _buildStatusOption(
                        label: 'Half-Day',
                        value: 'half_day',
                        isSelected: selectedStatus == 'half_day',
                        color: const Color(0xFF063B2B),
                        onTap: () => setModalState(() => selectedStatus = 'half_day'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Times
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Punch In (HH:MM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: checkInCtrl,
                              decoration: InputDecoration(
                                hintText: '09:00',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Punch Out (HH:MM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: checkOutCtrl,
                              decoration: InputDecoration(
                                hintText: '18:00',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Note / Compliance Memo
                  const Text('Reason & Audit Memo *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Card forgotten at home, physically verified by manager.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (selectedUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select an employee')),
                          );
                          return;
                        }
                        final dateStr = DateFormat('yyyy-MM-dd').format(_currentDate);
                        final success = await provider.overrideAttendance({
                          'user_id': selectedUserId,
                          'date': dateStr,
                          'status': selectedStatus,
                          'check_in': checkInCtrl.text.trim(),
                          'check_out': checkOutCtrl.text.trim(),
                          'note': noteCtrl.text.trim(),
                        });

                        if (mounted) {
                          Navigator.pop(ctx);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Attendance manually overridden & verified!'),
                                backgroundColor: Color(0xFF063B2B),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.how_to_reg, color: Color(0xFFB8E83D)),
                      label: const Text('Confirm Manual Punch', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063B2B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusOption({
    required String label,
    required String value,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFFF2F4F1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF002418),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final monitor = provider.attendanceMonitor;
    final dateDisplay = DateFormat('EEE, MMM dd, yyyy').format(_currentDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF7),
        elevation: 0,
        titleSpacing: 16,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF002418)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF063B2B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fact_check, color: Color(0xFFB8E83D), size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN PORTAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF4D6700),
                  ),
                ),
                Text(
                  'Attendance Monitor',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002418),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF063B2B)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: provider.isLoading && monitor == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF063B2B)))
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: const Color(0xFF063B2B),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Narrative Banner Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE1E3E0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
                                const CircleAvatar(radius: 4, backgroundColor: Color(0xFFB8E83D)),
                                const SizedBox(width: 8),
                                const Text(
                                  'SYNC ACTIVE • REALTIME',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF4D6700),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF063B2B),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.fact_check, color: Color(0xFFB8E83D), size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Staff Attendance Register',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002418),
                          ),
                        ),
                        const Text(
                          'Daily office attendance log, filters, and manual punch overrides.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF717974)),
                        ),
                        const SizedBox(height: 14),

                        // Mini metrics row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat(
                                label: 'Present Today',
                                value: '${monitor?.metrics.presentCount ?? 0} / ${monitor?.metrics.totalStaff ?? 0}',
                                color: const Color(0xFF002418),
                              ),
                              Container(width: 1, height: 28, color: const Color(0xFFC0C9C2)),
                              _buildMiniStat(
                                label: 'Late Arrivals',
                                value: '${monitor?.metrics.lateCount ?? 0}',
                                color: const Color(0xFFE28A00),
                              ),
                              Container(width: 1, height: 28, color: const Color(0xFFC0C9C2)),
                              _buildMiniStat(
                                label: 'On-Time Rate',
                                value: '${monitor?.metrics.onTimeRate ?? 0}%',
                                color: const Color(0xFF4D6700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Date Navigation Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE1E3E0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Color(0xFF002418)),
                          onPressed: () => _changeDate(-1),
                        ),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC0F045).withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.calendar_today, size: 14, color: Color(0xFF4D6700)),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  Text(
                                    dateDisplay,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF002418),
                                    ),
                                  ),
                                  const Text('Tap to change date', style: TextStyle(fontSize: 10, color: Color(0xFF717974))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Color(0xFF002418)),
                          onPressed: () => _changeDate(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All', monitor?.metrics.totalStaff ?? 0),
                        const SizedBox(width: 8),
                        _buildFilterChip('present', 'Present', monitor?.metrics.presentCount ?? 0),
                        const SizedBox(width: 8),
                        _buildFilterChip('late', 'Late', monitor?.metrics.lateCount ?? 0),
                        const SizedBox(width: 8),
                        _buildFilterChip('absent', 'Absent', monitor?.metrics.absentCount ?? 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Manual Attendance Override CTA Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFB8E83D).withOpacity(0.7)),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB8E83D).withOpacity(0.08),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF063B2B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.build_circle, color: Color(0xFFB8E83D), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manual Punch Override',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                              ),
                              Text('Punch in or adjust for forgotten badge / phone', style: TextStyle(fontSize: 11, color: Color(0xFF717974))),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showOverrideModal(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF063B2B),
                            foregroundColor: const Color(0xFFB8E83D),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Punch In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attendance Roster List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Attendance Roster (${monitor?.records.length ?? 0})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002418),
                        ),
                      ),
                      const Text('Live Synced', style: TextStyle(fontSize: 12, color: Color(0xFF4D6700), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (monitor != null && monitor.records.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('No attendance records for this date/filter.', style: TextStyle(color: Color(0xFF717974))),
                      ),
                    )
                  else if (monitor != null)
                    ...monitor.records.map((rec) => _buildRosterCard(rec)),

                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniStat({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF717974))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, int count) {
    final isSelected = _activeFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() => _activeFilter = key);
        _loadData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF063B2B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF063B2B) : const Color(0xFFE1E3E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF002418),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB8E83D) : const Color(0xFFF2F4F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF063B2B) : const Color(0xFF717974),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRosterCard(AttendanceMonitorRecord rec) {
    Color statusBg;
    Color statusTextColor;
    String statusLabel;
    IconData statusIcon;

    if (rec.status == 'present') {
      statusBg = const Color(0xFFC0F045).withOpacity(0.25);
      statusTextColor = const Color(0xFF4D6700);
      statusLabel = 'Present (On-Time)';
      statusIcon = Icons.check_circle;
    } else if (rec.status == 'late') {
      statusBg = const Color(0xFFFFDAD6);
      statusTextColor = const Color(0xFF93000A);
      statusLabel = 'Late Arrival';
      statusIcon = Icons.warning;
    } else if (rec.status == 'half_day') {
      statusBg = const Color(0xFFECEEEB);
      statusTextColor = const Color(0xFF063B2B);
      statusLabel = 'Half-Day';
      statusIcon = Icons.timelapse;
    } else {
      statusBg = const Color(0xFFECEEEB);
      statusTextColor = const Color(0xFF717974);
      statusLabel = 'Absent / Sick';
      statusIcon = Icons.event_busy;
    }

    if (rec.isManualOverride) {
      statusLabel += ' • Overridden';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E3E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  rec.avatarUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: const Color(0xFF063B2B),
                    child: Center(
                      child: Text(
                        rec.name.isNotEmpty ? rec.name[0] : 'U',
                        style: const TextStyle(color: Color(0xFFB8E83D), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            rec.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            rec.employeeCode,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF063B2B)),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${rec.designation} • ${rec.shiftTiming}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF717974)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note, color: Color(0xFF063B2B), size: 22),
                onPressed: () => _showOverrideModal(record: rec),
                tooltip: 'Manual Override / Edit Punch',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CHECK IN', style: TextStyle(fontSize: 9, color: Color(0xFF717974), fontWeight: FontWeight.bold)),
                        Text(
                          rec.checkIn,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: rec.status == 'late' ? const Color(0xFFBA1A1A) : const Color(0xFF002418),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CHECK OUT', style: TextStyle(fontSize: 9, color: Color(0xFF717974), fontWeight: FontWeight.bold)),
                        Text(
                          rec.checkOut,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF717974)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 12, color: statusTextColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
