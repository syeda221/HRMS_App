import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/payroll_model.dart';
import '../providers/admin_provider.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final NumberFormat _curr = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);
  bool _rulesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPayroll();
    });
  }

  void _showSalarySlipModal(PayrollItem p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OFFICIAL SALARY SLIP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Color(0xFF4D6700),
                      ),
                    ),
                    Text(
                      p.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                    ),
                    Text('${p.designation} • ${p.employeeCode}', style: const TextStyle(fontSize: 12, color: Color(0xFF717974))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.status == 'paid'
                        ? const Color(0xFFC0F045).withOpacity(0.3)
                        : const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: p.status == 'paid' ? const Color(0xFF4D6700) : const Color(0xFF93000A),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text('Month: November 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildSlipRow('Basic Monthly Salary', _curr.format(p.basicSalary)),
            _buildSlipRow('Allowances & Per Diem', '+ ${_curr.format(p.allowances)}', isCredit: true),
            _buildSlipRow('Attendance Deductions', '- ${_curr.format(p.deductions)}', isDebit: p.deductions > 0),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Salary Payable', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  _curr.format(p.netSalary),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF063B2B)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, size: 16, color: Color(0xFF063B2B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment Method: ${p.paymentMethod} (Verified)',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF717974)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 10),
                if (p.status != 'paid')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final provider = context.read<AdminProvider>();
                        final success = await provider.updatePayrollStatus(p.id, 'paid');
                        if (mounted) {
                          Navigator.pop(ctx);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Disbursement recorded for ${p.name}!'),
                                backgroundColor: const Color(0xFF063B2B),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark Paid'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF063B2B),
                        foregroundColor: const Color(0xFFB8E83D),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSlipRow(String label, String value, {bool isCredit = false, bool isDebit = false}) {
    Color col = const Color(0xFF002418);
    if (isCredit) col = const Color(0xFF4D6700);
    if (isDebit) col = const Color(0xFFBA1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF717974))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: col)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final data = provider.payrollData;
    final summary = data?.summary;

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
              child: const Icon(Icons.payments, color: Color(0xFFB8E83D), size: 20),
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
                  'Payroll & Salaries',
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
            onPressed: () => provider.loadPayroll(),
          ),
        ],
      ),
      body: provider.isLoading && data == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF063B2B)))
          : RefreshIndicator(
              onRefresh: () => provider.loadPayroll(),
              color: const Color(0xFF063B2B),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Title & Tag
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
                            Icon(Icons.verified, size: 12, color: Color(0xFF4D6700)),
                            SizedBox(width: 4),
                            Text(
                              'QR BIOMETRIC LEDGER',
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
                    'Payroll & Salary Calculation',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002418),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Automated salary disbursements based on verified QR attendance records.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF717974)),
                  ),
                  const SizedBox(height: 16),

                  // Financial Overview Bento Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE1E3E0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_month, size: 18, color: Color(0xFF063B2B)),
                                SizedBox(width: 6),
                                Text(
                                  'November 2026',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8E83D).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Active Cycle',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4D6700)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Payroll', style: TextStyle(fontSize: 11, color: Color(0xFF717974))),
                                    const SizedBox(height: 4),
                                    Text(
                                      _curr.format(summary?.totalPayroll ?? 0),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF002418),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${summary?.paidCount ?? 0} Paid • ${summary?.pendingCount ?? 0} Pending',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF4D6700), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Deductions', style: TextStyle(fontSize: 11, color: Color(0xFF717974))),
                                    const SizedBox(height: 4),
                                    Text(
                                      _curr.format(summary?.totalDeductions ?? 0),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFBA1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Late penalties & leaves',
                                      style: TextStyle(fontSize: 10, color: Color(0xFF717974)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 1-Click Run / Finalize CTA
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final success = await provider.generatePayroll();
                              if (mounted && success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Payroll calculated & recalculated successfully!'),
                                    backgroundColor: Color(0xFF063B2B),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle, size: 18, color: Color(0xFFB8E83D)),
                            label: const Text('1-Click Recalculate & Sync Payroll'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF063B2B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Collapsible Deduction Rules
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE1E3E0)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () => setState(() => _rulesExpanded = !_rulesExpanded),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.rule, color: Color(0xFF063B2B), size: 20),
                          ),
                          title: const Text(
                            'Deduction Logic Active',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('3 core rules applied from attendance', style: TextStyle(fontSize: 11)),
                          trailing: Icon(
                            _rulesExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color(0xFF063B2B),
                          ),
                        ),
                        if (_rulesExpanded)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                            child: Column(
                              children: [
                                _buildRuleTile('3 Late Arrivals', '0.5 Day basic deduction', Icons.alarm_off, isPenalty: true),
                                const SizedBox(height: 6),
                                _buildRuleTile('Unexcused Absent', '1.0 Day basic deduction', Icons.event_busy, isPenalty: true),
                                const SizedBox(height: 6),
                                _buildRuleTile('Overtime Hours', '1.25x Hourly credit added', Icons.more_time, isPenalty: false),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Staff Salary Breakdown Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Staff Salary Breakdown (${data?.payrolls.length ?? 0})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002418),
                        ),
                      ),
                      const Text('Audit Verified', style: TextStyle(fontSize: 12, color: Color(0xFF4D6700), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Salary Cards
                  if (data != null && data.payrolls.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: Text('No payroll records found.')),
                    )
                  else if (data != null)
                    ...data.payrolls.map((p) => _buildPayrollCard(p)),

                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildRuleTile(String title, String subtitle, IconData icon, {required bool isPenalty}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isPenalty ? const Color(0xFFBA1A1A) : const Color(0xFF4D6700)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPenalty ? const Color(0xFFBA1A1A) : const Color(0xFF4D6700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCard(PayrollItem p) {
    final isPaid = p.status == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E3E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF063B2B),
                    backgroundImage: p.avatarUrl.isNotEmpty ? NetworkImage(p.avatarUrl) : null,
                    child: p.avatarUrl.isEmpty
                        ? Text(
                            p.name.isNotEmpty ? p.name[0] : 'U',
                            style: const TextStyle(color: Color(0xFFB8E83D), fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.employeeCode,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF063B2B)),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${p.department} • ${p.designation}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF717974)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFC0F045).withOpacity(0.3) : const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPaid ? 'Approved & Paid' : 'Pending Review',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? const Color(0xFF4D6700) : const Color(0xFF93000A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Attendance Summary Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Present: ${p.presentDays}d', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text(
                  'Late: ${p.lateDays}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: p.lateDays > 0 ? const Color(0xFFE28A00) : const Color(0xFF717974),
                  ),
                ),
                Text(
                  'Absent: ${p.absentDays}d',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: p.absentDays > 0 ? const Color(0xFFBA1A1A) : const Color(0xFF717974),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Financial Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NET PAYABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF717974))),
                  Text(
                    _curr.format(p.netSalary),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                  ),
                ],
              ),
              Row(
                children: [
                  if (p.deductions > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '- ${_curr.format(p.deductions)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A)),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.receipt_long, color: Color(0xFF063B2B)),
                    onPressed: () => _showSalarySlipModal(p),
                    tooltip: 'View Salary Slip & Details',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
