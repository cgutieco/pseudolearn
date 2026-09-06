import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Public API Surface', () {
    late final String packageRoot;
    late final String entrypointPath;

    setUpAll(() {
      packageRoot = Directory.current.path;
      entrypointPath = p.join(packageRoot, 'lib', 'pseudolearn_core.dart');
    });

    test('lib/pseudolearn_core.dart exists and is the only public entrypoint',
        () {
      expect(File(entrypointPath).existsSync(), isTrue);

      final libDir = Directory(p.join(packageRoot, 'lib'));
      final topLevelDartFiles = libDir
          .listSync(recursive: false)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map((f) => p.basename(f.path))
          .toList();

      expect(topLevelDartFiles, equals(['pseudolearn_core.dart']));
    });

    test('public entrypoint exports exactly the authorized exported files', () {
      final content = File(entrypointPath).readAsStringSync();
      final parsed = parseString(content: content, throwIfDiagnostics: true);

      final exportedUris = <String>{};
      for (final directive in parsed.unit.directives) {
        if (directive is ExportDirective) {
          final uri = directive.uri.stringValue;
          if (uri != null) exportedUris.add(uri);
        }
      }

      final expectedExportUris = {
        'src/diagnostics/diagnostic_catalog.dart',
        'src/diagnostics/diagnostic_locale.dart',
        'src/diagnostics/diagnostic_renderer.dart',
        'src/diagnostics/diagnostic_template.dart',
        'src/diagnostics/diagnostic_term_catalog.dart',
        'src/domain/diagnostic.dart',
        'src/domain/diagnostic_argument.dart',
        'src/domain/diagnostic_code.dart',
        'src/domain/node_id.dart',
        'src/domain/position.dart',
        'src/domain/primitive_type.dart',
        'src/domain/pseudo_integer.dart',
        'src/domain/profile/accent_policy.dart',
        'src/domain/profile/builtin_function.dart',
        'src/domain/profile/builtin_function_entry.dart',
        'src/domain/profile/builtin_parameter_kind.dart',
        'src/domain/profile/builtin_signature.dart',
        'src/domain/profile/case_policy.dart',
        'src/domain/profile/identifier_alphabet.dart',
        'src/domain/profile/language_profile.dart',
        'src/domain/profile/lexeme_entry.dart',
        'src/domain/profile/lexer_profile.dart',
        'src/domain/profile/parser_profile.dart',
        'src/domain/profile/profile_normalizer.dart',
        'src/domain/profile/profiles/classic_spanish_profile.dart',
        'src/domain/profile/profiles/english_profile.dart',
        'src/domain/profile/semantic_profile.dart',
        'src/domain/profile/syntax_lexicon.dart',
        'src/domain/profile/unsupported_construct.dart',
        'src/domain/severity.dart',
        'src/domain/span.dart',
        'src/domain/token.dart',
        'src/domain/token_type.dart',
        'src/domain/visibility.dart',
        'src/syntax/ast/ast_node.dart',
        'src/syntax/ast/classes/super_constructor_call.dart',
        'src/syntax/ast/operators.dart',
        'src/syntax/ast/structural_traversal.dart',
        'src/syntax/lexer/lexer.dart',
        'src/syntax/lexer/lexer_result.dart',
        'src/syntax/parser/expression_parse_result.dart',
        'src/syntax/parser/expression_parser.dart',
        'src/syntax/parser/operator_precedence.dart',
        'src/syntax/parser/parse_result.dart',
        'src/syntax/parser/parser.dart',
        'src/syntax/parser/token_stream.dart',
        'src/semantic/symbols/name_resolver.dart',
        'src/semantic/symbols/resolution_result.dart',
        'src/semantic/symbols/scope.dart',
        'src/semantic/symbols/symbol.dart',
        'src/semantic/symbols/symbol_kind.dart',
        'src/semantic/types/class_hierarchy_provider.dart',
        'src/semantic/types/operator_type_table.dart',
        'src/semantic/types/scope_class_hierarchy_provider.dart',
        'src/semantic/types/semantic_type.dart',
        'src/semantic/types/type_check_result.dart',
        'src/semantic/types/type_checker.dart',
        'src/semantic/types/type_environment.dart',
        'src/semantic/types/type_relations.dart',
        'src/evaluation/environment/object_instance.dart',
        'src/evaluation/environment/variable_cell.dart',
        'src/evaluation/events/composite_execution_observer.dart',
        'src/evaluation/events/environment_snapshot.dart',
        'src/evaluation/events/execution_event.dart',
        'src/evaluation/events/execution_event_stream_adapter.dart',
        'src/evaluation/events/execution_observer.dart',
        'src/evaluation/events/recording_execution_observer.dart',
        'src/evaluation/interpreter/analyzed_program.dart',
        'src/evaluation/interpreter/execution_result.dart',
        'src/evaluation/interpreter/interpreter.dart',
        'src/evaluation/interpreter/program_runner.dart',
        'src/evaluation/interpreter/step_outcome.dart',
        'src/evaluation/values/random_source.dart',
        'src/evaluation/values/runtime_value.dart',
      };

      expect(exportedUris, equals(expectedExportUris));
    });

    test('no internal executor, dispatcher or collector is leaked in exports',
        () {
      final content = File(entrypointPath).readAsStringSync();
      final forbiddenSnippets = [
        'task_dispatcher.dart',
        'arithmetic_task_executor.dart',
        'array_access_task_executor.dart',
        'call_task_executor.dart',
        'oop_task_executor.dart',
        'method_call_task_executor.dart',
        'member_access_task_executor.dart',
        'builtin_invoker.dart',
        'statement_synchronizer.dart',
        'body_declaration_collector.dart',
        'top_level_collector.dart',
        'snapshot_builder.dart',
      ];

      for (final forbidden in forbiddenSnippets) {
        expect(content.contains(forbidden), isFalse,
            reason: 'Export of internal detail $forbidden is strictly forbidden');
      }
    });

    test('publicly exported symbol names match the snapshot of authorized types',
        () {
      final content = File(entrypointPath).readAsStringSync();
      final parsed = parseString(content: content, throwIfDiagnostics: true);

      final exportedSymbols = <String>{};
      for (final directive in parsed.unit.directives) {
        if (directive is ExportDirective) {
          final uri = directive.uri.stringValue;
          if (uri == null) continue;
          final targetFile = p.join(packageRoot, 'lib', uri);
          expect(File(targetFile).existsSync(), isTrue,
              reason: 'Exported file $targetFile must exist');

          _collectExportedDeclarations(targetFile, exportedSymbols);
        }
      }

      final expectedSymbols = {
        'DiagnosticCatalog',
        'DiagnosticLocale',
        'DiagnosticRenderer',
        'DiagnosticTemplate',
        'DiagnosticTermCatalog',
        'DiagnosticTerm',
        'Diagnostic',
        'DiagnosticArgument',
        'TokenDiagnosticArgument',
        'TypeDiagnosticArgument',
        'TermDiagnosticArgument',
        'LexemeDiagnosticArgument',
        'NumberDiagnosticArgument',
        'DiagnosticCode',
        'NodeId',
        'Position',
        'PrimitiveType',
        'PseudoInteger',
        'AccentPolicy',
        'BuiltinFunction',
        'BuiltinFunctionEntry',
        'BuiltinParameterKind',
        'BuiltinSignature',
        'CasePolicy',
        'IdentifierAlphabet',
        'LanguageProfile',
        'LexemeEntry',
        'LexerProfile',
        'ParserProfile',
        'ProfileNormalizer',
        'ClassicSpanishProfile',
        'EnglishProfile',
        'SemanticProfile',
        'SyntaxLexicon',
        'UnsupportedConstruct',
        'Severity',
        'Span',
        'Token',
        'TokenType',
        'Visibility',
        'AstNode',
        'BinaryOperator',
        'UnaryOperator',
        'isSuperConstructorCall',
        'getChildNodes',
        'collectNodeIds',
        'findInnermostNodeAt',
        'calculateEnclosingSpan',
        'collectNodesOfType',
        'Lexer',
        'LexerResult',
        'ExpressionParseResult',
        'ExpressionParser',
        'OperatorPrecedence',
        'ParseResult',
        'Parser',
        'TokenStream',
        'NameResolver',
        'ResolutionResult',
        'Scope',
        'Symbol',
        'SymbolKind',
        'ClassHierarchyProvider',
        'OperatorTypeTable',
        'ScopeClassHierarchyProvider',
        'SemanticType',
        'TypeCheckResult',
        'TypeChecker',
        'TypeEnvironment',
        'TypeRelations',
        'ObjectInstance',
        'VariableCell',
        'CompositeExecutionObserver',
        'DecisionBranch',
        'DecisionEvaluatedEvent',
        'EnvironmentSnapshot',
        'ExecutionEvent',
        'ExecutionEventStreamAdapter',
        'ExecutionObserver',
        'RecordingExecutionObserver',
        'AnalyzedProgram',
        'ExecutionStartResult',
        'ExecutionReady',
        'ExecutionNotExecutable',
        'NotExecutableReason',
        'Interpreter',
        'ProgramRunner',
        'InputProvider',
        'StepOutcome',
        'StepAdvanced',
        'StepAwaitingInput',
        'StepFinished',
        'StepHalted',
        'RandomSource',
        'SeededRandomSource',
        'RuntimeValue',
      };

      for (final expected in expectedSymbols) {
        expect(exportedSymbols.contains(expected), isTrue,
            reason: 'Expected public symbol $expected should be exported');
      }
    });

    test('Negative fixture: detection of unauthorized export', () {
      const mockEntrypoint = '''
export 'src/domain/position.dart';
export 'src/evaluation/interpreter/task_dispatcher.dart';
''';
      final parsed = parseString(content: mockEntrypoint);
      final exports = <String>[];
      for (final d in parsed.unit.directives) {
        if (d is ExportDirective && d.uri.stringValue != null) {
          exports.add(d.uri.stringValue!);
        }
      }

      final hasForbidden = exports.any((e) => e.contains('task_dispatcher'));
      expect(hasForbidden, isTrue);
    });
  });
}

void _collectExportedDeclarations(String filePath, Set<String> target) {
  final content = File(filePath).readAsStringSync();
  final parsed = parseString(content: content, throwIfDiagnostics: false);

  for (final declaration in parsed.unit.declarations) {
    final name = switch (declaration) {
      ClassDeclaration(:final namePart) => namePart.typeName.lexeme,
      EnumDeclaration(:final namePart) => namePart.typeName.lexeme,
      MixinDeclaration(:final name) => name.lexeme,
      FunctionTypeAlias(:final name) => name.lexeme,
      GenericTypeAlias(:final name) => name.lexeme,
      FunctionDeclaration(:final name) => name.lexeme,
      TopLevelVariableDeclaration(:final variables) =>
        variables.variables.firstOrNull?.name.lexeme,
      _ => null,
    };

    if (name != null && !name.startsWith('_')) {
      target.add(name);
    }
  }

  for (final directive in parsed.unit.directives) {
    if (directive is ExportDirective) {
      final uri = directive.uri.stringValue;
      if (uri != null) {
        final nested = p.normalize(p.join(p.dirname(filePath), uri));
        if (File(nested).existsSync()) {
          _collectExportedDeclarations(nested, target);
        }
      }
    }
  }
}
