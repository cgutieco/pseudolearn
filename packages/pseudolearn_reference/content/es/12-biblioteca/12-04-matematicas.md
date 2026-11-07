---
id: biblioteca.matematicas
numero: "12.4"
tipo: concepto
titulo: Matemáticas y redondeo
anclas: [LIB.CORE.MATH#R1, LIB.CORE.MATH#R2, LIB.CORE.MATH#R3, LIB.CORE.ROUNDING#R1, LIB.CORE.ROUNDING#R2]
fichas: [help.builtin-math, help.builtin-rounding]
diagnosticos: [nonFiniteRealResult, integerOverflow]
terminos: [redondeo, truncamiento]
---

::: frase
Las funciones matemáticas calculan raíces, logaritmos y trigonometría con resultados exactos al último bit, y las de redondeo pasan de real a entero de cuatro maneras distintas.
:::

## Cómo funciona {#funciona}

Las funciones matemáticas aceptan enteros o reales y devuelven reales: `rc` (raíz cuadrada), `abs`, `ln`, `exp`, `log10`, `log2`, y la trigonometría en radianes `sen`, `cos`, `tan`, `asen`, `acos`, `atan`, `atan2`. `min` y `max` devuelven entero si los dos argumentos son enteros.

El resultado es siempre el real más cercano al valor exacto, en cualquier máquina: no depende de la biblioteca matemática del sistema.

Para pasar de real a entero hay cuatro funciones, que solo difieren en los números con decimales:

| Función | Regla | 2.5 | -2.5 |
|---|---|---|---|
| `trunc` | hacia el cero | 2 | -2 |
| `redon` | al más cercano; los empates, lejos del cero | 3 | -3 |
| `piso` | hacia abajo | 2 | -3 |
| `techo` | hacia arriba | 3 | -2 |

```figura id=redondeos
pie: Las cuatro formas de llevar -2.5 a un entero sobre la recta numérica.
```

```programa id=mates titulo="Funciones y redondeos" ejecutar
Algoritmo Mates
  Escribir rc(16), " ", abs(-3), " ", trunc(2.7), " ", redon(2.5), " ", redon(-2.5);
  Escribir piso(-2.5), " ", techo(-2.5), " ", min(3, 7), " ", max(2, 4.5);
  Escribir ln(1), " ", exp(0), " ", sen(0), " ", cos(0), " ", log10(1000), " ", log2(8);
FinAlgoritmo
```

```salida
4.0 3.0 2 3 -3
-3 -2 3 4.5
0.0 1.0 0.0 1.0 3.0 3.0
```

::: limite
- Un argumento fuera del dominio —la raíz de un negativo, el logaritmo de cero— produce `nonFiniteRealResult`.
- Los redondeos devuelven enteros de 64 bits: un real demasiado grande produce `integerOverflow`.
:::

::: errores
```programa id=raiz-negativa titulo="La raíz de un negativo" ejecutar termina=failed
Algoritmo Raiz
  Escribir rc(-1);
FinAlgoritmo
```

```diagnosticos
nonFiniteRealResult
```
:::

::: resumen
- Las funciones matemáticas devuelven reales exactos en cualquier máquina.
- `trunc`, `redon`, `piso` y `techo` pasan de real a entero.
- Fuera del dominio, el programa se detiene.
:::

::: vease
- [Potencia](#expresiones.potencia)
- [División](#expresiones.division)
:::
