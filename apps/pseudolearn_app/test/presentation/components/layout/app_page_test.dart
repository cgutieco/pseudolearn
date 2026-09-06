import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_page.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void _setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildTestApp(Widget child, {Size size = const Size(800, 600)}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(
      theme: AppTheme.light(),
      home: DesignCanvas(child: Scaffold(body: child)),
    ),
  );
}

void main() {
  group('AppPage layout', () {
    testWidgets('renders title and body without action or filter', (tester) async {
      _setViewSize(tester, const Size(800, 600));

      await tester.pumpWidget(_buildTestApp(
        const AppPage(
          title: 'Test Title',
          body: Text('Body Content'),
        ),
      ));

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders action on the right side of the title', (tester) async {
      _setViewSize(tester, const Size(800, 600));

      await tester.pumpWidget(_buildTestApp(
        const AppPage(
          title: 'Test Title',
          action: SizedBox(key: Key('test-action'), width: 50, height: 30),
          body: Text('Body Content'),
        ),
      ));

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byKey(const Key('test-action')), findsOneWidget);

      final titleTopLeft = tester.getTopLeft(find.text('Test Title'));
      final actionTopLeft = tester.getTopLeft(find.byKey(const Key('test-action')));

      expect(actionTopLeft.dx, greaterThan(titleTopLeft.dx));
    });

    testWidgets('renders filter below heading and above body', (tester) async {
      _setViewSize(tester, const Size(800, 600));

      await tester.pumpWidget(_buildTestApp(
        const AppPage(
          title: 'Test Title',
          filter: SizedBox(key: Key('test-filter'), height: 40),
          body: Text('Body Content'),
        ),
      ));

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byKey(const Key('test-filter')), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);

      final titleBottom = tester.getBottomLeft(find.text('Test Title')).dy;
      final filterTop = tester.getTopLeft(find.byKey(const Key('test-filter'))).dy;
      final bodyTop = tester.getTopLeft(find.text('Body Content')).dy;

      expect(filterTop, greaterThan(titleBottom));
      expect(bodyTop, greaterThan(filterTop));
    });
  });
}
