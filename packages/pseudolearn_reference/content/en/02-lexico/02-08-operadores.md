---
id: lexico.operadores
numero: "2.8"
tipo: concepto
titulo: Operators and signs
anclas: [LANG.LEXICAL.OPERATOR-TOKEN#R1]
terminos: [operator, sign, longest match]
---

::: frase
Operators and signs are the pieces made of symbols, such as `+`, `<=` or `<-`; the engine always reads the longest possible piece.
:::

## How it works {#funciona}

Besides words, the language has pieces made of symbols:

| Family | Signs |
|---|---|
| Assignment | `<-` |
| Arithmetic | `+` `-` `*` `/` `^` |
| Comparison | `=` `<>` `<` `<=` `>` `>=` |
| Grouping and access | `(` `)` `[` `]` `.` |
| Separators | `,` `;` `:` |

When two pieces could overlap, the engine chooses the **longest** one. That is why `x<-1` reads as `x`, `<-` and `1` (an assignment), while `x < -1` reads as `x`, `<`, `-` and `1` (a comparison with a negative number).

```figura id=coincidencia-larga
pie: The same symbols, split differently, are different pieces. The space decides.
```

```programa id=flecha titulo="Assigning is not comparing"
```

The assignment `<-` and the comparison `=` are different operators: `<-` stores a value, `=` asks whether two values are equal.

::: docentes
The most common mistake is reading `x = 1` as "x is 1". Insist that `=` only asks; storing uses the arrow, which reads "gets".
:::

::: resumen
- Symbol pieces form operators and signs.
- The engine always chooses the longest piece.
- `<-` assigns; `=` compares.
:::

::: vease
- [Precedence and associativity](#expresiones.precedencia)
- [Assignment](#declaraciones.asignacion)
:::
