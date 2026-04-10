import 'package:flutter/material.dart';
import '../models/ai_response.dart';
import '../models/chat_message.dart';
import '../services/unified_ai_service.dart';

/// State management for the Smart Chat orchestrator.
///
/// Manages message history, loading state, quiz answer tracking,
/// and delegates AI calls to [GeminiService.sendSmartRequest].
class SmartChatProvider extends ChangeNotifier {
  final UnifiedAiService _ai = UnifiedAiService();

  final List<ChatMessage> _messages = [];
  String _mode = 'lab';
  bool _isLoading = false;

  // ─── Getters ────────────────────────────────────────────────

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String get mode => _mode;
  bool get isLoading => _isLoading;
  bool get isLabMode => _mode == 'lab';
  bool get isQuizMode => _mode == 'quiz';

  /// Returns the last AiResponse that triggered a lab action, if any.
  AiResponse? get lastLabAction {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].hasLabAction) return _messages[i].aiResponse;
    }
    return null;
  }

  // ─── Initialization ─────────────────────────────────────────

  /// Initialize the chat session with a greeting message.
  /// Call this once when the screen mounts.
  void initChat({
    required String mode,
    required bool isArabic,
  }) {
    _messages.clear();
    _mode = mode;

    final greeting = mode == 'lab'
        ? (isArabic
            ? 'أهلاً بك في المعمل الذكي! 🔬\nأخبرني عن الموضوع العلمي الذي تريد استكشافه وسأشرحه لك ثم نجهز المعمل الافتراضي.'
            : 'Welcome to Smart Lab! 🔬\nTell me the science topic you want to explore and I\'ll explain it, then we\'ll prepare the virtual lab.')
        : (isArabic
            ? 'أهلاً بك في الاختبار الذكي! 🧠\nأخبرني بالمادة والموضوع الذي تريد اختبار نفسك فيه.'
            : 'Welcome to Smart Quiz! 🧠\nTell me the subject and topic you\'d like to test yourself on.');

    _messages.add(ChatMessage.ai(greeting));
    notifyListeners();
  }

  // ─── Send Message ───────────────────────────────────────────

  /// Sends the user's message to the AI orchestrator.
  ///
  /// Adds the user message, calls Gemini with conversation history,
  /// and appends the structured AI response.
  Future<void> sendMessage(String text, {required bool isArabic}) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage.user(text.trim()));
    _isLoading = true;
    notifyListeners();

    try {
      // Build history (skip greeting and current user message)
      // We pass all prior messages so the AI has conversational context
      final history = _messages.sublist(0, _messages.length - 1);

      final response = await _ai.sendSmartRequest(
        message: text.trim(),
        mode: _mode,
        history: history,
        isArabic: isArabic,
      );

      _messages.add(ChatMessage.aiWithResponse(response));
    } catch (e) {
      final errorMsg = isArabic
          ? '⚠️ حدث خطأ. تأكد من اتصالك بالإنترنت.\nالتفاصيل: $e'
          : '⚠️ An error occurred. Check your internet connection.\nDetails: $e';
      _messages.add(ChatMessage.ai(errorMsg));
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Quiz Answer Tracking ───────────────────────────────────

  /// Records the user's answer for a quiz question within a chat message.
  ///
  /// [messageIndex]  — index of the message in [_messages]
  /// [questionIndex] — index of the question within that message's quiz
  /// [answerIndex]   — index of the option the user selected
  void selectQuizAnswer(int messageIndex, int questionIndex, int answerIndex) {
    if (messageIndex < 0 || messageIndex >= _messages.length) return;

    final msg = _messages[messageIndex];
    if (!msg.hasQuiz) return;
    if (msg.isQuestionAnswered(questionIndex)) return; // Already answered

    // Replace with updated message (immutable pattern)
    _messages[messageIndex] = msg.withAnswer(questionIndex, answerIndex);
    notifyListeners();
  }

  // ─── Clear ──────────────────────────────────────────────────

  /// Clears all messages and resets state.
  void clearChat() {
    _messages.clear();
    _isLoading = false;
    notifyListeners();
  }
}
