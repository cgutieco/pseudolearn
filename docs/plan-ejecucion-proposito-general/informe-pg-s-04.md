# Informe PG-S.04 (archivos) y estado de PG-S.05

Estado: PG-S.04 implementada y verificada con el alcance indicado abajo; **PG-S.05 no se inició** (ver «PG-S.05»).
No se hizo commit ni push, y la fase no se declara cerrada: no se ejecutó `cargo xtask verify` completo ni las pruebas
nativas de `pseudolearn_api` (requieren la feature `native`).

## Decisiones tomadas

| Tema | Decisión |
|---|---|
| `EsDirectorio` (DS-14, «Persona») | Incluido: sin él, `Listar` obliga a abrir cada entrada. |
| Resultados | `Existe`, `EsDirectorio`, `Borrar`, `Renombrar`, `CrearDirectorio` devuelven `Lógico` (verdadero); `Listar` devuelve `Vector<Cadena>`; `AgregarTexto/Bytes` devuelven el número de octetos escritos. |
| Mapeo de errores (DS-15) | Directorio no vacío → `peticion_invalida`; es-directorio/no-es-directorio → `ruta_invalida`; sin variantes nuevas en `ErrorES`. Mover un directorio dentro de sí mismo, borrar o renombrar la raíz `.` → `ruta_invalida`. |
| Derechos | Consultar exige lectura, mutar y añadir exigen escritura; `Subdirectorio` en `lectura` rechaza las mutaciones con `permiso_denegado`. |
| `Agregar*` | Escribe al final del contenido actual; `Abrir` en escritura sigue vaciando el archivo (modos sin cambio, para no ampliar el modelo de derechos). Consecuencia: no se puede añadir sobre un archivo preexistente sin un modo de apertura nuevo (`agregar`), que requiere su aprobación. |
| Memoria | Directorios vacíos mediante la directiva `directories` del anfitrión; `Subdirectorio` acepta un directorio explícito vacío. |
| Booleanos en el corpus | Los casos imprimen `1`/`0` para que la salida sea idéntica en ambos perfiles (`fake_host` compara contra una sola salida). |
| Vínculos | `engine`: `cumple` (conformidad ejecutada). `aot`: `pendiente`, `resuelve_en` `PG-N.08` (no se midió AOT: sus 370 incumplimientos previos ya existían). |
| Evidencia heredada | `results/engine.json`, `matrix-engine.json` y `properties-engine.json` se restauraron a su estado previo; la evidencia nueva de `LIB.IO` está en `packages/pseudolearn_spec/results/pg-s-04-05-2026-11-04/`. |

## Qué se hizo

- Corpus: `LIB.IO` R5–R11 y casos C22–C67 (46 casos, ambos perfiles, con grabar y reproducir donde procede);
  `LIB.MODEL` D2 (ocho operaciones), ocho fichas es/en, cobertura de RI V217–V223, esquema `see-1` (`directories`),
  validador de casos (operaciones que mutan), reanclaje de `IR.INSTRUCTIONS`, `LIB.IO`, `LIB.MODEL` y
  `TOOL.SERVICE.CATALOG`, exportación regenerada.
- Motor: `pseudolearn_host` (`physical_directory_ops.rs`, `physical_file_append.rs`, mapeo de `ErrorKind`),
  `pseudolearn_runtime` (`memory_host_directories.rs`, derechos, validación de incertidumbre, configuración).
- Extensión web: `browser_directory_ops.ts`, `browser_file_support.ts`. CLI, puente de la app y exportadores no
  necesitaron código: las operaciones pasan por `pseudolearn_host` y el catálogo exportado.
- Pruebas: 13 de anfitrión físico (mil rutas con `..`, enlace simbólico, derechos, cierre), 6+1 de memoria,
  3 de ABI, 4 de API (suspensión, incertidumbre, tipo de resultado), 13 del adaptador web con sistema de archivos en memoria.

## Verificación ejecutada

- `see validate` (197 contratos), `see lock`, `see export --check`: en verde.
- `see conform --subject engine --only LIB.IO`: 134 observaciones, 0 divergencias.
- `cargo test` de `pseudolearn_abi`, `ir`, `service`, `runtime`, `semantic`, `lowering`, `vm`, `host`, y de `pseudolearn_api` sin las pruebas `native*`: en verde. `see_validation`: en verde.
- `cargo fmt --check`, `clippy -D warnings` (host, runtime, abi, API dirigidas), `rust-checks all`: en verde.
- Extensión: `tsc`, arquitectura, comentarios, tamaño y 178 pruebas de vitest: en verde.

### Prueba manual registrada (CLI, carpeta temporal)

```bash
cd "$(mktemp -d)" && pseudo ejecutar prueba.pseudo
```

Programa: crea `carpeta`, abre `carpeta/a.txt` en escritura, `EscribirTexto("uno")`, `AgregarTexto(" dos")`, cierra,
renombra a `carpeta/b.txt` y lista `carpeta`. Salida: `1:b.txt` (código 0); `carpeta/b.txt` contiene `uno dos`.
Segunda ejecución en la misma carpeta: `ya_existe`.

## Pendientes

1. **Hallazgo previo al cambio:** `record` con `seek_every_event` falla con «Invalid protocol: unreachable event» tras
   un efecto fallido *incierto* (reproducible con `file_write_text`). Por eso el corpus no tiene caso de incertidumbre;
   la de `Renombrar` se cubre en `pseudolearn_api/tests/directory_effects.rs`. Registrar y corregir en la capa de historia.
2. Pruebas de adversarios en Windows (`:` y `\` solo se prueban en la rama confinada) y nombres no UTF-8 en Linux
   (la prueba existe pero no corre en macOS).
3. AOT/nativo: `PG-N.08` (el AOT ya incumplía 370 observaciones antes de este cambio; no se comparó).
4. `cargo xtask verify` completo, pruebas `native*` de la API y el resto de sujetos (`cli`, `service`, `app`) no se ejecutaron.

## PG-S.05

No se implementó. Requiere un tipo de efecto nuevo atravesando `abi/build.rs`, `EffectValueKind`, `HostValue`,
`host_words.rs`, `effect_types.rs`, el verificador semántico y el lowering, el experimento `PS-E01` con una dependencia
de zonas horarias (`jiff` está en la caché local de Cargo, 0.2.24 y 0.2.37) con medición de licencia, tamaño y
plataformas, y la decisión de parar si algo excede el presupuesto. Hacerlo a medias dejaría el corpus y los verificadores
en rojo; queda como siguiente fase con luz verde explícita.
