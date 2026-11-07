---
id: lexico.espacios
numero: "2.2"
tipo: concepto
titulo: Espacios y saltos de línea
anclas: [LANG.LEXICAL.WHITESPACE#R1]
terminos: [espacio en blanco, indentación]
---

::: frase
Los espacios, las tabulaciones y los saltos de línea solo separan piezas: la sangría no cambia el significado y el salto de línea no termina una sentencia.
:::

## Cómo funciona {#funciona}

Entre dos palabras del programa puede haber un espacio, muchos o un salto de línea: para el motor da igual. La **sangría** (los espacios al principio de una línea) tampoco tiene significado. Se usa para que las personas vean qué está dentro de qué, pero el motor se guía por las palabras de apertura y cierre, como `Si` y `FinSi`.

```figura id=espacios
pie: Dos escrituras del mismo programa. Los espacios cambian la forma, no el contenido.
```

Este programa tiene una sangría descuidada y espacios de más; aun así se ejecuta igual que uno bien escrito:

```programa id=desordenado titulo="Sangría descuidada" ejecutar
Proceso   Desordenado
      Definir   n   Como Entero <- 3;
Si n > 2 Entonces
Escribir    "mayor que dos";
      FinSi
FinProceso
```

```salida
mayor que dos
```

## El salto de línea no termina nada {#salto}

Un salto de línea **no** sustituye al punto y coma. Si olvidas el `;`, el motor lo señala aunque la sentencia siguiente empiece en otra línea. Las palabras reservadas de varias palabras, como `Con Paso` o `Hasta Que`, tampoco pueden partirse en dos líneas.

::: docentes
Pide escribir el mismo programa con dos sangrías distintas y ejecutarlo: el resultado no cambia. Después explica por qué la sangría sigue siendo imprescindible para leerlo. Es una buena forma de separar «lo que entiende la máquina» de «lo que necesita una persona».
:::

::: resumen
- Espacios, tabulaciones y saltos de línea solo separan piezas.
- La sangría no tiene significado para el motor, pero sí para las personas.
- El salto de línea no sustituye al punto y coma.
:::

::: vease
- [Fin de sentencia](#lexico.fin-de-sentencia)
- [Comentarios](#lexico.comentarios)
:::
