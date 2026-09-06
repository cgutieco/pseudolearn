final class DevicePreferences {
  final double editorFontSize;
  final bool showLineNumbers;
  final bool showIndentGuides;
  final bool hasSeenOnboarding;

  const DevicePreferences({
    required this.editorFontSize,
    required this.showLineNumbers,
    required this.showIndentGuides,
    required this.hasSeenOnboarding,
  });

  const DevicePreferences.defaults()
      : editorFontSize = 14.0,
        showLineNumbers = true,
        showIndentGuides = true,
        hasSeenOnboarding = false;

  DevicePreferences copyWith({
    double? editorFontSize,
    bool? showLineNumbers,
    bool? showIndentGuides,
    bool? hasSeenOnboarding,
  }) {
    return DevicePreferences(
      editorFontSize: editorFontSize ?? this.editorFontSize,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      showIndentGuides: showIndentGuides ?? this.showIndentGuides,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  Map<String, dynamic> toJson() => {
        'editorFontSize': editorFontSize,
        'showLineNumbers': showLineNumbers,
        'showIndentGuides': showIndentGuides,
        'hasSeenOnboarding': hasSeenOnboarding,
      };

  factory DevicePreferences.fromJson(Map<String, dynamic> json) {
    return DevicePreferences(
      editorFontSize: (json['editorFontSize'] as num?)?.toDouble() ?? 14.0,
      showLineNumbers: json['showLineNumbers'] as bool? ?? true,
      showIndentGuides: json['showIndentGuides'] as bool? ?? true,
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevicePreferences &&
          runtimeType == other.runtimeType &&
          editorFontSize == other.editorFontSize &&
          showLineNumbers == other.showLineNumbers &&
          showIndentGuides == other.showIndentGuides &&
          hasSeenOnboarding == other.hasSeenOnboarding;

  @override
  int get hashCode => Object.hash(
        editorFontSize,
        showLineNumbers,
        showIndentGuides,
        hasSeenOnboarding,
      );
}
