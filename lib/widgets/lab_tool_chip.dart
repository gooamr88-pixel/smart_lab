import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';
import '../services/model_assets.dart';

/// A chip widget representing a lab tool with emoji icon and placed state
class LabToolChip extends StatelessWidget {
  final String toolName;
  final String reason;
  final bool isSelected;
  final bool isPlaced;
  final VoidCallback onTap;

  const LabToolChip({
    super.key,
    required this.toolName,
    required this.reason,
    this.isSelected = false,
    this.isPlaced = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = ModelAssets.getIconForTool(toolName);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withAlpha(30)
              : isPlaced
                  ? AppColors.success.withAlpha(20)
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : isPlaced
                    ? AppColors.success.withAlpha(100)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Name and reason
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toolName,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (reason.isNotEmpty)
                    Text(
                      reason,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Status icon
            if (isPlaced)
              const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            else
              Icon(
                Icons.touch_app_rounded,
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.textMuted,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
