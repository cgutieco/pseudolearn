# pseudolearn_cli

## 1. Qué es y qué no es

Binario pseudo para comprobar, ejecutar e inspeccionar programas. Análisis y preferencias implementados; ejecución e inspección pendientes de sus capas.
Fuera de alcance: semántica propia del lenguaje, UI gráfica y configuración ejecutable.

| Pendiente | Dependencia | Fase |
|---|---|---|
| ejecutar/run y ri/ir | API de ejecución | R5 |
| compilar/build | Backend nativo | R6 |
| formatear/format, traducir/translate, lsp | Servicio de lenguaje | R7 |

## 2. Guía operativa y ciclo de vida

Binario de línea de comandos implementado en Rust.
Comandos de compilación y verificación:
- Verificación completa del miembro: `cargo xtask verify`.
- Compilación de producción: `cargo build --release` (salida en `target/release/pseudo`).
- Pruebas unitarias y funcionales: `cargo test`.
- Conformidad desde `packages/pseudolearn_spec`: `cargo run -p see_cli --bin see -- conform --subject cli --operation cli`.
- Adaptador del protocolo SEE para pruebas automatizadas: `pseudo --see-adapter`.
Distribución nativa en macOS, Linux y Windows. Sin secretos.

## 3. Arquitectura y modelo del sistema

Adaptador de borde → API pública de pseudolearn_engine. Prohibido importar sus crates internos.
Flujo: argumentos y entorno → configuración explícita → API → presentación o JSON.
Sin estado global de ejecución. I/O solo en el adaptador; el núcleo recibe capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: separar idioma de lector y autor. Elección: vocabulario por primera apertura significativa después de BOM y trivia; API.ANALYZE recibe perfil explícito.
Las aperturas no colisionan entre perfiles; --vocabulario/--vocabulary fuerza es o en cuando no se puede deducir. Texto vacío usa español con diagnóstico si no se fuerza.
El idioma de interfaz sigue --idioma/--language > PSEUDO_IDIOMA/PSEUDO_LANGUAGE > preferencias declarativas de usuario > sistema (LC_ALL, LC_MESSAGES, LANG o preferencia nativa) > español.
Preferencias: pseudo preferencias idioma en, alias pseudo preferences language en; archivo de datos idioma = "en" en configuración de usuario de la plataforma.
La grafía de la orden, el archivo y su vocabulario nunca deciden el idioma de interfaz.
Alternativas descartadas: comentarios mágicos, configuración ejecutable y manifiesto de proyecto para una preferencia personal.
Los alias ingleses siempre se aceptan y conservan idénticos efectos y salida.
Opciones: --rigor/--strictness, --traza/--trace, --json. La ayuda muestra forma del idioma de interfaz y la otra como alias.

`build.rs` genera el catálogo de mensajes desde la exportación de `TOOL.CLI.MESSAGES`.
La sustitución de argumentos recorre la plantilla una sola vez, preservando llaves en lexemas del usuario.
Los tramos públicos ya contienen línea y columna; la CLI los presenta sin convertir offsets.
La prosa de diagnóstico se renderiza por código y argumentos en el idioma de interfaz.

La extensión de ejecutar/run usará únicamente la API pública con entrada estándar, semilla, límites
de profundidad, sentencias y celdas. La traza se narra con las plantillas trace* del catálogo generado;
la salida del programa se conserva literalmente. ri/ir imprime la RI canónica de la API o el diagnóstico
de la primera violación. No se introduce semántica propia ni se accede a capas internas. Los casos cli
verifican ambos idiomas, opciones equivalentes, códigos de salida y errores operativos.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios. Mensajes desde TOOL.CLI.MESSAGES y DIAG.MESSAGES generados; sin copias ni prosa en la lógica.
Errores como valores y códigos de salida de TOOL.CLI.CONVENTIONS; ningún pánico cruza la frontera.
Las reglas del miembro se declaran antes de escribir código.

## 6. Decisiones de producto que condicionan el código

La salida del programa y los valores siguen su vocabulario. Narración de traza, diagnósticos, ayuda y progreso siguen idioma de interfaz.
Códigos, claves JSON y formato de intercambio son independientes del idioma.
Contratos TOOL.CLI.CONVENTIONS, MESSAGES, CHECK, RUN e IR; límites por defecto según ENG.LIMITS.

## 7. Verificación, testing y aseguramiento de calidad

Tests de precedencia de cada fuente de idioma, alias equivalentes, aperturas bilingües, BOM, trivia, texto vacío, argumentos inválidos y error operativo.
Conformidad contra casos cli del corpus en ambos idiomas; --json estable al cambiar idioma.
Verificadores, formato, Clippy, dependencias y tests mediante cargo xtask verify al implementar.

## 8. Fuentes consultadas y genealogía conceptual

El corpus TOOL.CLI es normativo. Las convenciones de CLI y gettext inspiran precedencia de preferencias; se rechaza que una forma de orden traduzca implícitamente la salida. LSP aporta locale para el idioma del cliente.
