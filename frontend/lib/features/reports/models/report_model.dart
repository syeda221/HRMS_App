class MonthlyReport {
  final String month;
  final String monthName;
  final double attendanceRate;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final int holidays;
  final double totalHours;
  final double averageHoursPerDay;

  MonthlyReport({
    required this.month,
    required this.monthName,
    required this.attendanceRate,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.holidays,
    required this.totalHours,
    required this.averageHoursPerDay,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      month: json['month'] as String? ?? '',
      monthName: json['month_name'] as String? ?? '',
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 100.0,
      presentDays: json['present_days'] as int? ?? 0,
      lateDays: json['late_days'] as int? ?? 0,
      absentDays: json['absent_days'] as int? ?? 0,
      holidays: json['holidays'] as int? ?? 0,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
      averageHoursPerDay: (json['average_hours_per_day'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
