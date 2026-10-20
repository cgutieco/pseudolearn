import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/presentation/editor/components/completion_detail_label.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations_en.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations_es.dart';

CompletionItem _item(String? key, [List<String> arguments = const []]) =>
    CompletionItem(
      label: 'x',
      template: 'x',
      caretOffset: 1,
      family: CompletionFamily.structured,
      detail: 'prosa',
      detailKey: key,
      detailArguments: arguments,
    );

void main() {
  group('localizedCompletionDetail', () {
    test('translates the stable keys to the interface language', () {
      final english = AppLocalizationsEn();
      final spanish = AppLocalizationsEs();
      expect(
        localizedCompletionDetail(english, _item('close_block')),
        'Close block',
      );
      expect(
        localizedCompletionDetail(spanish, _item('close_block')),
        'Cerrar bloque',
      );
      expect(
        localizedCompletionDetail(spanish, _item('structure')),
        'Estructura',
      );
      expect(
        localizedCompletionDetail(english, _item('primitive_type')),
        'Primitive type',
      );
      expect(localizedCompletionDetail(spanish, _item('class')), 'Clase');
      expect(
        localizedCompletionDetail(english, _item('standard_function')),
        'Standard function',
      );
    });

    test('formats the bilingual equivalent with its term', () {
      expect(
        localizedCompletionDetail(
          AppLocalizationsEs(),
          _item('bilingual_equivalent', ['while']),
        ),
        'Equivalente de while',
      );
    });

    test('type names and signatures are shown as the service sent them', () {
      final spanish = AppLocalizationsEs();
      expect(
        localizedCompletionDetail(spanish, _item('type_name', ['Entero'])),
        'Entero',
      );
      expect(
        localizedCompletionDetail(spanish, _item('signature', ['F(a)'])),
        'F(a)',
      );
      expect(localizedCompletionDetail(spanish, _item('type_name')), isNull);
    });

    test('an unknown key falls back to the prose detail', () {
      expect(
        localizedCompletionDetail(AppLocalizationsEs(), _item('futuro')),
        'prosa',
      );
      expect(
        localizedCompletionDetail(AppLocalizationsEs(), _item(null)),
        'prosa',
      );
    });
  });
}
