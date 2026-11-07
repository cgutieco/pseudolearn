---
id: imperativo.estrategias.intentos-100
leccion: imperativo.estrategias
tipo: predecir
nivel: semilla
obligatorio: true
titulo: El peor caso
---

::: enunciado
Este programa adivina por mitades un número secreto entre 1 y 100. Sin ejecutarlo, escribe exactamente lo que muestra si el secreto es 100.
:::

```programa rol=objeto id=prediccion
Algoritmo Adivinar
  Definir secreto Como Entero;
  Leer secreto;
  Definir bajo Como Entero <- 1;
  Definir alto Como Entero <- 100;
  Definir medio Como Entero;
  Definir intentos Como Entero <- 0;
  Repetir
    medio <- (bajo + alto) div 2;
    intentos <- intentos + 1;
    Si medio < secreto Entonces
      bajo <- medio + 1;
    Sino
      Si medio > secreto Entonces
        alto <- medio - 1;
      FinSi
    FinSi
  Hasta Que medio = secreto
  Escribir "Intentos: ", intentos;
FinAlgoritmo
```

```entrada
100
```

```salida
Intentos: 7
```

::: explicacion
Dice 50, 75, 88, 94, 97, 99 y 100: siete intentos. Cada respuesta «mayor» deja una mitad de lo que quedaba, y en siete pasos queda un solo número.
:::
