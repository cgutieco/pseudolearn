import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_run.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section_kind.dart';
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

ReferenceIndexEntry specificationEntry(String id, {int order = 1, String? title}) {
  return ReferenceIndexEntry(
    id: id,
    number: '$order',
    kind: ReferenceSectionKind.concept,
    title: [ReferenceTextRun(title ?? id)],
    phrase: const [],
  );
}
