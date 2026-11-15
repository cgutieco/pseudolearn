import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/program_construct_reader.dart';
import 'rust_construct_projection.dart';
import 'rust_program_view_source.dart';
import 'rust_transport.dart';

final class RustProgramConstructReader implements ProgramConstructReader {
  final RustProgramViewSource _views;

  RustProgramConstructReader(RustTransport transport)
    : _views = RustProgramViewSource(transport);

  @override
  Set<AstConstruct> constructsOf({
    required String sourceCode,
    required SyntaxProfileId profileId,
  }) {
    final view = _views.load(sourceCode: sourceCode, profileId: profileId);
    if (view == null) return const {};
    final constructs = <AstConstruct>{};
    for (final node in view.nodes) {
      final construct = rustConstructOf(node.syntaxKind);
      if (construct != null) constructs.add(construct);
    }
    return constructs;
  }
}
