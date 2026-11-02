import 'dart:convert';
import 'dart:io';

const String _specificationRoot =
    '../../packages/pseudolearn_spec/specifications';
final RegExp _referencePattern = RegExp(
  r'^([A-Z][A-Z0-9]*(?:\.[A-Z0-9]+)*)@(\d+\.\d+\.\d+)#(C\d+)$',
);

List<String> checkNormativeCaseReferences({
  required String exerciseId,
  required String languageCode,
  required List<String> references,
  String specificationRoot = _specificationRoot,
}) {
  final errors = <String>[];
  for (final reference in references) {
    if (specificationCaseExists(
      reference,
      specificationRoot: specificationRoot,
    )) {
      continue;
    }
    errors.add(
      'Exercise "$exerciseId" ($languageCode) cites unknown normative case "$reference"',
    );
  }
  return errors;
}

bool specificationCaseExists(
  String reference, {
  String specificationRoot = _specificationRoot,
}) {
  final match = _referencePattern.firstMatch(reference);
  if (match == null) return false;
  final id = match.group(1)!;
  final version = match.group(2)!;
  final caseId = match.group(3)!;
  final domain = id.split('.').first.toLowerCase();
  final path = '$specificationRoot/$domain/${id.toLowerCase()}.md';
  final file = File(path);
  if (!file.existsSync()) return false;
  final source = file.readAsStringSync();
  if (!source.contains('"id": "$id"') ||
      !source.contains('"version": "$version"')) {
    return false;
  }
  for (final section in source.split('```caso').skip(1)) {
    final end = section.indexOf('```');
    if (end < 0) continue;
    try {
      final data =
          jsonDecode(section.substring(0, end)) as Map<String, dynamic>;
      if (data['id'] == caseId) return true;
    } on FormatException {
      continue;
    } on TypeError {
      continue;
    }
  }
  return false;
}
