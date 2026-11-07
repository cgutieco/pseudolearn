---
id: inicio.nombres.cajas
leccion: inicio.nombres
tipo: predecir
nivel: semilla
obligatorio: true
titulo: ¿Qué queda en cada caja?
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo Cajas
  Definir a Como Entero <- 5;
  Definir b Como Entero <- 0;
  b <- a;
  a <- 7;
  Escribir a, " ", b;
FinAlgoritmo
```

```salida
7 5
```

::: explicacion
`b <- a` copia el 5 en `b` en ese momento. Cuando después `a` pasa a 7, `b` no se entera: cada caja guarda su propio valor y no se recalcula sola.
:::

::: docentes
Error frecuente: responder `7 7`, como si `b` quedara atada a `a`. Pide dibujar las dos cajas y tachar el valor viejo en cada asignación.
:::
