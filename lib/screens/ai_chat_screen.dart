import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/chat_bubble.dart';
import 'subject_roadmap_screen.dart';
import 'virtual_lab_screen.dart';

/// AI Chat screen — supports general Q&A and experiment preparation modes
class AiChatScreen extends StatefulWidget {
  final String subject;
  final ChatMode mode;

  const AiChatScreen({
    super.key,
    required this.subject,
    this.mode = ChatMode.experiment,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  bool get isGeneral => widget.mode == ChatMode.general;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );
    _fabScale = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    // Initialize chat after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = context.read<LocaleProvider>();
      context.read<ChatProvider>().initChat(
            subject: widget.subject,
            isArabic: locale.isArabic,
            isGeneral: isGeneral,
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final locale = context.read<LocaleProvider>();
    context.read<ChatProvider>().sendMessage(text, isArabic: locale.isArabic);
    // Award XP for asking AI
    context.read<ProgressProvider>().recordAiQuestion();
    _controller.clear();
    _scrollToBottom();
  }

  void _navigateToLab() {
    final chatProvider = context.read<ChatProvider>();
    if (!chatProvider.hasExperiment) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VirtualLabScreen(experiment: chatProvider.currentExperiment!),
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
    final l10n = AppLocalizations(locale.locale);
    final chatProvider = context.watch<ChatProvider>();

    // Show/hide FAB based on experiment availability (only in experiment mode)
    if (!isGeneral && chatProvider.hasExperiment) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }

    _scrollToBottom();

    return Directionality(
      textDirection: locale.textDirection,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        // Top App Bar — model badge hidden
        appBar: AppBar(
          backgroundColor: AppColors.surfaceCard,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isGeneral
                      ? AppGradients.roadmapAi
                      : AppGradients.primary,
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.get('ai_assistant'),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.subject,
                    style: GoogleFonts.inter(
                      fontSize: 12,
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
          // No model badge in actions — removed per user request
          actions: [
            // Mode indicator
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isGeneral ? AppColors.roadmapAi : AppColors.roadmapLab)
                    .withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGeneral
                        ? Icons.auto_awesome_rounded
                        : Icons.science_rounded,
                    size: 14,
                    color:
                        isGeneral ? AppColors.roadmapAi : AppColors.roadmapLab,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGeneral
                        ? (isArabic ? 'عام' : 'General')
                        : (isArabic ? 'تجارب' : 'Lab'),
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isGeneral
                          ? AppColors.roadmapAi
                          : AppColors.roadmapLab,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Chat body
        body: Column(
          children: [
            // Warning banner if experiment is dangerous
            if (!isGeneral &&
                (chatProvider.currentExperiment?.hasDangerWarning ?? false))
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.danger.withAlpha(20),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatProvider.currentExperiment!.warning!,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: chatProvider.messages.length +
                    (chatProvider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing indicator
                  if (index == chatProvider.messages.length &&
                      chatProvider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: TypingIndicator(),
                    );
                  }

                  final msg = chatProvider.messages[index];
                  return ChatBubble(
                    text: msg.text,
                    isUser: msg.isUser,
                    isArabic: isArabic,
                  );
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withAlpha(8),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Text field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: isGeneral
                                ? l10n.get('type_message')
                                : l10n.get('type_experiment'),
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
                          gradient: isGeneral
                              ? AppGradients.roadmapAi
                              : AppGradients.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isGeneral
                                      ? AppColors.roadmapAi
                                      : AppColors.primaryLight)
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
            ),
          ],
        ),

        // Start Lab FAB — only in experiment mode
        floatingActionButton: isGeneral
            ? null
            : ScaleTransition(
                scale: _fabScale,
                child: FloatingActionButton.extended(
                  onPressed: _navigateToLab,
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primaryDark,
                  icon: const Icon(Icons.science_rounded),
                  label: Text(
                    l10n.get('start_lab'),
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
