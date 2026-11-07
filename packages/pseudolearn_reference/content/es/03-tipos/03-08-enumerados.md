---
id: tipos.enumerados
numero: "3.8"
tipo: tipo
titulo: Enumerados
anclas: [LANG.TYPES.ENUM]
fichas: [help.enum]
diagnosticos: [undefinedEnumMember, duplicateEnumMember, incompatibleOperandTypes]
terminos: [enumerado, miembro]
---

::: frase
Un enumerado es un tipo con una lista cerrada de valores con nombre, como los colores de un semáforo.
:::

## Cómo se escribe {#escribe}

```forma
Enumerado «Nombre»
  «miembro», «miembro», …
FinEnumerado
```

```railes produccion=enumUnit
```

## Cómo funciona {#funciona}

Un **enumerado** declara un tipo nuevo cuyos únicos valores son los **miembros** de la lista. Cada miembro se escribe con el nombre del tipo, un punto y su nombre. Una variable de ese tipo solo puede guardar uno de esos miembros, así que no hay valores inventados ni errores de escritura que pasen desapercibidos.

```programa id=semaforo titulo="Un semáforo con nombre" ejecutar
Enumerado Semaforo
  Rojo, Amarillo, Verde
FinEnumerado
Algoritmo Cruce
  Definir luz Como Semaforo <- Semaforo.Verde;
  Si luz = Semaforo.Verde Entonces
    Escribir "Cruzar con ", luz;
  FinSi
FinAlgoritmo
```

```salida
Cruzar con Verde
```

```figura id=enumerado
pie: Un enumerado es una lista cerrada. Una variable del tipo solo puede apuntar a uno de sus miembros.
```

Los enumerados combinan muy bien con `Segun`, que puede tener un caso por miembro:

```programa id=segun-enumerado titulo="Un caso por color" ejecutar
Enumerado Semaforo
  Rojo, Amarillo, Verde
FinEnumerado
Algoritmo Indicacion
  Definir luz Como Semaforo <- Semaforo.Amarillo;
  Segun luz Hacer
    Semaforo.Rojo: Escribir "Para";
    Semaforo.Amarillo: Escribir "Precaución";
    Semaforo.Verde: Escribir "Adelante";
  FinSegun
FinAlgoritmo
```

```salida
Precaución
```

::: limite
- Cada miembro tiene un ordinal interno de 32 bits desde 0, en orden de declaración, pero el programa no puede convertirlo a número.
- Un enumerado puede estar vacío o tener un solo miembro.
- Solo admite `=` y `<>`; no tiene orden ni aritmética.
- `Escribir` muestra el nombre del miembro tal como se declaró.
:::

::: errores
Un miembro que no existe se detecta antes de ejecutar:

```programa id=azul titulo="Un color que no existe" ejecutar
Enumerado Semaforo
  Rojo, Amarillo, Verde
FinEnumerado
Algoritmo Azul
  Definir luz Como Semaforo <- Semaforo.Azul;
FinAlgoritmo
```

```diagnosticos
undefinedEnumMember
```

Y los miembros no se ordenan:

```programa id=orden-enum titulo="Comparar con menor que" ejecutar
Enumerado Semaforo
  Rojo, Amarillo, Verde
FinEnumerado
Algoritmo OrdenEnum
  Escribir Semaforo.Rojo < Semaforo.Verde;
FinAlgoritmo
```

```diagnosticos
incompatibleOperandTypes
```
:::

::: por-dentro
Al ejecutar, un miembro es solo su ordinal: un entero pequeño en una casilla. El nombre se recupera de la declaración cuando hace falta escribirlo. Comparar dos miembros es comparar dos enteros.

```ri programa=semaforo
```
:::

::: resumen
- Un enumerado es un tipo con una lista cerrada de miembros.
- Los miembros se escriben `Tipo.miembro`.
- Solo admiten igualdad y desigualdad.
- Funcionan muy bien con `Segun`.
:::

::: vease
- [Variantes](#tipos.variantes)
- [Segun](#control.segun)
:::
