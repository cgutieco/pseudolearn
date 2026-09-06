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
);
