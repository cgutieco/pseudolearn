---
id: imperativo.contado.uno-a-diez-resolver
leccion: imperativo.contado
tipo: resolver
nivel: brote
obligatorio: false
titulo: Hasta que esté en rango
---

::: enunciado
Pide un número una y otra vez hasta que esté entre 1 y 10, ambos incluidos, y muestra `Aceptado: ` seguido del número.
:::

```programa rol=referencia
Algoritmo UnoADiez
  Definir n Como Entero;
  Repetir
    Leer n;
  Hasta Que n >= 1 Y n <= 10
  Escribir "Aceptado: ", n;
FinAlgoritmo
```

```casos
visible | 0 ; 15 ; 7 | Aceptado: 7
visible | 3 | Aceptado: 3
oculto | 10 | Aceptado: 10
oculto | 11 ; 1 | Aceptado: 1
oculto | -5 ; 0 ; 11 ; 5 | Aceptado: 5
```

::: pistas
1. ¿Cuántas veces hay que leer como mínimo? ¿Sabes cuántas como máximo?
2. Mira la figura para elegir la forma de repetir en [la lección](ruta:imperativo.contado).
3. La condición para terminar combina dos comparaciones.
4. `Repetir` con `Leer n;` y `Hasta Que n >= 1 Y n <= 10`. Cierra con la variante.
:::

::: variante
Muestra también cuántos intentos hicieron falta. (Con 0, 15 y 7: 3 intentos.)
:::

::: explicacion
Casos ocultos: los bordes 10 y 1 y varios intentos inválidos seguidos. Error frecuente: `O` en lugar de `Y`, que acepta cualquier número.
:::
