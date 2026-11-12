---
id: inicio.preguntar.orden-inverso
leccion: inicio.preguntar
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Al revés
---

::: enunciado
Este programa recibe primero 4 y después 9. Sin ejecutarlo, escribe exactamente lo que muestra.
:::

```programa rol=objeto id=prediccion
Algoritmo AlReves
  Definir a Como Entero;
  Definir b Como Entero;
  Leer a;
  Leer b;
  Escribir b, " ", a;
FinAlgoritmo
```

```entrada
4
9
```

```salida
9 4
```

::: explicacion
El primer valor que llega va a la primera caja que se lee: `a` vale 4 y `b` vale 9. El `Escribir` los muestra en el orden en que están escritos: primero `b`.
:::
