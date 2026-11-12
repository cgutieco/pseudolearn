import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/presentation/document/components/execution_replay_section.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _help =
    'Vuelve a ejecutar el programa con los mismos datos que registró la última ejecución: lo que escribiste, los archivos y los argumentos. Sirve para volver a ver un error; solo funciona si no cambiaste el código.';
const _rejected =
    'No se puede repetir porque la grabación de la última ejecución no es válida. Pulsa Ejecutar para lanzarla de nuevo.';
const _changed =
    'No se puede repetir porque el código cambió desde la última ejecución. Pulsa Ejecutar para probar la versión actual.';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: DesignCanvas(child: child)),
);

VoidCallback? _pressOf(WidgetTester tester) => tester
    .widget<InkWell>(
      find
          .ancestor(
            of: find.text('Repetir última ejecución'),
            matching: find.byType(InkWell),
          )
          .first,
    )
    .onTap;

void main() {
  group('ExecutionReplaySection', () {
    testWidgets('explains what repeating does when nothing went wrong', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ExecutionReplaySection(execution: ExecutionState.initial()),
        ),
      );

      expect(find.text('Repetir última ejecución'), findsOneWidget);
      expect(find.text(_help), findsOneWidget);
      expect(find.text(_rejected), findsNothing);
      expect(_pressOf(tester), isNotNull);
    });

    testWidgets('a rejected replay replaces the explanation with the reason', (
      tester,
    ) async {
      final state = const ExecutionState.initial().copyWith(
        replayRejection: ReplayRejection.divergence,
      );
      await tester.pumpWidget(
        _wrap(ExecutionReplaySection(execution: state)),
      );

      expect(find.text(_rejected), findsOneWidget);
      expect(find.text(_help), findsNothing);
    });

    testWidgets('a changed program names the edit as the reason', (
      tester,
    ) async {
      final state = const ExecutionState.initial().copyWith(
        replayRejection: ReplayRejection.identityMismatch,
      );
      await tester.pumpWidget(
        _wrap(ExecutionReplaySection(execution: state)),
      );

      expect(find.text(_changed), findsOneWidget);
      expect(find.text(_rejected), findsNothing);
    });

    testWidgets('repeating is unavailable while a run is in flight', (
      tester,
    ) async {
      final state = const ExecutionState.initial().copyWith(
        status: ExecutionStatus.running,
      );
      await tester.pumpWidget(
        _wrap(ExecutionReplaySection(execution: state)),
      );

      expect(_pressOf(tester), isNull);
    });
  });
}
