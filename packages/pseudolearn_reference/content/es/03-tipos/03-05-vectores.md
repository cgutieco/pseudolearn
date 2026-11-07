---
id: tipos.vectores
numero: "3.5"
tipo: tipo
titulo: Vectores
anclas: [LANG.TYPES.VECTOR]
fichas: [construction.vector, help.pgs02.vector_sort, help.pgs02.vector_contains]
diagnosticos: [arrayIndexOutOfRange, collectionCannotBeWritten, collectionLimitExceeded]
terminos: [vector, colección, referencia compartida]
---

::: frase
Un vector es una lista que crece y se encoge mientras el programa se ejecuta; todos sus elementos son del mismo tipo.
:::

## Cómo se escribe {#escribe}

```forma
Definir «nombre» Como Vector<«tipo»> <- Vector();
«nombre».Agregar(«valor»);
«nombre».Insertar(«posición», «valor»);
«nombre».Eliminar(«posición»);
«nombre»[«posición»]
```

## Cómo funciona {#funciona}

A diferencia de un arreglo, un **vector** no tiene un tamaño fijo. Empieza vacío y crece con `Agregar` (al final) o `Insertar` (en una posición); se encoge con `Eliminar`. Las posiciones se cuentan desde cero y `Longitud` dice cuántos elementos tiene.

```programa id=compra titulo="La lista de la compra" ejecutar
Algoritmo Compra
  Definir lista Como Vector<Cadena> <- Vector();
  lista.Agregar("pan");
  lista.Agregar("leche");
  lista.Insertar(0, "fruta");
  Escribir lista, " ", lista.Longitud();
  lista.Eliminar(1);
  lista.Ordenar();
  Escribir lista, " ", lista.Contiene("pan");
FinAlgoritmo
```

```salida
["fruta", "pan", "leche"] 3
["fruta", "leche"] Falso
```

```figura id=vector-crece
pie: Un vector crece y se encoge. Insertar desplaza a la derecha lo que ya había; eliminar cierra el hueco.
paso: El vector empieza vacío.
paso: `Agregar` pone «pan» al final y después «leche».
paso: `Insertar(0, …)` pone «fruta» al principio y desplaza el resto.
paso: `Eliminar(1)` quita la posición 1 y el resto se corre a la izquierda.
```

## Una referencia compartida {#referencia}

Un vector es una **referencia**: dos variables pueden apuntar al mismo vector. Si se modifica a través de una, la otra ve el cambio, porque no hay dos vectores sino uno.

```programa id=compartido titulo="Dos nombres, un solo vector" ejecutar
Algoritmo Compartido
  Definir a Como Vector<Entero> <- Vector();
  Definir b Como Vector<Entero> <- a;
  b.Agregar(5);
  Escribir a.Longitud(), " ", a;
FinAlgoritmo
```

```salida
1 [5]
```

Para obtener una copia independiente se usa `Copiar`.

## Métodos {#metodos}

| Método | Qué hace |
|---|---|
| `Agregar(x)` | Añade al final |
| `Insertar(i, x)` | Añade en la posición `i` (de 0 a la longitud) |
| `Eliminar(i)` | Quita la posición `i` |
| `Longitud()` | Cuántos elementos hay |
| `Ordenar()` | Ordena de menor a mayor; admite un comparador |
| `Invertir()` | Da la vuelta al orden |
| `Contiene(x)` | `Verdadero` si `x` está |
| `PosicionDe(x)` | `Algo(posición)` o `Nada` |

::: limite
- Posiciones: de 0 a `Longitud() - 1`. `Insertar` admite también `Longitud()` (al final).
- El orden natural de `Ordenar` vale para `Entero`, `Real`, `Caracter`, `Cadena` y `Logico` (`Falso` antes que `Verdadero`); es estable.
- El tamaño máximo lo fija el presupuesto de memoria del motor; superarlo produce `collectionLimitExceeded`.
- `Escribir` muestra los elementos entre corchetes separados por coma y espacio, con las cadenas entre comillas.
:::

::: errores
Leer o eliminar una posición que no existe detiene el programa:

```programa id=vacio titulo="Eliminar de un vector vacío" ejecutar termina=failed
Algoritmo Vacio
  Definir v Como Vector<Entero> <- Vector();
  v.Eliminar(0);
FinAlgoritmo
```

```diagnosticos
arrayIndexOutOfRange
```

Y un vector cuyos elementos no se pueden escribir no admite `Escribir`:

```programa id=no-imprimible titulo="Un vector de registros" ejecutar
Registro Caja
  Definir valor Como Entero;
FinRegistro
Algoritmo NoImprimible
  Definir cajas Como Vector<Caja> <- Vector();
  Escribir cajas;
FinAlgoritmo
```

```diagnosticos
collectionCannotBeWritten
```
:::

::: por-dentro
Un vector vive en el montón: la variable guarda una referencia. Su capacidad empieza en cero, pasa a uno y después se duplica cada vez que se llena, así que añadir al final es barato casi siempre. Cada cambio de estructura incrementa una versión interna que permite detectar si alguien lo modifica mientras se recorre.

```ri programa=compartido
```
:::

::: resumen
- Un vector crece y se encoge; todos sus elementos son del mismo tipo.
- Posiciones desde cero; salirse es un fallo.
- Es una referencia: asignarlo comparte el mismo vector.
- `Copiar` crea uno independiente.
:::

::: vease
- [Arreglos](#tipos.arreglos)
- [Para Cada](#control.para-cada)
- [Copia, referencias e identidad](#objetos.copia)
:::
