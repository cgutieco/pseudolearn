import '../../test/fakes/native_test_engine.dart';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/data/knowledge/bundled_knowledge_repository.dart';
import 'package:pseudolearn_app/data/knowledge/marker_resolver.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../test/fakes/in_memory_document_repository.dart';
import '../../test/fakes/in_memory_preferences_store.dart';
import '../../test/fakes/test_dependencies.dart';
import 'product_documents.dart';

final DateTime productClockInstant = DateTime(2026, 8, 15, 12, 0);

AppDependencies buildProductDependencies({
  required UiLanguageId language,
  required AppThemeMode themeMode,
}) {
  final engine = nativeTestEngine;
  return buildTestDependencies(
    repository: _seededRepository(language),
    preferences: InMemoryPreferencesStore(
      const AppPreferences.defaults().copyWith(
        themeMode: themeMode,
        language: language,
      ),
    ),
    syntaxReferenceSource: engine.syntaxReferenceSource,
    knowledgeRepository: BundledKnowledgeRepository(
      markers: MarkerResolver(reference: engine.syntaxReferenceSource),
      assetLoader: rootBundle.loadString,
    ),
    engine: engine,
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
