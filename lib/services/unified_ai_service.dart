import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../models/ai_response.dart';
import '../models/chat_message.dart';

/// Production-ready AI service with Groq → Gemini fallback.
///
/// Flow:
///   1. Call Groq (Llama-3.3-70B) with a 15-second timeout.
///   2. If Groq fails (timeout, non-200, parse error) → try Gemini 2.5 Flash.
///   3. If both fail → return a friendly error [AiResponse].
///
/// API keys loaded from `.env` via `flutter_dotenv`:
///   `GROK_KEY` → Groq key, `GEMINI_KEY` → Gemini fallback key.
class UnifiedAiService {
  // ═══════════════════════════════════════════════════════════════
  //  Configuration
  // ═══════════════════════════════════════════════════════════════

  static String get _groqApiKey =>
      dotenv.env['GROK_KEY'] ?? dotenv.env['HF_KEY'] ?? '';

  static String get _geminiApiKey => dotenv.env['GEMINI_KEY'] ?? '';

  // Use llama-3.3-70b-versatile which properly supports response_format: json_object
  static const String _groqModel = 'llama-3.3-70b-versatile';

  static const String _groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const Duration _groqTimeout = Duration(seconds: 15);

  // ═══════════════════════════════════════════════════════════════
  //  Singleton
  // ═══════════════════════════════════════════════════════════════

  static final UnifiedAiService _instance = UnifiedAiService._internal();
  factory UnifiedAiService() => _instance;
  UnifiedAiService._internal();

  // Lazy-initialised Gemini model for fallback
  GenerativeModel? _geminiModel;
  GenerativeModel get _gemini {
    _geminiModel ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _geminiApiKey,
    );
    return _geminiModel!;
  }

  // ═══════════════════════════════════════════════════════════════
  //  Public Orchestrator
  // ═══════════════════════════════════════════════════════════════

  /// Sends a structured AI request.
  ///
  /// [message]  — the user's current input
  /// [mode]     — `'lab'` or `'quiz'` (selects system prompt)
  /// [history]  — previous chat messages for conversational context
  /// [isArabic] — controls the language of the system prompt & response
  ///
  /// Returns a parsed [AiResponse] with action routing data.
  Future<AiResponse> sendSmartRequest({
    required String message,
    required String mode,
    required List<ChatMessage> history,
    required bool isArabic,
  }) async {
    final systemPrompt = _buildSystemPrompt(mode: mode, isArabic: isArabic);

    // Filter history: only include actual user/AI conversation turns,
    // skip the initial greeting message (it's not a real AI response and
    // its plain-text format confuses the model into mirroring non-JSON).
    final filteredHistory = _filterHistory(history);

    // ── Attempt 1: Groq (primary) ──
    try {
      debugPrint('[UnifiedAiService] 🚀 Attempting Groq...');
      final rawJson = await _callGroq(
        systemPrompt: systemPrompt,
        message: message,
        history: filteredHistory,
      );
      debugPrint('[UnifiedAiService] ✅ Groq responded (${rawJson.length} chars)');
      final cleaned = _stripMarkdownWrapper(rawJson);
      return AiResponse.fromGeminiResponse(cleaned);
    } catch (e, st) {
      debugPrint('[UnifiedAiService] ⚠️ Groq failed: $e');
      debugPrint('[UnifiedAiService] Stack: $st');
    }

    // ── Attempt 2: Gemini (fallback) ──
    if (_geminiApiKey.isNotEmpty) {
      try {
        debugPrint('[UnifiedAiService] 🔄 Falling back to Gemini...');
        final rawJson = await _callGemini(
          systemPrompt: systemPrompt,
          message: message,
          history: filteredHistory,
          isArabic: isArabic,
        );
        debugPrint('[UnifiedAiService] ✅ Gemini responded (${rawJson.length} chars)');
        final cleaned = _stripMarkdownWrapper(rawJson);
        return AiResponse.fromGeminiResponse(cleaned);
      } catch (e, st) {
        debugPrint('[UnifiedAiService] ⚠️ Gemini fallback also failed: $e');
        debugPrint('[UnifiedAiService] Stack: $st');
      }
    } else {
      debugPrint('[UnifiedAiService] ⚠️ GEMINI_KEY not set, skipping fallback');
    }

    // ── Both failed — return friendly error ──
    return AiResponse(
      action: 'message',
      message: isArabic
          ? 'الخوادم مشغولة حالياً، يرجى المحاولة مرة أخرى بعد قليل. ⏳'
          : 'Servers are busy right now. Please try again in a moment. ⏳',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Groq HTTP Call
  // ═══════════════════════════════════════════════════════════════

  /// Calls the Groq REST API (OpenAI-compatible).
  ///
  /// Enforces JSON output via `response_format`.
  /// Throws on timeout, non-200 status, or empty body.
  Future<String> _callGroq({
    required String systemPrompt,
    required String message,
    required List<ChatMessage> history,
  }) async {
    if (_groqApiKey.isEmpty) {
      throw Exception('GROK_KEY not configured in .env');
    }

    // Build the messages array (system + history + user)
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    for (final msg in history) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    messages.add({'role': 'user', 'content': message});

    final body = jsonEncode({
      'model': _groqModel,
      'messages': messages,
      'response_format': {'type': 'json_object'},
      'temperature': 0.7,
      'max_tokens': 2048,
    });

    debugPrint('[UnifiedAiService] 📤 Groq request: model=$_groqModel, '
        'messages=${messages.length}, timeout=${_groqTimeout.inSeconds}s');

    final response = await http
        .post(
          Uri.parse(_groqEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_groqApiKey',
          },
          body: body,
        )
        .timeout(_groqTimeout);

    if (response.statusCode != 200) {
      final preview = response.body.length > 300
          ? response.body.substring(0, 300)
          : response.body;
      debugPrint('[UnifiedAiService] ❌ Groq HTTP ${response.statusCode}: $preview');
      throw Exception('Groq returned HTTP ${response.statusCode}');
    }

    // Safely decode the response
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[UnifiedAiService] ❌ Failed to decode Groq response body: $e');
      throw Exception('Groq response was not valid JSON');
    }

    final choices = decoded['choices'] as List<dynamic>?;

    if (choices == null || choices.isEmpty) {
      debugPrint('[UnifiedAiService] ❌ Groq response contained no choices');
      throw Exception('Groq response contained no choices');
    }

    // Safely navigate: choices[0] -> message -> content
    final firstChoice = choices[0];
    if (firstChoice is! Map<String, dynamic>) {
      debugPrint('[UnifiedAiService] ❌ Groq choices[0] is not a Map');
      throw Exception('Groq choices[0] is not a Map');
    }

    final messageObj = firstChoice['message'];
    if (messageObj is! Map<String, dynamic>) {
      debugPrint('[UnifiedAiService] ❌ Groq choices[0].message is not a Map');
      throw Exception('Groq choices[0].message is not a Map');
    }

    final content = messageObj['content'] as String?;

    if (content == null || content.trim().isEmpty) {
      debugPrint('[UnifiedAiService] ❌ Groq response content was empty');
      throw Exception('Groq response content was empty');
    }

    debugPrint('[UnifiedAiService] 📥 Groq raw content: '
        '${content.length > 200 ? '${content.substring(0, 200)}...' : content}');

    return content;
  }

  // ═══════════════════════════════════════════════════════════════
  //  Gemini Fallback Call
  // ═══════════════════════════════════════════════════════════════

  /// Calls Google Gemini as a fallback when Groq fails.
  Future<String> _callGemini({
    required String systemPrompt,
    required String message,
    required List<ChatMessage> history,
    required bool isArabic,
  }) async {
    // Build conversation history for the Gemini chat session
    final historyContent = <Content>[];

    for (final msg in history) {
      if (msg.isUser) {
        historyContent.add(Content('user', [TextPart(msg.text)]));
      } else {
        historyContent.add(Content('model', [TextPart(msg.text)]));
      }
    }

    // Start a chat session with system instruction baked in
    final chat = _gemini.startChat(
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

    final response = await chat.sendMessage(Content.text(message));
    final rawText = response.text ?? '';

    if (rawText.trim().isEmpty) {
      throw Exception('Gemini response was empty');
    }

    debugPrint('[UnifiedAiService] 📥 Gemini raw content: '
        '${rawText.length > 200 ? '${rawText.substring(0, 200)}...' : rawText}');

    return rawText;
  }

  // ═══════════════════════════════════════════════════════════════
  //  Helpers
  // ═══════════════════════════════════════════════════════════════

  /// Strips markdown code-block wrappers from the AI response.
  ///
  /// Handles:
  ///   - ```json ... ```
  ///   - ``` ... ```  (bare, no language tag)
  ///   - Leading/trailing whitespace
  static String _stripMarkdownWrapper(String raw) {
    var cleaned = raw.trim();

    // Remove ```json ... ``` wrapper
    final jsonBlockMatch =
        RegExp(r'^```(?:json)?\s*\n?([\s\S]*?)\n?\s*```$').firstMatch(cleaned);
    if (jsonBlockMatch != null) {
      cleaned = jsonBlockMatch.group(1)!.trim();
    }

    return cleaned;
  }

  /// Filters history to only include real conversation turns.
  ///
  /// Removes the initial greeting message (first AI message that has no
  /// aiResponse attached) to prevent poisoning the model context with
  /// a non-JSON assistant message.
  static List<ChatMessage> _filterHistory(List<ChatMessage> history) {
    if (history.isEmpty) return history;

    // Skip the very first message if it's an AI greeting (not user, no aiResponse)
    final filtered = <ChatMessage>[];
    bool skippedGreeting = false;

    for (final msg in history) {
      if (!skippedGreeting && !msg.isUser && msg.aiResponse == null) {
        // This is the greeting — skip it
        skippedGreeting = true;
        continue;
      }
      filtered.add(msg);
    }

    return filtered;
  }

  /// Selects the correct system prompt based on [mode] and [isArabic].
  String _buildSystemPrompt({
    required String mode,
    required bool isArabic,
  }) {
    if (mode == 'lab') {
      return isArabic ? _Prompts.labAr : _Prompts.labEn;
    }
    return isArabic ? _Prompts.quizAr : _Prompts.quizEn;
  }
}

// ─────────────────────────────────────────────────────────────────
//  System Prompts
// ─────────────────────────────────────────────────────────────────

/// Private prompt constants for the AI orchestrator.
/// These enforce strict JSON output from the Groq model.
class _Prompts {
  _Prompts._();

  // ─── LAB MODE (Arabic) ───
  static const String labAr = '''
أنت معلم علوم ذكي اسمك "سمارت لاب". أنت تعمل داخل تطبيق تعليمي تفاعلي.

دورك:
1. الطالب سيسألك عن موضوع علمي (كيمياء أو فيزياء).
2. اشرح له المفهوم بطريقة بسيطة وممتعة (3-5 جمل).
3. عندما يكون الشرح كافياً أو يطلب الطالب تجربة، أرسل أمر فتح المعمل مع الأدوات.

⚠️ قاعدة صارمة: يجب أن يكون ردك دائماً JSON صالح فقط — بدون أي نص خارج JSON وبدون markdown وبدون code blocks.

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
You are a smart science tutor called "Smart Lab". You work inside an interactive educational app.

Your role:
1. The student will ask about a science topic (Chemistry or Physics).
2. Explain the concept in a simple, engaging way (3-5 sentences).
3. When the explanation is sufficient or the student requests an experiment, send the open_lab command with tools.

⚠️ STRICT RULE: Your response MUST always be strictly valid JSON only — no text outside JSON, no markdown, no code blocks.

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
أنت مقيّم علمي ذكي اسمك "سمارت لاب". أنت تعمل داخل تطبيق تعليمي تفاعلي.

دورك:
1. الطالب سيخبرك بالموضوع الذي يريد اختبار نفسه فيه.
2. اسأله أولاً عن المادة والموضوع المحدد إذا لم يحدد.
3. عندما تعرف الموضوع، أنشئ 5 أسئلة اختيار من متعدد (4 خيارات لكل سؤال).

⚠️ قاعدة صارمة: يجب أن يكون ردك دائماً JSON صالح فقط — بدون أي نص خارج JSON وبدون markdown وبدون code blocks.

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
You are a smart science evaluator called "Smart Lab". You work inside an interactive educational app.

Your role:
1. The student will tell you the topic they want to be tested on.
2. First ask them about the specific subject and topic if not specified.
3. Once you know the topic, generate 5 multiple-choice questions (4 options each).

⚠️ STRICT RULE: Your response MUST always be strictly valid JSON only — no text outside JSON, no markdown, no code blocks.

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
