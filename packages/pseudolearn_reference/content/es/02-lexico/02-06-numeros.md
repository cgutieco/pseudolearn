---
id: lexico.numeros
numero: "2.6"
tipo: concepto
titulo: Literales numéricos
anclas: [LANG.LEXICAL.NUMBER-LITERAL#R1]
diagnosticos: [integerLiteralOutOfRange]
terminos: [literal, entero, real]
---

::: frase
Un número escrito en el programa es entero si solo tiene dígitos y real si tiene un punto con dígitos a los dos lados.
:::

## Cómo funciona {#funciona}

Un **literal** es un valor escrito tal cual en el programa. Los literales numéricos son de dos clases:

- **Enteros**: solo dígitos, como `0`, `42` o `2026`.
- **Reales**: dígitos, un punto y más dígitos, como `3.14` o `0.5`. El separador es siempre el punto, no la coma, y tiene que haber al menos un dígito a cada lado.

```figura id=literales-numericos
pie: Qué se lee como entero, qué como real y qué no es un número.
```

El signo menos no forma parte del literal: `-5` es el operador menos aplicado a `5`.

```programa id=numeros titulo="Enteros y reales escritos tal cual" ejecutar
Proceso Numeros
  Definir edad Como Entero <- 12;
  Definir pi Como Real <- 3.14159;
  Definir mitad Como Real <- 0.5;
  Escribir edad, " ", pi, " ", mitad, " ", -7;
FinProceso
```

```salida
12 3.14159 0.5 -7
```

::: limite
Un literal entero tiene que caber en 64 bits con signo: el mayor es 9223372036854775807. El literal 9223372036854775808 es un error aunque vaya precedido de un menos; el entero más pequeño se obtiene como `-9223372036854775807 - 1`. No hay notación científica (`1e3` no es un número) ni separadores de miles.
:::

::: errores
Un entero demasiado grande se detecta antes de ejecutar:

```programa id=enorme titulo="Un entero que no cabe" ejecutar
Proceso Enorme
  Definir x Como Entero <- 9223372036854775808;
FinProceso
```

```diagnosticos
integerLiteralOutOfRange
```
:::

::: resumen
- Entero: solo dígitos. Real: dígitos, punto y dígitos.
- El separador decimal es el punto.
- El signo es un operador aparte.
- Un literal entero debe caber en 64 bits con signo.
:::

::: vease
- [Tipos primitivos](#tipos.primitivos)
- [Operadores aritméticos](#expresiones.aritmeticos)
:::
