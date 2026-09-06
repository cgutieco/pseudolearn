import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/knowledge/content_marker_scanner.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker_kind.dart';

void main() {
  const scanner = ContentMarkerScanner();

  group('ContentMarkerScanner', () {
    test('finds a marker and reports where it starts and ends', () {
      final found = scanner.scan('Se escribe {{lexema:whileKeyword}} aqui.');

      expect(found.length, 1);
      expect(found.single.marker?.kind, ContentMarkerKind.lexeme);
      expect(found.single.marker?.argument, 'whileKeyword');
      expect(found.single.raw, '{{lexema:whileKeyword}}');
      expect('Se escribe {{lexema:whileKeyword}} aqui.'.substring(
        found.single.start,
        found.single.end,
      ), '{{lexema:whileKeyword}}');
    });

    test('finds several markers in order', () {
      final found = scanner.scan('{{tabla:precedence}} y {{firma:length}}');

      expect(found.map((o) => o.marker?.kind).toList(), [
        ContentMarkerKind.table,
        ContentMarkerKind.signature,
      ]);
    });

    test('trims spaces around the kind and the argument', () {
      final found = scanner.scan('{{ lexema : whileKeyword }}');

      expect(found.single.marker?.argument, 'whileKeyword');
    });

    test('a marker with no colon is found but not parsed', () {
      final found = scanner.scan('{{lexema}}');

      expect(found.single.marker, isNull);
      expect(found.single.raw, '{{lexema}}');
    });

    test('a marker with an unknown kind is found but not parsed', () {
      expect(scanner.scan('{{simbolo:x}}').single.marker, isNull);
    });

    test('a marker with an empty argument is found but not parsed', () {
      expect(scanner.scan('{{lexema:}}').single.marker, isNull);
    });

    test('text with no markers yields nothing, and neither does empty text', () {
      expect(scanner.scan('Sin marcadores'), isEmpty);
      expect(scanner.scan(''), isEmpty);
    });

    test('an unclosed marker is not a marker', () {
      expect(scanner.scan('Roto {{lexema:whileKeyword'), isEmpty);
    });

    test('braces that are not a marker opening are ignored', () {
      expect(scanner.scan('Un solo { y otro }'), isEmpty);
    });
  });
}
