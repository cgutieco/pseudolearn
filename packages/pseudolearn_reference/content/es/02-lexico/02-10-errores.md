---
id: lexico.errores
numero: "2.10"
tipo: concepto
titulo: Errores léxicos
anclas: [LANG.LEXICAL.ERRORS#R1, LANG.SYNTAX.ANALYSIS-LIMITS#R1, DIAG.CLASSES#R1]
diagnosticos: [unrecognizedCharacter, analysisNestingLimitExceeded]
terminos: [error léxico, recuperación]
---

::: frase
Un error léxico aparece cuando un trozo del texto no forma ninguna pieza válida: un carácter que el lenguaje no conoce, un escape inventado o unas comillas sin cerrar.
:::

## Cómo funciona {#funciona}

El análisis léxico parte el texto en piezas. Si encuentra algo que no puede ser ninguna pieza, emite un **error léxico** que señala exactamente ese fragmento. Hay tres situaciones:

| Situación | Diagnóstico |
|---|---|
| Un carácter que no pertenece al lenguaje, como `@` | `unrecognizedCharacter` |
| Un escape desconocido dentro de un texto | `invalidEscapeSequence` |
| Unas comillas que nunca se cierran | `unterminatedString` |

Cuando puede delimitar el fragmento culpable, el motor sigue leyendo para encontrar más errores en la misma pasada. Lo que nunca hace es inventar un valor o ejecutar un programa con errores léxicos.

```figura id=error-lexico
pie: El motor señala el fragmento culpable y sigue leyendo. Las fases semánticas no se ejecutan mientras haya errores léxicos.
```

```programa id=arroba titulo="Un carácter que no existe en el lenguaje" ejecutar
Proceso Arroba
  Escribir "correo" @ "dominio";
FinProceso
```

```diagnosticos
unrecognizedCharacter
missingStatementTerminator
```

El segundo diagnóstico es consecuencia del primero: al saltarse la `@`, el motor ya no reconoce el final de la sentencia donde lo esperaba.

::: limite
El análisis admite hasta 256 construcciones anidadas a la vez: paréntesis, operadores unarios, potencias encadenadas y sentencias compuestas dentro de otras. La siguiente produce `analysisNestingLimitExceeded`. El límite protege al motor; ningún programa razonable se acerca a él.
:::

::: resumen
- Tres errores léxicos: carácter desconocido, escape inválido y texto sin cerrar.
- El diagnóstico señala el fragmento exacto.
- Con errores léxicos no hay análisis semántico ni ejecución.
:::

::: vease
- [Literales de texto y de carácter](#lexico.textos)
- [Severidad y clases](#diagnosticos.severidad)
:::
