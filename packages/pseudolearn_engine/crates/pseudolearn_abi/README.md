# pseudolearn_abi

## 1. Qué es y qué no es

Declara la disposición compartida de los valores de ejecución. Diseño aprobado; pendiente de implementación del motor de ejecución.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Implementación y pruebas del diseño descrito | Contratos y puertas previas verificadas | Motor de ejecución |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. La carpeta aún no contiene manifiesto ni código.
Al implementarla se incorpora al workspace y se retira pending de architecture.yaml. Comprobación
actual: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 0. Sin imports internos ni dependencias externas. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Palabra u64; Handle(u32) con cero reservado; cabeceras de dos palabras; ordinal u64 para objetos y arreglos. Objetos con máscara de enteros solo cuando necesitan definición, campos heredados antes que propios y mapa estático de desplazamientos de referencias. Arreglos con longitud, cota densa, dimensiones, mapa de definición y celdas por filas. Cadenas con puntos de código, desplazamiento y longitud en la arena, y asa de migas. Marco con función, identificador de retorno y bases de los dos bancos.

Invariantes: Una sola disposición para runtime, VM, línea temporal y futuros consumidores nativos. NaN representa real ausente, 2 lógico ausente, 0xFFFFFFFF carácter ausente y asa cero referencia ausente.

## 4. Decisiones de diseño y fundamentos técnicos

El prefijo contiguo de referencias no compone con herencia sin mover campos heredados. El mapa por clase conserva desplazamientos y solo se consulta al recolectar. Se rechazan punteros, páginas persistentes y disposiciones diferentes por motor.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

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
