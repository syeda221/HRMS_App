class TodayAttendance {
  final String date;
  final String status;
  final String badgeText;
  final String? checkIn;
  final String? checkOut;
  final double totalHours;
  final bool canCheckIn;
  final bool canCheckOut;

  TodayAttendance({
    required this.date,
    required this.status,
    required this.badgeText,
    this.checkIn,
    this.checkOut,
    required this.totalHours,
    required this.canCheckIn,
    required this.canCheckOut,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'not_marked',
      badgeText: json['attendance_badge'] as String? ?? 'Not Checked In',
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
      canCheckIn: json['can_check_in'] as bool? ?? true,
      canCheckOut: json['can_check_out'] as bool? ?? false,
    );
  }
}

class MonthlySummary {
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int holidays;
  final double totalHours;

  MonthlySummary({
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.holidays,
    required this.totalHours,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      presentDays: json['present_days'] as int? ?? 0,
      lateDays: json['late_days'] as int? ?? 0,
      absentDays: json['absent_days'] as int? ?? 0,
      holidays: json['holidays'] as int? ?? 0,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ShiftPolicy {
  final String shiftName;
  final String shiftHours;
  final String startTime;
  final String endTime;
  final double requiredDailyHours;
  final int gracePeriodMins;
  final String lateThreshold;
  final String workDays;
  final String lateRuleText;
  final String hoursRuleText;

  ShiftPolicy({
    required this.shiftName,
    required this.shiftHours,
    required this.startTime,
    required this.endTime,
    required this.requiredDailyHours,
    required this.gracePeriodMins,
    required this.lateThreshold,
    required this.workDays,
    required this.lateRuleText,
    required this.hoursRuleText,
  });

  factory ShiftPolicy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ShiftPolicy.defaultPolicy();
    }
    return ShiftPolicy(
      shiftName: json['shift_name'] as String? ?? 'General Day Shift',
      shiftHours: json['shift_hours'] as String? ?? '09:00 AM - 06:00 PM',
      startTime: json['start_time'] as String? ?? '09:00 AM',
      endTime: json['end_time'] as String? ?? '06:00 PM',
      requiredDailyHours: (json['required_daily_hours'] as num?)?.toDouble() ?? 8.0,
      gracePeriodMins: json['grace_period_mins'] as int? ?? 15,
      lateThreshold: json['late_threshold'] as String? ?? '09:15 AM',
      workDays: json['work_days'] as String? ?? 'Mon - Fri',
      lateRuleText: json['late_rule_text'] as String? ?? 'Check-in after 09:15 AM is marked as Late',
      hoursRuleText: json['hours_rule_text'] as String? ?? 'Minimum 8.0 working hours required per day',
    );
  }

  factory ShiftPolicy.defaultPolicy() {
    return ShiftPolicy(
      shiftName: 'General Day Shift',
      shiftHours: '09:00 AM - 06:00 PM',
      startTime: '09:00 AM',
      endTime: '06:00 PM',
      requiredDailyHours: 8.0,
      gracePeriodMins: 15,
      lateThreshold: '09:15 AM',
      workDays: 'Mon - Fri',
      lateRuleText: 'Check-in after 09:15 AM is marked as Late',
      hoursRuleText: 'Minimum 8.0 working hours required per day',
    );
  }
}

class DashboardData {
  final String serverTime;
  final String serverDate;
  final TodayAttendance today;
  final MonthlySummary monthlySummary;
  final ShiftPolicy shiftPolicy;

  DashboardData({
    required this.serverTime,
    required this.serverDate,
    required this.today,
    required this.monthlySummary,
    required this.shiftPolicy,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      serverTime: json['server_time'] as String? ?? '',
      serverDate: json['server_date'] as String? ?? '',
      today: TodayAttendance.fromJson(json['today'] as Map<String, dynamic>? ?? {}),
      monthlySummary: MonthlySummary.fromJson(json['monthly_summary'] as Map<String, dynamic>? ?? {}),
      shiftPolicy: ShiftPolicy.fromJson(json['shift_policy'] as Map<String, dynamic>?),
    );
  }
}
