---
id: biblioteca.conversion
numero: "12.3"
tipo: concepto
titulo: Conversiones
anclas: [LIB.CORE.CONVERSION#R1, LIB.CORE.CONVERSION#R2]
fichas: [help.builtin-conversion, help.pgs08.text_decimals]
diagnosticos: [stringToNumberConversionFailed, decimalPlacesOutOfRange]
terminos: [conversión]
---

::: frase
Las conversiones cambian un valor de tipo de forma explícita: de número a texto, de texto a número, o de real a texto con un número fijo de decimales.
:::

## Cómo funciona {#funciona}

PseudoLearn nunca convierte por su cuenta. Cuando hace falta, se pide:

| Función | Convierte |
|---|---|
| `ATexto(v)` | cualquier primitivo a `Cadena`, con el mismo formato que `Escribir` |
| `AEntero(t)` | una cadena decimal a `Entero` |
| `AReal(t)` | una cadena decimal a `Real` |
| `Decimales(x, n)` | un número a texto con exactamente `n` decimales |

```figura id=conversiones
pie: Las conversiones van y vuelven entre texto y números. Si el texto no es un número, la conversión falla en vez de inventar un cero.
```

```programa id=conversiones titulo="Convertir en ambos sentidos" ejecutar
Algoritmo Conversiones
  Escribir ATexto(12) + "!", " ", AEntero("42") + 1, " ", AReal("2.5") * 2;
  Escribir Decimales(3.14159, 2), " ", Decimales(2.5, 0), " ", Decimales(-0.001, 1);
FinAlgoritmo
```

```salida
12! 43 5.0
3.14 3 -0.0
```

`Decimales` redondea los empates alejándose de cero, conserva el signo —por eso `-0.001` con un decimal es `-0.0`— y no usa separadores de miles.

::: errores
```programa id=convertir-mal titulo="Un texto que no es un número" ejecutar termina=failed
Algoritmo Mal
  Escribir AEntero("doce");
FinAlgoritmo
```

```diagnosticos
stringToNumberConversionFailed
```
:::

::: resumen
- Toda conversión es explícita.
- `ATexto`, `AEntero` y `AReal` van entre texto y números.
- Un texto que no es número falla; no se convierte en cero.
- `Decimales` fija los decimales de un número.
:::

::: vease
- [Concatenación](#expresiones.concatenacion)
- [Formato de los valores](#tipos.primitivos)
:::
