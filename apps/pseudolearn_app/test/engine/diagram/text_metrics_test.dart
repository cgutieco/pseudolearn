import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/diagram/text_metrics.dart';

void main() {
  const metrics = TextMetrics();

  group('advanceUnits', () {
    test('grows with the number of characters', () {
      expect(metrics.advanceUnits('aa'), greaterThan(metrics.advanceUnits('a')));
    });

    test('wide characters advance more than narrow ones', () {
      expect(metrics.advanceUnits('mmmm'), greaterThan(metrics.advanceUnits('iiii')));
    });

    test('empty text advances nothing', () {
      expect(metrics.advanceUnits(''), 0.0);
    });

    test('is stable across repeated calls', () {
      expect(metrics.advanceUnits('contador <- 0'), metrics.advanceUnits('contador <- 0'));
    });
  });

  group('wrapText', () {
    test('returns a single line when the text fits', () {
      final lines = metrics.wrapText('a <- 1', maxUnits: 40.0, maxLines: 3);
      expect(lines, ['a <- 1']);
    });

    test('breaks on word boundaries when possible', () {
      final lines = metrics.wrapText('alfa beta gamma delta', maxUnits: 3.0, maxLines: 3);
      expect(lines.length, greaterThan(1));
      expect(lines.first, 'alfa');
    });

    test('splits a single word longer than the line', () {
      final lines = metrics.wrapText('aaaaaaaaaaaaaaaaaaaa', maxUnits: 3.0, maxLines: 3);
      expect(lines.length, 3);
    });

    test('marks truncation with an ellipsis when the text overflows', () {
      final lines = metrics.wrapText('a' * 500, maxUnits: 5.0, maxLines: 3);
      expect(lines.length, 3);
      expect(lines.last.endsWith('…'), isTrue);
    });

    test('never returns more lines than the limit', () {
      final lines = metrics.wrapText('x ' * 200, maxUnits: 4.0, maxLines: 2);
      expect(lines.length, lessThanOrEqualTo(2));
    });

    test('empty text yields one empty line', () {
      expect(metrics.wrapText('', maxUnits: 10.0, maxLines: 3), ['']);
    });

    test('a one-character text yields that character', () {
      expect(metrics.wrapText('n', maxUnits: 10.0, maxLines: 3), ['n']);
    });
  });
}
