import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure wrapper around dotenv for accessing API keys.
/// All keys are loaded from `.env` at the project root.
/// NEVER hardcode any key in source code.
class EnvConfig {
  EnvConfig._();

  /// Gemini API key for google_generative_ai
  static String get geminiKey => dotenv.env['GEMINI_KEY'] ?? '';

  /// Grok API key (for future use)
  static String get grokKey => dotenv.env['GROK_KEY'] ?? '';

  /// Hugging Face API key (for future use)
  static String get hfKey => dotenv.env['HF_KEY'] ?? '';

  /// Validates that required keys are present
  static bool get isGeminiConfigured => geminiKey.isNotEmpty;

  /// Debug: prints key availability (never prints actual keys)
  static Map<String, bool> get keyStatus => {
    'GEMINI_KEY': geminiKey.isNotEmpty,
    'GROK_KEY': grokKey.isNotEmpty,
    'HF_KEY': hfKey.isNotEmpty,
  };
}
