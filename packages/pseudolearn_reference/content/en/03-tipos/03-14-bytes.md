---
id: tipos.bytes
numero: "3.14"
tipo: tipo
titulo: Bytes
anclas: [LIB.CORE.BYTES]
fichas: [help.pg501.bytes_new, help.pg501.bytes_from_text, help.pg501.bytes_segment, help.pg501.bytes_utf8]
diagnosticos: [bytesRangeOutOfBounds, arrayIndexOutOfRange]
terminos: [byte, octet, UTF-8]
---

::: frase
`Bytes` is a sequence of octets, numbers from 0 to 255; it is used to work with binary data, such as the exact content of a file.
:::

## How to write it {#escribe}

```forma
Define «name» As Bytes <- Bytes();
Define «name» As Bytes <- bytesFromText(«text»);
«name».at(«position»)
«name».segment(«start», «count»)
```

## How it works {#funciona}

A text is a row of characters; **bytes** are the way that text is stored in a file or travels over the network. Converting a text to bytes uses the UTF-8 encoding. Letters without accents take one octet, but ñ takes two.

```programa id=octetos titulo="The octets of a word"
```

```figura id=bytes-utf8
pie: "año" has three characters but four octets: ñ is encoded with two.
```

Decoding goes the other way and returns a `Result`, because not every byte sequence is a valid text:

```programa id=decodificar titulo="From bytes to text"
```

::: limite
- `Bytes` is **immutable**: taking a segment or joining return new sequences. That is why it can move between tasks.
- Reading position `i` returns an `Integer` between 0 and 255, with `i` from 0.
- A segment must stay inside the sequence; otherwise, `bytesRangeOutOfBounds`.
- Encoding adds no byte order mark (BOM).
:::

::: errores
A segment that goes past the sequence stops the program at the call:

```programa id=segmento titulo="A segment that is too long"
```
:::

::: por-dentro
A byte sequence lives on the heap and never changes, so several variables can share it without copying it. Segments and joins create new sequences instead of modifying the original.

```ri programa=octetos
```
:::

::: resumen
- `Bytes` is an immutable sequence of octets from 0 to 255.
- Text is encoded to UTF-8; decoding returns a `Result`.
- Some characters take several octets.
:::

::: vease
- [Files](#biblioteca.archivos)
- [Text and character literals](#lexico.textos)
:::
