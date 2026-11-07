---
id: expresiones.potencia
numero: "4.3"
tipo: concepto
titulo: Potencia
anclas: [LANG.OPS.POWER#R1]
diagnosticos: [negativeIntegerExponent, integerOverflow, nonFiniteRealResult]
terminos: [potencia, exponente]
---

::: frase
`^` eleva un número a otro: `2 ^ 10` es 1024; entre enteros el resultado es exacto, y con un real es real.
:::

## Cómo funciona {#funciona}

La **potencia** `a ^ b` multiplica `a` por sí mismo `b` veces. Igual que en los otros operadores, el tipo del resultado depende de los operandos: dos enteros dan un entero exacto; si alguno es real, el resultado es real.

```programa id=potencias titulo="Potencias enteras y reales" ejecutar
Proceso Potencias
  Escribir 2 ^ 10, " ", 2 ^ 0.5, " ", 0 ^ 0, " ", 2.0 ^ 3;
  Escribir 2 ^ 3 ^ 2, " ", -2 ^ 2;
FinProceso
```

```salida
1024 1.4142135623730951 1 8.0
512 4
```

Dos detalles que conviene saber:

- La potencia **asocia a la derecha**: `2 ^ 3 ^ 2` es `2 ^ (3 ^ 2)`, es decir 2 elevado a 9.
- El signo liga **más** que la potencia: `-2 ^ 2` es `(-2) ^ 2`, que vale 4.

```figura id=potencia-derecha
pie: La potencia se agrupa de derecha a izquierda. Primero se calcula 3 ^ 2 y después 2 ^ 9.
```

::: limite
- Con dos enteros, el exponente no puede ser negativo: `negativeIntegerExponent`. Para eso usa un real: `2.0 ^ -1` vale 0.5.
- Cualquier número elevado a 0 es 1, también 0 ^ 0.
- Un resultado entero que no cabe produce `integerOverflow`; uno real infinito, `nonFiniteRealResult`.
:::

::: errores
```programa id=exponente-negativo titulo="Exponente negativo entre enteros" ejecutar
Proceso ExponenteNegativo
  Escribir 2 ^ -1;
FinProceso
```

```diagnosticos
negativeIntegerExponent
```
:::

::: resumen
- `a ^ b` es la potencia; entre enteros es exacta.
- Asocia a la derecha: `2 ^ 3 ^ 2` es 512.
- El signo se aplica antes: `-2 ^ 2` es 4.
- Entre enteros el exponente no puede ser negativo.
:::

::: vease
- [Precedencia y asociatividad](#expresiones.precedencia)
- [Matemáticas y redondeo](#biblioteca.matematicas)
:::
