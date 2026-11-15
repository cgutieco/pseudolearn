---
id: inicio.nombres.que-tipo
leccion: inicio.nombres
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Cada valor en su caja
---

::: enunciado
Ubica cada valor en el tipo de caja que puede guardarlo.
:::

```categorias
- Número sin decimales
- Número con decimales
- Texto
```

```elementos
- `23` | Número sin decimales
- `0` | Número sin decimales
- `2.5` | Número con decimales
- `8.0` | Número con decimales
- `"Lucía"` | Texto
- `"23"` | Texto
```

::: explicacion
Los números sin punto van en una caja `Entero`; con punto, aunque terminen en `.0`, en una caja `Real`. Todo lo que va entre comillas es una `Cadena`, aunque adentro haya cifras: `"23"` no se puede multiplicar.

La trampa es `"23"`. Si lo pusiste entre los números, predice qué muestra `Escribir "23" + "1";`.
:::
