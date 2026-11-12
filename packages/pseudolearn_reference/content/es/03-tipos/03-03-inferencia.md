---
id: tipos.inferencia
numero: "3.3"
tipo: concepto
titulo: "Inferencia: el tipo siempre se declara"
anclas: [LANG.TYPES.INFERENCE#R1]
diagnosticos: [undeclaredVariable]
terminos: [inferencia, declaración]
---

::: frase
En PseudoLearn ninguna variable adivina su tipo: cada una se declara con `Definir` y un tipo explícito antes de usarse.
:::

## Cómo funciona {#funciona}

Algunos lenguajes deducen el tipo de una variable a partir del primer valor que recibe. PseudoLearn no: la **declaración** es obligatoria y el tipo se escribe siempre. El valor inicial es opcional y nunca decide el tipo.

```figura id=declarar-antes
pie: Primero se declara la caja con su forma; después se pueden guardar valores. Una asignación nunca crea una caja nueva.
```

```programa id=declarar titulo="Declarar y después asignar" ejecutar
Algoritmo Declarar
  Definir total Como Entero;
  total <- 10;
  total <- total * 2;
  Escribir total;
FinAlgoritmo
```

```salida
20
```

Asignar a un nombre que nadie declaró no crea una variable: es un error. Así una errata como `contdor` en lugar de `contador` se descubre antes de ejecutar, en vez de crear en silencio una variable nueva.

```programa id=sin-declarar titulo="Asignar sin declarar" ejecutar
Algoritmo SinDeclarar
  contador <- 1;
FinAlgoritmo
```

```diagnosticos
undeclaredVariable
```

::: nota
¿Por qué un lenguaje pensado para aprender exige declarar? La respuesta corta: una declaración es una promesa que el motor puede comprobar, y las erratas en nombres de variables son de los errores más difíciles de encontrar a ojo.
:::

::: resumen
- Toda variable se declara con `Definir` y un tipo explícito.
- El valor inicial es opcional y no decide el tipo.
- Asignar a un nombre no declarado es un error, no una declaración.
:::

::: vease
- [Definir](#declaraciones.definir)
- [Variables sin valor](#declaraciones.sin-valor)
:::
