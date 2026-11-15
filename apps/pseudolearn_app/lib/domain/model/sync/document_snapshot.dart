import '../documents/document.dart';
import '../profiles/syntax_profile_id.dart';

final class DocumentSnapshot {
  final String id;
  final int revision;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String content;
  final String title;
  final SyntaxProfileId profileId;
  final String? exerciseId;

  const DocumentSnapshot({
    required this.id,
    required this.revision,
    required this.updatedAt,
    this.deletedAt,
    required this.content,
    required this.title,
    required this.profileId,
    this.exerciseId,
  });

  factory DocumentSnapshot.fromDocument(
    Document document, {
    DateTime? deletedAt,
  }) {
    return DocumentSnapshot(
      id: document.id,
      revision: document.revision,
      updatedAt: document.updatedAt,
      deletedAt: deletedAt,
      content: document.content,
      title: document.title,
      profileId: document.profileId,
      exerciseId: document.exerciseId,
    );
  }

  bool get isDeleted => deletedAt != null;
}
