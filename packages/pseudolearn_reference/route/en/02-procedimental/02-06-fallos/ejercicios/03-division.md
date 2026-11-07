---
id: procedimental.fallos.division
leccion: procedimental.fallos
tipo: resolver
nivel: brote
obligatorio: true
titulo: A division that warns
---

::: enunciado
Read two whole numbers and show the whole quotient of the first by the second, or «No se puede dividir entre 0».
:::

::: restriccion
The division goes in a subprogram `DividirSeguro` that receives both numbers and returns the quotient or the reason.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | DividirSeguro | 2 | The subprogram DividirSeguro, which receives both numbers, is missing.
```

::: pistas
1. Which input has to give a reason instead of a number?
2. Look at dividing without crashing in [the lesson](ruta:procedimental.fallos).
3. The subprogram returns a success or an error; the main algorithm handles them with a `Switch`.
4. `DividirSeguro` returns `Failure` if the divisor is 0 and `Success(a div b)` otherwise. Close with the variant.
:::

::: variante
Add a second reason: «El dividendo es negativo».
:::

::: docentes
Hidden cases: 0 in the numerator (it is valid) and 0 by 0 (it is an error). Frequent mistake: checking the numerator instead of the divisor.
:::
