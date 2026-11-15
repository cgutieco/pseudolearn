---
id: imperativo.mientras.misterio-tabla
leccion: imperativo.mientras
tipo: rastrear
nivel: brote
obligatorio: true
titulo: Rastrea el misterio
---

::: enunciado
Completa la tabla por vuelta del programa del número misterioso: el valor de cada caja al terminar cada vuelta.
:::

```programa rol=objeto id=traza
Algoritmo Misterio
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
Al terminar cada vuelta, `total` es la suma de 1 hasta `n`: ese es el invariante. En la vuelta 4 llega a 10 y la condición deja de cumplirse.
:::
