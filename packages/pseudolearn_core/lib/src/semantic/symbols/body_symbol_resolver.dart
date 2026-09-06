import '../../domain/diagnostic.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../syntax/ast/ast_node.dart';
import 'body_declaration_collector.dart';
import 'expression_symbol_resolver.dart';
import 'scope.dart';
import 'statement_symbol_resolver.dart';
import 'symbol.dart';

final class BodySymbolResolver {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;
  final Map<NodeId, Symbol> resolvedSymbols;
  final Map<NodeId, ClassSymbol> resolvedClasses;
  final List<Scope> localScopes = [];
  late final ExpressionSymbolResolver expressionResolver;
  late final StatementSymbolResolver _statementResolver;
  late final BodyDeclarationCollector _declarationCollector;

  BodySymbolResolver({
    required this.profile,
    required this.diagnostics,
    required this.resolvedSymbols,
    required this.resolvedClasses,
  }) {
    expressionResolver = ExpressionSymbolResolver(
      profile: profile,
      diagnostics: diagnostics,
      resolvedSymbols: resolvedSymbols,
      resolvedClasses: resolvedClasses,
    );
    _statementResolver = StatementSymbolResolver(
      profile: profile,
      diagnostics: diagnostics,
      resolvedSymbols: resolvedSymbols,
      expressionResolver: expressionResolver,
    );
    _declarationCollector = BodyDeclarationCollector(
      profile: profile,
      diagnostics: diagnostics,
      resolvedSymbols: resolvedSymbols,
    );
  }

  void resolveAll({
    required SourceUnitNode sourceUnit,
    required SourceUnitScope rootScope,
    required Map<String, SubroutineSymbol> subroutines,
    required Map<String, ClassSymbol> classes,
  }) {
    if (sourceUnit.algorithm != null) {
      _resolveAlgorithm(sourceUnit.algorithm!, rootScope);
    }
    for (final subroutine in subroutines.values) {
      _resolveSubroutine(subroutine, rootScope);
    }
    for (final classSymbol in classes.values) {
      _resolveClassMembers(classSymbol, rootScope);
    }
  }

  void _resolveAlgorithm(AlgorithmNode algorithm, SourceUnitScope rootScope) {
    final scope = AlgorithmScope(parent: rootScope);
    localScopes.add(scope);
    _declarationCollector.collectFromStatements(algorithm.body, scope);
    final visibleVars = <String>{};
    for (final stmt in algorithm.body) {
      _statementResolver.resolveStatement(stmt, scope, visibleVars);
    }
  }

  void _resolveSubroutine(
    SubroutineSymbol subroutine,
    SourceUnitScope rootScope,
  ) {
    final scope = SubroutineScope(
      parent: rootScope,
      subroutineSymbol: subroutine,
    );
    localScopes.add(scope);
    final visibleVars = <String>{};
    for (final param in subroutine.parameters) {
      scope.define(param);
      visibleVars.add(param.name);
    }
    _declarationCollector.collectFromStatements(
      subroutine.declarationNode.body,
      scope,
    );
    for (final stmt in subroutine.declarationNode.body) {
      _statementResolver.resolveStatement(stmt, scope, visibleVars);
    }
  }

  void _resolveClassMembers(
      ClassSymbol classSymbol, SourceUnitScope rootScope) {
    final classScope = ClassScope(parent: rootScope, classSymbol: classSymbol);
    for (final member in classSymbol.declarationNode.members) {
      if (member is MethodDeclarationNode) {
        _resolveMethod(member, classScope);
      } else if (member is ConstructorDeclarationNode) {
        _resolveConstructor(member, classScope);
      }
    }
  }

  void _resolveMethod(MethodDeclarationNode node, ClassScope classScope) {
    final methodScope = MethodScope(classScope: classScope);
    localScopes.add(methodScope);
    final visibleVars = <String>{};
    final methodSymbol = classScope.classSymbol.methods[node.name];
    if (methodSymbol != null) {
      for (final param in methodSymbol.parameters) {
        methodScope.define(param);
        visibleVars.add(param.name);
      }
    }
    _declarationCollector.collectFromStatements(node.body, methodScope);
    for (final stmt in node.body) {
      _statementResolver.resolveStatement(stmt, methodScope, visibleVars);
    }
  }

  void _resolveConstructor(
    ConstructorDeclarationNode node,
    ClassScope classScope,
  ) {
    final methodScope =
        MethodScope(classScope: classScope, isConstructor: true);
    localScopes.add(methodScope);
    final visibleVars = <String>{};
    final constructorSymbol = classScope.classSymbol.constructor;
    if (constructorSymbol != null) {
      for (final param in constructorSymbol.parameters) {
        methodScope.define(param);
        visibleVars.add(param.name);
      }
    }
    _declarationCollector.collectFromStatements(node.body, methodScope);
    for (final stmt in node.body) {
      _statementResolver.resolveStatement(stmt, methodScope, visibleVars);
    }
  }
}
