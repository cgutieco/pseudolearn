import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/domain/severity.dart';
import 'package:test/test.dart';

void main() {
  const classBCodes = <DiagnosticCode>{
    DiagnosticCode.undeclaredVariable,
    DiagnosticCode.variableUsedUninitialized,
    DiagnosticCode.incompatibleSwitchCaseType,
  };

  const classCCodes = <DiagnosticCode>{
    DiagnosticCode.variableDeclaredNeverUsed,
    DiagnosticCode.variableAssignedNeverRead,
    DiagnosticCode.unusedParameter,
    DiagnosticCode.unusedSubroutine,
    DiagnosticCode.realEqualityComparison,
    DiagnosticCode.discardedReturnValue,
  };

  const classDCodes = <DiagnosticCode>{
    DiagnosticCode.inferredVariableType,
    DiagnosticCode.widenedVariableType,
  };

  const classECodes = <DiagnosticCode>{
    DiagnosticCode.readValueTypeMismatch,
  };

  final nonClassACodes = <DiagnosticCode>{
    ...classBCodes,
    ...classCCodes,
    ...classDCodes,
    ...classECodes,
  };

  final classACodes = DiagnosticCode.values
      .where((code) => !nonClassACodes.contains(code))
      .toSet();

  void verifySeverityPolicyInvariants({
    required Map<DiagnosticCode, Severity> strictPolicy,
    required Map<DiagnosticCode, Severity> flexiblePolicy,
  }) {
    for (final code in DiagnosticCode.values) {
      final strictSeverity = strictPolicy[code];
      final flexibleSeverity = flexiblePolicy[code];

      expect(
        strictSeverity,
        isNotNull,
        reason: 'DiagnosticCode.${code.name} must be in strict severity policy',
      );
      expect(
        flexibleSeverity,
        isNotNull,
        reason:
            'DiagnosticCode.${code.name} must be in flexible severity policy',
      );

      if (classACodes.contains(code)) {
        expect(
          strictSeverity,
          equals(Severity.error),
          reason: 'Class A code ${code.name} must be error in strict policy',
        );
        expect(
          flexibleSeverity,
          equals(Severity.error),
          reason: 'Class A code ${code.name} must be error in flexible policy',
        );
      } else if (classBCodes.contains(code)) {
        expect(
          strictSeverity,
          equals(Severity.error),
          reason: 'Class B code ${code.name} must be error in strict policy',
        );
        expect(
          flexibleSeverity,
          equals(Severity.warning),
          reason: 'Class B code ${code.name} must be warning in flexible policy',
        );
      } else if (classCCodes.contains(code)) {
        expect(
          strictSeverity,
          equals(Severity.warning),
          reason: 'Class C code ${code.name} must be warning in strict policy',
        );
        expect(
          flexibleSeverity,
          equals(Severity.warning),
          reason: 'Class C code ${code.name} must be warning in flexible policy',
        );
      } else if (classDCodes.contains(code)) {
        expect(
          strictSeverity,
          equals(Severity.info),
          reason: 'Class D code ${code.name} must be info in strict policy',
        );
        expect(
          flexibleSeverity,
          equals(Severity.info),
          reason: 'Class D code ${code.name} must be info in flexible policy',
        );
      } else if (classECodes.contains(code)) {
        expect(
          strictSeverity,
          equals(Severity.warning),
          reason: 'Class E code ${code.name} must be warning in strict policy',
        );
        expect(
          flexibleSeverity,
          equals(Severity.warning),
          reason: 'Class E code ${code.name} must be warning in flexible policy',
        );
      }

      final isMoreSevereInFlexible = flexibleSeverity == Severity.error &&
          strictSeverity != Severity.error;
      expect(
        isMoreSevereInFlexible,
        isFalse,
        reason:
            'Flexible policy cannot be stricter than strict policy for ${code.name}',
      );
    }
  }

  group('Classification partition completeness', () {
    test('every DiagnosticCode belongs to exactly one normative class', () {
      expect(DiagnosticCode.values.length, equals(159));
      expect(classACodes.length, equals(147));
      expect(classBCodes.length, equals(3));
      expect(classCCodes.length, equals(6));
      expect(classDCodes.length, equals(2));
      expect(classECodes.length, equals(1));

      final totalClassified = classACodes.length +
          classBCodes.length +
          classCCodes.length +
          classDCodes.length +
          classECodes.length;
      expect(totalClassified, equals(DiagnosticCode.values.length));
    });
  });

  group('Severity policy invariants for ClassicSpanishProfile', () {
    test('strict and flexible policies satisfy all mechanical invariants', () {
      const strict = ClassicSpanishProfile.strict();
      const flexible = ClassicSpanishProfile.flexible();

      verifySeverityPolicyInvariants(
        strictPolicy: strict.severityPolicy,
        flexiblePolicy: flexible.severityPolicy,
      );
    });
  });

  group('Severity policy invariants for EnglishProfile', () {
    test('strict and flexible policies satisfy all mechanical invariants', () {
      const strict = EnglishProfile.strict();
      const flexible = EnglishProfile.flexible();

      verifySeverityPolicyInvariants(
        strictPolicy: strict.severityPolicy,
        flexiblePolicy: flexible.severityPolicy,
      );
    });
  });

  group('Mechanical invariant negative test cases with deliberate violations',
      () {
    test('fails when flexible policy is stricter than strict policy', () {
      final invalidStrict = Map<DiagnosticCode, Severity>.from(
        const ClassicSpanishProfile.strict().severityPolicy,
      );
      final invalidFlexible = Map<DiagnosticCode, Severity>.from(
        const ClassicSpanishProfile.flexible().severityPolicy,
      );

      invalidStrict[DiagnosticCode.undeclaredVariable] = Severity.warning;
      invalidFlexible[DiagnosticCode.undeclaredVariable] = Severity.error;

      expect(
        () => verifySeverityPolicyInvariants(
          strictPolicy: invalidStrict,
          flexiblePolicy: invalidFlexible,
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('fails when Class A code is demoted below error', () {
      final invalidStrict = Map<DiagnosticCode, Severity>.from(
        const ClassicSpanishProfile.strict().severityPolicy,
      );
      final invalidFlexible = Map<DiagnosticCode, Severity>.from(
        const ClassicSpanishProfile.flexible().severityPolicy,
      );

      invalidStrict[DiagnosticCode.unrecognizedCharacter] = Severity.warning;

      expect(
        () => verifySeverityPolicyInvariants(
          strictPolicy: invalidStrict,
          flexiblePolicy: invalidFlexible,
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('fails when Class B code is not downgraded in flexible policy', () {
      final invalidStrict = Map<DiagnosticCode, Severity>.from(
        const ClassicSpanishProfile.strict().severityPolicy,
      );
      final invalidFlexible = Map<DiagnosticCode, Severity>.from(
        const ClassicSpanishProfile.flexible().severityPolicy,
      );

      invalidFlexible[DiagnosticCode.undeclaredVariable] = Severity.error;

      expect(
        () => verifySeverityPolicyInvariants(
          strictPolicy: invalidStrict,
          flexiblePolicy: invalidFlexible,
        ),
        throwsA(isA<TestFailure>()),
      );
    });
  });
}
