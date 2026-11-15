import '../model/knowledge/ast_construct.dart';
import '../model/profiles/syntax_profile_id.dart';

abstract interface class ProgramConstructReader {
  Set<AstConstruct> constructsOf({
    required String sourceCode,
    required SyntaxProfileId profileId,
  });
}
