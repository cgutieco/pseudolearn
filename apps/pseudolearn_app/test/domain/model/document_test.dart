import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

void main() {
  group('Document Domain Model', () {
    test('creates document and copies with new values including exerciseId', () {
      final now = DateTime(2026, 8, 15, 12, 0);
      final doc = Document(
        id: 'doc-1',
        title: 'Algoritmo 1',
        content: 'algoritmo Test fin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: now,
        updatedAt: now,
        exerciseId: 'con-b1-ej1',
      );

      expect(doc.id, 'doc-1');
      expect(doc.title, 'Algoritmo 1');
      expect(doc.exerciseId, 'con-b1-ej1');

      final updated = doc.copyWith(
        title: 'Nuevo Titulo',
        revision: 2,
        exerciseId: () => 'con-b1-ej2',
      );
      expect(updated.title, 'Nuevo Titulo');
      expect(updated.revision, 2);
      expect(updated.content, 'algoritmo Test fin');
      expect(updated.exerciseId, 'con-b1-ej2');

      final summary = doc.toSummary();
      expect(summary.id, 'doc-1');
      expect(summary.title, 'Algoritmo 1');
      expect(summary.profileId, SyntaxProfileId.classicSpanish);
      expect(summary.updatedAt, now);
      expect(summary.exerciseId, 'con-b1-ej1');
    });
  });
}
