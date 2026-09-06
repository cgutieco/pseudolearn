import '../../domain/primitive_type.dart';
import '../../domain/profile/builtin_function.dart';
import '../../domain/profile/builtin_signature.dart';
import '../../domain/span.dart';
import '../../domain/visibility.dart';
import '../../syntax/ast/ast_node.dart';
import 'symbol_kind.dart';

sealed class Symbol {
  String get name;
  Span get span;
  SymbolKind get kind;

  const Symbol();
}

final class VariableSymbol extends Symbol {
  @override
  final String name;

  @override
  final Span span;

  final PrimitiveType? primitiveType;
  final String? customTypeName;
  final int dimensionCount;
  final bool isDeclared;

  bool isAssigned;
  bool isRead;

  @override
  SymbolKind get kind => SymbolKind.variable;

  VariableSymbol({
    required this.name,
    required this.span,
    this.primitiveType,
    this.customTypeName,
    this.dimensionCount = 0,
    this.isDeclared = true,
    this.isAssigned = false,
    this.isRead = false,
  });

  void markAssigned() {
    isAssigned = true;
  }

  void markRead() {
    isRead = true;
  }
}

final class ParameterSymbol extends Symbol {
  @override
  final String name;

  @override
  final Span span;

  final PrimitiveType? primitiveType;
  final String? customTypeName;
  final int dimensionCount;
  final ParameterPassingMode passingMode;

  bool isAssigned;
  bool isRead;

  @override
  SymbolKind get kind => SymbolKind.parameter;

  ParameterSymbol({
    required this.name,
    required this.span,
    this.primitiveType,
    this.customTypeName,
    this.dimensionCount = 0,
    this.passingMode = ParameterPassingMode.byValue,
    this.isAssigned = false,
    this.isRead = false,
  });

  void markAssigned() {
    isAssigned = true;
  }

  void markRead() {
    isRead = true;
  }
}

final class SubroutineSymbol extends Symbol {
  @override
  final String name;

  @override
  final Span span;

  final List<ParameterSymbol> parameters;
  final PrimitiveType? returnType;
  final String? customReturnType;
  final Span? returnTypeSpan;
  final SubroutineDeclarationNode declarationNode;

  bool isCalled;

  @override
  SymbolKind get kind => SymbolKind.subroutine;

  SubroutineSymbol({
    required this.name,
    required this.span,
    required this.parameters,
    this.returnType,
    this.customReturnType,
    this.returnTypeSpan,
    required this.declarationNode,
    this.isCalled = false,
  });

  void markCalled() {
    isCalled = true;
  }
}

final class ClassSymbol extends Symbol {
  @override
  final String name;

  @override
  final Span span;

  final String? superclassName;
  final Span? superclassSpan;
  final ClassNode declarationNode;

  final Map<String, FieldSymbol> fields;
  final Map<String, MethodSymbol> methods;
  ConstructorSymbol? constructor;
  ClassSymbol? superclass;

  bool isInstantiated;

  @override
  SymbolKind get kind => SymbolKind.clazz;

  ClassSymbol({
    required this.name,
    required this.span,
    this.superclassName,
    this.superclassSpan,
    required this.declarationNode,
    Map<String, FieldSymbol>? fields,
    Map<String, MethodSymbol>? methods,
    this.constructor,
    this.superclass,
    this.isInstantiated = false,
  })  : fields = fields ?? {},
        methods = methods ?? {};

  void markInstantiated() {
    isInstantiated = true;
  }

  FieldSymbol? findField(String fieldName) {
    final localField = fields[fieldName];
    if (localField != null) return localField;
    return superclass?.findField(fieldName);
  }

  MethodSymbol? findMethod(String methodName) {
    final localMethod = methods[methodName];
    if (localMethod != null) return localMethod;
    return superclass?.findMethod(methodName);
  }
}

final class FieldSymbol extends Symbol {
  @override
  final String name;

  @override
  final Span span;

  final Visibility visibility;
  final PrimitiveType? primitiveType;
  final String? customTypeName;
  final int dimensionCount;

  bool isAssigned;
  bool isRead;

  @override
  SymbolKind get kind => SymbolKind.field;

  FieldSymbol({
    required this.name,
    required this.span,
    this.visibility = Visibility.public,
    this.primitiveType,
    this.customTypeName,
    this.dimensionCount = 0,
    this.isAssigned = false,
    this.isRead = false,
  });

  void markAssigned() {
    isAssigned = true;
  }

  void markRead() {
    isRead = true;
  }
}

final class MethodSymbol extends Symbol {
  @override
  final String name;

  @override
  final Span span;

  final Visibility visibility;
  final List<ParameterSymbol> parameters;
  final PrimitiveType? returnType;
  final String? customReturnType;
  final Span? returnTypeSpan;
  final MethodDeclarationNode declarationNode;

  @override
  SymbolKind get kind => SymbolKind.method;

  MethodSymbol({
    required this.name,
    required this.span,
    this.visibility = Visibility.public,
    required this.parameters,
    this.returnType,
    this.customReturnType,
    this.returnTypeSpan,
    required this.declarationNode,
  });
}

final class ConstructorSymbol extends Symbol {
  @override
  String get name => 'Constructor';

  @override
  final Span span;

  final List<ParameterSymbol> parameters;
  final ConstructorDeclarationNode? declarationNode;

  @override
  SymbolKind get kind => SymbolKind.constructor;

  ConstructorSymbol({
    required this.span,
    required this.parameters,
    this.declarationNode,
  });
}

final class BuiltinFunctionSymbol extends Symbol {
  @override
  final String name;

  final BuiltinFunction function;
  final BuiltinSignature signature;

  @override
  Span get span => Span.zero;

  @override
  SymbolKind get kind => SymbolKind.builtinFunction;

  const BuiltinFunctionSymbol({
    required this.name,
    required this.function,
    required this.signature,
  });
}
