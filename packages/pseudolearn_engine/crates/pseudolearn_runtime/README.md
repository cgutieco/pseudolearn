# pseudolearn_runtime

## 1. Qué es y qué no es

`pseudolearn_runtime` proporciona las operaciones comprobadas de memoria y valores que comparten la VM y los consumidores del motor. Incluye aritmética primitiva, montón, objetos, arreglos, texto y estado aleatorio determinista.

No ejecuta bytecode, no conoce el lenguaje fuente y no traduce errores a mensajes localizados. Las fallas esperables se expresan con `Result` y `MemoryError` o `ArithmeticError`.

## 2. Guía operativa y ciclo de vida

El crate forma parte del workspace de `pseudolearn_engine`. Sus dependencias de código son `pseudolearn_abi` y `pseudolearn_diagnostics`; no necesita servicios externos ni archivos generados.

Desde `packages/pseudolearn_engine`:

- Compilar: `cargo check -p pseudolearn_runtime`.
- Ejecutar sus pruebas de integración: `cargo test -p pseudolearn_runtime`.
- Ejecutar todas las verificaciones del motor: `cargo xtask verify`.

La API pública existente se consume mediante los tipos y funciones exportados por `src/lib.rs`. Los límites de memoria y la política de recolección se entregan en `MemoryOptions` al crear `Heap`.

## 3. Arquitectura y modelo del sistema

El montón guarda palabras `u64` en un vector plano. Cada asignación comienza con una cabecera `CommonHeader` de dos palabras: la primera empaqueta forma y banderas, y la segunda guarda el ordinal o la cantidad de puntos de código. Un vector ordenado de `BlockRecord` conserva solo dirección, tamaño físico y celdas lógicas para recolección y diferenciales. El valor cero representa una referencia ausente; las asas son desplazamientos de 32 bits dentro del vector y las asignaciones de objetos y arreglos reciben una identidad ordinal que no depende de su dirección física. Una dirección reutilizada recibe un ordinal nuevo, así que igualdad de asa no implica identidad de objeto.

Los objetos conservan sus diseños en `Heap.layouts`, indexados por clase, y llevan el desplazamiento de campos en la cabecera. Los arreglos codifican tipo de elemento, rango y literal en las banderas; guardan el total, la cantidad de enteros definidos y la dirección del mapa de definición en sus primeras palabras. El arreglo de rango uno reutiliza el total como su dimensión; los de mayor rango guardan sus dimensiones antes de los datos. El mapa de definición distingue una celda sin inicializar de un entero cuyo valor sea cero. Las celdas auxiliares permiten representar ese mapa sin añadir etiquetas a los valores.

La recolección es no móvil y marca desde las asas raíz recibidas por la operación. Los bloques liberados se agrupan por tamaño físico para reutilizar direcciones. El texto usa un arena propio con migas de caracteres y una operación explícita de compactación que devuelve los desplazamientos movidos. La recolección compacta el arena automáticamente y, al descartar los índices de migas, libera solo los auxiliares que un texto referencia (una vez cada uno, porque los prefijos compartidos comparten índice): los búferes de `Vector` y `Diccionario` también son bloques auxiliares y no deben liberarse con ellos. El generador pseudoaleatorio recibe una semilla y mantiene su estado dentro de `RandomState`.

Tabla de capacidades y efectos (`capability_table`): `CapabilityTable` gestiona las ranuras activas del anfitrión mediante `CapabilityToken` (índice y generación `u32`). Implementa la invalidación generacional en el cierre (`close`), de forma que cualquier intento de invocar un descriptor cerrado produce `CapacidadCerrada` (`CapabilityError::ClosedToken`). Controla máscaras de derechos (`RightsMask`) para impedir amplificaciones no autorizadas. Modela el ciclo formal de compromiso de efectos (`EffectPhase`: `Requested`, `Resolved`, `Committed`, `Failed`, `Uncertain`, conforme a `CF-07` y `ENG.EXEC.EFFECT-COMMIT`). Un corte o fallo externo incierto transiciona el estado a `ReproducibilityStatus::UncertainExternalState`. La operación `close_all` garantiza la liberación inmediata de todos los recursos del host ante corte o cancelación del anfitrión (`CF-11`).

## 4. Decisiones de diseño y fundamentos técnicos

Problema: una política única obliga al nativo a recolectar árboles vivos con demasiada frecuencia. Elección: `MemoryOptions.collection_minimum` configura el mínimo de celdas asignadas antes de recolección automática; el valor predeterminado es 4096. La asignación, la consulta previa y la ventana en línea usan el mismo umbral, máximo entre mínimo y celdas vivas. La presión del límite y la recolección forzada conservan prioridad. La holgura se repone por debajo de 8192 palabras libres y reserva al menos 16384. Se descarta cambiar la política predeterminada de la VM.

Problema: la consulta de límite y el recolector repetían el mismo recorrido. Elección: la preparación construye una sola marca, calcula sus celdas antes de liberar y entrega esa marca al recolector. La compactación solo elimina auxiliares de texto de costo lógico cero; el conteo de celdas alcanzables no cambia. Una asignación que excede el límite falla antes de recolectar, como exige su contrato. Se descarta ocultar recorridos: el mínimo automático se configura explícitamente por consumidor y se mide con el mismo contrato de celdas vivas.

Problema: copiar vectores de campos y referencias por objeto repite metadatos inmutables. Elección: la asignación valida el diseño contra el registrado y solo copia el diseño si la clase aún no lo tiene. La reserva y la inicialización del objeto siguen el mismo contrato de identidad y definición. Se descarta cambiar la representación de objetos o el recolector para eliminar esta copia.

Problema: los perfiles agregados no distinguen mecanismos de memoria. Elección: la feature `telemetry`, desactivada por omisión, cuenta asignaciones, crecimiento de palabras, recolecciones, recorridos, copias de diseño y accesos o raíces de celdas según la responsabilidad del crate. Sus resultados pertenecen a sesiones diagnósticas separadas; el código de producto y la campaña normativa no contienen estos incrementos. Se descarta atribuir los tiempos instrumentados al rendimiento de producción.

Problema: consultar un mapa de descriptores en cada lectura y escritura añade una búsqueda y conserva descripciones duplicadas fuera de las palabras vivas. Elección: las cabeceras en banda contienen forma, tipo, rango, desplazamiento de campos, literal y ordinal; `ObjectLayout` se registra una vez en un vector indexado por clase. Lecturas y escrituras de arreglos, campos y celdas derivan sus metadatos de la cabecera y de ese diseño. `BlockRecord` mantiene solo `Handle`, tamaño físico y celdas; el recolector lo recorre para marcar/liberar bloques y los snapshots enumeran sus asas. Se descarta una tabla de asignaciones consultada en el camino de acceso.

Problema: diferenciar la capacidad reservada del vector de palabras retiene datos no usados en cada punto de control. Elección: `Heap.used` delimita las palabras lógicas; la ventana nativa puede extender `Heap.words.len()` con holgura inicializada, excluida del estado observable. La capacidad interna de `Vec` tampoco forma parte del estado. `HeapDelta` compara solo el prefijo usado, aplica deltas por bloques a palabras y `BlockRecord`, y conserva el sufijo de diseños registrados junto con las listas libres y el estado del arena de texto. `advance_heap` actualiza la imagen de la punta y devuelve el segmento inverso; `revert_heap` lo aplica y `compose_heap_deltas` fusiona segmentos contiguos. Se descarta capturar palabras reservadas fuera del montón lógico.

`BlockDelta::advance_from` recibe el primer índice modificado para omitir los bloques anteriores al cambio. El propietario registra ese índice al escribir y lo restablece después de capturar; el crecimiento y el truncado siguen detectando el borde común entre el estado anterior y el nuevo.

`compact_text` devuelve un `TextCompaction` con los rangos movidos. La compactación disparada por una recolección automática no conserva ni publica ese mapa: el runtime actual no tiene un consumidor de los desplazamientos del arena. Un consumidor que necesite observarlos debe añadir su contrato de notificación junto con su integración; el runtime no acumula mapas sin lector.

El montón no mueve objetos: así, una recolección no altera identidades ni asas visibles. El ordinal identifica la asignación lógica, mientras el asa permite llegar a su almacenamiento actual. Los errores de capacidad, tamaño negativo, límite de celdas, índice, valor no inicializado e invariantes internos son variantes tipadas, no pánicos.

Las dimensiones se convierten y multiplican con comprobación de rango; una dimensión cero produce un arreglo de cero elementos, mientras el rango vacío no representa un arreglo válido. El límite de celdas cuenta el costo lógico exacto y se comprueba con las celdas vivas antes de aceptar la asignación.

## 5. Reglas de legibilidad, estilo y estructura de código

El código y sus identificadores están en inglés. No se permiten comentarios, documentación Rust ni atributos de supresión. Los errores esperables se devuelven como valores tipados; el crate declara `#![forbid(unsafe_code)]`.

Los módulos de `src/` separan aritmética, arreglos, celdas, heap, objetos, azar y texto. Las pruebas de caja negra están en `tests/` y reflejan estas responsabilidades.

## 6. Decisiones de producto que condicionan el código

El runtime conserva valores sin etiquetas dinámicas: `ValueKind` y los mapas de definición describen cómo interpretar cada palabra. Las representaciones compartidas se declaran en `pseudolearn_abi` para mantener iguales los contratos de VM y AOT.

La colección automática puede activarse por presión de límite o asignaciones acumuladas; `Forced` permite solicitarla al asignar y `Disabled` impide recolectar. La semilla explícita hace reproducible el azar. La asignación de texto y la memoria de observación se mantienen fuera de las garantías de identidad de objetos.

## 7. Verificación, testing y aseguramiento de calidad

Las pruebas de `tests/heap_tests.rs` y `tests/array_tests.rs` cubren asignación, acceso directo a metadatos en banda, rangos de arreglos, límites, errores, identidades, recolección, definición de enteros y crecimiento del almacenamiento. La regresión de reutilización verifica que una misma asa conserva una identidad ordinal distinta tras recolectar y reasignar. `tests/delta_tests.rs` cubre restauración y composición tras asignar, modificar y liberar bloques. Las pruebas de consumo en `pseudolearn_api` contrastan las operaciones con los casos del corpus bajo recolección automática, forzada y desactivada.

Para aceptar un cambio, se ejecutan las pruebas dirigidas del crate afectado y `cargo xtask verify` desde la raíz del motor. La conformidad observable del lenguaje se mantiene en el corpus y se contrasta desde `packages/pseudolearn_spec`.

## 8. Fuentes consultadas y genealogía conceptual

La representación de asas comprimidas toma como referencia los diseños de V8 y la JVM. La compactación de texto y sus migas se inspiran en técnicas de arenas de texto empleadas por Swift. Estas referencias orientan alternativas de implementación; el contrato del runtime pertenece a PseudoLearn.

El contraste E-12 fue una medición histórica local. La decisión de usar consultas ordenadas en los descriptores y el estado de rendimiento se documentan junto con la arquitectura del motor.

Problema: reservar el vector de palabras con la capacidad exacta de cada asignación hacía un realojo por objeto, y el código nativo no puede crecer un vector de Rust. Elección: la reserva usa crecimiento amortizado y `Heap::inline_window` extiende además la longitud con una holgura de ceros (mínimo 16 384 palabras) que `shrink_to_fit` recorta al uso real. La ventana publica el uso, el límite, el ordinal, el margen de celdas y de umbral de recolección (las dos condiciones de `prepare`, expresadas como contadores que el código nativo decrementa), y una máscara de tamaños con bloques libres (el bit 63 agrupa los tamaños desde 63). `Heap::adopt_inline` incorpora los bloques que el código nativo asignó sin pasar por Rust y rechaza regresiones de uso u ordinal, rangos fuera del vector y bloques duplicados. Se descarta registrar bloques desde el código nativo en el vector ordenado del montón: se difiere a un búfer plano que se concilia al entrar en el runtime.

## Colecciones, interfaces e iteración con limpieza

Vector y Diccionario mantienen cabeceras estables y bancos separados de escalares y referencias. Crecer sustituye bancos conservando asa e identidad; Vector duplica capacidad mediante aritmética comprobada. Diccionario conserva entradas en inserción, usa FNV-1a de 64 bits con bytes enteros en orden little endian o UTF-8 exacto para cadenas, índice abierto con sondeo lineal y ocupación máxima de tres cuartos. Compacta establemente cuando los huecos superan un cuarto de las posiciones usadas. No hay tabla lateral de Rust que quede fuera de snapshots. Los bloques auxiliares pertenecen al heap y las referencias activas se recorren desde la cabecera; eliminar borra los enlaces y permite recolectar objetos. Solo las mutaciones estructurales exitosas incrementan la versión u32, cuyo agotamiento falla antes de modificar. Los límites de elementos y palabras variables derivan de cells y del espacio u32; las celdas lógicas dependen de longitud, no de capacidad. Las reservas y el cambio de cabecera se separan para que un fallo no publique almacenamiento parcial.

Los tests de estas capacidades se ejecutaron en selecciones acotadas, incluida la comparación de gemelos con recolección forzada. La conformidad del corpus sigue pendiente de la revisión editorial independiente de los contratos nuevos, y la medición de tamaño excede el presupuesto de Wasm.
