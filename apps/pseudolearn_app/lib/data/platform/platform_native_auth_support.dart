import 'dart:io';

import '../auth/native_auth_support.dart';

final class PlatformNativeAuthSupport implements NativeAuthSupport {
  const PlatformNativeAuthSupport();

  @override
  bool get isAppleSupported => Platform.isMacOS || Platform.isIOS;

  @override
  bool get isGoogleSupported =>
      Platform.isMacOS || Platform.isIOS || Platform.isAndroid;
}
