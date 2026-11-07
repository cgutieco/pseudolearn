---
id: tipos.inferencia
numero: "3.3"
tipo: concepto
titulo: "Inference: the type is always declared"
anclas: [LANG.TYPES.INFERENCE#R1]
diagnosticos: [undeclaredVariable]
terminos: [inference, declaration]
---

::: frase
In PseudoLearn no variable guesses its type: each one is declared with `Define` and an explicit type before it is used.
:::

## How it works {#funciona}

Some languages deduce the type of a variable from the first value it receives. PseudoLearn does not: the **declaration** is required and the type is always written. The initial value is optional and never decides the type.

```figura id=declarar-antes
pie: First the box is declared with its shape; then values can be stored. An assignment never creates a new box.
```

```programa id=declarar titulo="Declare and then assign"
```

Assigning to a name nobody declared does not create a variable: it is an error. That way a typo such as `contdor` instead of `contador` is found before running, instead of silently creating a new variable.

```programa id=sin-declarar titulo="Assigning without declaring"
```

::: docentes
Ask why a language designed for learning requires declarations. The short answer: a declaration is a promise the engine can check, and typos in variable names are among the hardest mistakes to spot by eye.
:::

::: resumen
- Every variable is declared with `Define` and an explicit type.
- The initial value is optional and does not decide the type.
- Assigning to an undeclared name is an error, not a declaration.
:::

::: vease
- [Define](#declaraciones.definir)
- [Variables without a value](#declaraciones.sin-valor)
:::
