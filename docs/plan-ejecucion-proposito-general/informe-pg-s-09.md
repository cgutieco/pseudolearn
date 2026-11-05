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

## Ejecución web real (S.09.02)

Se reconstruyó el Wasm (`pnpm build:wasm`), se regeneró la gramática TextMate (`pnpm generate:grammar`, artefacto
generado) y se ejecutó `tests/web/run-web.mjs` con el escenario nuevo `general_purpose_scenario.ts` (programas de
`tests/fixtures/web-scenarios/es/proposito-general/`, copias de los de la CLI): Chromium y WebKit en verde. El escenario
exige la salida de las operaciones puras derivada de las reglas y el error tipado `permiso_denegado` de `Entorno`.
Firefox no se ejecutó. La columna «Ext. web» de las áreas puras (S.01, S.02, S.03, S.08, S.05 puro) y S.06 pasa a
`cumple` en Chromium y WebKit; S.04 y S.07 siguen como estaban.

## Ejecución en la app (S.09.02)

`apps/pseudolearn_app/integration_test/general_purpose_acceptance_test.dart` ejecuta el programa puro por el servicio de
ejecución con el puente nativo real: app macOS (debug) y simulador iPhone 18 Pro (iOS 27.0), ambos en verde, con las once
líneas esperadas. Los programas de archivos y de consola con efectos físicos no se ejecutaron en la app.

## No verificado físicamente

Windows, dispositivos físicos, Firefox, WebKit y Chromium reales, suite Flutter, iOS simulador y la vista de consola de
la app con estilo de error (pendiente declarado de S.07). El DAP informa `stderr` según el informe de S.07, sin sesión
de editor real en esta fase.

## Pendientes

1. `PG-S.09.02`: en la app solo se ejecutó el programa puro (no archivos ni consola con efectos); sin Windows ni Firefox.
2. `PG-S.09.04`: hecho el estilo de error y la lectura de `error_ranges`/`exit_code` (834 pruebas Flutter dirigidas en verde); la app no muestra el código de salida y no se verificó el color en ambos temas.
