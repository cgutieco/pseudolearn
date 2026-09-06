import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/model/settings/app_preferences.dart';
import '../../domain/ports/preferences_store.dart';

final class FilePreferencesStore implements PreferencesStore {
  final Directory directory;
  final String fileName;

  const FilePreferencesStore({
    required this.directory,
    this.fileName = 'preferences.json',
  });

  File get _targetFile => File(p.join(directory.path, fileName));
  File get _tempFile => File(p.join(directory.path, '$fileName.tmp'));

  @override
  Future<AppPreferences> read() async {
    final file = _targetFile;
    if (!file.existsSync()) {
      return const AppPreferences.defaults();
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return const AppPreferences.defaults();
      }
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic>) {
        return const AppPreferences.defaults();
      }
      return AppPreferences.fromJson(json);
    } catch (_) {
      return const AppPreferences.defaults();
    }
  }

  @override
  Future<void> write(AppPreferences preferences) async {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(preferences.toJson());
    final temp = _tempFile;
    await temp.writeAsString(jsonString, flush: true);

    final target = _targetFile;
    if (target.existsSync()) {
      target.deleteSync();
    }
    await temp.rename(target.path);
  }
}
