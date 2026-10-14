# pseudolearn_spec

## 1. Qué es y qué no es

Sistema de Especificaciones Ejecutables: corpus `see/1`, validación, anclaje, impacto y conformidad
por procesos. Sirve a quienes redactan contratos y a consumidores de la exportación JSON.
Responsabilidades: identidad del corpus, integridad de reglas y casos, evidencia por sujeto.
Fuera de alcance de producto: motor Rust, diferencial entre motores,
propiedades generativas y observación de memoria; pertenecen a fases posteriores.
Fuera de alcance técnico: imports del núcleo Dart, red durante conformidad, shell para ejecutar sujetos.
Casos de uso: crear un borrador, validar, bloquear versiones, comparar revisiones, contrastar un sujeto.
Pendientes declarados: propiedades generativas y reducción de contraejemplos (R2/R3, al incorporar
propiedades al corpus); sujetos Rust (R4).

## 2. Guía operativa y ciclo de vida

Rust exacto según `rust-toolchain.toml`, rustfmt, Clippy y cargo-deny 0.20.2. macOS, Linux y Windows.
Dart y las dependencias de desarrollo del núcleo son necesarios solo para `reference`.
Preparación: `cargo fetch`; desde el núcleo, `dart pub get`.
Desarrollo: `cargo run -p see_cli --bin see -- validate`.
Compilación: `cargo build --release`; binario `target/release/see`.
Todas las órdenes admiten `--root <directorio>` para seleccionar otro miembro de corpus.
Órdenes: `budget` (E-10 reproducible), `new <ID> --domain <dominio>`, `validate`, `graph [--focus ID] [--dot]`,
`lock [--check]`, `diff <rev>`, `impact <ID>`, `conform --subject reference [--only ID]`,
`matrix`, `feature <nombre>`, `export [--check]`.
`diff` lee la revisión con Git, sin cambiar el checkout. `lock` conserva versiones históricas;
una versión normativa ya anclada es inmutable. Código 0: éxito; 1: error o regresión exigible.
Conformidad conserva divergencias de reglas exentas sin ocultar los resultados crudos.
E-10 se reproduce con `cargo run -p see_cli --bin see -- budget`; la evidencia está en results/e10.json. E-14 registra el estudio humano diferido en results/e14.json. La correspondencia completa usa specifications/cases/migration.json y el índice educativo del núcleo.
Verificación: `cargo xtask verify`; incluye el corpus, anclaje y exportación actualizados.
La evidencia de E-15 vive en `results/e15.json`: ventana bruta de autoría automatizada por regla,
resultados y límites de interpretación. No mide autoría humana ni declara descubrimiento ciego.
No se despliega ni publica a un registro. La rama del monorepo contiene corpus y artefactos revisables.

## 3. Arquitectura y modelo del sistema

Workspace por capas, con listas cerradas en `architecture.yaml`. Ningún crate importa un miembro
ajeno; el tooling ejecuta los verificadores compartidos por proceso.

| Carpeta | Responsabilidad | Imports permitidos | Prohibido |
|---|---|---|---|
| see_model | Entidades de contratos | serde, serde_json | capas superiores, sujetos |
| see_format | Lectura de Markdown y YAML | model, serde-saphyr, serde_json | validación, procesos |
| see_oracles | Cálculo independiente de límites enteros | biblioteca estándar | sujetos |
| see_graph | Dependencias e impacto | model, semver | procesos, CLI |
| see_change | Hash canónico y clasificación | model, serde_json, sha2 | sujetos, CLI |
| see_validation | Integridad del corpus | model, graph, change, semver, serde_json | procesos |
| see_translation | Reimpresión léxica | model | sujeto, parser |
| see_conformance | Protocolo y comparación | model, translation, serde_json | internos de sujetos |
| see_export | Exportación de contratos | model, change, serde_json | sujetos |
| see_report | Matriz y características | model, serde_json | ejecución de sujetos |
| see_cli | Orquestación CLI | capas del producto, serde_json, serde-saphyr | otros miembros |
| xtask | Puertas locales | biblioteca estándar | lógica del producto |
| specifications | Contratos y recursos de casos | datos | implementación |
| schemas | Esquemas versionados | datos | implementación |
| fixtures | Violaciones deliberadas | datos | recorrido ordinario |
| results | Evidencia de conformidad | datos generados | oráculos capturados sin revisión |

Flujo: archivos → modelo → validación/grafo/hash → adaptador → comparación → matriz/exportación.
Ejecución síncrona y determinista. Un proceso por sesión negocia capacidades y procesa JSON por línea.
Cada petición y respuesta admite hasta un MiB; la sesión de reference usa quince segundos por operación.
La escritura se ejecuta en un hilo con confirmación y la lectura usa una cola acotada. El cierre exige
salida satisfactoria y conserva stderr. Un sujeto bloqueado es error operativo, nunca cumplimiento.

## 4. Decisiones de diseño y fundamentos técnicos

- El corpus y sus recursos son autosustentables. La investigación transitoria de la raíz no es una dependencia; una puerta local comprueba referencias externas y tiene casos negativos.
- La migración cubre la edición 2026, español e inglés y rigores estricto/flexible. Las palabras reservadas y restricciones de identificadores son las vigentes. NFC se aplica a nombres y reconocimiento léxico; literales, comentarios y posiciones originales se conservan.
- El índice documental del núcleo conserva la proyección educativa y una tabla completa de secciones hacia contratos existentes; la comprobación rechaza huecos, duplicados y destinos inexistentes.
- Los recursos de vocabulario, funciones y diagnósticos se extraen del corpus y se verifican contra la exportación. Ningún consumidor mantiene una copia manual.
- Los casos admiten semilla explícita; la ausencia conserva 42. La comparación preserva resultados desfavorables y exenciones específicas de reglas con resolución declarada.
- E-10 mide colisiones sobre programas locales con procedencia explícita. El estudio humano de E-14 requiere participantes y construcciones de la evolución del lenguaje; no se atribuyen resultados humanos a comprobaciones técnicas.

- Problema: prosa legible y datos verificables. Elección: Markdown con YAML y bloques tipados;
  serde-saphyr conserva la cadena segura usada en el monorepo. Se descarta DSL propio por coste.
- Problema: versión mutable por edición silenciosa. Elección: SHA-256 del JSON canónico ordenado del
  encabezado contractual y bloques, excluyendo títulos, resumen y prosa; historial en lock.
  Se descarta hashear bytes Markdown porque espacio y presentación no cambian obligaciones.
- Problema: estados y elementos persistentes. Elección: lock retiene identidades/versiones,
  valida transiciones y lápidas. Se descarta borrar historia al regenerar.
- Problema: oráculo circular. Elección: casos derivados de reglas, sujeto por JSONL, comparación de
  multiconjuntos completos y tramos declarados. El campo `arbol` permite contrastar recuperación.
  Se descarta deduplicar diagnósticos o completar árboles nulos, porque ocultaría defectos.
- Problema: reimprimir sin cambiar identidades. Elección: recursos bilingües normativos independientes
  del adaptador, incluidos alias y nombres de funciones; reemplaza tokens fuera de cadenas/comentarios, conserva trivia y detecta colisiones.
  Casos pueden dar programas explícitos por perfil. Se descarta pedir traducción al sujeto.
- Problema: divergencias conocidas de un sujeto congelado. Elección: vínculos `exento` con hallazgo;
  resultados conservan `incumple` y la matriz muestra ambas cosas. Se descarta corregir Dart.
- Problema: verificación humana y N3 no se pueden fingir como ejecución. Elección: justificación
  obligatoria para revisión humana, propiedades sin ejecutor marcadas no aplicables. Se descarta
  declarar cumplimiento por ausencia de casos. El arranque SEE queda en borrador tras revisión
  estructural manual; los contratos restantes entran en experimental bajo la autorización de R1.
- Problema: clasificar significado requiere juicio. Elección: diff propone clases y exige registro
  de clasificación e impacto; cambios de texto quedan para revisión. No infiere aprobación humana.

### Hallazgos del sujeto reference

Identidades permanentes de evidencia, independientes de la investigación transitoria. Los esperados son normativos; las exenciones solo afectan al sujeto congelado y se resuelven en R4. La matriz mide los casos declarados, no una demostración universal del contrato.

| Hallazgo | Diferencia observable | Resolución |
|---|---|---|
| H-05 | Devuelve árbol nulo ante texto vacío aunque debe conservar estructura recuperable. | R4 |
| H-06 | El literal negativo fuera de rango provoca expectedExpression duplicado después del error léxico. La recuperación emite expectedExpression duplicado para una sentencia malformada. | R4 |
| H-37 | No emite controlVariableModified sobre la modificación directa del control de un bucle. | R4 |
| REF-FLEXIBLE-INITIALIZATION | No emite la advertencia estática de lectura sin inicializar en flexible, aunque la política la declara. | R4 |
| REF-INVALID-SYMBOL-CASCADE | El chequeo agrega inicialización o aridad sobre símbolos con resolución inválida; se conserva el error original sin añadir consecuencias del símbolo sintético. El parámetro duplicado reduce artificialmente la aridad y provoca argumentCountMismatch en una llamada con dos argumentos para dos parámetros declarados. Informa inicialización sobre un identificador cuya resolución ya falló por ausencia de declaración. | R4 |
| REF-OBJECT-CONTEXT | Acepta Este y Super fuera de métodos sin los diagnósticos sintácticos requeridos. | R4 |
| REF-SOURCE-BOM | El lexer reconoce el BOM inicial como carácter inválido en vez de excluirlo de los tokens. | R4 |
| REF-SOURCE-NFC | No reconoce como el mismo nombre la grafía compuesta y la descompuesta por ausencia de NFC. | R4 |
| REF-STATEMENT-CASCADE | Tras rechazar un inicializador en declaración agrega missingStatementTerminator sobre la misma sentencia. | R4 |
| REF-STATIC-MEMBER-CHECK | No informa acceso privado durante análisis aunque el receptor tiene tipo de clase declarado. No informa el miembro inexistente durante análisis sobre un receptor de clase conocido. | R4 |
| REF-STRICT-INFERENCE | Emite inferredVariableType en estricto después del error de declaración; la inferencia informativa pertenece al modo flexible. | R4 |
| REF-STRUCTURAL-RECOVERY | Agrega unexpectedTokenInExpression después de classInsideAlgorithm en el mismo bloque inválido. Agrega unexpectedTokenInExpression tras methodOutsideClass en el mismo bloque inválido. La recuperación agrega unexpectedStatement al cierre de una construcción estructural ya diagnosticada. Agrega un diagnóstico del cierre tras rechazar la construcción ajena a la edición. | R4 |
| REF-UNCLOSED-BLOCK-CASCADE | Al llegar a EOF informa cada bloque exterior sin cerrar además del bloque más interno. | R4 |
| REF-UNICODE-CHARACTER | Clasifica el literal suplementario como cadena por su longitud UTF-16; un escalar debe ser carácter. El carácter suplementario se tipa como cadena y se rechaza al consultar su código Unicode. CodigoDe rechaza el literal suplementario que debe ser un carácter, impidiendo la ejecución del caso Unicode. | R4 |

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés sin comentarios, doc/allow/expect, unsafe ni pánicos explícitos. Fallos esperables
son `Result`; las fronteras de CLI y adaptador los convierten en respuesta/código de salida.
Límites y nombres se leen exclusivamente de `architecture.yaml`. Tests espejo de módulos;
no se duplican casos del corpus en tests del núcleo.

## 6. Decisiones de producto que condicionan el código

La resolución inválida de un símbolo impide diagnosticar inicialización o aridad derivadas de ese símbolo: se conserva el error original y cualquier error independiente. Una firma con nombres duplicados no reduce aridad para generar una cascada sobre llamadas compatibles. Estas obligaciones viven en DIAG.CLASSES y se contrastan con reference sin alterar el sujeto.

`SEE.FORMAT`, `SEE.IDENTITY` y `SEE.LIFECYCLE` definen el arranque.
`SEE.VALIDATION`, `SEE.ORACLE.POLICY` y `SEE.CONFORMANCE.MATRIX` separan validez, origen y evidencia.
Los contratos del lenguaje conservan expectativas normativas aunque `reference` discrepe.
El lenguaje está en experimental; escribir el motor Rust requiere completar sus contratos de frontera. El corpus es la fuente de comportamiento;
este README explica arquitectura y operación.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify`: formato, Clippy estricto, tests, seis verificadores Rust, versión de cadena,
cargo-deny (avisos, licencias, duplicados y fuentes), `see validate`, `see lock --check`, `see export --check` y conformidad reference.
Los casos negativos prueban duplicados, regla huérfana, captura sin revisor, hash/version,
ciclos y perfil faltante; otros prueban esquema, referencias, rango, estados y clasificación.
Las pruebas de protocolo incluyen negociación inválida, JSON corrupto, EOF, timeout y capacidad ausente.
Las pruebas de traducción incluyen cadenas, comentarios, ida/vuelta y colisión.
Las dependencias internas declaran versión y ruta; no hay excepciones de auditoría. Los fallos esperados del piloto se conservan como evidencia,
con exenciones justificadas; cualquier vínculo cumple que falle impide verificar.

## 8. Fuentes consultadas y genealogía conceptual

Los contratos SEE definen see/1, identidad, fases de ciclo de vida y protocolo. Cargo aporta workspaces,
metadatos y xtask; serde aporta contratos de datos; semver rangos; SHA-256 anclaje canónico.
Se toma el modelo de versión semántica para cambios declarados; se rechaza equiparar cambio
textual con clasificación semántica definitiva. No se consultan fuentes externas para decidir
comportamiento del lenguaje.
