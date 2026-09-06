part of 'diagnostic_catalog.dart';

final Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _statementTemplates = {
  DiagnosticCode.expectedAlgorithmStart: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el inicio del algoritmo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected algorithm start',
    ),
  },
  DiagnosticCode.expectedAlgorithmName: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el nombre del algoritmo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected algorithm name',
    ),
  },
  DiagnosticCode.unclosedAlgorithm: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Algoritmo sin cerrar al final del archivo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed algorithm at end of file',
    ),
  },
  DiagnosticCode.unexpectedTokenOutsideAlgorithm: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Elemento inesperado fuera del algoritmo: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unexpected token outside algorithm: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.missingStatementTerminator: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba un punto y coma al final de la sentencia',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected a semicolon at the end of the statement',
    ),
  },
  DiagnosticCode.expectedIdentifierInDeclaration: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba al menos una variable para declarar',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected at least one variable to declare',
    ),
  },
  DiagnosticCode.reservedLexemeUsedAsName: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      '«{lexeme}» es una palabra reservada de este perfil, equivalente a '
      '{token}. Elegí otro nombre.',
      requiredArguments: {'lexeme', 'token'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      '"{lexeme}" is a reserved word in this profile, equivalent to {token}. '
      'Choose another name.',
      requiredArguments: {'lexeme', 'token'},
    ),
  },
  DiagnosticCode.expectedTypeConnector: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba la palabra de tipo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected type connector',
    ),
  },
  DiagnosticCode.expectedType: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba un tipo de dato primitivo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected a primitive data type',
    ),
  },
  DiagnosticCode.initializationInDeclarationNotAllowed: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La declaración de variables no admite asignación de valor inicial',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Variable declaration does not support initial value assignment',
    ),
  },
  DiagnosticCode.expectedIdentifierInDimension: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el nombre del arreglo a dimensionar',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected array name to dimension',
    ),
  },
  DiagnosticCode.emptyDimensionList: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El dimensionamiento requiere al menos una dimensión',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Dimension declaration requires at least one dimension',
    ),
  },
  DiagnosticCode.invalidAssignmentTarget: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El destino de la asignación no es una variable o elemento válido',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Assignment target is not a valid variable or array element',
    ),
  },
  DiagnosticCode.expectedAssignmentOperator: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el operador de asignación',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected assignment operator',
    ),
  },
  DiagnosticCode.expectedReadTarget: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La sentencia de lectura requiere al menos una variable',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Read statement requires at least one variable',
    ),
  },
  DiagnosticCode.invalidReadTarget: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El elemento a leer no es una variable o elemento válido',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Read target is not a valid variable or array element',
    ),
  },
  DiagnosticCode.unexpectedModifierPosition: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El modificador sin salto debe colocarse al final de la sentencia',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Without newline modifier must be placed at the end of the statement',
    ),
  },
  DiagnosticCode.duplicateModifier: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Modificador duplicado',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Duplicate modifier',
    ),
  },
};
