# xtask

## 1. Qué es y qué no es

Capa cli del sistema SEE; responsabilidad y contratos definidos en el README del miembro.

## 2. Guía operativa y ciclo de vida

`cargo test -p xtask`; `cargo check -p xtask` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Sin imports de crates del producto: ejecuta comandos por proceso y recorre archivos mediante la biblioteca estándar. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

La puerta DOC-NO-TRANSIENT-REFS examina archivos versionados de texto fuera de la carpeta documental de la raíz. Resuelve rutas relativas y enlaces a documentos internos. La validación del corpus tiene otra puerta: rechaza cualquier enlace HTTP externo dentro de una especificación y permite referencias entre identidades del corpus. Las pruebas incluyen enlaces internos permitidos y enlaces externos rechazados en bloques y prosa.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

R1 autoriza solo el sistema de especificaciones. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. No hay fuentes externas normativas.
