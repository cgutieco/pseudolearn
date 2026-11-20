const List<String> typedProgramLines = [
  'Algoritmo Promedios',
  'Definir total, contador, valor Como Entero;',
  'Definir promedio Como Real;',
  'total <- 0;',
  'contador <- 0;',
  'Para valor <- 1 Hasta 40 Hacer',
  'Si valor MOD 3 = 0 Entonces',
  'total <- total + valor;',
  'contador <- contador + 1;',
  'Sino',
  'total <- total + 1;',
  'FinSi',
  'FinPara',
  'promedio <- total / contador;',
  'Escribir "Total: ", total;',
  'Escribir "Promedio: ", promedio;',
  'FinAlgoritmo',
];

String outputProgram(int lineCount) =>
    'Algoritmo Salida\n'
    'Definir indice Como Entero;\n'
    'Para indice <- 1 Hasta $lineCount Hacer\n'
    'Escribir "Linea ", indice;\n'
    'FinPara\n'
    'FinAlgoritmo\n';

String branchingProgram(int branchCount) {
  final buffer = StringBuffer()
    ..writeln('Algoritmo Ramas')
    ..writeln('Definir valor Como Entero;')
    ..writeln('valor <- $branchCount;');
  for (var branch = 0; branch < branchCount; branch++) {
    buffer
      ..writeln('Si valor > $branch Entonces')
      ..writeln('valor <- valor - 1;')
      ..writeln('Sino')
      ..writeln('Escribir "Rama $branch";')
      ..writeln('FinSi');
  }
  buffer.writeln('FinAlgoritmo');
  return buffer.toString();
}

String longProgram(int statementCount) {
  final buffer = StringBuffer()
    ..writeln('Algoritmo Largo')
    ..writeln('Definir acumulado Como Entero;')
    ..writeln('acumulado <- 0;');
  for (var statement = 0; statement < statementCount; statement++) {
    buffer.writeln('acumulado <- acumulado + $statement;');
  }
  buffer
    ..writeln('Escribir acumulado;')
    ..writeln('FinAlgoritmo');
  return buffer.toString();
}
