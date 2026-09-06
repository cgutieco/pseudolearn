import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import '../../tool/check_content.dart';

const String _manifest = '''
{
  "manifestVersion": 2,
  "contentVersion": 1,
  "modules": [
    {
      "id": "CON-B1",
      "track": "B",
      "order": 1,
      "title": "Datos",
      "summary": "Tipos y variables.",
      "path": "modules/CON-B1_es.md",
      "constructs": []
    }
  ],
  "specification": [
    {
      "id": "esp-i-datos",
      "document": "esp-i",
      "anchor": "datos",
      "order": 1,
      "title": "Datos",
      "summary": "Tipos y operadores.",
      "path": "specification/esp-i-datos_es.md"
    }
  ],
  "exercises": [
    {
      "id": "CON-B1-E1",
      "level": 1,
      "kind": "crear",
      "module": "CON-B1",
      "title": "Cuadrado",
      "summary": "Escribe el cuadrado.",
      "path": "exercises/CON-B1-E1_es.json"
    }
  ],
  "examples": [
    {
      "id": "example-cuadrado",
      "title": "Cuadrado",
      "summary": "Eleva al cuadrado.",
      "path": "examples/cuadrado_es.pseudo",
      "profile": "classic_spanish"
    }
  ],
  "illustrations": [
    {"id": "cajas-memoria", "title": "Cajas de memoria", "summary": "Memoria con nombres."}
  ]
}
''';

const String _module = '''
:::parte pregunta
Como se guarda un valor con un nombre.

:::parte modelo-maquina
La memoria tiene casillas con nombre.

{{figura:cajas-memoria}}

:::parte desarrollo
Una variable es un nombre para un valor.

{{ejemplo:example-cuadrado}}

:::parte prediccion
Que valor tiene n en el paso 4.

:::parte errores-frecuentes
Declarar y asignar en la misma linea no esta permitido.

```pseudo
Algoritmo Error
  Definir n Como Entero <- 5
FinAlgoritmo
```

{{diagnostico:initializationInDeclarationNotAllowed}}

:::parte especificacion
- esp-i-datos Tipos y operadores

:::parte ejercicios
- CON-B1-E1 Cuadrado
''';

const String _specification = '''
# Datos

Cinco tipos primitivos.

## Tipos

{{ejemplo:example-cuadrado}}
''';

const String _exercise = '''
{
  "id": "CON-B1-E1",
  "title": "Cuadrado",
  "statement": "Lee un entero y escribe su cuadrado.",
  "level": 1,
  "kind": "crear",
  "module": "CON-B1",
  "visibleCases": [
    {"inputs": ["4"], "expectedOutputs": ["16"], "expected": "numerico"}
  ],
  "hiddenCases": [
    {"inputs": ["7"], "expectedOutputs": ["49"], "expected": "numerico"}
  ],
  "referenceSolution": "Algoritmo Cuadrado\\n  Definir n Como Entero\\n  Leer n\\n  Escribir n * n\\nFinAlgoritmo\\n"
}
''';

const String _example = '''
Algoritmo Cuadrado
  Definir n Como Entero
  n <- 4
  Escribir n * n
FinAlgoritmo
''';

Map<String, String> get _goodContent => {
      'manifest_es.json': _manifest,
      'modules/CON-B1_es.md': _module,
      'specification/esp-i-datos_es.md': _specification,
      'exercises/CON-B1-E1_es.json': _exercise,
      'examples/cuadrado_es.pseudo': _example,
    };

Directory _fixture(String name, Map<String, String> files) {
  final dir = Directory(
    p.join(Directory.current.path, 'test', 'tool', 'fixtures', 'content', name),
  );
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);
  addTearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  files.forEach((relative, contents) {
    final file = File(p.join(dir.path, relative));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
  });
  return dir;
}

Future<List<String>> _errorsOf(String name, Map<String, String> files) {
  return validateKnowledgeDirectory(_fixture(name, files));
}

Map<String, String> _withReplacement(String path, String from, String to) {
  final files = _goodContent;
  files[path] = files[path]!.replaceAll(from, to);
  return files;
}

void main() {
  group('Knowledge Content Checker · real assets', () {
    test('passes cleanly on the real knowledge assets directory', () async {
      final realDir = Directory(p.join(Directory.current.path, 'assets', 'knowledge'));

      expect(await validateKnowledgeDirectory(realDir), isEmpty);
    });

    test('passes on a fixture that satisfies every invariant', () async {
      expect(await _errorsOf('good', _goodContent), isEmpty);
    });

    test('passes when the directory does not exist or the manifest is empty', () async {
      final absent = Directory(p.join(Directory.current.path, 'no', 'such', 'place'));

      expect(await validateKnowledgeDirectory(absent), isEmpty);
      expect(
        await _errorsOf('empty', {'manifest_es.json': '{"manifestVersion": 2}'}),
        isEmpty,
      );
    });

    test('passes with a single declared language', () async {
      expect(await _errorsOf('one_language', _goodContent), isEmpty);
    });
  });

  group('Knowledge Content Checker · the four original failures', () {
    test('fails when the manifest references a missing file', () async {
      final files = _goodContent..remove('examples/cuadrado_es.pseudo');

      expect(
        await _errorsOf('missing_file', files),
        contains(contains('references missing file')),
      );
    });

    test('fails when an orphan file is not referenced by any manifest', () async {
      final files = _goodContent..['examples/huerfano_es.pseudo'] = _example;

      expect(
        await _errorsOf('orphan_file', files),
        contains(contains('Orphan file in knowledge assets')),
      );
    });

    test('fails when entry identifiers are asymmetric between languages', () async {
      final files = _goodContent
        ..['manifest_en.json'] = '{"manifestVersion": 2, "modules": []}';

      expect(
        await _errorsOf('asymmetric_ids', files),
        contains(contains('is missing in "en" manifest')),
      );
    });

    test('fails when an example does not analyse cleanly under its profile', () async {
      expect(
        await _errorsOf(
          'dirty_example',
          _withReplacement('examples/cuadrado_es.pseudo', 'Definir n Como Entero', 'Definir Como Entero'),
        ),
        contains(contains('does not analyse cleanly')),
      );
    });
  });

  group('Knowledge Content Checker · the new failures', () {
    test('fails when a marker names something the engine does not have', () async {
      expect(
        await _errorsOf(
          'unresolved_marker',
          _withReplacement('modules/CON-B1_es.md', '{{ejemplo:example-cuadrado}}', '{{lexema:goto}}'),
        ),
        contains(contains('unresolvedMarker')),
      );
    });

    test('fails when a module does not have its seven parts', () async {
      expect(
        await _errorsOf(
          'missing_part',
          _withReplacement('modules/CON-B1_es.md', ':::parte prediccion', ':::parte desarrollo'),
        ),
        contains(contains('is missing its')),
      );
    });

    test('fails when a module anchors a specification section that does not exist', () async {
      expect(
        await _errorsOf(
          'bad_anchor',
          _withReplacement('modules/CON-B1_es.md', '- esp-i-datos ', '- esp-i-arreglos '),
        ),
        contains(contains('which no specification section declares')),
      );
    });

    test('fails when a module lists an exercise the manifest does not declare', () async {
      expect(
        await _errorsOf(
          'bad_exercise_reference',
          _withReplacement('modules/CON-B1_es.md', '- CON-B1-E1 ', '- CON-B1-E9 '),
        ),
        contains(contains('which the manifest does not declare')),
      );
    });

    test('fails when the reference solution does not pass its own cases', () async {
      expect(
        await _errorsOf(
          'broken_solution',
          _withReplacement('exercises/CON-B1-E1_es.json', 'Escribir n * n', 'Escribir n + n'),
        ),
        contains(contains('the reference solution does not solve it')),
      );
    });

    test('fails when an exercise has no reference solution at all', () async {
      expect(
        await _errorsOf(
          'no_solution',
          _withReplacement('exercises/CON-B1-E1_es.json', '"referenceSolution"', '"unusedSolution"'),
        ),
        contains(contains('has no reference solution')),
      );
    });

    test('fails when the hidden cases do not discriminate the impostor program', () async {
      expect(
        await _errorsOf(
          'weak_hidden_cases',
          _withReplacement('exercises/CON-B1-E1_es.json', '{"inputs": ["7"], "expectedOutputs": ["49"], "expected": "numerico"}', '{"inputs": ["4"], "expectedOutputs": ["16"], "expected": "numerico"}'),
        ),
        contains(contains('do not discriminate')),
      );
    });

    test('fails when a level 1 exercise needs a construct beyond its module', () async {
      const withLoop =
          '"referenceSolution": "Algoritmo Cuadrado\\n  Definir n Como Entero\\n  Definir i Como Entero\\n  Definir total Como Entero\\n  Leer n\\n  total <- 0\\n  Para i <- 1 Hasta n Con Paso 1 Hacer\\n    total <- total + n\\n  FinPara\\n  Escribir total\\nFinAlgoritmo\\n"';
      final files = _goodContent;
      final start = files['exercises/CON-B1-E1_es.json']!.indexOf('"referenceSolution"');
      files['exercises/CON-B1-E1_es.json'] =
          '${files['exercises/CON-B1-E1_es.json']!.substring(0, start)}$withLoop\n}\n';

      expect(
        await _errorsOf('dishonest_level', files),
        contains(contains('uses constructs beyond its module')),
      );
    });

    test('fails when a cited diagnostic is not produced by its program', () async {
      expect(
        await _errorsOf(
          'unreal_diagnostic',
          _withReplacement('modules/CON-B1_es.md', '{{diagnostico:initializationInDeclarationNotAllowed}}', '{{diagnostico:divisionByZero}}'),
        ),
        contains(contains('but no program in its common errors part produces it')),
      );
    });

    test('fails when an illustration is declared but never referenced', () async {
      expect(
        await _errorsOf(
          'unused_illustration',
          _withReplacement('modules/CON-B1_es.md', '{{figura:cajas-memoria}}', 'Sin figura.'),
        ),
        contains(contains('is declared but never referenced')),
      );
    });

    test('fails when a module has a different structure in the other language', () async {
      final files = _goodContent
        ..['manifest_en.json'] = _manifest.replaceAll('_es.', '_en.')
        ..['modules/CON-B1_en.md'] =
            _module.replaceAll('Como se guarda un valor con un nombre.', '# A heading that Spanish does not have')
        ..['specification/esp-i-datos_en.md'] = _specification
        ..['exercises/CON-B1-E1_en.json'] = _exercise
        ..['examples/cuadrado_en.pseudo'] = _example;

      expect(
        await _errorsOf('module_parity', files),
        contains(contains('has a different heading tree')),
      );
    });

    test('fails when an exercise has different cases in the other language', () async {
      final files = _goodContent
        ..['manifest_en.json'] = _manifest.replaceAll('_es.', '_en.')
        ..['modules/CON-B1_en.md'] = _module
        ..['specification/esp-i-datos_en.md'] = _specification
        ..['exercises/CON-B1-E1_en.json'] =
            _exercise.replaceAll('"expectedOutputs": ["49"]', '"expectedOutputs": ["48"]')
        ..['examples/cuadrado_en.pseudo'] = _example;

      expect(
        await _errorsOf('case_parity', files),
        contains(contains('does not declare the same hidden cases')),
      );
    });

    test('fails when a specification section differs in structure between languages', () async {
      final files = _goodContent
        ..['manifest_en.json'] = _manifest.replaceAll('_es.', '_en.')
        ..['modules/CON-B1_en.md'] = _module
        ..['specification/esp-i-datos_en.md'] = '$_specification\n## Una seccion de mas\n\nTexto.\n'
        ..['exercises/CON-B1-E1_en.json'] = _exercise
        ..['examples/cuadrado_en.pseudo'] = _example;

      expect(
        await _errorsOf('specification_parity', files),
        contains(contains('has a different heading tree')),
      );
    });

    test('fails when the two language versions of an example differ in tree shape', () async {
      final files = _goodContent
        ..['manifest_en.json'] = _manifest.replaceAll('_es.', '_en.')
        ..['modules/CON-B1_en.md'] = _module
        ..['specification/esp-i-datos_en.md'] = _specification
        ..['exercises/CON-B1-E1_en.json'] = _exercise
        ..['examples/cuadrado_en.pseudo'] =
            _example.replaceAll('Escribir n * n', 'Escribir n * n\n  Escribir n');

      expect(
        await _errorsOf('example_shape', files),
        contains(contains('does not produce the same tree shape')),
      );
    });

    test('fails when a specification subsection has no code example and is not exempt', () async {
      expect(
        await _errorsOf(
          'spec_no_example',
          _withReplacement(
            'specification/esp-i-datos_es.md',
            '{{ejemplo:example-cuadrado}}',
            'Texto sin ejemplo.',
          ),
        ),
        contains(contains('has no code example and is not in the exempt list')),
      );
    });

    test('fails when a specification diagnostic cited is not produced by its program', () async {
      expect(
        await _errorsOf(
          'spec_unreal_diagnostic',
          _withReplacement(
            'specification/esp-i-datos_es.md',
            '{{ejemplo:example-cuadrado}}',
            '```pseudo\nAlgoritmo Ok\nFinAlgoritmo\n```\n\n{{diagnostico:divisionByZero}}',
          ),
        ),
        contains(contains('cites diagnostic "divisionByZero", but no program in that section produces it')),
      );
    });

    test('fails when an example is declared but never referenced', () async {
      final manifestWithExtra = _manifest.replaceAll(
        '"examples": [',
        '"examples": [\n    {"id": "example-unused", "title": "Unused", "summary": "Unused.", "path": "examples/unused_es.pseudo", "profile": "classic_spanish"},',
      );
      final files = _goodContent
        ..['manifest_es.json'] = manifestWithExtra
        ..['examples/unused_es.pseudo'] = _example;

      expect(
        await _errorsOf('unused_example', files),
        contains(contains('is declared but never referenced')),
      );
    });

    test('fails when a specification-only example exceeds twelve lines', () async {
      const longExample = '''
Algoritmo Largo
  Definir a Como Entero
  Definir b Como Entero
  Definir c Como Entero
  Definir d Como Entero
  Definir e Como Entero
  Definir f Como Entero
  Definir g Como Entero
  Definir h Como Entero
  Definir i Como Entero
  Definir j Como Entero
  Definir k Como Entero
FinAlgoritmo
''';
      final manifestWithLong = _manifest.replaceAll(
        '"examples": [',
        '"examples": [\n    {"id": "example-long", "title": "Long", "summary": "Long.", "path": "examples/long_es.pseudo", "profile": "classic_spanish"},',
      );
      final files = _goodContent
        ..['manifest_es.json'] = manifestWithLong
        ..['examples/long_es.pseudo'] = longExample
        ..['specification/esp-i-datos_es.md'] = '$_specification\n{{ejemplo:example-long}}';

      expect(
        await _errorsOf('long_spec_example', files),
        contains(contains('exceeding the limit of 12')),
      );
    });
  });

  group('Knowledge Content Checker · declared exceptions and edge cases', () {
    test('CON-A1 may have no exercises part, and only CON-A1', () async {
      final withoutExercises = _module.split(':::parte ejercicios').first;
      final asA1 = _manifest
          .replaceAll('CON-B1', 'CON-A1')
          .replaceAll('"track": "B"', '"track": "A"');
      final files = {
        'manifest_es.json': asA1,
        'modules/CON-A1_es.md': withoutExercises.replaceAll('CON-B1-E1', 'CON-A1-E1'),
        'specification/esp-i-datos_es.md': _specification,
        'exercises/CON-A1-E1_es.json': _exercise.replaceAll('CON-B1', 'CON-A1'),
        'examples/cuadrado_es.pseudo': _example,
      };

      final errors = await _errorsOf('con_a1', files);

      expect(errors, isNot(contains(contains('is missing its "ejercicios" part'))));
    });

    test('an exercise with no hidden cases is not asked to discriminate', () async {
      expect(
        await _errorsOf(
          'no_hidden_cases',
          _withReplacement(
            'exercises/CON-B1-E1_es.json',
            '"hiddenCases": [\n    {"inputs": ["7"], "expectedOutputs": ["49"], "expected": "numerico"}\n  ]',
            '"hiddenCases": []',
          ),
        ),
        isEmpty,
      );
    });

    test('a module with no illustrations passes', () async {
      final files = _withReplacement('modules/CON-B1_es.md', '{{figura:cajas-memoria}}', 'Sin figura.');
      files['manifest_es.json'] = _manifest.replaceAll(
        '"illustrations": [\n    {"id": "cajas-memoria", "title": "Cajas de memoria", "summary": "Memoria con nombres."}\n  ]',
        '"illustrations": []',
      );

      expect(await _errorsOf('no_illustrations', files), isEmpty);
    });
  });
}
