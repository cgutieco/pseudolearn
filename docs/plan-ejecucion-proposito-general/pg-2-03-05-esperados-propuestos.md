# PG-2.03–PG-2.05 · Esperados propuestos para revisión

Estado: nueve cambios aprobados explícitamente por la persona el 2026-10-25; implementación aplicada y verificada.

La migración conserva las salidas y los diagnósticos de los casos que pueden expresar su intención con inicializadores y mutabilidad explícita. Los siguientes casos necesitan cambiar su esperado, operación o intención porque prueban reglas reemplazadas. No se capturan resultados del motor como oráculo.

| Contrato y caso | Antes | Propuesta |
|---|---|---|
| `LANG.DECL.VARIABLE#C3` | `initializationInDeclarationNotAllowed`, error | Inicializador permitido; añadir lectura de x y analizar sin diagnósticos |
| `LANG.DECL.UNINITIALIZED#C1` | `variableUsedUninitialized`, error estricto | `missingBindingInitializer`, error; conservar declaración sin inicializador |
| `LANG.DECL.UNINITIALIZED#C2` | Ejecución flexible con trampa `uninitializedVariableRead` | Análisis flexible con `missingBindingInitializer`, error |
| `LANG.TYPES.INFERENCE#C1` | Ejecución flexible con salida `1` | Análisis flexible con `undeclaredVariable`, error; la primera asignación ya no declara |
| `LANG.TYPES.INFERENCE#C3` | `undeclaredVariable` warning, `inferredVariableType` info, `typeConflictOnInferredVariable` error | `undeclaredVariable`, error en la primera asignación; símbolo inválido evita cascadas |
| `LANG.TYPES.ENUM#C9` | Ejecución flexible con trampa `uninitializedVariableRead` | Análisis flexible con `missingBindingInitializer`, error |
| `LANG.TYPES.RECORD#C15` | Ejecución flexible con trampa `uninitializedVariableRead` | Análisis flexible con `missingBindingInitializer`, error |
| `DIAG.SEVERITY.POLICY#C1` | `variableUsedUninitialized`, error estricto | `missingBindingInitializer`, error estricto |
| `DIAG.SEVERITY.POLICY#C2` | `variableUsedUninitialized`, warning flexible | `missingBindingInitializer`, error flexible; la obligación de inicializar es estructural |

`LANG.DECL.VARIABLE#C1` se migra a dos declaraciones inicializadas y conserva `12`. `LANG.DECL.VARIABLE#C2` conserva `expectedIdentifierInDeclaration`. `LANG.DECL.UNINITIALIZED#C3` se migra y conserva `0`. `LANG.TYPES.INFERENCE#C2` conserva `undeclaredVariable`, error estricto. `LANG.SUBPROGRAM.SCOPE#C1–C3` no necesitan cambios de esperado. `RT.ABI#C2` conserva la trampa: su programa lee un elemento de arreglo sin valor y no un vínculo local sin inicializar.

Si el inventario posterior descubre otro esperado incompatible que no pueda conservarse migrando el programa, se presenta una ampliación antes de editarlo. Los diagnósticos nuevos y los casos nuevos se derivan de sus reglas, sin alterar esta lista por resultados capturados.

## Decisión posterior de la persona

El 2026-10-25 la persona autorizó elegir las opciones de desarrollo necesarias, indicó que el lenguaje aún no tiene usuarios y estableció la versión nueva como oficial sin migraciones. Esta decisión sustituye la obligación previa de migración asistida y permite ajustar fixtures y ejemplos a la forma oficial. No habilita inventar revisiones independientes ni dar por verdes verificaciones pendientes.

## Ajuste adicional de la edición oficial

Bajo la autorización posterior, `LANG.TYPES.RECORD#C21` conserva el programa de asignación implícita y pasa de `recordNotInferable` más `undeclaredVariable` advertencia a un único `undeclaredVariable` error. La regla oficial prohíbe toda declaración implícita; no hay una inferencia especial de registros que diagnosticar. Los demás ajustes de fixtures conservan sus esperados, incluidos los nombres Unicode normalizados y la referencia compartida del registro.
