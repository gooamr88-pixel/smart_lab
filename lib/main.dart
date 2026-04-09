import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/locale_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/lab_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/image_gen_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/smart_chat_provider.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env (API keys)
  await dotenv.load(fileName: ".env");

  // Pre-load user progress
  final progressProvider = ProgressProvider();
  await progressProvider.loadProgress();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LabProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ImageGenProvider()),
        ChangeNotifierProvider(create: (_) => SmartChatProvider()),
        ChangeNotifierProvider.value(value: progressProvider),
      ],
      child: const SmartLabApp(),
    ),
  );
}