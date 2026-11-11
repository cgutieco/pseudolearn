---
id: imperativo.estrategias.seleccion-tabla
leccion: imperativo.estrategias
tipo: rastrear
nivel: arbol
obligatorio: false
titulo: Tracing the selection
---

::: enunciado
Complete the table: what each cell of `v` holds at the end of each pass of the outer walk.
:::

```programa rol=objeto id=traza
Algoritmo Selection
  Dimension v[4] Como Entero;
  v[0] <- 4;
  v[1] <- 3;
  v[2] <- 2;
  v[3] <- 1;
  Para i <- 0 Hasta 2 Hacer
    Definir smallest Como Entero <- i;
    Para j <- i + 1 Hasta 3 Hacer
      Si v[j] < v[smallest] Entonces
        smallest <- j;
      FinSi
    FinPara
    Definir saved Como Entero <- v[i];
    v[i] <- v[smallest];
    v[smallest] <- saved;
  FinPara
  Escribir v[0], v[1], v[2], v[3];
FinAlgoritmo
```

```salida
1234
```

```vueltas marca=17 inicio=7 columnas=v[0],v[1],v[2],v[3]
antes | 4 | 3 | 2 | 1
1 | ?1 | ?3 | ?2 | ?4
2 | ?1 | ?2 | ?3 | ?4
3 | ?1 | ?2 | ?3 | ?4
```

::: explicacion
The first pass brings 1 to the front by swapping it with 4. The second brings 2 to second place. On the third, 3 is already in place and the swap changes nothing.
:::
