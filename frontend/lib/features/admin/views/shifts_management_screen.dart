import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shift_model.dart';
import '../providers/admin_provider.dart';

class ShiftsManagementScreen extends StatefulWidget {
  const ShiftsManagementScreen({super.key});

  @override
  State<ShiftsManagementScreen> createState() => _ShiftsManagementScreenState();
}

class _ShiftsManagementScreenState extends State<ShiftsManagementScreen> {
  // Grace buffer slider for active shift
  double _graceMinutes = 15;
  String _startTime = '09:00';
  String _endTime = '18:00';
  ShiftModel? _selectedShift;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      await provider.loadShifts();
      if (provider.shifts.isNotEmpty) {
        final first = provider.shifts.first;
        setState(() {
          _selectedShift = first;
          _graceMinutes = first.gracePeriodMins.toDouble();
          _startTime = first.startTime;
          _endTime = first.endTime;
        });
      }
    });
  }

  void _showAddEditShiftDialog({ShiftModel? shift}) {
    final nameCtrl = TextEditingController(text: shift?.name ?? '');
    final startCtrl = TextEditingController(text: shift?.startTime ?? '09:00');
    final endCtrl = TextEditingController(text: shift?.endTime ?? '18:00');
    final graceCtrl = TextEditingController(text: (shift?.gracePeriodMins ?? 15).toString());
    final hoursCtrl = TextEditingController(text: (shift?.requiredHours ?? 8.0).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          shift == null ? 'Create Custom Shift' : 'Edit Shift Timing',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002418)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shift Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Midday Support Shift',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start (HH:MM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: startCtrl,
                          decoration: InputDecoration(
                            hintText: '09:00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End (HH:MM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: endCtrl,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grace (Mins)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: graceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '15',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hours/Day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: hoursCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '8.0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<AdminProvider>();
              final success = await provider.saveShift({
                'name': nameCtrl.text.trim(),
                'start_time': startCtrl.text.trim(),
                'end_time': endCtrl.text.trim(),
                'grace_period_mins': int.tryParse(graceCtrl.text.trim()) ?? 15,
                'required_hours': double.tryParse(hoursCtrl.text.trim()) ?? 8.0,
              }, id: shift?.id);

              if (mounted) {
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shift timing saved successfully!'),
                      backgroundColor: Color(0xFF063B2B),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF063B2B),
              foregroundColor: const Color(0xFFB8E83D),
            ),
            child: const Text('Save Shift'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePolicyEngine() async {
    if (_selectedShift == null) return;
    final provider = context.read<AdminProvider>();
    final success = await provider.saveShift({
      'name': _selectedShift!.name,
      'start_time': _startTime,
      'end_time': _endTime,
      'grace_period_mins': _graceMinutes.round(),
      'required_hours': _selectedShift!.requiredHours,
    }, id: _selectedShift!.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timing policy updated! Grace window is ${_graceMinutes.round()}m.'),
            backgroundColor: const Color(0xFF063B2B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final shifts = provider.shifts;

    // Calculate cutoff display
    final startParts = _startTime.split(':');
    final startH = int.tryParse(startParts[0]) ?? 9;
    final startM = int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0;
    final totalM = startM + _graceMinutes.round();
    final cutoffH = (startH + (totalM ~/ 60)).toString().padLeft(2, '0');
    final cutoffM = (totalM % 60).toString().padLeft(2, '0');
    final cutoffText = '$cutoffH:$cutoffM AM';

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
              child: const Icon(Icons.schedule, color: Color(0xFFB8E83D), size: 20),
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
                  'Shifts & Timings',
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
            onPressed: () => provider.loadShifts(),
          ),
        ],
      ),
      body: provider.isLoading && shifts.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF063B2B)))
          : RefreshIndicator(
              onRefresh: () => provider.loadShifts(),
              color: const Color(0xFF063B2B),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Engine Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8E83D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'POLICY ENGINE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Color(0xFF063B2B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const CircleAvatar(radius: 3, backgroundColor: Color(0xFF4D6700)),
                          const SizedBox(width: 6),
                          Text(
                            '${shifts.length} Shifts Configured',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4D6700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Shifts & Work Hours',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002418),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Configure office schedules, grace periods, and late arrival penalties.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF717974)),
                  ),
                  const SizedBox(height: 16),

                  // Primary Active Shift Card (Verdant Precision highlight card)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE1E3E0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF063B2B).withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top decorative accent glow line
                        Container(
                          height: 5,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            gradient: LinearGradient(
                              colors: [Color(0xFFB8E83D), Color(0xFF4D6700), Color(0xFF063B2B)],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                _selectedShift?.name ?? 'Standard Morning Shift',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF002418),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF063B2B),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'PRIMARY',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFB8E83D),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$_startTime — $_endTime • ${_selectedShift?.requiredHours ?? 8.0}h daily required',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF717974)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC0F045).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.schedule, color: Color(0xFF063B2B), size: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Time Inputs Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2F4F1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.login, size: 14, color: Color(0xFF4D6700)),
                                              SizedBox(width: 4),
                                              Text('Check-in Time', style: TextStyle(fontSize: 11, color: Color(0xFF717974))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _startTime,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF002418),
                                            ),
                                          ),
                                          const Text('Default start hour', style: TextStyle(fontSize: 10, color: Color(0xFF717974))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2F4F1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.logout, size: 14, color: Color(0xFFBA1A1A)),
                                              SizedBox(width: 4),
                                              Text('Check-out Time', style: TextStyle(fontSize: 11, color: Color(0xFF717974))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _endTime,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF002418),
                                            ),
                                          ),
                                          const Text('Standard checkout', style: TextStyle(fontSize: 10, color: Color(0xFF717974))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Grace Buffer Interactive Slider
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.timer, size: 18, color: Color(0xFF063B2B)),
                                            SizedBox(width: 6),
                                            Text(
                                              'Grace Buffer Window',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF002418),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB8E83D),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_graceMinutes.round()} Mins',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF063B2B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Slider(
                                      value: _graceMinutes,
                                      min: 5,
                                      max: 45,
                                      divisions: 8,
                                      activeColor: const Color(0xFF063B2B),
                                      inactiveColor: const Color(0xFFC0C9C2),
                                      onChanged: (val) {
                                        setState(() => _graceMinutes = val);
                                      },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.info_outline, size: 16, color: Color(0xFF063B2B)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Allows check-in up to $cutoffText without penalty. Arrivals after this mark automatically trigger a "Late" status.',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF717974), height: 1.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Policy Rules Stack
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.contrast, size: 16, color: Color(0xFF063B2B)),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Half-Day Threshold', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            Text('Beyond 11:30 AM marks 0.5 Day', style: TextStyle(fontSize: 10, color: Color(0xFF717974))),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '11:30 AM',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF063B2B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Save Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _updatePolicyEngine,
                                  icon: const Icon(Icons.verified, size: 18, color: Color(0xFFB8E83D)),
                                  label: const Text('Update Timing Policy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF063B2B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Shift Templates Header & List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shift Templates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002418),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddEditShiftDialog(),
                        icon: const Icon(Icons.add, size: 16, color: Color(0xFF4D6700)),
                        label: const Text('Add Shift', style: TextStyle(color: Color(0xFF4D6700))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ...shifts.map((s) {
                    final isSelected = _selectedShift?.id == s.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF063B2B) : const Color(0xFFE1E3E0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF063B2B) : const Color(0xFFF2F4F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.access_time,
                              color: isSelected ? const Color(0xFFB8E83D) : const Color(0xFF717974),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF002418),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.startTime} — ${s.endTime} • Grace: ${s.gracePeriodMins}m',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF717974)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${s.assignedStaffCount} Staff',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF063B2B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF717974)),
                            onPressed: () => _showAddEditShiftDialog(shift: s),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }
}
