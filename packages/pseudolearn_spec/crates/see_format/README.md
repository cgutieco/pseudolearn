# see_format

## 1. Qué es y qué no es

Convierte el encabezado YAML y los bloques cercados tipados de Markdown en Specification; acepta secuencias YAML y CRLF. La prosa fuera de bloques no ingresa al modelo. Rechaza enlaces documentales externos en prosa y bloques tipados, pero admite direcciones HTTP y HTTPS como datos de protocolo en ejemplos y anfitriones falsos. Escribe una representación canónica legible sin alterar programas. Los fallos de lectura y formato se devuelven como Result.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_format`; `cargo check -p see_format` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: el corpus no debe citar documentación externa, mientras los casos de protocolo necesitan direcciones URL. Elección: se rechazan direcciones web usadas como enlaces documentales y referencias `www.`; se admiten como datos de ejemplos y anfitriones falsos. Las relaciones entre especificaciones se expresan por sus identidades internas.
Se descarta prohibir cada aparición de `http://` y `https://`, porque impediría especificar comportamiento de red como datos de prueba.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

R1 autoriza solo el sistema de especificaciones. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; los tests espejo cubren enlaces internos, enlaces externos en bloques y enlaces externos en prosa.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.
