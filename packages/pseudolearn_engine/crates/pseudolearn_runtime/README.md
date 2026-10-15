# pseudolearn_runtime

## 1. Qué es y qué no es

Gestiona los valores de ejecución en un montón plano determinista. La primera entrega implementa la
aritmética primitiva comprobada que consumen los intrínsecos y la VM.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Heap, texto, arreglos, recolección, azar y operaciones de sus tipos | ABI y contratos de B4 | B4 |

## 2. Guía operativa y ciclo de vida

Usa la versión exacta de rust-toolchain.toml del miembro. El crate ya está activo en el workspace y
contiene aritmética primitiva comprobada de B3. El heap permanece para B4. Comprobación: `cargo xtask verify`
y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 6. Importa abi y diagnostics; solo biblioteca estándar externa. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Vec<u64> plano con asas directas, crecimiento por duplicación y avance en bloques de 4096 palabras puestos a cero. Recolector no móvil con marcado iterativo, bits laterales y raíces nocionales; reutilización determinista elegida mediante medición de prototipos. Arena UTF-8 de solo apéndice, cabeceras inmutables por prefijo, indicador ASCII y migas cada 64 puntos. La aritmética primitiva es comprobada; `int.mod` produce cero para el entero mínimo módulo −1. El montón, la arena de texto, la recolección y xoshiro256** con SplitMix64 permanecen en bloques posteriores.

Invariantes: La recolección no cambia observables. La identidad es un ordinal que no se reutiliza. Ninguna escritura rápida paga una barrera. El estado interno se reproduce determinísticamente.

## 4. Decisiones de diseño y fundamentos técnicos

El montón paginado y su copia en escritura no superaron el criterio de coste; la medición de memoria plana y combustible está en results/r5-e02r.json del sistema de especificaciones. El límite de celdas usa raíces exactas y cuenta el valor nuevo antes de sobrescribir. La ausencia usa centinelas, cota densa en arreglos enteros y máscara en objetos. Compartir apéndice conserva prefijos anteriores; una bifurcación del tramo obliga a copiar. La compactación de texto actualiza cabeceras y avisa a la línea temporal. Un fallo de reserva es un recurso de API, no un observable del programa. La aritmética convierte overflow y división por cero en errores tipados; no depende de pánicos de Rust. Cada operación primitiva está marcada `#[inline]` para que el manejador de la VM la integre a través del límite del crate; sin la marca la trazadora medía una llamada por operación aritmética.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

MEM.*, RT.HOST.INTERFACE y ejecución de tipos, operadores, arreglos y celdas de ENG.LIMITS. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Recolección forzada, ciclos, alias, temporales muertos, conteo frente al oráculo, cero y bordes, bifurcación de apéndice, cota densa y medición de los candidatos del recolector. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Se toman mapas de pila por punto seguro de HotSpot y LLVM; se rechazan mapas para tipos. Go y CPython inspiran apéndice, sin condición por conteo de referencias. Swift inspira migas, conservando UTF-8. Immix aporta un candidato no móvil; se rechaza evacuación por dispersar la sombra.
