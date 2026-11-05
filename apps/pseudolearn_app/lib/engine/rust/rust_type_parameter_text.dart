import 'rust_program_view.dart';

final class RustTypeParameterText {
  final RustProgramView _view;

  const RustTypeParameterText(this._view);

  String of(RustViewNode? declaration) {
    if (declaration == null) return '';
    final group = rustChildrenOf(
      _view,
      declaration,
    ).where((child) => child.syntaxKind == 'type_parameters').firstOrNull;
    if (group == null) return '';
    final parameters = [
      for (final parameter in rustChildrenForRole(
        _view,
        group,
        'type_parameter',
      ))
        _parameter(parameter),
    ];
    return '<${parameters.join(', ')}>';
  }

  String argumentsAfter(RustViewNode? declaration, String targetName) {
    if (declaration == null) return '';
    final children = rustChildrenOf(_view, declaration);
    for (var index = 0; index + 1 < children.length; index++) {
      final candidate = children[index];
      final next = children[index + 1];
      if (candidate.syntaxKind == 'identifier' &&
          candidate.text.trim() == targetName &&
          next.syntaxKind == 'type_arguments') {
        return next.text.trim();
      }
    }
    return '';
  }

  String _parameter(RustViewNode parameter) {
    final name = _view.childForRole(parameter, 'name')?.text.trim() ?? '';
    final constraint = _view.childForRole(parameter, 'constraint')?.text.trim();
    return constraint == null ? name : '$name: $constraint';
  }
}
