---
id: lexico.comentarios
numero: "2.3"
tipo: concepto
titulo: Comentarios
anclas: [LANG.LEXICAL.COMMENT#R1]
terminos: [comentario]
---

::: frase
Un comentario empieza con `//` y llega hasta el final de la línea; el motor lo guarda pero no lo ejecuta.
:::

## Cómo funciona {#funciona}

Un **comentario** es una nota para las personas que leen el programa. Empieza con dos barras, `//`, y termina donde termina la línea. Puede ocupar una línea entera o ir al final de una instrucción.

```figura id=comentario
pie: Lo que hay a la derecha de las dos barras es comentario hasta el final de la línea. Dentro de un texto entre comillas, las barras son solo caracteres.
```

```programa id=comentarios titulo="Comentarios en su sitio" ejecutar
Algoritmo Comentarios
  // Calcula el área de un rectángulo
  Definir base Como Entero <- 4;
  Definir altura Como Entero <- 3;
  Escribir base * altura; // 4 por 3
  Escribir "// esto no es un comentario";
FinAlgoritmo
```

```salida
12
// esto no es un comentario
```

El motor no ejecuta los comentarios, pero tampoco los tira: los conserva para que el editor, el formateador y el traductor de perfiles los dejen intactos.

::: nota
PseudoLearn solo tiene comentarios de línea. No existe un comentario que abra en una línea y cierre en otra: para comentar varias líneas, cada una lleva su propio `//`.
:::

::: resumen
- `//` abre un comentario hasta el final de la línea.
- Dentro de un texto entre comillas, `//` es texto normal.
- Los comentarios se conservan al formatear y al traducir.
:::

::: vease
- [Espacios y saltos de línea](#lexico.espacios)
- [Perfiles de sintaxis](#lectura.perfiles)
:::
