import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';

/// Settings / Profile screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;
    final progress = context.watch<ProgressProvider>().progress;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            isArabic ? 'الإعدادات ⚙️' : 'Settings ⚙️',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Profile Card ───
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryMid.withAlpha(25),
                      AppColors.primaryLight.withAlpha(10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(10)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withAlpha(40),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${progress.level}',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? 'المستوى ${progress.level}'
                                : 'Level ${progress.level}',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${progress.totalXp} XP • ${progress.experimentsCompleted} ${isArabic ? 'تجربة' : 'experiments'}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Language Section ───
              _SectionTitle(text: isArabic ? 'اللغة' : 'Language'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: isArabic ? 'لغة التطبيق' : 'App Language',
                subtitle: isArabic ? 'العربية' : 'English',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isArabic ? 'EN ← عربي' : 'عربي → EN',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                onTap: () => locale.toggleLocale(),
              ),

              const SizedBox(height: 28),

              // ─── Stats Section ───
              _SectionTitle(text: isArabic ? 'الإحصائيات' : 'Statistics'),
              const SizedBox(height: 12),
              _StatRow(
                label: isArabic ? 'إجمالي XP' : 'Total XP',
                value: '${progress.totalXp}',
                icon: '⚡',
              ),
              _StatRow(
                label: isArabic ? 'أسئلة مجابة' : 'Questions Answered',
                value: '${progress.questionsAnswered}',
                icon: '📝',
              ),
              _StatRow(
                label: isArabic ? 'الدقة' : 'Accuracy',
                value: '${(progress.accuracy * 100).toStringAsFixed(1)}%',
                icon: '🎯',
              ),
              _StatRow(
                label: isArabic ? 'التجارب' : 'Experiments',
                value: '${progress.experimentsCompleted}',
                icon: '🧪',
              ),
              _StatRow(
                label: isArabic ? 'المحاكيات' : 'Simulations',
                value: '${progress.simulationsCompleted}',
                icon: '🎮',
              ),
              _StatRow(
                label: isArabic ? 'أسئلة AI' : 'AI Questions',
                value: '${progress.aiQuestionsAsked}',
                icon: '🤖',
              ),
              _StatRow(
                label: isArabic ? 'أفضل streak' : 'Best Streak',
                value: '${progress.bestStreak} ${isArabic ? 'يوم' : 'days'}',
                icon: '🔥',
              ),

              const SizedBox(height: 28),

              // ─── Danger Zone ───
              _SectionTitle(text: isArabic ? 'خيارات متقدمة' : 'Advanced'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFEF4444),
                title: isArabic ? 'مسح كل البيانات' : 'Reset All Progress',
                subtitle: isArabic
                    ? 'إزالة XP والشارات والإحصائيات'
                    : 'Remove XP, badges, and stats',
                onTap: () => _showResetDialog(context, isArabic),
              ),

              const SizedBox(height: 28),

              // ─── About Section ───
              _SectionTitle(text: isArabic ? 'حول التطبيق' : 'About'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withAlpha(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🚀', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skillify',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'v1.0.0',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isArabic
                          ? 'منصة تعلم ذكية ومتكيفة للكيمياء والفيزياء مع محاكيات تفاعلية وذكاء اصطناعي.'
                          : 'An adaptive learning platform for Chemistry & Physics with interactive simulations and AI.',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isArabic ? '⚠️ تأكيد المسح' : '⚠️ Confirm Reset',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد؟ سيتم مسح كل البيانات بما في ذلك XP والشارات والتقدم.'
                : 'Are you sure? All data including XP, badges, and progress will be permanently deleted.',
            style: GoogleFonts.cairo(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isArabic ? 'إلغاء' : 'Cancel',
                style: GoogleFonts.cairo(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProgressProvider>().resetProgress();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic ? 'تم مسح كل البيانات ✓' : 'All data reset ✓',
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isArabic ? 'مسح' : 'Reset',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Section Title ───
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
      ),
    );
  }
}

// ─── Settings Tile ───
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withAlpha(8)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ?trailing,
            if (trailing == null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Row ───
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(5)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
