---
id: inicio.preguntar.orden-inverso
leccion: inicio.preguntar
tipo: predecir
nivel: semilla
obligatorio: false
titulo: The other way round
---

::: enunciado
This program receives 4 first and then 9. Without running it, write exactly what it shows.
:::

```programa rol=objeto id=prediccion
Algoritmo Reversed
  Definir a Como Entero;
  Definir b Como Entero;
  Leer a;
  Leer b;
  Escribir b, " ", a;
FinAlgoritmo
```

```entrada
4
9
```

```salida
9 4
```

::: explicacion
The first value that arrives goes to the first box that is read: `a` is 4 and `b` is 9. The `Write` shows them in the order in which they are written: `b` first.
:::
