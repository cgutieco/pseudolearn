---
id: declaraciones.definir
numero: "5.1"
tipo: construccion
titulo: "Declarar variables con `Definir`"
anclas: [LANG.DECL.VARIABLE#R1]
fichas: [help.variables]
diagnosticos: [initializerWithMultipleNames, duplicateVariableDeclaration, bindingReadsOwnInitializer]
terminos: [variable, declaración, valor inicial]
---

::: frase
`Definir` crea variables: cajas con nombre y tipo donde el programa guarda un valor que puede cambiar.
:::

## Cómo se escribe {#escribe}

```forma
Definir «nombre» Como «tipo» ⟦<- «valor inicial»⟧;
Definir «nombre», «nombre» Como «tipo»;
```

::: partes
- `Definir` abre la declaración.
- «nombre» es un identificador. Una letra sola también vale.
- `Como` separa los nombres del tipo.
- «tipo» dice qué clase de valores puede guardar: `Entero`, `Real`, `Cadena`…
- `<-` y el «valor inicial» son opcionales, y solo se admiten con un único nombre.
- `;` termina la declaración.
:::

## Cómo funciona {#funciona}

Una **variable** es un nombre ligado a un lugar de la memoria. `Definir` crea ese lugar con el tipo indicado. Si lleva valor inicial, el valor se guarda en el momento; si no, la caja queda vacía hasta la primera asignación.

```programa id=mochila titulo="Variables de una mochila" ejecutar
Algoritmo Mochila
  Definir libros, cuadernos Como Entero;
  Definir nombre Como Cadena <- "Leo";
  libros <- 3;
  cuadernos <- libros * 2;
  Escribir nombre, " lleva ", libros, " libros y ", cuadernos, " cuadernos";
FinAlgoritmo
```

```salida
Leo lleva 3 libros y 6 cuadernos
```

```figura id=cajas-variables
pie: Cada `Definir` crea una caja con nombre y tipo. Las que no tienen valor inicial empiezan vacías.
paso: `Definir libros, cuadernos Como Entero;` crea dos cajas vacías.
paso: `Definir nombre Como Cadena <- "Leo";` crea una caja que ya tiene valor.
paso: `libros <- 3;` llena la primera caja.
paso: `cuadernos <- libros * 2;` lee `libros` y guarda 6.
```

Una caja vacía **no tiene un valor por defecto**: no vale 0 ni `""`. El motor comprueba antes de ejecutar que nunca se lea una variable que puede estar vacía.

Toda variable declarada con `Definir` se puede cambiar después. Para un valor que no cambia nunca existe [`Constante`](#declaraciones.constante).

::: errores
El valor inicial solo vale con un nombre. Con varios, no está claro a cuál se refiere:

```programa id=varios-nombres titulo="Valor inicial con dos nombres" ejecutar
Algoritmo Varios
  Definir a, b Como Entero <- 0;
  Escribir a;
FinAlgoritmo
```

```diagnosticos
initializerWithMultipleNames
```

Un nombre solo puede declararse una vez en el mismo ámbito:

```programa id=repetido titulo="Un nombre declarado dos veces" ejecutar
Algoritmo Repetido
  Definir x Como Entero <- 1;
  Definir x Como Entero <- 2;
  Escribir x;
FinAlgoritmo
```

```diagnosticos
duplicateVariableDeclaration
```
:::

::: por-dentro
Cada variable local ocupa una ranura numerada del marco de su subprograma. En la representación intermedia, la declaración no genera ninguna instrucción por sí sola: solo el valor inicial produce un `store`.

```ri programa=mochila
```
:::

::: nota
Antes de ejecutarlo, dibuja las cajas de `mochila`. Si dibujas `cuadernos` con un 0 desde el principio, estás suponiendo un valor por defecto que no existe.
:::

::: resumen
- `Definir` crea una o varias variables de un tipo.
- El valor inicial es opcional y solo vale con un nombre.
- Sin valor inicial, la variable empieza vacía, no en cero.
- Un nombre no se repite en el mismo ámbito.
:::

::: vease
- [Constantes](#declaraciones.constante)
- [Asignación](#declaraciones.asignacion)
- [Variables sin valor](#declaraciones.sin-valor)
:::
