---
id: inicio.primer-problema.ana-y-beto
leccion: inicio.primer-problema
tipo: comparar
nivel: brote
obligatorio: false
titulo: Dos soluciones que parecen iguales
---

::: enunciado
Ana y Beto resolvieron el problema de las pizzas. Ana escribió `techo(23 * 3 / 8)` y Beto escribió `23 * 3 div 8 + 1`. Con 23 personas, los dos muestran 9. ¿Con cuál de estas cantidades de personas dan resultados distintos?
:::

```opciones
- [ ] 23 personas | Con 23 los dos muestran 9: es justo el caso que ya probaron.
- [x] 16 personas | Son 48 porciones, una división exacta: Ana pide 6 y Beto pide 7, una de más.
- [ ] 30 personas | Son 90 porciones: Ana pide 12 y Beto también, porque sobran porciones.
- [ ] 47 personas | Son 141 porciones: los dos piden 18, porque la división no es exacta.
```

::: explicacion
Beto suma 1 «por si sobra algo». Cuando la división es exacta no sobra nada, y pide una pizza de más. Cualquier cantidad de personas cuyas porciones se dividan exacto entre 8 rompe su solución.
:::

::: docentes
Es el primer contacto con la idea de buscar el caso que rompe una solución, que la lección 0.4 desarrolla. Pide al grupo otra cantidad que también la rompa: 8, 24 o 32.
:::
