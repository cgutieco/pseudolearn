---
id: inicio.primer-problema.pintar-aula
leccion: inicio.primer-problema
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Pintar el aula
---

::: enunciado
Las paredes del aula suman 54 metros cuadrados. Hay que darles dos manos de pintura. Un litro cubre 10 metros cuadrados y la pintura se vende en latas de 4 litros. ¿Cuántas latas hay que comprar? El programa muestra solo el número.
:::

```programa rol=inicial
Algoritmo Pintura
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Pintura
  Escribir techo(54 * 2 / 10 / 4);
FinAlgoritmo
```

```casos
visible | — | 3
```

::: pistas
1. ¿Qué significa «dos manos» para la superficie que hay que cubrir?
2. Planea en pasos, como [las pizzas](ruta:inicio.primer-problema), con una cuenta más en el medio.
3. Superficie total, después litros, después latas. ¿En cuál de esos pasos hace falta redondear hacia arriba?
4. `Escribir techo(54 * 2 / 10 / 4);` muestra 3. Cierra con la variante.
:::

::: variante
¿Cuántos litros de pintura sobran después de pintar? (Respuesta: 1.2.)
:::

::: explicacion
Solución: 108 metros cuadrados, 10.8 litros, 2.7 latas, se compran 3. Error frecuente: redondear los litros antes de dividir entre 4, que también da 3 aquí pero falla con otras medidas.
:::
