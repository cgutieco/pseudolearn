---
id: lectura.convenciones
numero: "0.2"
tipo: concepto
titulo: Convenciones tipográficas
anclas: [LANG.PROFILE.VOCABULARY#R1]
terminos: [palabra reservada, hueco, píldora]
---

::: frase
Todo lo que pertenece al lenguaje se ve como código; todo lo que tienes que rellenar tú se ve como un hueco.
:::

## Cómo funciona {#funciona}

En español, «si» es una palabra corriente y `Si` es una palabra del lenguaje. Para no confundirlas, toda palabra del lenguaje dentro de un párrafo aparece como una **píldora** con fondo sombreado y los mismos colores del editor: `Si`, `Mientras`, `Definir edad Como Entero`.

Los **huecos** son los sitios donde va algo que eliges tú. Se escriben entre comillas angulares, como «condición» o «nombre». Nunca se copian tal cual: se sustituyen por código real.

```figura id=convenciones
pie: Las tres formas de mostrar el lenguaje: píldora de código, hueco y bloque de programa con su salida.
```

Los programas completos van en bloques numerados. Debajo de cada bloque aparece la salida que produjo el motor y cómo terminó la ejecución. El botón «Probar en el editor» lo abre como documento nuevo.

```programa id=edad titulo="Un programa con su salida" ejecutar
Algoritmo Edad
  Definir edad Como Entero <- 12;
  Escribir "Tengo ", edad, " años";
FinAlgoritmo
```

```salida
Tengo 12 años
```

## Colores {#colores}

Los colores siguen al editor. Las palabras que estructuran el programa (`Si`, `Mientras`, `Algoritmo`) tienen un color; las de subprogramas (`SubProceso`, `Retornar`) otro; las de objetos (`Clase`, `Nuevo`) un tercero. Los números, los textos y los valores lógicos tienen el suyo. El color ayuda, pero nunca es la única pista: el texto siempre dice lo mismo sin color.

::: resumen
- Las palabras del lenguaje aparecen como píldoras de código.
- Los huecos «así» se sustituyen por código tuyo.
- Cada programa muestra debajo su salida real.
- Los colores son los del editor.
:::

::: vease
- [Cómo leer una forma de escritura](#lectura.formas)
- [Palabras reservadas](#lexico.palabras-reservadas)
:::
