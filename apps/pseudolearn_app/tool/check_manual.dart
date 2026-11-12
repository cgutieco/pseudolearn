import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const List<String> manualLanguages = ['es', 'en'];
final RegExp _featureKey = RegExp(r"ValueKey\(\s*'feature:([a-z0-9-]+)'\s*\)");

final class ManualViolation {
  final String rule;
  final String detail;

  const ManualViolation(this.rule, this.detail);

  @override
  String toString() => '[$rule] $detail';
}

Set<String> featureAnchorsIn(Directory sourceRoot) {
  final anchors = <String>{};
  for (final entity in sourceRoot.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    for (final match in _featureKey.allMatches(entity.readAsStringSync())) {
      anchors.add(match.group(1)!);
    }
  }
  return anchors;
}

List<ManualViolation> validateManual({
  required Directory sourceRoot,
  required Directory manualRoot,
}) {
  final anchors = featureAnchorsIn(sourceRoot);
  final violations = <ManualViolation>[];
  for (final language in manualLanguages) {
    final file = File(p.join(manualRoot.path, language, 'manual.json'));
    if (!file.existsSync()) {
      violations.add(ManualViolation('MANUAL-MISSING', '$language/manual.json'));
      continue;
    }
    violations.addAll(_validateLanguage(language, file, anchors));
  }
  return violations;
}

List<ManualViolation> _validateLanguage(String language, File file, Set<String> anchors) {
  final violations = <ManualViolation>[];
  final entries = _entriesOf(file);
  if (entries == null) return [ManualViolation('MANUAL-FORMAT', '$language/manual.json')];
  final seen = <String>{};
  for (final entry in entries) {
    final id = entry['id'];
    if (id is! String || !seen.add(id)) {
      violations.add(ManualViolation('MANUAL-DUPLICATE', '$language: $id'));
      continue;
    }
    if (entry['anchor'] != 'feature:$id') {
      violations.add(ManualViolation('MANUAL-ANCHOR', '$language: $id'));
    }
    for (final field in ['title', 'body', 'route']) {
      final value = entry[field];
      if (value is! String || value.trim().isEmpty) {
        violations.add(ManualViolation('MANUAL-FIELD', '$language: $id.$field'));
      }
    }
    if (!anchors.contains(id)) {
      violations.add(ManualViolation('MANUAL-ORPHAN', '$language: $id has no widget'));
    }
  }
  for (final anchor in anchors.difference(seen)) {
    violations.add(ManualViolation('MANUAL-UNDOCUMENTED', '$language: feature:$anchor'));
  }
  return violations;
}

List<Map<String, Object?>>? _entriesOf(File file) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    final entries = decoded is Map<String, Object?> ? decoded['entries'] : null;
    if (entries is! List<Object?>) return null;
    return [for (final entry in entries) entry as Map<String, Object?>];
  } on Object {
    return null;
  }
}

void main() {
  final violations = validateManual(
    sourceRoot: Directory('lib'),
    manualRoot: Directory('assets/manual'),
  );
  if (violations.isEmpty) {
    stdout.writeln('The manual documents every feature.');
    return;
  }
  violations.forEach(stderr.writeln);
  exitCode = 1;
}
