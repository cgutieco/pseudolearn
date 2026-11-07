---
id: subprogramas.pureza
numero: "7.8"
tipo: concepto
titulo: "Pureza: `Funcion` frente a `SubProceso`"
anclas: [LANG.CAPABILITY.PURITY#R1, LANG.CAPABILITY.PURITY#R2, LANG.CAPABILITY.PURITY#R3, LANG.CAPABILITY.PURITY#R4, LANG.CAPABILITY.PURITY#R5, LANG.CAPABILITY.PURITY#R6]
diagnosticos: [pureFunctionSideEffect, pureFunctionTransitiveSideEffect, pureFunctionInterfaceImpurity, awaitOutsideSuspendible]
terminos: [función pura, efecto]
---

::: frase
Una `Funcion` solo calcula: no escribe, no lee, no toca archivos ni red. Lo que hace efectos se declara con `SubProceso`.
:::

## Cómo funciona {#funciona}

Un **efecto** es cualquier cosa que el programa hace hacia fuera: escribir en la consola, leer del teclado, abrir un archivo, pedir la hora. PseudoLearn separa dos clases de subprogramas:

| Unidad | ¿Puede tener efectos? |
|---|---|
| `SubProceso` y el algoritmo principal | sí |
| `Funcion` | no: es **pura** |

Una función pura devuelve siempre el mismo resultado para los mismos argumentos. Eso la hace fácil de probar y de entender.

```programa id=funcion-impura titulo="Una función que escribe" ejecutar
Funcion r <- Cuadrado(n Como Entero)
  Definir r Como Entero;
  Escribir "calculando";
  r <- n * n;
FinFuncion

Algoritmo Principal
  Escribir Cuadrado(3);
FinAlgoritmo
```

```diagnosticos
pureFunctionSideEffect
```

La comprobación es **transitiva**: una función tampoco puede llamar a un subprograma que tenga efectos, ni a uno que llame a otro que los tenga.

```figura id=pureza-grafo
pie: El efecto de `Avisar` sube por las llamadas hasta `Triple`, que es una `Funcion` y queda rechazada.
```

```programa id=funcion-transitiva titulo="Un efecto escondido en una llamada" ejecutar
SubProceso Avisar()
  Escribir "aviso";
FinSubProceso

Funcion r <- Triple(n Como Entero)
  Definir r Como Entero;
  Avisar();
  r <- n * 3;
FinFuncion

Algoritmo Principal
  Escribir Triple(3);
FinAlgoritmo
```

```diagnosticos
pureFunctionTransitiveSideEffect
```

El diagnóstico señala, en orden, cada unidad de la cadena desde la primera llamada con efecto hasta la que lo produce.

::: limite
- Donde se espera una función pura no se puede pasar un subprograma o una clausura con efectos.
- Si una interfaz declara un método como `Funcion`, todas sus implementaciones tienen que ser puras.
- Una `Funcion` no puede contener `Aguardar`.
:::

::: resumen
- `Funcion` es pura: sin entrada, salida ni capacidades.
- La pureza se comprueba a través de todas las llamadas.
- Los efectos van en `SubProceso` o en el algoritmo.
:::

::: vease
- [Declarar subprogramas](#subprogramas.declaracion)
- [Efectos y capacidades](#tareas.efectos)
- [Interfaces](#objetos.interfaces)
:::
