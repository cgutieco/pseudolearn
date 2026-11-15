import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

final class NodoExchange {
  final String question;
  final String reply;

  const NodoExchange({required this.question, required this.reply});
}

const Map<UiLanguageId, NodoExchange> nodoExchanges =
    <UiLanguageId, NodoExchange>{
  UiLanguageId.spanish: NodoExchange(
    question: '¿Cómo lo escribo con una función?',
    reply: 'Puedes separar el enfriamiento en un SubProceso. '
        'Así el bucle se lee casi como una frase:\n\n'
        '```pseudolearn\n'
        'SubProceso Enfriar(t Como Entero) Como Entero\n'
        '    Retornar t - 3;\n'
        'FinSubProceso\n'
        '\n'
        'Proceso Termostato\n'
        '    Definir temperatura Como Entero <- 30;\n'
        '    Mientras temperatura > 24 Hacer\n'
        '        temperatura <- Enfriar(temperatura);\n'
        '    FinMientras\n'
        '    Escribir temperatura;\n'
        'FinProceso\n'
        '```\n\n'
        'Cada vuelta llama a Enfriar y guarda el resultado.',
  ),
  UiLanguageId.english: NodoExchange(
    question: 'How do I write this with a function?',
    reply: 'You can move the cooling into a subroutine. '
        'Then the loop reads almost like a sentence:\n\n'
        '```pseudolearn\n'
        'subroutine Cool(t as integer) as integer\n'
        '    return t - 3;\n'
        'endSubroutine\n'
        '\n'
        'algorithm Thermostat\n'
        '    define temperature as integer <- 30;\n'
        '    while temperature > 24 do\n'
        '        temperature <- Cool(temperature);\n'
        '    endWhile\n'
        '    write temperature;\n'
        'endAlgorithm\n'
        '```\n\n'
        'Each pass calls Cool and keeps the result.',
  ),
};
