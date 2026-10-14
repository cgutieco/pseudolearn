import '../model/workload.dart';

const awfyWorkloads = <Workload>[
  Workload(
    name: 'sieve',
    family: 'arrays',
    expectedOutput: '669',
    operations: 5000,
    source: '''
Proceso Criba
  Dimension marcas[5001] Como Logico
  Definir indice, multiplo, cantidad Como Entero
  Para indice <- 0 Hasta 5000 Hacer
    marcas[indice] <- Verdadero
  FinPara
  cantidad <- 0
  Para indice <- 2 Hasta 5000 Hacer
    Si marcas[indice] Entonces
      cantidad <- cantidad + 1
      multiplo <- indice + indice
      Mientras multiplo <= 5000 Hacer
        marcas[multiplo] <- Falso
        multiplo <- multiplo + indice
      FinMientras
    FinSi
  FinPara
  Escribir cantidad
FinProceso
''',
  ),
  Workload(
    name: 'permute',
    family: 'recursive',
    expectedOutput: '8660',
    operations: 8660,
    source: '''
SubProceso Permutar(valores[] Como Entero Por Referencia, numero Como Entero) Como Entero
  Definir contador, indice, temporal Como Entero
  contador <- 1
  Si numero <> 0 Entonces
    contador <- contador + Permutar(valores, numero - 1)
    Para indice <- numero - 1 Hasta 0 Con Paso -1 Hacer
      temporal <- valores[numero - 1]
      valores[numero - 1] <- valores[indice]
      valores[indice] <- temporal
      contador <- contador + Permutar(valores, numero - 1)
      temporal <- valores[numero - 1]
      valores[numero - 1] <- valores[indice]
      valores[indice] <- temporal
    FinPara
  FinSi
  Retornar contador
FinSubProceso
Proceso Permutaciones
  Dimension valores[6] Como Entero
  Definir indice Como Entero
  Para indice <- 0 Hasta 5 Hacer
    valores[indice] <- 0
  FinPara
  Escribir Permutar(valores, 6)
FinProceso
''',
  ),
];
