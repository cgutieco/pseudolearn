# PG-2.09–PG-2.11: registro de implementación y verificación

## Alcance

Rama única: `feature/agregar-ruta-de-especificacion`. Las tres capacidades se desarrollan juntas. La primera parte contiene corpus, casos, tests escritos, código y documentación; la segunda contiene pruebas acotadas y correcciones. La autorización de la segunda parte se recibió después, en un mensaje nuevo de la persona. Ninguna compilación se presenta como ejecución de tests.

## Inventario de implementación

| Capacidad | Dueños modificados |
|---|---|
| Interfaces nominales, realización explícita e heredada, restricciones y métodos de la clase real | syntax, semantic, lowering, API y catálogo de ayuda |
| Vector y Diccionario, bancos, crecimiento, hash, compactación, presupuestos y versiones | abi, runtime, library, RI, bytecode, VM y AOT |
| Para Cada, Salir y limpieza léxica por aristas de salida | syntax, semantic, lowering, metadatos de raíces y ambos ejecutores |
| Formato de contenidos, observación, historial y consulta pública | library, lowering, timeline y API |
| Ayuda, traducción y formateo contextual bilingües | corpus, generadores, service y API |
| Consumo de las nuevas entradas de estado | adaptador Rust de la tabla de variables en Dart |

El corpus incorpora seis contratos del lenguaje; mantiene versiones y estados de los existentes. Se actualizan los tres esperados expresamente autorizados y se conserva el identificador ordinario interface. D-PG2-07 conserva despacho directo cuando procede y el despacho virtual de clase existente cuando corresponde. Los metadatos de colección tienen representación reversible en RI textual.

Los contratos nuevos conservan `revisado_por` vacío hasta recibir revisión independiente del texto concreto. La aprobación del plan no se registra como revisión editorial realizada. Los vínculos de conformidad nuevos permanecen pendientes hasta obtener evidencia; no se cierra ninguna fase por compilación.

## Órdenes de desarrollo

Desde `packages/pseudolearn_engine` se ejecutaron compilaciones `cargo check --all-targets` acotadas a syntax, semantic, lowering, VM, AOT y API; la selección conjunta incluye los catorce crates afectados. También se ejecutó rustfmt sobre archivos modificados. Los artefactos del corpus se regeneraron con `see_format` y `see_export`, sin ejecutar conformidad ni propiedades.

La primera selección conjunta de catorce crates y todos sus targets terminó correctamente. La compilación de los tests encontró una llamada escrita con la aridad incorrecta de new_text, que se corrigió. Hubo un intento de cargo check desde la raíz sin Cargo.toml: no ejecutó ninguna prueba.

El lanzador Dart no pudo formatear porque intentó escribir la caché de Flutter fuera del área permitida. La invocación directa del SDK formateó ambos archivos y después falló al escribir su registro de telemetría fuera del área permitida. No se amplió el acceso ni se ejecutaron tests de Dart durante desarrollo.

## Estado de verificación (2026-10-26, segunda sesión)

Se corrigieron cuatro fallos y se repitieron las selecciones acotadas. No hay `PHASE-GREEN`: la puerta `see validate` exige revisión editorial independiente de los seis contratos nuevos (`revisado_por` vacío, que no se completa sin revisión real), y de ella dependen `see export` y `see conform`; además el módulo Wasm excede su presupuesto de tamaño.

### Fallos corregidos

| Fallo | Causa | Corrección |
|---|---|---|
| `MemoryError::Internal` al recolectar un vector tras una recolección previa | `discard_breadcrumbs` liberaba todo bloque auxiliar, incluidos los búferes de colecciones | Solo libera los índices que un texto referencia, una vez cada uno (los prefijos compartidos comparten índice) |
| Casos de `Diccionario<Cadena,…>` rechazados con `incompatibleArgumentType` | Un literal de un carácter es `Carácter` y no existe conversión a `Cadena`; la comprobación del índice exigía igualdad de tipos | Decisión de la persona: reescribir las claves de los casos a 2 o más caracteres (`aa`, `bb`, `xx`, `éx` precompuesto y descompuesto); el índice usa asignabilidad y ensanchamiento |
| `lang.control.cleanup#C5` devolvía 9 en vez de 2 | El operando de `Retornar` compartía registro con la variable que la limpieza reasigna | Con limpiezas pendientes, el retorno copia el operando con `value.require` antes de emitirlas |
| El formato de un vector en AOT fallaba con recolección forzada | Los literales de delimitadores no tenían tramo, las raíces léxicas no cubrían el vector y se liberaba antes de terminar | Los literales de `collection_output` llevan el tramo de la expresión |

También se corrigieron lints de Clippy de los archivos tocados y tres preexistentes triviales (`closure_values`, `closure_layout`, `hir_finalization`).

### Resultados confirmados

| Selección | Resultado |
|---|---|
| Runtime `vector_tests` (4), `dictionary_tests` (3), `--lib` (2: versión agotada y colisiones sembradas), `text_tests`, `heap_tests` | Pasan |
| ABI `vector_layout`, IR `collection_types`, bytecode `verify_collection_types`, library `quoted_text`, syntax `interface_parser` e `iteration_parser`, service `contextual_tokens`, semantic `interface_registry` | Pasan |
| Lowering `cleanup_edges` (3, con el test nuevo del retorno) y los crates `pseudolearn_lowering`, `pseudolearn_runtime` y `pseudolearn_semantic` completos | Pasan |
| API `collection_state`, `program_view_nominal` | Pasan |
| API `collection_execution`: todos los casos de los seis contratos con gemelos, observación `none` y `events`, y recolección forzada; con `native`, AOT contra VM | Pasan |
| Dart `rust_watch_rows_test.dart`, `check_limits.dart`, `dart analyze` | Pasan |
| `rust-checks` `limits`, `layers`, `comments`, `names`, `unsafe` en engine | Pasan |
| Clippy `-D warnings --all-targets` en los crates tocados con `native` | Sin avisos |

### Cierre

- **Revisión editorial:** la persona autorizó en el chat registrar su nombre como revisor de los seis contratos nuevos. `see validate` pasa, el anclaje se refrescó para los contratos existentes editados y `see export --check` pasa.
- **Conformidad:** `see conform --only` sin divergencias en engine y AOT para los seis contratos; sus vínculos pasan a `cumple` (engine) y a `cumple` o `exento` (AOT, por reglas de análisis estático que el adaptador no anuncia). También sin divergencias en engine y AOT para `LANG.CLASS.OUT-OF-SCOPE`, `LANG.SYNTAX.GRAMMAR`, `LANG.PROFILE.VOCABULARY`, `LANG.TYPES.GENERIC`, `LANG.EDITION.MODEL`, y en engine para `DIAG.CATALOG` e `IR.TEXT-FORMAT`.
- **Casos corregidos durante la conformidad:** `LANG.TYPES.INTERFACE#C15` ya no llama al método privado desde `Main` (producía un diagnóstico extra), y una clave de diccionario rechazada ya no produce `undeclaredSubroutine` además de `invalidDictionaryKeyType`.
- **Deuda ajena, preexistente:** `LANG.TYPES.RELATIONS#C5` (advertencia de sombreado), `MEM.VALUE.COPY` (C1, C3, C4), `ENG.LIMITS` (C8, C9, C17, C18) e `IR.INSTRUCTIONS` (C2 a C4) usan la sintaxis anterior a los inicializadores obligatorios y fallan en engine (algunos también en AOT); no se tocaron. Las reglas `#R3` de `API.PROGRAM.VIEW`, `API.STATE.QUERY` y `RT.ABI` se verifican con propiedades que `--only` no ejecuta.
- **Tamaño:** presupuesto ampliado por la persona a 5 MiB y 900 KiB (`PERF.ARTIFACT.SIZE` M1 y M2, `capture_bridge_artifacts.dart`, README y conformidad de la app); medido 4 566 624 B y 819 420 B.
- Commit y push: no se hicieron.
