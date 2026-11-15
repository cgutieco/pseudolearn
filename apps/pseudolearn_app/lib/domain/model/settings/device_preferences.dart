final class DevicePreferences {
  final double editorFontSize;
  final bool showLineNumbers;
  final bool showIndentGuides;
  final bool hasSeenOnboarding;
  final bool editorAssistance;
  final bool agentLauncherShown;

  const DevicePreferences({
    required this.editorFontSize,
    required this.showLineNumbers,
    required this.showIndentGuides,
    required this.hasSeenOnboarding,
    this.editorAssistance = false,
    this.agentLauncherShown = true,
  });

  const DevicePreferences.defaults()
      : editorFontSize = 14.0,
        showLineNumbers = true,
        showIndentGuides = true,
        hasSeenOnboarding = false,
        editorAssistance = false,
        agentLauncherShown = true;

  DevicePreferences copyWith({
    double? editorFontSize,
    bool? showLineNumbers,
    bool? showIndentGuides,
    bool? hasSeenOnboarding,
    bool? editorAssistance,
    bool? agentLauncherShown,
  }) {
    return DevicePreferences(
      editorFontSize: editorFontSize ?? this.editorFontSize,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      showIndentGuides: showIndentGuides ?? this.showIndentGuides,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      editorAssistance: editorAssistance ?? this.editorAssistance,
      agentLauncherShown: agentLauncherShown ?? this.agentLauncherShown,
    );
  }

  Map<String, dynamic> toJson() => {
        'editorFontSize': editorFontSize,
        'showLineNumbers': showLineNumbers,
        'showIndentGuides': showIndentGuides,
        'hasSeenOnboarding': hasSeenOnboarding,
        'editorAssistance': editorAssistance,
        'agentLauncherShown': agentLauncherShown,
      };

  factory DevicePreferences.fromJson(Map<String, dynamic> json) {
    return DevicePreferences(
      editorFontSize: (json['editorFontSize'] as num?)?.toDouble() ?? 14.0,
      showLineNumbers: json['showLineNumbers'] as bool? ?? true,
      showIndentGuides: json['showIndentGuides'] as bool? ?? true,
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
      editorAssistance: json['editorAssistance'] as bool? ?? false,
      agentLauncherShown: json['agentLauncherShown'] as bool? ?? true,
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
          hasSeenOnboarding == other.hasSeenOnboarding &&
          editorAssistance == other.editorAssistance &&
          agentLauncherShown == other.agentLauncherShown;

  @override
  int get hashCode => Object.hash(
        editorFontSize,
        showLineNumbers,
        showIndentGuides,
        hasSeenOnboarding,
        editorAssistance,
        agentLauncherShown,
      );
}
