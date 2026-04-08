import 'package:flutter/material.dart';

/// Provider for managing the app's locale (Arabic / English).
/// In-memory only for MVP — locale resets on app restart.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar'); // Default to Arabic

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  void toggleLocale() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }
}
