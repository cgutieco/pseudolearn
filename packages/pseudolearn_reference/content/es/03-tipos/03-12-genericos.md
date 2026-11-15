---
id: tipos.genericos
numero: "3.12"
tipo: concepto
titulo: Genéricos
anclas: [LANG.TYPES.GENERIC#R1, LANG.TYPES.GENERIC#R2]
fichas: [help.pgl04.type_parameter, help.pgl04.generic_class]
diagnosticos: [typeArgumentCountMismatch, incompatibleOperandTypes]
terminos: [genérico, parámetro de tipo]
---

::: frase
Un genérico es un subprograma o un tipo escrito una sola vez para cualquier tipo: el tipo concreto se rellena al usarlo.
:::

## Cómo funciona {#funciona}

A veces la misma idea sirve para muchos tipos: una caja que guarda un valor, un subprograma que devuelve lo que recibe. Con un **parámetro de tipo**, escrito entre `<` y `>` tras el nombre, se escribe una sola versión.

```programa id=identidad titulo="Un subprograma para cualquier tipo" ejecutar
SubProceso identidad<T>(valor Como T) Como T
  Retornar valor;
FinSubProceso
Algoritmo Identidad
  Escribir identidad(4);
  Escribir identidad(2.5);
  Escribir identidad("hola");
FinAlgoritmo
```

```salida
4
2.5
hola
```

El motor **infiere** el tipo `T` en cada llamada a partir de los argumentos. También pueden ser genéricos los registros, las clases, las interfaces y las variantes:

```programa id=caja titulo="Una caja genérica" ejecutar
Registro Caja<T>
  Definir contenido Como T;
FinRegistro
SubProceso abrir<T>(c Como Caja<T>) Como T
  Retornar c.contenido;
FinSubProceso
Algoritmo Cajas
  Definir numeros Como Caja<Entero> <- Caja(7);
  Escribir abrir(numeros), " ", abrir(Caja("x"));
FinAlgoritmo
```

```salida
7 x
```

```figura id=generico
pie: Una plantilla con un hueco de tipo. Cada uso la rellena con un tipo concreto y obtiene una versión propia.
```

## Lo que se puede hacer con un valor de tipo T {#opaco}

Dentro del genérico, `T` es **opaco**: el motor no sabe qué tipo será, así que solo permite copiar, pasar, devolver y guardar el valor. Sumarlo, compararlo o escribirlo es un error en la propia definición, aunque todas las llamadas usaran números.

```programa id=mayor titulo="Comparar dos valores de tipo T" ejecutar
SubProceso mayor<T>(a Como T, b Como T) Como T
  Si a > b Entonces
    Retornar a;
  FinSi
  Retornar b;
FinSubProceso
Algoritmo Mayor
  Escribir mayor(1, 2);
FinAlgoritmo
```

```diagnosticos
incompatibleOperandTypes
```

::: resumen
- Un parámetro de tipo `<T>` permite escribir una sola versión para muchos tipos.
- El tipo concreto se infiere en cada llamada o se escribe entre `<` y `>`.
- Dentro del genérico, `T` solo se copia, pasa, devuelve y guarda.
- Registros, subprogramas, clases, interfaces y variantes pueden ser genéricos.
:::

::: vease
- [Funciones como valores](#tipos.funciones)
- [Interfaces](#objetos.interfaces)
:::
