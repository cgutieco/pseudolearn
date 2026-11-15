---
id: objetos.copia
numero: "9.6"
tipo: concepto
titulo: Copia, referencias e identidad
anclas: [LANG.CLASS.COPY#R1, LIB.CORE.COPY#R1, MEM.IDENTITY#R1, MEM.IDENTITY#R2, MEM.IDENTITY#R3, MEM.IDENTITY#R4, MEM.VALUE.COPY#R1, MEM.VALUE.COPY#R2, MEM.VALUE.COPY#R3, MEM.VALUE.COPY#R4]
fichas: [help.builtin-copy]
diagnosticos: [incompatibleArgumentType]
terminos: [referencia, identidad, copia superficial]
---

::: frase
Asignar un objeto no lo duplica: da otro nombre al mismo objeto. Para tener un objeto nuevo con los mismos datos hace falta `Copiar`.
:::

## Cómo funciona {#funciona}

No todos los valores se comportan igual al asignarlos:

| Valor | Al asignar o pasar por valor |
|---|---|
| números, lógicos, caracteres y textos | se **copia**: cambiar el origen no afecta a la copia |
| objetos | se **comparte**: los dos nombres ven el mismo objeto |
| arreglos | se pasan por referencia |

`Copiar(objeto)` crea un objeto **nuevo** de la misma clase sin ejecutar el constructor, y copia **un solo nivel**: los atributos primitivos se copian, y los que son referencias siguen compartidos con el original.

```programa id=copias titulo="Un alias y una copia" ejecutar
Clase Mochila
  Definir dueno Como Cadena;
  Definir libros Como Entero;
FinClase

Algoritmo Copias
  Definir a Como Mochila <- Nuevo Mochila();
  a.dueno <- "Ana";
  a.libros <- 3;
  Definir alias Como Mochila <- a;
  Definir copia Como Mochila <- Copiar(a);
  alias.libros <- 5;
  copia.libros <- 9;
  Escribir a.libros, " ", alias.libros, " ", copia.libros;
  Escribir a = alias, " ", a = copia;
FinAlgoritmo
```

```salida
5 5 9
Verdadero Falso
```

```figura id=alias-copia
pie: `a` y `alias` señalan el mismo objeto; `copia` señala otro con los mismos datos al principio.
paso: `alias <- a` no crea nada: dos flechas al mismo objeto.
paso: `Copiar(a)` crea un segundo objeto con los mismos valores.
paso: Cambiar `alias.libros` se ve por `a`; cambiar `copia.libros`, no.
```

## Identidad {#identidad}

Cada objeto o arreglo tiene una **identidad**: el número de orden en que se creó durante la ejecución. El primero es el 1, el siguiente el 2, y así. La identidad no cambia nunca ni se reutiliza, aunque el objeto deje de usarse. `=` entre objetos compara identidades: por eso `a = copia` es `Falso` aunque tengan los mismos datos.

Los ciclos de referencias —un objeto que apunta a otro que apunta al primero— son válidos.

::: resumen
- Los primitivos y los textos se copian; los objetos se comparten.
- `Copiar` crea un objeto nuevo y copia un solo nivel.
- La identidad es el orden de creación y nunca se reutiliza.
- `=` entre objetos compara identidad, no contenido.
:::

::: vease
- [Clases y atributos](#objetos.clase)
- [Parámetros](#subprogramas.parametros)
- [Memoria](#motor.memoria)
:::
