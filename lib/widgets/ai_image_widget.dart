import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/app_constants.dart';
import '../providers/image_gen_provider.dart';

/// A widget that displays an AI-generated image with loading shimmer,
/// error fallback, and smooth fade-in transition.
class AiImageWidget extends StatefulWidget {
  /// Unique key for caching (e.g., 'welcome', 'chemistry')
  final String imageKey;

  /// The text prompt to the image generation API
  final String prompt;

  /// Widget to show as fallback if image generation fails
  final Widget? fallback;

  /// How the image should be fitted
  final BoxFit fit;

  /// Border radius for clipping
  final BorderRadius? borderRadius;

  /// Overlay gradient for text readability
  final bool showOverlay;

  /// Height constraint
  final double? height;

  /// Width constraint
  final double? width;

  const AiImageWidget({
    super.key,
    required this.imageKey,
    required this.prompt,
    this.fallback,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showOverlay = true,
    this.height,
    this.width,
  });

  @override
  State<AiImageWidget> createState() => _AiImageWidgetState();
}

class _AiImageWidgetState extends State<AiImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Trigger image generation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ImageGenProvider>()
          .generateImage(widget.imageKey, widget.prompt);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ImageGenProvider>();
    final imageBytes = imageProvider.getImage(widget.imageKey);
    final isLoading = imageProvider.isLoading(widget.imageKey);

    // Trigger fade-in when image arrives
    if (imageBytes != null && !_fadeController.isCompleted) {
      _fadeController.forward();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: widget.height,
        width: widget.width ?? double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Shimmer loading placeholder
            if (isLoading && imageBytes == null) _buildShimmer(),

            // Layer 2: Fallback gradient (always visible behind image)
            if (imageBytes == null && !isLoading)
              widget.fallback ?? _buildFallbackGradient(),

            // Layer 3: AI-generated image with fade-in
            if (imageBytes != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.memory(
                  imageBytes,
                  fit: widget.fit,
                  width: double.infinity,
                  height: double.infinity,
                  gaplessPlayback: true,
                ),
              ),

            // Layer 4: Dark overlay for text readability
            if (widget.showOverlay)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(100),
                      Colors.black.withAlpha(160),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surfaceCard,
      child: Container(
        color: AppColors.surfaceLight,
      ),
    );
  }

  Widget _buildFallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryMid],
        ),
      ),
    );
  }
}

/// A compact version for card backgrounds
class AiCardBackground extends StatelessWidget {
  final String imageKey;
  final String prompt;
  final Widget child;
  final BorderRadius borderRadius;

  const AiCardBackground({
    super.key,
    required this.imageKey,
    required this.prompt,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AiImageWidget(
            imageKey: imageKey,
            prompt: prompt,
            borderRadius: borderRadius,
            showOverlay: true,
          ),
        ),
        child,
      ],
    );
  }
}
