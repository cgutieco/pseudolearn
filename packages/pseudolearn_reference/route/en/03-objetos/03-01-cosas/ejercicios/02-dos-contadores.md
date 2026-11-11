---
id: objetos.cosas.dos-contadores
leccion: objetos.cosas
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Two counters
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Clase Counter
  Definir count Como Entero;

  Metodo Constructor()
    Este.count <- 0;
  FinMetodo

  Metodo Increment()
    Este.count <- Este.count + 1;
  FinMetodo

  Metodo Current() Como Entero
    Retornar Este.count;
  FinMetodo
FinClase

Algoritmo Two
  Definir a Como Counter <- Nuevo Counter();
  Definir b Como Counter <- Nuevo Counter();
  a.Increment();
  a.Increment();
  a.Increment();
  b.Increment();
  Escribir a.Current(), " ", b.Current();
FinAlgoritmo
```

```salida
3 1
```

::: explicacion
`a` and `b` are two different objects, each with its own `count`. Incrementing `a` does not touch `b`.
:::
