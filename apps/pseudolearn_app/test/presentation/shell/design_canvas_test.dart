import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/shell/device_class.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/motion.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';

void _setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<DesignCanvasData> _pumpAndRead(
  WidgetTester tester,
  Size size, {
  bool disableAnimations = false,
  TextScaler textScaler = TextScaler.noScaling,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) async {
  _setViewSize(tester, size);
  late DesignCanvasData captured;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        disableAnimations: disableAnimations,
        textScaler: textScaler,
        viewInsets: viewInsets,
      ),
      child: MaterialApp(
        home: DesignCanvas(
          child: Builder(
            builder: (context) {
              captured = DesignCanvasScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );
  return captured;
}


void main() {
  group('DesignCanvas device class resolution', () {
    testWidgets('a narrow window resolves compact', (tester) async {
      final data = await _pumpAndRead(tester, const Size(360, 800));
      expect(data.deviceClass, DeviceClass.compact);
    });

    testWidgets('the class boundaries land on 600 and 960', (tester) async {
      expect((await _pumpAndRead(tester, const Size(599, 900))).deviceClass, DeviceClass.compact);
      expect((await _pumpAndRead(tester, const Size(600, 900))).deviceClass, DeviceClass.medium);
      expect((await _pumpAndRead(tester, const Size(959, 900))).deviceClass, DeviceClass.medium);
      expect((await _pumpAndRead(tester, const Size(960, 900))).deviceClass, DeviceClass.expanded);
    });

    testWidgets('an ultrawide window is still expanded, not a class of its own', (tester) async {
      final data = await _pumpAndRead(tester, const Size(3440, 1440));
      expect(data.deviceClass, DeviceClass.expanded);
      expect(data.size.width, 3440);
    });
  });

  group('DesignCanvas density scale', () {
    testWidgets('the scale depends on the class, never on the window width', (tester) async {
      final atMinimum = await _pumpAndRead(tester, const Size(960, 900));
      final atUltrawide = await _pumpAndRead(tester, const Size(3440, 1440));
      expect(atUltrawide.scaled(SpacingTokens.space4), atMinimum.scaled(SpacingTokens.space4));
    });

    testWidgets('a compact window applies no density scaling', (tester) async {
      final data = await _pumpAndRead(tester, const Size(360, 800));
      expect(data.scaled(SpacingTokens.space4), SpacingTokens.space4);
    });
  });

  group('DesignCanvas content measures', () {
    testWidgets('reading is narrower than wide, and full is unbounded', (tester) async {
      final data = await _pumpAndRead(tester, const Size(1920, 1080));
      expect(data.maxWidthFor(ContentMeasure.reading),
          lessThan(data.maxWidthFor(ContentMeasure.wide)));
      expect(data.maxWidthFor(ContentMeasure.full), double.infinity);
    });
  });

  group('DesignCanvas motion', () {
    testWidgets('animations run at full duration by default', (tester) async {
      final data = await _pumpAndRead(tester, const Size(960, 900));
      expect(data.motion(MotionSpeed.standard), MotionTokens.motionDefault);
    });

    testWidgets('the reduced duration wins when the system asks for less motion', (tester) async {
      final data = await _pumpAndRead(tester, const Size(960, 900), disableAnimations: true);
      expect(data.motion(MotionSpeed.standard), MotionTokens.motionDefaultReduced);
      expect(data.motion(MotionSpeed.step), Duration.zero);
    });
  });

  group('DesignCanvas text scaling', () {
    testWidgets('a scale above the ceiling is clamped', (tester) async {
      _setViewSize(tester, const Size(960, 900));
      late TextScaler published;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(960, 900), textScaler: TextScaler.linear(4.0)),
          child: MaterialApp(
            home: DesignCanvas(
              child: Builder(builder: (context) {
                published = MediaQuery.textScalerOf(context);
                return const SizedBox();
              }),
            ),
          ),
        ),
      );
      expect(published.scale(10), lessThanOrEqualTo(10 * 2.0));
    });
  });

  group('DesignCanvas keyboard visibility', () {
    testWidgets('reports keyboard visible when bottom inset is non-zero', (tester) async {
      final withKeyboard = await _pumpAndRead(
        tester,
        const Size(360, 800),
        viewInsets: const EdgeInsets.only(bottom: 300),
      );
      expect(withKeyboard.isKeyboardVisible, isTrue);

      final withoutKeyboard = await _pumpAndRead(
        tester,
        const Size(360, 800),
        viewInsets: EdgeInsets.zero,
      );
      expect(withoutKeyboard.isKeyboardVisible, isFalse);
    });
  });
}

