class AttendanceDay {
  final String date;
  final int dayNumber;
  final String dayName;
  final bool isWeekend;
  final String status;
  final String? checkIn;
  final String? checkOut;
  final double totalHours;
  final String? note;

  AttendanceDay({
    required this.date,
    required this.dayNumber,
    required this.dayName,
    required this.isWeekend,
    required this.status,
    this.checkIn,
    this.checkOut,
    required this.totalHours,
    this.note,
  });

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    return AttendanceDay(
      date: json['date'] as String? ?? '',
      dayNumber: json['day_number'] as int? ?? 1,
      dayName: json['day_name'] as String? ?? '',
      isWeekend: json['is_weekend'] as bool? ?? false,
      status: json['status'] as String? ?? 'not_marked',
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
    );
  }
}

class HistoryItem {
  final int id;
  final String date;
  final String formattedDate;
  final String dayName;
  final String status;
  final String checkIn;
  final String checkOut;
  final String totalHours;
  final String? note;

  HistoryItem({
    required this.id,
    required this.date,
    required this.formattedDate,
    required this.dayName,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.totalHours,
    this.note,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      formattedDate: json['formatted_date'] as String? ?? '',
      dayName: json['day_name'] as String? ?? '',
      status: json['status'] as String? ?? 'not_marked',
      checkIn: json['check_in'] as String? ?? '--:--',
      checkOut: json['check_out'] as String? ?? '--:--',
      totalHours: json['total_hours'] as String? ?? '-',
      note: json['note'] as String?,
    );
  }
}
