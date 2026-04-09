import 'ai_response.dart';

/// Represents a single message in the AI chat.
///
/// Enhanced to support:
///   - Structured AI responses with actions (lab, quiz)
///   - In-chat quiz answer tracking per question
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  /// Attached AI response with structured action data.
  /// Only non-null for AI messages that carry an action payload.
  final AiResponse? aiResponse;

  /// Tracks which answer the user selected for each quiz question
  /// within a `start_quiz` message.
  /// Key: question index, Value: selected option index
  final Map<int, int> selectedAnswers;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.aiResponse,
    Map<int, int>? selectedAnswers,
  })  : timestamp = timestamp ?? DateTime.now(),
        selectedAnswers = selectedAnswers ?? {};

  // ─── Factory Constructors ────────────────────────────────────

  /// Creates a user message (plain text)
  factory ChatMessage.user(String text) => ChatMessage(
        text: text,
        isUser: true,
      );

  /// Creates a plain AI text message (no action)
  factory ChatMessage.ai(String text) => ChatMessage(
        text: text,
        isUser: false,
      );

  /// Creates an AI message with a structured response attached.
  /// The display text is pulled from [response.message].
  factory ChatMessage.aiWithResponse(AiResponse response) => ChatMessage(
        text: response.message,
        isUser: false,
        aiResponse: response,
      );

  // ─── Quiz Helpers ────────────────────────────────────────────

  /// Whether this message contains quiz questions
  bool get hasQuiz =>
      aiResponse != null &&
      aiResponse!.isQuizAction &&
      aiResponse!.questions.isNotEmpty;

  /// Whether this message contains a lab action
  bool get hasLabAction => aiResponse != null && aiResponse!.isLabAction;

  /// Whether a specific question has been answered
  bool isQuestionAnswered(int questionIndex) =>
      selectedAnswers.containsKey(questionIndex);

  /// Whether all quiz questions in this message have been answered
  bool get allQuestionsAnswered =>
      hasQuiz &&
      aiResponse!.questions.length == selectedAnswers.length;

  /// Records the user's answer for a quiz question.
  /// Returns a new [ChatMessage] with the updated answer map (immutable pattern).
  ChatMessage withAnswer(int questionIndex, int selectedOption) {
    final updated = Map<int, int>.from(selectedAnswers);
    updated[questionIndex] = selectedOption;
    return ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: timestamp,
      aiResponse: aiResponse,
      selectedAnswers: updated,
    );
  }
}
