import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../attendance/providers/attendance_provider.dart';

class QrScannerScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const QrScannerScreen({super.key, this.onNavigateTab});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final token = barcode.rawValue!.trim();
    _handleQrPayload(token);
  }

  void _handleQrPayload(String token) async {
    setState(() => _isProcessing = true);

    final provider = context.read<AttendanceProvider>();
    final result = await provider.scanQr(token);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: result['success'] == true
                    ? AppColors.statusPresentBg
                    : AppColors.statusAbsentBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                result['success'] == true
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                size: 48,
                color: result['success'] == true
                    ? AppColors.statusPresent
                    : AppColors.statusAbsent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result['success'] == true
                  ? (result['type'] == 'check_out' ? 'Check-Out Recorded!' : 'Check-In Recorded!')
                  : 'Scan Failed',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              result['message'] as String? ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _isProcessing = false);
                if (result['success'] == true && widget.onNavigateTab != null) {
                  widget.onNavigateTab!(0); // return to dashboard
                }
              },
              child: const Text('Back to Dashboard', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Dark overlay with transparent center viewfinder
          SafeArea(
            child: Column(
              children: [
                // Top App Bar Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () {
                          if (widget.onNavigateTab != null) widget.onNavigateTab!(0);
                        },
                      ),
                      const Text(
                        'Scan Office QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
                        onPressed: () => _controller.toggleTorch(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Electric Lime Viewfinder Reticle (Matching Stitch "Scan QR Code")
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.accentLime, width: 3),
                    ),
                    child: Stack(
                      children: [
                        // Animated Scanning reticle glow
                        Center(
                          child: Container(
                            width: 230,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.accentLime,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentLime.withOpacity(0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Align the office QR code within the frame',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.schedule_rounded, size: 13, color: AppColors.accentLime),
                      SizedBox(width: 6),
                      Text(
                        'Shift: 09:00 AM - 06:00 PM  •  Late after 09:15 AM',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Developer / Testing Mock Scan Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                    icon: const Icon(Icons.touch_app_rounded, color: AppColors.accentLime),
                    label: const Text(
                      'Test Scan Office QR (Mock)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () => _handleQrPayload('STITCH-OFFICE-HQ-2026'),
                  ),
                ),
                const SizedBox(height: 70), // room for floating nav
              ],
            ),
          ),
        ],
      ),
    );
  }
}
