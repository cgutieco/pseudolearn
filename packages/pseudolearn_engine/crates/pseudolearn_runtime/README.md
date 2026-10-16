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

El montón guarda palabras `u64` en un vector plano y registra cada asignación en mapas ordenados por `Handle`. El valor cero representa una referencia ausente; las asas son desplazamientos de 32 bits dentro del vector y las asignaciones de objetos y arreglos reciben una identidad ordinal que no depende de su dirección física.

Los objetos conservan su diseño de campos y mapa de referencias en `ObjectLayout`. Los arreglos conservan rango, dimensiones y clase de elemento; sus datos son contiguos y el mapa de definición de enteros distingue una celda sin inicializar de un entero cuyo valor sea cero. Las celdas auxiliares permiten representar ese mapa sin añadir etiquetas a los valores.

La recolección es no móvil y marca desde las asas raíz recibidas por la operación. Los bloques liberados se agrupan por tamaño físico para reutilizar direcciones. El texto usa un arena propio con migas de caracteres y una operación explícita de compactación. El generador pseudoaleatorio recibe una semilla y mantiene su estado dentro de `RandomState`.

## 4. Decisiones de diseño y fundamentos técnicos

Las búsquedas de asignaciones y bloques libres usan `BTreeMap`; las consultas de arreglo y campo consultan el mapa de asignaciones para validar el asa y recuperar su descriptor antes de acceder a las palabras. Se conserva esta estructura porque satisface las puertas actuales de corrección y verificación. No se establece un mínimo de rendimiento adicional.

El montón no mueve objetos: así, una recolección no altera identidades ni asas visibles. El ordinal identifica la asignación lógica, mientras el asa permite llegar a su almacenamiento actual. Los errores de capacidad, tamaño negativo, límite de celdas, índice, valor no inicializado e invariantes internos son variantes tipadas, no pánicos.

Las dimensiones se convierten y multiplican con comprobación de rango; una dimensión cero produce un arreglo de cero elementos, mientras el rango vacío no representa un arreglo válido. El límite de celdas cuenta el costo lógico exacto y se comprueba con las celdas vivas antes de aceptar la asignación.

## 5. Reglas de legibilidad, estilo y estructura de código

El código y sus identificadores están en inglés. No se permiten comentarios, documentación Rust ni atributos de supresión. Los errores esperables se devuelven como valores tipados; el crate declara `#![forbid(unsafe_code)]`.

Los módulos de `src/` separan aritmética, arreglos, celdas, heap, objetos, azar y texto. Las pruebas de caja negra están en `tests/` y reflejan estas responsabilidades.

## 6. Decisiones de producto que condicionan el código

El runtime conserva valores sin etiquetas dinámicas: `ValueKind` y los mapas de definición describen cómo interpretar cada palabra. Las representaciones compartidas se declaran en `pseudolearn_abi` para mantener iguales los contratos de VM y AOT.

La colección automática puede activarse por presión de límite o asignaciones acumuladas; `Forced` permite solicitarla al asignar y `Disabled` impide recolectar. La semilla explícita hace reproducible el azar. La asignación de texto y la memoria de observación se mantienen fuera de las garantías de identidad de objetos.

## 7. Verificación, testing y aseguramiento de calidad

Las pruebas de `tests/heap_tests.rs` y `tests/array_tests.rs` cubren asignación, acceso, límites, errores, identidades, recolección, definición de enteros y crecimiento del almacenamiento. Las pruebas de consumo en `pseudolearn_api` contrastan las operaciones con los casos del corpus.

Para aceptar un cambio, se ejecutan las pruebas dirigidas del crate afectado y `cargo xtask verify` desde la raíz del motor. La conformidad observable del lenguaje se mantiene en el corpus y se contrasta desde `packages/pseudolearn_spec`.

## 8. Fuentes consultadas y genealogía conceptual

La representación de asas comprimidas toma como referencia los diseños de V8 y la JVM. La compactación de texto y sus migas se inspiran en técnicas de arenas de texto empleadas por Swift. Estas referencias orientan alternativas de implementación; el contrato del runtime pertenece a PseudoLearn.

El contraste E-12 de la fase se conserva en [r5-e12.json](../../../pseudolearn_spec/results/r5-e12.json). La decisión de usar consultas ordenadas en los descriptores y el estado actual de rendimiento se documentan junto con la arquitectura del motor.
