---
id: inicio.primer-problema.mesas
leccion: inicio.primer-problema
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Las mesas del comedor
---

::: enunciado
Después de la pizza, las 23 personas de la fiesta se sientan en el comedor. Cada mesa tiene 4 sillas. ¿Cuántas mesas hay que armar para que nadie se quede de pie? El programa muestra solo el número.
:::

```programa rol=inicial
Algoritmo Mesas
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Mesas
  Escribir techo(23 / 4);
FinAlgoritmo
```

```casos
visible | — | 6
```

::: pistas
1. ¿La respuesta puede tener decimales? ¿Qué pasa con la persona que no completa una mesa?
2. Es el mismo problema que el de las pizzas de [la lección](ruta:inicio.primer-problema), con otros números.
3. Te falta una sola instrucción dentro del sobre del programa: mostrar la cuenta redondeada hacia arriba.
4. `Escribir techo(23 / 4);` muestra 6. Cierra el ejercicio con la variante.
:::

::: variante
Las mesas nuevas tienen 6 sillas. ¿Cuántas hacen falta ahora? (Respuesta: 4.)
:::

::: explicacion
Solución: `Escribir techo(23 / 4);`. Error frecuente: responder 5, que deja tres personas de pie, o 5.75. No hay casos ocultos: antes de saber leer datos, el programa tiene un solo caso.
:::
