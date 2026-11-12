import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/input_wait.dart';
import 'package:pseudolearn_app/presentation/document/dialogs/data_input_dialog.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  testWidgets('shows request identity and returns the entered text', (
    tester,
  ) async {
    final values = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) =>
            DesignCanvas(child: child ?? const SizedBox.shrink()),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDataInputDialog(
                context: context,
                prompt: 'Ingresa un valor',
                inputWait: const InputWait(
                  resourceId: 4,
                  taskId: 7,
                  requestId: 11,
                ),
                onSubmit: values.add,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Tarea 7, solicitud 11'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'dato');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(values, ['dato']);
  });
}
