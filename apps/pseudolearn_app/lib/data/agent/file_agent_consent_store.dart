import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/ports/agent_consent_store.dart';

final class FileAgentConsentStore implements AgentConsentStore {
  static const String fileName = 'agent_consent.json';
  static const String grantedText = '{"consent":"granted","version":1}';

  final Directory _directory;

  const FileAgentConsentStore(this._directory);

  File get _file => File(p.join(_directory.path, fileName));

  @override
  Future<bool> hasConsented() async =>
      _file.existsSync() && _file.readAsStringSync().trim() == grantedText;

  @override
  Future<void> grant() async {
    _directory.createSync(recursive: true);
    _file.writeAsStringSync(grantedText, flush: true);
  }

  @override
  Future<void> withdraw() async {
    if (_file.existsSync()) _file.deleteSync();
  }
}
