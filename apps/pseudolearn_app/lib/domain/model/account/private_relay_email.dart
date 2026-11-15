const String _applePrivateRelayDomain = '@privaterelay.appleid.com';

bool isApplePrivateRelayEmail(String? email) {
  final address = email?.trim().toLowerCase() ?? '';
  return address.endsWith(_applePrivateRelayDomain);
}
