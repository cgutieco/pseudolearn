import 'dart:io';

final class GoogleClientIds {
  final String? clientId;
  final String? serverClientId;
  final bool isSufficientForNativeSignIn;

  const GoogleClientIds({this.clientId, this.serverClientId, this.isSufficientForNativeSignIn = false});
}

const String _appleClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
const String _webClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

GoogleClientIds _appleIdentifiesItsOwnClient(String appleClientId, String webClientId) =>
    GoogleClientIds(clientId: _configured(appleClientId), isSufficientForNativeSignIn: true);

GoogleClientIds _androidNeedsTheWebClientAsAudience(String appleClientId, String webClientId) =>
    GoogleClientIds(
      serverClientId: _configured(webClientId),
      isSufficientForNativeSignIn: webClientId.isNotEmpty,
    );

const Map<String, GoogleClientIds Function(String appleClientId, String webClientId)> _byOperatingSystem = {
  'ios': _appleIdentifiesItsOwnClient,
  'macos': _appleIdentifiesItsOwnClient,
  'android': _androidNeedsTheWebClientAsAudience,
};

GoogleClientIds googleClientIdsFor(
  String operatingSystem, {
  String appleClientId = _appleClientId,
  String webClientId = _webClientId,
}) {
  final select = _byOperatingSystem[operatingSystem];
  return select == null ? const GoogleClientIds() : select(appleClientId, webClientId);
}

GoogleClientIds currentGoogleClientIds() => googleClientIdsFor(Platform.operatingSystem);

String? _configured(String value) => value.isEmpty ? null : value;
