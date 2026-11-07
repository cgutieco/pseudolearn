---
id: programas.estructura
numero: "8.1"
tipo: concepto
titulo: Estructura de un programa
anclas: [LANG.PROGRAM.STRUCTURE#R1, LANG.PROGRAM.CLASSIC#R1, LANG.PROGRAM.CLASSIC#R2, LANG.PROGRAM.CLASSIC#R3]
fichas: [help.module-unit]
diagnosticos: [multipleAlgorithms, unexpectedTokenOutsideProgramUnit, expectedAlgorithmStart]
terminos: [algoritmo, unidad]
---

::: frase
Un programa es un texto con **un solo algoritmo** y, a su alrededor, las piezas que ese algoritmo usa: subprogramas, clases, registros, enumerados y constantes.
:::

## Cómo funciona {#funciona}

El nivel superior del texto solo admite **unidades**: bloques con nombre que se abren y se cierran. Ninguna sentencia ejecutable puede quedar suelta fuera de ellas.

```figura id=estructura-archivo
pie: Un archivo con su único algoritmo y sus unidades hermanas. Ninguna va dentro de otra, y el orden no importa.
```

| Unidad | Cuántas |
|---|---|
| `Algoritmo` o `Proceso` | exactamente una |
| `SubProceso`, `Funcion` | las que hagan falta |
| `Clase`, `Interfaz` | las que hagan falta |
| `Registro`, `Enumerado`, `Variante` | las que hagan falta |
| `Constante` | las que hagan falta |

Las unidades son **hermanas**: ninguna va dentro de otra. Pueden escribirse antes o después del algoritmo, en cualquier orden.

```programa id=tienda titulo="Un algoritmo con sus vecinos" ejecutar
Constante SALUDO Como Cadena <- "Hola";

Enumerado Color
  Rojo, Verde
FinEnumerado

Algoritmo Tienda
  Escribir SALUDO, " ", Precio(3);
FinAlgoritmo

SubProceso Precio(unidades Como Entero) Como Entero
  Retornar unidades * 5;
FinSubProceso
```

```salida
Hola 15
```

Un algoritmo vacío es válido y no hace nada. El nombre del algoritmo no ocupa el espacio de las variables: puede coincidir con el de una variable.

## Pseudocódigo clásico {#clasico}

Un programa escrito al estilo clásico —`Proceso`, `Definir` con varios nombres, `Leer`, `Escribir`, `Si`, `Segun`, bucles, `Dimension` y `Funcion` con variable de resultado— se analiza **sin ningún diagnóstico** y se ejecuta tal cual, también desde la terminal con `pseudo ejecutar`. Las únicas exigencias son las de siempre: punto y coma, índices desde cero y ninguna variable leída sin valor.

::: errores
Una sentencia fuera de toda unidad no pertenece a ningún sitio:

```programa id=sentencia-suelta titulo="Una sentencia suelta" ejecutar
Escribir "suelta";
Algoritmo Uno
FinAlgoritmo
```

```diagnosticos
unexpectedTokenOutsideProgramUnit
```

Y un texto no puede tener dos algoritmos:

```programa id=dos-algoritmos titulo="Dos algoritmos en un texto" ejecutar
Algoritmo Uno
FinAlgoritmo
Algoritmo Dos
FinAlgoritmo
```

```diagnosticos
multipleAlgorithms
```
:::

::: resumen
- Un texto tiene exactamente un algoritmo.
- Alrededor van unidades hermanas, en cualquier orden.
- No hay sentencias sueltas ni unidades anidadas.
- El pseudocódigo clásico funciona sin retoques.
:::

::: vease
- [Módulos y proyectos](#programas.modulos)
- [Declarar subprogramas](#subprogramas.declaracion)
- [Qué es PseudoLearn](#vision.que-es)
:::
