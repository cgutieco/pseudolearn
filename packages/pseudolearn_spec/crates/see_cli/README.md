# see_cli

## 1. Qué es y qué no es

Orquesta archivos y procesos para new, validate, graph, lock, diff, impact, conform, matrix, feature, export y budget. Lee revisiones Git sin modificar el checkout, rechaza sobrescrituras y comprueba artefactos generados. Los adaptadores ejecutables son reference, engine y cli.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_cli`; `cargo check -p see_cli` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, format, graph, change, validation, conformance, report, export, translation. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Budget mide E-10 sobre archivos .pseudo de ejemplos locales: recoge candidatos de declaraciones y controles contados sin usar el sujeto ni descartar los que colisionan. Registra revisión Git, archivos, candidatos, presupuesto de lexemas y colisiones. Es una muestra editorial local, no una muestra de estudiantes ni evidencia suficiente para cambiar palabras reservadas.

Export comprueba además los recursos derivados; la correspondencia educativa se comprueba desde el índice del núcleo sin que el corpus dependa del índice. Los contratos estructurales producen evidencia separada del sujeto reference.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

Cuando el corpus contiene propiedades, `validate` exige `property-conformance.json` y contrasta el
esquema, el modelo tipado y sus referencias. Así retirar o desactualizar un vínculo es visible antes de ejecutar.

`conform --subject engine --operation properties` ejecuta los vínculos de propiedades del sujeto.
`--property <ID@versión#P>` selecciona uno; `--seed`, `--samples` y `--sample` reproducen una muestra.
La selección explícita de muestra omite el recorrido exhaustivo del corpus. El artefacto separado
`results/properties-<sujeto>.json` conserva evidencia sin sustituir resultados de casos. Un vínculo
pendiente o fallido devuelve código distinto de cero después de guardar su evidencia.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

El sistema especifica y contrasta el lenguaje vigente. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
