---
id: expresiones.division
numero: "4.2"
tipo: concepto
titulo: "División, `div` y `mod`"
anclas: [LANG.OPS.DIVISION#R1]
diagnosticos: [divisionByZero]
terminos: [división, cociente, resto]
---

::: frase
Hay tres maneras de dividir: `/` da siempre un real, `div` da el cociente entero y `mod` da lo que sobra.
:::

## Cómo funciona {#funciona}

Repartir 7 caramelos entre 2 personas admite tres preguntas distintas, y cada una tiene su operador:

| Pregunta | Operador | 7 entre 2 |
|---|---|---|
| ¿Cuánto toca exactamente? | `/` | 3.5 |
| ¿Cuántos enteros toca a cada una? | `div` | 3 |
| ¿Cuántos sobran? | `mod` | 1 |

```figura id=reparto
pie: Siete caramelos entre dos personas: tres para cada una y sobra uno.
```

```programa id=dividir titulo="Tres maneras de dividir" ejecutar
Algoritmo Dividir
  Escribir 7 / 2, " ", 7 div 2, " ", 7 mod 2;
  Escribir -7 div 2, " ", -7 mod 2;
FinAlgoritmo
```

```salida
3.5 3 1
-3 -1
```

`div` recorta **hacia el cero**: `-7 div 2` es -3, no -4. Y `mod` se ajusta para que siempre se cumpla: dividendo = cociente × divisor + resto. Por eso `-7 mod 2` es -1.

`/` siempre devuelve un `Real`, aunque los dos números sean enteros. `div` y `mod` solo aceptan enteros.

::: limite
- Todo divisor cero detiene el programa con `divisionByZero`, también en `/` con reales.
- El entero más pequeño dividido entre -1 desborda (`integerOverflow`).
- El signo del resto coincide con el del dividendo.
:::

::: errores
```programa id=entre-cero titulo="Dividir entre cero" ejecutar termina=failed
Algoritmo EntreCero
  Definir divisor Como Entero <- 0;
  Escribir 10 / divisor;
FinAlgoritmo
```

```diagnosticos
divisionByZero
```
:::

::: resumen
- `/` divide de verdad y da un real.
- `div` da el cociente entero, recortado hacia el cero.
- `mod` da el resto, con el signo del dividendo.
- Dividir entre cero detiene el programa.
:::

::: vease
- [Operadores aritméticos](#expresiones.aritmeticos)
- [Matemáticas y redondeo](#biblioteca.matematicas)
:::
