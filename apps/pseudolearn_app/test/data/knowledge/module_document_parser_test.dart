import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/knowledge/module_document_parser.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';

const String _complete = '''
:::parte pregunta
Por que hace falta guardar valores.

:::parte modelo-maquina
La memoria tiene nombres.

:::parte desarrollo
Una variable es un nombre con un valor.

:::parte prediccion
Que valor tiene a en el paso 4.

:::parte errores-frecuentes
Leer una variable sin asignarla.

:::parte especificacion
- ESP-I, datos

:::parte ejercicios
- CON-B1-E1
''';

List<ModuleSection> _sectionsOf(String source) {
  final result = const ModuleDocumentParser().parse(source);
  return (result as ContentLoaded<List<ModuleSection>>).value;
}

void main() {
  group('ModuleDocumentParser', () {
    test('reads the seven parts in the order they are written', () {
      final sections = _sectionsOf(_complete);

      expect(sections.map((s) => s.part).toList(), ModulePart.values);
      expect(sections.first.blocks.single, isA<ParagraphBlock>());
    });

    test('a module missing a part yields only the parts it declares', () {
      final withoutExercises = _complete.split(':::parte ejercicios').first;
      final sections = _sectionsOf(withoutExercises);

      expect(sections.length, 6);
      expect(sections.map((s) => s.part), isNot(contains(ModulePart.exercises)));
    });

    test('a document with no part delimiter at all is a named failure', () {
      final result = const ModuleDocumentParser().parse('# Un titulo suelto');

      expect(
        (result as ContentLoadFailed<List<ModuleSection>>).failure,
        ContentLoadFailure.moduleMalformed,
      );
    });

    test('an unknown part name is a named failure that says which name', () {
      final result = const ModuleDocumentParser().parse(
        ':::parte resumen\nTexto.\n',
      );

      final failed = result as ContentLoadFailed<List<ModuleSection>>;
      expect(failed.failure, ContentLoadFailure.unknownModulePart);
      expect(failed.detail, 'resumen');
    });

    test('text written before the first delimiter is not part of any section', () {
      final sections = _sectionsOf('Preambulo suelto.\n$_complete');

      expect(sections.length, 7);
      expect(sections.first.part, ModulePart.question);
    });

    test('a part with no text yields a section with no blocks', () {
      final sections = _sectionsOf(':::parte pregunta\n\n:::parte desarrollo\nTexto.\n');

      expect(sections.first.blocks, isEmpty);
      expect(sections.last.blocks, isNotEmpty);
    });

    test('an empty document is a named failure', () {
      final result = const ModuleDocumentParser().parse('');

      expect(
        (result as ContentLoadFailed<List<ModuleSection>>).failure,
        ContentLoadFailure.moduleMalformed,
      );
    });
  });
}
