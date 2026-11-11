---
id: procedimental.puras.suma-cuadrados
leccion: procedimental.puras
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Chained squares
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Funcion r <- Square(x Como Entero)
  Definir r Como Entero;
  r <- x * x;
FinFuncion

Algoritmo Main
  Escribir Square(2) + Square(Square(2));
FinAlgoritmo
```

```salida
20
```

::: explicacion
`Square(2)` is 4. `Square(Square(2))` is `Square(4)`, which is 16. They add up to 20.
:::
