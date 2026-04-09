import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../models/skill_area.dart';
import '../widgets/xp_overlay_manager.dart';
import 'smart_chat_screen.dart';
import 'settings_screen.dart';

/// Main dashboard showing user stats, XP, streak, skills, and activity.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnims = List.generate(6, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryController,
          curve: Interval(i * 0.1, 0.5 + i * 0.1, curve: Curves.easeOut),
        ),
      );
    });

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;
    final progressProvider = context.watch<ProgressProvider>();
    final progress = progressProvider.progress;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: XpOverlayManager(
          child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ─── Header ───
                FadeTransition(
                  opacity: _fadeAnims[0],
                  child: Row(
                    children: [
                      Flexible(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'أهلاً بك! 👋' : 'Welcome! 👋',
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isArabic
                                ? 'المستوى ${progress.level} • ${progress.totalXp} XP'
                                : 'Level ${progress.level} • ${progress.totalXp} XP',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      ),
                      const Spacer(),
                      // Settings gear
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(10),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: Colors.white.withAlpha(15)),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Language toggle
                      GestureDetector(
                        onTap: () => locale.toggleLocale(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(10),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: Colors.white.withAlpha(15)),
                          ),
                          child: Center(
                            child: Text(
                              isArabic ? 'EN' : 'ع',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Stats Row ───
                FadeTransition(
                  opacity: _fadeAnims[1],
                  child: Row(
                    children: [
                      _StatCard(
                        emoji: '🔥',
                        value: '${progress.streak}',
                        label: isArabic ? 'يوم متواصل' : 'Day Streak',
                        color: AppColors.roadmapQuiz,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        emoji: '⚡',
                        value: '${progress.totalXp}',
                        label: 'Total XP',
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        emoji: '🎯',
                        value: '${(progress.accuracy * 100).toStringAsFixed(0)}%',
                        label: isArabic ? 'الدقة' : 'Accuracy',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Level Progress ───
                FadeTransition(
                  opacity: _fadeAnims[2],
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryMid.withAlpha(30),
                          AppColors.primaryLight.withAlpha(15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(10)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primary,
                              ),
                              child: Center(
                                child: Text(
                                  '${progress.level}',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic
                                        ? 'المستوى ${progress.level}'
                                        : 'Level ${progress.level}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${progress.currentLevelXp} / ${progress.xpForNextLevel} XP',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Progress bar
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress.levelProgress),
                          duration: AppDurations.slow,
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: val,
                                minHeight: 10,
                                backgroundColor:
                                    AppColors.surfaceLight.withAlpha(150),
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primaryLight),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Quick Actions ───
                FadeTransition(
                  opacity: _fadeAnims[3],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'ابدأ التعلم' : 'Start Learning',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickAction(
                              emoji: '🔬',
                              label: isArabic ? 'المعمل الذكي' : 'Virtual Lab',
                              gradient: AppGradients.roadmapLab,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SmartChatScreen(mode: 'lab')),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickAction(
                              emoji: '🧠',
                              label: isArabic ? 'اختبار ذكي' : 'Smart Quiz',
                              gradient: AppGradients.roadmapQuiz,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SmartChatScreen(mode: 'quiz')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Activity Heatmap ───
                FadeTransition(
                  opacity: _fadeAnims[4],
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('📊',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'النشاط' : 'Activity',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              isArabic ? 'آخر 30 يوم' : 'Last 30 days',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _ActivityHeatmap(
                          progressProvider: progressProvider,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Badges ───
                FadeTransition(
                  opacity: _fadeAnims[5],
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🏅',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'الشارات' : 'Badges',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${progress.earnedBadges.length}/${Badges.all.length}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: Badges.all.map((badge) {
                            final earned =
                                progress.earnedBadges.contains(badge.id);
                            return _BadgeChip(
                              badge: badge,
                              earned: earned,
                              isArabic: isArabic,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// ─── Stat Card ───
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(20)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action ───
class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Activity Heatmap ───
class _ActivityHeatmap extends StatelessWidget {
  final ProgressProvider progressProvider;

  const _ActivityHeatmap({required this.progressProvider});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(30, (i) {
      return today.subtract(Duration(days: 29 - i));
    });

    return SizedBox(
      height: 60,
      child: Row(
        children: days.map((day) {
          final active = progressProvider.wasActiveOn(day);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.success.withAlpha(180)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Badge Chip ───
class _BadgeChip extends StatelessWidget {
  final BadgeDefinition badge;
  final bool earned;
  final bool isArabic;

  const _BadgeChip({
    required this.badge,
    required this.earned,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isArabic ? badge.descAr : badge.descEn,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: earned
              ? AppColors.warning.withAlpha(20)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: earned ? AppColors.warning.withAlpha(50) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              earned ? badge.emoji : '🔒',
              style: TextStyle(
                fontSize: 18,
                color: earned ? null : Colors.grey,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                isArabic ? badge.nameAr : badge.nameEn,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: earned ? AppColors.textPrimary : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
