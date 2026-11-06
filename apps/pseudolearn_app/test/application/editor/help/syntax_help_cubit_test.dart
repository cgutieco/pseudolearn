import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/help/syntax_help_cubit.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
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

HighlightSpan _span(int start, int end, HighlightCategory category) =>
    HighlightSpan(
      range: SourceRange(
        startOffset: start,
        endOffset: end,
        startLine: 1,
        startColumn: start + 1,
        endLine: 1,
        endColumn: end + 1,
      ),
      category: category,
    );

final List<HighlightSpan> _spans = [
  _span(0, 7, HighlightCategory.keywordProcedural),
  _span(8, 12, HighlightCategory.identifier),
  _span(13, 17, HighlightCategory.keywordStructured),
  _span(18, 24, HighlightCategory.type),
];

void _rest(SyntaxHelpCubit cubit, int cursor, {int revision = 1, List<HighlightSpan>? spans}) =>
    cubit.caretMoved(
      spans: spans ?? _spans,
      cursorUtf16: cursor,
      revision: revision,
    );

void main() {
  group('SyntaxHelpCubit · resting caret', () {
    SyntaxHelpCubit fresh() {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found));
      cubit.documentChanged(1);
      return cubit;
    }

    test('a caret inside a keyword marks that keyword', () {
      final cubit = fresh();
      _rest(cubit, 3);
      expect(cubit.state.restingKeyword?.startOffset, 0);
      expect(cubit.state.restingKeyword?.endOffset, 7);
    });

    test('both edges of a keyword still count as resting on it', () {
      final cubit = fresh();
      _rest(cubit, 13);
      expect(cubit.state.restingKeyword?.startOffset, 13);
      _rest(cubit, 24);
      expect(cubit.state.restingKeyword?.startOffset, 18);
    });

    test('a type name is explainable like a keyword', () {
      final cubit = fresh();
      _rest(cubit, 20);
      expect(cubit.state.restingKeyword?.startOffset, 18);
    });

    test('an identifier offers nothing to explain', () {
      final cubit = fresh();
      _rest(cubit, 3);
      _rest(cubit, 10);
      expect(cubit.state.restingKeyword, isNull);
    });

    test('a program without spans offers nothing to explain', () {
      final cubit = fresh();
      _rest(cubit, 0, spans: const []);
      expect(cubit.state.restingKeyword, isNull);
    });

    test('any edit retires the resting keyword', () {
      final cubit = fresh();
      _rest(cubit, 3);
      cubit.documentChanged(2);
      expect(cubit.state.restingKeyword, isNull);
    });

    test('a caret report from an older revision is ignored', () {
      final cubit = fresh();
      cubit.documentChanged(3);
      _rest(cubit, 3, revision: 2);
      expect(cubit.state.restingKeyword, isNull);
    });

    test('opening the help retires the resting keyword', () {
      final cubit = fresh();
      _rest(cubit, 3);
      _request(cubit, 1, cursor: 0);
      expect(cubit.state.restingKeyword, isNull);
      expect(cubit.state.visibleResult, isNotNull);
    });

    test('resting again on the same keyword does not emit', () async {
      final cubit = fresh();
      _rest(cubit, 3);
      final emitted = <Object>[];
      final subscription = cubit.stream.listen(emitted.add);
      _rest(cubit, 4);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      expect(emitted, isEmpty);
    });
  });


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
