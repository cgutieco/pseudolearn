import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/ports/program_construct_reader.dart';

final class FakeProgramConstructReader implements ProgramConstructReader {
  Map<String, Set<AstConstruct>> constructsBySource;

  FakeProgramConstructReader({this.constructsBySource = const {}});

  @override
  Set<AstConstruct> constructsOf({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    return constructsBySource[sourceCode] ?? const <AstConstruct>{};
  }
}
