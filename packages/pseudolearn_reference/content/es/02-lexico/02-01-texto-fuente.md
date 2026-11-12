---
id: lexico.texto-fuente
numero: "2.1"
tipo: concepto
titulo: Texto fuente y codificación
anclas: [LANG.SOURCE.ENCODING#R1, LANG.SOURCE.ENCODING#R2, LANG.SOURCE.POSITION#R1]
terminos: [texto fuente, UTF-8, posición]
---

::: frase
Un programa es texto UTF-8; el motor lo lee carácter a carácter y recuerda la línea y la columna de cada uno para señalar errores con precisión.
:::

## Cómo funciona {#funciona}

El **texto fuente** es lo que escribes. PseudoLearn lo lee como texto **UTF-8**, la codificación que permite escribir ñ, tildes y cualquier otro símbolo de Unicode dentro de los textos y los comentarios.

Cada carácter tiene una **posición**: su línea y su columna, contando desde 1. Cuando el motor encuentra un problema, usa esas posiciones para señalar el lugar exacto. Las líneas pueden separarse con cualquiera de las tres convenciones habituales de los sistemas operativos; el motor las trata igual.

```figura id=posiciones
pie: Cada carácter tiene línea y columna. Un diagnóstico apunta a un tramo que empieza en una posición y termina justo antes de otra.
```

Los textos conservan exactamente lo que escribiste, también los caracteres fuera del alfabeto latino:

```programa id=unicode titulo="Unicode dentro de un texto" ejecutar
Algoritmo Saludos
  Escribir "¡Hola! ¿Qué tal?";
  Escribir "Ñandú, pingüino, café";
FinAlgoritmo
```

```salida
¡Hola! ¿Qué tal?
Ñandú, pingüino, café
```

## Normalización {#normalizacion}

En Unicode, algunas letras acentuadas pueden escribirse de dos maneras: como un solo carácter o como una letra seguida de un acento. Para comparar nombres, el motor las convierte primero a la misma forma, llamada **NFC**. Así `año` es siempre el mismo nombre, lo escribas como lo escribas. Los textos entre comillas no se tocan.

::: limite
Una posición cuenta líneas y columnas desde 1 y caracteres desde 0. Un tramo incluye su inicio y excluye su final. Un texto que no es UTF-8 válido no se analiza: se informa como fallo de entrada.
:::

::: resumen
- El texto fuente es UTF-8.
- Cada carácter tiene línea y columna desde 1.
- Los nombres se comparan tras normalizar a NFC; los textos no se modifican.
:::

::: vease
- [Espacios y saltos de línea](#lexico.espacios)
- [Identificadores](#lexico.identificadores)
:::
