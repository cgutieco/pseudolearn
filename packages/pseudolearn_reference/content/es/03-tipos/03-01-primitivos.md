---
id: tipos.primitivos
numero: "3.1"
tipo: tipo
titulo: Tipos primitivos
anclas: [LANG.TYPES.INTEGER, LANG.TYPES.REAL#R1, LANG.TYPES.BOOLEAN#R1, LANG.TYPES.CHARACTER#R1, LANG.TYPES.TEXT#R1, LANG.IO.VALUE-FORMAT#R1]
diagnosticos: [integerOverflow, realEqualityComparison, noOrderBetweenBooleans, incompatibleTypesInAssignment, cannotConcatenateNumberWithText, nonFiniteRealResult, invalidCharacterCode]
terminos: [tipo, Entero, Real, Logico, Caracter, Cadena]
---

::: frase
Cada dato tiene un tipo que dice qué valores puede guardar y qué se puede hacer con él; PseudoLearn tiene cinco tipos primitivos y con ellos se construyen todos los demás.
:::

## Cómo se escribe {#escribe}

```forma
Definir «nombre» Como Entero
Definir «nombre» Como Real
Definir «nombre» Como Logico
Definir «nombre» Como Caracter
Definir «nombre» Como Cadena
```

```figura id=tipos-cajas
pie: Los cinco tipos primitivos. Dos guardan números, uno una respuesta de sí o no y dos guardan texto: un símbolo suelto o una fila de símbolos.
```

## Cómo funciona {#funciona}

Una variable se declara con `Definir`, su nombre, la palabra `Como` y su tipo. Desde ese momento solo acepta valores de ese tipo, y su tipo no cambia mientras el programa se ejecuta.

```programa id=ficha titulo="La ficha de Lucía" ejecutar
Algoritmo FichaDeLucia
  Definir edad Como Entero <- 11;
  Definir altura Como Real <- 1.42;
  Definir inicial Como Caracter <- 'L';
  Definir nombre Como Cadena <- "Lucía";
  Definir aprobada Como Logico <- Verdadero;
  Escribir nombre + " (" + inicial + ")";
  Escribir edad, " años, ", altura, " m";
  Escribir aprobada;
FinAlgoritmo
```

```salida
Lucía (L)
11 años, 1.42 m
Verdadero
```

| Tipo | Qué guarda | Valores de ejemplo |
|---|---|---|
| `Entero` | Un número sin decimales | `0`, `42`, `-7` |
| `Real` | Un número con parte decimal | `3.14`, `0.5`, `-2.0` |
| `Logico` | La respuesta a una pregunta de sí o no | `Verdadero`, `Falso` |
| `Caracter` | Un único símbolo | `'A'`, `"7"` |
| `Cadena` | Una fila de símbolos, incluso vacía | `"Hola"`, `""` |

::: analogia
Piensa en el tipo como la forma de un recipiente: en una huevera caben huevos y en una botella, líquido. No puedes guardar sopa en la huevera aunque las dos sirvan para guardar. La analogía deja de valer en un punto: algunos valores sí pasan solos de un recipiente a otro, siempre que no se pierda nada.
:::

## `Entero` {#entero}

Un `Entero` es un número sin parte decimal. Las operaciones con enteros dan el resultado **exacto** mientras quepa en el rango. Salirse del rango no da la vuelta en silencio: el programa se detiene.

## `Real` {#real}

Un `Real` es un número con parte decimal. Al escribirse muestra siempre al menos un decimal, para que se distinga de un entero a simple vista.

```programa id=precios titulo="Los reales muestran su punto" ejecutar
Algoritmo Precios
  Definir precio Como Real <- 7;
  Escribir precio;
  Escribir 0.1 + 0.2;
FinAlgoritmo
```

```salida
7.0
0.30000000000000004
```

La segunda línea sorprende a casi todo el mundo. No es un fallo del motor: así funcionan los reales en cualquier computadora. Un `Real` no puede guardar cualquier número; guarda la marca más cercana de una regla finísima, pero con huecos.

```figura id=regla-reales
pie: La regla con huecos. 0.3 y 0.1 + 0.2 caen en marcas vecinas de la regla, así que no son el mismo número.
```

## `Logico` {#logico}

Un `Logico` tiene exactamente dos valores, `Verdadero` y `Falso`. Es el tipo de toda pregunta: `edad >= 18` no es un número, es un `Logico`. No es un número, no tiene orden y no se convierte solo en texto. Al escribirse aparece con la palabra del perfil: `Verdadero` en español y `true` en inglés.

## `Caracter` y `Cadena` {#texto}

Un `Caracter` es un único símbolo: una letra, una cifra, un signo, un espacio o un emoji. Una `Cadena` es una fila de caracteres que puede estar vacía. Las posiciones dentro de una cadena se cuentan desde cero.

```programa id=textos titulo="Medir y mirar dentro de un texto" ejecutar
Algoritmo Textos
  Definir cara Como Caracter <- "😀";
  Escribir Longitud(""), " ", Longitud("año"), " ", CaracterEn("Hola", 0);
  Escribir cara, " ", CodigoDe(cara), " ", CaracterDesde(76);
FinAlgoritmo
```

```salida
0 3 H
😀 128512 L
```

## Pasar de un tipo a otro {#conversiones}

El lenguaje solo convierte un valor por su cuenta cuando es imposible perder información: de `Entero` a `Real` y de `Caracter` a `Cadena`. Todo lo demás se pide con una función, porque la decisión de cómo convertir es de quien escribe el programa.

```programa id=conversiones titulo="Conversiones pedidas" ejecutar
Algoritmo Conversiones
  Definir nota Como Real <- -8.7;
  Escribir trunc(nota), " ", redon(nota), " ", ATexto(1.5) + "!";
FinAlgoritmo
```

```salida
-8 -9 1.5!
```

`trunc` corta los decimales hacia el cero y `redon` redondea al entero más cercano. Con `-8.7` dan resultados distintos, y por eso el lenguaje no elige por ti.

::: limite
- `Entero`: 64 bits con signo, de -9223372036854775808 a 9223372036854775807, ambos incluidos. Salirse produce `integerOverflow`.
- `Real`: binario de coma flotante de 64 bits (IEEE 754 binario64), siempre finito. Cada operación redondea al representable más cercano y, en empate, al de mantisa par. Un infinito o un «no es un número» detiene el programa con `nonFiniteRealResult`. Existen 0.0 y -0.0.
- `Caracter`: un punto de código Unicode entre 0 y 1114111, excepto los sustitutos de 55296 a 57343.
- `Cadena`: sin longitud máxima fijada por el lenguaje; cuenta puntos de código, no letras visibles.
:::

::: errores
Pasarse del máximo de un entero detiene el programa sin escribir nada:

```programa id=desborde titulo="Pasarse del máximo" ejecutar termina=failed
Algoritmo Desborde
  Definir grande Como Entero <- 9223372036854775807;
  Escribir grande + 1;
FinAlgoritmo
```

```diagnosticos
integerOverflow
```

Comparar reales con `=` funciona, pero el motor avisa, porque dos cálculos que deberían coincidir pueden caer en marcas vecinas:

```programa id=comparar titulo="Comparar reales con =" ejecutar
Algoritmo Comparar
  Definir a Como Real <- 0.1 + 0.2;
  Si a = 0.3 Entonces
    Escribir "iguales";
  Sino
    Escribir "distintos";
  FinSi
FinAlgoritmo
```

```salida
distintos
```

```diagnosticos
realEqualityComparison
```

Un número no se pega a un texto con `+`; hay que convertirlo o separar con comas:

```programa id=mezcla titulo="Un número no se pega a un texto" ejecutar
Algoritmo Mezcla
  Escribir "Tengo " + 11;
FinAlgoritmo
```

```diagnosticos
cannotConcatenateNumberWithText
```

Y un real no entra solo en un entero:

```programa id=sin-perder titulo="Un real no entra en un entero" ejecutar
Algoritmo SinPerder
  Definir cantidad Como Entero <- 2.5;
FinAlgoritmo
```

```diagnosticos
incompatibleTypesInAssignment
```
:::

::: por-dentro
Antes de ejecutar, el motor traduce el programa a su representación intermedia. Cada constante dice qué clase de valor produce: `i64` (entero de 64 bits), `f64` (real), `char`, `str` y `bool`. Como el tipo de cada valor se conoce al compilar, la máquina virtual no pregunta «¿qué eres?» en cada paso.

```ri programa=ficha
```

Los cuatro tipos de tamaño fijo caben en una casilla de la máquina; una cadena puede medir cualquier cosa, así que vive en el montón y la casilla guarda solo una referencia.
:::

::: nota
- «Un número entre comillas es un número»: `"7"` es un `Caracter` y `"75"` una `Cadena`. Predice el tipo antes de ejecutar.
- «`/` entre enteros da entero»: en PseudoLearn siempre da real.
- «0.1 + 0.2 = 0.3»: no es una rareza del lenguaje; la figura de la regla muestra por qué pasa.
:::

::: resumen
- Hay cinco tipos primitivos: `Entero`, `Real`, `Logico`, `Caracter` y `Cadena`.
- El tipo de una variable no cambia nunca.
- Un `Entero` es exacto dentro de su rango; salirse detiene el programa.
- Un `Real` guarda la marca más cercana de una regla finita y siempre muestra un decimal.
- Un `Logico` no es un número ni tiene orden.
- Solo pasan solos `Entero` a `Real` y `Caracter` a `Cadena`.
:::

::: vease
- [Literales numéricos](#lexico.numeros)
- [Relaciones entre tipos](#tipos.relaciones)
- [División, div y mod](#expresiones.division)
- [Conversión](#biblioteca.conversion)
:::
