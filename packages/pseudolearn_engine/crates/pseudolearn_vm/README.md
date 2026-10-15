# pseudolearn_vm

## 1. Qué es y qué no es

Ejecuta bytecode verificado mediante bancos de registros. Diseño aprobado; pendiente de implementación del motor de ejecución.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Implementación y pruebas del diseño descrito | Contratos y puertas previas verificadas | Motor de ejecución |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. La carpeta aún no contiene manifiesto ni código.
Al implementarla se incorpora al workspace y se retira pending de architecture.yaml. Comprobación
actual: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 7. Importa bytecode, runtime, library y diagnostics; serde_json solo para generación. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Despacho generado con pc, bases, combustible, eventos, marca de agua y máscaras en locales. Bancos Vec<u64> y Vec<u32> de longitud potencia de dos, ventanas solapadas y acceso por máscara. Crecen por duplicación al llamar; profundidad del lenguaje se comprueba aparte. Trampas inmediatas Result con construcción fría del diagnóstico.

Invariantes: Ningún acceso sale de su banco. El rápido nunca observa. Ningún límite agota la pila del anfitrión. La profundidad no depende de una capacidad fija elegida por plataforma.

## 4. Decisiones de diseño y fundamentos técnicos

La VM sale hacia su llamador con Exit::Service y no importa timeline ni API. Se carga el mínimo de presupuesto, distancia al punto y cuanto de sondeo. Los ciclos sin sentencias tienen contador de sondeo propio. Solo el servicio consulta cancelación y tiempo. Se cambia de gemelo en entradas de bloque y retornos por identidad independiente. El sondeado emite lotes en columnas y un búfer de cambios, sin objeto por evento. Se rechazan bancos fijos que alterarían límites y banderas de trampa escritas en cada operación.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

ENG.EXEC.*, ENG.TRACE.*, ENG.INPUT y ENG.LIMITS. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Trazadora numérica y recursiva antes del runtime completo; gemelos y cambios arbitrarios; límites exactos, cancelación de bucle vacío, entrada inválida, ausencia y robustez generada. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Lua inspira ventanas, JVM verificación y Self cambio de código; se preserva Rust seguro y se mide el despacho antes de optimizar.
