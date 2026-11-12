# Informe final de ENT-1

Documento transitorio de `docs/`. Cierra `PG-7.03`, `PG-7.04`, `PG-7.05` y `PG-7.11` del
[plan general](plan-ejecucion-proposito-general.md) con la evidencia del [plan de PG-7](fase-pg-7-plan-ejecucion.md).
Revisión de partida `bdbf4618`; la revisión de cierre es la del commit de PG-7.

## 1. Capacidades C-01–C-16 (`PG-7.03`)

La evidencia de conformidad es la campaña de cierre de PG-7 (§11.1 del plan de PG-7): `see conform` de los cinco
sujetos sin divergencias no exentas y diferencial VM/AOT sin diferencias.

| Capacidad | Criterio de salida | Evidencia | Estado |
|---|---|---|---|
| C-01 Proyecto | Proyecto de tres módulos, dos perfiles y biblioteca local pasa check/run/build desde otro directorio | `API.PROJECT`, `API.PROJECT.MANIFEST`, `API.PROJECT.LOCK`, `TOOL.CLI.RUN` y `TOOL.CLI.BUILD` en `engine`, `cli` y `aot`; aceptación nativa de proyectos de PG-N.08 | Cumple |
| C-02 Módulos | Corpus positivo/negativo de import, alias, visibilidad, reexport y ciclo, sin E/S en la carga | `LANG.MODULE.MODEL`, `LANG.MODULE.IMPORT` y `API.PROJECT.MANIFEST` en `engine`/`service`/`cli` | Cumple |
| C-03 Edición/perfiles | Edición única 2026, perfil por archivo, cambios incompatibles documentados sin edición GP | Decisión ADR-05/CF-03; `LANG.EDITION.MODEL`, `LANG.PROFILE.MODEL`, `LANG.PROFILE.TRANSLATION`; PG-C sin migrador por decisión de la persona | Cumple |
| C-04 Tipos y valores | Variante omitida/duplicada, tamaño cero, ciclo infinito y bordes; verificador de RI | `LANG.TYPES.ENUM`, `LANG.TYPES.RECORD`, `LANG.TYPES.VARIANT`, `LANG.CONTROL.SWITCH`, `IR.WELL-FORMEDNESS` | Cumple |
| C-05 Abstracción | Inferencia y límites de instanciación, capturas y despacho VM/AOT, GC de entornos | `LANG.TYPES.GENERIC`, `LANG.TYPES.FUNCTION`, `LANG.TYPES.INTERFACE`; PG-L.03–.05; diferencial VM/AOT | Cumple |
| C-06 Colecciones/control | Vacíos, colisiones, mutación durante iteración, cierre exactamente una vez | `LANG.TYPES.VECTOR`, `LANG.TYPES.DICTIONARY`, `LANG.CONTROL.FOR-EACH`, `LANG.CONTROL.CLEANUP`, limpieza ante error y cancelación (PG-3/PG-4) | Cumple |
| C-07 Efectos | Cinta completa reproduce sin tocar disco ni red; error tipado cuando la capacidad no alcanza | `ENG.EFFECT.TAPE` R1–R6 y `API.EXECUTE` R5/R8/R9 (reproducción sin anfitrión); la «capacidad insuficiente» es ahora la atenuación voluntaria (`LANG.CAPABILITY.MODEL#R3`) o el fallo real del SO, sin denegación por política | Cumple con el criterio reformulado |
| C-08 Red/HTTP | GET/POST locales, TLS inválido, timeout, redirección, cuerpo excesivo, cancelación y fallo de permiso | `LIB.HTTP`, `LIB.HTTP.POLICY` y pruebas de red de `pseudolearn_host`/CLI contra servidores locales; «permiso denegado» es el error real del SO o del navegador; sin Internet en conformidad | Cumple con el criterio reformulado |
| C-09 Async/concurrencia | 10 000 agendas sembradas, límites de tareas/cola, bloqueo detectado, raíces con GC forzado | E-PG-06 con 10 000 semillas en VM y `aot` (PG-N.11); `LANG.TASK.SCOPE`, `LANG.TASK.CHANNEL`, `LANG.TASK.ISOLATION`, `ENG.TASK.AGENDA`, `ENG.TASK.MEMORY` | Cumple |
| C-10 Biblioteca | Igual firma, efectos y cobertura en ambos perfiles; matemática rigurosa | `LIB.CORE.*`, `LIB.IO`, `LIB.TIME`, `LIB.HTTP` en `engine`, `aot` y web; PG-S.01–.09; PS-E04 (tablas Unicode idénticas en VM, AOT y Wasm) | Cumple |
| C-11 Servicio/LSP | 100 archivos/10 000 líneas, Unicode, edición obsoleta, cambio de manifiesto, dos clientes | E-PG-02 de PG-7 (p95 de diagnóstico ≤ 31,2 ms en las cargas de C-11) y contraste de dos clientes de PG-6A | Cumple |
| C-12 Extensión | VSIX desde cero, sin parser cliente, host escritorio y navegador, DAP VM | PG-6A/6B; DAP web de PG-7.18 con proyección idéntica a `pseudo dap`; VSIX `darwin-arm64`, `win32-x64` y web | Cumple |
| C-13 Experiencia telefónica | E-PG-08 o documento de producto que no anuncia móvil completo | E-PG-08 diferido por la persona (2026-10-22); la guía de uso declara el teléfono «no verificado» | Cumple como evaluación documentada |
| C-14 Calidad/distribución | Documentación bilingüe, licencia, paquetes verificables, conformidad, publicación solo con aprobación | PG-7.06–.10 | Cumple |
| C-15 App didáctica | Cobertura de sintaxis por vista, interfaz nunca instanciada, foco por tarea | PG-A/PG-B; `check_syntax_coverage.dart` 81/81; conformidad del sujeto `app` | Cumple |
| C-16 Ayuda de sintaxis | 100 % de identidades y roles con ficha o exclusión tipada | PG-H; COV-HELP sin violaciones; `TOOL.SERVICE.CATALOG` en `service` | Cumple |

## 2. Trazabilidad bidireccional (`PG-7.04`)

Recorrido directo: cada punto base de la hoja de ruta (§12.1) tiene destino; los que van a FUT-xx siguen excluidos con su
condición de activación (§8). Recorrido inverso:

| Requisito | Capacidades | Fases que lo construyen (todas con puntos cumplidos) | Paquetes dueños |
|---|---|---|---|
| R-01 | C-01, C-02 | PG-1, PG-L.02/.03, PG-N.08 | spec, semantic, project, API, CLI |
| R-02 | C-01 | PG-1 | project, API, CLI |
| R-03 | C-03, C-10 | PG-1, PG-2, PG-6A | lexicon, syntax, service |
| R-04 | C-03 | PG-0, PG-1, PG-2, PG-C | spec |
| R-05 | C-04, C-05 | PG-2, PG-L | semantic, lowering, codegen |
| R-06 | C-05 | PG-2, PG-4, PG-C.04 | semantic, runtime, VM, codegen |
| R-07 | C-06 | PG-2, PG-S.02 | library, runtime |
| R-08 | C-06, C-07 | PG-2, PG-3 | semantic, runtime |
| R-09 | C-07 | PG-3, PG-B (autoridad plena) | runtime, host, API |
| R-10 | C-09 | PG-4, PG-N.03–.06 | IR, VM, aot_rt |
| R-11 | C-08, C-10 | PG-5, PG-S, PG-N.07 | library, host, Wasm |
| R-12 | C-14 | PG-0, PG-4, PG-5, PG-N.12, PG-7.02 | benchmarks, bench_worker |
| R-13 | C-07, C-08 | PG-3, PG-5, PG-B, PG-7.05 | runtime, host |
| R-14 | C-11 | PG-6A, PG-7.19 | service, semantic, CLI |
| R-15 | C-12 | PG-6A, PG-6B, PG-7.13, PG-7.18 | extensión, CLI |
| R-16 | C-13 | PG-6B (E-PG-08 diferido) | extensión |
| R-17 | C-03, C-16 | PG-2, PG-H, PG-C | semantic, diagnostics, service |
| R-18 | C-14 | PG-0, PG-7.14, PG-7.15 | SEE, rust_checks |
| R-19 | C-15 | PG-A, PG-B, PG-L.07 | app |
| R-20 | C-16 | PG-H y cada fase con sintaxis | SEE, service, app |

Huecos: ninguno. R-09 conserva en la hoja de ruta la prueba «denegación por defecto», sustituida por la decisión de la
persona del 2026-11-02; se anota en la hoja de ruta (`PG-7.15`).

## 3. Casos negativos y riesgos residuales (`PG-7.05`)

| Riesgo | Reglas con casos negativos | Resultado | Riesgo residual |
|---|---|---|---|
| K-05 alias o captura rompe aislamiento o GC | `LANG.TASK.ISOLATION` R1–R5 (28 casos), E-PG-06 con GC forzado | Sin divergencias en `engine` y `aot` | 1×5 = 5, aceptado |
| K-06 la reproducción repite efectos | `API.EXECUTE` R5/R8/R9 y `ENG.EFFECT.TAPE` R1/R2/R4–R6 (cinta alterada rechazada) | Sin divergencias | 1×5 = 5, aceptado |
| K-13 la cinta revela secretos | `ENG.EFFECT.TAPE` R3/R5 y `LIB.HTTP.POLICY` R1/R3 | Sin divergencias | 1×5 = 5, aceptado |
| K-07 reformulado: la atenuación voluntaria no se amplía | `LANG.CAPABILITY.MODEL#R3` (7 casos) y `RT.HOST.INTERFACE#R7` | Sin divergencias | 1×5 = 5, aceptado |

Los riesgos residuales se aceptan bajo la delegación expresa de la persona del 2026-11-12.

## 4. Propuesta de capacidad futura (`PG-7.11`)

Se propone evaluar **FUT-04, acotada a dos optimizaciones medidas**, sin activarla:

1. Reutilización del análisis semántico por dependencia en el servicio: la carga ampliada de E-PG-02 (100 000 líneas)
   queda en 129–196 ms de p95 frente a ≤ 31,2 ms de las cargas de C-11; hoy cada edición reanaliza el proyecto completo.
2. Familia de arreglos de `PERF.AOT.LEVEL`: 2,07 frente al techo V1F, con presupuesto adecuado a 2,20.

Condición de activación según §8 de la hoja de ruta: autorización de la persona para una optimización concreta, con
línea base, control equivalente y diferencial sin cambios observables. Ninguna se activa en PG-7.
