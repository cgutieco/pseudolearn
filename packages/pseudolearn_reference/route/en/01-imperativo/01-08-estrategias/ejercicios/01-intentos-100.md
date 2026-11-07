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
```

::: explicacion
It says 50, 75, 88, 94, 97, 99 and 100: seven attempts. Each «higher» answer leaves half of what was left, and in seven steps a single number remains.
:::
