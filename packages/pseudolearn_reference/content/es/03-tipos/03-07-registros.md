---
id: tipos.registros
numero: "3.7"
tipo: tipo
titulo: Registros
anclas: [LANG.TYPES.RECORD]
fichas: [help.record, help.pgl01.record_array_element]
diagnosticos: [recordCannotBeWritten, argumentCountMismatch, recursiveRecordContainment, recordWithoutFields]
terminos: [registro, campo, copia por valor]
---

::: frase
Un registro agrupa varios datos con nombre en un solo valor, como una ficha con sus apartados; al asignarlo se copia entero.
:::

## Cómo se escribe {#escribe}

```forma
Registro «Nombre»
  Definir «campo» Como «tipo»;
  …
FinRegistro
```

## Cómo funciona {#funciona}

Un **registro** se declara fuera del algoritmo, con un nombre y sus **campos**. Después se usa como un tipo más: se construye escribiendo su nombre con un valor por campo, en el orden en que se declararon, y cada campo se lee o se cambia con un punto.

```programa id=alumno titulo="La ficha de un alumno" ejecutar
Registro Alumno
  Definir nombre Como Cadena;
  Definir nota Como Real;
FinRegistro
Algoritmo Ficha
  Definir ana Como Alumno <- Alumno("Ana", 8.5);
  ana.nota <- ana.nota + 1;
  Escribir ana.nombre, ": ", ana.nota;
FinAlgoritmo
```

```salida
Ana: 9.5
```

## Se copia por valor {#copia}

Un registro es un **valor**, no una referencia. Asignarlo, pasarlo a un subprograma o devolverlo copia todos sus campos. Cambiar la copia no cambia el original.

```programa id=copia titulo="Cada variable tiene su propia ficha" ejecutar
Registro Casilla
  Definir fila, columna Como Entero;
FinRegistro
Algoritmo Tablero
  Definir a Como Casilla <- Casilla(1, 2);
  Definir b Como Casilla <- a;
  b.fila <- 10;
  Escribir a.fila, " ", b.fila, " ", a = b;
FinAlgoritmo
```

```salida
1 10 Falso
```

```figura id=registro-copia
pie: Asignar un registro hace una copia. Las dos fichas empiezan iguales, pero a partir de ahí cambian por separado.
```

Dos registros del mismo tipo son iguales si todos sus campos lo son. Un registro no puede contenerse a sí mismo, ni directa ni indirectamente.

::: limite
- Al menos un campo; como máximo 65535 hojas (campos que no son registros, contando los anidados).
- Un registro de más de 1024 hojas no puede ser elemento de un arreglo.
- Campos admitidos: tipos primitivos, enumerados, clases y otros registros.
- Escribir un registro entero no está permitido; se escriben sus campos.
:::

::: errores
Un registro no se escribe de una vez:

```programa id=escribir-registro titulo="Escribir la ficha entera" ejecutar
Registro Casilla
  Definir fila, columna Como Entero;
FinRegistro
Algoritmo EscribirRegistro
  Escribir Casilla(1, 2);
FinAlgoritmo
```

```diagnosticos
recordCannotBeWritten
```

Y la construcción necesita un valor por campo:

```programa id=faltan titulo="Falta un campo" ejecutar
Registro Casilla
  Definir fila, columna Como Entero;
FinRegistro
Algoritmo Faltan
  Definir c Como Casilla <- Casilla(1);
FinAlgoritmo
```

```diagnosticos
argumentCountMismatch
```
:::

::: nota
`y` no puede ser el nombre de un campo: en el perfil español es la palabra reservada `Y`, y las palabras reservadas no distinguen mayúsculas.
:::

::: por-dentro
En la máquina, un registro ocupa varias casillas seguidas, una por hoja. Copiarlo es copiar esas casillas, sin crear nada en el montón. Por eso los registros pequeños son tan rápidos como las variables sueltas.

```ri programa=alumno
```
:::

::: resumen
- Un registro agrupa campos con nombre en un solo valor.
- Se construye con un valor por campo y se accede con punto.
- Se copia al asignar, pasar o devolver.
- Dos registros son iguales si todos sus campos lo son.
:::

::: vease
- [Clase](#objetos.clase)
- [Copia de objetos](#objetos.copia)
- [Designadores](#declaraciones.designadores)
:::
