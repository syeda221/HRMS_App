class AttendanceMonitorResponse {
  final String date;
  final AttendanceMetrics metrics;
  final List<AttendanceMonitorRecord> records;

  AttendanceMonitorResponse({
    required this.date,
    required this.metrics,
    required this.records,
  });

  factory AttendanceMonitorResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceMonitorResponse(
      date: json['date'] ?? '',
      metrics: AttendanceMetrics.fromJson(json['metrics'] ?? {}),
      records: (json['records'] as List? ?? [])
          .map((r) => AttendanceMonitorRecord.fromJson(r))
          .toList(),
    );
  }
}

class AttendanceMetrics {
  final int totalStaff;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final double onTimeRate;

  AttendanceMetrics({
    required this.totalStaff,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.onTimeRate,
  });

  factory AttendanceMetrics.fromJson(Map<String, dynamic> json) {
    return AttendanceMetrics(
      totalStaff: json['total_staff'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      lateCount: json['late_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      onTimeRate: (json['on_time_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AttendanceMonitorRecord {
  final int userId;
  final String employeeCode;
  final String name;
  final String email;
  final String avatarUrl;
  final String department;
  final String designation;
  final String shiftName;
  final String shiftTiming;
  final int? attendanceId;
  final String date;
  final String status;
  final String checkIn;
  final String checkOut;
  final double totalHours;
  final bool isManualOverride;
  final String? note;

  AttendanceMonitorRecord({
    required this.userId,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.department,
    required this.designation,
    required this.shiftName,
    required this.shiftTiming,
    this.attendanceId,
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.totalHours,
    required this.isManualOverride,
    this.note,
  });

  factory AttendanceMonitorRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceMonitorRecord(
      userId: json['user_id'] ?? 0,
      employeeCode: json['employee_code'] ?? 'EMP-000',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      department: json['department'] ?? 'General',
      designation: json['designation'] ?? 'Staff',
      shiftName: json['shift_name'] ?? 'Standard Shift',
      shiftTiming: json['shift_timing'] ?? '09:00 - 18:00',
      attendanceId: json['attendance_id'],
      date: json['date'] ?? '',
      status: json['status'] ?? 'absent',
      checkIn: json['check_in'] ?? '--:--',
      checkOut: json['check_out'] ?? '--:--',
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
      isManualOverride: json['is_manual_override'] ?? false,
      note: json['note'],
    );
  }
}
