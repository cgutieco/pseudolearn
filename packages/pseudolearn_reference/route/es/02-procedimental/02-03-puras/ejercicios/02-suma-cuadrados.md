---
id: procedimental.puras.suma-cuadrados
leccion: procedimental.puras
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Cuadrados encadenados
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Funcion r <- Cuadrado(x Como Entero)
  Definir r Como Entero;
  r <- x * x;
FinFuncion

Algoritmo Principal
  Escribir Cuadrado(2) + Cuadrado(Cuadrado(2));
FinAlgoritmo
```

```salida
20
```

::: explicacion
`Cuadrado(2)` es 4. `Cuadrado(Cuadrado(2))` es `Cuadrado(4)`, que es 16. Suman 20.
:::
