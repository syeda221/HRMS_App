import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'present':
        bg = AppColors.statusPresentBg;
        fg = AppColors.statusPresent;
        label = 'Present';
        break;
      case 'late':
        bg = AppColors.statusLateBg;
        fg = AppColors.statusLate;
        label = 'Late';
        break;
      case 'absent':
        bg = AppColors.statusAbsentBg;
        fg = AppColors.statusAbsent;
        label = 'Absent';
        break;
      case 'holiday':
        bg = AppColors.statusHolidayBg;
        fg = AppColors.statusHoliday;
        label = 'Holiday';
        break;
      case 'checked_in':
        bg = AppColors.accentLimeLight;
        fg = AppColors.primary;
        label = 'Checked In';
        break;
      case 'checked_out':
        bg = AppColors.statusPresentBg;
        fg = AppColors.statusPresent;
        label = 'Completed';
        break;
      default:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
        label = status.isEmpty ? 'Pending' : status;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999), // Pill shape
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
