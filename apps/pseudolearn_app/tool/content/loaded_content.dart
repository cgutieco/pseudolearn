import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

final class LoadedExercise {
  final Exercise exercise;
  final String referenceSolution;

  const LoadedExercise({
    required this.exercise,
    required this.referenceSolution,
  });
}

final class LoadedLanguage {
  final String code;
  final UiLanguageId languageId;
  final SyntaxProfileId profileId;
  final List<KnowledgeEntry> entries;
  final Map<String, LearningModule> modules;
  final Map<String, LoadedExercise> exercises;
  final Map<String, String> exampleSources;
  final Set<String> specificationAnchors;
  final Map<String, Set<String>> constructsByModule;
  final Map<String, List<ContentBlock>> specificationBlocks;
  final Set<String> moduleExampleIds;
  final Set<String> specificationExampleIds;

  const LoadedLanguage({
    required this.code,
    required this.languageId,
    required this.profileId,
    required this.entries,
    required this.modules,
    required this.exercises,
    required this.exampleSources,
    required this.specificationAnchors,
    required this.constructsByModule,
    required this.specificationBlocks,
    required this.moduleExampleIds,
    required this.specificationExampleIds,
  });
}
