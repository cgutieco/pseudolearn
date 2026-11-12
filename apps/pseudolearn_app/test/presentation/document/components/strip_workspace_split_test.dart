import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/document/components/strip_workspace_split.dart';

const Key _stripKey = Key('strip');
const Key _workspaceKey = Key('workspace');

Future<void> _pumpSplit(
  WidgetTester tester, {
  required double stripHeight,
  double available = 600,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 300,
        height: available,
        child: StripWorkspaceSplit(
          strip: SingleChildScrollView(
            key: _stripKey,
            child: SizedBox(height: stripHeight),
          ),
          workspace: const SizedBox.expand(key: _workspaceKey),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('a short strip leaves the workspace the rest of the height', (
    tester,
  ) async {
    await _pumpSplit(tester, stripHeight: 36);

    expect(tester.getSize(find.byKey(_stripKey)).height, 36);
    expect(tester.getTopLeft(find.byKey(_workspaceKey)).dy, 36);
    expect(tester.getBottomLeft(find.byKey(_workspaceKey)).dy, 600);
  });

  testWidgets('a tall strip is capped at half and the workspace keeps the other half', (
    tester,
  ) async {
    await _pumpSplit(tester, stripHeight: 2000);

    expect(tester.getSize(find.byKey(_stripKey)).height, 300);
    expect(tester.getSize(find.byKey(_workspaceKey)).height, 300);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty strip leaves the workspace the whole height', (
    tester,
  ) async {
    await _pumpSplit(tester, stripHeight: 0);

    expect(tester.getSize(find.byKey(_stripKey)).height, 0);
    expect(tester.getSize(find.byKey(_workspaceKey)).height, 600);
  });

  testWidgets('a zero height leaves both parts empty without overflowing', (
    tester,
  ) async {
    await _pumpSplit(tester, stripHeight: 36, available: 0);

    expect(tester.getSize(find.byKey(_stripKey)).height, 0);
    expect(tester.getSize(find.byKey(_workspaceKey)).height, 0);
    expect(tester.takeException(), isNull);
  });
}
