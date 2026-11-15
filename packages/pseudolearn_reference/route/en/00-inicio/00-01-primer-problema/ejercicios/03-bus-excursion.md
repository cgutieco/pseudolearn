---
id: inicio.primer-problema.bus-excursion
leccion: inicio.primer-problema
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The school trip bus
---

::: enunciado
95 pupils are going on a trip in buses with 40 seats. A classmate wrote this program and says 2 buses are needed. Is that right? If not, fix it.
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
1. Do a worked example: how many pupils fit in 2 buses?
2. `div` is another way of dividing. Find out what it does with what is left over in [the Specification](especificacion:expresiones.division).
3. Compare with the last line of the party: there were people left over there too.
4. The fixed line is `Write "Buses: ", ceil(95 / 40);`, which shows 3. Close with the variant.
:::

::: variante
How many more pupils could go without ordering a fourth bus? (Answer: 25, because 3 buses carry 120.)
:::

::: explicacion
The classmate's program drops the 15 pupils who do not fill a bus. The fix uses `ceil`. Frequent mistake: adding 1 by hand, which works with 95 and fails with 80.
:::
