---
id: declaraciones.asignacion
numero: "5.3"
tipo: construccion
titulo: Asignación
anclas: [LANG.STMT.ASSIGNMENT#R1]
fichas: [help.assignment]
diagnosticos: [incompatibleTypesInAssignment, invalidAssignmentTarget, arrayIndexOutOfRange]
terminos: [asignación, destino]
---

::: frase
`x <- valor` guarda un valor nuevo en una variable y olvida el que tenía.
:::

## Cómo se escribe {#escribe}

```forma
«destino» <- «expresión»;
```

::: partes
- «destino» es un [designador](#declaraciones.designadores): una variable, una casilla de arreglo o un atributo.
- `<-` es la flecha de asignación. Se lee «recibe».
- «expresión» calcula el valor nuevo. Su tipo tiene que encajar con el del destino.
- `;` termina la sentencia.
:::

## Cómo funciona {#funciona}

La asignación se hace en tres tiempos, siempre en este orden:

1. Se evalúa el destino: la variable y, si los hay, sus índices.
2. Se evalúa la expresión de la derecha, con los valores que hay **antes** de asignar.
3. Se guarda el resultado en el destino.

Por eso `contador <- contador + 1` funciona: la derecha lee el valor viejo y el resultado reemplaza al viejo.

El ejemplo clásico es intercambiar dos valores. Hace falta una tercera variable, porque al asignar se pierde lo anterior:

```programa id=intercambio titulo="Intercambiar dos variables" ejecutar
Algoritmo Intercambio
  Definir a Como Entero <- 1;
  Definir b Como Entero <- 2;
  Definir auxiliar Como Entero;
  auxiliar <- a;
  a <- b;
  b <- auxiliar;
  Escribir a, " ", b;
FinAlgoritmo
```

```salida
2 1
```

```figura id=intercambio
pie: Intercambiar dos valores necesita una caja auxiliar que guarde el primero antes de pisarlo.
paso: Situación inicial: `a` vale 1 y `b` vale 2.
paso: `auxiliar <- a;` copia el 1 en la caja auxiliar.
paso: `a <- b;` pisa el 1 de `a` con un 2. El 1 sigue a salvo en `auxiliar`.
paso: `b <- auxiliar;` recupera el 1. Los valores están intercambiados.
```

Asignar un objeto copia la **referencia**, no el objeto: después las dos variables nombran el mismo objeto. Un arreglo completo no se asigna de una vez.

::: errores
El tipo de la derecha tiene que encajar con el destino:

```programa id=asignar-tipo titulo="Un texto en una variable entera" ejecutar
Algoritmo Tipos
  Definir x Como Entero <- 1;
  x <- "uno";
  Escribir x;
FinAlgoritmo
```

```diagnosticos
incompatibleTypesInAssignment
```

Un índice fuera de rango solo se descubre al ejecutar:

```programa id=asignar-fuera titulo="Asignar fuera del arreglo" ejecutar termina=failed
Algoritmo Fuera
  Dimension notas[3] Como Entero;
  notas[3] <- 1;
FinAlgoritmo
```

```diagnosticos
arrayIndexOutOfRange
```
:::

::: por-dentro
Cada asignación a una variable local es un `store` en su ranura. Fíjate en que `auxiliar <- a` es un `load` de la ranura de `a` seguido de un `store` en la de `auxiliar`.

```ri programa=intercambio
```
:::

::: nota
Es fácil leer `a <- b` como una igualdad matemática. Dibuja las cajas y explica por qué `a <- b; b <- a;` no intercambia nada.
:::

::: resumen
- `<-` guarda un valor nuevo y olvida el anterior.
- Primero el destino, después la derecha, al final se guarda.
- El tipo tiene que encajar; los índices se comprueban al ejecutar.
:::

::: vease
- [Designadores](#declaraciones.designadores)
- [Declarar variables con Definir](#declaraciones.definir)
- [Copia y referencias](#objetos.copia)
:::
