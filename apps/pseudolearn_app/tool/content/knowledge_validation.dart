import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/engine/mapping/profile_catalog.dart';
import 'content_loading.dart';
import 'example_checks.dart';
import 'language_checks.dart';
import 'loaded_content.dart';
import 'parity_checks.dart';

Future<List<String>> validateKnowledge(Directory knowledgeDir) async {
  if (!knowledgeDir.existsSync()) return const [];
  final manifests = _manifestFiles(knowledgeDir);
  if (manifests.isEmpty) return const [];

  final errors = <String>[];
  final languages = <LoadedLanguage>[];
  for (final code in manifests) {
    final language = await loadLanguage(
      knowledgeDir: knowledgeDir,
      code: code,
      errors: errors,
    );
    languages.add(language);
    errors.addAll(validateLanguage(language: language));
  }
  errors.addAll(_validateFileReferences(knowledgeDir, languages));
  errors.addAll(_validateAcrossLanguages(languages));
  return errors;
}

List<String> _manifestFiles(Directory knowledgeDir) {
  final codes = <String>[];
  for (final file in knowledgeDir.listSync().whereType<File>()) {
    final name = p.basename(file.path);
    if (!name.startsWith('manifest_') || !name.endsWith('.json')) continue;
    codes.add(name.replaceFirst('manifest_', '').replaceFirst('.json', ''));
  }
  codes.sort();
  return codes;
}

List<String> _validateFileReferences(
  Directory knowledgeDir,
  List<LoadedLanguage> languages,
) {
  final errors = <String>[];
  final referenced = <String>{};
  for (final language in languages) {
    for (final entry in language.entries) {
      final path = entry.path;
      if (path == null) continue;
      referenced.add(p.normalize(path));
      final file = File(p.join(knowledgeDir.path, path));
      if (!file.existsSync()) {
        errors.add('Manifest "${language.code}" references missing file: $path');
      }
    }
  }
  errors.addAll(_orphanFiles(knowledgeDir, referenced));
  return errors;
}

List<String> _orphanFiles(Directory knowledgeDir, Set<String> referenced) {
  final errors = <String>[];
  for (final file in knowledgeDir.listSync(recursive: true).whereType<File>()) {
    final name = p.basename(file.path);
    if (name.startsWith('manifest_') && name.endsWith('.json')) continue;
    if (name.startsWith('.')) continue;
    final relative = p.normalize(p.relative(file.path, from: knowledgeDir.path));
    if (referenced.contains(relative)) continue;
    errors.add('Orphan file in knowledge assets not referenced by any manifest: $relative');
  }
  return errors;
}

List<String> _validateAcrossLanguages(List<LoadedLanguage> languages) {
  final errors = <String>[];
  for (var i = 0; i < languages.length; i++) {
    for (var j = i + 1; j < languages.length; j++) {
      final a = languages[i];
      final b = languages[j];
      errors.addAll(_identifierSymmetry(a, b));
      errors.addAll(checkModuleParity(a, b));
      errors.addAll(checkModuleParity(b, a));
      errors.addAll(checkSpecificationParity(a, b));
      errors.addAll(checkSpecificationParity(b, a));
      errors.addAll(checkExerciseParity(a, b));
      errors.addAll(checkExerciseParity(b, a));
      errors.addAll(checkExamplesShareShape(
        a: a,
        b: b,
        profileA: ProfileCatalog.toLanguageProfile(a.profileId),
        profileB: ProfileCatalog.toLanguageProfile(b.profileId),
      ));
    }
  }
  return errors;
}

List<String> _identifierSymmetry(LoadedLanguage a, LoadedLanguage b) {
  final errors = <String>[];
  final idsA = _idsOf(a.entries);
  final idsB = _idsOf(b.entries);
  for (final id in idsA.difference(idsB)) {
    errors.add('Entry id "$id" in "${a.code}" manifest is missing in "${b.code}" manifest');
  }
  for (final id in idsB.difference(idsA)) {
    errors.add('Entry id "$id" in "${b.code}" manifest is missing in "${a.code}" manifest');
  }
  return errors;
}

Set<String> _idsOf(List<KnowledgeEntry> entries) {
  final ids = <String>{};
  for (final entry in entries) {
    if (entry.type == KnowledgeEntryType.illustration) continue;
    ids.add(entry.id);
  }
  return ids;
}
