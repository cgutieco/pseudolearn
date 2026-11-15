import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/help/help_program_highlighter.dart';
import 'package:pseudolearn_app/application/editor/help/syntax_help_cubit.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/help/help_form.dart';
import 'package:pseudolearn_app/domain/model/help/help_part.dart';
import 'package:pseudolearn_app/domain/model/help/help_program.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/help/syntax_help.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../../fakes/fake_program_analyzer.dart';
import '../../../fakes/fake_syntax_help_source.dart';

HelpQueryResult _found(int revision) => HelpQueryResult.help(
  const SyntaxHelp(headline: 'x', range: CaretRange(start: 0, end: 1)),
  revision: revision,
);

HelpProgramHighlighter _highlighter([FakeProgramAnalyzer? analyzer]) =>
    HelpProgramHighlighter(analyzer ?? FakeProgramAnalyzer());

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
      sourceCode: 'x',
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      spans: spans ?? _spans,
      cursorUtf16: cursor,
      revision: revision,
    );

void main() {
  group('SyntaxHelpCubit · resting caret', () {
    SyntaxHelpCubit fresh() {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found), highlighter: _highlighter());
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

    test('an identifier the engine has no help for offers nothing to explain', () {
      final cubit = SyntaxHelpCubit(
        source: FakeSyntaxHelpSource(),
        highlighter: _highlighter(),
      )..documentChanged(1);
      _rest(cubit, 3);
      _rest(cubit, 10);
      expect(cubit.state.restingKeyword, isNull);
    });

    test('an identifier the engine can explain, like a standard function, is explainable', () {
      final cubit = fresh();
      _rest(cubit, 10);
      expect(cubit.state.restingKeyword?.startOffset, 8);
      expect(cubit.state.restingKeyword?.endOffset, 12);
    });

    test('a user symbol is not offered as an explainable word', () {
      final cubit = SyntaxHelpCubit(
        source: FakeSyntaxHelpSource(
          answer: (revision) => HelpQueryResult.symbol(
            const SyntaxHelp(headline: 'x', range: CaretRange(start: 8, end: 12)),
            revision: revision,
          ),
        ),
        highlighter: _highlighter(),
      )..documentChanged(1);
      _rest(cubit, 10);
      expect(cubit.state.restingKeyword, isNull);
    });

    test('a boolean literal is explainable', () {
      final cubit = fresh();
      _rest(
        cubit,
        2,
        spans: [_span(0, 9, HighlightCategory.literalBoolean)],
      );
      expect(cubit.state.restingKeyword?.endOffset, 9);
    });

    test('a boolean literal without engine help offers nothing', () {
      final cubit = SyntaxHelpCubit(
        source: FakeSyntaxHelpSource(),
        highlighter: _highlighter(),
      )..documentChanged(1);
      _rest(
        cubit,
        2,
        spans: [_span(0, 9, HighlightCategory.literalBoolean)],
      );
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
      final cubit = SyntaxHelpCubit(source: source, highlighter: _highlighter());
      cubit.documentChanged(1);
      _request(cubit, 1, cursor: 4);
      expect(cubit.state.visibleResult?.outcome, HelpOutcome.help);
      expect(source.requestedCursors, [4]);
    });

    test('drops visible help when the document moves to a newer revision', () {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found), highlighter: _highlighter());
      cubit.documentChanged(1);
      _request(cubit, 1);
      cubit.documentChanged(2);
      expect(cubit.state.visibleResult, isNull);
      expect(cubit.state.documentRevision, 2);
    });

    test('ignores a request from a revision older than the current one', () {
      final source = FakeSyntaxHelpSource(answer: _found);
      final cubit = SyntaxHelpCubit(source: source, highlighter: _highlighter());
      cubit.documentChanged(2);
      _request(cubit, 1);
      expect(cubit.state.visibleResult, isNull);
      expect(source.requestedCursors, isEmpty);
      _request(cubit, 2);
      expect(cubit.state.visibleResult?.revision, 2);
    });

    test('an older document revision never rewinds the state', () {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found), highlighter: _highlighter());
      cubit.documentChanged(5);
      cubit.documentChanged(3);
      expect(cubit.state.documentRevision, 5);
    });

    test('dismiss clears the result and is idempotent', () {
      final cubit = SyntaxHelpCubit(source: FakeSyntaxHelpSource(answer: _found), highlighter: _highlighter());
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
        highlighter: _highlighter(),
      );
      _request(cubit, 0);
      expect(cubit.state.visibleResult?.outcome, HelpOutcome.failure);
    });

    test('does not touch editor state: the source receives only the query', () {
      final source = FakeSyntaxHelpSource();
      final cubit = SyntaxHelpCubit(source: source, highlighter: _highlighter());
      _request(cubit, 0, cursor: 7);
      expect(source.requestedCursors, [7]);
      expect(cubit.state.visibleResult?.outcome, HelpOutcome.noHelp);
    });

    test('highlights example and mistake programs in the document profile', () {
      final analyzer = FakeProgramAnalyzer();
      final cubit = SyntaxHelpCubit(
        source: FakeSyntaxHelpSource(answer: _withCard),
        highlighter: _highlighter(analyzer),
      );
      _request(cubit, 0);
      final card = cubit.state.visibleResult?.help?.card;
      expect(analyzer.analyzedSources, unorderedEquals(['Escribir 1;', 'Escribir 2;']));
      expect(analyzer.analyzedProfiles.toSet(), {SyntaxProfileId.classicSpanish});
      expect(card?.examples.single.program.highlightSpans, hasLength(1));
      expect(card?.commonErrors.first.program?.highlightSpans, hasLength(1));
      expect(card?.commonErrors.last.program, isNull);
      expect(card?.form, isNotEmpty);
    });

    test('results without a card are not analyzed', () {
      final analyzer = FakeProgramAnalyzer();
      final cubit = SyntaxHelpCubit(
        source: FakeSyntaxHelpSource(answer: _found),
        highlighter: _highlighter(analyzer),
      );
      _request(cubit, 0);
      expect(analyzer.analyzedSources, isEmpty);
      expect(cubit.state.visibleResult?.outcome, HelpOutcome.help);
    });
  });
}

HelpQueryResult _withCard(int revision) => HelpQueryResult.help(
  const SyntaxHelp(
    headline: 'Escribir',
    range: CaretRange(start: 0, end: 8),
    card: HelpCardSections(
      id: 'help.output',
      title: 'Escribir',
      summary: 'Muestra un dato.',
      category: HelpCategory.instruction,
      form: [
        HelpFormLine(
          indent: 0,
          segments: [
            HelpFormSegment(kind: HelpFormSegmentKind.word, text: 'Escribir'),
            HelpFormSegment(kind: HelpFormSegmentKind.slot, text: 'valor'),
            HelpFormSegment(
              kind: HelpFormSegmentKind.symbol,
              text: ';',
              joined: true,
            ),
          ],
        ),
      ],
      commonErrors: [
        HelpCommonError(
          text: 'Olvidar el punto y coma.',
          program: HelpProgram(source: 'Escribir 2;'),
        ),
        HelpCommonError(text: 'Sin código.'),
      ],
      examples: [
        HelpExample(
          kind: HelpExampleKind.executable,
          note: 'Muestra 1.',
          program: HelpProgram(source: 'Escribir 1;', output: '1\n'),
        ),
      ],
    ),
  ),
  revision: revision,
);
