import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/utils/env_config.dart';
import '../core/constants/app_constants.dart';
import '../models/ai_response.dart';
import '../models/chat_message.dart';

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

  // ═══════════════════════════════════════════════════════════════
  //  SMART ORCHESTRATOR — Structured JSON Responses
  // ═══════════════════════════════════════════════════════════════

  /// Sends a message through the smart AI orchestrator.
  ///
  /// The AI is instructed via strict system prompts to return
  /// structured JSON payloads with an `action` field that the
  /// Flutter app uses to route navigation.
  ///
  /// [message]  — the user's current input
  /// [mode]     — 'lab' or 'quiz' (determines the system prompt)
  /// [history]  — previous messages for conversational context
  /// [isArabic] — language for the AI response
  ///
  /// Returns a parsed [AiResponse] with action routing data.
  Future<AiResponse> sendSmartRequest({
    required String message,
    required String mode,
    List<ChatMessage> history = const [],
    required bool isArabic,
  }) async {
    if (!isConfigured) {
      throw Exception('GEMINI_KEY not configured in .env');
    }

    // ── Build the system prompt based on mode ──
    final systemPrompt = mode == 'lab'
        ? (isArabic ? _SmartPrompts.labAr : _SmartPrompts.labEn)
        : (isArabic ? _SmartPrompts.quizAr : _SmartPrompts.quizEn);

    // ── Build conversation history for context ──
    final historyContent = <Content>[];
    for (final msg in history) {
      if (msg.isUser) {
        historyContent.add(Content('user', [TextPart(msg.text)]));
      } else {
        historyContent.add(Content('model', [TextPart(msg.text)]));
      }
    }

    // ── Start a chat session with system instruction ──
    final chat = model.startChat(
      history: [
        Content('user', [TextPart(systemPrompt)]),
        Content('model', [
          TextPart(isArabic
              ? 'فهمت. سأرد دائماً بصيغة JSON المطلوبة.'
              : 'Understood. I will always respond in the required JSON format.')
        ]),
        ...historyContent,
      ],
    );

    // ── Send the user's message ──
    final response = await chat.sendMessage(Content.text(message));
    final rawText = response.text ?? '';

    // ── Parse into structured AiResponse ──
    return AiResponse.fromGeminiResponse(rawText);
  }
}

// ─────────────────────────────────────────────────────────────────
//  Smart Orchestrator System Prompts
// ─────────────────────────────────────────────────────────────────

/// Private prompt constants for the smart chat orchestrator.
/// These enforce strict JSON output from the Gemini model.
class _SmartPrompts {
  _SmartPrompts._();

  // ─── LAB MODE (Arabic) ───
  static const String labAr = '''
أنت معلم علوم ذكي اسمك "Skillify". أنت تعمل داخل تطبيق تعليمي تفاعلي.

دورك:
1. الطالب سيسألك عن موضوع علمي (كيمياء أو فيزياء).
2. اشرح له المفهوم بطريقة بسيطة وممتعة (3-5 جمل).
3. عندما يكون الشرح كافياً أو يطلب الطالب تجربة، أرسل أمر فتح المعمل مع الأدوات.

⚠️ قاعدة صارمة: يجب أن يكون ردك دائماً JSON فقط بالشكل التالي:

للرد العادي (شرح مفهوم):
{"action": "message", "message": "نص الشرح هنا"}

لفتح المعمل الافتراضي:
{"action": "open_lab", "subject": "كيمياء", "message": "نص تمهيدي", "tools": ["أداة_1", "أداة_2"]}

ملاحظات:
- حقل subject إجباري: إما "كيمياء" أو "فيزياء".
- لا تكتب أي نص خارج JSON أبداً.
- لا تستخدم markdown أو code blocks.
- للكيمياء: الأدوات أسماء معملية (دورق، ميزان، حمض الهيدروكلوريك).
- للفيزياء: الأدوات مثل (مدفع، كرة، مقياس زاوية، ساعة إيقاف، مسار مقذوف).
- اجعل الشرح ممتعاً واستخدم إيموجي مناسبة 🔬.
- عندما يطلب الطالب "تجربة" أو "معمل" أو "أريد أجرب"، أرسل open_lab فوراً.
''';

  // ─── LAB MODE (English) ───
  static const String labEn = '''
You are a smart science tutor called "Skillify". You work inside an interactive educational app.

Your role:
1. The student will ask about a science topic (Chemistry or Physics).
2. Explain the concept in a simple, engaging way (3-5 sentences).
3. When the explanation is sufficient or the student requests an experiment, send the open_lab command with tools.

⚠️ STRICT RULE: Your response MUST always be valid JSON only, in this exact format:

For a regular reply (explaining a concept):
{"action": "message", "message": "Your explanation text here"}

To open the virtual lab:
{"action": "open_lab", "subject": "chemistry", "message": "Introductory text", "tools": ["tool_1", "tool_2"]}

Rules:
- The "subject" field is REQUIRED: either "chemistry" or "physics".
- NEVER write any text outside the JSON object.
- Do NOT use markdown or code blocks.
- For chemistry: tools are lab equipment (e.g., beaker, sodium, hydrochloric acid).
- For physics: tools are equipment (e.g., cannon, ball, protractor, stopwatch, projectile trajectory).
- Make explanations engaging and use appropriate emojis 🔬.
- When the student says "experiment", "lab", "I want to try", send open_lab immediately.
''';

  // ─── QUIZ MODE (Arabic) ───
  static const String quizAr = '''
أنت مقيّم علمي ذكي اسمك "Skillify". أنت تعمل داخل تطبيق تعليمي تفاعلي.

دورك:
1. الطالب سيخبرك بالموضوع الذي يريد اختبار نفسه فيه.
2. اسأله أولاً عن المادة والموضوع المحدد إذا لم يحدد.
3. عندما تعرف الموضوع، أنشئ 5 أسئلة اختيار من متعدد (4 خيارات لكل سؤال).

⚠️ قاعدة صارمة: يجب أن يكون ردك دائماً JSON فقط بالشكل التالي:

للرد العادي (سؤال توضيحي):
{"action": "message", "message": "نص السؤال أو الرد هنا"}

لبدء الاختبار:
{"action": "start_quiz", "message": "نص تمهيدي قبل الاختبار", "questions": [
  {"question": "نص السؤال", "options": ["خيار أ", "خيار ب", "خيار ج", "خيار د"], "correctIndex": 0, "explanation": "شرح الإجابة الصحيحة"}
]}

ملاحظات:
- لا تكتب أي نص خارج JSON أبداً.
- لا تستخدم markdown أو code blocks.
- الأسئلة يجب أن تكون عملية ومعملية وليست نظرية فقط.
- correctIndex يبدأ من 0.
- إذا أخطأ الطالب كثيراً، اقترح عليه الذهاب للمعمل الافتراضي لممارسة التجربة.
- اجعل الأسئلة متدرجة الصعوبة.
''';

  // ─── QUIZ MODE (English) ───
  static const String quizEn = '''
You are a smart science evaluator called "Skillify". You work inside an interactive educational app.

Your role:
1. The student will tell you the topic they want to be tested on.
2. First ask them about the specific subject and topic if not specified.
3. Once you know the topic, generate 5 multiple-choice questions (4 options each).

⚠️ STRICT RULE: Your response MUST always be valid JSON only, in this exact format:

For a regular reply (asking clarification):
{"action": "message", "message": "Your question or reply text here"}

To start the quiz:
{"action": "start_quiz", "message": "Introductory text before the quiz", "questions": [
  {"question": "Question text", "options": ["Option A", "Option B", "Option C", "Option D"], "correctIndex": 0, "explanation": "Explanation of the correct answer"}
]}

Rules:
- NEVER write any text outside the JSON object.
- Do NOT use markdown or code blocks.
- Questions must be practical and lab-focused, not purely theoretical.
- correctIndex starts from 0.
- If the student fails many questions, suggest going to the virtual lab to practice.
- Questions should be progressively harder.
''';
}
