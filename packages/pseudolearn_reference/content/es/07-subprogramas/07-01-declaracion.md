---
id: subprogramas.declaracion
numero: "7.1"
tipo: construccion
titulo: "Declarar subprogramas"
anclas: [LANG.SUBPROGRAM.DECLARATION#R1, LANG.SUBPROGRAM.INTERACTIONS#R1]
fichas: [help.subprogram]
diagnosticos: [subroutineWithoutReturn, returnVariableNotDeclared, duplicateSubroutine]
terminos: [subprograma, procedimiento, función]
---

::: frase
Un subprograma es un trozo de programa con nombre: se escribe una vez y se usa tantas veces como haga falta.
:::

## Cómo se escribe {#escribe}

```forma
SubProceso «nombre»(«parámetros») ⟦Como «tipo»⟧
  «instrucciones»
FinSubProceso
Funcion «resultado» <- «nombre»(«parámetros»)
  Definir «resultado» Como «tipo»;
  «instrucciones»
FinFuncion
```

```railes produccion=subprogram
```

::: partes
- `SubProceso` abre un subprograma. Los paréntesis son obligatorios aunque no haya parámetros.
- `Como` «tipo» es opcional: con él, el subprograma **devuelve** un valor; sin él, solo hace cosas.
- `Funcion` declara una función con **variable de resultado**: el valor que tenga «resultado» al terminar es lo que se devuelve.
- `FinSubProceso` y `FinFuncion` cierran cada forma.
:::

## Cómo funciona {#funciona}

Los subprogramas se declaran **al lado** del algoritmo principal, nunca dentro de él ni dentro de otro subprograma. El orden no importa: se puede llamar a uno que está escrito más abajo.

```programa id=saludar-doble titulo="Un procedimiento y una función" ejecutar
SubProceso Saludar(nombre Como Cadena)
  Escribir "Hola, ", nombre;
FinSubProceso

SubProceso Doble(n Como Entero) Como Entero
  Retornar n * 2;
FinSubProceso

Proceso Principal
  Saludar("Ana");
  Escribir Doble(21);
FinProceso
```

```salida
Hola, Ana
42
```

```figura id=subprograma-caja
pie: Un subprograma visto desde fuera: entran los argumentos, sale el resultado. Lo de dentro no se ve.
```

La forma `Funcion` es cómoda cuando el resultado se va construyendo poco a poco. No lleva `Retornar` con valor: devuelve lo que tenga su variable de resultado.

```programa id=area titulo="Función con variable de resultado" ejecutar
Funcion area <- AreaRectangulo(base Como Real, alto Como Real)
  Definir area Como Real;
  area <- base * alto;
FinFuncion

Proceso Principal
  Escribir AreaRectangulo(3.0, 4.5);
FinProceso
```

```salida
13.5
```

Dentro de un subprograma vale todo lo que vale en el algoritmo: declaraciones, `Leer`, `Escribir`, decisiones y bucles. Las variables que declara son **locales**: nadie más las ve.

::: limite
- El tipo de retorno puede ser un primitivo o una clase, nunca un arreglo.
- Una `Funcion` es [pura](#subprogramas.pureza): no puede escribir, leer ni llamar a nada que lo haga.
:::

::: errores
Un subprograma con tipo de retorno necesita al menos un `Retornar`:

```programa id=sin-retornar titulo="Un tipo de retorno sin Retornar" ejecutar
SubProceso Siete() Como Entero
  Escribir "sin retorno";
FinSubProceso

Proceso Principal
  Escribir Siete();
FinProceso
```

```diagnosticos
subroutineWithoutReturn
```
:::

::: por-dentro
Cada subprograma es una función de la representación intermedia con sus propios bloques. Una llamada es una instrucción `call` que nombra la función de destino.

```ri programa=saludar-doble
```
:::

::: docentes
Antes de escribir subprogramas, pide a la clase que busque en un programa largo dos trozos casi iguales. Ese es el primer candidato a subprograma.
:::

::: resumen
- `SubProceso` declara un subprograma; con `Como` tipo devuelve un valor.
- `Funcion` devuelve lo que tenga su variable de resultado y es pura.
- Se declaran al lado del algoritmo, en cualquier orden.
- Sus variables son locales.
:::

::: vease
- [Parámetros](#subprogramas.parametros)
- [Llamadas](#subprogramas.llamada)
- [Retornar](#subprogramas.retornar)
:::
