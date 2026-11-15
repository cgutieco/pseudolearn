import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/syntax_help_source.dart';

final class FakeSyntaxHelpSource implements SyntaxHelpSource {
  final List<int> requestedCursors = [];
  HelpQueryResult? Function(int revision)? answer;

  FakeSyntaxHelpSource({this.answer});

  @override
  HelpQueryResult query({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required int cursorUtf16,
    required int revision,
  }) {
    requestedCursors.add(cursorUtf16);
    return answer?.call(revision) ?? HelpQueryResult.noHelp(revision: revision);
  }
}
