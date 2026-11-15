---
id: inicio.primer-problema.ascensor
leccion: inicio.primer-problema
tipo: explicar
nivel: semilla
obligatorio: false
titulo: ¿Qué resuelve este programa?
---

::: enunciado
Elige la frase que mejor explica qué resuelve este programa.
:::

```programa rol=objeto id=misterio
Algoritmo Misterio
  Escribir techo(130 / 50);
FinAlgoritmo
```

```salida
3
```

```opciones
- [ ] Divide 130 entre 50. | Describe cómo lo hace, no qué resuelve.
- [x] Cuántos viajes hace un ascensor que carga 50 kilos para subir 130 kilos de libros. | Habla del problema: cada viaje lleva 50 kilos y el último va con lo que sobra.
- [ ] Cuántas veces cabe 50 en 130. | Es falsa: 50 cabe 2 veces en 130, pero el programa muestra 3.
```

::: explicacion
Una buena explicación habla del problema, no de las operaciones. El redondeo hacia arriba es la pista: el último viaje va aunque no esté lleno.
:::
