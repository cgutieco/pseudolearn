import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/help/syntax_help_cubit.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/help/syntax_help.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../../fakes/fake_syntax_help_source.dart';

HelpQueryResult _found(int revision) => HelpQueryResult.help(
  const SyntaxHelp(headline: 'x', range: CaretRange(start: 0, end: 1)),
  revision: revision,
);

void _request(SyntaxHelpCubit cubit, int revision, {int cursor = 0}) =>
    cubit.request(
      sourceCode: 'x',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      cursorUtf16: cursor,
      revision: revision,
    );

void main() {
  group('SyntaxHelpCubit', () {
    test('shows the result of the current revision', () {
      final source = FakeSyntaxHelpSource(answer: _found);
      final cubit = SyntaxHelpCubit(source: source);
      cubit.documentChanged(1);
      _request(cubit, 1, cursor: 4);
      expect(cubit.state.visibleResult?.outcome, HelpOutcome.help);
      expect(source.requestedCursors, [4]);
    });

    test('drops visible help when the document moves to a newer revision', () {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found));
      cubit.documentChanged(1);
      _request(cubit, 1);
      cubit.documentChanged(2);
      expect(cubit.state.visibleResult, isNull);
      expect(cubit.state.documentRevision, 2);
    });

    test('ignores a request from a revision older than the current one', () {
      final source = FakeSyntaxHelpSource(answer: _found);
      final cubit = SyntaxHelpCubit(source: source);
      cubit.documentChanged(2);
      _request(cubit, 1);
      expect(cubit.state.visibleResult, isNull);
      expect(source.requestedCursors, isEmpty);
      _request(cubit, 2);
      expect(cubit.state.visibleResult?.revision, 2);
    });

    test('an older document revision never rewinds the state', () {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found));
      cubit.documentChanged(5);
      cubit.documentChanged(3);
      expect(cubit.state.documentRevision, 5);
    });

    test('dismiss clears the result and is idempotent', () {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found));
      _request(cubit, 0);
      cubit.dismiss();
      expect(cubit.state.result, isNull);
      cubit.dismiss();
      expect(cubit.state.result, isNull);
    });

    test('failures stay visible as their own outcome', () {
      final cubit = SyntaxHelpCubit(
        source: FakeSyntaxHelpSource(
          answer: (revision) => HelpQueryResult.failure(revision: revision),
        ),
      );
      _request(cubit, 0);
      expect(cubit.state.visibleResult?.outcome, HelpOutcome.failure);
    });

    test('does not touch editor state: the source receives only the query', () {
      final source = FakeSyntaxHelpSource();
      final cubit = SyntaxHelpCubit(source: source);
      _request(cubit, 0, cursor: 7);
      expect(source.requestedCursors, [7]);
      expect(cubit.state.visibleResult?.outcome, HelpOutcome.noHelp);
    });
  });
}
