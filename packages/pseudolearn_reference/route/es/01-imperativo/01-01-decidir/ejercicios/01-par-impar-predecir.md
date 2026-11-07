---
id: imperativo.decidir.par-impar-predecir
leccion: imperativo.decidir
tipo: predecir
nivel: semilla
obligatorio: true
titulo: ¿Qué camino toma?
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo ParImpar
  Definir x Como Entero <- 7;
  Si x mod 2 = 0 Entonces
    Escribir "par";
  Sino
    Escribir "impar";
  FinSi
FinAlgoritmo
```

```salida
impar
```

::: explicacion
7 repartido de a 2 deja 1: `x mod 2` vale 1, la condición es falsa y el dedo salta a la rama de `Sino`.
:::
