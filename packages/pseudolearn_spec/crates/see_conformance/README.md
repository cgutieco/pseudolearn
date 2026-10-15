# see_conformance

## 1. Qué es y qué no es

Negocia JSONL por proceso con capacidades explícitas, ejecuta casos en perfiles y rigores declarados y compara observables. La escritura y lectura tienen timeout; el cierre conserva stderr. No deduplica diagnósticos ni completa árboles.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_conformance`; `cargo check -p see_conformance` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, translation, generators, oracles; format solo en tests. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

diagnosticos compara multiconjuntos; diagnosticos_ordenados compara en orden los mismos campos observables. Ninguna comparación ordena ni deduplica resultados del sujeto. La semilla del caso se transmite sin transformación a seed del protocolo; su ausencia usa 42. `cancelacion_prueba` se transmite como `cancel_at_poll`, independiente de la cancelación por sentencia. El contador incluye condiciones para cancelar también bucles vacíos. La fuente y sus tramos se transmiten originales, también en casos de normalización NFC.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

La ejecución de propiedades lee vínculos versionados, deriva escenarios del corpus y añade programas
bien tipados por semilla. La frontera `PropertySubject` permite procesos reales y dobles que introducen
una violación deliberada: la lógica de contraste no depende del transporte. Una capacidad ausente produce
pendiente con cero muestras completadas. Nunca equivale a cumplimiento. El primer desacuerdo conserva
petición, esperado, observado y comando de repetición; un fallo operativo se propaga como tal.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

El sistema especifica y contrasta el lenguaje vigente. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
