---
id: diagnosticos.recuperacion
numero: "10.3"
tipo: concepto
titulo: Recuperación y orden
anclas: [LANG.SYNTAX.RECOVERY#R1, LANG.SYNTAX.RECOVERY#R2, LANG.SYNTAX.RECOVERY#R3, LANG.SYNTAX.RECOVERY#R4, LANG.SYNTAX.RECOVERY#R5, DIAG.ORDERING#R1]
diagnosticos: [missingStatementTerminator, expectedExpression, unclosedIfStatement, maxDiagnosticsExceeded]
terminos: [recuperación, sincronización]
---

::: frase
Tras un error de sintaxis, el motor busca un punto seguro para seguir leyendo: así informa de todos los errores independientes de una vez, cada uno una sola vez.
:::

## Cómo funciona {#funciona}

Cuando una sentencia está mal escrita, el análisis no se detiene. Descarta lo que no entiende hasta un punto de **sincronización** —el fin de línea, un `;` o el borde de un bloque— y continúa desde ahí. Cada sentencia rota produce **como mucho un** diagnóstico principal, y los errores que caen sobre lo descartado no se informan.

```programa id=dos-errores titulo="Dos errores independientes" ejecutar
Algoritmo Dos
  Definir a Como Entero <- 1
  Escribir a;
  Escribir (a + ;
  Escribir "fin";
FinAlgoritmo
```

```diagnosticos
missingStatementTerminator
expectedExpression
```

```figura id=sincronizacion
pie: Cada error descarta hasta el siguiente punto seguro y el análisis sigue. Las líneas correctas se reconocen con normalidad.
```

Un bloque que queda sin cerrar produce **un solo** diagnóstico, con un tramo relacionado que apunta a su apertura, aunque haya otros bloques exteriores pendientes:

```programa id=bloques-abiertos titulo="Dos bloques sin cerrar" ejecutar
Algoritmo Abierto
  Mientras Verdadero Hacer
    Si Verdadero Entonces
      Escribir 1;
FinAlgoritmo
```

```diagnosticos
unclosedIfStatement
```

## Orden {#orden}

Los diagnósticos se publican en un orden fijo, que no depende del idioma ni de cuándo se descubrieron: primero por fase (léxica, sintáctica, semántica), después por posición, extensión y código.

::: limite
- Se informan como mucho cien diagnósticos sintácticos principales. Al llegar al tope se añade `maxDiagnosticsExceeded` como resumen.
- Incluso un texto vacío o completamente inválido produce un árbol: el editor siempre tiene algo con lo que trabajar.
:::

::: resumen
- Tras un error, el análisis sincroniza y sigue.
- Una sentencia rota da como mucho un diagnóstico principal.
- Un bloque sin cerrar da un solo diagnóstico.
- El orden es fijo: fase, posición, extensión y código.
:::

::: vease
- [Severidad y clases](#diagnosticos.severidad)
- [Fin de sentencia](#lexico.fin-de-sentencia)
:::
