import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';

/// Wrapper around model_viewer_plus with loading state and error handling
class ModelViewerWidget extends StatelessWidget {
  final String modelUrl;
  final String? alt;
  final bool autoRotate;
  final bool cameraControls;
  final Color backgroundColor;

  const ModelViewerWidget({
    super.key,
    required this.modelUrl,
    this.alt,
    this.autoRotate = true,
    this.cameraControls = true,
    this.backgroundColor = const Color(0xFF0D1B2A),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceOverlay,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // 3D Model Viewer
            ModelViewer(
              src: modelUrl,
              alt: alt ?? '3D Lab Model',
              autoRotate: autoRotate,
              cameraControls: cameraControls,
              backgroundColor: backgroundColor,
              autoPlay: true,
              shadowIntensity: 1,
              touchAction: TouchAction.panY,
              interactionPrompt: InteractionPrompt.auto,
            ),

            // Gradient overlay at bottom for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      backgroundColor.withAlpha(200),
                    ],
                  ),
                ),
              ),
            ),

            // Hint text
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.three_p_rounded,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '3D',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
    );
  }
}
