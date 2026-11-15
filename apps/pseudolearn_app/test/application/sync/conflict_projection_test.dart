import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/sync/conflict_projection.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

void main() {
  group('ConflictProjection', () {
    const projection = ConflictProjection();

    test('detects conflict titles and counts accurately', () {
      final doc1 = DocumentSummary(
        id: '1',
        title: 'Algoritmo Normal',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );
      final doc2 = DocumentSummary(
        id: '2',
        title: 'Algoritmo Normal (conflicto)',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );
      final doc3 = DocumentSummary(
        id: '3',
        title: 'Otro (conflicto) 2',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      expect(projection.isConflict(doc1), isFalse);
      expect(projection.isConflict(doc2), isTrue);
      expect(projection.isConflict(doc3), isTrue);

      expect(projection.countConflicts([doc1, doc2, doc3]), equals(2));
      expect(projection.countConflicts([doc1]), equals(0));
    });
  });
}
