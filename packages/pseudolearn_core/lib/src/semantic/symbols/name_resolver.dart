import '../../domain/diagnostic.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/builtin_function.dart';
import '../../domain/profile/builtin_function_entry.dart';
import '../../domain/profile/builtin_signature.dart';
import '../../domain/profile/language_profile.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../syntax/ast/ast_node.dart';
import 'body_symbol_resolver.dart';
import 'class_hierarchy_validator.dart';
import 'resolution_result.dart';
import 'scope.dart';
import 'symbol.dart';
import 'top_level_declaration_collector.dart';
import 'unused_symbol_analyzer.dart';

final class NameResolver {
  final SemanticProfile profile;
  final Map<BuiltinFunction, BuiltinFunctionEntry>? builtinFunctions;

  const NameResolver({
    required this.profile,
    this.builtinFunctions,
  });

  ResolutionResult resolve(SourceUnitNode sourceUnit) {
    final diagnostics = <Diagnostic>[];
    final rootScope = SourceUnitScope();
    final subroutines = <String, SubroutineSymbol>{};
    final classes = <String, ClassSymbol>{};
    final resolvedSymbols = <NodeId, Symbol>{};
    final resolvedClasses = <NodeId, ClassSymbol>{};

    _registerBuiltinFunctions(rootScope);

    _runTopLevelAndHierarchyPasses(
      sourceUnit: sourceUnit,
      rootScope: rootScope,
      subroutines: subroutines,
      classes: classes,
      diagnostics: diagnostics,
    );

    _runBodyAndUsagePasses(
      sourceUnit: sourceUnit,
      rootScope: rootScope,
      subroutines: subroutines,
      classes: classes,
      resolvedSymbols: resolvedSymbols,
      resolvedClasses: resolvedClasses,
      diagnostics: diagnostics,
    );

    return ResolutionResult(
      resolvedSymbols: resolvedSymbols,
      resolvedClasses: resolvedClasses,
      diagnostics: diagnostics,
      rootScope: rootScope,
    );
  }

  void _runTopLevelAndHierarchyPasses({
    required SourceUnitNode sourceUnit,
    required SourceUnitScope rootScope,
    required Map<String, SubroutineSymbol> subroutines,
    required Map<String, ClassSymbol> classes,
    required List<Diagnostic> diagnostics,
  }) {
    final topLevelCollector = TopLevelDeclarationCollector(
      profile: profile,
      diagnostics: diagnostics,
    );
    topLevelCollector.collect(
      sourceUnit: sourceUnit,
      rootScope: rootScope,
      subroutines: subroutines,
      classes: classes,
    );

    final classHierarchyValidator = ClassHierarchyValidator(
      profile: profile,
      diagnostics: diagnostics,
    );
    classHierarchyValidator.validate(
      classes: classes,
      rootScope: rootScope,
    );
  }

  void _runBodyAndUsagePasses({
    required SourceUnitNode sourceUnit,
    required SourceUnitScope rootScope,
    required Map<String, SubroutineSymbol> subroutines,
    required Map<String, ClassSymbol> classes,
    required Map<NodeId, Symbol> resolvedSymbols,
    required Map<NodeId, ClassSymbol> resolvedClasses,
    required List<Diagnostic> diagnostics,
  }) {
    final bodyResolver = BodySymbolResolver(
      profile: profile,
      diagnostics: diagnostics,
      resolvedSymbols: resolvedSymbols,
      resolvedClasses: resolvedClasses,
    );
    bodyResolver.resolveAll(
      sourceUnit: sourceUnit,
      rootScope: rootScope,
      subroutines: subroutines,
      classes: classes,
    );

    final unusedAnalyzer = UnusedSymbolAnalyzer(
      profile: profile,
      diagnostics: diagnostics,
    );
    unusedAnalyzer.analyze(
      rootScope: rootScope,
      subroutines: subroutines,
      classes: classes,
    );

    for (final scope in bodyResolver.localScopes) {
      unusedAnalyzer.analyzeVariablesInScope(scope);
    }
  }

  void _registerBuiltinFunctions(SourceUnitScope rootScope) {
    final functions = builtinFunctions ??
        (profile is LanguageProfile
            ? (profile as LanguageProfile).builtinFunctions
            : null);
    if (functions == null) return;

    for (final entry in functions.entries) {
      final builtin = entry.key;
      final builtinEntry = entry.value;
      final signature = builtinSignatures[builtin]!;
      rootScope.registerBuiltin(
        BuiltinFunctionSymbol(
          name: builtinEntry.canonicalName,
          function: builtin,
          signature: signature,
        ),
      );
      for (final alias in builtinEntry.aliases) {
        rootScope.registerBuiltin(
          BuiltinFunctionSymbol(
            name: alias,
            function: builtin,
            signature: signature,
          ),
        );
      }
    }
  }
}
