import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';

/// Root MaterialApp with Provider, localization, and theming
class SmartLabApp extends StatelessWidget {
  const SmartLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بساريا',

      // Theme
      theme: AppTheme.darkTheme,

      // Localization
      locale: locale.locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Set text direction based on locale
      builder: (context, child) {
        return Directionality(
          textDirection: locale.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },

      // Entry screen — now starts with splash
      home: const SplashScreen(),
    );
  }
}
