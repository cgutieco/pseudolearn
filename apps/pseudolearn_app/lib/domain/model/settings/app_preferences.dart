import 'account_preferences.dart';
import 'app_theme_mode.dart';
import 'device_preferences.dart';
import 'ui_language_id.dart';

final class AppPreferences {
  final AccountPreferences account;
  final DevicePreferences device;

  UiLanguageId get language => account.language;
  AppThemeMode get themeMode => account.themeMode;
  bool get isDarkMode => account.isDarkMode;
  bool get assistedDiagramZoom => account.assistedDiagramZoom;

  double get editorFontSize => device.editorFontSize;
  bool get showLineNumbers => device.showLineNumbers;
  bool get showIndentGuides => device.showIndentGuides;
  bool get hasSeenOnboarding => device.hasSeenOnboarding;

  const AppPreferences({
    required this.account,
    required this.device,
  });

  const AppPreferences.defaults()
      : account = const AccountPreferences.defaults(),
        device = const DevicePreferences.defaults();

  AppPreferences copyWith({
    AccountPreferences? account,
    DevicePreferences? device,
    UiLanguageId? language,
    AppThemeMode? themeMode,
    bool? isDarkMode,
    double? editorFontSize,
    bool? showLineNumbers,
    bool? showIndentGuides,
    bool? assistedDiagramZoom,
    bool? hasSeenOnboarding,
  }) {
    final effectiveAccount = account ??
        this.account.copyWith(
              language: language,
              themeMode: themeMode,
              isDarkMode: isDarkMode,
              assistedDiagramZoom: assistedDiagramZoom,
            );
    final effectiveDevice = device ??
        this.device.copyWith(
              editorFontSize: editorFontSize,
              showLineNumbers: showLineNumbers,
              showIndentGuides: showIndentGuides,
              hasSeenOnboarding: hasSeenOnboarding,
            );
    return AppPreferences(
      account: effectiveAccount,
      device: effectiveDevice,
    );
  }

  Map<String, dynamic> toJson() => {
        'account': account.toJson(),
        'device': device.toJson(),
        ...account.toJson(),
        ...device.toJson(),
      };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    final accountJson = json['account'];
    final deviceJson = json['device'];

    final account = accountJson is Map<String, dynamic>
        ? AccountPreferences.fromJson(accountJson)
        : AccountPreferences.fromJson(json);

    final device = deviceJson is Map<String, dynamic>
        ? DevicePreferences.fromJson(deviceJson)
        : DevicePreferences.fromJson(json);

    return AppPreferences(
      account: account,
      device: device,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppPreferences &&
          runtimeType == other.runtimeType &&
          account == other.account &&
          device == other.device;

  @override
  int get hashCode => Object.hash(account, device);
}
