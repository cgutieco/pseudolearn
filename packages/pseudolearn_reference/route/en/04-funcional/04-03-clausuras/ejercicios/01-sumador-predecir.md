---
id: funcional.clausuras.sumador-predecir
leccion: funcional.clausuras
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The adder of 10
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Funcion made <- MakeAdder(amount Como Entero)
  Definir made Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + amount;
  FinFuncion;
FinFuncion

Algoritmo Sums
  Definir s Como Funcion(Entero) Como Entero <- MakeAdder(10);
  Escribir s(1);
  Escribir s(s(1));
FinAlgoritmo
```

```salida
11
21
```

::: explicacion
`s` carries the 10 in its backpack. `s(1)` is 11, and `s(s(1))` is `s(11)`, that is 21.
:::
