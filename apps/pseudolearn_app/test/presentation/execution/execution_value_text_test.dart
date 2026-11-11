import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/execution/execution_value_text.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations_en.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations_es.dart';

void main() {
  final spanish = AppLocalizationsEs();
  final english = AppLocalizationsEn();
  Map<String, Object?> channel({bool open = true, int queued = 0}) => {
    'canal': {
      'identidad': 1,
      'capacidad': 2,
      'abierto': open,
      'en_cola': queued,
    },
  };

  group('executionValueText', () {
    test('a channel shows its identity, capacity, state and queue', () {
      expect(
        executionValueText(spanish, channel(queued: 1)),
        'Canal 1: capacidad 2, abierto, 1 en cola',
      );
      expect(
        executionValueText(english, channel(open: false, queued: 1)),
        'Channel 1: capacity 2, closed, 1 queued',
      );
    });

    test('a malformed channel falls back to the raw wire value', () {
      final text = executionValueText(spanish, {
        'canal': {'identidad': 1},
      });
      expect(text, '{"canal":{"identidad":1}}');
    });

    test('the scalar shapes keep their text', () {
      expect(executionValueText(spanish, {'valor': '7'}), '7');
      expect(executionValueText(spanish, {'nulo': true}), 'Nulo');
      expect(executionValueText(english, {'nulo': true}), 'Null');
      expect(executionValueText(spanish, {'ref': 3}), 'Referencia 3');
      expect(executionValueText(spanish, {'sin_valor': true}), 'Sin valor');
    });
  });
}
