---
id: expresiones.aritmeticos
numero: "4.1"
tipo: concepto
titulo: Operadores aritméticos
anclas: [LANG.OPS.ARITHMETIC#R1]
fichas: [help.arithmetic]
diagnosticos: [integerOverflow, incompatibleOperandTypes]
terminos: [expresión, operador, operando]
---

::: frase
`+`, `-` y `*` calculan con números: entre dos enteros dan un entero exacto y, si alguno es real, dan un real.
:::

## Cómo funciona {#funciona}

Una **expresión** combina valores con **operadores** para calcular otro valor. Los operadores aritméticos básicos son la suma `+`, la resta `-` y el producto `*`, más el signo menos delante de un número.

El tipo del resultado depende de los operandos:

| Operandos | Resultado |
|---|---|
| `Entero` y `Entero` | `Entero` exacto |
| al menos un `Real` | `Real` |

```figura id=tipo-resultado
pie: Dos enteros dan un entero; basta un real para que el resultado sea real.
```

```programa id=aritmetica titulo="Las cuatro cuentas básicas" ejecutar
Algoritmo Aritmetica
  Definir precio Como Entero <- 7;
  Definir cantidad Como Entero <- 3;
  Escribir precio + cantidad, " ", precio - cantidad, " ", precio * cantidad;
  Escribir precio * 1.5, " ", -precio;
FinAlgoritmo
```

```salida
10 4 21
10.5 -7
```

Los operadores aritméticos solo aceptan números. Sumar un número y un lógico, o un número y un texto, se detecta antes de ejecutar.

::: limite
Las operaciones entre enteros se comprueban en 64 bits con signo: si el resultado no cabe, el programa se detiene con `integerOverflow`. No hay «vuelta» silenciosa. El signo menos aplicado al entero más pequeño también desborda, porque su opuesto no cabe.
:::

::: resumen
- `+`, `-` y `*` operan con números.
- Dos enteros dan un entero exacto; si hay un real, el resultado es real.
- Salirse del rango de los enteros detiene el programa.
:::

::: vease
- [División, div y mod](#expresiones.division)
- [Precedencia y asociatividad](#expresiones.precedencia)
- [Tipos primitivos](#tipos.primitivos)
:::
