import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/agent/reply_run.dart';
import 'package:pseudolearn_app/application/agent/reply_link_policy.dart';
import 'package:pseudolearn_app/presentation/agent/reply/reply_runs_text.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../../fakes/fake_external_url_launcher.dart';

Widget _host(FakeExternalUrlLauncher launcher, List<ReplyRun> runs) {
  return RepositoryProvider<ReplyLinkOpener>.value(
    value: ReplyLinkOpener(launcher),
    child: MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
      home: Scaffold(body: ReplyRunsText(runs: runs)),
    ),
  );
}

TapGestureRecognizer? _recognizerOf(WidgetTester tester, String text) {
  final rich = tester.widget<RichText>(find.byType(RichText).last);
  TapGestureRecognizer? found;
  rich.text.visitChildren((span) {
    if (span is TextSpan && span.text == text) found = span.recognizer as TapGestureRecognizer?;
    return true;
  });
  return found;
}

void main() {
  testWidgets('tapping an https link opens it outside the app', (tester) async {
    final launcher = FakeExternalUrlLauncher();
    await tester.pumpWidget(_host(launcher, const [
      ReplyRun('see '),
      ReplyRun('the docs', target: 'https://pseudolearn.app/docs'),
    ]));

    _recognizerOf(tester, 'the docs')?.onTap?.call();

    expect(launcher.launchedUrls, [Uri.parse('https://pseudolearn.app/docs')]);
  });

  testWidgets('a link with an unsafe scheme is plain text and opens nothing', (tester) async {
    final launcher = FakeExternalUrlLauncher();
    await tester.pumpWidget(_host(launcher, const [
      ReplyRun('run it', target: 'javascript:alert(1)'),
    ]));

    expect(_recognizerOf(tester, 'run it'), isNull);
    expect(launcher.launchedUrls, isEmpty);
  });

  testWidgets('text without a target has no tap handler', (tester) async {
    final launcher = FakeExternalUrlLauncher();
    await tester.pumpWidget(_host(launcher, const [ReplyRun('plain')]));

    expect(_recognizerOf(tester, 'plain'), isNull);
  });

  testWidgets('rebuilding with new runs does not leak the old recognizers', (tester) async {
    final launcher = FakeExternalUrlLauncher();
    await tester.pumpWidget(_host(launcher, const [ReplyRun('one', target: 'https://a.example')]));
    await tester.pumpWidget(_host(launcher, const [ReplyRun('two', target: 'https://b.example')]));

    _recognizerOf(tester, 'two')?.onTap?.call();

    expect(launcher.launchedUrls, [Uri.parse('https://b.example')]);
  });
}
