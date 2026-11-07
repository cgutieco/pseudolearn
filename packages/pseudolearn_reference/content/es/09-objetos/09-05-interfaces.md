---
id: objetos.interfaces
numero: "9.5"
tipo: concepto
titulo: Interfaces
anclas: [LANG.TYPES.INTERFACE#R1, LANG.TYPES.INTERFACE#R2, LANG.TYPES.INTERFACE#R3]
fichas: [construction.interface]
diagnosticos: [interfaceMethodSignatureMismatch]
terminos: [interfaz, realización, restricción]
---

::: frase
Una interfaz es una lista de métodos que una clase **promete** tener; sirve para escribir código que funciona con cualquier clase que cumpla la promesa.
:::

## Cómo funciona {#funciona}

`Interfaz` declara firmas de métodos sin cuerpo. Una clase la **realiza** de forma explícita con `Realiza`, y entonces tiene que declarar esos métodos con la firma exacta.

```figura id=interfaz-promesa
pie: `Cuadrado` y `Circulo` realizan `Figura`. `Describir` solo conoce la promesa y acepta las dos.
```

Las interfaces no son tipos de valor: no se declaran variables de tipo interfaz. Se usan como **restricción** de un parámetro de tipo genérico: `T: Figura` acepta cualquier clase que realice `Figura`.

```programa id=figuras titulo="Una interfaz como restricción" ejecutar
Interfaz Figura
  Metodo Area() Como Real;
FinInterfaz

Clase Cuadrado Realiza Figura
  Definir lado Como Real;
  Metodo Constructor(l Como Real)
    Este.lado <- l;
  FinMetodo
  Metodo Area() Como Real
    Retornar Este.lado * Este.lado;
  FinMetodo
FinClase

Clase Circulo Realiza Figura
  Definir radio Como Real;
  Metodo Constructor(r Como Real)
    Este.radio <- r;
  FinMetodo
  Metodo Area() Como Real
    Retornar 3.0 * Este.radio * Este.radio;
  FinMetodo
FinClase

SubProceso Describir<T: Figura>(figura Como T)
  Escribir "Área: ", figura.Area();
FinSubProceso

Algoritmo Figuras
  Describir(Nuevo Cuadrado(2.0));
  Describir(Nuevo Circulo(1.0));
FinAlgoritmo
```

```salida
Área: 4.0
Área: 3.0
```

La realización es **nominal**: una clase que tenga por casualidad un método `Area` pero no declare `Realiza Figura` no cumple la interfaz. Una clase puede realizar varias interfaces, separadas por comas, y una subclase hereda las realizaciones de su superclase.

::: errores
```programa id=firma-interfaz titulo="Un método que no cumple la firma" ejecutar
Interfaz Figura
  Metodo Area() Como Real;
FinInterfaz

Clase Linea Realiza Figura
  Metodo Area() Como Entero
    Retornar 0;
  FinMetodo
FinClase

Algoritmo Mal
FinAlgoritmo
```

```diagnosticos
interfaceMethodSignatureMismatch
```
:::

::: resumen
- Una interfaz declara firmas sin cuerpo.
- Una clase la cumple declarándolo con `Realiza` y con firmas exactas.
- Se usa como restricción de genéricos, no como tipo de variable.
:::

::: vease
- [Genéricos](#tipos.genericos)
- [Herencia y sobrescritura](#objetos.herencia)
- [Pureza](#subprogramas.pureza)
:::
