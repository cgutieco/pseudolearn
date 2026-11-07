---
id: biblioteca.archivos
numero: "12.7"
tipo: concepto
titulo: Files and folders
anclas: [LIB.IO#R1, LIB.IO#R2, LIB.IO#R3, LIB.IO#R4, LIB.IO#R5, LIB.IO#R6, LIB.IO#R7, LIB.IO#R8, LIB.IO#R9, LIB.IO#R10, LIB.IO#R11, LIB.IO#R12, LIB.IO#R13, LIB.IO#R14, LIB.IO#R15, LIB.IO#R16]
fichas: [construction.bytes_io, construction.environment_date_time]
diagnosticos: [incompatiblePropagationType]
terminos: [file, directory, IoError]
---

::: frase
To read or write files you ask for a folder capability, open the file with it, and every operation returns a `Result` that may carry an `IoError`.
:::

## How it works {#funciona}

The path is always the same:

1. `requestDirectory(path)` gives a `DirCap` for that folder.
2. `folder.open(name, mode)` gives a `FileCap`. With `"lectura"` it only reads; `"escritura"` creates or empties the file; `"lectura_escritura"` creates it if missing and keeps what it had.
3. `readText`, `writeText`, `appendText` and their `Bytes` versions do the work.

Every step can fail, so it returns `Result<…, IoError>`. With `Propagate`, a failure is returned to the caller without writing the `Switch` by hand.

```figura id=archivo-capas
pie: From folder to file and from file to contents. Every arrow is an operation that may fail with an `IoError`.
```

```programa id=nota titulo="Saving and re-reading a note"
```

A file that does not exist does not stop the program: it arrives as an `Error` whose `code` is `"no_encontrado"`, and the program decides what to do.

```programa id=no-existe titulo="A file that is not there"
```

Folders can also be queried and changed: `exists`, `isDirectory`, `list` (sorted), `createDirectory`, `rename` and `delete` (never recursive). `subdirectory` gives a confined capability that cannot leave its folder.

::: limite
- Text is read and written as strict UTF-8: invalid content is `Utf8Invalido`, never silently replaced.
- `IoError` has fixed variants —`NoEncontrado`, `PermisoDenegado`, `YaExiste`, `RutaInvalida`, `CapacidadCerrada` and others— and its `code` is a stable text such as `"no_encontrado"`.
- A `Defer` cleanup that closes a file never hides the main error.
:::

::: resumen
- Folder, file and contents: three steps, each one fallible.
- Failures arrive as `IoError` inside a `Result`.
- `Propagate` returns the error to the caller.
:::

::: vease
- [Effects and capabilities](#tareas.efectos)
- [Optional and Result](#tipos.opcional-resultado)
- [Bytes](#tipos.bytes)
- [JSON](#biblioteca.json)
:::
