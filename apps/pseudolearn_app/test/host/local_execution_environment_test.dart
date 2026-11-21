import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pseudolearn_app/host/local_execution_environment.dart';

void main() {
  group('LocalExecutionEnvironment', () {
    final root = p.join('documents', 'root');
    final executionRoot = p.join(root, 'execution');
    const environment = LocalExecutionEnvironment('documents/root');

    String directoryOf(String documentId) => LocalExecutionEnvironment(root).directoryFor(documentId);

    test('places a document inside the execution folder of the root', () {
      expect(directoryOf('3f2a9c1e-0b4d-4e8a-9f1c-2d3e4f5a6b7c'),
          p.join(executionRoot, '3f2a9c1e-0b4d-4e8a-9f1c-2d3e4f5a6b7c'));
    });

    test('joins with the platform separator instead of a literal slash', () {
      expect(environment.directoryFor('doc'), p.join('documents/root', 'execution', 'doc'));
    });

    test('a one character identifier keeps its own folder', () {
      expect(directoryOf('a'), p.join(executionRoot, 'a'));
    });

    test('separators in an identifier never create nested folders', () {
      final directory = directoryOf('folder/inner\\file');

      expect(p.dirname(directory), executionRoot);
    });

    test('dot segments never escape the execution folder', () {
      for (final documentId in ['.', '..', '../..', '...']) {
        final directory = directoryOf(documentId);

        expect(p.dirname(directory), executionRoot, reason: documentId);
        expect(p.normalize(directory), directory, reason: documentId);
      }
    });

    test('an empty identifier still gets a folder of its own', () {
      final directory = directoryOf('');

      expect(p.dirname(directory), executionRoot);
      expect(directory, isNot(executionRoot));
    });

    test('spaces and unicode stay distinguishable and inside the folder', () {
      final accented = directoryOf('programa número 1');
      final plain = directoryOf('programa numero 1');

      expect(p.dirname(accented), executionRoot);
      expect(accented, isNot(plain));
    });
  });
}
