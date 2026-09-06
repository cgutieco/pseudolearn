import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'statement_printer.dart';

final class StructurePrinter {
  final StatementPrinter _statementPrinter;
  final SyntaxLexicon _lexicon;

  const StructurePrinter({
    required StatementPrinter statementPrinter,
    required SyntaxLexicon lexicon,
  })  : _statementPrinter = statementPrinter,
        _lexicon = lexicon;

  String printUnit(SourceUnitNode unit) {
    final parts = <String>[];
    if (unit.declarations.isNotEmpty) {
      for (final decl in unit.declarations) {
        parts.add(_printDeclaration(decl));
      }
    } else {
      for (final cls in unit.classes) {
        parts.add(printClass(cls));
      }
      for (final sub in unit.subroutines) {
        parts.add(printSubroutine(sub));
      }
      if (unit.algorithm != null) {
        parts.add(printAlgorithm(unit.algorithm!));
      }
    }
    return parts.where((p) => p.isNotEmpty).join('\n\n');
  }

  String printAlgorithm(AlgorithmNode node) {
    final buf = StringBuffer('${_lexeme(TokenType.algorithm)} ${node.name}\n');
    if (node.body.isNotEmpty) {
      buf.writeln(_statementPrinter.printBlock(node.body, indentLevel: 1));
    }
    buf.write(_lexeme(TokenType.endAlgorithm));
    return buf.toString();
  }

  String printSubroutine(SubroutineDeclarationNode node) {
    final params = node.parameters.map(_printParameter).join(', ');
    final ret = _returnTypeSuffix(node.returnType, node.customReturnType);
    final buf = StringBuffer('${_lexeme(TokenType.subroutine)} ${node.name}($params)$ret\n');
    if (node.body.isNotEmpty) {
      buf.writeln(_statementPrinter.printBlock(node.body, indentLevel: 1));
    }
    buf.write(_lexeme(TokenType.endSubroutine));
    return buf.toString();
  }

  String printClass(ClassNode node) {
    final inh = node.superclassName != null ? ' ${_lexeme(TokenType.inheritsFrom)} ${node.superclassName}' : '';
    final buf = StringBuffer('${_lexeme(TokenType.classKeyword)} ${node.name}$inh\n');
    for (final member in node.members) {
      buf.writeln(_printMember(member));
    }
    buf.write(_lexeme(TokenType.endClass));
    return buf.toString();
  }

  String _printParameter(ParameterNode param) {
    final dim = param.dimensionCount > 0 ? '[${',' * (param.dimensionCount - 1)}]' : '';
    final type = _typeSuffix(param.type, param.customTypeName);
    final ref = param.passingMode == ParameterPassingMode.byReference ? ' ${_lexeme(TokenType.byReference)}' : '';
    return '${param.name}$dim$type$ref';
  }

  String _printMember(ClassMemberNode member) {
    return switch (member) {
      ClassFieldNode() => _printField(member),
      MethodDeclarationNode() => _printMethod(member),
      ConstructorDeclarationNode() => _printConstructor(member),
    };
  }

  String _printDeclaration(AstNode decl) {
    return switch (decl) {
      AlgorithmNode() => printAlgorithm(decl),
      SubroutineDeclarationNode() => printSubroutine(decl),
      ClassNode() => printClass(decl),
      _ => '',
    };
  }

  String _lexeme(TokenType type) => _lexicon.formatTokenType(type);

  String _typeSuffix(PrimitiveType? type, String? custom) {
    if (type == null && custom == null) return '';
    final formatted = type != null ? _formatPrimitiveType(type) : custom!;
    return ' ${_lexeme(TokenType.typeConnector)} $formatted';
  }

  String _returnTypeSuffix(PrimitiveType? type, String? custom) => _typeSuffix(type, custom);

  String _formatPrimitiveType(PrimitiveType type) {
    final token = switch (type) {
      PrimitiveType.integer => TokenType.integerType,
      PrimitiveType.real => TokenType.realType,
      PrimitiveType.boolean => TokenType.booleanType,
      PrimitiveType.character => TokenType.characterType,
      PrimitiveType.string => TokenType.stringType,
    };
    return _lexeme(token);
  }

  String _printField(ClassFieldNode field) {
    final vis = _visibilityPrefix(field.visibility);
    final stmt = _statementPrinter.printStatement(field.declaration, indentLevel: 0);
    return '  $vis$stmt';
  }

  String _printMethod(MethodDeclarationNode method) {
    final vis = _visibilityPrefix(method.visibility);
    final params = method.parameters.map(_printParameter).join(', ');
    final ret = _returnTypeSuffix(method.returnType, method.customReturnType);
    final buf = StringBuffer('  $vis${_lexeme(TokenType.method)} ${method.name}($params)$ret\n');
    if (method.body.isNotEmpty) {
      buf.writeln(_statementPrinter.printBlock(method.body, indentLevel: 2));
    }
    buf.write('  ${_lexeme(TokenType.endMethod)}');
    return buf.toString();
  }

  String _printConstructor(ConstructorDeclarationNode ctor) {
    final params = ctor.parameters.map(_printParameter).join(', ');
    final buf = StringBuffer('  ${_lexeme(TokenType.method)} ${_lexeme(TokenType.constructor)}($params)\n');
    if (ctor.body.isNotEmpty) {
      buf.writeln(_statementPrinter.printBlock(ctor.body, indentLevel: 2));
    }
    buf.write('  ${_lexeme(TokenType.endMethod)}');
    return buf.toString();
  }

  String _visibilityPrefix(Visibility visibility) {
    return switch (visibility) {
      Visibility.private => '${_lexeme(TokenType.privateVisibility)} ',
      Visibility.public => '',
    };
  }
}
