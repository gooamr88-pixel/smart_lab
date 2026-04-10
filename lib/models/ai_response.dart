import 'dart:convert';
import 'quiz_question.dart';

/// Unified AI response model for the Smart Chat orchestrator.
///
/// Parses structured JSON from the Gemini response to determine
/// which action the Flutter app should take:
///   - `message`    → plain text, render as normal chat bubble
///   - `open_lab`   → navigate to VirtualLabScreen with tools
///   - `start_quiz` → render interactive quiz buttons in-chat
class AiResponse {
  /// The action type: 'message', 'open_lab', or 'start_quiz'
  final String action;

  /// Human-readable text from the AI (always present)
  final String message;

  /// Tool names for `open_lab` action (e.g. ["sodium", "water", "beaker"])
  final List<String> tools;

  /// Quiz questions for `start_quiz` action
  final List<QuizQuestion> questions;

  /// Subject for `open_lab` action: 'chemistry' or 'physics'
  /// Auto-detected from tool names if not provided by AI.
  final String subject;

  const AiResponse({
    required this.action,
    required this.message,
    this.tools = const [],
    this.questions = const [],
    this.subject = 'chemistry',
  });

  /// Creates a plain text response (no special action)
  factory AiResponse.message(String text) => AiResponse(
        action: 'message',
        message: text,
      );

  /// Whether this response triggers a lab navigation
  bool get isLabAction => action == 'open_lab';

  /// Whether this response triggers quiz rendering
  bool get isQuizAction => action == 'start_quiz';

  /// Whether this is a plain message with no special action
  bool get isPlainMessage => action == 'message';

  /// Whether the lab is a physics experiment
  bool get isPhysics => subject == 'physics';

  /// Whether the lab is a chemistry experiment
  bool get isChemistry => subject == 'chemistry';

  /// Parses the raw Gemini response text into a structured [AiResponse].
  ///
  /// Strategy:
  /// 1. Try to extract a JSON object `{...}` from the response
  /// 2. Parse the `action` field to determine intent
  /// 3. Extract `tools` or `questions` based on the action
  /// 4. Capture any text outside the JSON as the `message`
  /// 5. Fallback to plain `message` action if no valid JSON found
  factory AiResponse.fromGeminiResponse(String raw) {
    if (raw.trim().isEmpty) {
      return AiResponse.message('...');
    }

    try {
      // ── Step 1: Find the outermost JSON object ──
      final jsonObject = _extractJsonObject(raw);
      if (jsonObject == null) {
        // No JSON found — treat entire response as plain text
        return AiResponse.message(raw.trim());
      }

      // ── Step 2: Parse the JSON ──
      final Map<String, dynamic> json =
          jsonDecode(jsonObject) as Map<String, dynamic>;

      final action = (json['action'] as String?)?.toLowerCase().trim() ?? '';
      final jsonMessage = json['message'] as String? ?? '';

      // ── Step 3: Extract text outside the JSON block ──
      final textOutsideJson = raw
          .replaceFirst(jsonObject, '')
          .trim()
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'```\s*$', multiLine: true), '')
          .trim();

      // Combine: prefer the JSON message, append text outside if available
      final combinedMessage = jsonMessage.isNotEmpty
          ? jsonMessage
          : textOutsideJson.isNotEmpty
              ? textOutsideJson
              : raw.trim();

      // ── Step 4: Route by action ──
      switch (action) {
        case 'open_lab':
          final toolsList = _parseStringList(json['tools']);
          final rawSubject = (json['subject'] as String?)?.toLowerCase().trim();
          final detectedSubject = rawSubject == 'physics' || rawSubject == 'فيزياء'
              ? 'physics'
              : rawSubject == 'chemistry' || rawSubject == 'كيمياء'
                  ? 'chemistry'
                  : _detectSubject(toolsList);
          return AiResponse(
            action: 'open_lab',
            message: combinedMessage,
            tools: toolsList,
            subject: detectedSubject,
          );

        case 'start_quiz':
          final questions = _parseQuestions(json['questions']);
          return AiResponse(
            action: 'start_quiz',
            message: combinedMessage,
            questions: questions,
          );

        default:
          // Unknown action or 'message' — treat as plain text
          return AiResponse(
            action: 'message',
            message: combinedMessage,
          );
      }
    } catch (_) {
      // Any parsing error → graceful fallback to plain text
      return AiResponse.message(raw.trim());
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Private helpers
  // ─────────────────────────────────────────────────────────────

  /// Extracts the first valid JSON object `{...}` from the raw text,
  /// handling nested braces correctly.
  static String? _extractJsonObject(String raw) {
    // First, try to find JSON inside ```json ... ``` or bare ``` ... ``` code blocks
    // Handles: ```json, ```JSON, ``` (bare), ```text, etc.
    final codeBlockMatch =
        RegExp(r'```(?:json|JSON)?\s*\n?([\s\S]*?)\n?\s*```').firstMatch(raw);
    if (codeBlockMatch != null) {
      final candidate = codeBlockMatch.group(1)!.trim();
      if (_isValidJson(candidate)) return candidate;
    }

    // Fallback: find the first `{` and match to its closing `}`
    final startIndex = raw.indexOf('{');
    if (startIndex == -1) return null;

    int depth = 0;
    bool inString = false;
    bool escape = false;

    for (int i = startIndex; i < raw.length; i++) {
      final char = raw[i];

      if (escape) {
        escape = false;
        continue;
      }

      if (char == '\\') {
        escape = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          final candidate = raw.substring(startIndex, i + 1);
          if (_isValidJson(candidate)) return candidate;
          // If invalid, keep searching
          break;
        }
      }
    }

    return null;
  }

  /// Validates that a string is parseable JSON
  static bool _isValidJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Safely parses a JSON field into a `List<String>`
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
  }

  /// Safely parses a JSON field into a `List<QuizQuestion>`
  static List<QuizQuestion> _parseQuestions(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    final result = <QuizQuestion>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(QuizQuestion.fromJson(item));
        } catch (_) {
          // Skip malformed questions
        }
      }
    }
    return result;
  }

  /// Detects whether tools indicate physics or chemistry.
  static String _detectSubject(List<String> tools) {
    const physicsKeywords = {
      'cannon', 'projectile', 'ball', 'ramp', 'incline', 'spring',
      'pendulum', 'pulley', 'lever', 'velocity', 'acceleration',
      'angle', 'gravity', 'friction', 'force', 'mass', 'weight',
      'protractor', 'stopwatch', 'trajectory', 'launcher',
      // Arabic
      'مدفع', 'مقذوف', 'كرة', 'منحدر', 'زنبرك', 'بندول',
      'بكرة', 'رافعة', 'سرعة', 'تسارع', 'زاوية', 'جاذبية',
      'احتكاك', 'قوة', 'كتلة', 'وزن', 'مسار',
    };

    final allText = tools.join(' ').toLowerCase();
    for (final kw in physicsKeywords) {
      if (allText.contains(kw)) return 'physics';
    }
    return 'chemistry';
  }

  @override
  String toString() =>
      'AiResponse(action: $action, subject: $subject, '
      'message: ${message.length > 50 ? '${message.substring(0, 50)}...' : message}, '
      'tools: ${tools.length}, questions: ${questions.length})';
}
