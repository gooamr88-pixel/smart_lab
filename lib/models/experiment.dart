/// A single lab tool required for an experiment
class LabTool {
  final String name;
  final String reason;
  final String? modelAssetPath;

  const LabTool({
    required this.name,
    required this.reason,
    this.modelAssetPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LabTool && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => '$name: $reason';
}

/// Represents a complete experiment parsed from AI response
class Experiment {
  final String name;
  final String subject;
  final List<LabTool> tools;
  final String? warning;
  final String rawResponse;

  const Experiment({
    required this.name,
    required this.subject,
    required this.tools,
    this.warning,
    required this.rawResponse,
  });

  /// Parses the AI's bullet-point response into structured data
  factory Experiment.fromAiResponse({
    required String name,
    required String subject,
    required String response,
  }) {
    final lines = response.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final tools = <LabTool>[];
    String? warning;

    for (final line in lines) {
      final trimmed = line.trim();

      // Detect warning lines (contains ⚠️ or تحذير or Warning)
      if (trimmed.contains('⚠') ||
          trimmed.contains('تحذير') ||
          trimmed.contains('Warning') ||
          trimmed.contains('خطر') ||
          trimmed.contains('Danger')) {
        warning = trimmed.replaceAll(RegExp(r'^[-•*⚠️\s]+'), '');
        continue;
      }

      // Parse bullet points: "- Tool Name: reason" or "• Tool Name - reason"
      final bulletMatch = RegExp(r'^[-•*]\s*(.+?)(?:[:–-]\s*(.+))?$').firstMatch(trimmed);
      if (bulletMatch != null) {
        final toolName = bulletMatch.group(1)?.trim() ?? trimmed;
        final reason = bulletMatch.group(2)?.trim() ?? '';
        tools.add(LabTool(name: toolName, reason: reason));
      }
    }

    return Experiment(
      name: name,
      subject: subject,
      tools: tools,
      warning: warning,
      rawResponse: response,
    );
  }

  bool get hasDangerWarning => warning != null && warning!.isNotEmpty;
}
