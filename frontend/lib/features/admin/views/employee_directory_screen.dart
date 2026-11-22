import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/staff_directory_model.dart';
import '../providers/admin_provider.dart';
import 'employee_qr_badge_screen.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() => _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  int _activeSegment = 0; // 0: All Staff, 1: Register Staff
  final TextEditingController _searchController = TextEditingController();
  int? _selectedDeptFilter;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController(text: '75000');
  final _designationController = TextEditingController();
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  int? _selectedDeptId;
  int? _selectedShiftId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStaff();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _designationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AdminProvider>().loadStaff(
          search: query,
          departmentId: _selectedDeptFilter,
        );
  }

  void _showQrModal(StaffMemberItem staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildBadgeModal(staff),
    );
  }

  Widget _buildBadgeModal(StaffMemberItem staff) {
    final qrData = 'HRMS-STAFF-${staff.employeeCode}-${staff.id}';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Verified badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFB8E83D).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: Color(0xFF063B2B), size: 30),
          ),
          const SizedBox(height: 8),
          const Text(
            'VERDANT NFC & QR PASS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF4D6700),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            staff.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002418),
            ),
          ),
          Text(
            '${staff.designationTitle} • ${staff.employeeCode}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF717974)),
          ),
          const SizedBox(height: 16),
          // QR code in reticle box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC0C9C2).withOpacity(0.4)),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 160.0,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF002418),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF002418),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SHIFT: ${staff.shiftTiming}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF063B2B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Color(0xFF063B2B))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeQrBadgeScreen(staffId: staff.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.badge, size: 18),
                  label: const Text('Full Badge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF063B2B),
                    foregroundColor: const Color(0xFFB8E83D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _submitRegisterForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AdminProvider>();
    final salary = double.tryParse(_salaryController.text.trim()) ?? 50000.0;

    final success = await provider.addStaff({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'basic_salary': salary,
      'password': _passwordController.text.trim(),
      'department_id': _selectedDeptId,
      'shift_id': _selectedShiftId,
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee registered successfully! QR badge generated.'),
            backgroundColor: Color(0xFF063B2B),
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        setState(() {
          _activeSegment = 0; // Switch to list
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Registration failed.'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final dir = provider.staffDirectory;

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
              child: const Icon(Icons.badge, color: Color(0xFFB8E83D), size: 20),
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
                  'Employee Directory',
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
            onPressed: () => provider.loadStaff(),
          ),
        ],
      ),
      body: provider.isLoading && dir == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF063B2B)))
          : RefreshIndicator(
              onRefresh: () => provider.loadStaff(),
              color: const Color(0xFF063B2B),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Subtitle & Status Chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0F045).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Color(0xFF4D6700)),
                            SizedBox(width: 6),
                            Text(
                              'HR ROSTER • ACTIVE SYNC',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4D6700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Staff Directory & Registration',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002418),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Manage active team members or onboard new staff effortlessly.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF717974)),
                  ),
                  const SizedBox(height: 16),

                  // Segmented Switcher (All Staff vs Register New Staff)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E9E6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeSegment = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeSegment == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _activeSegment == 0
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group,
                                    size: 18,
                                    color: _activeSegment == 0 ? const Color(0xFF002418) : const Color(0xFF717974),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'All Staff (${dir?.totalStaff ?? 0})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: _activeSegment == 0 ? FontWeight.bold : FontWeight.w500,
                                      color: _activeSegment == 0 ? const Color(0xFF002418) : const Color(0xFF717974),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeSegment = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _activeSegment == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _activeSegment == 1
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_add,
                                    size: 18,
                                    color: _activeSegment == 1 ? const Color(0xFF002418) : const Color(0xFF717974),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Register Staff',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: _activeSegment == 1 ? FontWeight.bold : FontWeight.w500,
                                      color: _activeSegment == 1 ? const Color(0xFF002418) : const Color(0xFF717974),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2 Quick Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE1E3E0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Onboarded MTD', style: TextStyle(fontSize: 12, color: Color(0xFF717974))),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB8E83D).withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.verified, size: 14, color: Color(0xFF063B2B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${dir?.totalStaff ?? 0}',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF002418),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4D6700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE1E3E0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('QR Tokens Live', style: TextStyle(fontSize: 12, color: Color(0xFF717974))),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF063B2B).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.qr_code_2, size: 14, color: Color(0xFF063B2B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '100%',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF002418),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'encrypted',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF063B2B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Content based on Active Segment
                  if (_activeSegment == 0) ...[
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search staff by name or EMP-ID...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF717974)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE1E3E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE1E3E0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Department Filter Chips
                    if (dir != null && dir.departments.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('All Departments'),
                              selected: _selectedDeptFilter == null,
                              onSelected: (selected) {
                                setState(() => _selectedDeptFilter = null);
                                provider.loadStaff(search: _searchController.text.trim());
                              },
                              selectedColor: const Color(0xFF063B2B),
                              labelStyle: TextStyle(
                                color: _selectedDeptFilter == null ? Colors.white : const Color(0xFF002418),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ...dir.departments.map(
                              (dept) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(dept.name),
                                  selected: _selectedDeptFilter == dept.id,
                                  onSelected: (selected) {
                                    setState(() => _selectedDeptFilter = selected ? dept.id : null);
                                    provider.loadStaff(
                                      search: _searchController.text.trim(),
                                      departmentId: _selectedDeptFilter,
                                    );
                                  },
                                  selectedColor: const Color(0xFF063B2B),
                                  labelStyle: TextStyle(
                                    color: _selectedDeptFilter == dept.id ? Colors.white : const Color(0xFF002418),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Employee Cards List
                    if (dir != null && dir.employees.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No staff members found.',
                            style: TextStyle(color: Color(0xFF717974)),
                          ),
                        ),
                      )
                    else if (dir != null)
                      ...dir.employees.map((emp) => _buildEmployeeCard(emp)),
                  ] else ...[
                    // Register New Staff Form (Stitch layout)
                    _buildRegistrationForm(dir),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildEmployeeCard(StaffMemberItem emp) {
    Color statusColor;
    String statusText;
    if (emp.todayStatus == 'present') {
      statusColor = const Color(0xFF4D6700);
      statusText = emp.todayCheckIn != null ? 'In: ${emp.todayCheckIn}' : 'Present';
    } else if (emp.todayStatus == 'late') {
      statusColor = const Color(0xFFE28A00);
      statusText = emp.todayCheckIn != null ? 'Late: ${emp.todayCheckIn}' : 'Late';
    } else {
      statusColor = const Color(0xFFBA1A1A);
      statusText = 'Absent';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E3E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              emp.avatarUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: const Color(0xFF063B2B),
                child: Center(
                  child: Text(
                    emp.name.isNotEmpty ? emp.name[0] : 'U',
                    style: const TextStyle(color: Color(0xFFB8E83D), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        emp.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002418),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        emp.employeeCode,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF063B2B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${emp.departmentName} • ${emp.designationTitle}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF717974)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      emp.shiftTiming,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF717974)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // QR Badge Button
          IconButton(
            onPressed: () => _showQrModal(emp),
            icon: const Icon(Icons.qr_code_2, color: Color(0xFF063B2B)),
            tooltip: 'View QR Pass',
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(StaffDirectoryResponse? dir) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E3E0)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF063B2B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.how_to_reg, color: Color(0xFFB8E83D), size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Employee Onboarding',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002418),
                      ),
                    ),
                    Text(
                      'Initializes digital badge & credentials.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF717974)),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE1E3E0)),

            // Name
            const Text('Full Legal Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Farhan Zaidi',
                prefixIcon: const Icon(Icons.person, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),

            // Email
            const Text('Work Email Address *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'e.g. farhan.z@company.com',
                prefixIcon: const Icon(Icons.email, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
            ),
            const SizedBox(height: 12),

            // Phone
            const Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'e.g. +92 300 1234567',
                prefixIcon: const Icon(Icons.phone, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Department & Shift Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Department', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _selectedDeptId,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        hint: const Text('Select Dept'),
                        items: (dir?.departments ?? []).map((d) {
                          return DropdownMenuItem<int>(
                            value: d.id,
                            child: Text(d.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedDeptId = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assigned Shift', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _selectedShiftId,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        hint: const Text('Select Shift'),
                        items: (dir?.shifts ?? []).map((s) {
                          return DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedShiftId = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Monthly Base Salary
            const Text('Base Monthly Salary (PKR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 85000',
                prefixIcon: const Icon(Icons.payments, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Temporary Password
            const Text('Temporary Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitRegisterForm,
                icon: const Icon(Icons.auto_awesome, color: Color(0xFFB8E83D)),
                label: const Text(
                  'Save Employee & Generate Badge',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF063B2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
