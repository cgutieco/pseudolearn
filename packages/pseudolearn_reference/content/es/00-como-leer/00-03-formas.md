---
id: lectura.formas
numero: "0.3"
tipo: concepto
titulo: Cómo leer una forma de escritura
anclas: [LANG.SYNTAX.GRAMMAR#R1]
terminos: [forma, diagrama de sintaxis, opcional]
---

::: frase
Una forma de escritura es el molde de una construcción: dice qué palabras van fijas, qué huecos rellenas y qué partes puedes omitir.
:::

## Cómo funciona {#funciona}

Cada construcción del lenguaje se presenta primero con su forma. Las palabras en color se escriben tal cual. Los huecos «así» se sustituyen por código. Lo que va entre ⟦ y ⟧ es opcional: puedes escribirlo o no.

```forma
Mientras «condición» Hacer
  «instrucciones»
FinMientras
```

Debajo de la forma suele aparecer un **diagrama de sintaxis**. Se recorre como una vía de tren: de izquierda a derecha y de arriba abajo. Las píldoras son palabras fijas; las cajas punteadas son huecos; una vía que pasa por debajo de algo indica que puedes saltarlo, y una vía que vuelve hacia atrás indica que puedes repetirlo.

```railes produccion=whileLoop
```

```figura id=leer-raíles
pie: Las tres piezas de un diagrama de sintaxis: tramo fijo, desvío opcional y vuelta para repetir.
```

Este programa rellena la forma de `Mientras` con una condición y una instrucción:

```programa id=cuenta titulo="Rellenar la forma" ejecutar
Algoritmo Cuenta
  Definir n Como Entero <- 1;
  Mientras n <= 3 Hacer
    Escribir n;
    n <- n + 1;
  FinMientras
FinAlgoritmo
```

```salida
1
2
3
```

::: nota
Los diagramas de sintaxis se generan a partir de la gramática oficial del lenguaje. Por eso a veces muestran nombres de huecos más generales que los de la forma, como «expresión» en lugar de «condición».
:::

::: resumen
- Palabras en color: van tal cual.
- Huecos «así»: los rellenas tú.
- ⟦…⟧: parte opcional.
- En los raíles, un desvío por debajo se puede saltar y una vuelta se puede repetir.
:::

::: vease
- [Convenciones tipográficas](#lectura.convenciones)
- [Gramática completa](#apendice.gramatica)
:::
