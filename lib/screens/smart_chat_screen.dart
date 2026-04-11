import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../models/ai_response.dart';
import '../models/chat_message.dart';
import '../models/quiz_question.dart';
import '../providers/locale_provider.dart';
import '../providers/smart_chat_provider.dart';
import '../providers/progress_provider.dart';
import '../models/skill_area.dart';
import '../widgets/chat_bubble.dart';
import 'chem_lab_screen.dart';
import 'physics_lab_screen.dart';
import 'physics_simulation_screen.dart';

/// Reusable AI-driven chat screen with dual-mode support.
///
/// [mode] determines the AI's behavior:
///   - `'lab'`  → explains concepts, then offers to open a Virtual Lab
///   - `'quiz'` → asks topic, then renders interactive quiz buttons in-chat
class SmartChatScreen extends StatefulWidget {
  final String mode; // 'lab' or 'quiz'

  const SmartChatScreen({super.key, required this.mode});

  @override
  State<SmartChatScreen> createState() => _SmartChatScreenState();
}

class _SmartChatScreenState extends State<SmartChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _inputGlowController;
  late Animation<double> _inputGlow;

  bool get isLabMode => widget.mode == 'lab';

  @override
  void initState() {
    super.initState();

    _inputGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _inputGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inputGlowController, curve: Curves.easeInOut),
    );

    // Initialize chat after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = context.read<LocaleProvider>();
      context.read<SmartChatProvider>().initChat(
            mode: widget.mode,
            isArabic: locale.isArabic,
          );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputGlowController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppDurations.normal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final locale = context.read<LocaleProvider>();
    context.read<SmartChatProvider>().sendMessage(
          text,
          isArabic: locale.isArabic,
        );

    // Award XP for engaging with AI
    context.read<ProgressProvider>().recordAiQuestion();

    _textController.clear();
    _scrollToBottom();
  }

  void _navigateToLab(AiResponse response) {
    Widget labScreen;

    if (response.isPhysics) {
      // Check if there's a specific experiment with a simulation
      final experiment = response.physicsExperiment;
      if (experiment != null && experiment.hasSimulation) {
        if (experiment.simType == 'projectile') {
          // Projectile motion uses the dedicated PhysicsLabScreen
          labScreen = PhysicsLabScreen(
            initialParams: response.experimentParams,
          );
        } else {
          // All other sim types use the PhysicsSimulationScreen tabs
          labScreen = PhysicsSimulationScreen(
            initialTabIndex: experiment.simTabIndex ?? 0,
          );
        }
      } else {
        // Default: open PhysicsLabScreen (projectile)
        labScreen = const PhysicsLabScreen();
      }
    } else {
      labScreen = ChemLabScreen(toolNames: response.tools);
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => labScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: AppDurations.slow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isArabic = locale.isArabic;
    final provider = context.watch<SmartChatProvider>();

    // Auto-scroll when messages change
    _scrollToBottom();

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(isArabic),
        body: Column(
          children: [
            // ─── Message List ───
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: provider.messages.length +
                    (provider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing indicator at the end
                  if (index == provider.messages.length &&
                      provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: TypingIndicator(),
                    );
                  }

                  final msg = provider.messages[index];
                  return _buildMessageWidget(msg, index, isArabic);
                },
              ),
            ),

            // ─── Input Area ───
            _buildInputArea(isArabic),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  APP BAR
  // ═══════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(bool isArabic) {
    return AppBar(
      backgroundColor: AppColors.surfaceCard,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isLabMode
                  ? AppGradients.roadmapLab
                  : AppGradients.roadmapQuiz,
            ),
            child: Center(
              child: Text(
                isLabMode ? '🔬' : '🧠',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? (isLabMode ? 'معمل Skillify' : 'اختبار Skillify')
                      : (isLabMode ? 'Skillify Lab' : 'Skillify Quiz'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isArabic
                      ? (isLabMode ? 'اسأل واستكشف' : 'اختبر معلوماتك')
                      : (isLabMode ? 'Ask & Explore' : 'Test Your Knowledge'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
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
      actions: [
        // Mode badge
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (isLabMode ? AppColors.roadmapLab : AppColors.roadmapQuiz)
                .withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLabMode ? Icons.science_rounded : Icons.quiz_rounded,
                size: 14,
                color: isLabMode
                    ? AppColors.roadmapLab
                    : AppColors.roadmapQuiz,
              ),
              const SizedBox(width: 4),
              Text(
                isArabic
                    ? (isLabMode ? 'معمل' : 'اختبار')
                    : (isLabMode ? 'Lab' : 'Quiz'),
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLabMode
                      ? AppColors.roadmapLab
                      : AppColors.roadmapQuiz,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MESSAGE ROUTING
  // ═══════════════════════════════════════════════════════════════

  /// Determines which widget to render for each message type.
  Widget _buildMessageWidget(ChatMessage msg, int index, bool isArabic) {
    // User messages → standard bubble
    if (msg.isUser) {
      return ChatBubble(
        text: msg.text,
        isUser: true,
        isArabic: isArabic,
      );
    }

    // AI messages — route by action type
    if (msg.hasLabAction) {
      return _buildLabActionBubble(msg, isArabic);
    }

    if (msg.hasQuiz) {
      return _buildQuizBubble(msg, index, isArabic);
    }

    // Plain AI text message
    return ChatBubble(
      text: msg.text,
      isUser: false,
      isArabic: isArabic,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LAB ACTION BUBBLE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLabActionBubble(ChatMessage msg, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          _aiAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message text bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.aiBubble,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        msg.text,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                        textDirection:
                            isArabic ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      if (msg.aiResponse!.tools.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        // Tool chips preview
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: msg.aiResponse!.tools.map((tool) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.accent.withAlpha(30),
                                ),
                              ),
                              child: Text(
                                '🧪 $tool',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ─── Enter Lab Button ───
                _LabEntryButton(
                  isArabic: isArabic,
                  onTap: () => _navigateToLab(msg.aiResponse!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  QUIZ BUBBLE — Interactive Questions
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuizBubble(ChatMessage msg, int messageIndex, bool isArabic) {
    final questions = msg.aiResponse!.questions;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aiAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introductory message
                if (msg.text.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.aiBubble,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SelectableText(
                      msg.text,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),

                const SizedBox(height: 10),

                // ─── Question Cards ───
                ...List.generate(questions.length, (qIndex) {
                  return _QuizQuestionCard(
                    question: questions[qIndex],
                    questionIndex: qIndex,
                    questionNumber: qIndex + 1,
                    totalQuestions: questions.length,
                    selectedAnswer: msg.selectedAnswers[qIndex],
                    isArabic: isArabic,
                    onAnswer: (answerIndex) {
                      context.read<SmartChatProvider>().selectQuizAnswer(
                            messageIndex,
                            qIndex,
                            answerIndex,
                          );

                      // Award/record XP with visual overlay
                      final correct =
                          questions[qIndex].isCorrect(answerIndex);
                      if (correct) {
                        context.read<ProgressProvider>().addXpWithOverlay(
                              context,
                              amount: XpRewards.correctAnswer,
                              skill: 'general',
                              label: 'Correct! ✅',
                              emoji: '🧠',
                            );
                      }
                      context.read<ProgressProvider>().recordAnswer(
                            topic: 'quiz',
                            correct: correct,
                            skill: 'general',
                          );

                      _scrollToBottom();
                    },
                  );
                }),

                // ─── Score Summary ───
                if (msg.allQuestionsAnswered)
                  _QuizScoreSummary(
                    message: msg,
                    isArabic: isArabic,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  INPUT AREA
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInputArea(bool isArabic) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(8)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text input
            Expanded(
              child: AnimatedBuilder(
                animation: _inputGlow,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: (isLabMode
                                ? AppColors.roadmapLab
                                : AppColors.roadmapQuiz)
                            .withAlpha(
                                (20 * _inputGlow.value).toInt()),
                      ),
                    ),
                    child: child,
                  );
                },
                child: TextField(
                  controller: _textController,
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? (isLabMode
                            ? 'اكتب موضوعاً علمياً...'
                            : 'اكتب الموضوع المطلوب...')
                        : (isLabMode
                            ? 'Type a science topic...'
                            : 'Type the topic to test...'),
                    hintStyle: GoogleFonts.cairo(
                      color: AppColors.textMuted,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Send button
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isLabMode
                      ? AppGradients.roadmapLab
                      : AppGradients.roadmapQuiz,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isLabMode
                              ? AppColors.roadmapLab
                              : AppColors.roadmapQuiz)
                          .withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared AI Avatar ───
  Widget _aiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isLabMode ? AppGradients.roadmapLab : AppGradients.roadmapQuiz,
        boxShadow: [
          BoxShadow(
            color: (isLabMode ? AppColors.roadmapLab : AppColors.roadmapQuiz)
                .withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          isLabMode ? '🔬' : '🧠',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  LAB ENTRY BUTTON — Animated CTA
// ═════════════════════════════════════════════════════════════════

class _LabEntryButton extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const _LabEntryButton({required this.isArabic, required this.onTap});

  @override
  State<_LabEntryButton> createState() => _LabEntryButtonState();
}

class _LabEntryButtonState extends State<_LabEntryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent
                    .withAlpha((40 * _pulse.value).toInt()),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFF00D4AA)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.science_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isArabic
                        ? 'ادخل المعمل الافتراضي 🚀'
                        : 'Enter Virtual Lab 🚀',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  QUIZ QUESTION CARD — Interactive Options
// ═════════════════════════════════════════════════════════════════

class _QuizQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int questionIndex;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedAnswer;
  final bool isArabic;
  final ValueChanged<int> onAnswer;

  const _QuizQuestionCard({
    required this.question,
    required this.questionIndex,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isArabic,
    required this.onAnswer,
  });

  bool get isAnswered => selectedAnswer != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAnswered
              ? (question.isCorrect(selectedAnswer!)
                  ? AppColors.success.withAlpha(40)
                  : AppColors.danger.withAlpha(40))
              : Colors.white.withAlpha(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.roadmapQuiz.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isArabic ? 'سؤال' : 'Q'} $questionNumber/$totalQuestions',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.roadmapQuiz,
                    ),
                  ),
                ),
                const Spacer(),
                if (isAnswered)
                  Icon(
                    question.isCorrect(selectedAnswer!)
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: question.isCorrect(selectedAnswer!)
                        ? AppColors.success
                        : AppColors.danger,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Question text
            Text(
              question.question,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 14),

            // Option buttons
            ...List.generate(question.options.length, (i) {
              return _buildOptionButton(i);
            }),

            // Explanation (shown after answering)
            if (isAnswered) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: question.isCorrect(selectedAnswer!)
                      ? AppColors.success.withAlpha(10)
                      : AppColors.danger.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: question.isCorrect(selectedAnswer!)
                        ? AppColors.success.withAlpha(20)
                        : AppColors.danger.withAlpha(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? '💡 الشرح:' : '💡 Explanation:',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: question.isCorrect(selectedAnswer!)
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.explanation,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int optionIndex) {
    final isSelected = selectedAnswer == optionIndex;
    final isCorrectOption = optionIndex == question.correctIndex;

    // Determine colors
    Color bgColor = AppColors.surfaceLight;
    Color borderColor = Colors.transparent;
    Color textColor = AppColors.textPrimary;

    if (isAnswered) {
      if (isCorrectOption) {
        bgColor = AppColors.success.withAlpha(20);
        borderColor = AppColors.success;
        textColor = AppColors.success;
      } else if (isSelected && !isCorrectOption) {
        bgColor = AppColors.danger.withAlpha(20);
        borderColor = AppColors.danger;
        textColor = AppColors.danger;
      } else {
        bgColor = AppColors.surfaceLight.withAlpha(100);
        textColor = AppColors.textMuted;
      }
    }

    final labels = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: isAnswered ? null : () => onAnswer(optionIndex),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Option label (A, B, C, D)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(isAnswered ? 5 : 10),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected || (isAnswered && isCorrectOption)
                      ? Border.all(
                          color: isCorrectOption
                              ? AppColors.success
                              : AppColors.danger,
                          width: 1.5,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    labels[optionIndex],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Option text
              Expanded(
                child: Text(
                  question.options[optionIndex],
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: textColor,
                    fontWeight:
                        isAnswered && isCorrectOption
                            ? FontWeight.w700
                            : FontWeight.w400,
                  ),
                ),
              ),
              // Check/cross icon
              if (isAnswered && isCorrectOption)
                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
              if (isAnswered && isSelected && !isCorrectOption)
                const Icon(Icons.cancel, color: AppColors.danger, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  QUIZ SCORE SUMMARY
// ═════════════════════════════════════════════════════════════════

class _QuizScoreSummary extends StatelessWidget {
  final ChatMessage message;
  final bool isArabic;

  const _QuizScoreSummary({
    required this.message,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final questions = message.aiResponse!.questions;
    int correct = 0;
    for (final entry in message.selectedAnswers.entries) {
      if (questions[entry.key].isCorrect(entry.value)) {
        correct++;
      }
    }
    final total = questions.length;
    final percentage = total > 0 ? (correct / total * 100).round() : 0;

    final isGood = percentage >= 70;
    final isMedium = percentage >= 40 && percentage < 70;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGood
              ? [AppColors.success.withAlpha(15), AppColors.success.withAlpha(5)]
              : isMedium
                  ? [AppColors.warning.withAlpha(15), AppColors.warning.withAlpha(5)]
                  : [AppColors.danger.withAlpha(15), AppColors.danger.withAlpha(5)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isGood
              ? AppColors.success.withAlpha(30)
              : isMedium
                  ? AppColors.warning.withAlpha(30)
                  : AppColors.danger.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isGood
                    ? [AppColors.success, const Color(0xFF00C853)]
                    : isMedium
                        ? [AppColors.warning, const Color(0xFFFF8F00)]
                        : [AppColors.danger, const Color(0xFFD32F2F)],
              ),
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: GoogleFonts.inter(
                  fontSize: 16,
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
                  isGood
                      ? (isArabic ? 'ممتاز! 🌟' : 'Excellent! 🌟')
                      : isMedium
                          ? (isArabic ? 'جيد! 👍' : 'Good! 👍')
                          : (isArabic ? 'تحتاج تدريب 💪' : 'Needs Practice 💪'),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic
                      ? '$correct من $total إجابة صحيحة'
                      : '$correct out of $total correct',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
