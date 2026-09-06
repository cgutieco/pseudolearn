import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/library_metrics_projection.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'dashboard_fixtures.dart';

void main() {
  group('projectLibraryMetrics (PANT-06-F5)', () {
    test('counts documents and splits them by syntax profile', () {
      final metrics = projectLibraryMetrics([
        summaryOf('a'),
        summaryOf('b'),
        summaryOf('c', profileId: SyntaxProfileId.english),
      ]);

      expect(metrics.total, 3);
      expect(metrics.countOf(SyntaxProfileId.classicSpanish), 2);
      expect(metrics.countOf(SyntaxProfileId.english), 1);
    });

    test('an empty library reports zero for every profile', () {
      final metrics = projectLibraryMetrics(const []);

      expect(metrics.total, 0);
      expect(metrics.countOf(SyntaxProfileId.classicSpanish), 0);
      expect(metrics.countOf(SyntaxProfileId.english), 0);
    });

    test('a profile with no documents reports zero, never null', () {
      final metrics = projectLibraryMetrics([summaryOf('a')]);

      expect(metrics.countOf(SyntaxProfileId.english), 0);
    });
  });
}
