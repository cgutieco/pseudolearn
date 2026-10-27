# pseudolearn_diagnostics

## 1. Qué es y qué no es

Representa diagnósticos mediante códigos con argumentos tipados. Implementación disponible en el workspace.

Los códigos de pureza (`pureFunctionSideEffect`, `pureFunctionTransitiveSideEffect`, `pureFunctionInterfaceImpurity`) no declaran argumentos: la ruta de propagación de la impureza viaja en `Diagnostic::related`, uno por unidad de la cadena de llamadas, y la emite `pseudolearn_semantic::effect_check`.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Hito técnico |
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

Invariantes: Ningún texto de idioma dentro del modelo: se renderiza en el borde. `sort_diagnostics_with`
recibe claves canónicas de fuente desde el consumidor y ordena por nombre de paquete en NFC/minúsculas Unicode,
segmentos de módulo en NFC conservando caja, fase,
tramo inicial y final, código, severidad, argumentos tipados y secuencia ordenada de ubicaciones relacionadas.
Las fuentes ausentes quedan al final; los diagnósticos sin fuente no reciben una fuente inventada. El orden
no usa IDs opacos, prosa localizada ni orden de descubrimiento. La entrada `sort_diagnostics` conserva el
orden local de documentos individuales.

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: representa y ordena diagnósticos mediante códigos con argumentos tipados respetando los observables del corpus.
Elección: `Diagnostic { code, class, severity, span, related, arguments }`; `enum DiagnosticCode` generado; plantillas bilingües generadas; ordenación de `DIAG.ORDERING` con claves de fuentes suministradas por la API. La identidad opaca se conserva en el resultado, pero nunca participa en la comparación. Los relacionados conservan multiplicidad y orden significativo; los errores de documento individual mantienen la ordenación local por ubicación.
Alternativas descartadas y fundamento: El corpus DIAG aporta el catálogo y las plantillas. Se rechaza traducir lexemas del usuario o mezclar idioma de interfaz con vocabulario.

Problema: clase y severidad deben coincidir con la ficha del corpus. Elección: el generador valida
las clases cerradas lexical, syntax, semantic, runtime e internal y genera las dos severidades.
El modelo conserva códigos, tramos y argumentos; la selección de rigor consulta la tabla generada.
Se rechaza inferir clase por un prefijo del código o tratar una clase desconocida como fallo interno.

Los argumentos conservan su clase: lexema, token, tipo, término o número. El catálogo genera la ficha
de argumentos requeridos; el borde valida que no falten claves ni se sustituyan números por cadenas.
Los tokens y tipos primitivos se resuelven con el vocabulario del programa antes de presentar prosa.
La sustitución recorre la plantilla una sola vez y no reinterpreta llaves dentro de un lexema del usuario.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `DIAG.*`.
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan. Cada diagnóstico conserva el ID de la fuente de su tramo y de cada tramo relacionado; un consumidor no aplica coordenadas de un archivo a otro.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

El corpus DIAG aporta el catálogo y las plantillas. Se rechaza traducir lexemas del usuario o mezclar idioma de interfaz con vocabulario.
