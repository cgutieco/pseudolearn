import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../syntax/ast/operators.dart';
import 'class_hierarchy_provider.dart';
import 'semantic_type.dart';
import 'type_relations.dart';

final class OperatorEvaluationResult {
  final SemanticType resultType;
  final DiagnosticCode? diagnosticCode;
  final DiagnosticCode? warningCode;

  const OperatorEvaluationResult(
    this.resultType, {
    this.diagnosticCode,
    this.warningCode,
  });

  const OperatorEvaluationResult.error(DiagnosticCode this.diagnosticCode)
      : resultType = const ErrorSemanticType(),
        warningCode = null;

  const OperatorEvaluationResult.success(
    this.resultType, {
    this.warningCode,
  }) : diagnosticCode = null;
}

final class OperatorTypeTable {
  const OperatorTypeTable();

  OperatorEvaluationResult computeUnary(
    UnaryOperator op,
    SemanticType operand,
  ) {
    if (operand.isError) {
      return const OperatorEvaluationResult.success(ErrorSemanticType());
    }
    if (operand.isIndeterminate) {
      return const OperatorEvaluationResult.success(
          IndeterminateSemanticType());
    }
    return switch (op) {
      UnaryOperator.positive || UnaryOperator.negate => operand.isNumeric
          ? OperatorEvaluationResult.success(operand)
          : const OperatorEvaluationResult.error(
              DiagnosticCode.incompatibleOperandTypes,
            ),
      UnaryOperator.not => operand.isBoolean
          ? const OperatorEvaluationResult.success(
              PrimitiveSemanticType(PrimitiveType.boolean),
            )
          : const OperatorEvaluationResult.error(
              DiagnosticCode.incompatibleOperandTypes,
            ),
    };
  }

  OperatorEvaluationResult computeBinary(
    BinaryOperator op,
    SemanticType left,
    SemanticType right, {
    ClassHierarchyProvider? hierarchy,
  }) {
    if (left.isError || right.isError) {
      return const OperatorEvaluationResult.success(ErrorSemanticType());
    }
    if (left.isIndeterminate || right.isIndeterminate) {
      return const OperatorEvaluationResult.success(
          IndeterminateSemanticType());
    }
    if (left.isArray || right.isArray) {
      return const OperatorEvaluationResult.error(
        DiagnosticCode.arrayCannotBeUsedAsValue,
      );
    }
    return switch (op) {
      BinaryOperator.add => _computeAdd(left, right),
      BinaryOperator.subtract ||
      BinaryOperator.multiply =>
        _computeSubMul(left, right),
      BinaryOperator.divide => _computeDiv(left, right),
      BinaryOperator.integerDivide ||
      BinaryOperator.modulo =>
        _computeIntDivMod(left, right),
      BinaryOperator.power => _computePower(left, right),
      BinaryOperator.equal ||
      BinaryOperator.notEqual =>
        _computeEquality(left, right, hierarchy),
      BinaryOperator.lessThan ||
      BinaryOperator.lessThanOrEqual ||
      BinaryOperator.greaterThan ||
      BinaryOperator.greaterThanOrEqual =>
        _computeRelational(left, right),
      BinaryOperator.and || BinaryOperator.or => _computeLogical(left, right),
    };
  }

  OperatorEvaluationResult _computeAdd(SemanticType left, SemanticType right) {
    if (left.isNumeric && right.isNumeric) {
      return OperatorEvaluationResult.success(
        left.isReal || right.isReal
            ? const PrimitiveSemanticType(PrimitiveType.real)
            : const PrimitiveSemanticType(PrimitiveType.integer),
      );
    }
    if ((left.isNumeric && (right.isString || right.isCharacter)) ||
        ((left.isString || left.isCharacter) && right.isNumeric)) {
      return const OperatorEvaluationResult.error(
        DiagnosticCode.cannotConcatenateNumberWithText,
      );
    }
    if (left.isString && (right.isString || right.isCharacter) ||
        right.isString && (left.isString || left.isCharacter) ||
        (left.isCharacter && right.isCharacter)) {
      return const OperatorEvaluationResult.success(
        PrimitiveSemanticType(PrimitiveType.string),
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }

  OperatorEvaluationResult _computeSubMul(
      SemanticType left, SemanticType right) {
    if (left.isNumeric && right.isNumeric) {
      return OperatorEvaluationResult.success(
        left.isReal || right.isReal
            ? const PrimitiveSemanticType(PrimitiveType.real)
            : const PrimitiveSemanticType(PrimitiveType.integer),
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }

  OperatorEvaluationResult _computeDiv(SemanticType left, SemanticType right) {
    if (left.isNumeric && right.isNumeric) {
      return const OperatorEvaluationResult.success(
        PrimitiveSemanticType(PrimitiveType.real),
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }

  OperatorEvaluationResult _computeIntDivMod(
    SemanticType left,
    SemanticType right,
  ) {
    if (left.isInteger && right.isInteger) {
      return const OperatorEvaluationResult.success(
        PrimitiveSemanticType(PrimitiveType.integer),
      );
    }
    if (left.isReal || right.isReal) {
      return const OperatorEvaluationResult.error(
        DiagnosticCode.divOrModWithRealOperand,
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }

  OperatorEvaluationResult _computePower(
      SemanticType left, SemanticType right) {
    if (left.isNumeric && right.isNumeric) {
      return OperatorEvaluationResult.success(
        left.isReal || right.isReal
            ? const PrimitiveSemanticType(PrimitiveType.real)
            : const PrimitiveSemanticType(PrimitiveType.integer),
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }

  OperatorEvaluationResult _computeEquality(
    SemanticType left,
    SemanticType right,
    ClassHierarchyProvider? hierarchy,
  ) {
    if (left.isReal && right.isReal) {
      return const OperatorEvaluationResult.success(
        PrimitiveSemanticType(PrimitiveType.boolean),
        warningCode: DiagnosticCode.realEqualityComparison,
      );
    }
    if (TypeRelations.areComparable(left, right, hierarchy: hierarchy)) {
      return const OperatorEvaluationResult.success(
        PrimitiveSemanticType(PrimitiveType.boolean),
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }

  OperatorEvaluationResult _computeRelational(
    SemanticType left,
    SemanticType right,
  ) {
    if (left.isBoolean && right.isBoolean) {
      return const OperatorEvaluationResult.error(
        DiagnosticCode.noOrderBetweenBooleans,
      );
    }
    if ((left.isNumeric && right.isNumeric) ||
        (left.isCharacter && right.isCharacter) ||
        (left.isString && right.isString)) {
      return const OperatorEvaluationResult.success(
        PrimitiveSemanticType(PrimitiveType.boolean),
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }

  OperatorEvaluationResult _computeLogical(
    SemanticType left,
    SemanticType right,
  ) {
    if (left.isBoolean && right.isBoolean) {
      return const OperatorEvaluationResult.success(
        PrimitiveSemanticType(PrimitiveType.boolean),
      );
    }
    return const OperatorEvaluationResult.error(
      DiagnosticCode.incompatibleOperandTypes,
    );
  }
}
