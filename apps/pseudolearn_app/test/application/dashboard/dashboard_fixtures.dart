import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:pseudolearn_app/domain/model/sync/outbox_entry.dart';

DocumentSummary summaryOf(
  String id, {
  SyntaxProfileId profileId = SyntaxProfileId.classicSpanish,
  DateTime? createdAt,
  String title = 'Algoritmo',
}) {
  final moment = createdAt ?? DateTime(2026, 8, 31);
  return DocumentSummary(
    id: id,
    title: title,
    profileId: profileId,
    revision: 1,
    createdAt: moment,
    updatedAt: moment,
  );
}

KnowledgeEntry moduleEntry(
  String id, {
  required LearningTrack track,
  int order = 1,
  String title = 'Módulo',
}) {
  return KnowledgeEntry(
    id: id,
    type: KnowledgeEntryType.module,
    title: title,
    summary: '',
    track: track,
    order: order,
  );
}

KnowledgeEntry exerciseEntry(
  String id, {
  required String moduleId,
  ExerciseLevel level = ExerciseLevel.reproduce,
  ExerciseKind kind = ExerciseKind.create,
}) {
  return KnowledgeEntry(
    id: id,
    type: KnowledgeEntryType.exercise,
    title: id,
    summary: '',
    level: level,
    kind: kind,
    moduleId: moduleId,
  );
}

KnowledgeEntry specificationEntry(String id, {int order = 1, String? title}) {
  return KnowledgeEntry(
    id: id,
    type: KnowledgeEntryType.specificationSection,
    title: title ?? id,
    summary: '',
    order: order,
  );
}

ProgressEntry visitedEntry(String contentId, {DateTime? at}) {
  return ProgressEntry(
    contentId: contentId,
    visited: true,
    completed: false,
    firstVisitedAt: at,
  );
}

ProgressEntry completedEntry(String contentId, {DateTime? at}) {
  return ProgressEntry(
    contentId: contentId,
    visited: true,
    completed: true,
    firstVisitedAt: at,
    firstCompletedAt: at,
  );
}

OutboxEntry outboxEntry(String id, {required DateTime enqueuedAt}) {
  return OutboxEntry(
    entryId: id,
    entityType: 'document',
    entityId: id,
    operation: 'upsert',
    enqueuedAt: enqueuedAt,
  );
}
