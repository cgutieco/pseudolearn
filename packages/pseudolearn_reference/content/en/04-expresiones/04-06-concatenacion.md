---
id: expresiones.concatenacion
numero: "4.6"
tipo: concepto
titulo: Concatenation
anclas: [LANG.OPS.CONCATENATION#R1]
fichas: [help.builtin-concatenate]
diagnosticos: [cannotConcatenateNumberWithText]
terminos: [concatenation]
---

::: frase
`+` between texts glues them one after the other: `"Hola, " + "Ana"` is `"Hola, Ana"`.
:::

## How it works {#funciona}

The same `+` sign that adds numbers **concatenates** texts. It accepts any combination of `String` and `Character`, and the result is always a `String`: even two single characters form a string of length 2.

```figura id=concatenar
pie: Each piece is copied after the previous one, from left to right, and forms a new string.
```

```programa id=saludo titulo="Gluing texts"
```

Concatenation **does not convert** numbers or booleans to text. To put a number in a message there are two ways: convert it with `ConvertirATexto`, or separate the pieces with commas in `Write`.

```programa id=con-numero titulo="A number inside a text"
```

::: errores
```programa id=texto-mas-numero titulo="Adding a text and a number"
```
:::

::: resumen
- `+` between texts or characters concatenates them and gives a `String`.
- It does not convert numbers: use `ConvertirATexto` or commas in `Write`.
- It has the same precedence as addition.
:::

::: vease
- [Text](#biblioteca.texto)
- [Conversion](#biblioteca.conversion)
- [Precedence and associativity](#expresiones.precedencia)
:::
