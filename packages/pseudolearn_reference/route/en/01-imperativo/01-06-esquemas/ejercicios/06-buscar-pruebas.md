---
id: imperativo.esquemas.buscar-pruebas
leccion: imperativo.esquemas
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: Cases for a search
---

::: enunciado
A program reads 5 numbers and then a searched number, and shows the position of the first appearance of the searched number, or -1 if it is not there. Write between 3 and 4 test cases so that any wrong version fails at least one.
:::

```programa rol=referencia
Algoritmo Search
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir searched Como Entero;
  Leer searched;
  Definir position Como Entero <- -1;
  Para i <- 0 Hasta 4 Hacer
    Si v[i] = searched Entonces
      position <- i;
      Salir;
    FinSi
  FinPara
  Escribir position;
FinAlgoritmo
```

```programa rol=mutante id=ultima-aparicion
Algoritmo Search
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir searched Como Entero;
  Leer searched;
  Definir position Como Entero <- -1;
  Para i <- 0 Hasta 4 Hacer
    Si v[i] = searched Entonces
      position <- i;
    FinSi
  FinPara
  Escribir position;
FinAlgoritmo
```

```programa rol=mutante id=desde-uno
Algoritmo Search
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir searched Como Entero;
  Leer searched;
  Definir position Como Entero <- -1;
  Para i <- 1 Hasta 4 Hacer
    Si v[i] = searched Entonces
      position <- i;
      Salir;
    FinSi
  FinPara
  Escribir position;
FinAlgoritmo
```

```programa rol=mutante id=cero-si-falta
Algoritmo Search
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir searched Como Entero;
  Leer searched;
  Definir position Como Entero <- 0;
  Para i <- 0 Hasta 4 Hacer
    Si v[i] = searched Entonces
      position <- i;
      Salir;
    FinSi
  FinPara
  Escribir position;
FinAlgoritmo
```

```casos
visible | 4 ; 8 ; 15 ; 16 ; 23 ; 15 | 2
```

```casos-solucion minimo=3 maximo=4
3 ; 7 ; 9 ; 7 ; 1 ; 7 | 1
7 ; 1 ; 2 ; 3 ; 4 ; 7 | 0
1 ; 2 ; 3 ; 4 ; 5 ; 9 | -1
```

::: pistas
1. Imagine how a search can go wrong: where it starts, when it stops, what it answers if it finds nothing.
2. Each case has to test one of those decisions.
3. You need a repeated searched number, one in the first position and one that is not there.
4. With repeats (3, 7, 9, 7, 1 and 7 → 1), in position 0 (7, 1, 2, 3, 4 and 7 → 0) and absent (→ -1). Close with the variant.
:::

::: variante
Why does the visible case uncover none of the three wrong versions? (15 appears once, it is not in position 0 and it is there.)
:::

::: explicacion
Wrong versions: returns the last appearance, starts searching at position 1 and answers 0 when it finds nothing. Each of the three cases of the solution uncovers one.
:::
