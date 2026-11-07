---
id: objetos.clase
numero: "9.1"
tipo: construccion
titulo: "Clases y atributos"
anclas: [LANG.CLASS.DECLARATION#R1, LANG.CLASS.FIELDS#R1, LANG.TYPES.CLASS#R1]
fichas: [help.class]
diagnosticos: [duplicateMember, privateMemberAccess]
terminos: [clase, objeto, atributo]
---

::: frase
Una clase es un molde: describe qué datos guarda cada objeto (sus **atributos**) y qué sabe hacer (sus **métodos**).
:::

## Cómo se escribe {#escribe}

```forma
Clase «Nombre» ⟦Hereda De «Superclase»⟧
  ⟦Publico | Privado⟧ Definir «atributo» Como «tipo»;
  «métodos y constructor»
FinClase
```

```railes produccion=classUnit
```

::: partes
- `Clase` abre la declaración y «Nombre» es el nombre del tipo nuevo.
- `Hereda De` es opcional y nombra una sola [superclase](#objetos.herencia).
- Cada atributo se declara con `Definir`, sin valor inicial. Puede llevar delante `Publico` (la opción por omisión) o `Privado`.
- Después van los [métodos](#objetos.metodos) y, como mucho, un [constructor](#objetos.constructor).
- `FinClase` cierra la clase.
:::

## Cómo funciona {#funciona}

Una clase es una unidad hermana del algoritmo: no va dentro de él ni de otra clase. Su nombre es un **tipo** nuevo, y cada valor de ese tipo es un **objeto** que se crea con [`Nuevo`](#objetos.constructor).

```programa id=puntos titulo="Una clase con dos atributos" ejecutar
Clase Punto
  Definir x Como Entero;
  Definir yy Como Entero;
FinClase

Algoritmo Puntos
  Definir p Como Punto <- Nuevo Punto();
  p.x <- 3;
  p.yy <- 4;
  Escribir p.x, ",", p.yy;
FinAlgoritmo
```

```salida
3,4
```

```figura id=clase-objetos
pie: Una clase y dos objetos creados con ella. Cada objeto tiene sus propios atributos.
```

Los atributos empiezan **sin valor**: no admiten inicializador. Un atributo `Privado` solo se puede usar desde el código de su propia clase.

Las variables de tipo clase guardan una **referencia** al objeto, no el objeto: asignar o pasar por valor copia la referencia y las dos variables nombran el mismo objeto. La igualdad `=` entre objetos compara **identidad**. No existe un valor nulo que se pueda escribir.

::: errores
```programa id=espiar titulo="Leer un atributo privado desde fuera" ejecutar
Clase Caja
  Privado Definir secreto Como Entero;
FinClase

Algoritmo Espiar
  Definir c Como Caja <- Nuevo Caja();
  c.secreto <- 1;
FinAlgoritmo
```

```diagnosticos
privateMemberAccess
```
:::

::: por-dentro
Un objeto es un bloque del montón con una celda por atributo. El acceso `p.x` se traduce en la representación intermedia a una lectura o escritura de campo por posición.

```ri programa=puntos
```
:::

::: docentes
La pareja «molde y galleta» funciona: un molde, muchas galletas, cada una con su decoración. Deja de valer cuando dos variables comparten un objeto: no son dos galletas, son dos nombres para la misma.
:::

::: resumen
- Una clase declara atributos y métodos; su nombre es un tipo.
- Los atributos se declaran con `Definir` y empiezan sin valor.
- `Privado` limita el acceso al código de la clase.
- Las variables guardan referencias; `=` compara identidad.
:::

::: vease
- [Métodos](#objetos.metodos)
- [Constructores y Nuevo](#objetos.constructor)
- [Copia e identidad](#objetos.copia)
:::
