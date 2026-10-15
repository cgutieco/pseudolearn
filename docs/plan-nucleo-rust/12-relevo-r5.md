# Relevo de R5 — 2026-10-15

## Objetivo y punto de parada

Implementar **toda R5** del plan de fases siguiendo el diseño Remanso. La persona pide ahora detener
esta sesión, marcar avances y dejar el relevo porque se agotan sus tokens. **R5 no está terminada.**
No hay backend de ejecución Rust: ABI, RI, lowering, bytecode, runtime, biblioteca, VM y timeline
contienen su diseño en README, pero aún no tienen implementación. No empezar R6/R7.

La siguiente sesión debe continuar el árbol local completo, incluidos los archivos sin seguimiento.
No ejecutar `git reset`, `git clean` ni restauraciones generales: perderían trabajo sustancial.

## Rama, publicación y reglas

- Única rama: `feature/agregar-ruta-de-especificacion`. No crear ramas ni worktrees.
- Últimos commits publicados y comprobados durante esta sesión:
  - `8ad2dab`: `perf(benchmarks): validate flat memory with E-02R`.
  - `7b16907`: `feat(engine): rebuild the conforming analysis frontend`.
- Todo lo posterior sigue **sin commit ni push**, incluidos contratos, finalización del HIR, argumentos
  tipados, generadores, oráculos y extensiones de propiedades. Este relevo también queda local.
- Leer AGENTS, README y architecture del paquete antes de editar. Código inglés; documentación española;
  cero comentarios, doc/allow/expect, pánicos explícitos, índices inseguros y aritmética implícita en Rust.
- `packages/pseudolearn_core/lib` está congelado. Solo se modificó su manifiesto de conformidad para
  registrar limitaciones observadas del sujeto de referencia; no corregir su implementación.
- Skills ya utilizadas: layer-boundaries, code-quality, package-docs, language-spec-authoring,
  diagnostics-authoring, ast-node-authoring, phase-gate y commit-message, en `.agents/skills/`.
- No se eliminaron archivos para liberar almacenamiento. La autorización de la persona solo alcanza
  temporales y material de desarrollo prescindible; nunca contenido crítico o sensible.

## Trabajo verificado

### B0 y E-02R

Línea base, inventario y deuda en `packages/pseudolearn_spec/results/r5-baseline.json`,
`r5-inventory.json`, `r5-frontend-debt.json` y `r5-authoring-start.json`.
E-02R tiene 27.000 muestras en `packages/pseudolearn_benchmarks/results/e02r/` y resumen
`packages/pseudolearn_spec/results/r5-e02r.json`. RC-01 está resuelto en el registro de decisiones.
El máximo cociente V2R/V1F fue 1,2758 y su límite superior 1,27835; los criterios por familia pasan.

### BF: frente de análisis

- Parser contextual y recuperación acotada; límite normativo de anidación 256.
- NodeKind y vistas generados desde la gramática; vocabulario, firmas y mensajes también generados.
- Léxico Unicode/NFD, escapes, rangos y rechazo sin cascadas derivados corregidos.
- Semántica reescrita por pasadas, HIR en columnas con índices tipados, ensanchamientos explícitos,
  registro de firmas, ámbitos por unidad, jerarquía, clases y flujo de asignación.
- API de análisis con esquema y posiciones, idioma de interfaz separado del vocabulario.
- CLI de análisis con mensajes generados y precedencia de locale corregida.
- Resultado actual conservado: **524 observaciones analyze, 524 cumplen** en
  `packages/pseudolearn_spec/results/engine.json`. La última ejecución está en
  `/private/tmp/r5-typed-arguments-conform.log`.
- CLI: **49 observaciones, 35 cumplen y 14 divergen**, repetido durante el relevo. Los pendientes
  corresponden a ejecución/RI. Resultado en `results/cli.json` y `/private/tmp/r5-handoff-cli-conform.log`.
- E-08: captura completa de 8.400 muestras en `packages/pseudolearn_benchmarks/results/e08r/`;
  resumen `r5-frontend-e08.json`: aproximadamente 1,89–1,91 M líneas/s en 10.000 líneas y p95 5,55–5,62 ms;
  mínimo del corpus aproximadamente 1,432 M líneas/s. **La captura precede a las últimas correcciones
  de diagnósticos y finalización del HIR; repetir antes de certificar el estado final de R5.**
- Robustez: 833 procesos aislados, Unicode aleatorio, UTF-8 inválido, vacío, trivia y 100.000 niveles
  de operadores/paréntesis, sin fallo interno. Evidencia con prefijo `r5-frontend-`.

### HIR y diagnósticos: lote posterior al último commit

- `semantic/src/flow_bindings.rs`: restablece vínculos originales al repetir inferencia de parámetros;
  conserva los tipos inferidos sin perder diagnósticos ni variables implícitas.
- `hir_finalization.rs`: fija lecturas provisionales; introduce Never y Uninitialized para ausencia.
  Las lecturas ya tipadas conservan el tipo correspondiente al instante anterior a un ensanchamiento.
- `semantic/tests/hir.rs`: audita columnas, tipos, tramos y argumentos del catálogo en todo el corpus
  y 400 combinaciones de programas generados. Hay prueba de herencia de 1.500 clases y de ciclo propio.
- `diagnostics/src/arguments.rs` y `codegen/arguments.rs`: argumentos por clase semántica generada desde
  el catálogo; números JSON reales, tipos primitivos por identidad y clases por nombre.
- `api/src/argument_conversion.rs`: resuelve términos del perfil y conserva números en el wire format.
  Valida argumentos obligatorios antes de presentar; el test nativo evita que esta barrera oculte errores.
- Los emisores completan lexeme, límites, aridades, expected/found y className donde corresponde.
  El renderizador sustituye una sola vez y no interpreta llaves dentro de un lexema del usuario.
- `lexicon/codegen/function_metadata.rs`: búsqueda inversa generada de identidad a lexema canónico.

### B1.4: contratos

17 especificaciones cambiadas; clasificación/versiones/casos en `r5-contract-changes.json`.
Incluyen redondeo correcto, formato real de ida y vuelta, cero negativo, raíces exactas y celdas,
sondeos de cancelación en condiciones/bucles vacíos, consulta pasada y activación de engine.
`API.EXECUTE` también se alinea con los nuevos puntos de cancelación.
`LANG.CONTROL.FOR` amplía la dependencia de versión del entero sin cambiar semántica.
`LANG.SYNTAX.ANALYSIS-LIMITS@0.2.0` corrige limit a número JSON: las expectativas antiguas como texto
estaban mal derivadas del modelo de diagnósticos. Correcciones justificadas en
`r5-frontend-case-corrections.json`.

Anclaje, exportación y los cuatro manifiestos de conformidad están actualizados. Ninguna exención
Dart se heredó en engine. `r5-contract-impact.json` se refrescó durante el relevo: diff más 17 impactos,
**18 órdenes con salida 0**, usando el binario SEE de la última compilación válida.

Referencia: 1.180 observaciones, 134 divergencias conocidas, sin regresiones exigibles.
Las doce adicionales se explican por cuatro cancelaciones de bucle vacío y ocho formatos de cero
negativo; están registradas como REF-EMPTY-LOOP-CANCELLATION y REF-NEGATIVE-ZERO. Dart permanece intacto.

### B1.5: generadores y oráculos

- Nuevo `see_generators`: gramática bien tipada con arreglos, objetos cíclicos, copia superficial,
  llamada por referencia, texto y entrada. Usa vocabulario exportado; semilla e índice reproducibles.
- `results/r5-generator-programs.json`: 200 fuentes bilingües consumidas como datos por los tests HIR;
  400 combinaciones de rigor/perfil sin errores. La generación verifica desactualización y tiene un
  negativo real: `r5-generator-negative.json`.
- `see_oracles/integer_expression.rs`: i128 por operación, primera trampa y origen izquierdo a derecho.
- `cells.rs`: alcance por identidad, alias y ciclos, objetos/arreglos/textos y literal gratuito.
- Oráculo racional en `mathematics.rs`, `rational.rs`, `rounding.rs`, `interval.rs`, `dyadic.rs`,
  `series.rs` y `transcendentals.rs`. Series con restos acotados, reducción de argumento, intervalos
  diádicos para contener crecimiento y refinamiento hasta que ambos extremos redondean igual.
  No usa trascendentes del anfitrión ni código del sujeto. Redondeo por cociente/resto y paridad.
- Dependencias fijadas solo en SEE: num-bigint 0.4.8, num-rational 0.4.2, num-traits 0.2.19 y
  num-integer 0.1.46. Capas/README actualizados y auditoría de dependencias pasada.
  **Runtime/library/VM/timeline deben seguir sin estas dependencias**, según el diseño aprobado.
- Tests de empates, subnormales, límite de overflow, signo del cero, dominios y 10.000 bits finitos.
  La expectativa de `3^34` se derivó del entero exacto 16677181699666569.
  Última corrección: potencia real `0^0` devuelve 1 conforme al corpus. Clippy y los catorce tests
  del oráculo se repitieron tras ella: todos pasan. Log: `/private/tmp/r5-handoff-oracle-tests.log`.
- `r5-rounding-case-oracle.json` contiene derivaciones independientes de los casos normativos mediante
  intervalos racionales calculados con Python Fraction. No confundirlas con la futura validación de
  un millón de argumentos por función: esa validación aún no existe.

### B1.6: diseño antes del backend

README del workspace y de abi, ir, lowering, bytecode, runtime, library, vm, timeline, api y CLI
actualizados con el diseño Remanso: u64/u32, bancos crecientes, trampas inmediatas, raíces exactas,
texto por apéndice, gemelos, diferencias sin barrera y presupuesto de puntos de control.
Los crates aún no implementados mantienen `pending: true` y no están en Cargo.

## Punto exacto donde quedó la implementación

El último lote modifica **SEE**, no el backend. Está inconcluso:

1. `see_model/src/properties.rs`, `property-conformance.json` y su esquema registran treinta propiedades
   de engine/cli, incluyendo ocho heredadas de API/RI/reimpresión. Integridad y negativos funcionan.
2. `see_cli/src/property_execution.rs` y `property_selection.rs` incorporan
   `conform --operation properties --subject engine`, `--property`, `--seed`, `--sample`, `--samples`.
   Guardan evidencia aparte en `results/properties-<subject>.json`. Muestra explícita omite barrido del corpus.
3. `see_conformance/src/properties.rs`, `property_evidence.rs` y `property_scenarios.rs` gestionan muestras,
   contraejemplos y repetición. Recorrido exhaustivo añade casos del corpus a las muestras generadas.
   `property_comparison.rs` implementa determinismo, transparencia de GC, identidad por igualdad completa,
   correspondencia observado/no observado y expectativas normativas de ejecución.
4. `property_api.rs` y `property_resources.rs` proponen un puente **de pruebas** `kind: api` con operaciones
   de recursos, idioma, negociación e inyección de fallos. Ocho tests del arnés pasaron antes del último
   lote. **El adaptador engine no implementa ni anuncia ese puente.** Revisar su diseño, documentarlo
   completamente y crear el adaptador sobre API pública antes de tratar estos contrastes como evidencia.
5. Los últimos archivos escritos son `property_states.rs` y `property_recording.rs`. No se han compilado
   ni probado. Estados usa hojas JSON con caminos escapados para verificar deltas y vistas; recording
   esboza particiones de lotes/entrada, reproducción, horizonte y wire roundtrip.
6. **Bloqueo real actual:** E0583 en `see_conformance/src/lib.rs`: declara `mod property_steps;` pero
   `property_steps.rs` no existe. `property_recording.rs` ya lo llama para StepDepth. La primera tarea
   es terminar ese módulo o retirar temporalmente esa integración conservando el pendiente explícito.
7. Después aparecerán posibles lints/límites: `apply_delta` tiene cinco parámetros frente al máximo cuatro;
   faltan negativos para estados/recording; las opciones de record están anidadas en `options` en un
   módulo y planas en otro. Homogeneizar el contrato. El bool selector de minimalidad merece separar
   responsabilidades. No suponer que basta con crear un archivo vacío para recuperar el verde.
8. Faltan ejecutores de primera trampa contra el oráculo entero, RI válida/masa/CLI roundtrip, esquema
   independiente y reimpresión/recuperación, además de completar los restantes controles del registro.
   Hay una rama `executor unavailable` explícita. **Un registro de treinta vínculos no son treinta
   propiedades implementadas ni ejecutadas.** Tampoco `available` debe aceptar una capacidad aislada
   si faltan otras necesarias, ni la igualdad de dos respuestas vacías debe valer como prueba.
9. Las propiedades de traza deben recorrer el corpus apropiado y generados; las de análisis deben
   incluir programas inválidos de analyze. El colector actual selecciona execute/trace para todos:
   especializarlo por responsabilidad antes de certificar cobertura.

Para StepDepth, la intención era buscar externamente en la traza el primer evento posterior que cumple
cada condición: entrar = statement_entered; siguiente = statement_entered a profundidad igual o menor;
salir = return del marco actual; línea = statement_entered en esa línea. Probar también ninguna
coincidencia y final de ejecución. El adaptador debe devolver el índice observado, no decidir el esperado.

## Verificaciones: vigentes y anteriores

| Verificación | Resultado y límite |
|---|---|
| `cargo xtask verify` motor | Salida 0 tras argumentos tipados/HIR; `/private/tmp/r5-engine-typed-verify.log` |
| `cargo xtask verify` CLI | Salida 0; `/private/tmp/r5-cli-typed-verify.log` |
| `cargo xtask verify` SEE | Salida 0 con oráculo y registro, **antes de añadir ejecutores de propiedades**; `/private/tmp/r5-spec-oracle-verify.log` |
| Clippy y tests del oráculo | Verdes tras corregir `0^0`; catorce tests pasan; `/private/tmp/r5-oracle-clippy.log`, `/private/tmp/r5-handoff-oracle-tests.log` |
| Tests del arnés de propiedades | Ocho verdes antes de states/recording; `/private/tmp/r5-properties-tests.log` |
| Clippy y rust-checks SEE | Verdes antes de states/recording; `/private/tmp/r5-property-clippy.log`, `r5-property-limits.log` |
| Check SEE durante el relevo | **Falla E0583**; `/private/tmp/r5-handoff-check.log` |
| Conformidad CLI durante el relevo | 49 observaciones: 35 cumplen, 14 pendientes de implementación divergen |

Los archivos temporales sirven solo si la otra sesión comparte el dispositivo; no son la única evidencia.
El resumen portable del relevo está en `packages/pseudolearn_spec/results/r5-handoff.json`.

## Orden recomendado para continuar

1. Leer este relevo, el plan detallado completo, decisiones y README del paquete. Preservar el árbol local.
2. Terminar/corregir el lote de propiedades hasta recuperar compilación, fmt, Clippy, límites y tests;
   probar felices, infelices y vacíos. Completar B1.5 sin crear aprobaciones ficticias por capacidad ausente.
3. Repetir conformidad analyze y CLI, revisar cobertura BF.4/BF.5, actualizar evidencia de deuda y cerrar
   BF.8 solo con sus criterios reales. El caso de mensajes que ejecuta programas queda ligado a B7;
   no convertir 35 casos estáticos correctos en conformidad de toda la CLI.
4. Ejecutar B1.7 y puerta de referencias transitorias. Mantener las nuevas decisiones en los README,
   sin referencias a este documento desde código ni documentación de paquetes.
5. Implementar B2 → B3 → B4 → B5 → B6 → B7 → B8 con el orden y puertas del plan. Todo este backend falta.
   Implementar matemática propia segura con doble-doble y refinamiento independiente del oráculo;
   recolector exacto, superinstrucciones, gemelos y timeline no son opcionales.
6. Repetir E-08 con el frente final; realizar E-06, E-12, E-16, E-17, suite de rendimiento, conformidad
   completa, comparación con referencia y millón de argumentos matemáticos según el plan.
7. Hacer commits coherentes en la misma rama, push ordinario y comprobar HEAD remoto. Marcar fase
   terminada únicamente cuando todos los criterios estén satisfechos. No abrir fases posteriores.

## Comandos y precauciones prácticas

Cada miembro Rust tiene su propio workspace; **no hay Cargo en la raíz**. En esta sesión se necesitó
`export PATH="$HOME/.cargo/bin:$PATH"`. Los comandos siguientes se ejecutan dentro del miembro indicado:

```sh
cargo xtask verify
cargo run --manifest-path ../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all .
```

Desde `packages/pseudolearn_spec`, cuando compile:

```sh
cargo test -p see_oracles
cargo test -p see_conformance --test properties
cargo run -p see_cli --bin see -- validate
cargo run -p see_cli --bin see -- lock --check
cargo run -p see_cli --bin see -- export --check
cargo run -p see_cli --bin see -- conform --subject engine --operation analyze
cargo run -p see_cli --bin see -- conform --subject cli
cargo run -p see_generators --example program -- suite 42 100
```

`see` resuelve el corpus desde el directorio actual; `--manifest-path` de Cargo no lo cambia. Dependencias,
auditoría de advisories, caché Flutter y operaciones Git pueden necesitar escalación del sandbox.
No regenerar archivos de consumidores a mano. `see lock`/`see export` generan sus artefactos.

No reejecutar a ciegas scripts temporales de esta sesión: algunos incrementan versiones otra vez o
sobrescriben decisiones ya corregidas. En particular, evitar `r5-contracts.py`,
`r5-b1-contract-plumbing.py`, `r5-execution-activation.py`, `r5-property-registry.py`,
`r5-complete-property-registry.py` y `r5-save-frontend-evidence.py` sin leerlos. El último puede restaurar
estado histórico de casillas/evidencia. `rg` puede ignorar conformance.yaml por configuración global;
usar `git ls-files '*conformance.yaml'` o `rg --no-ignore` cuando haga falta.
