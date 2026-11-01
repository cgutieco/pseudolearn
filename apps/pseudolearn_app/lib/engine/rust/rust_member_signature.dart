import 'rust_program_view.dart';

final class RustMemberSignature {
  final RustProgramView _view;

  const RustMemberSignature(this._view);

  String of(String name, RustViewNode? node) {
    if (node == null) return name;
    final parameterGroup = _childOfKind(node, 'parameters');
    final parameters = parameterGroup == null
        ? const <String>[]
        : [
            for (final parameter in rustChildrenOf(_view, parameterGroup))
              if (parameter.syntaxKind == 'parameter') _parameter(parameter),
          ];
    final returnType = rustChildrenForRole(
      _view,
      node,
      'signature',
    ).where((child) => child.syntaxKind == 'type');
    final generics = _childOfKind(node, 'type_parameters')?.text ?? '';
    final signature = '$name$generics(${parameters.join(', ')})';
    if (returnType.isEmpty) return signature;
    return '$signature: ${returnType.first.text}';
  }

  RustViewNode? _childOfKind(RustViewNode node, String syntaxKind) =>
      rustChildrenOf(
        _view,
        node,
      ).where((child) => child.syntaxKind == syntaxKind).firstOrNull;

  String _parameter(RustViewNode parameter) {
    final children = rustChildrenOf(_view, parameter);
    final name = children
        .where((child) => child.syntaxKind == 'identifier')
        .firstOrNull
        ?.text;
    final type = children
        .where((child) => child.syntaxKind == 'type')
        .firstOrNull
        ?.text;
    final dimensions = parameter.dimensions ?? 0;
    if (name == null) return parameter.text.trim();
    if (type == null) return name;
    final typeName = type + List.filled(dimensions, '[]').join();
    return '$name: $typeName';
  }
}
