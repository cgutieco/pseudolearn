---
id: inicio.errores.se-detiene
leccion: inicio.errores
tipo: predecir
nivel: semilla
obligatorio: false
titulo: How far does it get?
---

::: enunciado
Without running it, write exactly what this program manages to show.
:::

```programa rol=objeto id=prediccion termina=failed
Algoritmo Stops
  Definir divisor Como Entero <- 0;
  Escribir "Hello";
  Escribir 10 div divisor;
  Escribir "Bye";
FinAlgoritmo
```

```salida
Hello
```

```diagnosticos
divisionByZero
```

::: explicacion
The first instruction shows `Hello`. The second tries to divide by 0 and the program stops there: the third one never runs.
:::
