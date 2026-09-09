import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/data/knowledge/bundled_knowledge_repository.dart';
import 'package:pseudolearn_app/data/knowledge/marker_resolver.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/analysis_cache.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_construct_reader.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'package:pseudolearn_app/engine/exercise/behaviour_checker.dart';
import 'package:pseudolearn_app/engine/exercise/exercise_check_runner.dart';
import 'package:pseudolearn_app/engine/exercise/structural_assertion_checker.dart';
import 'package:pseudolearn_app/engine/export/core_program_exporter.dart';
import 'package:pseudolearn_app/engine/knowledge/syntax_reference_generator.dart';

import '../../test/fakes/in_memory_document_repository.dart';
import '../../test/fakes/in_memory_preferences_store.dart';
import '../../test/fakes/test_dependencies.dart';
import 'product_documents.dart';

final DateTime productClockInstant = DateTime(2026, 8, 15, 12, 0);

const SyntaxReferenceGenerator _syntaxReference = SyntaxReferenceGenerator();

AppDependencies buildProductDependencies({
  required UiLanguageId language,
  required AppThemeMode themeMode,
}) {
  final analyses = AnalysisCache();
  return buildTestDependencies(
    repository: _seededRepository(language),
    preferences: InMemoryPreferencesStore(
      const AppPreferences.defaults()
          .copyWith(themeMode: themeMode, language: language),
    ),
    syntaxReferenceSource: _syntaxReference,
    knowledgeRepository: BundledKnowledgeRepository(
      markers: const MarkerResolver(reference: _syntaxReference),
      assetLoader: rootBundle.loadString,
    ),
    programExporter: CoreProgramExporter(analyses: analyses),
    programConstructReader: CoreProgramConstructReader(analyses: analyses),
    exerciseChecker: ExerciseCheckRunner(
      behaviour: BehaviourChecker(
        execution: CoreProgramExecution(analyses: analyses),
        analyzer: CoreProgramAnalyzer(analyses: analyses),
      ),
      structure: StructuralAssertionChecker(analyses: analyses),
    ),
  );
}

InMemoryDocumentRepository _seededRepository(UiLanguageId language) {
  final repository = InMemoryDocumentRepository();
  for (final spec in productDocuments[language]!) {
    repository.documents[spec.id] = Document(
      id: spec.id,
      title: spec.title,
      content: File(spec.sourcePath).readAsStringSync(),
      profileId: productProfiles[language]!,
      revision: 1,
      createdAt: productClockInstant,
      updatedAt: productClockInstant,
    );
  }
  return repository;
}
