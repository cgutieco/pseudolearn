---
id: exterior.json.valido-o-no
leccion: exterior.json
tipo: resolver
nivel: brote
obligatorio: true
titulo: Is it JSON?
---

::: enunciado
Read a text and parse it as JSON. If it is valid, show «Valid: » and its type; otherwise, show the code of the error, « at column » and the column where it was detected.
:::

```programa rol=referencia
Algoritmo ValidOrNot
  Definir text Como Cadena;
  Leer text;
  Segun AnalizarJson(text) Hacer
    Exito(valor): Escribir "Valid: ", valor.Tipo();
    Error(report): Escribir report.Codigo, " at column ", report.JsonColumna;
  FinSegun
FinAlgoritmo
```

```casos
visible | {"a": 1} | Valid: Objeto
visible | {"a": 1,} | SintaxisInvalida at column 9
oculto | [] | Valid: Arreglo
oculto | { | FinInesperado at column 2
oculto | {"a" 1} | SintaxisInvalida at column 6
```

```aserciones
- contiene | seleccion-multiple | The program chooses what to show with a Switch on the result of the parsing.
```

::: pistas
1. What does `parseJson` give back?
2. A `Result`: `Success` with the value or `Failure` with a report.
3. The value says its kind with `kind()`; the report has `code` and `jsonColumn`.
4. A `Switch` with the two branches writes each message. Close with the variant.
:::

::: variante
Also show the line of the error, as well as the column.
:::

::: explicacion
The columns are the ones the engine gives: they count from 1 and mark the first character that does not fit. An unclosed brace is `UnexpectedEnd`: the text ended too early.
:::
