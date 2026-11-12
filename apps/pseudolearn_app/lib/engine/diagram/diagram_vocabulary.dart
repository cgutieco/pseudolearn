import '../../domain/model/diagram/diagram_unit.dart';
import '../../domain/model/settings/ui_language_id.dart';

final class DiagramVocabulary {
  final String start;
  final String end;
  final String affirmative;
  final String negative;
  final String questionPrefix;
  final String questionSuffix;
  final String algorithmPrefix;
  final String functionPrefix;
  final String procedurePrefix;
  final String constructorPrefix;
  final String methodPrefix;
  final String emptyCell;
  final ExitVocabulary exits;

  const DiagramVocabulary({
    required this.start,
    required this.end,
    required this.affirmative,
    required this.negative,
    required this.questionPrefix,
    required this.questionSuffix,
    required this.algorithmPrefix,
    required this.functionPrefix,
    required this.procedurePrefix,
    required this.constructorPrefix,
    required this.methodPrefix,
    required this.emptyCell,
    required this.exits,
  });

  static DiagramVocabulary forLanguage(UiLanguageId languageId) {
    return switch (languageId) {
      UiLanguageId.english => _english,
      UiLanguageId.spanish || UiLanguageId.system => _spanish,
    };
  }

  String asQuestion(String condition) =>
      '$questionPrefix$condition$questionSuffix';

  String formatUnitTitle({
    required DiagramUnitKind kind,
    required String name,
    String? className,
    bool isFunction = false,
  }) {
    return switch (kind) {
      DiagramUnitKind.algorithm =>
        name.isEmpty ? algorithmPrefix : '$algorithmPrefix $name',
      DiagramUnitKind.subroutine =>
        '${isFunction ? functionPrefix : procedurePrefix} $name',
      DiagramUnitKind.constructor => '$constructorPrefix ${className ?? name}',
      DiagramUnitKind.method => '$methodPrefix ${className ?? ""}.$name',
    };
  }
}

const DiagramVocabulary _spanish = DiagramVocabulary(
  start: 'Inicio',
  end: 'Fin',
  affirmative: 'SÍ',
  negative: 'NO',
  questionPrefix: '¿',
  questionSuffix: '?',
  algorithmPrefix: 'Algoritmo',
  functionPrefix: 'Función',
  procedurePrefix: 'Subproceso',
  constructorPrefix: 'Constructor',
  methodPrefix: 'Método',
  emptyCell: 'Sin sentencias',
  exits: ExitVocabulary(
    loopEnd: 'Fin del bucle',
    cleanupsAtEnd: 'Limpiezas al terminar',
    cleanups: 'limpiezas',
    line: 'línea',
    lines: 'líneas',
    propagatedFailure: 'Propaga el fallo',
    propagationNote: 'si falla, propaga',
  ),
);

const DiagramVocabulary _english = DiagramVocabulary(
  start: 'Start',
  end: 'End',
  affirmative: 'YES',
  negative: 'NO',
  questionPrefix: '',
  questionSuffix: '?',
  algorithmPrefix: 'Algorithm',
  functionPrefix: 'Function',
  procedurePrefix: 'Subroutine',
  constructorPrefix: 'Constructor',
  methodPrefix: 'Method',
  emptyCell: 'No statements',
  exits: ExitVocabulary(
    loopEnd: 'Loop end',
    cleanupsAtEnd: 'Cleanups at end',
    cleanups: 'cleanups',
    line: 'line',
    lines: 'lines',
    propagatedFailure: 'Propagates failure',
    propagationNote: 'on failure, propagates',
  ),
);

final class ExitVocabulary {
  final String loopEnd;
  final String cleanupsAtEnd;
  final String cleanups;
  final String line;
  final String lines;
  final String propagatedFailure;
  final String propagationNote;

  const ExitVocabulary({
    required this.loopEnd,
    required this.cleanupsAtEnd,
    required this.cleanups,
    required this.line,
    required this.lines,
    required this.propagatedFailure,
    required this.propagationNote,
  });

  String loopExit(int loopLine) => '$loopEnd ($line $loopLine)';

  String cleanupsAtEndOf(List<int> sourceLines) =>
      '$cleanupsAtEnd: ${_lineList(sourceLines)}';

  String withCleanups(String text, List<int> sourceLines) => sourceLines.isEmpty
      ? text
      : '$text — $cleanups: ${_lineList(sourceLines)}';

  String _lineList(List<int> sourceLines) =>
      '${sourceLines.length == 1 ? line : lines} ${sourceLines.join(', ')}';
}
