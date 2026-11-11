---
id: exterior.http.predecir-estado
leccion: exterior.http
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Fine or problem?
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Funcion word <- HowItWent(code Como Entero)
  Definir word Como Cadena;
  Si code >= 200 Y code <= 299 Entonces
    word <- "fine";
  Sino
    word <- "problem";
  FinSi
FinFuncion

Algoritmo States
  Escribir HowItWent(204);
  Escribir HowItWent(301);
FinAlgoritmo
```

```salida
fine
problem
```

::: explicacion
204 is between 200 and 299: it went fine, even if the answer brings no body. 301 is outside the range: the function treats it as a problem.
:::
