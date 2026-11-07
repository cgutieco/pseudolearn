# route_resolve

## 1. Qué es y qué no es

Convierte cada lección y cada ejercicio fuente de la ruta de aprendizaje en su forma publicada para un idioma de interfaz y un perfil de sintaxis: tira del ciclo, encabezados de fase, ficha, roles, apertura de paradigma, tarjetas de recuerdo, enlaces y figuras de la Especificación, práctica, siguiente y la evaluación de cada tipo de ejercicio. Ejecuta los programas de cada ejercicio con los casos de su fuente y entrega esas ejecuciones al verificador. No juzga si un ejercicio está bien: eso es de `reference_verify`.

## 2. Guía operativa y ciclo de vida

`cargo test -p route_resolve` y `cargo clippy -p route_resolve --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model`, `reference_format` y `reference_resolve`; recibe el motor por el puerto a través de `Resolution`. Los bloques que la ruta comparte con la Especificación (párrafos, tablas, programas, figuras) se resuelven con `reference_resolve`; este crate solo agrega lo propio de la ruta. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

- Problema: las tarjetas «Recuerda» repetirían a mano una definición. Elección: `build_catalog` toma la frase del ítem etiquetado del resumen de la lección dueña y la tarjeta se genera desde ahí.
- Problema: la traza del motor no publica valores de variables. Elección: `rastrear` inserta antes de la línea marcada una instrucción que escribe las columnas entre `⟦` y `⟧`, ejecuta el programa instrumentado y lee una fila por línea marcada; el programa instrumentado nunca se publica.
- Problema: un ejercicio verificado en cuatro ediciones repetiría cada juicio. Elección: las ejecuciones para verificar se hacen solo en el perfil español; los datos publicados de cada edición (salidas esperadas, filas, bloques) salen de ejecutar el programa traducido de esa edición.
- Problema: un ejercicio para ordenar publicado en el orden correcto regala la respuesta. Elección: un orden determinista derivado del identificador del ejercicio, nunca igual al original.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La app nunca muestra un mutante ni la referencia: viajan en `evaluation`, aparte de los bloques visibles.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con un motor falso: camino feliz, camino infeliz (intento sin respuesta, recuerdo sin dueña, figura o sección inexistente, práctica con un ejercicio desconocido, datos de ejercicio dentro de una lección) y casos límite (orden de cero y un elemento, programa vacío).

## 8. Fuentes consultadas y genealogía conceptual

Los problemas de Parsons inspiran el tipo `ordenar`; las pruebas por mutación inspiran `disenar-pruebas`. Se toma la idea y se rechaza la puntuación numérica.
