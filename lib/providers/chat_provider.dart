import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/experiment.dart';
import '../services/gemini_service.dart';

/// Provider managing the AI chat state and experiment parsing.
/// Supports two modes: general Q&A and experiment preparation.
class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Experiment? _currentExperiment;
  String _currentSubject = '';
  String _lastExperimentName = '';
  bool _isGeneralMode = false;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  Experiment? get currentExperiment => _currentExperiment;
  String get currentSubject => _currentSubject;
  String get lastExperimentName => _lastExperimentName;
  bool get hasExperiment => _currentExperiment != null && _currentExperiment!.tools.isNotEmpty;
  bool get isGeneralMode => _isGeneralMode;

  /// Initialize chat for a subject with a greeting message
  void initChat({
    required String subject,
    required bool isArabic,
    bool isGeneral = false,
  }) {
    _messages.clear();
    _currentSubject = subject;
    _currentExperiment = null;
    _isGeneralMode = isGeneral;

    final greeting = isGeneral
        ? (isArabic
            ? 'أهلاً بك! 🤖\nأنا مساعدك الذكي. اسألني أي سؤال في أي موضوع وهجاوبك فوراً!'
            : 'Welcome! 🤖\nI\'m your smart assistant. Ask me anything on any topic and I\'ll answer right away!')
        : (isArabic
            ? 'أهلاً بك! 🤖\nاكتب اسم التجربة التي تريد القيام بها وسأجهز لك قائمة الأدوات المطلوبة.'
            : 'Welcome! 🤖\nType the experiment you want to perform and I\'ll prepare the required tools list.');

    _messages.add(ChatMessage.ai(greeting));
    notifyListeners();
  }

  /// Send a user message and get AI response
  Future<void> sendMessage(String text, {required bool isArabic}) async {
    if (text.trim().isEmpty) return;

    _lastExperimentName = text.trim();

    // Add user message
    _messages.add(ChatMessage.user(text));
    _isLoading = true;
    notifyListeners();

    // Check API key
    if (!_geminiService.isConfigured) {
      _messages.add(ChatMessage.ai(
        isArabic
            ? '⚠️ لم يتم العثور على مفتاح GEMINI_KEY في ملف .env'
            : '⚠️ GEMINI_KEY not found in .env file',
      ));
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      if (_isGeneralMode) {
        // General mode — answer any question
        final response = await _geminiService.sendGeneralMessage(
          message: text,
          subject: _currentSubject,
          isArabic: isArabic,
        );
        _messages.add(ChatMessage.ai(response));
      } else {
        // Experiment mode — get tools list
        final response = await _geminiService.getExperimentTools(
          experimentName: text,
          subject: _currentSubject,
          isArabic: isArabic,
        );

        // Parse the response into an Experiment
        _currentExperiment = Experiment.fromAiResponse(
          name: text,
          subject: _currentSubject,
          response: response,
        );

        _messages.add(ChatMessage.ai(response));
      }
    } catch (e) {
      final errorMsg = isArabic
          ? 'تأكد من اتصالك بالإنترنت.\nالتفاصيل: $e'
          : 'Check your internet connection.\nDetails: $e';
      _messages.add(ChatMessage.ai(errorMsg));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear chat history and experiment
  void clearChat() {
    _messages.clear();
    _currentExperiment = null;
    _lastExperimentName = '';
    notifyListeners();
  }
}
