part of 'diagnostic_catalog.dart';

const Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _typeTemplates = {
  DiagnosticCode.incompatibleTypesInAssignment: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Tipo incompatible en la asignación: no se puede asignar {found} a {expected}',
      requiredArguments: {'expected', 'found'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Incompatible types in assignment: cannot assign {found} to {expected}',
      requiredArguments: {'expected', 'found'},
    ),
  },
  DiagnosticCode.incompatibleOperandTypes: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Tipos incompatibles para el operador {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Incompatible types for operator {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.cannotConcatenateNumberWithText: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'No se puede concatenar un número con texto; use la función de conversión o separe las expresiones con coma',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Cannot concatenate number with text; use conversion function or separate expressions with comma',
    ),
  },
  DiagnosticCode.divOrModWithRealOperand: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Los operadores div y mod solo admiten enteros; use truncamiento o redondeo para valores reales',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'The div and mod operators only accept integers; use trunc or round for real values',
    ),
  },
  DiagnosticCode.noOrderBetweenBooleans: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Los operadores relacionales de orden no están permitidos entre valores lógicos',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Relational order operators are not permitted between boolean values',
    ),
  },
  DiagnosticCode.realEqualityComparison: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Comparación de igualdad entre valores reales; los errores de precisión pueden producir resultados inesperados',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Equality comparison between real values; precision errors may yield unexpected results',
    ),
  },
  DiagnosticCode.argumentCountMismatch: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Número incorrecto de argumentos: se esperaban {expected} pero se encontraron {found}',
      requiredArguments: {'expected', 'found'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Incorrect number of arguments: expected {expected} but found {found}',
      requiredArguments: {'expected', 'found'},
    ),
  },
  DiagnosticCode.incompatibleArgumentType: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Tipo de argumento incompatible para el parámetro {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Incompatible argument type for parameter {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.byReferenceArgumentRequiresDesignator: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Un argumento pasado por referencia debe ser una variable o elemento de arreglo',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'An argument passed by reference must be a variable or array element',
    ),
  },
  DiagnosticCode.byReferenceArgumentTypeMismatch: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El tipo del argumento pasado por referencia a {lexeme} debe coincidir exactamente con el parámetro',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'The type of argument passed by reference to {lexeme} must match parameter type exactly',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.incompatibleReturnType: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El tipo de la expresión retornada no coincide con el tipo de retorno declarado',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'The returned expression type does not match the declared return type',
    ),
  },
  DiagnosticCode.returnExpressionInVoidSubroutine: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Un subprograma o método sin tipo de retorno no puede retornar un valor',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'A subroutine or method with no return type cannot return a value',
    ),
  },
  DiagnosticCode.missingReturnExpression: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Se esperaba una expresión en la sentencia de retorno',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Expected an expression in the return statement',
    ),
  },
  DiagnosticCode.subroutineWithoutReturn: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El subprograma {lexeme} declara tipo de retorno pero su cuerpo no contiene ninguna sentencia Retornar',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Subroutine {lexeme} declares a return type but its body contains no return statement',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.callAsExpressionWithoutReturnType: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El subprograma {lexeme} no devuelve ningún valor y no puede usarse dentro de una expresión',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Subroutine {lexeme} does not return a value and cannot be used in an expression',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.discardedReturnValue: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Se descarta el valor devuelto por el subprograma {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Return value from subroutine {lexeme} is discarded',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.nonBooleanCondition: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La condición debe ser una expresión de tipo Lógico',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Condition must be a boolean expression',
    ),
  },
  DiagnosticCode.nonIntegerForBound: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La variable de control y los límites del bucle Para deben ser de tipo Entero',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'For loop control variable and bounds must be of integer type',
    ),
  },
  DiagnosticCode.nonIntegerArrayIndex: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El índice del arreglo debe ser de tipo Entero',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Array index must be of integer type',
    ),
  },
  DiagnosticCode.arrayDimensionCountMismatch: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Número de índices incorrecto para el arreglo {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Incorrect number of indices for array {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.arrayCannotBeUsedAsValue: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Un arreglo no puede usarse como valor escalar en una expresión o asignación',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'An array cannot be used as a scalar value in an expression or assignment',
    ),
  },
  DiagnosticCode.objectCannotBeWritten: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'No se puede escribir un objeto directamente en la salida; acceda a sus atributos',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Cannot write an object directly to output; access its attributes',
    ),
  },
  DiagnosticCode.incompatibleSwitchCaseType: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El tipo de la etiqueta del caso no es compatible con el selector',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Case label type is not compatible with switch selector',
    ),
  },
  DiagnosticCode.inferredVariableType: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Tipo inferido para {lexeme}: {type}',
      requiredArguments: {'lexeme', 'type'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Inferred type for {lexeme}: {type}',
      requiredArguments: {'lexeme', 'type'},
    ),
  },
  DiagnosticCode.widenedVariableType: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Tipo de {lexeme} ampliado de Entero a Real',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Type of {lexeme} widened from Integer to Real',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.typeConflictOnInferredVariable: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Conflicto de tipos para la variable {lexeme}: no se puede reasignar a un tipo incompatible',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Type conflict for variable {lexeme}: cannot reassign to incompatible type',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.variableUsedUninitialized: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La variable {lexeme} se usa sin haber sido inicializada',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Variable {lexeme} is used without being initialized',
      requiredArguments: {'lexeme'},
    ),
  },
};
