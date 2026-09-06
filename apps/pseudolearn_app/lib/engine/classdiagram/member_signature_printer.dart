import 'package:pseudolearn_core/pseudolearn_core.dart';

import '../diagram/type_lexeme.dart';

final class MemberSignaturePrinter {
  final SyntaxLexicon _lexicon;
  final TypeLexeme _types;

  MemberSignaturePrinter(SyntaxLexicon lexicon)
      : _lexicon = lexicon,
        _types = TypeLexeme(lexicon);

  String attribute({
    required String name,
    PrimitiveType? type,
    String? customTypeName,
    int dimensionCount = 0,
  }) {
    final typeText = _typeText(type, customTypeName, dimensionCount);
    return typeText.isEmpty ? name : '$name: $typeText';
  }

  String method(MethodDeclarationNode declaration) => _signature(
        name: declaration.name,
        parameters: declaration.parameters,
        returnType: declaration.returnType,
        customReturnType: declaration.customReturnType,
      );

  String constructor(ConstructorDeclarationNode declaration) => _signature(
        name: _lexicon.formatTokenType(TokenType.constructor),
        parameters: declaration.parameters,
      );

  String _signature({
    required String name,
    required List<ParameterNode> parameters,
    PrimitiveType? returnType,
    String? customReturnType,
  }) {
    final buffer = StringBuffer()
      ..write(name)
      ..write('(')
      ..write(_parameterList(parameters))
      ..write(')');
    final returnText = _typeText(returnType, customReturnType, 0);
    if (returnText.isNotEmpty) buffer.write(': $returnText');
    return buffer.toString();
  }

  String _parameterList(List<ParameterNode> parameters) {
    final printed = <String>[];
    for (final parameter in parameters) {
      printed.add(attribute(
        name: parameter.name,
        type: parameter.type,
        customTypeName: parameter.customTypeName,
        dimensionCount: parameter.dimensionCount,
      ));
    }
    return printed.join(', ');
  }

  String _typeText(PrimitiveType? type, String? customTypeName, int dimensions) {
    final base = _types.of(type, customTypeName);
    if (base.isEmpty) return base;
    final buffer = StringBuffer(base);
    for (var index = 0; index < dimensions; index++) {
      buffer.write('[]');
    }
    return buffer.toString();
  }
}
