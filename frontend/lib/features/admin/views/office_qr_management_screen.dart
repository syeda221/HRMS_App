import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/admin_provider.dart';

class OfficeQrManagementScreen extends StatefulWidget {
  const OfficeQrManagementScreen({super.key});

  @override
  State<OfficeQrManagementScreen> createState() => _OfficeQrManagementScreenState();
}

class _OfficeQrManagementScreenState extends State<OfficeQrManagementScreen> {
  int _selectedRadius = 150;
  bool _enforceGeofence = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      await provider.loadOfficeQr();
      if (provider.officeQr != null) {
        setState(() {
          _selectedRadius = provider.officeQr!.radiusMeters;
        });
      }
    });
  }

  void _regenerateKey() async {
    final provider = context.read<AdminProvider>();
    final success = await provider.regenerateOfficeQr();
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dynamic QR code regenerated! Kiosks updated in real-time.'),
          backgroundColor: Color(0xFF063B2B),
        ),
      );
    }
  }

  void _saveGeofence() async {
    final provider = context.read<AdminProvider>();
    final success = await provider.updateGeofence(_selectedRadius);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geofence updated to ${_selectedRadius}m radius!'),
          backgroundColor: const Color(0xFF063B2B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final office = provider.officeQr;
    final qrPayload = office?.qrPayload ?? 'HRMS-HQ-DEFAULT-KIOSK';

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
              child: const Icon(Icons.qr_code_2, color: Color(0xFFB8E83D), size: 20),
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
                  'Office QR & Geofence',
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
            onPressed: () => provider.loadOfficeQr(),
          ),
        ],
      ),
      body: provider.isLoading && office == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF063B2B)))
          : RefreshIndicator(
              onRefresh: () => provider.loadOfficeQr(),
              color: const Color(0xFF063B2B),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Status Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Office Lobby QR & Geofence',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002418),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8E83D).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Color(0xFF4D6700)),
                            SizedBox(width: 6),
                            Text(
                              'Live & Active',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4D6700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage reception check-in posters, rotation tokens, and spatial perimeter.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF717974)),
                  ),
                  const SizedBox(height: 16),

                  // Printable Poster Graphic Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE1E3E0)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.assignment, size: 18, color: Color(0xFF063B2B)),
                                SizedBox(width: 6),
                                Text(
                                  'Lobby Reception Poster',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'READY TO PRINT',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF717974)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Realistic Printable Poster Design (Verdant Forest green)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF063B2B),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF063B2B).withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 14, color: Color(0xFFB8E83D)),
                                    SizedBox(width: 6),
                                    Text(
                                      'QR ATTENDANCE • HEAD OFFICE LOBBY',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: Color(0xFFB8E83D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Fast Check-in Terminal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // White QR Box
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: qrPayload,
                                  version: QrVersions.auto,
                                  size: 180.0,
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
                              const SizedBox(height: 14),

                              const Text(
                                'Open your QR Attendance app & scan this code upon arrival to register attendance.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFB8E83D),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock, size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Token: ${office?.qrSecretKey ?? "SECURE-HQ"}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('A4 Printable Poster prepared & sent to printer/PDF!'),
                                      backgroundColor: Color(0xFF063B2B),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.print, size: 18),
                                label: const Text('Print Poster (PDF)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF063B2B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _regenerateKey,
                                icon: const Icon(Icons.security_update_good, size: 18, color: Color(0xFF063B2B)),
                                label: const Text('Rotate QR Token', style: TextStyle(color: Color(0xFF063B2B))),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Spatial Geofence Perimeter Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE1E3E0)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.radar, size: 18, color: Color(0xFF063B2B)),
                                SizedBox(width: 6),
                                Text(
                                  'Spatial Security & Geofence',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF002418)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC0F045).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_selectedRadius m Perimeter',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4D6700)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Radar Simulation Graphic
                        Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFB8E83D), width: 2),
                                    color: const Color(0xFFB8E83D).withOpacity(0.12),
                                  ),
                                ),
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF063B2B).withOpacity(0.3)),
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF063B2B),
                                  ),
                                  child: const Icon(Icons.corporate_fare, color: Color(0xFFB8E83D), size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Radius Selector Buttons
                        const Text('Geofence Radius Window', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [50, 100, 150].map((r) {
                            final isSel = _selectedRadius == r;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text('$r Meters'),
                                  selected: isSel,
                                  onSelected: (val) {
                                    setState(() => _selectedRadius = r);
                                  },
                                  selectedColor: const Color(0xFF063B2B),
                                  labelStyle: TextStyle(
                                    color: isSel ? Colors.white : const Color(0xFF002418),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Strict Enforcement Toggle
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enforce Strict Geofence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Reject scan if employee GPS is outside perimeter', style: TextStyle(fontSize: 11)),
                          value: _enforceGeofence,
                          activeColor: const Color(0xFF063B2B),
                          onChanged: (val) => setState(() => _enforceGeofence = val),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _saveGeofence,
                            icon: const Icon(Icons.save, size: 18, color: Color(0xFFB8E83D)),
                            label: const Text('Update Security & Geofence'),
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

                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }
}
