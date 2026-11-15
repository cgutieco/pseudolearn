---
id: objetos.cosas.dos-contadores
leccion: objetos.cosas
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Dos contadores
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Clase Contador
  Definir valor Como Entero;

  Metodo Constructor()
    Este.valor <- 0;
  FinMetodo

  Metodo Incrementar()
    Este.valor <- Este.valor + 1;
  FinMetodo

  Metodo Actual() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Dos
  Definir a Como Contador <- Nuevo Contador();
  Definir b Como Contador <- Nuevo Contador();
  a.Incrementar();
  a.Incrementar();
  a.Incrementar();
  b.Incrementar();
  Escribir a.Actual(), " ", b.Actual();
FinAlgoritmo
```

```salida
3 1
```

::: explicacion
`a` y `b` son dos objetos distintos, cada uno con su propio `valor`. Incrementar `a` no toca a `b`.
:::
