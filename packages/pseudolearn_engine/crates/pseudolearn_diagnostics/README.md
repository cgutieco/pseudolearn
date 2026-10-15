# pseudolearn_diagnostics

## 1. Qué es y qué no es

Representa diagnósticos mediante códigos con argumentos tipados. Implementación disponible en el workspace.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Fase |
|---|---|---|
| Ninguno en el contrato de análisis implementado | — | — |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 1. Dependencias internas permitidas: pseudolearn_source. Externas: biblioteca estándar y serde_json exclusivamente para generación durante el build.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: `Diagnostic { code, class, severity, span, related, arguments }`; `enum DiagnosticCode` generado; plantillas bilingües generadas; ordenación de `DIAG.ORDERING`.

Invariantes: Ningún texto de idioma dentro del modelo: se renderiza en el borde.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: representa diagnósticos mediante códigos con argumentos tipados respetando los observables del corpus.
Elección: `Diagnostic { code, class, severity, span, related, arguments }`; `enum DiagnosticCode` generado; plantillas bilingües generadas; ordenación de `DIAG.ORDERING`.
Alternativas descartadas y fundamento: El corpus DIAG aporta el catálogo y las plantillas. Se rechaza traducir lexemas del usuario o mezclar idioma de interfaz con vocabulario.

Problema: clase y severidad deben coincidir con la ficha del corpus. Elección: el generador valida
las clases cerradas lexical, syntax, semantic, runtime e internal y genera las dos severidades.
El modelo conserva códigos, tramos y argumentos; la selección de rigor consulta la tabla generada.
Se rechaza inferir clase por un prefijo del código o tratar una clase desconocida como fallo interno.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `DIAG.*`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

El corpus DIAG aporta el catálogo y las plantillas. Se rechaza traducir lexemas del usuario o mezclar idioma de interfaz con vocabulario.
