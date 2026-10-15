# see_model

## 1. Qué es y qué no es

Define Metadata, Block, Specification, Anchor, Manifest, Conformance, PropertyRun y Evidence como datos serializables. La frontera pública no ejecuta sujetos ni interpreta programas.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_model`; `cargo check -p see_model` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: ninguno. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

La evidencia de propiedades conserva semilla, número de muestras solicitadas y completadas, veredicto y
el primer contraejemplo con programa, perfil, rigor, esperado, observado y comando de reproducción.
Un registro vacío o con capacidad ausente no equivale a cumplimiento. El campo `properties` es opcional
al leer evidencia histórica y se omite al escribir una lista vacía para conservar compatibilidad JSON.

`PropertyRegistry` contiene el vínculo entre una propiedad versionada y un algoritmo de contraste,
con semilla y cantidad. El vínculo vive en `property-conformance.json`, nunca en el código de un ejecutor.
Los algoritmos se identifican por responsabilidad; una entrada no declara que la propiedad se haya ejecutado.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

R1 autoriza solo el sistema de especificaciones. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
