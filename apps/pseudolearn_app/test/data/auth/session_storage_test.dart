import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/auth/session_storage.dart';

final class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}

void main() {
  group('SessionStorage and GotrueSessionStorageAdapter', () {
    late SessionStorage storage;
    late GotrueSessionStorageAdapter adapter;

    setUp(() {
      storage = InMemorySessionStorage();
      adapter = GotrueSessionStorageAdapter(storage);
    });

    test('reads null when key does not exist', () async {
      expect(await storage.read('non_existent'), isNull);
      expect(await adapter.getItem(key: 'non_existent'), isNull);
    });

    test('writes and reads value correctly', () async {
      await storage.write('auth_token', 'token_123');
      expect(await storage.read('auth_token'), 'token_123');
      expect(await adapter.getItem(key: 'auth_token'), 'token_123');
    });

    test('adapter writes and storage reads', () async {
      await adapter.setItem(key: 'refresh_token', value: 'refresh_456');
      expect(await storage.read('refresh_token'), 'refresh_456');
    });

    test('deletes value correctly', () async {
      await storage.write('key', 'val');
      await adapter.removeItem(key: 'key');
      expect(await storage.read('key'), isNull);
    });
  });
}
