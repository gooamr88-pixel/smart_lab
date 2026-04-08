import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/experiment.dart';
import '../providers/locale_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/quiz_option_tile.dart';

/// Quiz screen — supports experiment-based and topic-based quizzes.
/// Pass an [experiment] for experiment-based, or [subject] for topic-based.
class QuizScreen extends StatefulWidget {
  final Experiment? experiment;
  final String? subject;

  const QuizScreen({super.key, this.experiment, this.subject});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _xpAwarded = false;
  bool _topicSubmitted = false;
  final TextEditingController _topicController = TextEditingController();

  bool get _isTopicMode => widget.experiment == null;
  String get _subject =>
      widget.experiment?.subject ?? widget.subject ?? 'Science';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // If experiment-based, generate quiz immediately
    if (!_isTopicMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final locale = context.read<LocaleProvider>();
        final toolsList = widget.experiment!.tools
            .map((t) => '- ${t.name}: ${t.reason}')
            .join('\n');

        context.read<QuizProvider>().generateQuiz(
              experimentName: widget.experiment!.name,
              subject: widget.experiment!.subject,
              toolsList: toolsList,
              isArabic: locale.isArabic,
            );
        _topicSubmitted = true;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _submitTopic(String topic) {
    if (topic.trim().isEmpty) return;
    final locale = context.read<LocaleProvider>();
    context.read<QuizProvider>().generateTopicQuiz(
          topic: topic.trim(),
          subject: _subject,
          isArabic: locale.isArabic,
        );
    setState(() => _topicSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;
    final l10n = AppLocalizations(locale.locale);
    final quizProvider = context.watch<QuizProvider>();

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCard,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () {
              quizProvider.resetQuiz();
              Navigator.pop(context);
            },
          ),
          title: Text(
            l10n.get('quiz_title'),
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            if (_topicSubmitted &&
                !quizProvider.isLoading &&
                quizProvider.questions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${quizProvider.currentIndex + 1}/${quizProvider.totalQuestions}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
          ],
        ),
        body: _topicSubmitted
            ? _buildBody(quizProvider, l10n, isArabic)
            : _buildTopicInputScreen(isArabic),
      ),
    );
  }

  // ─── Topic Input Screen ───
  Widget _buildTopicInputScreen(bool isArabic) {
    final isPhysics = _subject.toLowerCase().contains('phys') ||
        _subject.contains('فيزياء');

    final suggestionsAr = isPhysics
        ? ['قوانين نيوتن', 'البندول البسيط', 'الضغط والكثافة', 'الكهرباء', 'الموجات الصوتية', 'المرايا والعدسات']
        : ['التفاعلات الكيميائية', 'الأحماض والقواعد', 'الجدول الدوري', 'روابط كيميائية', 'المحاليل', 'التأكسد والاختزال'];

    final suggestionsEn = isPhysics
        ? ["Newton's Laws", 'Simple Pendulum', 'Pressure & Density', 'Electricity', 'Sound Waves', 'Mirrors & Lenses']
        : ['Chemical Reactions', 'Acids & Bases', 'Periodic Table', 'Chemical Bonds', 'Solutions', 'Oxidation & Reduction'];

    final suggestions = isArabic ? suggestionsAr : suggestionsEn;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.roadmapQuiz.withAlpha(20),
              ),
              child: const Center(
                child: Text('📝', style: TextStyle(fontSize: 40)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              isArabic
                  ? 'عايز تتسأل في إيه؟'
                  : 'What do you want to be tested on?',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isArabic
                  ? 'اكتب الموضوع أو اختار من الاقتراحات'
                  : 'Type a topic or pick from suggestions',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),

          // Text field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    style: GoogleFonts.cairo(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? 'مثال: قوانين نيوتن...'
                          : 'e.g. Newton\'s Laws...',
                      hintStyle: GoogleFonts.cairo(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: _submitTopic,
                  ),
                ),
                GestureDetector(
                  onTap: () => _submitTopic(_topicController.text),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.roadmapQuiz,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Suggestions label
          Text(
            isArabic ? '💡 اقتراحات سريعة' : '💡 Quick suggestions',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () {
                  _topicController.text = s;
                  _submitTopic(s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.roadmapQuiz.withAlpha(30),
                    ),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Quiz Body ───
  Widget _buildBody(
      QuizProvider quizProvider, AppLocalizations l10n, bool isArabic) {
    // Loading state
    if (quizProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryLight),
            const SizedBox(height: 20),
            Text(
              l10n.get('generating_quiz'),
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    // Quiz complete
    if (quizProvider.isQuizComplete) {
      if (!_xpAwarded) {
        _xpAwarded = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ProgressProvider>().completeQuiz(
                score: quizProvider.score,
                total: quizProvider.totalQuestions,
              );
        });
      }
      return _buildCompletionScreen(quizProvider, l10n, isArabic);
    }

    // No questions (error)
    if (quizProvider.questions.isEmpty) {
      return Center(
        child: Text(
          quizProvider.errorMessage.isNotEmpty
              ? quizProvider.errorMessage
              : l10n.get('error'),
          style: GoogleFonts.cairo(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Current question
    return _buildQuestionView(quizProvider, l10n, isArabic);
  }

  Widget _buildQuestionView(
      QuizProvider quizProvider, AppLocalizations l10n, bool isArabic) {
    final question = quizProvider.currentQuestion!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (quizProvider.currentIndex + 1) /
                  quizProvider.totalQuestions,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 28),

          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${l10n.get('question')} ${quizProvider.currentIndex + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  question.question,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Options
          ...List.generate(question.options.length, (index) {
            return QuizOptionTile(
              text: question.options[index],
              index: index,
              isSelected: quizProvider.selectedAnswer == index,
              isCorrect: question.isCorrect(index),
              isAnswered: quizProvider.isAnswered,
              correctIndex: question.correctIndex,
              onTap: () => quizProvider.selectAnswer(index),
            );
          }),

          // Explanation (after answering)
          if (quizProvider.isAnswered) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLight.withAlpha(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: AppColors.primaryLight, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.get('explanation'),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Next button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => quizProvider.nextQuestion(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  quizProvider.currentIndex < quizProvider.totalQuestions - 1
                      ? l10n.get('next_question')
                      : l10n.get('quiz_complete'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(
      QuizProvider quizProvider, AppLocalizations l10n, bool isArabic) {
    final percentage = quizProvider.totalQuestions > 0
        ? (quizProvider.score / quizProvider.totalQuestions * 100).round()
        : 0;

    return GradientBackground(
      showParticles: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(20),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 52)),
                ),
              ),
              const SizedBox(height: 24),

              // Completion text
              Text(
                l10n.get('quiz_complete'),
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Score
              Text(
                '$percentage%',
                style: GoogleFonts.inter(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${quizProvider.score} ${l10n.get('of_total')} ${quizProvider.totalQuestions}',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white.withAlpha(180),
                ),
              ),
              const SizedBox(height: 28),

              // "What If" scenario
              if (quizProvider.whatIfScenario.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.get('what_if'),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        quizProvider.whatIfScenario,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white.withAlpha(200),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    quizProvider.resetQuiz();
                    Navigator.of(context).popUntil(
                      (route) =>
                          route.isFirst ||
                          route.settings.name == '/subjects',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.get('back_to_subjects'),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
