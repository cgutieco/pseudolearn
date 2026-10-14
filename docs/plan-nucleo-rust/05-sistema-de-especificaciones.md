# 05 · Sistema de especificaciones y conformidad

> **Estado:** propuesta. Concreta [11](../11-especificaciones-ejecutables-diseno.md) §9–§11 y §14 para
> una herramienta escrita en Rust que verifica sujetos escritos en cualquier lenguaje. Revisa
> [D-10](../17-riesgos-preguntas-y-decisiones.md#d-10): el paquete sigue siendo independiente, pero
> pasa a ser Rust.

---

## 1. Por qué la herramienta en Rust y el protocolo por proceso

- **Los sujetos están en dos lenguajes** (Dart y Rust) y la CLI es un binario. Un adaptador en
  proceso obligaría a la herramienta a enlazar con cada uno. Un **protocolo por la entrada y salida
  estándar** la hace independiente del lenguaje de cada sujeto y, de paso, cumple la regla de
  [11](../11-especificaciones-ejecutables-diseno.md) §10, punto 2: el ejecutor solo ve la API del adaptador,
  nunca los internos.
- **Dart se retira en R9.** Una herramienta en Dart tendría que reescribirse entonces, o mantendría viva
  la cadena Dart solo para ella.
- **Es el primer código Rust del proyecto.** Su dominio (leer archivos, validar, recorrer un grafo,
  lanzar procesos) es sencillo. Sirve para aprender Rust y fijar los verificadores
  (`pseudolearn_rust_checks`) antes de tocar el motor.

---

## 2. `packages/pseudolearn_spec`

```
packages/pseudolearn_spec/
├── README.md                     arquitectura de la herramienta y del corpus (español)
├── architecture.yaml
├── rust-toolchain.toml
├── Cargo.toml                    workspace
├── specifications/               EL CORPUS: datos, sin código
│   ├── see/  lang/  diag/  lib/  eng/  mem/  ir/  rt/  api/  tool/  app/  perf/
│   ├── features/                 manifiestos de característica
│   ├── cases/                    programas largos de casos, referenciados por ruta
│   └── specifications.lock       generado y versionado
├── schemas/                      JSON Schema del formato see/1, versionado
├── fixtures/                     corpus inválidos: un caso negativo por regla de validación
├── crates/
│   ├── see_model/                entidades: especificación, regla, caso, error, vínculo, manifiesto
│   ├── see_format/               lectura de Markdown + YAML a modelo; escritura canónica
│   ├── see_validation/           las cinco capas de validación
│   ├── see_graph/                dependencias, rangos, ciclos, impacto
│   ├── see_change/               hash canónico, diff, clasificación preliminar
│   ├── see_oracles/              oráculos independientes de las propiedades (enteros de precisión arbitraria, IEEE 754, puntos de código)
│   ├── see_translation/          traductor de referencia entre perfiles a partir del vocabulario del corpus
│   ├── see_conformance/          protocolo, ejecución de casos y propiedades, comparación
│   ├── see_report/               matriz, impacto, estado de manifiestos; texto y JSON
│   ├── see_export/               exportación para consumidores y su comprobación
│   └── see_cli/                  binario `see`
└── xtask/
```

Capas (de abajo arriba):

| Capa | Crates                                                                 |
|------|------------------------------------------------------------------------|
| 1    | `see_model`                                                            |
| 2    | `see_format`, `see_oracles`                                            |
| 3    | `see_validation`, `see_graph`, `see_change`, `see_translation`         |
| 4    | `see_conformance`, `see_export`                                        |
| 5    | `see_report`                                                           |
| 6    | `see_cli`                                                              |

### 2.1 Órdenes

| Orden                                      | Qué hace                                                                                       | Especificación               |
|--------------------------------------------|------------------------------------------------------------------------------------------------|------------------------------|
| `see new <ID> --domain lang`               | Crea una especificación en `borrador` desde la plantilla de su dominio                          | `SEE.FORMAT`                 |
| `see validate`                             | Las cinco capas; sale con código distinto de cero ante cualquier error                          | `SEE.VALIDATION`             |
| `see graph [--focus ID]`                   | Grafo de dependencias en texto o DOT                                                           | `SEE.GRAPH`                  |
| `see diff <rev>`                           | Diferencias normativas respecto de una revisión y clasificación preliminar                     | `SEE.CHANGE.CLASSIFICATION`  |
| `see lock [--check]`                       | Regenera o comprueba `specifications.lock`                                                     | `SEE.LOCK`                   |
| `see impact <ID>`                          | Informe de impacto de un cambio                                                                | `SEE.IMPACT`                 |
| `see conform --subject <s> [--only ID]`    | Ejecuta casos y propiedades contra un sujeto y actualiza su resultado                          | `SEE.ADAPTER.PROTOCOL`, `SEE.CONFORMANCE.*` |
| `see matrix`                               | Matriz regla × sujeto                                                                          | `SEE.CONFORMANCE.MATRIX`     |
| `see feature <nombre>`                     | Estado agregado de un manifiesto                                                               | `SEE.FEATURE-MANIFEST`       |
| `see export [--check]`                     | Exportación JSON para consumidores ([04](04-arquitectura-del-workspace-rust.md) §5)            | `SEE.GENERATION`             |

---

## 3. Protocolo de adaptador (`see-protocol/1`)

**Transporte.** El sujeto es un proceso. `see` le escribe **una petición JSON por línea** en la entrada
estándar y lee **una respuesta JSON por línea** en la salida estándar. La salida de error del sujeto
se guarda para el informe, pero no forma parte del veredicto.

### 3.1 Negociación

```json
{"kind":"hello","protocol":"see-protocol/1"}
```

```json
{"kind":"hello","protocol":"see-protocol/1","subject":"engine","subject_version":"0.4.0",
 "capabilities":["analyze","execute","observe_events","observe_state","emit_ir"],
 "profiles":["es","en"],"strictness":["strict","flexible"]}
```

Un caso que necesita una capacidad que el sujeto no anuncia da el veredicto **`no aplicable`**, no
`incumple`. Por ejemplo, un caso de `ENG.STATE.SNAPSHOT` contra `reference`. La matriz distingue las dos
cosas.

### 3.2 Peticiones

| `kind`      | Entrada                                                                                  | Respuesta                                                                                             | La usan               |
|-------------|------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|-----------------------|
| `analyze`   | `program`, `profile`, `strictness`                                                        | `diagnostics[]`                                                                                       | `LANG`, `DIAG`        |
| `execute`   | `program`, `profile`, `strictness`, `inputs[]`, `seed`, `observe` (`none`, `events`, `events_and_state`), `limits` | `output`, `termination` (`completed`, `failed` + `code`, `awaiting_input`, `limit_reached` + `limit`), `diagnostics[]`, `events[]`, `states[]` | `LANG`, `ENG`, `LIB`, `MEM` |
| `emit_ir`   | `program`, `profile`                                                                      | `ir_text` o `diagnostics[]`                                                                           | `IR`                  |
| `verify_ir` | `ir_text`                                                                                 | `valid` o `violations[]`                                                                              | `IR.WELL-FORMEDNESS`  |
| `api_script`| Secuencia de llamadas de la API con sus argumentos                                        | Una respuesta por llamada                                                                             | `API`                 |
| `shutdown`  | —                                                                                        | —                                                                                                     | —                     |

Forma de un diagnóstico en el protocolo (`API.WIRE-FORMAT`):

```json
{"code":"integerOverflow","class":"runtime","severity":"error",
 "span":{"start":{"line":4,"column":14},"end":{"line":4,"column":23}},
 "related":[],"arguments":{"operator":"+"}}
```

### 3.3 Órdenes de línea de comandos

Los casos de `TOOL.CLI.*` no usan el protocolo. `see` crea un directorio temporal con los archivos del
caso, ejecuta el binario declarado (`pseudo check …`) y compara la salida estándar, la de error y el
código de salida.

### 3.4 Comparación

Cómo se compara cada campo de `espera` es parte de `SEE.CONFORMANCE.*`, no una decisión de cada caso:

| Campo esperado       | Comparación                                                                                   |
|----------------------|-----------------------------------------------------------------------------------------------|
| `salida`             | Exacta, byte a byte, tras resolver los marcadores de lexema del perfil (`{{lexema:booleanTrue}}`) |
| `fallo.codigo`       | El código de terminación coincide                                                             |
| `diagnosticos`       | Igualdad de multiconjunto por `(codigo, severidad)`; además, tramo exacto cuando el caso lo declara. Un diagnóstico de más es un fallo |
| `eventos`            | Prefijo o secuencia completa, según declare el caso; lexemas resueltos                        |
| `estado`             | Igualdad estructural del estado observable en los puntos declarados; la identidad de objeto se compara por isomorfismo, no por número |
| `ir`                 | Igualdad de texto canónico de la RI, o solo que verifica, según el caso                       |

### 3.5 Los dos perfiles

Un caso de `LANG` se escribe en un perfil. Para ejecutarlo en el otro:

1. `see_translation` **reimprime el programa** con el vocabulario de destino, tomado de
   `LANG.PROFILE.VOCABULARY`. Es un traductor de referencia **independiente de los sujetos**: por eso no
   se le pide al sujeto que traduzca, lo que lo convertiría en su propio oráculo.
2. Si el programa usa un identificador que sería palabra reservada en el otro perfil, `see validate`
   exige que el caso incluya el texto en ese perfil o una exclusión justificada
   ([11](../11-especificaciones-ejecutables-diseno.md) §3.3).
3. Relación metamórfica obligatoria: la traza de ejecución en los dos perfiles coincide, salvo los
   lexemas.

### 3.6 Propiedades

`see` genera las entradas a partir del `generador` de la propiedad, construye el programa desde una
plantilla del caso y compara con un **oráculo de `see_oracles`**, nunca con otro sujeto:

- enteros de precisión arbitraria para decidir el desbordamiento;
- operaciones IEEE 754 de la biblioteca estándar de Rust para los reales;
- conteo de puntos de código para el texto.

Si falla, se reduce a un contraejemplo mínimo y el informe lo muestra como programa.

---

## 4. Adaptadores de los sujetos

| Sujeto      | Adaptador                                                                                 | Dónde vive                                                         | Fase |
|-------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------|------|
| `reference` | Programa Dart que implementa `see-protocol/1` usando **solo la API pública** del núcleo Dart | `packages/pseudolearn_core/tool/conformance_adapter.dart`         | R1   |
| `engine`    | Binario Rust sobre `pseudolearn_api`                                                     | `packages/pseudolearn_engine/crates/pseudolearn_conformance`       | R4   |
| `aot`       | El mismo binario, con `execute` resuelto como «compilar con Cranelift, enlazar, ejecutar» | Ídem, opción `--subject aot`                                       | R6   |
| `cli`       | Ninguno: ejecución directa (§3.3)                                                         | —                                                                  | R4   |
| `service`   | Petición `api_script` sobre las operaciones del servicio                                  | `pseudolearn_conformance`                                          | R7   |
| `app`       | Test de integración de Flutter que lee casos `APP.*` exportados                           | `apps/pseudolearn_app/integration_test/`                           | R8   |

El adaptador `reference` es **el único cambio de código que recibe el núcleo Dart** en este plan,
aparte de las correcciones que pida una especificación. Vive en `tool/`, que ya está exento de los
límites, y no modifica `lib/`.

---

## 5. Archivos de conformidad

Cada sujeto declara lo que cumple en un archivo de datos en su propio miembro, con la forma de
[11](../11-especificaciones-ejecutables-diseno.md) §9.1:

| Sujeto                     | Archivo                                                     |
|----------------------------|-------------------------------------------------------------|
| `reference`                | `packages/pseudolearn_core/conformance.yaml`                |
| `engine`, `aot`, `service` | `packages/pseudolearn_engine/conformance.yaml`              |
| `cli`                      | `apps/pseudolearn_cli/conformance.yaml`                     |
| `app`                      | `apps/pseudolearn_app/conformance.yaml`                     |

```yaml
sujeto: engine
vinculos:
  - regla: LANG.TYPES.INTEGER@1.0.0
    verificacion: ejecutor
    estado: cumple
  - regla: LANG.CONTROL.FOR@2.0.0#R5
    verificacion: ejecutor
    estado: pendiente
    resuelve_en: R5
  - regla: ENG.STATE.SNAPSHOT@1.0.0
    verificacion: ejecutor
    estado: exento
    justificacion: el sujeto reference no expone estado observable completo (H-10)
```

---

## 6. Reglas de la CI sobre la matriz

| Situación                                                                 | Resultado en la CI                         |
|---------------------------------------------------------------------------|--------------------------------------------|
| Especificación `estable` o `experimental` con un vínculo `cumple` que falla | **Falla**                                 |
| Vínculo `pendiente` cuya fase no está cerrada                              | Pasa, con aviso                            |
| Vínculo `pendiente` cuya fase ya se cerró                                   | **Falla**                                  |
| Caso de una `propuesta` que falla                                          | Pasa (esperado), informado                 |
| Caso de una `propuesta` que **pasa**                                       | Aviso: candidata a `experimental`          |
| Especificación `estable` sin vínculo en un sujeto declarado                | **Falla**                                  |
| `reference` diverge de `engine` en una regla `estable` sin `exento` justificado | **Falla**                             |
| `see export --check` o `see lock --check` desactualizados                   | **Falla**                                  |

---

## 7. Salud de los casos (métrica, no puerta)

- **Mutación del sujeto:** `cargo-mutants` sobre `pseudolearn_engine`. Los mutantes que sobreviven al
  corpus señalan reglas con casos débiles.
- **Mutación de la especificación:** `see` altera un valor esperado o invierte una fuerza y comprueba que
  algún caso falle.
- Se publica en el informe de cada fase. Nunca bloquea un cambio ([11](../11-especificaciones-ejecutables-diseno.md) §10, punto 4).
