import '../diagnostic_code.dart';
import '../severity.dart';

abstract interface class SemanticProfile {
  bool get mandatoryVariableDeclaration;

  bool get mandatoryInitialization;

  bool get numericSwitchCases;

  bool get constantArrayDimension;

  Map<DiagnosticCode, Severity> get severityPolicy;
}
