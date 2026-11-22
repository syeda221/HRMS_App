class ShiftBreakdownItem {
  final int id;
  final String name;
  final String timingLabel;
  final int presentCount;
  final int totalCount;
  final double percent;

  ShiftBreakdownItem({
    required this.id,
    required this.name,
    required this.timingLabel,
    required this.presentCount,
    required this.totalCount,
    required this.percent,
  });

  factory ShiftBreakdownItem.fromJson(Map<String, dynamic> json) {
    return ShiftBreakdownItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      timingLabel: json['timing_label'] as String? ?? '',
      presentCount: json['present_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecentCheckInItem {
  final int id;
  final int userId;
  final String name;
  final String employeeCode;
  final String? avatarUrl;
  final String department;
  final String timeFormatted;
  final String status;
  final String statusLabel;
  final String note;

  RecentCheckInItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.employeeCode,
    this.avatarUrl,
    required this.department,
    required this.timeFormatted,
    required this.status,
    required this.statusLabel,
    required this.note,
  });

  factory RecentCheckInItem.fromJson(Map<String, dynamic> json) {
    return RecentCheckInItem(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      employeeCode: json['employee_code'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      department: json['department'] as String? ?? '',
      timeFormatted: json['time_formatted'] as String? ?? '',
      status: json['status'] as String? ?? 'present',
      statusLabel: json['status_label'] as String? ?? 'On-Time',
      note: json['note'] as String? ?? '',
    );
  }
}

class AdminDashboardModel {
  final String terminalName;
  final String serverDate;
  final String serverTime;
  final int totalStaff;
  final double workforcePercent;
  final int presentToday;
  final int onTimeCount;
  final double onTimeRate;
  final int lateToday;
  final int absentToday;
  final int shiftsCount;
  final List<ShiftBreakdownItem> shiftBreakdown;
  final List<RecentCheckInItem> recentCheckins;
  final String locationName;
  final int geofenceRadius;
  final String officeQrSecret;

  AdminDashboardModel({
    required this.terminalName,
    required this.serverDate,
    required this.serverTime,
    required this.totalStaff,
    required this.workforcePercent,
    required this.presentToday,
    required this.onTimeCount,
    required this.onTimeRate,
    required this.lateToday,
    required this.absentToday,
    required this.shiftsCount,
    required this.shiftBreakdown,
    required this.recentCheckins,
    required this.locationName,
    required this.geofenceRadius,
    required this.officeQrSecret,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final geofence = json['geofence'] as Map<String, dynamic>? ?? {};
    final officeQr = json['office_qr'] as Map<String, dynamic>? ?? {};
    final shiftsList = (json['shift_breakdown'] as List<dynamic>?)
            ?.map((e) => ShiftBreakdownItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final checkinsList = (json['recent_checkins'] as List<dynamic>?)
            ?.map((e) => RecentCheckInItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AdminDashboardModel(
      terminalName: json['terminal_name'] as String? ?? 'HQ Terminal 01 • Live',
      serverDate: json['server_date'] as String? ?? '',
      serverTime: json['server_time'] as String? ?? '',
      totalStaff: json['total_staff'] as int? ?? 0,
      workforcePercent: (json['workforce_percent'] as num?)?.toDouble() ?? 0.0,
      presentToday: json['present_today'] as int? ?? 0,
      onTimeCount: json['on_time_count'] as int? ?? 0,
      onTimeRate: (json['on_time_rate'] as num?)?.toDouble() ?? 0.0,
      lateToday: json['late_today'] as int? ?? 0,
      absentToday: json['absent_today'] as int? ?? 0,
      shiftsCount: json['shifts_count'] as int? ?? 0,
      shiftBreakdown: shiftsList,
      recentCheckins: checkinsList,
      locationName: geofence['location_name'] as String? ?? 'HQ Main Campus',
      geofenceRadius: geofence['radius_meters'] as int? ?? 50,
      officeQrSecret: officeQr['secret_key'] as String? ?? 'STITCH-OFFICE-HQ-2026',
    );
  }
}
