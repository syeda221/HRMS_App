class PayrollResponse {
  final String month;
  final PayrollSummary summary;
  final List<PayrollItem> payrolls;

  PayrollResponse({
    required this.month,
    required this.summary,
    required this.payrolls,
  });

  factory PayrollResponse.fromJson(Map<String, dynamic> json) {
    return PayrollResponse(
      month: json['month'] ?? '',
      summary: PayrollSummary.fromJson(json['summary'] ?? {}),
      payrolls: (json['payrolls'] as List? ?? [])
          .map((p) => PayrollItem.fromJson(p))
          .toList(),
    );
  }
}

class PayrollSummary {
  final double totalPayroll;
  final double totalDisbursed;
  final double totalPending;
  final double totalDeductions;
  final int paidCount;
  final int pendingCount;

  PayrollSummary({
    required this.totalPayroll,
    required this.totalDisbursed,
    required this.totalPending,
    required this.totalDeductions,
    required this.paidCount,
    required this.pendingCount,
  });

  factory PayrollSummary.fromJson(Map<String, dynamic> json) {
    return PayrollSummary(
      totalPayroll: (json['total_payroll'] as num?)?.toDouble() ?? 0.0,
      totalDisbursed: (json['total_disbursed'] as num?)?.toDouble() ?? 0.0,
      totalPending: (json['total_pending'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0.0,
      paidCount: json['paid_count'] ?? 0,
      pendingCount: json['pending_count'] ?? 0,
    );
  }
}

class PayrollItem {
  final int id;
  final int userId;
  final String employeeCode;
  final String name;
  final String avatarUrl;
  final String department;
  final String designation;
  final String month;
  final double basicSalary;
  final double allowances;
  final double deductions;
  final double netSalary;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final String status;
  final String? paymentDate;
  final String paymentMethod;
  final String? notes;

  PayrollItem({
    required this.id,
    required this.userId,
    required this.employeeCode,
    required this.name,
    required this.avatarUrl,
    required this.department,
    required this.designation,
    required this.month,
    required this.basicSalary,
    required this.allowances,
    required this.deductions,
    required this.netSalary,
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.status,
    this.paymentDate,
    required this.paymentMethod,
    this.notes,
  });

  factory PayrollItem.fromJson(Map<String, dynamic> json) {
    return PayrollItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      employeeCode: json['employee_code'] ?? 'EMP-000',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      department: json['department'] ?? 'General',
      designation: json['designation'] ?? 'Staff',
      month: json['month'] ?? '',
      basicSalary: (json['basic_salary'] as num?)?.toDouble() ?? 0.0,
      allowances: (json['allowances'] as num?)?.toDouble() ?? 0.0,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0.0,
      netSalary: (json['net_salary'] as num?)?.toDouble() ?? 0.0,
      presentDays: json['present_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      status: json['status'] ?? 'pending',
      paymentDate: json['payment_date'],
      paymentMethod: json['payment_method'] ?? 'Direct Bank Transfer',
      notes: json['notes'],
    );
  }
}
