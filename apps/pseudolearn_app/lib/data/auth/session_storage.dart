import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase/supabase.dart';

abstract interface class SessionStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

final class SecureSessionStorage implements SessionStorage {
  final FlutterSecureStorage _storage;

  const SecureSessionStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

final class GotrueSessionStorageAdapter extends GotrueAsyncStorage {
  final SessionStorage _storage;

  const GotrueSessionStorageAdapter(this._storage);

  @override
  Future<String?> getItem({required String key}) => _storage.read(key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key, value);

  @override
  Future<void> removeItem({required String key}) => _storage.delete(key);
}
