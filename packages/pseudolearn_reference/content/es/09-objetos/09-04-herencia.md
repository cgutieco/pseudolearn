---
id: objetos.herencia
numero: "9.4"
tipo: concepto
titulo: Herencia y sobrescritura
anclas: [LANG.CLASS.INHERITANCE#R1, LANG.CLASS.OVERRIDE#R1, LANG.CLASS.SELF-AND-SUPER#R1]
fichas: [help.inheritance]
diagnosticos: [incompatibleMethodOverride, circularInheritance, multipleInheritanceNotSupported, undeclaredSuperclass, inheritedAttributeShadowed, superInClassWithoutSuperclass]
terminos: [herencia, superclase, subclase, despacho]
---

::: frase
Con `Hereda De`, una clase recibe los atributos y métodos de otra y puede cambiar cómo se comportan algunos de ellos.
:::

## Cómo funciona {#funciona}

Una **subclase** hereda de **una sola** superclase. Todo lo que tiene la superclase lo tiene la subclase, y un objeto de la subclase sirve donde se espera uno de la superclase: un `Perro` es un `Animal`.

Si la subclase declara un método con el mismo nombre y la misma firma, lo **sobrescribe**. Cada llamada usa el método de la clase **real** del objeto, no el del tipo de la variable. Eso se llama **despacho**.

```programa id=granja titulo="Un método que cambia en la subclase" ejecutar
Clase Animal
  Definir nombre Como Cadena;

  Metodo Constructor(n Como Cadena)
    Este.nombre <- n;
  FinMetodo

  Metodo Sonido() Como Cadena
    Retornar "...";
  FinMetodo

  Metodo Presentarse() Como Cadena
    Retornar Este.nombre + " dice " + Este.Sonido();
  FinMetodo
FinClase

Clase Perro Hereda De Animal
  Metodo Constructor(n Como Cadena)
    Super.Constructor(n);
  FinMetodo

  Metodo Sonido() Como Cadena
    Retornar "guau";
  FinMetodo
FinClase

Algoritmo Granja
  Definir a Como Animal <- Nuevo Perro("Toby");
  Escribir a.Presentarse();
  Definir b Como Animal <- Nuevo Animal("Pez");
  Escribir b.Presentarse();
FinAlgoritmo
```

```salida
Toby dice guau
Pez dice ...
```

```figura id=herencia-despacho
pie: `Presentarse` está en `Animal`, pero `Este.Sonido()` busca primero en la clase real del objeto: para Toby encuentra el de `Perro`.
```

`Super` llama a la versión de la superclase sobre el mismo objeto. Solo se usa dentro de una subclase, seguido de una llamada.

::: limite
- Solo hay herencia simple: una superclase por clase.
- Una sobrescritura conserva número y tipos de parámetros, modos de paso y retorno. Si cambia algo, es `incompatibleMethodOverride`, no una sobrecarga.
- Una subclase no puede declarar un atributo con el nombre de uno heredado.
:::

::: errores
```programa id=firma-distinta titulo="Una sobrescritura con otra firma" ejecutar
Clase Base
  Metodo Saludo() Como Cadena
    Retornar "hola";
  FinMetodo
FinClase

Clase Hija Hereda De Base
  Metodo Saludo(nombre Como Cadena) Como Cadena
    Retornar "hola " + nombre;
  FinMetodo
FinClase

Algoritmo Mal
FinAlgoritmo
```

```diagnosticos
incompatibleMethodOverride
```
:::

::: resumen
- `Hereda De` da a una clase todo lo de su superclase.
- Un método con la misma firma sobrescribe; cada llamada usa la clase real.
- `Super` llama a la versión de la superclase.
- Herencia simple y sin cambios de firma.
:::

::: vease
- [Métodos y Este](#objetos.metodos)
- [Interfaces](#objetos.interfaces)
- [Relaciones entre tipos](#tipos.relaciones)
:::
