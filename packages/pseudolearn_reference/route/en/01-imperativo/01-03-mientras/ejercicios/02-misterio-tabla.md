---
id: imperativo.mientras.misterio-tabla
leccion: imperativo.mientras
tipo: rastrear
nivel: brote
obligatorio: true
titulo: Trace the mystery
---

::: enunciado
Complete the pass table of the mystery number program: the value of each box at the end of each pass.
:::

```programa rol=objeto id=traza
Algoritmo Mystery
  Definir n Como Entero <- 0;
  Definir total Como Entero <- 0;
  Mientras total < 10 Hacer
    n <- n + 1;
    total <- total + n;
  FinMientras
  Escribir n, " ", total;
FinAlgoritmo
```

```salida
4 10
```

```vueltas marca=7 inicio=4 columnas=n,total
antes | 0 | 0
1 | 1 | ?1
2 | ?2 | ?3
3 | ?3 | ?6
4 | ?4 | ?10
```

::: explicacion
At the end of each pass, `total` is the sum from 1 to `n`: that is the invariant. On pass 4 it reaches 10 and the condition stops holding.
:::
