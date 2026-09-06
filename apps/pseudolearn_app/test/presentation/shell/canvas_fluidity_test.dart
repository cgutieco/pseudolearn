import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';

const List<double> _windowWidths = <double>[360, 600, 800, 960, 1280, 1440, 1920, 2560, 3440];

Future<double> _contentWidthAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(home: DesignCanvas(child: Scaffold(body: SizedBox.expand(child: ColoredBox(key: key, color: const Color(0xFF000000)))))),
  );
  return (key.currentContext!.findRenderObject()! as RenderBox).size.width;
}

void main() {
  group('The design canvas keeps the whole window at every width', () {
    for (final width in _windowWidths) {
      testWidgets('${width.toInt()} px is used in full', (tester) async {
        expect(await _contentWidthAt(tester, width), equals(width));
      });
    }
  });

  testWidgets('the canvas publishes its own size, not the window size', (tester) async {
    tester.view.physicalSize = const Size(1920, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late Size published;
    await tester.pumpWidget(
      MaterialApp(
        home: DesignCanvas(
          child: Builder(builder: (context) {
            published = MediaQuery.sizeOf(context);
            return const SizedBox.shrink();
          }),
        ),
      ),
    );

    expect(published.width, equals(1920));
  });

  testWidgets('nesting the canvas is rejected instead of silently halving the width', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DesignCanvas(child: DesignCanvas(child: SizedBox.shrink()))),
    );
    expect(tester.takeException(), isAssertionError);
  });
}
