import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../models/skill_area.dart';
import 'ai_chat_screen.dart';
import 'physics_simulation_screen.dart';
import 'chemistry_simulation_screen.dart';
import 'diagnostic_screen.dart';
import 'quiz_screen.dart';

/// Chat mode enum used by AI Chat Screen
enum ChatMode { general, experiment }

/// Professional roadmap screen — shown when a subject is selected.
/// Personalized based on diagnostic results.
class SubjectRoadmapScreen extends StatefulWidget {
  final String subject;
  final String subjectEmoji;
  final LinearGradient subjectGradient;

  const SubjectRoadmapScreen({
    super.key,
    required this.subject,
    required this.subjectEmoji,
    required this.subjectGradient,
  });

  @override
  State<SubjectRoadmapScreen> createState() => _SubjectRoadmapScreenState();
}

class _SubjectRoadmapScreenState extends State<SubjectRoadmapScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _bgController;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 7 cards + header
    _fadeAnims = List.generate(7, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.12, 0.5 + i * 0.1, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(7, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.12, 0.5 + i * 0.1, curve: Curves.easeOutCubic),
        ),
      );
    });

    _scaleAnims = List.generate(7, (i) {
      return Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(i * 0.12, 0.5 + i * 0.1, curve: Curves.easeOut),
        ),
      );
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.normal,
      ),
    );
  }

  bool get _isPhysics {
    final s = widget.subject.toLowerCase();
    return s.contains('فيزياء') || s.contains('physics');
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;
    final l10n = AppLocalizations(locale.locale);
    final progressProvider = context.watch<ProgressProvider>();
    final progress = progressProvider.progress;
    final recommended = progressProvider.getRecommendedTopics();

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background blob
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _bgController.value * 2 * 3.14159,
                    child: child,
                  );
                },
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.subjectGradient.colors.first.withAlpha(25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Top bar
                    FadeTransition(
                      opacity: _fadeAnims[0],
                      child: Row(
                        children: [
                          _buildBackButton(),
                          const Spacer(),
                          // XP badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  '${progress.totalXp} XP',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Subject badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: widget.subjectGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.subjectGradient.colors.first.withAlpha(60),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(widget.subjectEmoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  widget.subject,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    SlideTransition(
                      position: _slideAnims[0],
                      child: FadeTransition(
                        opacity: _fadeAnims[0],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.get('roadmap_title'),
                              style: isArabic
                                  ? GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2)
                                  : GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (recommended.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  isArabic
                                      ? '💡 ننصحك بالتركيز على: ${recommended.map((t) => SkillAreas.getName(t, true)).join('، ')}'
                                      : '💡 Focus on: ${recommended.map((t) => SkillAreas.getName(t, false)).join(', ')}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: AppColors.warning,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Cards list
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Card 1: AI Assistant
                          _buildAnimatedCard(
                            index: 1,
                            emoji: '🤖',
                            title: l10n.get('ai_general'),
                            subtitle: l10n.get('ai_general_desc'),
                            gradient: AppGradients.roadmapAi,
                            glowColor: AppColors.roadmapAi,
                            onTap: () => _navigateTo(AiChatScreen(
                              subject: widget.subject,
                              mode: ChatMode.general,
                            )),
                          ),
                          const SizedBox(height: 14),

                          // Card 2: Simulations (NEW!)
                          _buildAnimatedCard(
                            index: 2,
                            emoji: '🎮',
                            title: isArabic ? 'المحاكاة التفاعلية' : 'Interactive Simulations',
                            subtitle: isArabic
                                ? 'غيّر المتغيرات وشوف النتيجة'
                                : 'Change variables and see results',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFFA502)],
                            ),
                            glowColor: const Color(0xFFFF6B6B),
                            onTap: () => _navigateTo(
                              _isPhysics
                                  ? const PhysicsSimulationScreen()
                                  : const ChemistrySimulationScreen(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Card 3: Experiment Lab
                          _buildAnimatedCard(
                            index: 3,
                            emoji: '🧪',
                            title: l10n.get('lab_entry'),
                            subtitle: l10n.get('lab_entry_desc'),
                            gradient: AppGradients.roadmapLab,
                            glowColor: AppColors.roadmapLab,
                            onTap: () => _navigateTo(
                              _isPhysics
                                  ? const PhysicsSimulationScreen()
                                  : const ChemistrySimulationScreen(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Card 4: Quiz / Test
                          _buildAnimatedCard(
                            index: 4,
                            emoji: '📝',
                            title: l10n.get('quiz_entry'),
                            subtitle: l10n.get('quiz_entry_desc'),
                            gradient: AppGradients.roadmapQuiz,
                            glowColor: AppColors.roadmapQuiz,
                            onTap: () => _navigateTo(
                              QuizScreen(subject: _isPhysics ? 'Physics' : 'Chemistry'),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Card 5: Diagnostic Test
                          _buildAnimatedCard(
                            index: 5,
                            emoji: '🧠',
                            title: isArabic ? 'اختبار تشخيصي' : 'Diagnostic Test',
                            subtitle: isArabic
                                ? 'اكتشف نقاط قوتك وضعفك'
                                : 'Discover your strengths & weaknesses',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            ),
                            glowColor: const Color(0xFF8B5CF6),
                            onTap: () => _navigateTo(const DiagnosticScreen()),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required int index,
    required String emoji,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return SlideTransition(
      position: _slideAnims[index],
      child: FadeTransition(
        opacity: _fadeAnims[index],
        child: ScaleTransition(
          scale: _scaleAnims[index],
          child: _RoadmapCard(
            emoji: emoji,
            title: title,
            subtitle: subtitle,
            gradient: gradient,
            glowColor: glowColor,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

/// Roadmap card widget
class _RoadmapCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _RoadmapCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_RoadmapCard> createState() => _RoadmapCardState();
}

class _RoadmapCardState extends State<_RoadmapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) => Transform.scale(scale: _pressScale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) { _pressController.reverse(); widget.onTap(); },
        onTapCancel: () => _pressController.reverse(),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: widget.glowColor.withAlpha(45), blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -4),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(decoration: BoxDecoration(gradient: widget.gradient)),
                // Glass circles
                Positioned(right: -30, top: -30, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(10)))),
                Positioned(right: 20, bottom: -40, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(6)))),
                // Glass border
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withAlpha(20)))),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(22), border: Border.all(color: Colors.white.withAlpha(25))),
                        child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(widget.subtitle, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white.withAlpha(190)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(18)),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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
