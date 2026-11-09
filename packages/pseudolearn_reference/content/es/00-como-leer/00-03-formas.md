---
id: lectura.formas
numero: "0.3"
tipo: concepto
titulo: Cómo leer una forma de escritura
anclas: [LANG.SYNTAX.GRAMMAR#R1]
terminos: [forma, anatomía, opcional]
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

```figura id=leer-forma
pie: Una forma tiene palabras fijas y huecos. Al rellenar los huecos sale una línea de código; lo que va entre ⟦ y ⟧ puedes omitirlo.
```

Cuando una forma tiene piezas que se repiten u opcionales, la acompaña una **anatomía**: una línea de código real partida en piezas, con el nombre de cada una debajo.

```anatomia
Mientras | palabra que abre el ciclo
n <= 3 | condición: se comprueba antes de cada vuelta
Hacer | palabra que cierra la línea
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
La forma muestra la manera habitual de escribir una construcción, con los nombres que usa el texto, como «condición». La gramática completa, con todas sus variantes, está en el apéndice.
:::

::: resumen
- Palabras en color: van tal cual.
- Huecos «así»: los rellenas tú.
- ⟦…⟧: parte opcional.
- Una anatomía parte un ejemplo real y nombra cada pieza.
:::

::: vease
- [Convenciones tipográficas](#lectura.convenciones)
- [Gramática completa](#apendice.gramatica)
:::
