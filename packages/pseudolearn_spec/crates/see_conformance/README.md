# see_conformance

## 1. Qué es y qué no es

Negocia JSONL por proceso con capacidades explícitas, ejecuta casos en perfiles y rigores declarados y compara observables. La escritura y lectura tienen timeout; el cierre conserva stderr. No deduplica diagnósticos ni completa árboles.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_conformance`; `cargo check -p see_conformance` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

`runtime_fixtures` materializa casos con el mismo constructor de peticiones de conformidad; sus
programas generados de grafos conservan el resultado independiente de `see_oracles::cells`. Esta
preparación de datos no anuncia capacidades de ningún sujeto ni produce un veredicto de conformidad.
Los escenarios de memoria B4 usan un arreglo de referencias como raíz de objetos y texto durante una
llamada, e incluyen un objeto local sin usos posteriores para comprobar que no se vuelve raíz. El resultado
esperado incluye el costo del arreglo y la alcanzabilidad calculada por el oráculo independiente; los
programas se traducen con el vocabulario exportado y consumen la semilla/cantidad ya registradas.

Imports internos permitidos: model, translation, generators, oracles; format solo en tests. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Las peticiones de ejecución del corpus fijan explícitamente 1 000 marcos cuando el caso no declara profundidad, para comparar los sujetos bajo el mismo límite. Un límite declarado prevalece. Los valores por omisión de cada producto se verifican en sus pruebas de anfitrión; no se infieren de esta configuración experimental.

La correspondencia entre ejecución rápida y observada consume la ejecución observada por lotes de la API pública cuando el sujeto anuncia posicionamiento con recursos; los sujetos anteriores conservan la operación directa. Así una traza larga no rebasa el límite JSONL de una respuesta; el contraste conserva salida, terminación, diagnósticos y entradas consumidas. Los análisis rechazados se comparan por la operación directa, porque no pueden iniciar un recurso de ejecución. Se descarta ampliar el límite del transporte para acomodar una traza completa.

El contraste entre objetivos materializa peticiones de ejecución y traza con el mismo traductor del corpus. Los programas sembrados se generan fuera del sujeto; su variante EMI elimina un bloque condicional de condición falsa agregado al final del algoritmo. La equivalencia EMI compara salida y terminación, mientras la paridad entre objetivos compara la respuesta completa de cada variante por separado. Se descarta exigir trazas idénticas entre fuentes distintas.

diagnosticos compara multiconjuntos; diagnosticos_ordenados compara en orden los mismos campos observables. Ninguna comparación ordena ni deduplica resultados del sujeto. La semilla del caso se transmite sin transformación a seed del protocolo; su ausencia usa 42. `cancelacion_prueba` se transmite como `cancel_at_poll`, independiente de la cancelación por sentencia. El contador incluye condiciones para cancelar también bucles vacíos. La fuente y sus tramos se transmiten originales, también en casos de normalización NFC.

En proyecciones de páginas, `next_cursor: "opaque"` exige un cursor no vacío, sin fijar su codificación. `candidates_include` comprueba pertenencia y no orden. `tokens_include` comprueba que cada token esperado aparece con la identidad y los campos declarados, sin exigir igualdad con toda la secuencia ni excluir la trivia. Se descartan comparar estos marcadores literalmente, porque fijarían detalles ajenos al contrato.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

La ejecución de propiedades lee vínculos versionados, deriva escenarios del corpus y añade programas
bien tipados por semilla. La frontera `PropertySubject` permite procesos reales y dobles que introducen
una violación deliberada: la lógica de contraste no depende del transporte. Una capacidad ausente produce
pendiente con cero muestras completadas. Nunca equivale a cumplimiento. El primer desacuerdo conserva
petición, esperado, observado y comando de repetición; un fallo operativo se propaga como tal.

El contraste matemático de `LIB.CORE.MATH` vive en `math_sampling.rs`, `math_arguments.rs`,
`math_power_arguments.rs` y `math_contrast.rs`. Un muestreador SplitMix64 con semilla genera, por
función, argumentos aleatorios por bits, por magnitud logarítmica y uniformes en el rango útil, junto con
bordes (ceros con signo, subnormales, `f64::MAX`, umbrales de desbordamiento de `exp`), cercanía a uno en
`ln` y `atan`, cercanía a múltiplos de π/2 en seno y coseno, y en la potencia bases negativas con
exponente entero, raíces perfectas con exponentes `k/2` y `k/4` y bases cercanas a uno con exponentes
grandes. El esperado sale siempre de `see_oracles`; un dominio inválido o un resultado infinito se
reduce a `nonFiniteRealResult`, que es lo único observable. Se descarta una malla regular, que no
alcanza los argumentos difíciles, y muestrear con la biblioteca del anfitrión.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

El sistema especifica y contrasta el lenguaje vigente. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
