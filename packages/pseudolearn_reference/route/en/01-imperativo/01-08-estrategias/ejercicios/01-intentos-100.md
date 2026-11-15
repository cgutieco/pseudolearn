---
id: imperativo.estrategias.intentos-100
leccion: imperativo.estrategias
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The worst case
---

::: enunciado
This program guesses by halves a secret number between 1 and 100. Without running it, write exactly what it shows if the secret is 100.
:::

```programa rol=objeto id=prediccion
Algoritmo Guess
  Definir secret Como Entero;
  Leer secret;
  Definir low Como Entero <- 1;
  Definir high Como Entero <- 100;
  Definir middle Como Entero;
  Definir attempts Como Entero <- 0;
  Repetir
    middle <- (low + high) div 2;
    attempts <- attempts + 1;
    Si middle < secret Entonces
      low <- middle + 1;
    Sino
      Si middle > secret Entonces
        high <- middle - 1;
      FinSi
    FinSi
  Hasta Que middle = secret
  Escribir "Attempts: ", attempts;
FinAlgoritmo
```

```entrada
100
```

```salida
Attempts: 7
```

::: explicacion
It says 50, 75, 88, 94, 97, 99 and 100: seven attempts. Each «higher» answer leaves half of what was left, and in seven steps a single number remains.
:::
