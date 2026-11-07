---
id: declaraciones.designadores
numero: "5.4"
tipo: concepto
titulo: Designadores
anclas: [LANG.DECL.DESIGNATOR#R1]
diagnosticos: [invalidAssignmentTarget, invalidReadTarget]
terminos: [designador]
---

::: frase
Un designador es algo que nombra un lugar donde se puede guardar un valor: una variable, una casilla de un arreglo o un atributo de un objeto.
:::

## Cómo funciona {#funciona}

No todo lo que se puede leer se puede escribir. `x + 1` tiene un valor, pero no es un lugar: no hay dónde guardar nada. Las sentencias que guardan valores —la asignación, `Leer` y el paso por referencia— exigen un **designador**.

```figura id=designadores
pie: A la izquierda, designadores: nombran un lugar. A la derecha, expresiones que solo tienen valor.
```

| Es designador | No es designador |
|---|---|
| `x` | `5` |
| `notas[i]` | `x + 1` |
| `persona.nombre` | `Longitud(t)` |
| `tabla[i, j]` | `(x)` |

Los índices y el receptor de un designador se evalúan **una sola vez**, antes de guardar:

```programa id=designadores titulo="Casillas como destino" ejecutar
Algoritmo Designadores
  Dimension notas[3] Como Entero;
  Definir i Como Entero <- 0;
  notas[0] <- 7;
  notas[i + 1] <- notas[0] + 1;
  notas[2] <- 10;
  Escribir notas[0], " ", notas[1], " ", notas[2];
FinAlgoritmo
```

```salida
7 8 10
```

En `notas[i + 1]` el índice es una expresión cualquiera, pero `notas[…]` en conjunto sigue nombrando un lugar.

::: errores
```programa id=leer-literal titulo="Leer en un número" ejecutar
Algoritmo LeerLiteral
  Leer 5;
FinAlgoritmo
```

```diagnosticos
invalidReadTarget
```
:::

::: resumen
- Un designador nombra un lugar: variable, casilla o atributo.
- Asignar, `Leer` y pasar por referencia exigen designador.
- Literales, operaciones, llamadas y paréntesis no lo son.
:::

::: vease
- [Asignación](#declaraciones.asignacion)
- [Arreglos](#tipos.arreglos)
- [Parámetros por referencia](#subprogramas.referencia)
:::
