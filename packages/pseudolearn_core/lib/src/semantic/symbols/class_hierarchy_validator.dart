import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../../syntax/ast/classes/super_constructor_call.dart';
import 'class_member_validator.dart';
import 'scope.dart';
import 'symbol.dart';

final class ClassHierarchyValidator {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;
  late final ClassMemberValidator _memberValidator;

  ClassHierarchyValidator({
    required this.profile,
    required this.diagnostics,
  }) {
    _memberValidator = ClassMemberValidator(
      profile: profile,
      diagnostics: diagnostics,
    );
  }

  void validate({
    required Map<String, ClassSymbol> classes,
    required SourceUnitScope rootScope,
  }) {
    _resolveInheritanceHierarchy(classes, rootScope);
    for (final classSymbol in classes.values) {
      _memberValidator.collectAndValidateMembers(classSymbol);
    }
    for (final classSymbol in classes.values) {
      _validateConstructors(classSymbol);
    }
  }

  void _resolveInheritanceHierarchy(
    Map<String, ClassSymbol> classes,
    SourceUnitScope rootScope,
  ) {
    for (final classSymbol in classes.values) {
      final superName = classSymbol.superclassName;
      if (superName == null) continue;

      final superSymbol = rootScope.lookup(superName);
      if (superSymbol == null || superSymbol is! ClassSymbol) {
        _report(
          DiagnosticCode.undeclaredSuperclass,
          classSymbol.superclassSpan ?? classSymbol.span,
          {'lexeme': LexemeDiagnosticArgument(superName)},
        );
        continue;
      }

      if (_hasCircularInheritance(classSymbol, superSymbol)) {
        _report(
          DiagnosticCode.circularInheritance,
          classSymbol.span,
          {'lexeme': LexemeDiagnosticArgument(classSymbol.name)},
          relatedSpans: [superSymbol.span],
        );
      } else {
        classSymbol.superclass = superSymbol;
      }
    }
  }

  bool _hasCircularInheritance(ClassSymbol current, ClassSymbol targetSuper) {
    var cursor = targetSuper;
    while (true) {
      if (cursor.name == current.name) return true;
      final next = cursor.superclass;
      if (next == null) break;
      cursor = next;
    }
    return false;
  }

  void _validateConstructors(ClassSymbol classSymbol) {
    final constructor = classSymbol.constructor;
    final superConstructor = classSymbol.superclass?.constructor;
    final superRequiresCall =
        superConstructor != null && superConstructor.parameters.isNotEmpty;

    if (constructor == null) {
      if (superRequiresCall) {
        _report(DiagnosticCode.missingSuperConstructorCall, classSymbol.span,
            const {});
      }
      return;
    }

    final body = constructor.declarationNode?.body ?? const [];
    _validateSuperCallInBody(body, superRequiresCall, constructor.span);
    _validateNoReturnWithValue(body);
  }

  void _validateSuperCallInBody(
    List<StatementNode> body,
    bool superRequiresCall,
    Span constructorSpan,
  ) {
    final firstIsSuperCall =
        body.isNotEmpty && isSuperConstructorCall(body.first);

    if (superRequiresCall && !firstIsSuperCall) {
      _report(DiagnosticCode.missingSuperConstructorCall, constructorSpan,
          const {});
    }

    for (var i = 1; i < body.length; i++) {
      if (isSuperConstructorCall(body[i])) {
        _report(DiagnosticCode.invalidSuperConstructorCallPosition,
            body[i].span, const {});
      }
    }
  }

  void _validateNoReturnWithValue(List<StatementNode> body) {
    for (final stmt in body) {
      if (stmt is ReturnStatementNode && stmt.value != null) {
        _report(
            DiagnosticCode.returnWithValueInConstructor, stmt.span, const {});
      }
    }
  }

  void _report(
    DiagnosticCode code,
    Span span,
    Map<String, DiagnosticArgument> arguments, {
    List<Span>? relatedSpans,
  }) {
    diagnostics.add(
      Diagnostic(
        code: code,
        severity:
            profile.severityPolicy[code] ?? profile.severityPolicy.values.first,
        span: span,
        relatedSpans: relatedSpans ?? const [],
        arguments: arguments,
      ),
    );
  }
}
