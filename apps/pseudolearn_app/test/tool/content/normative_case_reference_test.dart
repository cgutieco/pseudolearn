import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import '../../../tool/content/normative_case_reference.dart';

const String _specification = '''
---
{
  "id": "LANG.TYPES.INTERFACE",
  "version": "1.0.0"
}
---

```caso
{
  "id": "C5",
  "regla": "R2"
}
```
''';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('normative-case-');
    final file = File(p.join(root.path, 'lang', 'lang.types.interface.md'));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(_specification);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  test('accepts a case from the cited specification version', () {
    expect(
      specificationCaseExists(
        'LANG.TYPES.INTERFACE@1.0.0#C5',
        specificationRoot: root.path,
      ),
      isTrue,
    );
    expect(
      checkNormativeCaseReferences(
        exerciseId: 'CON-C4-E7',
        languageCode: 'en',
        references: const ['LANG.TYPES.INTERFACE@1.0.0#C5'],
        specificationRoot: root.path,
      ),
      isEmpty,
    );
  });

  test('rejects malformed, missing and wrong-version references', () {
    final errors = checkNormativeCaseReferences(
      exerciseId: 'CON-C4-E7',
      languageCode: 'en',
      references: const [
        'LANG.TYPES.INTERFACE#C5',
        'LANG.TYPES.INTERFACE@1.0.0#C99',
        'LANG.TYPES.INTERFACE@2.0.0#C5',
      ],
      specificationRoot: root.path,
    );

    expect(errors, hasLength(3));
    expect(errors, everyElement(contains('unknown normative case')));
  });
}
