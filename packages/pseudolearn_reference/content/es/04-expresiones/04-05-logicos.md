---
id: expresiones.logicos
numero: "4.5"
tipo: concepto
titulo: Operadores lógicos
anclas: [LANG.OPS.LOGICAL#R1]
fichas: [help.logical]
diagnosticos: [incompatibleOperandTypes]
terminos: [cortocircuito, conjunción, disyunción, negación]
---

::: frase
`Y`, `O` y `NO` combinan respuestas lógicas: `Y` pide que las dos sean verdaderas, `O` se conforma con una y `NO` da la vuelta a la respuesta.
:::

## Cómo funciona {#funciona}

Los tres operadores solo aceptan valores `Logico` y devuelven un `Logico`.

| `a` | `b` | `a Y b` | `a O b` | `NO a` |
|---|---|---|---|---|
| `Verdadero` | `Verdadero` | `Verdadero` | `Verdadero` | `Falso` |
| `Verdadero` | `Falso` | `Falso` | `Verdadero` | `Falso` |
| `Falso` | `Verdadero` | `Falso` | `Verdadero` | `Verdadero` |
| `Falso` | `Falso` | `Falso` | `Falso` | `Verdadero` |

```programa id=logica titulo="Combinar condiciones" ejecutar
Algoritmo Logica
  Definir edad Como Entero <- 15;
  Definir socio Como Logico <- Falso;
  Escribir edad >= 12 Y edad < 18, " ", NO socio, " ", edad < 12 O socio;
FinAlgoritmo
```

```salida
Verdadero Verdadero Falso
```

## Cortocircuito {#cortocircuito}

`Y` y `O` evalúan primero la parte izquierda. Si con ella ya se sabe la respuesta, **la derecha no se calcula**:

- `Falso Y …` es siempre `Falso`.
- `Verdadero O …` es siempre `Verdadero`.

```figura id=cortocircuito
pie: Con `Y`, una izquierda falsa decide sin mirar la derecha. Con `O`, lo hace una izquierda verdadera.
```

```programa id=cortocircuito titulo="La derecha que nunca se calcula" ejecutar
Algoritmo Cortocircuito
  Escribir Verdadero O 1 div 0 = 0, " ", Falso Y 1 div 0 = 0;
FinAlgoritmo
```

```salida
Verdadero Falso
```

La división entre cero está ahí, pero nunca se ejecuta, así que no detiene el programa. El cortocircuito suprime los efectos y los fallos de la derecha; lo que no suprime es la comprobación de tipos: la derecha tiene que ser un `Logico` válido aunque no se calcule.

::: limite
- `1 Y Verdadero` se rechaza antes de ejecutar: los números no son respuestas lógicas.
- `NO` liga más fuerte que las comparaciones: `NO 1 = 2` intenta negar el 1. Escribe `NO (1 = 2)`.
:::

::: resumen
- `Y` exige las dos verdaderas; `O`, al menos una; `NO` invierte.
- Solo aceptan `Logico`.
- La derecha de `Y` y `O` solo se calcula si hace falta.
:::

::: vease
- [Comparación](#expresiones.comparacion)
- [Precedencia y asociatividad](#expresiones.precedencia)
- [La decisión Si](#control.si)
:::
