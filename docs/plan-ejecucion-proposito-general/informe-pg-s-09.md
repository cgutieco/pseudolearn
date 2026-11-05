# Informe PG-S.09 (aceptación por plataforma)

Estado: implementado con el alcance que el equipo permite. No se hizo commit ni push y no se declara cerrada la fase.

## Decisiones tomadas

| Tema | Decisión |
|---|---|
| Programas de aceptación | Tres archivos en `apps/pseudolearn_cli/examples/general-purpose/acceptance/` (puro, archivos, consola y entorno), con salida derivada de las reglas del corpus, no copiada del motor sin contraste. |
| Ejecución | `apps/pseudolearn_cli/tests/general_purpose_acceptance.rs` ejecuta el binario real en carpeta temporal (stdout, stderr, código de proceso, carpeta vacía). |
| Exhaustividad web (S.09.03) | `browser_operation_support.ts` + `browser_operation_coverage.test.ts` comparan con `capabilityLibrary` de `export.json`; caso negativo incluido. |
| Entorno en web | `environment_get` → `permiso_denegado`, declarado como `platform_error`. |
| PS-V-14 | Confirmada por lectura: la extensión de escritorio lanza `pseudo ejecutar --editor`. |
| PS-V-12 | Sin cambio: la exportación de la app marca las operaciones de efecto como bloqueo `capability`. |

## Matriz de aceptación (§7.2)

| Área | VM/API | CLI | Ext. escritorio | Ext. web | App macOS | App iOS sim. | App Windows |
|---|---|---|---|---|---|---|---|
| S.01 texto | cumple | cumple | cumple por CLI (lectura) | no verificado | no verificado | no verificado | no verificado |
| S.02 colecciones | cumple | cumple | idem | no verificado | no verificado | no verificado | no verificado |
| S.03 números | cumple | cumple | idem | no verificado | no verificado | no verificado | no verificado |
| S.04 archivos | cumple | cumple | idem | rama declarada, probada con sistema de archivos en memoria | no verificado | no verificado | no verificado |
| S.05 fecha y hora | cumple | cumple | idem | rama probada | no verificado | no verificado | no verificado |
| S.06 entorno | cumple | cumple | idem | error tipado esperado (`permiso_denegado`), probado | no verificado | no verificado | no verificado |
| S.07 error y salida | cumple | cumple (stderr, código 7) | idem | confirma conteo, sin estilo propio | sin vista de error | no verificado | no verificado |
| S.08 formato | cumple | cumple | idem | no verificado | no verificado | no verificado | no verificado |

## No verificado físicamente

Windows, dispositivos físicos, Firefox, WebKit y Chromium reales, suite Flutter, iOS simulador y la vista de consola de
la app con estilo de error (pendiente declarado de S.07). El DAP informa `stderr` según el informe de S.07, sin sesión
de editor real en esta fase.

## Pendientes

1. `PG-S.09.02`: ejecutar los programas en extensión web (Chromium/WebKit), app macOS y app iOS simulador.
2. `PG-S.09.04`: la app no interpreta `error_ranges` ni `exit_code`; falta el estilo propio de la consola, la proyección de operaciones nuevas, la matriz de cobertura y la suite Flutter dirigida.
