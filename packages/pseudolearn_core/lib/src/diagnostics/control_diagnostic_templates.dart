part of 'diagnostic_catalog.dart';

final Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _controlTemplates = {
  DiagnosticCode.expectedThenKeyword: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba la palabra condicional intermedia',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected then keyword',
    ),
  },
  DiagnosticCode.unclosedIfStatement: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Estructura condicional sin cerrar',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed if statement',
    ),
  },
  DiagnosticCode.duplicateElseClause: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La estructura condicional no puede tener más de una rama alternativa',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'If statement cannot have more than one else branch',
    ),
  },
  DiagnosticCode.expectedDoKeyword: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba la palabra intermedia de acción',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected do keyword',
    ),
  },
  DiagnosticCode.expectedBranchSeparator: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el separador de rama',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected branch separator',
    ),
  },
  DiagnosticCode.nonLiteralSwitchCaseLabel: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Las etiquetas del selector múltiple deben ser valores literales',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Switch case labels must be literal values',
    ),
  },
  DiagnosticCode.duplicateSwitchCaseLabel: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Etiqueta duplicada en el selector múltiple: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Duplicate label in switch statement: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.duplicateDefaultCase: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No puede haber más de una rama por defecto',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Cannot have more than one default branch',
    ),
  },
  DiagnosticCode.invalidDefaultCasePosition: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La rama por defecto debe ser la última del selector múltiple',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Default branch must be the last branch in switch statement',
    ),
  },
  DiagnosticCode.unclosedSwitchStatement: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Selector múltiple sin cerrar',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed switch statement',
    ),
  },
  DiagnosticCode.unclosedWhileStatement: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Bucle condicional sin cerrar',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed while loop',
    ),
  },
  DiagnosticCode.unclosedRepeatStatement: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Bucle de repetición sin cerrar',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed repeat loop',
    ),
  },
  DiagnosticCode.expectedForLoopVariable: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba la variable de control del bucle contado',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected control variable for counted loop',
    ),
  },
  DiagnosticCode.expectedToKeyword: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el límite final del bucle contado',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected to keyword for counted loop limit',
    ),
  },
  DiagnosticCode.missingStepClause: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se requiere especificar el paso del bucle contado',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Step clause is required in counted loop',
    ),
  },
  DiagnosticCode.unclosedForStatement: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Bucle contado sin cerrar',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed for loop',
    ),
  },
  DiagnosticCode.mismatchedBlockEnd: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El cierre no corresponde a la estructura abierta: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Closing token does not match open block: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.unexpectedBlockEnd: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Cierre de estructura sin bloque abierto correspondiente: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unexpected block closing without matching open block: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.unexpectedStatement: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Instrucción o elemento no reconocido: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unrecognized statement or token: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.unsupportedStructuredConstruct: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Instrucción fuera del alcance estructurado: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Construct not supported in structured programming: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.maxDiagnosticsExceeded: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se ha alcanzado el límite máximo de diagnósticos sintácticos',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Maximum limit of syntactic diagnostics exceeded',
    ),
  },
};
