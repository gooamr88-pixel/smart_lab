import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/utils/env_config.dart';
import '../core/constants/app_constants.dart';

/// Service wrapper for Google Gemini AI (gemini-2.5-flash)
class GeminiService {
  GenerativeModel? _model;

  // Singleton pattern — shared across all providers
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Initialize the Gemini model with the API key from .env
  GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: EnvConfig.geminiKey,
    );
    return _model!;
  }

  /// Check if the service is properly configured
  bool get isConfigured => EnvConfig.isGeminiConfigured;

  /// Send a general science question to the AI
  /// [message] - the user's question
  /// [subject] - Chemistry or Physics
  /// [isArabic] - language for the response
  Future<String> sendGeneralMessage({
    required String message,
    required String subject,
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    final systemPrompt = isArabic
        ? AppPrompts.generalAssistantAr
        : AppPrompts.generalAssistantEn;

    final subjectHint = subject.isNotEmpty
        ? (isArabic
            ? 'الطالب يدرس حالياً مادة $subject.'
            : 'The student is currently studying $subject.')
        : '';

    final content = [
      Content.text('$systemPrompt\n$subjectHint\n\n${isArabic ? 'سؤال الطالب' : 'Student question'}: $message'),
    ];

    final response = await model.generateContent(content);
    return response.text ?? (isArabic ? 'لم يتم الحصول على رد.' : 'No response received.');
  }

  /// Get experiment tools list from AI
  /// [experimentName] - what the student wants to experiment with
  /// [subject] - Chemistry or Physics
  /// [isArabic] - language for the response
  Future<String> getExperimentTools({
    required String experimentName,
    required String subject,
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    final systemPrompt = isArabic
        ? AppPrompts.labExpertAr
        : AppPrompts.labExpertEn;

    final userPrompt = isArabic
        ? 'تجهيز تجربة "$experimentName" لمادة $subject.\nاذكر الأدوات المطلوبة وسبب استخدام كل أداة.'
        : 'Prepare experiment "$experimentName" for $subject.\nList the required tools and the reason for each.';

    final content = [
      Content.text('$systemPrompt\n\n$userPrompt'),
    ];

    final response = await model.generateContent(content);
    return response.text ?? (isArabic ? 'لم يتم الحصول على رد.' : 'No response received.');
  }

  /// Get quiz questions based on an experiment
  /// Returns JSON string that should be parsed into QuizQuestion list
  Future<String> getQuizQuestions({
    required String experimentName,
    required String subject,
    required String toolsList,
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    final systemPrompt = isArabic
        ? AppPrompts.quizExpertAr
        : AppPrompts.quizExpertEn;

    final userPrompt = isArabic
        ? 'التجربة: "$experimentName" في مادة $subject.\nالأدوات المستخدمة:\n$toolsList\n\nأنشئ أسئلة التقييم بصيغة JSON.'
        : 'Experiment: "$experimentName" in $subject.\nTools used:\n$toolsList\n\nGenerate evaluation questions in JSON format.';

    final content = [
      Content.text('$systemPrompt\n\n$userPrompt'),
    ];

    final response = await model.generateContent(content);
    return response.text ?? '[]';
  }

  /// Get quiz questions based on a free-text topic (user types what they want)
  Future<String> getTopicQuizQuestions({
    required String topic,
    required String subject,
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    final systemPrompt = isArabic
        ? AppPrompts.topicQuizAr
        : AppPrompts.topicQuizEn;

    final userPrompt = isArabic
        ? 'الموضوع: "$topic" في مادة $subject.\n\nأنشئ 5 أسئلة عملية معملية بصيغة JSON.'
        : 'Topic: "$topic" in $subject.\n\nGenerate 5 practical lab questions in JSON format.';

    final content = [
      Content.text('$systemPrompt\n\n$userPrompt'),
    ];

    final response = await model.generateContent(content);
    return response.text ?? '[]';
  }

  /// Get a "What If" scenario for the experiment
  Future<String> getWhatIfScenario({
    required String experimentName,
    required String subject,
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    final prompt = isArabic
        ? 'بصفتك خبير علمي، أعطني سيناريو "ماذا لو" بديل مثير للتجربة "$experimentName" في مادة $subject. اكتب في 3 جمل فقط. اذكر ماذا سيحدث لو غيرنا أحد المتغيرات.'
        : 'As a science expert, give me an alternative "What If" scenario for the experiment "$experimentName" in $subject. Write in 3 sentences only. Describe what would happen if we changed one variable.';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text ?? '';
  }

  /// Analyze student's error pattern and give targeted advice
  Future<String> analyzeErrors({
    required Map<String, int> weakAreas,
    required double accuracy,
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    final weakTopics = weakAreas.entries
        .map((e) => '${e.key}: ${e.value} errors')
        .join(', ');

    final prompt = isArabic
        ? '''بصفتك معلم خبير، حلل أخطاء الطالب وأعطه نصائح مخصصة.
نقاط الضعف: $weakTopics
الدقة الإجمالية: ${(accuracy * 100).toStringAsFixed(0)}%
اكتب 3-5 نصائح مخصصة وعملية في نقاط. كن مشجعاً.'''
        : '''As an expert teacher, analyze the student's error patterns and give targeted advice.
Weak areas: $weakTopics
Overall accuracy: ${(accuracy * 100).toStringAsFixed(0)}%
Write 3-5 personalized, actionable tips in bullet points. Be encouraging.''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text ?? '';
  }

  /// Generate a progressive challenge based on difficulty level
  Future<String> getProgressiveChallenge({
    required String subject,
    required String difficulty, // easy, medium, hard
    required String topic,
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    final prompt = isArabic
        ? '''أنشئ تحدي علمي واحد في $subject عن $topic بمستوى $difficulty.
أعط: السؤال، 4 خيارات، الإجابة الصحيحة، شرح مفصل.
صيغة JSON:
{"question":"...","options":["أ","ب","ج","د"],"correctIndex":0,"explanation":"..."}'''
        : '''Create one science challenge in $subject about $topic at $difficulty level.
Provide: question, 4 options, correct answer, detailed explanation.
JSON format:
{"question":"...","options":["A","B","C","D"],"correctIndex":0,"explanation":"..."}''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response.text ?? '{}';
  }
}
