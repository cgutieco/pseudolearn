import '../domain/diagnostic_code.dart';
import 'diagnostic_locale.dart';
import 'diagnostic_template.dart';

part 'statement_diagnostic_templates.dart';
part 'control_diagnostic_templates.dart';
part 'subroutine_diagnostic_templates.dart';
part 'class_diagnostic_templates.dart';
part 'oop_expression_diagnostic_templates.dart';
part 'semantic_diagnostic_templates.dart';
part 'type_diagnostic_templates.dart';
part 'runtime_diagnostic_templates.dart';

final class DiagnosticCatalog {
  static final Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
      _templates = <DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>{
    ..._statementTemplates,
    ..._controlTemplates,
    ..._subroutineTemplates,
    ..._classTemplates,
    ..._oopExpressionTemplates,
    ..._semanticTemplates,
    ..._typeTemplates,
    ..._runtimeTemplates,
    DiagnosticCode.unrecognizedCharacter: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Carácter no reconocido: {lexeme}',
        requiredArguments: {'lexeme'},
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Unrecognized character: {lexeme}',
        requiredArguments: {'lexeme'},
      ),
    },
    DiagnosticCode.unterminatedString: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Cadena de texto sin cerrar',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Unterminated string literal',
      ),
    },
    DiagnosticCode.invalidEscapeSequence: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Secuencia de escape no válida: {lexeme}',
        requiredArguments: {'lexeme'},
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Invalid escape sequence: {lexeme}',
        requiredArguments: {'lexeme'},
      ),
    },
    DiagnosticCode.expectedExpression: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Se esperaba una expresión',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Expected an expression',
      ),
    },
    DiagnosticCode.unexpectedTokenInExpression: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Elemento inesperado en la expresión: {lexeme}',
        requiredArguments: {'lexeme'},
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Unexpected token in expression: {lexeme}',
        requiredArguments: {'lexeme'},
      ),
    },
    DiagnosticCode.unclosedParenthesis: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Paréntesis de apertura sin cerrar',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Unclosed opening parenthesis',
      ),
    },
    DiagnosticCode.unexpectedClosingParenthesis: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Paréntesis de cierre inesperado',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Unexpected closing parenthesis',
      ),
    },
    DiagnosticCode.emptyParentheses: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Los paréntesis no pueden estar vacíos',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Parentheses cannot be empty',
      ),
    },
    DiagnosticCode.unclosedBracket: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Corchete de apertura sin cerrar',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Unclosed opening bracket',
      ),
    },
    DiagnosticCode.emptyIndexList: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'El acceso a arreglo requiere al menos un índice',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Array access requires at least one index',
      ),
    },
    DiagnosticCode.trailingComma: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'Coma sobrante',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Trailing comma',
      ),
    },
    DiagnosticCode.chainedArrayAccess: {
      DiagnosticLocale.es: const DiagnosticTemplate(
        'El acceso multidimensional encadenado no está permitido; use corchetes con comas',
      ),
      DiagnosticLocale.en: const DiagnosticTemplate(
        'Chained multidimensional array access is not allowed; use single brackets with commas',
      ),
    },
  };

  static DiagnosticTemplate? templateFor(
    DiagnosticCode code,
    DiagnosticLocale locale,
  ) =>
      _templates[code]?[locale];

  static bool hasTemplateFor(
    DiagnosticCode code,
    DiagnosticLocale locale,
  ) =>
      _templates[code]?.containsKey(locale) ?? false;

  static void register(
    DiagnosticCode code,
    Map<DiagnosticLocale, DiagnosticTemplate> localeTemplates,
  ) {
    _templates[code] = localeTemplates;
  }
}
