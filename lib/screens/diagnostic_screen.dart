import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../models/skill_area.dart';
import '../providers/locale_provider.dart';
import '../providers/progress_provider.dart';
import '../services/gemini_service.dart';
import 'dashboard_screen.dart';

/// Diagnostic test screen — assesses student's level and identifies weak areas.
class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen>
    with SingleTickerProviderStateMixin {
  final GeminiService _gemini = GeminiService();
  List<_DiagQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _isLoading = true;
  bool _isComplete = false;
  int _score = 0;
  final Map<String, int> _topicCorrect = {};
  final Map<String, int> _topicTotal = {};
  String _aiTips = '';
  bool _loadingTips = false;

  late AnimationController _transitionController;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _generateQuestions();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestions() async {
    final locale = context.read<LocaleProvider>();
    final isArabic = locale.isArabic;

    setState(() => _isLoading = true);

    try {
      if (_gemini.isConfigured) {
        final prompt = isArabic
            ? '''أنت مقيّم تعليمي. أنشئ 8 أسئلة تشخيصية (4 فيزياء + 4 كيمياء) لطالب ثانوي.
كل سؤال يختبر مهارة مختلفة: ميكانيكا، ديناميكا حرارية، كهرباء، بصريات، كيمياء عضوية، أحماض وقواعد، حسابات كيميائية، كيمياء كهربية.
أجب بصيغة JSON فقط:
[{"question":"...","options":["أ","ب","ج","د"],"correctIndex":0,"topic":"mechanics","explanation":"..."}]'''
            : '''You are an educational assessor. Create 8 diagnostic questions (4 physics + 4 chemistry) for a high school student.
Each question tests a different skill: mechanics, thermodynamics, electricity, optics, organic_chemistry, acid_base, stoichiometry, electro_chemistry.
Respond in JSON ONLY:
[{"question":"...","options":["A","B","C","D"],"correctIndex":0,"topic":"mechanics","explanation":"..."}]''';

        final content = [
          Content.text(prompt),
        ];
        final response = await _gemini.model.generateContent(content);
        final text = response.text ?? '[]';

        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(text);
        if (jsonMatch != null) {
          final list = jsonDecode(jsonMatch.group(0)!) as List;
          _questions = list
              .map((e) => _DiagQuestion.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback
    }

    // Fallback if AI failed or not configured
    if (_questions.isEmpty) {
      _questions = _getFallbackQuestions(isArabic);
    }

    setState(() => _isLoading = false);
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;

      final q = _questions[_currentIndex];
      final correct = index == q.correctIndex;
      if (correct) _score++;

      // Track per topic
      _topicTotal[q.topic] = (_topicTotal[q.topic] ?? 0) + 1;
      if (correct) {
        _topicCorrect[q.topic] = (_topicCorrect[q.topic] ?? 0) + 1;
      }

      // Record in progress
      context.read<ProgressProvider>().recordAnswer(
            topic: q.topic,
            correct: correct,
            skill: q.topic,
          );
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      // Complete
      context.read<ProgressProvider>().completeDiagnostic();
      setState(() => _isComplete = true);
      _fetchAiTips();
      return;
    }

    _transitionController.forward(from: 0);
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Future<void> _fetchAiTips() async {
    if (!_gemini.isConfigured) return;
    final isArabic = context.read<LocaleProvider>().isArabic;
    final weakAreas = context.read<ProgressProvider>().progress.weakAreas;
    final accuracy = context.read<ProgressProvider>().progress.accuracy;

    if (weakAreas.isEmpty) return;

    setState(() => _loadingTips = true);
    try {
      final tips = await _gemini.analyzeErrors(
        weakAreas: weakAreas,
        accuracy: accuracy,
        isArabic: isArabic,
      );
      if (mounted) setState(() => _aiTips = tips);
    } catch (_) {
      // Silently fail
    }
    if (mounted) setState(() => _loadingTips = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            isArabic ? 'الاختبار التشخيصي 🧠' : 'Diagnostic Test 🧠',
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
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic
                          ? 'جاري إنشاء الأسئلة...'
                          : 'Generating questions...',
                      style: GoogleFonts.cairo(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : _isComplete
                ? _buildResults(isArabic)
                : _buildQuestion(isArabic),
      ),
    );
  }

  Widget _buildQuestion(bool isArabic) {
    if (_questions.isEmpty) return const SizedBox();
    final q = _questions[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (_currentIndex + 1) / _questions.length,
                    ),
                    duration: AppDurations.normal,
                    builder: (context, val, _) {
                      return LinearProgressIndicator(
                        value: val,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primaryLight),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Topic badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.roadmapAi.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              SkillAreas.getName(q.topic, isArabic),
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.roadmapAi,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Question
          Text(
            q.question,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Options
          ...List.generate(q.options.length, (i) {
            final selected = _selectedAnswer == i;
            final isCorrect = i == q.correctIndex;
            Color bgColor = AppColors.surfaceLight;
            Color borderColor = Colors.transparent;

            if (_answered) {
              if (isCorrect) {
                bgColor = AppColors.success.withAlpha(25);
                borderColor = AppColors.success;
              } else if (selected && !isCorrect) {
                bgColor = AppColors.danger.withAlpha(25);
                borderColor = AppColors.danger;
              }
            } else if (selected) {
              bgColor = AppColors.primaryLight.withAlpha(20);
              borderColor = AppColors.primaryLight;
            }

            return GestureDetector(
              onTap: () => _selectAnswer(i),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          ['A', 'B', 'C', 'D'][i],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        q.options[i],
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_answered && isCorrect)
                      const Icon(Icons.check_circle, color: AppColors.success, size: 22),
                    if (_answered && selected && !isCorrect)
                      const Icon(Icons.cancel, color: AppColors.danger, size: 22),
                  ],
                ),
              ),
            );
          }),

          // Explanation
          if (_answered)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                q.explanation,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Next button
          if (_answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentIndex == _questions.length - 1
                      ? (isArabic ? 'اعرض النتائج' : 'Show Results')
                      : (isArabic ? 'السؤال التالي →' : 'Next Question →'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isArabic) {
    final percentage = _questions.isEmpty ? 0 : (_score / _questions.length * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Score circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: percentage >= 70
                    ? [AppColors.success, const Color(0xFF00C853)]
                    : percentage >= 40
                        ? [AppColors.warning, const Color(0xFFFF8F00)]
                        : [AppColors.danger, const Color(0xFFD32F2F)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (percentage >= 70
                          ? AppColors.success
                          : percentage >= 40
                              ? AppColors.warning
                              : AppColors.danger)
                      .withAlpha(60),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$_score/${_questions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            percentage >= 70
                ? (isArabic ? 'ممتاز! 🌟' : 'Excellent! 🌟')
                : percentage >= 40
                    ? (isArabic ? 'جيد! 👍' : 'Good! 👍')
                    : (isArabic ? 'تحتاج تدريب 💪' : 'Needs Practice 💪'),
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // Per-topic breakdown
          Text(
            isArabic ? 'تحليل المهارات' : 'Skill Analysis',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ..._topicTotal.entries.map((entry) {
            final topic = entry.key;
            final total = entry.value;
            final correct = _topicCorrect[topic] ?? 0;
            final pct = total > 0 ? correct / total : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SkillAreas.getName(topic, isArabic),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation(
                              pct >= 0.7
                                  ? AppColors.success
                                  : pct >= 0.4
                                      ? AppColors.warning
                                      : AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$correct/$total',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: pct >= 0.7
                          ? AppColors.success
                          : pct >= 0.4
                              ? AppColors.warning
                              : AppColors.danger,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // AI Tips section
          if (_loadingTips)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryLight.withAlpha(20)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      isArabic ? 'جاري تحليل أخطائك...' : 'Analyzing your mistakes...',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          if (_aiTips.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight.withAlpha(12),
                    AppColors.primaryMid.withAlpha(8),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryLight.withAlpha(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isArabic ? 'نصائح ذكية' : 'Smart Tips',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _aiTips,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isArabic ? 'ابدأ التعلم 🚀' : 'Start Learning 🚀',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_DiagQuestion> _getFallbackQuestions(bool isArabic) {
    if (isArabic) {
      return [
        _DiagQuestion(question: 'ما هي وحدة قياس القوة في النظام الدولي؟', options: ['نيوتن', 'جول', 'واط', 'باسكال'], correctIndex: 0, topic: 'mechanics', explanation: 'النيوتن هو وحدة القوة = كجم × م/ث²'),
        _DiagQuestion(question: 'ماذا يحدث للضغط عند زيادة درجة الحرارة في حجم ثابت؟', options: ['يزداد', 'ينقص', 'يبقى ثابتاً', 'يتلاشى'], correctIndex: 0, topic: 'thermodynamics', explanation: 'قانون جاي-لوساك: الضغط يتناسب طردياً مع الحرارة'),
        _DiagQuestion(question: 'ما هو الرقم الذري للكربون؟', options: ['6', '12', '8', '14'], correctIndex: 0, topic: 'organic_chemistry', explanation: 'الكربون عدده الذري 6 وعدده الكتلي 12'),
        _DiagQuestion(question: 'ماذا ينتج عن تفاعل حمض مع قاعدة؟', options: ['ملح + ماء', 'غاز + ماء', 'أكسيد', 'هيدروكسيد'], correctIndex: 0, topic: 'acid_base', explanation: 'تفاعل المعادلة: حمض + قاعدة → ملح + ماء'),
        _DiagQuestion(question: 'ما هو قانون أوم؟', options: ['V = IR', 'F = ma', 'E = mc²', 'P = IV'], correctIndex: 0, topic: 'electricity', explanation: 'قانون أوم: الجهد = التيار × المقاومة'),
        _DiagQuestion(question: 'ما هي ظاهرة انكسار الضوء؟', options: ['تغير اتجاه الضوء عند انتقاله بين وسطين', 'انعكاس الضوء', 'امتصاص الضوء', 'تشتت الضوء'], correctIndex: 0, topic: 'optics', explanation: 'الانكسار يحدث بسبب اختلاف سرعة الضوء في الأوساط المختلفة'),
      ];
    }
    return [
      _DiagQuestion(question: 'What is the SI unit of force?', options: ['Newton', 'Joule', 'Watt', 'Pascal'], correctIndex: 0, topic: 'mechanics', explanation: 'Newton is the unit of force = kg × m/s²'),
      _DiagQuestion(question: 'What happens to pressure when temperature increases at constant volume?', options: ['Increases', 'Decreases', 'Stays same', 'Disappears'], correctIndex: 0, topic: 'thermodynamics', explanation: 'Gay-Lussac\'s law: pressure is directly proportional to temperature'),
      _DiagQuestion(question: 'What is the atomic number of Carbon?', options: ['6', '12', '8', '14'], correctIndex: 0, topic: 'organic_chemistry', explanation: 'Carbon has atomic number 6 and mass number 12'),
      _DiagQuestion(question: 'What is produced from an acid-base reaction?', options: ['Salt + Water', 'Gas + Water', 'Oxide', 'Hydroxide'], correctIndex: 0, topic: 'acid_base', explanation: 'Neutralization: acid + base → salt + water'),
      _DiagQuestion(question: 'What is Ohm\'s Law?', options: ['V = IR', 'F = ma', 'E = mc²', 'P = IV'], correctIndex: 0, topic: 'electricity', explanation: 'Ohm\'s Law: Voltage = Current × Resistance'),
      _DiagQuestion(question: 'What is light refraction?', options: ['Change in light direction between media', 'Light reflection', 'Light absorption', 'Light dispersion'], correctIndex: 0, topic: 'optics', explanation: 'Refraction occurs due to different light speeds in different media'),
    ];
  }
}

class _DiagQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String topic;
  final String explanation;

  _DiagQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.topic,
    required this.explanation,
  });

  factory _DiagQuestion.fromJson(Map<String, dynamic> json) {
    return _DiagQuestion(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      correctIndex: json['correctIndex'] as int? ?? 0,
      topic: json['topic'] as String? ?? 'mechanics',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}
