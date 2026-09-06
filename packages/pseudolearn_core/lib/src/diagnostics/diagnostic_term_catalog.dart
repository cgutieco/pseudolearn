import '../domain/diagnostic_argument.dart';
import 'diagnostic_locale.dart';

final class DiagnosticTermCatalog {
  static const Map<DiagnosticLocale, Map<DiagnosticTerm, String>> _terms = {
    DiagnosticLocale.es: {
      DiagnosticTerm.variable: 'variable',
      DiagnosticTerm.function: 'función',
      DiagnosticTerm.procedure: 'procedimiento',
      DiagnosticTerm.parameter: 'parámetro',
      DiagnosticTerm.classType: 'clase',
      DiagnosticTerm.attribute: 'atributo',
      DiagnosticTerm.method: 'método',
      DiagnosticTerm.subroutine: 'subprograma',
      DiagnosticTerm.constructor: 'constructor',
      DiagnosticTerm.array: 'arreglo',
    },
    DiagnosticLocale.en: {
      DiagnosticTerm.variable: 'variable',
      DiagnosticTerm.function: 'function',
      DiagnosticTerm.procedure: 'procedure',
      DiagnosticTerm.parameter: 'parameter',
      DiagnosticTerm.classType: 'class',
      DiagnosticTerm.attribute: 'attribute',
      DiagnosticTerm.method: 'method',
      DiagnosticTerm.subroutine: 'subroutine',
      DiagnosticTerm.constructor: 'constructor',
      DiagnosticTerm.array: 'array',
    },
  };

  static String termFor(DiagnosticTerm term, DiagnosticLocale locale) =>
      _terms[locale]?[term] ?? term.name;
}
