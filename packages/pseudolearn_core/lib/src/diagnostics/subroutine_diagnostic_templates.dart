part of 'diagnostic_catalog.dart';

final Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _subroutineTemplates = {
  DiagnosticCode.expectedSubroutineName: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el nombre del subprograma',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected subroutine name',
    ),
  },
  DiagnosticCode.expectedSubroutineLeftParenthesis: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el paréntesis de apertura en la cabecera del subprograma',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected opening parenthesis in subroutine header',
    ),
  },
  DiagnosticCode.unclosedSubroutine: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Subprograma sin cerrar al final del archivo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed subroutine at end of file',
    ),
  },
  DiagnosticCode.subroutineInsideAlgorithm: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite declarar un subprograma dentro del cuerpo del algoritmo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Declaring a subroutine inside the algorithm body is not allowed',
    ),
  },
  DiagnosticCode.subroutineInsideSubroutine: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite declarar un subprograma dentro de otro subprograma',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Declaring a subroutine inside another subroutine is not allowed',
    ),
  },
  DiagnosticCode.returnOutsideSubroutine: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La instrucción de retorno solo es válida dentro de un subprograma',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Return statement is only valid inside a subroutine',
    ),
  },
  DiagnosticCode.expectedParameterName: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el nombre del parámetro',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected parameter name',
    ),
  },
  DiagnosticCode.duplicatePassingModifier: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se puede especificar Por Valor y Por Referencia en el mismo parámetro',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Cannot specify both By Value and By Reference for the same parameter',
    ),
  },
  DiagnosticCode.passingModifierBeforeParameterName: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El modificador de paso debe colocarse después del tipo del parámetro',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Passing modifier must be placed after parameter type',
    ),
  },
  DiagnosticCode.invalidArrayReturnType: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El tipo de retorno no puede ser un arreglo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Return type cannot be an array',
    ),
  },
  DiagnosticCode.multipleAlgorithms: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite más de un algoritmo por archivo fuente',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Multiple algorithms in a single source file are not allowed',
    ),
  },
  DiagnosticCode.unexpectedTokenOutsideProgramUnit: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Elemento inesperado fuera del algoritmo y de los subprogramas: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unexpected token outside algorithm and subroutines: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
};
