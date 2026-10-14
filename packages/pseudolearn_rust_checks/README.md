# pseudolearn_rust_checks

## 1. Qué es y qué no es

Verificadores mecánicos de los miembros Rust. No implementa el lenguaje ni el sistema `see`.
La API devuelve diagnósticos ordenados o un error de configuración; nunca oculta fallos de lectura.
Los fixtures negativos son datos deliberadamente inválidos y no fuentes del producto.

## 2. Guía operativa y ciclo de vida

Rust se fija en `rust-toolchain.toml`, con rustfmt y Clippy. Plataformas: macOS, Linux y Windows.
Preparación: `cargo fetch` y `cargo install cargo-deny --locked`.
Desarrollo: `cargo run -p pseudolearn_check_command --bin rust-checks -- comments .`.
Compilación: `cargo build --release`; salida en `target/release/rust-checks`.
Verificación completa: `cargo xtask verify`. No se despliega ni publica a un registro.

Cada comando `layers`, `comments`, `names`, `limits`, `unsafe` y `attributes` recibe una ruta de
miembro. `all` ejecuta los seis. Salida 0: válido; 1: violaciones; 2: configuración o lectura inválida.
La salida textual inglesa contiene ruta, línea, ID estable y descripción. La biblioteca retorna
`Result<Vec<Violation>, String>`; el error es operativo, no una violación aceptable del producto.

## 3. Arquitectura y modelo del sistema

Un crate por capa, con dependencias declaradas en `architecture.yaml`:

| Capa | Responsabilidad | Puede importar | Prohibido |
|---|---|---|---|
| model | Contratos de reglas y diagnósticos | serde | source, checks, command |
| source | Lectura de fuentes Rust y reglas | model, syn, proc-macro2, lexer, serde_yaml, serde_json | checks, command |
| checks | Evaluación de reglas | model, source, syn, proc-macro2, serde_json | command |
| command | Adaptación CLI | checks, model | otras aplicaciones |
| tooling | Ejecución de puertas de calidad | biblioteca estándar | lógica del lenguaje |

Las carpetas `crates/<capa>/src` son la implementación; `tests` refleja sus módulos.
La capa source carga reglas y fuentes, checks reúne violaciones, command las presenta.
La ejecución es síncrona; el recorrido ordena rutas y diagnósticos para ser reproducible.
Los miembros Cargo, incluidas dependencias por target y desarrollo, se contrastan con reglas mediante
`cargo metadata --no-deps --format-version 1`. Los crates tooling también tienen lista cerrada.
Las dependencias internas siguen `may_import`; las externas siguen `external_dependencies`.

## 4. Decisiones de diseño y fundamentos técnicos

- **Problema:** expresiones regulares confunden cadenas y comentarios. **Elección:** lexer Rust para
  comentarios y `syn` para sintaxis, visitas y métricas. **Descartado:** un parser Rust propio por coste.
- **Problema:** no debe duplicarse el grafo de Cargo. **Elección:** metadatos Cargo, comparados contra
  reglas explícitas. **Descartado:** inferir dependencias desde imports, que omite targets y aliases.
- **Problema:** las excepciones de lint en código invalidan las reglas. **Elección:** atributos
  `allow`/`expect` prohibidos; tests separados con aserciones de test, sin unwrap/expect.
  **Descartado:** excepciones por archivo fuente sin contrato.
- **Problema:** los límites necesitan métricas consistentes. **Elección:** líneas físicas inclusivas
  por span; profundidad de bloques de control; métodos públicos agregados por tipo entre impls.
  Las funciones unsafe tienen límite propio y correspondencia exacta con la tabla del README.
  **Descartado:** contabilizar delimitadores dentro de literales como estructuras.
- **Problema:** el workspace se verifica a sí mismo. **Elección:** `xtask` usa procesos para formato,
  Clippy, auditoría, tests y el binario de reglas; los casos negativos se ejercitan desde tests.
  **Descartado:** incluir fixtures inválidos como miembros Cargo reales.
- **Problema:** los tests usan `assert!` y `assert_eq!` como contrato de prueba. **Elección:** esos
  contratos se admiten; los pánicos explícitos y unwrap/expect siguen prohibidos en tests.
- **Problema:** el proyecto es propietario y no publica estos crates. **Elección:** `publish = false`,
  sin inventar licencia pública; cargo-deny permite dependencias MIT/Apache-2.0/BSD/ISC/Unicode/Zlib.
  **Descartado:** asignar al proyecto una licencia de terceros. D-01 permanece para publicación.

## 5. Reglas de legibilidad, estilo y estructura de código

El código inglés no lleva comentarios, atributos doc, allow ni expect. `#![forbid(unsafe_code)]`
protege cada crate de R0. Límites y listas de nombres están únicamente en `architecture.yaml`.
Los tests se excluyen de tamaño, no de comentarios, nombres o atributos. Se inspeccionan `src`,
`tests`, ejemplos y build scripts; no se inspeccionan target, .git ni fixtures negativos.
Las declaraciones, aliases de imports, genéricos, bindings y tiempos de vida se verifican como declaraciones; rutas de terceros y
palabras de Rust no son nombres propios. Las firmas heredadas de traits externos no son nombres
propios renombrables: se verifican sus bindings y genéricos, no el nombre impuesto por el contrato. Los componentes camelCase y snake_case se normalizan.

## 6. Decisiones de producto que condicionan el código

ADR-001 exige una fundación sin motor. La ausencia de corpus en R0 no habilita implementar `see`,
conformidad, exportaciones ni capas del motor. No hay uso de unsafe en estos verificadores.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` ejecuta `cargo fmt --all --check`, Clippy estricto, tests del workspace,
`rust-checks all .` y `cargo deny check`. `deny.toml` define licencias, fuentes y duplicados.

| Verificador | Violación negativa |
|---|---|
| comments | Comentarios reales y atributos doc; cadenas con // válidas |
| names | Binding corto, abreviatura, genérico/lifetime corto y archivo prohibido |
| limits | Archivo, función, parámetros, anidación y métodos públicos excesivos |
| layers | Dependencia no permitida, crate ausente o no declarado |
| unsafe | Crate prohibido, función larga, fila ausente o huérfana |
| attributes | allow y expect, incluidas formas cfg_attr |
| Clippy | unwrap, expect y pánicos explícitos |
| toolchain | Miembros con versiones divergentes |

Entradas vacías, Rust inválido y reglas inválidas tienen tests explícitos. No se aprueba una fase
con un verificador fallando. La evidencia de aceptación vive en el informe de R0. No hay pendientes de implementación del verificador.

## 8. Fuentes consultadas y genealogía conceptual

Cargo aporta metadatos versionados y la convención xtask. syn aporta AST y spans; proc-macro2 spans
con posiciones; ra_ap_rustc_lexer tokenización; serde serialización; serde-saphyr/serde_json formatos.
Se rechaza usar rustdoc y comentarios SAFETY: el contrato exige documentación en README.
Las dependencias se usan para infraestructura, nunca como especificación del lenguaje PseudoLearn.

El lexer se fija a la serie 0.143; su API cubre tokens de comentarios y literales de Rust usados aquí.
Se usa serde-saphyr seguro en lugar de serde_yaml y forks con unsafe-libyaml sin mantenimiento. syn 3 evita versiones duplicadas
con serde_derive. Estas selecciones no alteran el comportamiento del lenguaje PseudoLearn.

La auditoría de licencias excluye solo crates privados con publish=false; sus dependencias externas
se auditan normalmente. Los avisos de seguridad no se ignoran.
