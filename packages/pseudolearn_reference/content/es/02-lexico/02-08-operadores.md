---
id: lexico.operadores
numero: "2.8"
tipo: concepto
titulo: Operadores y signos
anclas: [LANG.LEXICAL.OPERATOR-TOKEN#R1]
terminos: [operador, signo, coincidencia más larga]
---

::: frase
Los operadores y signos son las piezas hechas de símbolos, como `+`, `<=` o `<-`; el motor siempre lee la pieza más larga posible.
:::

## Cómo funciona {#funciona}

Además de palabras, el lenguaje tiene piezas formadas por símbolos:

| Familia | Signos |
|---|---|
| Asignación | `<-` |
| Aritméticos | `+` `-` `*` `/` `^` |
| Comparación | `=` `<>` `<` `<=` `>` `>=` |
| Agrupación y acceso | `(` `)` `[` `]` `.` |
| Separadores | `,` `;` `:` |

Cuando dos piezas podrían solaparse, el motor elige la **más larga**. Por eso `x<-1` se lee como `x`, `<-` y `1` (una asignación), mientras que `x < -1` se lee como `x`, `<`, `-` y `1` (una comparación con un número negativo).

```figura id=coincidencia-larga
pie: Los mismos símbolos, separados de otra forma, son otras piezas. El espacio decide.
```

```programa id=flecha titulo="Asignar no es comparar" ejecutar
Algoritmo Flecha
  Definir x Como Entero <- 5;
  x<-1;
  Escribir x;
  Escribir x < -1;
  Escribir x = 1;
FinAlgoritmo
```

```salida
1
Falso
Verdadero
```

La asignación `<-` y la comparación `=` son operadores distintos: `<-` guarda un valor, `=` pregunta si dos valores son iguales.

::: nota
El error más común es leer `x = 1` como «x vale 1». `=` solo pregunta; para guardar se usa la flecha, que se lee «recibe».
:::

::: resumen
- Las piezas de símbolos forman operadores y signos.
- El motor elige siempre la pieza más larga.
- `<-` asigna; `=` compara.
:::

::: vease
- [Precedencia y asociatividad](#expresiones.precedencia)
- [Asignación](#declaraciones.asignacion)
:::
