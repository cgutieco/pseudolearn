import '../profiles/syntax_profile_id.dart';

final class Document {
  final String id;
  final String title;
  final String content;
  final SyntaxProfileId profileId;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? exerciseId;

  const Document({
    required this.id,
    required this.title,
    required this.content,
    required this.profileId,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.exerciseId,
  });

  DocumentSummary toSummary() {
    return DocumentSummary(
      id: id,
      title: title,
      profileId: profileId,
      revision: revision,
      createdAt: createdAt,
      updatedAt: updatedAt,
      exerciseId: exerciseId,
    );
  }

  Document copyWith({
    String? title,
    String? content,
    SyntaxProfileId? profileId,
    int? revision,
    DateTime? updatedAt,
    String? Function()? exerciseId,
  }) {
    return Document(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      profileId: profileId ?? this.profileId,
      revision: revision ?? this.revision,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exerciseId: exerciseId != null ? exerciseId() : this.exerciseId,
    );
  }
}

final class DocumentSummary {
  final String id;
  final String title;
  final SyntaxProfileId profileId;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? exerciseId;

  const DocumentSummary({
    required this.id,
    required this.title,
    required this.profileId,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.exerciseId,
  });
}
