# reference_corpus

## 1. Qué es y qué no es

Lectura de la exportación `see-export/1` como dato: léxico bilingüe (palabras reservadas, contextuales, funciones y operaciones de capacidad), especificaciones con la huella de cada regla, diagnósticos, fichas de ayuda y producciones de la gramática.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_corpus` y `cargo clippy -p reference_corpus --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model`; usa `serde_json` y `sha2`. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: el compilador no debe copiar a mano nada que el corpus ya define (`GEN-NO-HAND-COPY`). Elección: todas las tablas salen de la exportación y la huella de una regla es el SHA-256 de su bloque serializado, que alimenta el candado de anclas. Las búsquedas de lexemas pliegan mayúsculas y tildes igual que el motor.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
