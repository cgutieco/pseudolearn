# pseudolearn_library

## 1. Qué es y qué no es

Implementa las funciones incorporadas sobre valores del runtime. Diseño aprobado; pendiente de implementación del motor de ejecución.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Implementación y pruebas del diseño descrito | Contratos y puertas previas verificadas | Motor de ejecución |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. La carpeta aún no contiene manifiesto ni código.
Al implementarla se incorpora al workspace y se retira pending de architecture.yaml. Comprobación
actual: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 6. Importa runtime y diagnostics; solo biblioteca estándar externa. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Funciones puras sobre representaciones del runtime, con identidad y firma generadas. Raíz cuadrada binario64 del hardware; ln, exp, sen, cos, atan y potencia real mediante aproximación doble-doble con cota y reevaluación de precisión múltiple cuando no se puede decidir el redondeo. Formato decimal mínimo de ida y vuelta, conversiones y copia superficial.

Invariantes: Mismo resultado binario64 y mismo texto en todas las plataformas. Los dominios inválidos y resultados no finitos atrapan antes de guardar un valor.

## 4. Decisiones de diseño y fundamentos técnicos

La libm del anfitrión puede diferir en el último bit, que el formato hace visible. El redondeo correcto es derivable por un oráculo racional independiente. Se usa sqrt correctamente redondeada y se rechazan las trascendentes del anfitrión. Display aporta dígitos mínimos posicionales y se añade .0 cuando hace falta; el cero negativo se conserva. Copiar conserva ausencia, comparte referencias y no ejecuta constructor.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

LIB.*, LANG.TYPES.REAL, LANG.OPS.POWER y LANG.IO.VALUE-FORMAT. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Oráculo racional en un millón de argumentos por función, bordes de dominio, casos difíciles, copia con campos sin valor y paridad nativa/Wasm. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Ziv, CRlibm y CORE-MATH inspiran aproximación rápida y reevaluación adaptativa; no se adopta dependencia de libm ni código inseguro.
