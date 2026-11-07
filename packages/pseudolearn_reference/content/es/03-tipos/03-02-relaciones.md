---
id: tipos.relaciones
numero: "3.2"
tipo: concepto
titulo: Relaciones entre tipos y ampliación
anclas: [LANG.TYPES.RELATIONS#R1]
diagnosticos: [incompatibleTypesInAssignment]
terminos: [ampliación, asignabilidad]
---

::: frase
Un valor solo pasa solo de un tipo a otro cuando el tipo de destino lo contiene entero: de `Entero` a `Real`, de `Caracter` a `Cadena` y de una subclase a su superclase.
:::

## Cómo funciona {#funciona}

Dos tipos pueden relacionarse de tres maneras distintas, y conviene no mezclarlas:

- **Igualdad**: son el mismo tipo.
- **Ampliación**: un valor de uno cabe en el otro sin perder nada.
- **Asignabilidad**: un valor puede guardarse en una variable del otro, ya sea porque son iguales o porque se amplía.

Hay tres ampliaciones, y ninguna más:

```figura id=ampliaciones
pie: Las únicas tres flechas que el motor sigue por su cuenta. Las flechas tachadas exigen una función de conversión.
```

La ampliación se aplica al inicializar, al asignar, al pasar un argumento por valor, al devolver un resultado y al guardar en una colección. También al comparar: un carácter comparado con una cadena se amplía a cadena antes de comparar.

```programa id=amplia titulo="Ampliaciones automáticas" ejecutar
Proceso Amplia
  Definir r Como Real <- 3;
  Definir letra Como Caracter <- 'a';
  Definir texto Como Cadena <- letra;
  Escribir r, " ", texto, " ", letra = "a";
FinProceso
```

```salida
3.0 a Verdadero
```

En sentido contrario no hay ampliación: un `Real` no se convierte solo en `Entero`, un `Logico` no es un número y un número no se convierte solo en texto.

```programa id=no-amplia titulo="Un entero no es un texto" ejecutar
Proceso NoAmplia
  Definir t Como Cadena <- 5;
FinProceso
```

```diagnosticos
incompatibleTypesInAssignment
```

::: nota
Los parámetros por referencia son la excepción: exigen exactamente el mismo tipo, sin ampliación, porque el subprograma escribirá en la variable original.
:::

::: resumen
- Igualdad, ampliación y asignabilidad son relaciones distintas.
- Solo hay tres ampliaciones: `Entero` a `Real`, `Caracter` a `Cadena` y subclase a superclase.
- Todo lo demás se pide con una función de conversión.
- Por referencia exige el tipo exacto.
:::

::: vease
- [Tipos primitivos](#tipos.primitivos)
- [Paso por valor y por referencia](#subprogramas.referencia)
- [Hereda De](#objetos.herencia)
:::
