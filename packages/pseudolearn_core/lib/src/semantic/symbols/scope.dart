import 'symbol.dart';

sealed class Scope {
  final Scope? parent;
  final Map<String, Symbol> _symbols = {};

  Scope({this.parent});

  Map<String, Symbol> get symbols => Map.unmodifiable(_symbols);

  bool define(Symbol symbol) {
    if (_symbols.containsKey(symbol.name)) {
      return false;
    }
    _symbols[symbol.name] = symbol;
    return true;
  }

  Symbol? lookupLocal(String name) => _symbols[name];

  Symbol? lookup(String name) {
    final local = lookupLocal(name);
    if (local != null) return local;
    return parent?.lookup(name);
  }
}

final class SourceUnitScope extends Scope {
  final Map<String, BuiltinFunctionSymbol> _builtins = {};

  SourceUnitScope() : super(parent: null);

  void registerBuiltin(BuiltinFunctionSymbol builtin) {
    _builtins[builtin.name] = builtin;
  }

  @override
  Symbol? lookup(String name) {
    final local = lookupLocal(name);
    if (local != null) return local;
    return _builtins[name];
  }

  BuiltinFunctionSymbol? lookupBuiltin(String name) => _builtins[name];
}

final class AlgorithmScope extends Scope {
  AlgorithmScope({required SourceUnitScope parent}) : super(parent: parent);
}

final class SubroutineScope extends Scope {
  final SubroutineSymbol subroutineSymbol;

  SubroutineScope({
    required SourceUnitScope parent,
    required this.subroutineSymbol,
  }) : super(parent: parent);
}

final class ClassScope extends Scope {
  final ClassSymbol classSymbol;

  ClassScope({
    required SourceUnitScope parent,
    required this.classSymbol,
  }) : super(parent: parent);
}

final class MethodScope extends Scope {
  final ClassScope classScope;
  final bool isConstructor;

  MethodScope({
    required this.classScope,
    this.isConstructor = false,
  }) : super(parent: classScope);

  @override
  Symbol? lookup(String name) {
    final local = lookupLocal(name);
    if (local != null) return local;
    return classScope.parent?.lookup(name);
  }

  FieldSymbol? findEnclosingField(String name) =>
      classScope.classSymbol.findField(name);
}
