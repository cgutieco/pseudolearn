---
id: tipos.bytes
numero: "3.14"
tipo: tipo
titulo: Bytes
anclas: [LIB.CORE.BYTES]
fichas: [help.pg501.bytes_new, help.pg501.bytes_from_text, help.pg501.bytes_segment, help.pg501.bytes_utf8]
diagnosticos: [bytesRangeOutOfBounds, arrayIndexOutOfRange]
terminos: [byte, octeto, UTF-8]
---

::: frase
`Bytes` es una secuencia de octetos, números del 0 al 255; sirve para trabajar con datos binarios, como el contenido exacto de un archivo.
:::

## Cómo se escribe {#escribe}

```forma
Definir «nombre» Como Bytes <- Bytes();
Definir «nombre» Como Bytes <- BytesDesdeTexto(«texto»);
«nombre».En(«posición»)
«nombre».Segmento(«inicio», «cantidad»)
```

## Cómo funciona {#funciona}

Un texto es una fila de caracteres; los **bytes** son la forma en que ese texto se guarda en un archivo o viaja por la red. `BytesDesdeTexto` convierte un texto en bytes con la codificación UTF-8. Las letras sin tilde ocupan un octeto, pero la ñ ocupa dos.

```programa id=octetos titulo="Los octetos de una palabra" ejecutar
Algoritmo Octetos
  Definir datos Como Bytes <- BytesDesdeTexto("año");
  Escribir datos.Longitud(), " ", datos.En(0), " ", datos.En(1), " ", datos.En(2);
  Definir vacio Como Bytes <- Bytes();
  Escribir vacio.Longitud();
FinAlgoritmo
```

```salida
4 97 195 177
0
```

```figura id=bytes-utf8
pie: «año» tiene tres caracteres pero cuatro octetos: la ñ se codifica con dos.
```

`TextoUtf8` hace el camino inverso y devuelve un `Resultado`, porque no cualquier secuencia de bytes es un texto válido:

```programa id=decodificar titulo="De bytes a texto" ejecutar
Algoritmo Decodificar
  Definir datos Como Bytes <- BytesDesdeTexto("año");
  Segun datos.TextoUtf8() Hacer
    Exito(texto): Escribir texto, " (", Longitud(texto), " caracteres)";
    De Otro Modo: Escribir "no es UTF-8";
  FinSegun
FinAlgoritmo
```

```salida
año (3 caracteres)
```

::: limite
- `Bytes` es **inmutable**: `Segmento` y `Unir` devuelven secuencias nuevas. Por eso puede pasar entre tareas.
- `En(i)` devuelve un `Entero` entre 0 y 255, con `i` desde 0.
- `Segmento(inicio, cantidad)` debe quedar dentro de la secuencia; si no, `bytesRangeOutOfBounds`.
- `BytesDesdeTexto` no añade marca de orden de bytes (BOM).
:::

::: errores
Un segmento que se sale de la secuencia detiene el programa en la llamada:

```programa id=segmento titulo="Un segmento demasiado largo" ejecutar termina=failed
Algoritmo Segmento
  Definir datos Como Bytes <- BytesDesdeTexto("hola");
  Escribir datos.Segmento(1, 5).Longitud();
FinAlgoritmo
```

```diagnosticos
bytesRangeOutOfBounds
```
:::

::: por-dentro
Una secuencia de bytes vive en el montón y nunca cambia, así que varias variables pueden compartirla sin copiarla. `Segmento` y `Unir` crean secuencias nuevas en lugar de modificar la original.

```ri programa=octetos
```
:::

::: resumen
- `Bytes` es una secuencia inmutable de octetos de 0 a 255.
- `BytesDesdeTexto` codifica en UTF-8; `TextoUtf8` decodifica y devuelve un `Resultado`.
- Algunos caracteres ocupan varios octetos.
:::

::: vease
- [Archivos](#biblioteca.archivos)
- [Literales de texto y de carácter](#lexico.textos)
:::
