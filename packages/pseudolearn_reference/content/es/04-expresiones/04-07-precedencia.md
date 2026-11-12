---
id: expresiones.precedencia
numero: "4.7"
tipo: concepto
titulo: Precedencia y asociatividad
anclas: [LANG.OPS.PRECEDENCE#R1]
diagnosticos: [incompatibleOperandTypes]
terminos: [precedencia, asociatividad, paréntesis]
---

::: frase
Cuando una expresión tiene varios operadores, la precedencia decide cuál se aplica primero: `2 + 3 * 4` es 14, no 20.
:::

## Cómo funciona {#funciona}

Cada operador tiene un **nivel**. Los de nivel más alto agarran antes a sus operandos. Del más fuerte al más débil:

```figura id=escalera-precedencia
pie: Los niveles de precedencia, del que liga más fuerte (arriba) al que liga más débil (abajo).
```

Cuando dos operadores del mismo nivel están seguidos, decide la **asociatividad**. Casi todos asocian a la izquierda: `10 - 4 - 3` es `(10 - 4) - 3`, que vale 3. Los unarios y la potencia asocian a la derecha.

```programa id=precedencia titulo="Quién va primero" ejecutar
Algoritmo Precedencia
  Escribir 2 + 3 * 4, " ", (2 + 3) * 4, " ", 10 - 4 - 3, " ", 2 ^ 3 ^ 2;
  Escribir 1 + 2 < 4 Y NO Falso, " ", 2 * 3 = 6 O Falso;
FinAlgoritmo
```

```salida
14 20 3 512
Verdadero Verdadero
```

En la segunda línea, primero se calculan las cuentas, después las comparaciones y al final `Y` y `O`. Por eso las condiciones se leen con naturalidad sin paréntesis.

```figura id=arbol-precedencia
pie: Cómo se agrupa `2 + 3 * 4`. El producto queda más abajo en el árbol porque se calcula antes.
paso: La expresión tal como se escribe.
paso: `*` tiene más nivel que `+`, así que se agrupa primero `3 * 4`.
paso: Se calcula el producto: 12.
paso: Queda la suma: 2 + 12 = 14.
```

::: nota
Los paréntesis siempre ganan. Si dudas, ponlos: `(a + b) / 2` deja claro lo que quieres y no cuesta nada.
:::

::: limite
Dos lugares donde la precedencia sorprende:

- El signo liga más que la potencia: `-2 ^ 2` es 4.
- `NO` liga más que las comparaciones: escribe `NO (a = b)` o, mejor, `a <> b`.
:::

::: resumen
- Primero lo postfijo, luego unarios, potencia, producto, suma, orden, igualdad, `Y` y `O`.
- A igual nivel se agrupa a la izquierda, salvo unarios y potencia.
- Los paréntesis cambian el orden.
:::

::: vease
- [Operadores aritméticos](#expresiones.aritmeticos)
- [Potencia](#expresiones.potencia)
- [Operadores lógicos](#expresiones.logicos)
:::
