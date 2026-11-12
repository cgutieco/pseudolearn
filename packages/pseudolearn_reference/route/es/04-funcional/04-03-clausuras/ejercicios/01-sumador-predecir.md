---
id: funcional.clausuras.sumador-predecir
leccion: funcional.clausuras
tipo: predecir
nivel: semilla
obligatorio: true
titulo: El sumador de 10
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Funcion fabricada <- CrearSumador(cantidad Como Entero)
  Definir fabricada Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + cantidad;
  FinFuncion;
FinFuncion

Algoritmo Sumas
  Definir s Como Funcion(Entero) Como Entero <- CrearSumador(10);
  Escribir s(1);
  Escribir s(s(1));
FinAlgoritmo
```

```salida
11
21
```

::: explicacion
`s` lleva el 10 en su mochila. `s(1)` es 11, y `s(s(1))` es `s(11)`, es decir 21.
:::
