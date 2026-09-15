import 'dart:io';
import 'package:supabase/supabase.dart';
import '../../domain/model/account/account_deletion_outcome.dart';
import '../../domain/ports/account_deletion_gateway.dart';
import 'native_credential_source.dart';

const String deleteAccountFunctionName = 'delete-account';

final class SupabaseAccountDeletionGateway implements AccountDeletionGateway {
  final SupabaseClient _client;
  final NativeCredentialSource _credentialSource;

  const SupabaseAccountDeletionGateway({
    required SupabaseClient client,
    required NativeCredentialSource credentialSource,
  })  : _client = client,
        _credentialSource = credentialSource;

  @override
  Future<AccountDeletionOutcome> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) return const AccountDeletionRejected('no_session');
    try {
      final body = await _requestBodyFor(user);
      if (body == null) return const AccountDeletionCancelled();
      await _client.functions.invoke(deleteAccountFunctionName, body: body);
      return const AccountDeleted();
    } on FunctionsFetchException {
      return const AccountDeletionNoConnection();
    } on FunctionException catch (error) {
      return AccountDeletionRejected(rejectionCodeOf(error));
    } on SocketException {
      return const AccountDeletionNoConnection();
    } catch (_) {
      return const AccountDeletionRejected('unexpected_failure');
    }
  }

  Future<Map<String, String>?> _requestBodyFor(User user) async {
    if (!hasAppleIdentity(user)) return const <String, String>{};
    final credential = await _credentialSource.getAppleCredential();
    if (credential == null) return null;
    return {'apple_authorization_code': credential.authorizationCode};
  }
}

bool hasAppleIdentity(User user) {
  final identities = user.identities ?? const <UserIdentity>[];
  if (identities.any((identity) => identity.provider == 'apple')) return true;
  final providers = user.appMetadata['providers'];
  if (providers is List && providers.contains('apple')) return true;
  return user.appMetadata['provider'] == 'apple';
}

String rejectionCodeOf(FunctionException error) {
  final details = error.details;
  if (details is Map && details['code'] is String) {
    return details['code'] as String;
  }
  return 'http_${error.status}';
}
