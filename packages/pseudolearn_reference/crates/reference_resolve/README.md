# reference_resolve

## 1. Qué es y qué no es

Convierte cada documento fuente en una sección publicada para un idioma de interfaz y un perfil de sintaxis: tokeniza y traduce el código en línea, las formas y los programas; ejecuta los ejemplos en español y en el perfil de destino; produce figuras, raíles, representación intermedia, traza y apéndices generados.

## 2. Guía operativa y ciclo de vida

`cargo test -p reference_resolve` y `cargo clippy -p reference_resolve --all-targets -- -D warnings` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Importa `reference_model`, `reference_corpus` y `reference_figures`; recibe el motor por el puerto. La dirección de dependencias está en `architecture.yaml` del miembro. `src/` implementa la capa; `tests/` refleja sus módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: mantener dos versiones de cada programa. Elección: los programas y las formas se escriben una vez en español; la edición inglesa los reutiliza por identificador y el motor los traduce. Un programa con errores de sintaxis no se puede traducir con `translate_source`, así que se traduce token a token con la misma ortografía canónica del motor (mayúscula inicial en inglés, salvo acceso a miembros y llamadas). `CachedEngine` memoriza ejecuciones porque cada programa aparece en cuatro ediciones.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml`; código en inglés sin comentarios ni `unsafe`.

## 6. Decisiones de producto que condicionan el código

La persona lectora nunca ve identificadores del corpus; ver el README del miembro.

## 7. Verificación, testing y aseguramiento de calidad

Tests espejo con camino feliz, camino infeliz y casos límite; los casos negativos de cada verificador viven en `tests/`.

## 8. Fuentes consultadas y genealogía conceptual

Plan del miembro y contrato del paquete descritos en el README del miembro.
