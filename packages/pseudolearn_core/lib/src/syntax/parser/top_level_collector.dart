import '../../domain/diagnostic_code.dart';
import '../../domain/profile/unsupported_construct.dart';
import '../ast/ast_node.dart';

final class TopLevelCollector {
  AlgorithmNode? algorithm;
  final List<SubroutineDeclarationNode> subroutines = [];
  final List<ClassNode> classes = [];
  final List<AstNode> declarations = [];
}

DiagnosticCode diagnosticForUnsupportedConstruct(
        UnsupportedConstruct construct) =>
    switch (construct) {
      UnsupportedConstruct.interfaceKeyword =>
        DiagnosticCode.unsupportedInterfaceConstruct,
      UnsupportedConstruct.abstractClass =>
        DiagnosticCode.unsupportedAbstractConstruct,
      UnsupportedConstruct.staticMember =>
        DiagnosticCode.unsupportedStaticConstruct,
      UnsupportedConstruct.protectedVisibility =>
        DiagnosticCode.unsupportedProtectedConstruct,
      UnsupportedConstruct.genericType =>
        DiagnosticCode.unsupportedGenericsConstruct,
      UnsupportedConstruct.exceptionHandling =>
        DiagnosticCode.unsupportedExceptionConstruct,
    };
