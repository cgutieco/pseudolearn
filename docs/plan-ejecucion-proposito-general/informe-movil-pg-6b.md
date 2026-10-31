# Informe móvil de PG-6B · cobertura real y CF-14

Documento transitorio de planificación. Fuente de las cifras: crudos en
`apps/pseudolearn_vscode/test-results/` y kit en `.artifacts/physical-kit` (regenerable con
`node scripts/physical-kit.mjs`). No es fuente normativa.

## Categorías

| Categoría | Significado |
|-----------|-------------|
| Comprobado automatizado | Ejecutado en navegador de escritorio automatizado sobre el artefacto final |
| Comprobado físico | Medido en un teléfono real con el kit; **ninguno** al cierre |
| No evaluado | No pudo ejecutarse o no se ejecutó; no es éxito ni fallo |
| No soportado | Ausente por diseño de la variante web |

## Cobertura

| Elemento | Categoría | Evidencia |
|----------|-----------|-----------|
| VS Code web 1.144.0, Chromium | Comprobado automatizado | activación, completado, hover, formato, ayuda, bucle infinito con LSP vivo, parada |
| VS Code web 1.144.0, WebKit | Comprobado automatizado | mismas comprobaciones; WebKit de Playwright **no** es Safari de iPhone |
| VS Code web, Firefox | No evaluado | el build de Playwright no arranca en este equipo; no es resultado de producto |
| Transporte Worker y Wasm | Comprobado automatizado | 1800 intentos válidos sin fallos (Chromium) |
| Artefacto Wasm | Comprobado automatizado | 4 181 471 bytes; Brotli 844 844 (≤921 600); memoria máxima 256 MiB |
| Ejecución en teléfonos (32 combinaciones × 20 ciclos) | No evaluado | kit generado; sin teléfonos ni resultados; diferido por decisión del 2026-10-22 |
| Teclado móvil, guardado y pérdida de texto | No evaluado | requieren dispositivo físico |
| Persistencia de archivos | No soportado | el proveedor de pruebas es memoria virtual |
| DAP, AOT, FFI, procesos, servidor remoto | No soportado | ausentes en la variante web |

## Latencias medidas (ms, Chromium de escritorio, no representativas de teléfonos)

| Carga | Worker (media / p95) | Control (media / p95) |
|-------|----------------------|------------------------|
| Entero extremo | 1,29 / 1,2 | 1,44 / 1,0 |
| Bucle de mil iteraciones | 64,8 / 107,6 | 62,1 / 104,7 |
| Cancelación | 15,3 / 25,4 | 14,6 / 24,6 |

El control es la página mínima con el mismo Wasm. La diferencia Worker/control es de unos 1 a 3 ms por
carga; no se concluye nada sobre enseñanza ni sobre la disponibilidad en todos los teléfonos.

## Opciones para CF-14 (decisión de la persona, no resuelta)

1. Aceptar la cobertura automatizada y declarar móvil «no evaluado físicamente», sin prometer teléfonos.
2. Ejecutar el kit físico en uno o más teléfonos antes de decidir; el analizador rechaza muestras
   sintéticas, duplicadas, incompletas o de otro dispositivo/Wasm.
3. Limitar la variante web a escritorio hasta contar con evidencia física.

Ninguna opción crea un IDE propio ni un host remoto. CF-14 y la aceptación de `PERF.PG.WEB` conservan su
diferimiento autorizado.
