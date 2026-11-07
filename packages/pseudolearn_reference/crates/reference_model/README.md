# reference_model

## 1. Qué es y qué no es

Tipos de datos del compilador: documento fuente, bloques, fragmentos en línea, sección publicada, violaciones con ID estable y el puerto `CodeEngine` hacia el motor. No lee archivos ni ejecuta nada.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_model` y `cargo clippy -p reference_model --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Ninguna capa interna; solo `serde` para serializar el paquete. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: el resto de capas necesita hablar el mismo idioma sin depender del motor. Elección: el puerto `CodeEngine` (tokenizar, traducir, ejecutar, representación intermedia y huella) vive aquí y lo implementa `reference_engine`; así resolución y verificación se prueban con motores falsos. Los tokens se serializan como pares `[texto, categoría]` para reducir el paquete a la mitad frente a objetos con claves; se descartó un formato binario porque Flutter y Astro leen JSON sin dependencias.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
