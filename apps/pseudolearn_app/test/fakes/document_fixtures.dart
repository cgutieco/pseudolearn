import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

Document documentFixture({
  String id = 'doc-1',
  String title = 'Fibonacci',
  String content = '',
  int revision = 1,
  String? exerciseId,
}) {
  final created = DateTime(2026, 11, 1, 9);
  return Document(
    id: id,
    title: title,
    content: content,
    profileId: SyntaxProfileId.classicSpanish,
    revision: revision,
    createdAt: created,
    updatedAt: created,
    exerciseId: exerciseId,
  );
}
