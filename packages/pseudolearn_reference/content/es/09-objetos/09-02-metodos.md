---
id: objetos.metodos
numero: "9.2"
tipo: construccion
titulo: "Métodos y `Este`"
anclas: [LANG.CLASS.METHODS#R1, LANG.CLASS.SELF-AND-SUPER#R1, LANG.CLASS.MEMBER-ACCESS#R1]
fichas: [help.method, help.member-access, help.object-context]
diagnosticos: [identifierMatchesFieldWithoutThis, undeclaredVariable, privateMemberAccess]
terminos: [método, receptor, objeto actual]
---

::: frase
Un método es un subprograma que vive dentro de una clase y trabaja sobre un objeto concreto: el que se nombra antes del punto.
:::

## Cómo se escribe {#escribe}

```forma
⟦Publico | Privado⟧ Metodo «nombre»(«parámetros») ⟦Como «tipo»⟧
  «instrucciones»
FinMetodo
```

```railes produccion=methodMember
```

::: partes
- `Metodo` abre el método. Puede ir precedido de `Publico` (por omisión) o `Privado`.
- «parámetros» y `Como` «tipo» siguen las mismas reglas que en un [subprograma](#subprogramas.declaracion).
- `FinMetodo` cierra el método.
:::

## Cómo funciona {#funciona}

Un método se llama sobre un objeto: `pasos.Sumar()`. Ese objeto es el **receptor**, y dentro del método se nombra con `Este`. Para usar un atributo o un método del objeto actual, `Este.` es **obligatorio**: un nombre suelto solo puede ser una variable local o un parámetro.

```programa id=contador titulo="Un contador con estado" ejecutar
Clase Contador
  Privado Definir valor Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.valor <- inicial;
  FinMetodo

  Metodo Sumar()
    Este.valor <- Este.valor + 1;
  FinMetodo

  Metodo Actual() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Pasos
  Definir pasos Como Contador <- Nuevo Contador(10);
  pasos.Sumar();
  pasos.Sumar();
  Escribir pasos.Actual();
FinAlgoritmo
```

```salida
12
```

```figura id=receptor-este
pie: Al llamar `pasos.Sumar()`, `Este` dentro del método es el mismo objeto que `pasos`.
```

El punto se puede encadenar: `Nuevo Contador(1).Actual()`. Un atributo después del punto es un [designador](#declaraciones.designadores); una llamada a método no. El receptor se calcula una sola vez.

No hay sobrecarga: dos miembros de una clase no pueden llamarse igual, aunque uno sea atributo y otro método.

::: errores
```programa id=sin-este titulo="Un atributo sin Este" ejecutar
Clase Contador
  Definir valor Como Entero;
  Metodo Sumar()
    valor <- valor + 1;
  FinMetodo
FinClase

Algoritmo Mal
FinAlgoritmo
```

```diagnosticos
identifierMatchesFieldWithoutThis
undeclaredVariable
```
:::

::: por-dentro
Un método es una función más de la representación intermedia con un primer parámetro oculto: el receptor. `pasos.Sumar()` se traduce en una llamada que pasa `pasos` como ese primer argumento.

```ri programa=contador
```
:::

::: resumen
- Un método trabaja sobre su receptor, el objeto antes del punto.
- Dentro, `Este.` es obligatorio para los miembros del objeto.
- Los métodos pueden ser públicos o privados; no hay sobrecarga.
:::

::: vease
- [Clases y atributos](#objetos.clase)
- [Herencia y sobrescritura](#objetos.herencia)
:::
