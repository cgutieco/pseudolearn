---
id: subprogramas.llamada
numero: "7.4"
tipo: concepto
titulo: Llamadas
anclas: [LANG.SUBPROGRAM.CALL#R1]
fichas: [help.subprogram-call]
diagnosticos: [argumentCountMismatch, discardedReturnValue, callAsExpressionWithoutReturnType]
terminos: [llamada, marco]
---

::: frase
Llamar a un subprograma es pausar lo que se está haciendo, ejecutar el subprograma con sus argumentos y volver justo al punto de la pausa.
:::

## Cómo funciona {#funciona}

Una llamada escribe el nombre y, entre paréntesis obligatorios, los argumentos. Los argumentos se calculan **de izquierda a derecha y una sola vez**, y tienen que coincidir en número y tipo con los parámetros.

Cada llamada crea un **marco**: un espacio propio para sus parámetros y variables locales. Al terminar, el marco desaparece y el control vuelve a quien llamó.

```figura id=llamada-marcos
pie: Los marcos se apilan al llamar y se retiran al volver. Solo el de arriba está ejecutándose.
paso: `Principal` está en marcha con su marco.
paso: `Doble(21)` apila un marco nuevo con `n` = 21. `Principal` espera.
paso: `Doble` retorna 42: su marco desaparece y `Principal` sigue con el valor.
```

Un subprograma que devuelve valor se usa **como expresión**, donde hace falta un valor. Uno que no devuelve nada se usa **como sentencia**. Mezclarlos tiene consecuencias distintas:

| Situación | Resultado |
|---|---|
| usar como valor algo que no devuelve nada | error |
| llamar como sentencia algo que devuelve un valor | advertencia: el valor se pierde |

```programa id=llamadas-mal titulo="Un valor descartado y un argumento de más" ejecutar
SubProceso Doble(n Como Entero) Como Entero
  Retornar n * 2;
FinSubProceso

Algoritmo Principal
  Doble(3);
  Escribir Doble(2, 3);
FinAlgoritmo
```

```diagnosticos
discardedReturnValue
argumentCountMismatch
```

::: resumen
- Los paréntesis son obligatorios; los argumentos se calculan de izquierda a derecha.
- Número y tipos tienen que coincidir con la firma.
- Cada llamada tiene su propio marco, que desaparece al volver.
- Descartar un valor devuelto es una advertencia.
:::

::: vease
- [Declarar subprogramas](#subprogramas.declaracion)
- [Retornar](#subprogramas.retornar)
- [Recursión](#subprogramas.recursion)
:::
