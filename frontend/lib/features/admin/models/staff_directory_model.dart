class StaffDirectoryResponse {
  final int totalStaff;
  final int activeCount;
  final List<StaffMemberItem> employees;
  final List<DepartmentOption> departments;
  final List<ShiftOption> shifts;
  final List<DesignationOption> designations;

  StaffDirectoryResponse({
    required this.totalStaff,
    required this.activeCount,
    required this.employees,
    required this.departments,
    required this.shifts,
    required this.designations,
  });

  factory StaffDirectoryResponse.fromJson(Map<String, dynamic> json) {
    return StaffDirectoryResponse(
      totalStaff: json['total_staff'] ?? 0,
      activeCount: json['active_count'] ?? 0,
      employees: (json['employees'] as List? ?? [])
          .map((e) => StaffMemberItem.fromJson(e))
          .toList(),
      departments: (json['departments'] as List? ?? [])
          .map((e) => DepartmentOption.fromJson(e))
          .toList(),
      shifts: (json['shifts'] as List? ?? [])
          .map((e) => ShiftOption.fromJson(e))
          .toList(),
      designations: (json['designations'] as List? ?? [])
          .map((e) => DesignationOption.fromJson(e))
          .toList(),
    );
  }
}

class StaffMemberItem {
  final int id;
  final String employeeCode;
  final String name;
  final String email;
  final String phone;
  final String emergencyContact;
  final String avatarUrl;
  final String departmentName;
  final String designationTitle;
  final String shiftName;
  final String shiftTiming;
  final double basicSalary;
  final String status;
  final String joiningDate;
  final String todayStatus;
  final String? todayCheckIn;

  StaffMemberItem({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.emergencyContact,
    required this.avatarUrl,
    required this.departmentName,
    required this.designationTitle,
    required this.shiftName,
    required this.shiftTiming,
    required this.basicSalary,
    required this.status,
    required this.joiningDate,
    required this.todayStatus,
    this.todayCheckIn,
  });

  factory StaffMemberItem.fromJson(Map<String, dynamic> json) {
    final dept = json['department'] as Map<String, dynamic>?;
    final desig = json['designation'] as Map<String, dynamic>?;
    final shift = json['shift'] as Map<String, dynamic>?;

    String shiftTiming = '09:00 - 18:00';
    if (shift != null && shift['start_time'] != null && shift['end_time'] != null) {
      shiftTiming = '${shift['start_time']} - ${shift['end_time']}';
    }

    return StaffMemberItem(
      id: json['id'] ?? 0,
      employeeCode: json['employee_code'] ?? 'EMP-000',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      departmentName: dept?['name'] ?? 'General',
      designationTitle: desig?['title'] ?? 'Staff',
      shiftName: shift?['name'] ?? 'Standard Shift',
      shiftTiming: shiftTiming,
      basicSalary: (json['basic_salary'] as num?)?.toDouble() ?? 50000.0,
      status: json['status'] ?? 'active',
      joiningDate: json['joining_date'] ?? '',
      todayStatus: json['today_status'] ?? 'absent',
      todayCheckIn: json['today_check_in'],
    );
  }
}

class DepartmentOption {
  final int id;
  final String name;
  final String code;

  DepartmentOption({required this.id, required this.name, required this.code});

  factory DepartmentOption.fromJson(Map<String, dynamic> json) {
    return DepartmentOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class ShiftOption {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final int gracePeriodMins;

  ShiftOption({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriodMins,
  });

  factory ShiftOption.fromJson(Map<String, dynamic> json) {
    return ShiftOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startTime: (json['start_time'] ?? '09:00').toString().substring(0, 5),
      endTime: (json['end_time'] ?? '18:00').toString().substring(0, 5),
      gracePeriodMins: json['grace_period_mins'] ?? 15,
    );
  }
}

class DesignationOption {
  final int id;
  final String title;
  final int? departmentId;

  DesignationOption({required this.id, required this.title, this.departmentId});

  factory DesignationOption.fromJson(Map<String, dynamic> json) {
    return DesignationOption(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      departmentId: json['department_id'],
    );
  }
}
