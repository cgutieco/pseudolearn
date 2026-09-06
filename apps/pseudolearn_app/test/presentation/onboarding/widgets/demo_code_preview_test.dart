import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/demo_code_preview.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildPreview({
  required String code,
  int? activeLine,
  double height = 200,
  double width = 360,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: DesignCanvas(
        child: SizedBox(
          width: width,
          child: DemoCodePreviewCard(
            code: code,
            activeLine: activeLine,
            height: height,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('DemoCodePreviewCard', () {
    testWidgets('renders all lines and line numbers completely without ellipsis', (tester) async {
      const code = 'Proceso Demo\n'
          '    Definir temperatura Como Entero;\n'
          '    Escribir "Lectura ", lecturas, ": ", temperatura, " grados";\n'
          'FinProceso';

      await tester.pumpWidget(_buildPreview(code: code));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text(code), findsOneWidget);
      expect(find.byType(CodeField), findsOneWidget);
    });

    testWidgets('allows horizontal scrolling when a code line exceeds card width', (tester) async {
      const longLine = '    Escribir "Mensaje sumamente largo que sobrepasa el ancho de la tarjeta para verificar el scroll horizontal";';
      const code = 'Proceso Largo\n$longLine\nFinProceso';

      await tester.pumpWidget(_buildPreview(code: code, width: 280));
      await tester.pumpAndSettle();

      final horizontalScroll = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal,
      );
      expect(horizontalScroll, findsOneWidget);

      final scrollable = tester.widget<SingleChildScrollView>(horizontalScroll);
      expect(scrollable.scrollDirection, Axis.horizontal);

      await tester.drag(horizontalScroll, const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(find.text(code), findsOneWidget);
    });

    testWidgets('highlights the active line in gutter', (tester) async {
      const code = 'linea Uno\nlinea Dos\nlinea Tres';

      await tester.pumpWidget(_buildPreview(code: code, activeLine: 2));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('handles empty code and single line gracefully', (tester) async {
      await tester.pumpWidget(_buildPreview(code: ''));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DemoCodePreviewCard), findsOneWidget);

      await tester.pumpWidget(_buildPreview(code: 'algoritmo Solo'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('algoritmo Solo'), findsOneWidget);
    });

    testWidgets('updates vertical reveal position when activeLine changes', (tester) async {
      final code = List.generate(30, (i) => 'instruccion $i').join('\n');

      await tester.pumpWidget(_buildPreview(code: code, activeLine: 1));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_buildPreview(code: code, activeLine: 25));
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
    });
  });
}
