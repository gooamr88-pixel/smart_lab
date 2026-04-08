import 'package:flutter/material.dart';
import 'lang/ar.dart';
import 'lang/en.dart';

/// Custom localization system for Smart Lab (Arabic / English)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': arStrings,
    'en': enStrings,
  };

  /// Get a translated string by key
  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  /// Whether the current locale is Arabic (RTL)
  bool get isArabic => locale.languageCode == 'ar';

  /// Text direction based on locale
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
