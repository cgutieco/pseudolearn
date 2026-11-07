---
id: vision.que-es
numero: "1.1"
tipo: concepto
titulo: Qué es PseudoLearn
anclas: [LANG.PROGRAM.STRUCTURE#R1, LANG.PROGRAM.CLASSIC#R1, LANG.PROFILE.MODEL#R1]
terminos: [pseudocódigo, algoritmo, motor]
---

::: frase
PseudoLearn es un lenguaje de pseudocódigo que se ejecuta de verdad: lo que escribes se analiza, se ejecuta y se puede observar paso a paso.
:::

## Cómo funciona {#funciona}

El **pseudocódigo** es una forma de escribir algoritmos con palabras cercanas al idioma de cada día. Muchos libros lo usan para explicar ideas sin depender de un lenguaje concreto. PseudoLearn toma esa tradición y le da reglas exactas, de modo que una máquina puede comprobar cada programa y ejecutarlo.

Un programa de PseudoLearn tiene siempre un **proceso** con nombre: empieza con `Proceso` y termina con `FinProceso`. Dentro van las instrucciones, una debajo de otra.

```programa id=media titulo="La media de dos notas" ejecutar
Proceso Media
  Definir primera Como Real <- 7.5;
  Definir segunda Como Real <- 9;
  Escribir "La media es ", (primera + segunda) / 2;
FinProceso
```

```salida
La media es 8.25
```

```figura id=ecosistema
pie: Un mismo lenguaje y un mismo motor detrás del editor, la línea de órdenes y la web.
```

## Pseudocódigo clásico sin retoques {#clasico}

Si has escrito pseudocódigo en clase, casi todo lo que conoces funciona igual: `Algoritmo`, `Definir`, `Leer`, `Escribir`, `Si`, `Segun`, `Mientras`, `Repetir` y `Para`. PseudoLearn añade tres exigencias que evitan errores difíciles de ver: cada sentencia simple termina en punto y coma, los índices empiezan en cero y ninguna variable tiene un valor inicial inventado.

::: analogia
PseudoLearn es como una receta escrita por alguien muy cuidadoso: dice exactamente qué ingredientes usar y en qué orden. La analogía deja de valer en que una persona interpreta una receta con sentido común, y el motor no: si algo no está escrito con precisión, lo señala.
:::

::: resumen
- PseudoLearn es pseudocódigo con reglas exactas.
- Todo programa tiene un `Proceso` con nombre y su `FinProceso`.
- El mismo motor está detrás del editor, la línea de órdenes y la web.
- El pseudocódigo clásico funciona con punto y coma, índices desde cero y sin valores inventados.
:::

::: vease
- [El viaje de un programa](#vision.viaje)
- [Estructura de un programa](#programas.estructura)
- [Proceso y Algoritmo](#programas.proceso)
:::
