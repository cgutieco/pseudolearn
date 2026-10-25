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
