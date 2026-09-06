import 'primitive_type.dart';
import 'pseudo_integer.dart';
import 'token_type.dart';

enum DiagnosticTerm {
  variable,
  function,
  procedure,
  parameter,
  classType,
  attribute,
  method,
  subroutine,
  constructor,
  array,
}

sealed class DiagnosticArgument {
  const DiagnosticArgument();
}

final class TokenDiagnosticArgument extends DiagnosticArgument {
  final TokenType tokenType;

  const TokenDiagnosticArgument(this.tokenType);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenDiagnosticArgument &&
          runtimeType == other.runtimeType &&
          tokenType == other.tokenType;

  @override
  int get hashCode => tokenType.hashCode;
}

final class TypeDiagnosticArgument extends DiagnosticArgument {
  final PrimitiveType type;

  const TypeDiagnosticArgument(this.type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeDiagnosticArgument &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

final class TermDiagnosticArgument extends DiagnosticArgument {
  final DiagnosticTerm term;

  const TermDiagnosticArgument(this.term);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermDiagnosticArgument &&
          runtimeType == other.runtimeType &&
          term == other.term;

  @override
  int get hashCode => term.hashCode;
}

final class LexemeDiagnosticArgument extends DiagnosticArgument {
  final String lexeme;

  const LexemeDiagnosticArgument(this.lexeme);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexemeDiagnosticArgument &&
          runtimeType == other.runtimeType &&
          lexeme == other.lexeme;

  @override
  int get hashCode => lexeme.hashCode;
}

final class NumberDiagnosticArgument extends DiagnosticArgument {
  final num value;

  const NumberDiagnosticArgument(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberDiagnosticArgument &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

final class IntegerValueDiagnosticArgument extends DiagnosticArgument {
  final PseudoInteger value;

  const IntegerValueDiagnosticArgument(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntegerValueDiagnosticArgument &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
