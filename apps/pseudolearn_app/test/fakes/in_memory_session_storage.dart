import 'package:pseudolearn_app/data/auth/session_storage.dart';

final class InMemorySessionStorage implements SessionStorage {
  final Map<String, String> _data = {};
  bool throwOnWrite = false;

  Map<String, String> get entries => Map.unmodifiable(_data);

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    if (throwOnWrite) throw Exception('Simulated keychain failure');
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}
