# see_cli

## 1. Qué es y qué no es

Orquesta archivos y procesos para new, validate, graph, lock, diff, impact, conform, matrix, feature, export, budget, math-arguments y math-check. Lee revisiones Git sin modificar el checkout, rechaza sobrescrituras y comprueba recursos generados. Los adaptadores ejecutables son engine y cli; `reference` solo conserva su manifiesto retirado.

`target-parity [--count N] [--seed S]` compara los adaptadores release nativo y wasm32-wasip1 del motor con Node WASI. Requiere compilar ambos previamente. Node usa `--no-incremental-marking`: en macOS arm64, la configuración local reproduce SIGSEGV al recolectar desde `uvwasi_fd_write` con memoria Wasm grande; desactivar el marcado incremental evita ese fallo del anfitrión sin cambiar el módulo. Guarda conteos, divergencias y tamaño Brotli en el directorio local ignorado de resultados; la matemática masiva se informa por separado y no se declara completa por este contraste.

## 2. Guía operativa y ciclo de vida

`runtime-fixtures` emite JSON de peticiones de ejecución materializadas con el traductor vigente y
escenarios de memoria derivados por el oráculo independiente. Usa semilla y muestras del vínculo de
transparencia de recolección, conserva hashes del corpus y no ejecuta sujetos ni modifica conformidad.

`cargo test -p see_cli`; `cargo check -p see_cli` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, format, graph, change, validation, conformance, report, export, translation. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: una regla estructural no produce un caso de ejecución. Elección: los vínculos con verificación `estructural` registran una observación del validador con hash del contrato, después de ejecutar `see validate`; se rechaza aplicarla a una regla que no declara verificación estructural. El esquema de límites y la cobertura de RI usan esta evidencia. Una revisión humana no se convierte en evidencia estructural automática.

Problema: las propiedades nativas necesitan un oráculo independiente y artefactos de proceso. Elección: `native_equivalence`, `native_diagnostics` y `native_roots` contrastan engine con aot sobre casos del corpus y grafos de memoria sembrados, con GC forzado para raíces; conserva códigos, argumentos y tramos de errores. Los ejecutores nativos de enlace, limpieza, permisos, códigos de salida y entorno compilan casos RT del corpus, borran la fuente y verifica dependencias, limpieza, permisos y ejecución desde otro directorio con entorno vacío. Se descarta declarar conformidad a partir del nombre de un test o de una exención del ejecutor.

El diferencial nativo exige igualdad de código, argumentos tipados y tramo de todos los diagnósticos de error, además de salida y terminación. La comparación con reference conserva sus exenciones y su contrato reducido. Se descarta comparar el texto traducido del diagnóstico.

Budget mide E-10 sobre archivos .pseudo de ejemplos locales: recoge candidatos de declaraciones y controles contados sin usar el sujeto ni descartar los que colisionan. Registra revisión Git, archivos, candidatos, presupuesto de lexemas y colisiones. Es una muestra editorial local, no una muestra de estudiantes ni evidencia suficiente para cambiar palabras reservadas.

Export comprueba además los recursos derivados; la correspondencia educativa se comprueba desde el índice del núcleo sin que el corpus dependa del índice. Los contratos estructurales producen evidencia separada del sujeto reference.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

Cuando el corpus contiene propiedades, `validate` exige `property-conformance.json` y contrasta el
esquema, el modelo tipado y sus referencias. Así retirar o desactualizar un vínculo es visible antes de ejecutar.

`conform --subject engine --operation properties` ejecuta los vínculos de propiedades del sujeto.
`--property <ID@versión#P>` selecciona uno; `--output <archivo>` conserva una ejecución dirigida sin sustituir la evidencia completa; `--seed`, `--samples` y `--sample` reproducen una muestra.
La selección explícita de muestra omite el recorrido exhaustivo del corpus. El artefacto separado
se guarda como `properties-<sujeto>.json` en el directorio local ignorado, sin sustituir resultados de
casos. Un vínculo pendiente o fallido devuelve código distinto de cero después de guardar su evidencia.

`math-arguments --output <directorio> [--count N] [--seed S]` escribe un archivo de argumentos por
función matemática (bits hexadecimales, uno o dos por línea) y un manifiesto con semilla y cantidad; por
omisión, un millón de argumentos y la semilla 20261015. `math-check --input <directorio>` lee esos
argumentos y los `.results` que escribe la herramienta del motor, calcula el esperado con el oráculo en
tantos hilos como núcleos haya y guarda el contraste con la revisión, la semilla, los conteos y una
muestra de discrepancias en el directorio local ignorado; devuelve error si alguna discrepa. Ninguna de las dos órdenes
lee el corpus. Los archivos crudos no se versionan porque se regeneran por semilla.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

El sistema especifica y contrasta el lenguaje vigente. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
