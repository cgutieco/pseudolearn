import 'package:supabase/supabase.dart';
import '../../domain/ports/access_token_source.dart';

final class SupabaseAccessTokenSource implements AccessTokenSource {
  final SupabaseClient _client;

  const SupabaseAccessTokenSource(this._client);

  @override
  Future<String?> accessToken() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    if (!session.isExpired) return session.accessToken;
    try {
      final refreshed = await _client.auth.refreshSession();
      return refreshed.session?.accessToken;
    } on Object {
      return null;
    }
  }
}
