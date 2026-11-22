class ShiftModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final int gracePeriodMins;
  final double requiredHours;
  final String workingDays;
  final bool isActive;
  final int assignedStaffCount;

  ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriodMins,
    required this.requiredHours,
    required this.workingDays,
    required this.isActive,
    required this.assignedStaffCount,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startTime: (json['start_time'] ?? '09:00').toString().substring(0, 5),
      endTime: (json['end_time'] ?? '18:00').toString().substring(0, 5),
      gracePeriodMins: json['grace_period_mins'] ?? 15,
      requiredHours: (json['required_hours'] as num?)?.toDouble() ?? 8.0,
      workingDays: json['working_days'] ?? 'Mon - Fri',
      isActive: json['is_active'] ?? true,
      assignedStaffCount: json['assigned_staff_count'] ?? 0,
    );
  }
}
