import 'package:pseudolearn_app/data/auth/native_credential_source.dart';

final class FakeNativeCredentialSource implements NativeCredentialSource {
  NativeAppleCredential? appleCredential;
  NativeGoogleCredential? googleCredential;
  bool throwError = false;
  int appleCredentialRequests = 0;

  @override
  Future<NativeAppleCredential?> getAppleCredential() async {
    appleCredentialRequests++;
    if (throwError) throw Exception('Apple native failure');
    return appleCredential;
  }

  @override
  Future<NativeGoogleCredential?> getGoogleCredential() async {
    if (throwError) throw Exception('Google native failure');
    return googleCredential;
  }
}
