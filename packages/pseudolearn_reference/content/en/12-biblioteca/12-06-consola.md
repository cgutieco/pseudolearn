---
id: biblioteca.consola
numero: "12.6"
tipo: construccion
titulo: "`Read` and `Write`"
anclas: [LANG.IO.INPUT#R1, LANG.IO.OUTPUT#R1]
fichas: [help.input, help.output]
diagnosticos: [readValueTypeMismatch, invalidReadTarget, unexpectedModifierPosition]
terminos: [input, output]
---

::: frase
`Write` shows values on the output and `Read` asks the person using the program for values: they are the simplest way to talk to the outside.
:::

## How to write it {#escribe}

```forma
```

::: partes
- `Write` evaluates zero or more comma-separated expressions, from left to right.
- `Without Newline` is optional and goes at the end: it avoids the line break.
- `Read` asks for one value per [designator](#declaraciones.designadores), one at a time and in order.
:::

## How it works {#funciona}

`Write` glues the representations of its values **without a separator** and ends with a line break, unless `Without Newline` is given. An empty `Write` writes a blank line.

`Read` converts every input according to the target's type. If the input does not fit, it warns with `readValueTypeMismatch` and **asks again** for the same value without touching the variable. Once `Read` gives a variable a value, that variable has a value for the [initialization check](#declaraciones.sin-valor).

```programa id=suma-leida titulo="Asking for two numbers"
```

```figura id=leer-escribir
pie: `Read` takes values from the input, one per target. `Write` puts text on the output, on one line unless `Without Newline` is used.
```

If no input is available, execution waits. In the app a field appears to type into; in the terminal standard input is read.

::: errores
```programa id=sin-saltar-mal titulo="Without Newline in the middle"
```
:::

::: por-dentro
`Write` becomes one output instruction per expression and a final line break. `Read` is an instruction that suspends execution until the host hands over a value.

```ri programa=suma-leida
```
:::

::: resumen
- `Write` joins values without a separator and breaks the line, unless `Without Newline`.
- `Read` asks for one value per target and converts it to the type.
- An invalid input is asked for again with a warning.
:::

::: vease
- [Severity](#diagnosticos.severidad)
- [Concatenation](#expresiones.concatenacion)
- [Effects and capabilities](#tareas.efectos)
:::
