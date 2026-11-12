---
id: inicio.primer-problema.bus-excursion
leccion: inicio.primer-problema
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: El bus de la excursión
---

::: enunciado
Van 95 alumnos de excursión en buses de 40 asientos. Un compañero escribió este programa y dice que hacen falta 2 buses. ¿Tiene razón? Si no, corrígelo.
:::

```programa rol=inicial
Algoritmo Buses
  Escribir "Buses: ", 95 div 40;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Buses
  Escribir "Buses: ", techo(95 / 40);
FinAlgoritmo
```

```casos
visible | — | Buses: 3
```

::: pistas
1. Haz un ejemplo a mano: ¿cuántos alumnos caben en 2 buses?
2. `div` es otra forma de dividir. Averigua qué hace con lo que sobra en [la Especificación](especificacion:expresiones.division).
3. Compara con la última línea de la fiesta: ahí también sobraban personas.
4. La línea corregida es `Escribir "Buses: ", techo(95 / 40);`, que muestra 3. Cierra con la variante.
:::

::: variante
¿Cuántos alumnos más podrían ir sin pedir un cuarto bus? (Respuesta: 25, porque 3 buses llevan 120.)
:::

::: explicacion
El programa del compañero descarta los 15 alumnos que no llenan un bus. La corrección usa `techo`. Error frecuente: sumar 1 a mano, que funciona con 95 y falla con 80.
:::
