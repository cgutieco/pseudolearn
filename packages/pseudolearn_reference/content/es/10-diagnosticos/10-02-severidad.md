---
id: diagnosticos.severidad
numero: "10.2"
tipo: concepto
titulo: Severidad y clases
anclas: [DIAG.SEVERITY.POLICY#R1, DIAG.CLASSES#R1, DIAG.CLASSES#R2, DIAG.ENGINE.INTERNAL-FAULT#R1]
diagnosticos: [variableDeclaredNeverUsed, readValueTypeMismatch]
terminos: [severidad, error, advertencia]
---

::: frase
La severidad dice qué hacer con un diagnóstico: un error impide ejecutar, una advertencia avisa y deja seguir.
:::

## Cómo funciona {#funciona}

Cada código tiene **una única severidad**, fijada en el catálogo e independiente de su clase. Se agrupan con una letra:

| Letra | Severidad | Ejemplos |
|---|---|---|
| A | error estructural o fallo de ejecución | `missingStatementTerminator`, `divisionByZero` |
| C | advertencia de higiene | `variableDeclaredNeverUsed` |
| D | información | sugerencias sin consecuencia |
| E | advertencia recuperable de lectura | `readValueTypeMismatch` |

La letra B no está asignada.

```figura id=severidad-clases
pie: Las clases dicen en qué fase se detecta el problema; la severidad, qué consecuencia tiene.
```

Las clases siguen el recorrido del programa: **léxica** y **sintáctica** al leer el texto, **semántica** al comprobar tipos y nombres, y **de ejecución** mientras corre. Si hay errores léxicos o sintácticos, la fase semántica no se ejecuta: así no aparecen errores derivados de un árbol roto.

Una advertencia no detiene nada. Al leer un valor que no encaja con el tipo, el motor avisa y **vuelve a pedirlo**, sin cambiar la variable:

```programa id=leer-mal titulo="Una lectura que se repite" ejecutar
Algoritmo Edad
  Definir edad Como Entero;
  Leer edad;
  Escribir "Tienes ", edad;
FinAlgoritmo
```

```entrada
doce
12
```

```salida
Tienes 12
```

```diagnosticos
readValueTypeMismatch
```

::: limite
Un defecto del propio motor nunca se presenta como error del programa. Se atrapa en la frontera y produce un **fallo interno** distinto de cualquier diagnóstico. Ningún programa, válido o no, debería provocarlo.
:::

::: resumen
- Cada código tiene una severidad fija: A error, C higiene, D información, E lectura.
- Las clases dicen la fase: léxica, sintáctica, semántica o ejecución.
- Con errores de sintaxis no se hace análisis semántico.
:::

::: vease
- [Anatomía de un diagnóstico](#diagnosticos.anatomia)
- [Recuperación y orden](#diagnosticos.recuperacion)
- [Variables sin usar](#declaraciones.sin-usar)
:::
