---
id: tipos.opcional-resultado
numero: "3.10"
tipo: tipo
titulo: "`Opcional` y `Resultado`"
anclas: [LANG.TYPES.RELATIONS#R2, LANG.TYPES.RELATIONS#R3, LANG.TYPES.RELATIONS#R4, LANG.TYPES.RELATIONS#R5]
fichas: [help.variants]
diagnosticos: [resultNotHandled, incompatiblePropagationType, incompatibleVariantConstructor, ambiguousVariantType]
terminos: [Opcional, Resultado, propagar, descartar]
---

::: frase
`Opcional` representa un valor que puede faltar y `Resultado` una operación que puede salir bien o mal; los dos obligan a mirar el caso malo antes de usar el valor.
:::

## Cómo se escribe {#escribe}

```forma
Definir «nombre» Como Opcional<«tipo»> <- Algo(«valor»);
Definir «nombre» Como Opcional<«tipo»> <- Nada;
Definir «nombre» Como Resultado<«tipo», «tipo de error»> <- Exito(«valor»);
Definir «nombre» Como Resultado<«tipo», «tipo de error»> <- Error(«error»);
```

## Cómo funciona {#funciona}

Son dos variantes incorporadas:

- `Opcional<T>` tiene dos formas: `Algo(valor)` cuando hay valor y `Nada` cuando falta.
- `Resultado<T, E>` tiene dos formas: `Exito(valor)` cuando la operación salió bien y `Error(error)` cuando no.

Como cualquier variante, se consultan con `Segun`. No existe una forma de «sacar el valor y esperar que esté»: el programa tiene que decidir qué hace en los dos casos.

```programa id=dividir titulo="Una división que puede fallar" ejecutar
SubProceso dividir(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("no se divide entre cero");
  FinSi
  Retornar Exito(a div b);
FinSubProceso
Proceso Division
  Segun dividir(10, 2) Hacer
    Exito(cociente): Escribir "Cociente: ", cociente;
    Error(motivo): Escribir "Error: ", motivo;
  FinSegun
  Segun dividir(1, 0) Hacer
    Exito(cociente): Escribir "Cociente: ", cociente;
    Error(motivo): Escribir "Error: ", motivo;
  FinSegun
FinProceso
```

```salida
Cociente: 5
Error: no se divide entre cero
```

```figura id=opcional-resultado
pie: Dos cajas que pueden estar llenas o no. Para abrirlas hay que contemplar las dos posibilidades.
```

## Propagar {#propagar}

Dentro de un subprograma que también devuelve `Resultado` (u `Opcional`), `Propagar` evita escribir un `Segun` en cada llamada: si el valor es `Exito`, da su contenido; si es `Error`, termina el subprograma devolviendo ese mismo error.

```programa id=propagar titulo="Pasar el error hacia arriba" ejecutar
SubProceso dividir(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("no se divide entre cero");
  FinSi
  Retornar Exito(a div b);
FinSubProceso
SubProceso mitadDelCociente(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Definir c Como Entero <- Propagar dividir(a, b);
  Retornar Exito(c div 2);
FinSubProceso
Proceso Encadenar
  Segun mitadDelCociente(20, 0) Hacer
    Exito(valor): Escribir valor;
    Error(motivo): Escribir "Falló: ", motivo;
  FinSegun
FinProceso
```

```salida
Falló: no se divide entre cero
```

`Descartar` deja claro que ignoras un `Resultado` a propósito: `Descartar dividir(4, 2);`.

::: limite
- `Opcional<Opcional<T>>` distingue `Nada` de `Algo(Nada)`.
- `Propagar` solo funciona dentro de un subprograma cuyo retorno sea del mismo tipo (`Opcional`, o `Resultado` con el mismo tipo de error).
- Un `Resultado` que se ignora sin `Descartar` es un error: `resultNotHandled`.
- Un `Resultado` no se escribe, no se compara y no se pasa por referencia.
:::

::: errores
Llamar a una función que devuelve `Resultado` y no hacer nada con él se detecta antes de ejecutar:

```programa id=sin-tratar titulo="Un resultado olvidado" ejecutar
SubProceso dividir(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("no se divide entre cero");
  FinSi
  Retornar Exito(a div b);
FinSubProceso
Proceso Olvido
  dividir(4, 2);
FinProceso
```

```diagnosticos
resultNotHandled
```
:::

::: por-dentro
`Propagar` se traduce a una comprobación de la etiqueta seguida de un retorno anticipado. Antes de salir, el motor ejecuta las limpiezas de `Diferir` pendientes, en orden inverso.

```ri programa=propagar
```
:::

::: resumen
- `Opcional<T>`: `Algo(valor)` o `Nada`.
- `Resultado<T, E>`: `Exito(valor)` o `Error(error)`.
- Se consultan con `Segun`; no hay atajo que ignore el caso malo.
- `Propagar` devuelve el error hacia arriba; `Descartar` lo ignora a propósito.
:::

::: vease
- [Variantes](#tipos.variantes)
- [Diferir](#control.diferir)
- [Fallo de efecto, trampa y corte del anfitrión](#diagnosticos.fallos)
:::
