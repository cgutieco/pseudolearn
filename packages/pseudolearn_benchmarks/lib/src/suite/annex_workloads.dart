import '../model/workload.dart';

const annexWorkloads = <Workload>[
  Workload(
    name: 'sum',
    family: 'numeric',
    expectedOutput: '500500',
    operations: 1000,
    source: '''
Proceso Suma
  Definir indice, total Como Entero
  total <- 0
  Para indice <- 1 Hasta 1000 Hacer
    total <- total + indice
  FinPara
  Escribir total
FinProceso
''',
  ),
  Workload(
    name: 'fibonacci',
    family: 'recursive',
    expectedOutput: '144',
    operations: 465,
    source: '''
SubProceso Fib(numero Como Entero) Como Entero
  Si numero < 2 Entonces
    Retornar numero
  SiNo
    Retornar Fib(numero - 1) + Fib(numero - 2)
  FinSi
FinSubProceso
Proceso Fibo
  Escribir Fib(12)
FinProceso
''',
  ),
  Workload(
    name: 'bubble',
    family: 'arrays',
    expectedOutput: '1 30',
    operations: 435,
    source: '''
Proceso Burbuja
  Dimension valores[30] Como Entero
  Definir indice, cursor, temporal Como Entero
  Para indice <- 0 Hasta 29 Hacer
    valores[indice] <- 30 - indice
  FinPara
  Para indice <- 0 Hasta 28 Hacer
    Para cursor <- 0 Hasta 28 - indice Hacer
      Si valores[cursor] > valores[cursor + 1] Entonces
        temporal <- valores[cursor]
        valores[cursor] <- valores[cursor + 1]
        valores[cursor + 1] <- temporal
      FinSi
    FinPara
  FinPara
  Escribir valores[0], " ", valores[29]
FinProceso
''',
  ),
  Workload(
    name: 'objects',
    family: 'objects',
    expectedOutput: '5050',
    operations: 100,
    source: '''
Clase Contador
  Privado Definir valor Como Entero
  Metodo Constructor()
    Este.valor <- 0
  FinMetodo
  Metodo Sumar(delta Como Entero)
    Este.valor <- Este.valor + delta
  FinMetodo
  Metodo Valor() Como Entero
    Retornar Este.valor
  FinMetodo
FinClase
Proceso Objetos
  Definir contador Como Contador
  Definir indice Como Entero
  contador <- Nuevo Contador()
  Para indice <- 1 Hasta 100 Hacer
    contador.Sumar(indice)
  FinPara
  Escribir contador.Valor()
FinProceso
''',
  ),
];
