---
id: objetos.identidad.alias-predecir
leccion: objetos.identidad
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Two names for a counter
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Clase Counter
  Definir valor Como Entero;

  Metodo Constructor()
    Este.valor <- 0;
  FinMetodo

  Metodo Increment()
    Este.valor <- Este.valor + 1;
  FinMetodo

  Metodo Current() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Alias
  Definir a Como Counter <- Nuevo Counter();
  Definir b Como Counter <- a;
  b.Increment();
  Escribir a.Current();
FinAlgoritmo
```

```salida
1
```

::: explicacion
`b <- a` does not create a new counter: `a` and `b` point at the same one. Incrementing through `b` changes the only counter there is.
:::
