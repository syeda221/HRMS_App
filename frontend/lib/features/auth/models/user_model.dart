class UserModel {
  final int id;
  final String employeeCode;
  final String name;
  final String email;
  final String? phone;
  final String department;
  final String designation;
  final String joiningDate;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    this.phone,
    required this.department,
    required this.designation,
    required this.joiningDate,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      employeeCode: json['employee_code'] as String? ?? 'N/A',
      name: json['name'] as String? ?? 'Employee',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      department: json['department'] as String? ?? 'General',
      designation: json['designation'] as String? ?? 'Staff Member',
      joiningDate: json['joining_date'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'designation': designation,
      'joining_date': joiningDate,
      'avatar_url': avatarUrl,
    };
  }
}
