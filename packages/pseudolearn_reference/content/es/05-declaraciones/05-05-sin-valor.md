---
id: declaraciones.sin-valor
numero: "5.5"
tipo: concepto
titulo: Variables sin valor
anclas: [LANG.DECL.UNINITIALIZED#R1, LANG.DECL.UNINITIALIZED#R2, LANG.DECL.UNINITIALIZED#R3, LANG.DECL.UNINITIALIZED#R4, LANG.DECL.UNINITIALIZED#R5, LANG.DECL.UNINITIALIZED#R6]
diagnosticos: [variableUsedUninitialized, uninitializedVariableRead, bindingOutsideScope, bindingReadsOwnInitializer]
terminos: [inicialización, camino de ejecución]
---

::: frase
Antes de ejecutar, el motor recorre todos los caminos posibles del programa y rechaza leer una variable a la que algún camino no le ha dado valor.
:::

## Cómo funciona {#funciona}

Una variable declarada sin valor inicial está vacía. No vale 0 ni nada parecido. Leerla en un punto al que algún camino llega sin haberle dado valor es el error `variableUsedUninitialized`, y se detecta **antes de ejecutar**.

```programa id=sin-rama titulo="Una rama que no da valor" ejecutar
Proceso SinValor
  Definir premio Como Entero;
  Definir puntos Como Entero <- 40;
  Si puntos > 50 Entonces
    premio <- 10;
  FinSi
  Escribir premio;
FinProceso
```

```diagnosticos
variableUsedUninitialized
```

Da igual que `puntos` valga 40: el motor no ejecuta para decidir, mira los caminos. Hay un camino —el de la condición falsa— que llega al `Escribir` con `premio` vacía.

```figura id=caminos-valor
pie: Los dos caminos que salen del `Si` llegan al `Escribir`. Por uno de ellos `premio` sigue vacía.
paso: Antes del `Si`, `premio` está vacía.
paso: Por la rama verdadera, `premio` recibe 10.
paso: Por la rama falsa no hay ninguna asignación: `premio` sigue vacía.
paso: Los caminos se juntan. Como uno llega sin valor, leer `premio` es un error.
```

Basta con dar valor en **todos** los caminos:

```programa id=con-rama titulo="Las dos ramas dan valor" ejecutar
Proceso ConValor
  Definir premio Como Entero;
  Definir puntos Como Entero <- 40;
  Si puntos > 50 Entonces
    premio <- 10;
  Sino
    premio <- 0;
  FinSi
  Escribir premio;
FinProceso
```

```salida
0
```

## Las causas {#causas}

El mensaje del error dice **por qué** falta el valor:

| Causa | Situación |
|---|---|
| ningún camino asigna | la variable nunca recibió valor antes |
| condición sin `Sino` | solo la rama verdadera asigna |
| rama sin asignación | alguna rama de `Si`, `Segun` o `Elegir` no asigna |
| el bucle puede no ejecutarse | solo el cuerpo de `Mientras`, `Para` o `Para Cada` asigna |
| `Segun` sin `De Otro Modo` | un valor del selector no entra en ninguna rama |

```programa id=bucle-sin-valor titulo="Un bucle que podría no ejecutarse" ejecutar
Proceso Bucle
  Definir ultimo Como Entero;
  Definir i Como Entero <- 0;
  Mientras i < 3 Hacer
    ultimo <- i;
    i <- i + 1;
  FinMientras
  Escribir ultimo;
FinProceso
```

```diagnosticos
variableUsedUninitialized
```

`Repetir` es distinto: su cuerpo se ejecuta al menos una vez, así que lo que asigna cuenta después del bucle. Y `Retornar` o `Salir` cortan su camino: ese camino ya no exige nada.

::: limite
Los campos de un registro local se siguen uno por uno. Las casillas de los arreglos y los atributos de los objetos no se siguen: leer una que está vacía se descubre al ejecutar, con la trampa `uninitializedVariableRead`.
:::

::: resumen
- Una variable sin valor inicial empieza vacía.
- Leerla donde algún camino la deja vacía es un error antes de ejecutar.
- El mensaje explica la causa: rama, bucle o `Segun` incompleto.
- `Repetir` siempre ejecuta su cuerpo una vez.
:::

::: vease
- [Declarar variables con Definir](#declaraciones.definir)
- [La decisión Si](#control.si)
- [Mientras](#control.mientras)
:::
