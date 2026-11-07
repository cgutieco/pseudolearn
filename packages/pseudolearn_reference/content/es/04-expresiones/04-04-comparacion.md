---
id: expresiones.comparacion
numero: "4.4"
tipo: concepto
titulo: Comparación
anclas: [LANG.OPS.COMPARISON#R1]
fichas: [help.comparison]
diagnosticos: [realEqualityComparison, noOrderBetweenBooleans]
terminos: [comparación, igualdad, orden]
---

::: frase
Los operadores de comparación preguntan algo sobre dos valores y responden con un `Logico`: `Verdadero` o `Falso`.
:::

## Cómo funciona {#funciona}

| Operador | Pregunta |
|---|---|
| `=` | ¿son iguales? |
| `<>` | ¿son distintos? |
| `<` `<=` | ¿es menor? ¿menor o igual? |
| `>` `>=` | ¿es mayor? ¿mayor o igual? |

Qué se puede comparar:

- **Números**: igualdad y orden. Un entero se amplía a real si se compara con un real.
- **Textos y caracteres**: igualdad y orden, carácter a carácter según su código Unicode.
- **Lógicos**: solo igualdad, sin orden.
- **Enumerados y registros del mismo tipo**: solo igualdad.
- **Objetos**: igualdad de identidad (si son el mismo objeto).

```programa id=comparar titulo="Comparar distintos tipos" ejecutar
Proceso Comparar
  Escribir 3 < 3.5, " ", "abc" < "abd", " ", 'a' = "a";
  Escribir "Zeta" < "alfa", " ", Verdadero <> Falso;
FinProceso
```

```salida
Verdadero Verdadero Verdadero
Verdadero Verdadero
```

```figura id=orden-texto
pie: Los textos se comparan carácter a carácter por su código. Todas las mayúsculas tienen un código menor que las minúsculas.
```

El resultado `"Zeta" < "alfa"` sorprende: la Z mayúscula tiene un código menor que la a minúscula. El orden de los textos no es el del diccionario.

::: nota
Comparar dos reales con `=` funciona, pero produce la advertencia `realEqualityComparison`: dos cálculos que deberían coincidir pueden diferir en el último decimal.
:::

::: resumen
- Las comparaciones devuelven un `Logico`.
- Números y textos admiten igualdad y orden; lógicos, enumerados y registros solo igualdad.
- Los textos se ordenan por código Unicode, no como en un diccionario.
:::

::: vease
- [Operadores lógicos](#expresiones.logicos)
- [Tipos primitivos](#tipos.primitivos)
:::
