import 'package:pseudolearn_core/pseudolearn_core.dart';

import 'analysis.dart';
import 'execution.dart';

final class ReferenceProtocol {
  bool _negotiated = false;
  final String subjectVersion;

  ReferenceProtocol({required this.subjectVersion});

  static final Map<String, LanguageProfile> _profiles = {
    'es:strict': const ClassicSpanishProfile.strict(),
    'es:flexible': const ClassicSpanishProfile.flexible(),
    'en:strict': const EnglishProfile.strict(),
    'en:flexible': const EnglishProfile.flexible(),
  };

  Map<String, Object?> handle(Map<String, Object?> request) {
    final kind = request['kind'];
    if (kind == 'hello') return _hello(request);
    if (!_negotiated) throw const FormatException('Handshake required');
    if (kind == 'shutdown') return {'kind': 'shutdown'};
    if (kind != 'analyze' && kind != 'execute') {
      throw const FormatException('Unsupported operation');
    }
    final profile = _profiles['${request['profile']}:${request['strictness']}'];
    final program = request['program'];
    if (profile == null || program is! String) {
      throw const FormatException('Invalid program, profile or strictness');
    }
    final analysis = analyze(program, profile);
    if (kind == 'analyze') return {'kind': 'analyze', ...analysis.response};
    return execute(request, analysis);
  }

  Map<String, Object?> _hello(Map<String, Object?> request) {
    if (request['protocol'] != 'see-protocol/1') {
      throw const FormatException('Incompatible protocol');
    }
    _negotiated = true;
    return {
      'kind': 'hello',
      'protocol': 'see-protocol/1',
      'subject': 'reference',
      'subject_version': subjectVersion,
      'capabilities': ['analyze', 'execute'],
      'profiles': ['es', 'en'],
      'strictness': ['strict', 'flexible'],
    };
  }
}
