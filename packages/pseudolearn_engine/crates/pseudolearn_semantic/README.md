# pseudolearn_semantic

## 1. Qué es y qué no es

Produce un HIR tipado desde la resolución estática. El análisis registra firmas antes de resolver cuerpos y produce expresiones tipadas en columnas.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Fase |
|---|---|---|
| Ninguno en el contrato de análisis implementado | — | — |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 3. Dependencias internas permitidas: pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax. Externas: biblioteca estándar.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Columnas con índices tipados (`LocalId`, `FunctionId`, `ExpressionId`, `TypeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; resolución de jerarquía y ranuras virtuales en mundo cerrado.

Invariantes: No hay fases semánticas con errores sintácticos; un símbolo inválido no genera cascadas (`DIAG.CLASSES`).

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: produce un hir tipado desde la resolución estática respetando los observables del corpus.
Elección: Columnas con índices tipados (`LocalId`, `FunctionId`, `ExpressionId`, `TypeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; resolución de jerarquía y ranuras virtuales en mundo cerrado.
Alternativas descartadas y fundamento: Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.


Problema: la traducción necesita identidades, tipos y designadores estables, sin resolver nombres otra vez.
Elección: seis responsabilidades separadas: registro de unidades y firmas, jerarquía, resolución de
variables por unidad, tipos y rigor, flujo y emisión. `HirModule` conserva funciones, clases, locales,
columnas de expresiones y columnas de sentencias. Los identificadores de arena son tipos distintos.
Cada expresión tiene tipo internado, clase escalar o referencia y tramo. `HirPlace` distingue ubicaciones
asignables; `Widen` materializa la ampliación entero → real. Las incorporadas usan la firma generada.
El nombre de una variable pertenece al algoritmo, subprograma o método; los bloques estructurados
comparten ese ámbito, como exige `LANG.SUBPROGRAM.SCOPE`. El flujo de asignación sí se separa por
rama y combina con intersección al salir de una condición. Una resolución inválida conserva la causa
y evita diagnósticos derivados. Los campos se resuelven desde el tipo del receptor y su clase propietaria.
La emisión del HIR se habilita solo sin errores; las advertencias no la bloquean.
Alternativas descartadas: resolución global, copiar lexemas de tipos y volver a interpretar el texto en lowering.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `LANG.TYPES.*`, `LANG.DECL.*`, `LANG.SUBPROGRAM.*`, `LANG.CLASS.*` (estático).
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.
