# see_translation

## 1. Qué es y qué no es

Reimprime lexemas del recurso bilingüe preservando cadenas, comentarios, trivia e identificadores. Detecta colisiones de nombres reservados fuera de literales y resuelve marcadores de salida. El vocabulario completo pertenece a R2.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_translation`; `cargo check -p see_translation` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

El vocabulario consumidor incluye alias derivados, con prioridad de forma canónica al reimprimir. Las identidades con prefijo function: solo se traducen en posición de llamada; nunca se renombran variables que oculten nombres de funciones ni se cuentan como reservadas para colisiones. Los nombres declarados de subprogramas, métodos y clases y los accesos detrás de punto conservan identidad aunque coincidan con una función incorporada. Se preservan literales, comentarios y fronteras de identificador.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

R1 autoriza solo el sistema de especificaciones. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
