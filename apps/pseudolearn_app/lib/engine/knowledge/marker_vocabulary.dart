import '../../domain/model/settings/ui_language_id.dart';

final class MarkerVocabulary {
  final String level;
  final String operators;
  final String associativity;
  final String toTheLeft;
  final String toTheRight;
  final String type;
  final String function;
  final String returns;

  const MarkerVocabulary.spanish()
      : level = 'Nivel',
        operators = 'Operadores',
        associativity = 'Asociatividad',
        toTheLeft = 'izquierda',
        toTheRight = 'derecha',
        type = 'Tipo',
        function = 'Función',
        returns = 'Devuelve';

  const MarkerVocabulary.english()
      : level = 'Level',
        operators = 'Operators',
        associativity = 'Associativity',
        toTheLeft = 'left',
        toTheRight = 'right',
        type = 'Type',
        function = 'Function',
        returns = 'Returns';

  factory MarkerVocabulary.of(UiLanguageId languageId) {
    return switch (languageId) {
      UiLanguageId.english => const MarkerVocabulary.english(),
      UiLanguageId.spanish || UiLanguageId.system => const MarkerVocabulary.spanish(),
    };
  }
}
