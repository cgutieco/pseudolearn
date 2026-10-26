# pseudolearn_abi

## 1. Qué es y qué no es

Declara la disposición compartida de los valores de ejecución. Implementado y verificado como parte del motor de ejecución.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Ninguno | Verificaciones en verde | Motor de ejecución |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. Crate activo incorporado al workspace de pseudolearn_engine.
Comprobación: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 0. Sin imports internos ni dependencias externas. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Palabra u64; Handle(u32) con cero reservado; cabecera común de dos palabras. La palabra 0 empaqueta `shape_tag` en los 32 bits bajos y `status_flags` en los altos; la palabra 1 contiene el ordinal de objetos/arreglos o la cantidad de puntos de código del texto. En arreglos, `status_flags` guarda `ValueKind` en bits 0–7, rango en bits 8–15 y literal en bit 16. En objetos, `shape_tag = 3 + class_id` y bits 0–15 guardan el desplazamiento de los campos; bit 16 marca literales. En texto, bit 0 identifica contenido ASCII y bit 16 marca literales. Los mapas de referencias por clase y la forma del marco bicameral también son datos compartidos.

Los arreglos guardan total de elementos en la palabra 2, cantidad de elementos enteros definidos en la palabra 3 y la dirección absoluta del mapa de definición en la palabra 4. El rango 1 reutiliza la palabra 2 como su dimensión; rangos mayores guardan dimensiones desde la palabra 5 y los datos desde `5 + rango`. Objetos colocan máscaras enteras desde la palabra 2 cuando su diseño no es denso y los campos en el desplazamiento de la cabecera. Los objetos conservan campos heredados antes que propios y el mapa estático de desplazamientos de referencias. Cadenas guardan desplazamiento y longitud en palabras 2 y 3, más el asa de migas en la palabra 4. El marco guarda función, identificador de retorno y bases de los dos bancos.

Invariantes: Una sola disposición para runtime, VM, línea temporal y futuros consumidores nativos. NaN representa real ausente, 2 lógico ausente, 0xFFFFFFFF carácter ausente y asa cero referencia ausente.

Capacidades (`capability_layout`): `CapabilityKind` define las clases normativas (`Console`, `Arguments`, `Directory`, `File`, `Clock`, `Timer`) y sus etiquetas numéricas (0..=5). `CAPABILITY_HEADER_WORDS = 2` y `CAPABILITY_SHAPE_TAG = 0x0000_CA00` definen la cabecera estándar en el montón para asas de capacidad, permitiendo que runtime, semántica, VM y línea temporal compartan la misma clasificación y disposición binaria sin descriptores externos.

Búfer de bytes (`bytes_layout`): `BYTES_SHAPE_TAG = 0x0000_BA00` y `bytes_cell_count(len)` formalizan la representación en celdas de 16 bytes para secuencias binarias independientes de cadenas UTF-8.

Errores de entrada/salida (`io_error_layout`): `IoErrorKind` unifica los 9 códigos canónicos de fallos de E/S (`notFound`, `permissionDenied`, `alreadyExists`, `endOfFile`, `invalidUtf8`, `invalidPath`, `closedCapability`, `timedOut`, `interrupted`) y sus etiquetas numéricas compartidas por runtime y VM.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: runtime, VM, línea temporal y consumidores nativos necesitan interpretar el mismo bloque sin descriptores de asignación externos. Elección: `CommonHeader` fija forma y banderas en la primera palabra y ordinal o cantidad de puntos en la segunda; los offsets de arreglos, objetos y cadenas completan una disposición única. Se rechazan punteros, páginas persistentes y disposiciones diferentes por motor.

El prefijo contiguo de referencias no compone con herencia sin mover campos heredados. El mapa por clase conserva desplazamientos y solo se consulta al recolectar. Se rechazan datos de referencias duplicados por objeto.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

`RecordLayout` describe un registro como lista de hojas con su banco (escalar o de referencias) y su desplazamiento
dentro de ese banco; las áreas escalar y de referencias son independientes, como el marco bicameral, de modo que el
mapa de raíces de un registro es estático por tipo. Un registro anidado se aplana con `from_parts` y el máximo de
hojas es el de un operando de 16 bits. Hoy lowering aplana los registros en valores y no consulta desplazamientos en
memoria: esta disposición es el dato compartido que usarán la incrustación en objetos y vectores
sin recalcular desplazamientos en cada motor. Semantic ya consume estas hojas para construir la unión por banco de las variantes.

`VariantLayout` superpone las cargas útiles dentro de cada banco y reserva un discriminante escalar. El máximo incluye discriminante y ambos bancos. `optional` elimina el discriminante solo para una referencia con nicho disponible: un opcional anidado cuyo interior usa el centinela debe construirse como variante etiquetada para distinguir Nada de Algo(Nada). Las ranuras de referencia inactivas se limpian a cero, manteniendo raíces estáticas. La validación de variante y capacidad precede cualquier escritura.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

Base compartida de RT.ABI; el ABI externo de R6 queda fuera del alcance actual. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Tamaños y desplazamientos; centinelas fuera del dominio válido; marcos y cabeceras con cero y máximos. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

V8 y JVM inspiran referencias comprimidas; SableVM inspira separar clases de valor. Se rechaza disposición bidireccional por impedir recorrido lineal del montón.


### Funciones como valores y ámbitos de ejecución

La disposición de un valor función contiene una palabra escalar de identidad de código y una referencia de entorno. `ClosureLayout` compone únicamente las capturas efectivas, ordenadas por banco; una función sin capturas usa el centinela cero. El entorno no conserva marcos ni referencias prestadas. La representación conserva los límites de 65 535 palabras del registro.

## Colecciones, interfaces e iteración con limpieza

Las colecciones reservan etiquetas de forma u32 máximo menos uno para Vector y menos dos para Diccionario. La cabecera estable transporta longitud, capacidad, versión, anchos de bancos y asas de almacenamiento reemplazable; la identidad y los alias nunca dependen de la dirección del banco. VectorLayout y DictionaryLayout centralizan la aritmética comprobada. CollectionCommand es la frontera compartida de ambos ejecutores; no contiene tipos dinámicos de valores.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.
