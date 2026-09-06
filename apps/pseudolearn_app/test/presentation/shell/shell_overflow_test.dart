import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/shell/destinations.dart';
import '../../fakes/pump_app.dart';

const List<double> _windowWidths = <double>[
  360,
  480,
  600,
  800,
  960,
  1280,
  1440,
  1920,
  2560
];

const List<Locale> _locales = <Locale>[Locale('es'), Locale('en')];

void main() {
  group('The application lays out without overflowing', () {
    for (final locale in _locales) {
      for (final width in _windowWidths) {
        testWidgets('${width.toInt()} px in ${locale.languageCode}',
            (tester) async {
          final errors = await collectLayoutErrors(() async {
            await pumpApp(tester, Size(width, 900), locale: locale);
            for (final destination in appDestinations) {
              await visitDestination(tester, destination.path);
            }
          });

          expect(
            errors.map((e) => e.exception.toString()).toList(),
            isEmpty,
            reason:
                'Layout errors at ${width.toInt()} px in ${locale.languageCode}',
          );
        });
      }
    }
  });
}
