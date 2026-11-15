final class ScreenContextSnapshot {
  final String screen;
  final String route;
  final Map<String, String> fields;

  const ScreenContextSnapshot({
    required this.screen,
    required this.route,
    this.fields = const {},
  });

  const ScreenContextSnapshot.unknown() : screen = 'unknown', route = '', fields = const {};
}

final class AmbientContext {
  final String interfaceLanguage;
  final String defaultProfile;
  final DateTime date;
  final String platform;

  const AmbientContext({
    required this.interfaceLanguage,
    required this.defaultProfile,
    required this.date,
    required this.platform,
  });
}
