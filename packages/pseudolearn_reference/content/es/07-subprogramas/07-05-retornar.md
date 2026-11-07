---
id: subprogramas.retornar
numero: "7.5"
tipo: construccion
titulo: "Devolver un valor con `Retornar`"
anclas: [LANG.SUBPROGRAM.RETURN#R1]
fichas: [help.return]
diagnosticos: [subroutineEndedWithoutReturn, subroutineWithoutReturn, returnValueInReturnVariableFunction, returnOutsideSubroutine]
terminos: [retorno]
---

::: frase
`Retornar` termina el subprograma en el acto y, si tiene tipo de retorno, entrega el valor a quien llamó.
:::

## Cómo se escribe {#escribe}

```forma
Retornar ⟦«expresión»⟧;
```

```railes produccion=returnStatement
```

::: partes
- `Retornar` termina la llamada.
- «expresión» es obligatoria si el subprograma declara `Como` tipo, y está prohibida si no.
- En una `Funcion` con variable de resultado, `Retornar` va **sin** expresión: devuelve la variable.
:::

## Cómo funciona {#funciona}

`Retornar` corta todo: sale de los bucles y bloques abiertos y abandona la llamada completa. Lo que queda después no se ejecuta. Por eso sirve para salir en cuanto se conoce la respuesta:

```programa id=primer-negativo titulo="Salir en cuanto se sabe" ejecutar
SubProceso PrimerNegativo(a Como Entero, b Como Entero, c Como Entero) Como Entero
  Si a < 0 Entonces
    Retornar a;
  FinSi
  Si b < 0 Entonces
    Retornar b;
  FinSi
  Retornar c;
FinSubProceso

Algoritmo Principal
  Escribir PrimerNegativo(4, -2, -7);
FinAlgoritmo
```

```salida
-2
```

```figura id=retornar-salidas
pie: Tres salidas posibles. Con 4, -2 y -7 se sale por la segunda, y la tercera nunca se alcanza.
```

Todo camino de un subprograma con tipo tiene que acabar en un `Retornar`. Si el motor no encuentra ninguno, es un error antes de ejecutar. Si hay alguno, pero un camino concreto llega al final sin pasar por él, el fallo se descubre **al ejecutar** ese camino.

::: errores
```programa id=signo-incompleto titulo="Un camino sin Retornar" ejecutar termina=failed
SubProceso Signo(n Como Entero) Como Cadena
  Si n > 0 Entonces
    Retornar "positivo";
  FinSi
FinSubProceso

Algoritmo Principal
  Escribir Signo(5);
  Escribir Signo(-1);
FinAlgoritmo
```

```salida
positivo
```

```diagnosticos
subroutineEndedWithoutReturn
```

La primera llamada funciona; la segunda llega a `FinSubProceso` sin valor que devolver.
:::

::: por-dentro
Cada `Retornar` es una instrucción `return` que termina el bloque. Un camino sin `Retornar` acaba en una instrucción de trampa con la posición del cierre.

```ri programa=signo-incompleto
```
:::

::: resumen
- `Retornar` termina la llamada en el acto, también desde dentro de bucles.
- Lleva expresión si y solo si el subprograma tiene tipo de retorno.
- Un camino que llega al cierre sin retornar falla al ejecutar.
:::

::: vease
- [Declarar subprogramas](#subprogramas.declaracion)
- [Salir de un bucle](#control.salir)
- [Diferir](#control.diferir)
:::
