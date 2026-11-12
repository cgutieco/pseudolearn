---
id: imperativo.estrategias.ordenar-seis
leccion: imperativo.estrategias
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Sorting six numbers
---

::: enunciado
Read 6 numbers and show them from smallest to largest, one per line.
:::

```programa rol=referencia
Algoritmo Selection
  Dimension v[6] Como Entero;
  Para i <- 0 Hasta 5 Hacer
    Leer v[i];
  FinPara
  Para i <- 0 Hasta 4 Hacer
    Definir smallest Como Entero <- i;
    Para j <- i + 1 Hasta 5 Hacer
      Si v[j] < v[smallest] Entonces
        smallest <- j;
      FinSi
    FinPara
    Definir saved Como Entero <- v[i];
    v[i] <- v[smallest];
    v[smallest] <- saved;
  FinPara
  Para Cada n En v Hacer
    Escribir n;
  FinPara
FinAlgoritmo
```

```casos
visible | 5 ; 3 ; 8 ; 1 ; 9 ; 2 | 1 ⏎ 2 ⏎ 3 ⏎ 5 ⏎ 8 ⏎ 9
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 | 1 ⏎ 2 ⏎ 3 ⏎ 4 ⏎ 5 ⏎ 6
oculto | 6 ; 5 ; 4 ; 3 ; 2 ; 1 | 1 ⏎ 2 ⏎ 3 ⏎ 4 ⏎ 5 ⏎ 6
oculto | 4 ; 4 ; 1 ; 4 ; 1 ; 1 | 1 ⏎ 1 ⏎ 1 ⏎ 4 ⏎ 4 ⏎ 4
oculto | -2 ; 0 ; -5 ; 3 ; 3 ; -1 | -5 ⏎ -2 ⏎ -1 ⏎ 0 ⏎ 3 ⏎ 3
```

::: pistas
1. Sort 5, 3, 8, 1, 9, 2 by hand, picking each time the smallest of those left.
2. It is the selection program of [the lesson](ruta:imperativo.estrategias), with one more number.
3. For each position from the first, find the smallest of what is left and swap it with the one in that position.
4. Two nested loops: the outer one walks the positions from 0 to 4; the inner one finds the smallest from the next one. Close with the variant.
:::

::: variante
Show them from largest to smallest by changing a single sign.
:::

::: explicacion
Hidden cases: reverse order, repeats and negatives. Frequent mistake: swapping inside the inner loop, which sorts but makes many more swaps.
:::
