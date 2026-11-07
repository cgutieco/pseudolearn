import '../rust_program_view.dart';
import 'expression_types.dart';

/// Primitive type each `input` target expects. A target that is not a plain
/// variable or an indexed array element of a known type stays unresolved.
final class ReadTargetTypes {
  final RustProgramView _view;
  final ExpressionTypes _types;
  final Set<String> primitives;

  const ReadTargetTypes._(this._view, this._types, this.primitives);

  factory ReadTargetTypes.of(RustProgramView view, ExpressionTypes types) =>
      ReadTargetTypes._(view, types, {
        for (final node in view.nodes)
          if (node.syntaxKind == 'input')
            for (final target in rustChildrenOf(view, node))
              if (_isDesignator(view, target)) ?types.of(target),
      });

  String? of(RustViewNode target) =>
      _isDesignator(_view, target) ? _types.of(target) : null;

  static bool _isDesignator(RustProgramView view, RustViewNode target) {
    if (target.syntaxKind == 'identifier') return true;
    if (target.syntaxKind != 'postfix') return false;
    final parts = rustChildrenOf(view, target);
    return parts.length == 2 &&
        parts.first.syntaxKind == 'identifier' &&
        parts.last.syntaxKind == 'expressions';
  }
}
