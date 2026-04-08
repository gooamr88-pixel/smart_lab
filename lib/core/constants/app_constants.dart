import 'package:flutter/material.dart';

/// App-wide color constants and design tokens
class AppColors {
  AppColors._();

  // Primary Gradient
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color primaryMid = Color(0xFF1A2980);
  static const Color primaryLight = Color(0xFF26D0CE);
  static const Color accent = Color(0xFF00F5D4);

  // Subject Colors
  static const Color chemistry = Color(0xFF00B4D8);
  static const Color chemistryDark = Color(0xFF0077B6);
  static const Color physics = Color(0xFF7B2FF7);
  static const Color physicsDark = Color(0xFF5A189A);

  // Surface Colors
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1F2937);
  static const Color surfaceCard = Color(0xFF1E293B);
  static const Color surfaceOverlay = Color(0x33FFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF64748B);

  // Status Colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color danger = Color(0xFFFF5252);

  // Chat Colors
  static const Color userBubble = Color(0xFF26D0CE);
  static const Color aiBubble = Color(0xFF1E293B);

  // Roadmap Colors
  static const Color roadmapAi = Color(0xFF6C63FF);
  static const Color roadmapLab = Color(0xFF00BFA6);
  static const Color roadmapQuiz = Color(0xFFFF6B6B);
}

/// Gradient presets used across the app
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryDark, AppColors.primaryMid, AppColors.primaryLight],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient dark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryDark, AppColors.surface],
  );

  static const LinearGradient chemistry = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.chemistryDark, AppColors.chemistry],
  );

  static const LinearGradient physics = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.physicsDark, AppColors.physics],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );

  static const LinearGradient roadmapAi = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
  );

  static const LinearGradient roadmapLab = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BFA6), Color(0xFF00897B)],
  );

  static const LinearGradient roadmapQuiz = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
  );
}

/// Animation durations
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration splash = Duration(milliseconds: 1500);
}

/// Gemini AI system prompts
class AppPrompts {
  AppPrompts._();

  static const String labExpertAr = '''
أنت خبير مختبرات علمية صارم. كن مباشراً ومحدداً.
اكتب الأدوات المطلوبة فقط كقائمة مرقمة:
لكل أداة اكتب: اسم الأداة — سبب استخدامها (جملة واحدة)
إذا كانت التجربة خطيرة، أضف سطر تحذير واحد فقط ⚠️
في النهاية اكتب: "✅ الأدوات جاهزة! اضغط 'ابدأ المعمل' للانتقال للمعمل الافتراضي."
ممنوع: تحيات، مقدمات نظرية، كلام زيادة. ابدأ مباشرة.
''';

  static const String labExpertEn = '''
You are a strict scientific lab expert. Be direct and specific.
List ONLY the required tools as a numbered list:
For each tool write: Tool name — reason for use (one sentence)
If dangerous, add ONE warning line ⚠️
At the end write: "✅ Tools ready! Press 'Start Lab' to enter the virtual lab."
NO greetings, NO theory, NO rambling. Start directly.
''';

  static const String quizExpertAr = '''
أنت مقيّم معملي عملي. أنشئ 5 أسئلة اختيار من متعدد (4 خيارات).
الأسئلة يجب أن تكون عملية ومعملية:
- "لماذا نستخدم هذه الأداة وليس تلك؟"
- "ماذا يحدث لو استخدمنا الأداة الخاطئة؟"
- "ما النتيجة الصحيحة لهذا التفاعل؟"
- "لو غيّرنا متغيراً معيناً، ماذا سيتغير؟"
الشرح يجب أن يوضح السبب العلمي بشكل عملي.
أجب بصيغة JSON فقط:
[{"question": "...", "options": ["أ","ب","ج","د"], "correctIndex": 0, "explanation": "..."}]
''';

  static const String quizExpertEn = '''
You are a practical lab evaluator. Create 5 multiple-choice questions (4 options each).
Questions MUST be practical and lab-focused:
- "Why do we use this tool instead of that one?"
- "What happens if we use the wrong tool/chemical?"
- "What is the correct result of this reaction?"
- "If we change a variable, what changes?"
Explanations must give the practical scientific reason.
Respond in JSON format ONLY:
[{"question": "...", "options": ["A","B","C","D"], "correctIndex": 0, "explanation": "..."}]
''';

  static const String topicQuizAr = '''
أنت مقيّم معملي عملي. أنشئ 5 أسئلة اختيار من متعدد (4 خيارات) عن الموضوع المطلوب.
الأسئلة يجب أن تكون عملية وتطبيقية كأنك في معمل حقيقي:
- "لماذا نستخدم هذا وليس ذاك؟"
- "ماذا يحدث لو استخدمنا الخطأ؟"
- "إذا استخدمنا الصح، ما النتيجة؟"
- "لو غيرنا متغير، ماذا يتغير؟"
كل شرح يوضح السبب العلمي بشكل عملي.
أجب بصيغة JSON فقط:
[{"question": "...", "options": ["أ","ب","ج","د"], "correctIndex": 0, "explanation": "..."}]
''';

  static const String topicQuizEn = '''
You are a practical lab evaluator. Create 5 multiple-choice questions (4 options each) on the requested topic.
Questions MUST be practical and applied, as if in a real lab:
- "Why do we use this instead of that?"
- "What happens if we use the wrong one?"
- "If we use the correct one, what's the result?"
- "If we change a variable, what changes?"
Each explanation must give the practical scientific reason.
Respond in JSON format ONLY:
[{"question": "...", "options": ["A","B","C","D"], "correctIndex": 0, "explanation": "..."}]
''';

  static const String generalAssistantAr = '''
أنت مساعد ذكي متعدد المعارف. يمكنك الإجابة على أي سؤال في أي مجال:
علوم، رياضيات، تاريخ، جغرافيا، لغات، برمجة، ثقافة عامة، نصائح حياتية، وأي شيء آخر.
أجب بطريقة واضحة وبسيطة ومفيدة.
استخدم أمثلة من الحياة اليومية لتوضيح المفاهيم.
استخدم الإيموجي المناسبة لجعل الشرح ممتعاً 🎯
اجعل إجاباتك مختصرة ومفيدة.
إذا كان السؤال عن الكيمياء أو الفيزياء، أعطِ إجابة علمية دقيقة.
''';

  static const String generalAssistantEn = '''
You are a smart, versatile assistant. You can answer any question on any topic:
science, math, history, geography, languages, programming, general knowledge, life advice, and anything else.
Answer in a clear, simple, and helpful manner.
Use real-life examples to clarify concepts.
Use appropriate emojis to make explanations fun 🎯
Keep your answers concise and useful.
If the question is about Chemistry or Physics, give a precise scientific answer.
''';
}
