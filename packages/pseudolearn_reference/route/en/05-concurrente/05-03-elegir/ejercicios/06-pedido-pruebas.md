---
id: concurrente.elegir.pedido-pruebas
leccion: concurrente.elegir
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: The tests of the order
---

::: enunciado
Do not write code. Write between two and four cases for the fruit order, with the right answer for each one, so that any wrong version fails at least one.
:::

```programa rol=referencia
SubProceso Suspendible Query(name Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock = 0 Entonces
    Retornar Error(name + " has no stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Order
  Definir north Como Entero;
  Definir south Como Entero;
  Definir west Como Entero;
  Leer north;
  Leer south;
  Leer west;
  Tareas outcome
    Lanzar Query("North", north);
    Lanzar Query("South", south);
    Lanzar Query("West", west);
  FinTareas
  Segun outcome Hacer
    Algo(report): Escribir "Order suspended: ", report.Primero;
    Nada: Escribir "Order confirmed: ", north + south + west;
  FinSegun
FinAlgoritmo
```

```programa rol=mutante id=solo-el-primero
SubProceso Suspendible Query(name Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si name = "North" Y stock = 0 Entonces
    Retornar Error(name + " has no stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Order
  Definir north Como Entero;
  Definir south Como Entero;
  Definir west Como Entero;
  Leer north;
  Leer south;
  Leer west;
  Tareas outcome
    Lanzar Query("North", north);
    Lanzar Query("South", south);
    Lanzar Query("West", west);
  FinTareas
  Segun outcome Hacer
    Algo(report): Escribir "Order suspended: ", report.Primero;
    Nada: Escribir "Order confirmed: ", north + south + west;
  FinSegun
FinAlgoritmo
```

```programa rol=mutante id=menor-que-cero
SubProceso Suspendible Query(name Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock < 0 Entonces
    Retornar Error(name + " has no stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Order
  Definir north Como Entero;
  Definir south Como Entero;
  Definir west Como Entero;
  Leer north;
  Leer south;
  Leer west;
  Tareas outcome
    Lanzar Query("North", north);
    Lanzar Query("South", south);
    Lanzar Query("West", west);
  FinTareas
  Segun outcome Hacer
    Algo(report): Escribir "Order suspended: ", report.Primero;
    Nada: Escribir "Order confirmed: ", north + south + west;
  FinSegun
FinAlgoritmo
```

```programa rol=mutante id=suma-de-dos
SubProceso Suspendible Query(name Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock = 0 Entonces
    Retornar Error(name + " has no stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Order
  Definir north Como Entero;
  Definir south Como Entero;
  Definir west Como Entero;
  Leer north;
  Leer south;
  Leer west;
  Tareas outcome
    Lanzar Query("North", north);
    Lanzar Query("South", south);
    Lanzar Query("West", west);
  FinTareas
  Segun outcome Hacer
    Algo(report): Escribir "Order suspended: ", report.Primero;
    Nada: Escribir "Order confirmed: ", north + south;
  FinSegun
FinAlgoritmo
```

```casos
visible | 5 ; 3 ; 2 | Order confirmed: 10
```

```casos-solucion minimo=2 maximo=4
5 ; 3 ; 2 | Order confirmed: 10
0 ; 3 ; 2 | Order suspended: North has no stock
4 ; 4 ; 0 | Order suspended: West has no stock
```

::: pistas
1. Think of possible errors: checking only one supplier, comparing badly with 0, adding too little.
2. You need a case that is confirmed, to check the sum.
3. You need a supplier without stock that is not the first one.
4. 5, 3, 2; 0, 3, 2; and 4, 4, 0 uncover the three wrong versions. Close with the variant.
:::

::: variante
Which of your cases could you remove without letting any wrong version escape?
:::

::: explicacion
Wrong versions: it only really queries the stock of North, it uses `< 0` instead of `= 0` and it confirms with the sum of the first two. A set without a confirmed case does not detect the third; one where only North fails does not detect the first. The cases have at most one supplier without stock, so the reason does not depend on the turns of the schedule.
:::
