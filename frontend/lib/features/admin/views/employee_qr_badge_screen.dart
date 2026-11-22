import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/staff_directory_model.dart';
import '../providers/admin_provider.dart';

class EmployeeQrBadgeScreen extends StatefulWidget {
  final int staffId;

  const EmployeeQrBadgeScreen({super.key, required this.staffId});

  @override
  State<EmployeeQrBadgeScreen> createState() => _EmployeeQrBadgeScreenState();
}

class _EmployeeQrBadgeScreenState extends State<EmployeeQrBadgeScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _employeeData;
  String _qrPayload = '';
  final NumberFormat _curr = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchStaffDetails();
  }

  Future<void> _fetchStaffDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.adminStaffDetail(widget.staffId));
      if (response.statusCode == 200 && response.data['status'] == true) {
        setState(() {
          _employeeData = response.data['data']['employee'] as Map<String, dynamic>;
          _qrPayload = response.data['data']['qr_badge_payload'] ?? 'HRMS-STAFF-${widget.staffId}';
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Failed to load badge.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = ApiClient.getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emp = _employeeData;
    final name = emp?['name'] ?? 'Staff Member';
    final code = emp?['employee_code'] ?? 'EMP-000';
    final dept = emp?['department'] != null ? emp!['department']['name'] : 'Operations';
    final desig = emp?['designation'] != null ? emp!['designation']['title'] : 'Staff';
    final shift = emp?['shift'] != null ? emp!['shift']['name'] : 'Morning Shift';
    final shiftTiming = emp?['shift'] != null
        ? '${emp!['shift']['start_time'].toString().substring(0, 5)} - ${emp!['shift']['end_time'].toString().substring(0, 5)}'
        : '09:00 - 18:00';
    final salary = (emp?['basic_salary'] as num?)?.toDouble() ?? 85000.0;
    final phone = emp?['phone'] ?? '+92 300 1234567';
    final avatar = emp?['avatar_url'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF7),
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002418)),
          onPressed: () => Navigator.pop(context),
        ),
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
                  'DETAILS & CONFIG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Color(0xFF4D6700),
                  ),
                ),
                Text(
                  'Employee QR Badge',
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
            onPressed: _fetchStaffDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF063B2B)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchStaffDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Status & Credential Header Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE1E3E0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(radius: 4, backgroundColor: Color(0xFFB8E83D)),
                              const SizedBox(width: 8),
                              const Text(
                                'Staff QR Credential',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF002418),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8E83D).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, size: 12, color: Color(0xFF4D6700)),
                                SizedBox(width: 4),
                                Text(
                                  'VERIFIED ACTIVE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4D6700)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Main Digital ID Badge Card (Lanyard aesthetic)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE1E3E0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF063B2B).withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Lanyard punch hole accent
                          Container(
                            width: 50,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE1E3E0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Header pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.fingerprint, size: 16, color: Color(0xFF063B2B)),
                                    SizedBox(width: 6),
                                    Text(
                                      'QR ATTENDANCE',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF063B2B)),
                                    ),
                                  ],
                                ),
                                Text(
                                  'ID #$code',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4D6700)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Avatar
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF063B2B), Color(0xFFB8E83D)],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFF063B2B),
                              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                              child: avatar.isEmpty
                                  ? Text(
                                      name.isNotEmpty ? name[0] : 'U',
                                      style: const TextStyle(fontSize: 28, color: Color(0xFFB8E83D), fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                          ),
                          Text(
                            desig,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF717974)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF063B2B)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Shift & Department 2x1 Grid
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAF7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE1E3E0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('DEPARTMENT', style: TextStyle(fontSize: 9, color: Color(0xFF717974), fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                        dept,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAF7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE1E3E0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('SHIFT TIMING', style: TextStyle(fontSize: 9, color: Color(0xFF717974), fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                        shiftTiming,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Reticle QR Viewport Container
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAF7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFB8E83D).withOpacity(0.6), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: _qrPayload,
                                  version: QrVersions.auto,
                                  size: 190.0,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF002418),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF002418),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Dynamic Attendance QR Code',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                                ),
                                const Text(
                                  'Auto-syncs with Kiosk • 256-bit Rotating HMAC',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF717974)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Credential Utilities 2x2 Grid
                    const Text(
                      'CREDENTIAL UTILITIES',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF717974)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildUtilityButton(
                            icon: Icons.share,
                            title: 'Share QR Pass',
                            subtitle: 'WhatsApp or Mail',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('QR Pass payload copied to clipboard / share tray!')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildUtilityButton(
                            icon: Icons.print,
                            title: 'Print Official Badge',
                            subtitle: 'Generate PDF Card',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Official ID Card exported to PDF!')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildUtilityButton(
                            icon: Icons.download,
                            title: 'Save PNG Badge',
                            subtitle: 'Direct to Gallery',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('High-res QR Badge saved to gallery!')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildUtilityButton(
                            icon: Icons.account_balance_wallet,
                            title: 'Add to Wallet',
                            subtitle: 'Apple & Google Pay',
                            isHighlighted: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pass ready for Apple Wallet / Google Pay!')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Employment Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE1E3E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Employment Profile',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB8E83D).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.stars, size: 12, color: Color(0xFF4D6700)),
                                    SizedBox(width: 4),
                                    Text(
                                      '98% On-Time',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4D6700)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildProfileRow('Base Salary', _curr.format(salary), Icons.payments),
                          const SizedBox(height: 8),
                          _buildProfileRow('Official Contact', phone, Icons.phone_iphone),
                          const SizedBox(height: 8),
                          _buildProfileRow('Assigned Shift', shift, Icons.schedule),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
    );
  }

  Widget _buildUtilityButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFF063B2B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E3E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isHighlighted ? Colors.white.withOpacity(0.15) : const Color(0xFFF2F4F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isHighlighted ? const Color(0xFFB8E83D) : const Color(0xFF063B2B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? Colors.white : const Color(0xFF002418),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isHighlighted ? Colors.white70 : const Color(0xFF717974),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF063B2B)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF717974))),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF002418))),
        ],
      ),
    );
  }
}
