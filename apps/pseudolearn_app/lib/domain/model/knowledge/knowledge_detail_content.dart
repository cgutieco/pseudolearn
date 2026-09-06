import 'content_block.dart';
import 'document_heading.dart';
import 'exercise.dart';
import 'knowledge_entry.dart';
import 'learning_module.dart';
import 'list_equality.dart';

sealed class KnowledgeDetailContent {
  const KnowledgeDetailContent();
}

final class ModuleDetailContent extends KnowledgeDetailContent {
  final LearningModule module;
  final List<DocumentHeading> headings;
  final List<KnowledgeEntry> specificationEntries;
  final List<KnowledgeEntry> exerciseEntries;
  final double scrollOffset;

  const ModuleDetailContent({
    required this.module,
    required this.headings,
    this.specificationEntries = const [],
    this.exerciseEntries = const [],
    this.scrollOffset = 0.0,
  });

  ModuleDetailContent copyWith({
    LearningModule? module,
    List<DocumentHeading>? headings,
    List<KnowledgeEntry>? specificationEntries,
    List<KnowledgeEntry>? exerciseEntries,
    double? scrollOffset,
  }) {
    return ModuleDetailContent(
      module: module ?? this.module,
      headings: headings ?? this.headings,
      specificationEntries: specificationEntries ?? this.specificationEntries,
      exerciseEntries: exerciseEntries ?? this.exerciseEntries,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleDetailContent &&
          runtimeType == other.runtimeType &&
          module == other.module &&
          scrollOffset == other.scrollOffset &&
          listEquals(headings, other.headings) &&
          listEquals(specificationEntries, other.specificationEntries) &&
          listEquals(exerciseEntries, other.exerciseEntries);

  @override
  int get hashCode => Object.hash(
        module,
        scrollOffset,
        Object.hashAll(headings),
        Object.hashAll(specificationEntries),
        Object.hashAll(exerciseEntries),
      );
}

final class SpecificationDetailContent extends KnowledgeDetailContent {
  final KnowledgeEntry entry;
  final List<ContentBlock> blocks;
  final List<DocumentHeading> headings;
  final String? selectedAnchor;
  final String? fromModuleId;
  final String? fromModuleTitle;
  final double scrollOffset;

  const SpecificationDetailContent({
    required this.entry,
    required this.blocks,
    required this.headings,
    this.selectedAnchor,
    this.fromModuleId,
    this.fromModuleTitle,
    this.scrollOffset = 0.0,
  });

  SpecificationDetailContent copyWith({
    KnowledgeEntry? entry,
    List<ContentBlock>? blocks,
    List<DocumentHeading>? headings,
    String? Function()? selectedAnchor,
    String? Function()? fromModuleId,
    String? Function()? fromModuleTitle,
    double? scrollOffset,
  }) {
    return SpecificationDetailContent(
      entry: entry ?? this.entry,
      blocks: blocks ?? this.blocks,
      headings: headings ?? this.headings,
      selectedAnchor: selectedAnchor != null ? selectedAnchor() : this.selectedAnchor,
      fromModuleId: fromModuleId != null ? fromModuleId() : this.fromModuleId,
      fromModuleTitle: fromModuleTitle != null ? fromModuleTitle() : this.fromModuleTitle,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecificationDetailContent &&
          runtimeType == other.runtimeType &&
          entry == other.entry &&
          selectedAnchor == other.selectedAnchor &&
          fromModuleId == other.fromModuleId &&
          fromModuleTitle == other.fromModuleTitle &&
          scrollOffset == other.scrollOffset &&
          listEquals(blocks, other.blocks) &&
          listEquals(headings, other.headings);

  @override
  int get hashCode => Object.hash(
        entry,
        selectedAnchor,
        fromModuleId,
        fromModuleTitle,
        scrollOffset,
        Object.hashAll(blocks),
        Object.hashAll(headings),
      );
}

final class ExerciseDetailContent extends KnowledgeDetailContent {
  final Exercise exercise;
  final bool isCompleted;
  final double scrollOffset;

  const ExerciseDetailContent({
    required this.exercise,
    this.isCompleted = false,
    this.scrollOffset = 0.0,
  });

  ExerciseDetailContent copyWith({
    Exercise? exercise,
    bool? isCompleted,
    double? scrollOffset,
  }) {
    return ExerciseDetailContent(
      exercise: exercise ?? this.exercise,
      isCompleted: isCompleted ?? this.isCompleted,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDetailContent &&
          runtimeType == other.runtimeType &&
          exercise == other.exercise &&
          isCompleted == other.isCompleted &&
          scrollOffset == other.scrollOffset;

  @override
  int get hashCode => Object.hash(exercise, isCompleted, scrollOffset);
}

final class DocumentDetailContent extends KnowledgeDetailContent {
  final List<ContentBlock> blocks;
  final List<DocumentHeading> headings;
  final double scrollOffset;

  const DocumentDetailContent({
    required this.blocks,
    required this.headings,
    this.scrollOffset = 0.0,
  });

  DocumentDetailContent copyWith({
    List<ContentBlock>? blocks,
    List<DocumentHeading>? headings,
    double? scrollOffset,
  }) {
    return DocumentDetailContent(
      blocks: blocks ?? this.blocks,
      headings: headings ?? this.headings,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentDetailContent &&
          runtimeType == other.runtimeType &&
          scrollOffset == other.scrollOffset &&
          listEquals(blocks, other.blocks) &&
          listEquals(headings, other.headings);

  @override
  int get hashCode => Object.hash(
        scrollOffset,
        Object.hashAll(blocks),
        Object.hashAll(headings),
      );
}
