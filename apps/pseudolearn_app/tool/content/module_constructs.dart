import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const String constructsKey = 'constructs';

Map<String, Set<String>> readModuleConstructs(
  Directory knowledgeDir,
  String languageCode,
) {
  final file = File(p.join(knowledgeDir.path, 'manifest_$languageCode.json'));
  if (!file.existsSync()) return const {};
  try {
    final manifest = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final modules = manifest['modules'];
    if (modules is! List) return const {};
    return _constructsOf(modules);
  } catch (_) {
    return const {};
  }
}

Map<String, Set<String>> _constructsOf(List<dynamic> modules) {
  final byModule = <String, Set<String>>{};
  for (final raw in modules) {
    if (raw is! Map<String, dynamic>) continue;
    final id = raw['id'] as String?;
    if (id == null) continue;
    final declared = raw[constructsKey];
    byModule[id] = declared is List
        ? declared.map((value) => '$value').toSet()
        : const <String>{};
  }
  return byModule;
}
