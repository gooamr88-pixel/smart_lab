import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';

/// A styled quiz answer option tile with correct/wrong state
class QuizOptionTile extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final int correctIndex;
  final VoidCallback onTap;

  const QuizOptionTile({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.correctIndex,
    required this.onTap,
  });

  static const _optionLetters = ['A', 'B', 'C', 'D'];

  Color get _backgroundColor {
    if (!isAnswered) {
      return isSelected
          ? AppColors.primaryLight.withAlpha(20)
          : AppColors.surfaceLight;
    }
    if (index == correctIndex) return AppColors.success.withAlpha(25);
    if (isSelected && !isCorrect) return AppColors.danger.withAlpha(25);
    return AppColors.surfaceLight;
  }

  Color get _borderColor {
    if (!isAnswered) {
      return isSelected ? AppColors.primaryLight : Colors.transparent;
    }
    if (index == correctIndex) return AppColors.success;
    if (isSelected && !isCorrect) return AppColors.danger;
    return Colors.transparent;
  }

  Color get _letterBgColor {
    if (!isAnswered) {
      return isSelected
          ? AppColors.primaryLight.withAlpha(40)
          : Colors.white.withAlpha(10);
    }
    if (index == correctIndex) return AppColors.success.withAlpha(50);
    if (isSelected && !isCorrect) return AppColors.danger.withAlpha(50);
    return Colors.white.withAlpha(10);
  }

  IconData? get _trailingIcon {
    if (!isAnswered) return null;
    if (index == correctIndex) return Icons.check_circle_rounded;
    if (isSelected && !isCorrect) return Icons.cancel_rounded;
    return null;
  }

  Color get _trailingColor {
    if (index == correctIndex) return AppColors.success;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Option letter
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _letterBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  index < _optionLetters.length ? _optionLetters[index] : '?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Option text
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),

            // Result icon
            if (_trailingIcon != null)
              Icon(_trailingIcon, color: _trailingColor, size: 24),
          ],
        ),
      ),
    );
  }
}
