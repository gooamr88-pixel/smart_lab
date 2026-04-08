import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/gemini_service.dart';

/// Provider managing the quiz / "What If" evaluation state
class QuizProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _isLoading = false;
  bool _isAnswered = false;
  String _whatIfScenario = '';
  String _errorMessage = '';

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int? get selectedAnswer => _selectedAnswer;
  bool get isLoading => _isLoading;
  bool get isAnswered => _isAnswered;
  String get whatIfScenario => _whatIfScenario;
  String get errorMessage => _errorMessage;
  bool get isQuizComplete => _currentIndex >= _questions.length && _questions.isNotEmpty;
  int get totalQuestions => _questions.length;

  QuizQuestion? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;

  /// Generate quiz questions from AI based on the experiment
  Future<void> generateQuiz({
    required String experimentName,
    required String subject,
    required String toolsList,
    required bool isArabic,
  }) async {
    _isLoading = true;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isAnswered = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get quiz questions
      final quizResponse = await _geminiService.getQuizQuestions(
        experimentName: experimentName,
        subject: subject,
        toolsList: toolsList,
        isArabic: isArabic,
      );

      // Parse JSON response
      _questions = _parseQuizResponse(quizResponse);

      // Get "What If" scenario
      _whatIfScenario = await _geminiService.getWhatIfScenario(
        experimentName: experimentName,
        subject: subject,
        isArabic: isArabic,
      );
    } catch (e) {
      _errorMessage = e.toString();
      // Create fallback questions if AI fails
      _questions = _getFallbackQuestions(isArabic);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Generate quiz based on a free-text topic (user types what they want to be tested on)
  Future<void> generateTopicQuiz({
    required String topic,
    required String subject,
    required bool isArabic,
  }) async {
    _isLoading = true;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isAnswered = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final quizResponse = await _geminiService.getTopicQuizQuestions(
        topic: topic,
        subject: subject,
        isArabic: isArabic,
      );

      _questions = _parseQuizResponse(quizResponse);

      _whatIfScenario = await _geminiService.getWhatIfScenario(
        experimentName: topic,
        subject: subject,
        isArabic: isArabic,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _questions = _getFallbackQuestions(isArabic);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Select an answer for the current question
  void selectAnswer(int index) {
    if (_isAnswered) return;

    _selectedAnswer = index;
    _isAnswered = true;

    if (currentQuestion != null && currentQuestion!.isCorrect(index)) {
      _score++;
    }

    notifyListeners();
  }

  /// Move to the next question
  void nextQuestion() {
    _currentIndex++;
    _selectedAnswer = null;
    _isAnswered = false;
    notifyListeners();
  }

  /// Reset quiz state
  void resetQuiz() {
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isAnswered = false;
    _whatIfScenario = '';
    _errorMessage = '';
    notifyListeners();
  }

  /// Parse the AI JSON response into QuizQuestion list
  List<QuizQuestion> _parseQuizResponse(String response) {
    try {
      // Extract JSON array from response (AI might add extra text)
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch == null) return [];

      final jsonStr = jsonMatch.group(0)!;
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fallback questions if AI generation fails
  List<QuizQuestion> _getFallbackQuestions(bool isArabic) {
    if (isArabic) {
      return [
        const QuizQuestion(
          question: 'ما هو الغرض الرئيسي من استخدام كأس الترسيب في المختبر؟',
          options: ['خلط المحاليل', 'تسخين السوائل', 'قياس الحجم بدقة', 'تخزين المواد الصلبة'],
          correctIndex: 0,
          explanation: 'كأس الترسيب يُستخدم أساساً لخلط المحاليل والتفاعلات الكيميائية.',
        ),
      ];
    }
    return [
      const QuizQuestion(
        question: 'What is the primary purpose of a beaker in the lab?',
        options: ['Mixing solutions', 'Heating liquids', 'Precise measurement', 'Storing solids'],
        correctIndex: 0,
        explanation: 'A beaker is primarily used for mixing solutions and chemical reactions.',
      ),
    ];
  }
}
