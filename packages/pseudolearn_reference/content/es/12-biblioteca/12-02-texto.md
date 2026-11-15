---
id: biblioteca.texto
numero: "12.2"
tipo: concepto
titulo: Funciones de texto
anclas: [LIB.CORE.TEXT#R1, LIB.CORE.TEXT#T1, LIB.CORE.TEXT#T2, LIB.CORE.TEXT#T3, LIB.CORE.TEXT#T4, LIB.CORE.TEXT#T5]
fichas: [help.builtin-text]
diagnosticos: [stringPositionOutOfRange, invalidCharacterCode, invalidPaddingText, paddingWidthOutOfRange]
terminos: [punto de código, subcadena]
---

::: frase
Las funciones de texto miden, recortan, buscan y transforman cadenas sin modificar nunca la original: siempre devuelven una nueva.
:::

## Cómo funciona {#funciona}

Todas trabajan por **puntos de código**: cada carácter Unicode cuenta como uno, lleve tilde o no. Las posiciones empiezan en **cero**.

| Función | Qué devuelve |
|---|---|
| `Longitud(t)` | cuántos caracteres tiene |
| `Subcadena(t, desde, hasta)` | el trozo entre dos posiciones, ambas incluidas |
| `Recortar(t)` | sin espacios al principio ni al final |
| `AMayusculas(t)`, `AMinusculas(t)` | con todas las letras cambiadas |
| `Contiene`, `EmpiezaCon`, `TerminaCon` | un `Logico` |
| `PosicionDe(t, parte)` | `Algo(posición)` o `Nada` |
| `Reemplazar(t, buscar, poner)` | con todas las apariciones cambiadas |
| `Dividir(t, separador)`, `Unir(v, separador)` | un vector de trozos, o el texto unido |
| `CaracterEn`, `CodigoDe`, `CaracterDesde` | un carácter o su código Unicode |
| `RellenarIzquierda`, `RellenarDerecha` | el texto completado hasta un ancho |

```figura id=subcadena-posiciones
pie: Las posiciones empiezan en cero y `Subcadena` incluye las dos que recibe: `Subcadena(t, 0, 3)` son los cuatro primeros caracteres.
```

```programa id=textos titulo="Un recorrido por las funciones de texto" ejecutar
Algoritmo Textos
  Definir frase Como Cadena <- "  Hola, mundo  ";
  Definir limpia Como Cadena <- Recortar(frase);
  Escribir "[", limpia, "] ", Longitud(limpia);
  Escribir Subcadena(limpia, 0, 3), " ", AMayusculas(limpia), " ", AMinusculas("ÁRBOL");
  Escribir Contiene(limpia, "mundo"), " ", EmpiezaCon(limpia, "Ho"), " ", TerminaCon(limpia, "x");
  Escribir Reemplazar(limpia, "o", "0"), " ", CaracterEn(limpia, 1), " ", CodigoDe('A'), " ", CaracterDesde(97);
  Escribir RellenarIzquierda("7", 3, '0'), " ", RellenarDerecha("ab", 4, '.'), "|";
  Escribir Unir(Dividir("a,b,c", ","), " - ");
FinAlgoritmo
```

```salida
[Hola, mundo] 11
Hola HOLA, MUNDO árbol
Verdadero Verdadero Falso
H0la, mund0 o 65 a
007 ab..|
a - b - c
```

::: limite
- Una posición fuera del texto detiene el programa con `stringPositionOutOfRange`.
- `CaracterDesde` solo acepta códigos Unicode válidos: de 0 a 1114111, sin el tramo 55296 a 57343.
- Los cambios de mayúsculas siguen Unicode completo: `ß` pasa a `SS`.
:::

::: resumen
- Las funciones de texto devuelven cadenas nuevas.
- Cuentan caracteres Unicode y numeran desde cero.
- `Subcadena` incluye las dos posiciones.
:::

::: vease
- [Concatenación](#expresiones.concatenacion)
- [Conversión](#biblioteca.conversion)
:::
