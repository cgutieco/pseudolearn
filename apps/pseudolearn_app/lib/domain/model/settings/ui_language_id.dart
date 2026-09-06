enum UiLanguageId {
  system,
  spanish,
  english;

  String resolveLocaleCode(String? systemLanguageCode) {
    switch (this) {
      case UiLanguageId.spanish:
        return 'es';
      case UiLanguageId.english:
        return 'en';
      case UiLanguageId.system:
        if (systemLanguageCode == 'en') {
          return 'en';
        }
        return 'es';
    }
  }
}
