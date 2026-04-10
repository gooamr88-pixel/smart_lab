import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/ai_response.dart';
import '../models/chat_message.dart';

/// Production-ready AI service powered exclusively by Groq (Llama-3 70B).
///
/// Flow:
///   1. Call Groq with a 15-second timeout.
///   2. If Groq fails (timeout, non-200, parse error) → return a friendly
///      error [AiResponse] immediately.
///
/// API key is loaded from `.env` via `flutter_dotenv`:
///   `GROK_KEY` → primary, `HF_KEY` → fallback env var name.
class UnifiedAiService {
  // ═══════════════════════════════════════════════════════════════
  //  Configuration
  // ═══════════════════════════════════════════════════════════════

  static String get _apiKey =>
      dotenv.env['GROK_KEY'] ?? dotenv.env['HF_KEY'] ?? '';

  static const String _model = 'llama3-70b-8192';

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const Duration _timeout = Duration(seconds: 15);

  // ═══════════════════════════════════════════════════════════════
  //  Singleton
  // ═══════════════════════════════════════════════════════════════

  static final UnifiedAiService _instance = UnifiedAiService._internal();
  factory UnifiedAiService() => _instance;
  UnifiedAiService._internal();

  // ═══════════════════════════════════════════════════════════════
  //  Public Orchestrator
  // ═══════════════════════════════════════════════════════════════

  /// Sends a structured AI request to Groq.
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

    try {
      final rawJson = await _callGroq(
        systemPrompt: systemPrompt,
        message: message,
        history: history,
      );
      return AiResponse.fromGeminiResponse(rawJson);
    } catch (e) {
      debugPrint('[UnifiedAiService] ⚠️ Groq request failed: $e');
    }

    // ── Groq failed — return friendly error ──
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
    if (_apiKey.isEmpty) {
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
      'model': _model,
      'messages': messages,
      'response_format': {'type': 'json_object'},
      'temperature': 0.7,
      'max_tokens': 2048,
    });

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      debugPrint('[UnifiedAiService] ❌ Groq HTTP ${response.statusCode}: '
          '${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
      throw Exception('Groq returned HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;

    if (choices == null || choices.isEmpty) {
      debugPrint('[UnifiedAiService] ❌ Groq response contained no choices');
      throw Exception('Groq response contained no choices');
    }

    final content =
        (choices[0]['message'] as Map<String, dynamic>)['content'] as String?;

    if (content == null || content.trim().isEmpty) {
      debugPrint('[UnifiedAiService] ❌ Groq response content was empty');
      throw Exception('Groq response content was empty');
    }

    return content;
  }

  // ═══════════════════════════════════════════════════════════════
  //  System Prompt Builder
  // ═══════════════════════════════════════════════════════════════

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
