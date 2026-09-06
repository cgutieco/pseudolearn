import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/data/knowledge/bundled_knowledge_repository.dart';
import 'package:pseudolearn_app/data/knowledge/content_marker_scanner.dart';
import 'package:pseudolearn_app/data/knowledge/diagram_marker_argument.dart';
import 'package:pseudolearn_app/data/knowledge/exercise_document_parser.dart';
import 'package:pseudolearn_app/data/knowledge/marker_resolver.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/knowledge/syntax_reference_generator.dart';
import 'loaded_content.dart';
import 'module_constructs.dart';

const MarkerResolver contentMarkers =
    MarkerResolver(reference: SyntaxReferenceGenerator());

BundledKnowledgeRepository repositoryOver(Directory knowledgeDir) {
  return BundledKnowledgeRepository(
    markers: contentMarkers,
    assetLoader: (path) async {
      final relative = path.replaceFirst(knowledgeAssetRoot, '');
      return File(p.join(knowledgeDir.path, relative)).readAsStringSync();
    },
  );
}

Future<LoadedLanguage> loadLanguage({
  required Directory knowledgeDir,
  required String code,
  required List<String> errors,
}) async {
  final repository = repositoryOver(knowledgeDir);
  final languageId = code == 'en' ? UiLanguageId.english : UiLanguageId.spanish;
  final profileId =
      code == 'en' ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish;
  final loaded = await repository.getEntries(languageId);
  if (loaded is! ContentLoaded<List<KnowledgeEntry>>) {
    errors.add('Manifest "$code" failed to load: ${_detailOf(loaded)}');
    return _empty(code, languageId, profileId);
  }
  final entries = loaded.value;
  return LoadedLanguage(
    code: code,
    languageId: languageId,
    profileId: profileId,
    entries: entries,
    modules: await _modulesOf(repository, entries, languageId, profileId, errors),
    exercises: _exercisesOf(knowledgeDir, entries, errors),
    exampleSources: _exampleSourcesOf(knowledgeDir, entries),
    specificationAnchors: _anchorsOf(entries),
    constructsByModule: readModuleConstructs(knowledgeDir, code),
    specificationBlocks: await _specificationBlocksOf(
      repository,
      entries,
      languageId,
      profileId,
      errors,
    ),
    moduleExampleIds: _moduleExampleIdsOf(knowledgeDir, entries),
    specificationExampleIds: _specificationExampleIdsOf(knowledgeDir, entries),
  );
}

String _detailOf(ContentLoadResult<Object?> result) {
  if (result is ContentLoadFailed<List<KnowledgeEntry>>) {
    return '${result.failure.name} (${result.detail})';
  }
  return 'unknown';
}

LoadedLanguage _empty(
  String code,
  UiLanguageId languageId,
  SyntaxProfileId profileId,
) {
  return LoadedLanguage(
    code: code,
    languageId: languageId,
    profileId: profileId,
    entries: const [],
    modules: const {},
    exercises: const {},
    exampleSources: const {},
    specificationAnchors: const {},
    constructsByModule: const {},
    specificationBlocks: const {},
    moduleExampleIds: const {},
    specificationExampleIds: const {},
  );
}

Future<Map<String, LearningModule>> _modulesOf(
  BundledKnowledgeRepository repository,
  List<KnowledgeEntry> entries,
  UiLanguageId languageId,
  SyntaxProfileId profileId,
  List<String> errors,
) async {
  final modules = <String, LearningModule>{};
  for (final entry in entries) {
    if (entry.type != KnowledgeEntryType.module) continue;
    final loaded = await repository.getModule(
      entry: entry,
      profileId: profileId,
      languageId: languageId,
    );
    if (loaded is ContentLoaded<LearningModule>) {
      modules[entry.id] = loaded.value;
      continue;
    }
    final failed = loaded as ContentLoadFailed<LearningModule>;
    errors.add(
      'Module "${entry.id}" failed to load: ${failed.failure.name} (${failed.detail})',
    );
  }
  return modules;
}

Future<Map<String, List<ContentBlock>>> _specificationBlocksOf(
  BundledKnowledgeRepository repository,
  List<KnowledgeEntry> entries,
  UiLanguageId languageId,
  SyntaxProfileId profileId,
  List<String> errors,
) async {
  final sections = <String, List<ContentBlock>>{};
  for (final entry in entries) {
    if (entry.type != KnowledgeEntryType.specificationSection) continue;
    final loaded = await repository.getDocumentBlocks(
      path: entry.path ?? '',
      profileId: profileId,
      languageId: languageId,
    );
    if (loaded is ContentLoaded<List<ContentBlock>>) {
      sections[entry.id] = loaded.value;
      continue;
    }
    final failed = loaded as ContentLoadFailed<List<ContentBlock>>;
    errors.add(
      'Specification section "${entry.id}" failed to load: '
      '${failed.failure.name} (${failed.detail})',
    );
  }
  return sections;
}

Map<String, LoadedExercise> _exercisesOf(
  Directory knowledgeDir,
  List<KnowledgeEntry> entries,
  List<String> errors,
) {
  final exercises = <String, LoadedExercise>{};
  for (final entry in entries) {
    if (entry.type != KnowledgeEntryType.exercise) continue;
    final file = File(p.join(knowledgeDir.path, entry.path ?? ''));
    if (!file.existsSync()) continue;
    final source = file.readAsStringSync();
    final parsed = const ExerciseDocumentParser().parse(source);
    if (parsed is! ContentLoaded<Exercise>) {
      final failed = parsed as ContentLoadFailed<Exercise>;
      errors.add(
        'Exercise "${entry.id}" is malformed: ${failed.failure.name} (${failed.detail})',
      );
      continue;
    }
    exercises[entry.id] = LoadedExercise(
      exercise: parsed.value,
      referenceSolution: _referenceSolutionOf(source),
    );
  }
  return exercises;
}

String _referenceSolutionOf(String source) {
  try {
    final document = jsonDecode(source) as Map<String, dynamic>;
    return document['referenceSolution'] as String? ?? '';
  } catch (_) {
    return '';
  }
}

Map<String, String> _exampleSourcesOf(
  Directory knowledgeDir,
  List<KnowledgeEntry> entries,
) {
  final sources = <String, String>{};
  for (final entry in entries) {
    if (entry.type != KnowledgeEntryType.example) continue;
    final file = File(p.join(knowledgeDir.path, entry.path ?? ''));
    if (file.existsSync()) sources[entry.id] = file.readAsStringSync();
  }
  return sources;
}

Set<String> _anchorsOf(List<KnowledgeEntry> entries) {
  final anchors = <String>{};
  for (final entry in entries) {
    if (entry.type != KnowledgeEntryType.specificationSection) continue;
    anchors.add(entry.id);
  }
  return anchors;
}

Set<String> _moduleExampleIdsOf(
  Directory knowledgeDir,
  List<KnowledgeEntry> entries,
) {
  final ids = <String>{};
  const scanner = ContentMarkerScanner();
  for (final entry in entries) {
    if (entry.type != KnowledgeEntryType.module) continue;
    final file = File(p.join(knowledgeDir.path, entry.path ?? ''));
    if (!file.existsSync()) continue;
    for (final occurrence in scanner.scan(file.readAsStringSync())) {
      final marker = occurrence.marker;
      if (marker == null) continue;
      if (marker.kind == ContentMarkerKind.example) {
        ids.add(marker.argument);
      } else if (marker.kind == ContentMarkerKind.diagram) {
        final parsed = DiagramMarkerArgument.parse(marker.argument);
        if (parsed != null) ids.add(parsed.exampleId);
      }
    }
  }
  return ids;
}

Set<String> _specificationExampleIdsOf(
  Directory knowledgeDir,
  List<KnowledgeEntry> entries,
) {
  final ids = <String>{};
  const scanner = ContentMarkerScanner();
  for (final entry in entries) {
    if (entry.type != KnowledgeEntryType.specificationSection) continue;
    final file = File(p.join(knowledgeDir.path, entry.path ?? ''));
    if (!file.existsSync()) continue;
    for (final occurrence in scanner.scan(file.readAsStringSync())) {
      final marker = occurrence.marker;
      if (marker == null) continue;
      if (marker.kind == ContentMarkerKind.example) {
        ids.add(marker.argument);
      } else if (marker.kind == ContentMarkerKind.diagram) {
        final parsed = DiagramMarkerArgument.parse(marker.argument);
        if (parsed != null) ids.add(parsed.exampleId);
      }
    }
  }
  return ids;
}
