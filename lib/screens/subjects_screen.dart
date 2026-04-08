import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/image_gen_provider.dart';
import '../services/huggingface_service.dart';
import 'subject_roadmap_screen.dart';

/// Subject selection screen with AI-generated card backgrounds
class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimations = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(3, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeOutCubic),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _navigateToRoadmap(BuildContext context, {
    required String subject,
    required String emoji,
    required LinearGradient gradient,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SubjectRoadmapScreen(
          subject: subject,
          subjectEmoji: emoji,
          subjectGradient: gradient,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;
    final l10n = AppLocalizations(locale.locale);

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Top bar
                FadeTransition(
                  opacity: _fadeAnimations[0],
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppColors.textPrimary, size: 20),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => locale.toggleLocale(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withAlpha(25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language,
                                  color: AppColors.textSecondary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isArabic ? 'EN' : 'ع',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                SlideTransition(
                  position: _slideAnimations[0],
                  child: FadeTransition(
                    opacity: _fadeAnimations[0],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('choose_subject'),
                          style: isArabic
                              ? GoogleFonts.cairo(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                )
                              : GoogleFonts.inter(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.get('experiments_count'),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Chemistry Card with AI background
                SlideTransition(
                  position: _slideAnimations[1],
                  child: FadeTransition(
                    opacity: _fadeAnimations[1],
                    child: _AiSubjectCard(
                      title: l10n.get('chemistry'),
                      subtitle: l10n.get('chemistry_desc'),
                      emoji: '🧪',
                      imageKey: 'chemistry',
                      prompt: ImagePrompts.chemistry,
                      fallbackGradient: AppGradients.chemistry,
                      onTap: () => _navigateToRoadmap(
                        context,
                        subject: isArabic ? 'الكيمياء' : 'Chemistry',
                        emoji: '🧪',
                        gradient: AppGradients.chemistry,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Physics Card with AI background
                SlideTransition(
                  position: _slideAnimations[2],
                  child: FadeTransition(
                    opacity: _fadeAnimations[2],
                    child: _AiSubjectCard(
                      title: l10n.get('physics'),
                      subtitle: l10n.get('physics_desc'),
                      emoji: '🧲',
                      imageKey: 'physics',
                      prompt: ImagePrompts.physics,
                      fallbackGradient: AppGradients.physics,
                      onTap: () => _navigateToRoadmap(
                        context,
                        subject: isArabic ? 'الفيزياء' : 'Physics',
                        emoji: '🧲',
                        gradient: AppGradients.physics,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Subject card with AI-generated background image
class _AiSubjectCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final String imageKey;
  final String prompt;
  final LinearGradient fallbackGradient;
  final VoidCallback onTap;

  const _AiSubjectCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.imageKey,
    required this.prompt,
    required this.fallbackGradient,
    required this.onTap,
  });

  @override
  State<_AiSubjectCard> createState() => _AiSubjectCardState();
}

class _AiSubjectCardState extends State<_AiSubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = context.watch<ImageGenProvider>();
    final imageBytes = imageProvider.getImage(widget.imageKey);
    final isLoading = imageProvider.isLoading(widget.imageKey);

    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnim.value, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.fallbackGradient.colors.first.withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: AI image or gradient fallback
                if (imageBytes != null)
                  Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                else if (isLoading)
                  Shimmer.fromColors(
                    baseColor: widget.fallbackGradient.colors.first,
                    highlightColor: widget.fallbackGradient.colors.last,
                    child: Container(
                      decoration: BoxDecoration(gradient: widget.fallbackGradient),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(gradient: widget.fallbackGradient),
                  ),

                // Layer 2: Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withAlpha(180),
                        Colors.black.withAlpha(80),
                      ],
                    ),
                  ),
                ),

                // Layer 3: Glassmorphism border
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha(25),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // Layer 4: Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 24),
                  child: Row(
                    children: [
                      // Emoji circle
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(20),
                          border: Border.all(
                            color: Colors.white.withAlpha(30),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Text content
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.cairo(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withAlpha(180),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(20),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
