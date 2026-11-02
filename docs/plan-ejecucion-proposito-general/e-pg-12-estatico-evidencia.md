# E-PG-12 · Material y evidencia estática

## 1. Alcance y oráculo

Esta campaña cubre proyecciones estáticas de PG-A. No evalúa tareas, suspensión, paralelismo, eventos, cancelación,
canales ni el umbral humano de espera frente a ejecución; esa evidencia pertenece a PG-B. No presenta pruebas automáticas
como comprensión pedagógica.

La fuente de escenas es el archivo bilingüe de `apps/pseudolearn_app/test/fixtures/static_view_scenes/`. El caso español usa
el perfil `classicSpanish`; el inglés usa `english`. Ambos contienen una interfaz, dos realizaciones, las alternativas
`Resultado`, una clausura con captura por valor y una iteración con dos elementos. El test
`apps/pseudolearn_app/test/engine/rust/static_view_protocol_test.dart` analiza los dos archivos por FRB real,
comprueba los IDs de relaciones y variantes, captura, iteración, ámbitos, cajas, relaciones y liberación de recursos.
También cambia la firma de una implementación, conserva su relación inválida y comprueba que tiene diagnóstico.

Oráculo manual derivado de las reglas y casos vigentes:

| Observación | Resultado esperado | Fuente normativa |
|---|---|---|
| Contrato y realizaciones | `Legible`/`Readable` es una declaración, no una instancia; `Lector`/`Reader` y `Escritor`/`Writer` son clases concretas. Hay dos relaciones, cada una con origen y destino identificables. | `LANG.TYPES.INTERFACE#R1`, `#R2`, `#C5`; `API.PROGRAM.VIEW#R6`–`R9` |
| Realización válida | Las dos firmas originales coinciden con el contrato y se muestran válidas. | `LANG.TYPES.INTERFACE#R2`; `API.PROGRAM.VIEW#R7`–`R9` |
| Realización inválida | Al cambiar solo el tipo de retorno de `Writer/Escritor`, su relación conserva `interfaceMethodSignatureMismatch`, se anuncia inválida por texto y enlaza el método de origen. La otra relación sigue válida. | `LANG.TYPES.INTERFACE#R2`; `API.PROGRAM.VIEW#R8`–`R9` |
| `Resultado` | La lectura con 4 produce `Exito(5)`/`success(5)`; la escritura produce `Error("bloqueado")`/`failure("blocked")`. Ambas ramas son visibles. El discriminante de la vista pública para la segunda alternativa es `error`. | `LANG.TYPES.RELATIONS#R3`, `#R5`; `LANG.CONTROL.SWITCH#R2`; `API.PROGRAM.VIEW#R5` |
| Captura | `CrearIncrementador(3)`/`createIncrementer(3)` conserva el vínculo inmutable `3` por valor; con argumentos 2 y 4 devuelve 5 y 7. No se infiere un alias para el entero. | `LANG.TYPES.FUNCTION#R1`, `#C2` |
| Iteración | La secuencia se evalúa antes de crear el vínculo; el orden es 2 y luego 4. El vínculo es inmutable, visible dentro del cuerpo y fuera de alcance al terminar el bucle. | `LANG.CONTROL.FOR-EACH#R1`, `#C1` |

Los casos de corpus y las pruebas de layout/semántica son fuentes independientes de la captura. No se usa una imagen
golden como oráculo. Para geometría, el resultado esperado es: relaciones no degeneradas entre cajas; el triángulo hueco
apunta al contrato; las aristas no cruzan cajas; cajas, filas y aristas tienen rango y nombre accesibles; la relación
inválida incluye diagnóstico textual. Los tests específicos existentes verifican esos invariantes además del puente.

## 2. Comprobaciones automatizadas

La campaña se ejecuta por proceso en este orden, con fuentes, perfil y configuración fijos:

1. Validar los archivos bilingües por la vista pública Rust y el puente FRB; verificar dos realizaciones, ambas variantes,
   una captura por valor, una iteración, su ámbito y balance de recursos.
2. Repetir con firma incompatible y afirmar diagnóstico, relación inválida y conservación de la relación válida.
3. Ejecutar pruebas de identidad, routing/geométrica, accesibilidad y render del diagrama junto a los tests de puente y
   la matriz de cobertura de 78/78 formas.
4. Medir proyección estática con los tamaños 1, 10 y 100. En cada muestra comprobar que salen `n + 1` cajas de clase y
   exactamente `n` relaciones de realización. Cualquier error de análisis o cuenta discrepante falla el proceso.

Selección automatizable ejecutada:

```sh
flutter test --no-pub test/engine/rust/static_view_protocol_test.dart
flutter test --no-pub test/engine/rust/rust_type_contract_diagram_test.dart test/engine/rust/rust_value_type_diagram_test.dart test/engine/rust/rust_class_diagram_integration_test.dart
flutter test --no-pub test/engine/classdiagram/class_diagram_layout_test.dart test/engine/classdiagram/class_relation_routing_test.dart test/engine/classdiagram/diagram_scene_validators_test.dart
flutter test --no-pub test/application/diagram/class_diagram_accessibility_test.dart test/presentation/diagram/class_diagram_semantics_layer_test.dart test/presentation/rendering/diagram/class_diagram_render_test.dart
dart run tool/check_syntax_coverage.dart
flutter analyze --fatal-infos --fatal-warnings
dart run tool/check_limits.dart
flutter test --no-pub test/architecture/ test/tool/spec_coverage_test.dart
```

El arnés de medición se activa solo con `STATIC_VIEW_OUTPUT` y deja una fila JSONL por muestra. Se lanzan diez procesos
Flutter independientes, treinta iteraciones por proceso y tamaño, siempre en orden 1, 10, 100. Cada iteración crea un
análisis nuevo. No se eliminan muestras, incluidos arranques lentos. El reloj usa ticks monotónicos calibrados por
proceso. La memoria RSS se muestrea después de cada tamaño.

Las métricas significan exactamente lo siguiente:

| Campo | Intervalo |
|---|---|
| `view_load_ns` | Análisis nativo, transporte, solicitud de vista y decodificación Dart |
| `scene_build_ns` | Pipeline completo de `RustClassDiagramBuilder`: análisis, vista, decodificación, proyección y layout |
| `layout_ns` | `ClassDiagramLayout.of` sobre un `ClassModel` sintético del mismo tamaño |
| `paint_record_ns` | Registro Canvas de `ClassBoxPainter` sobre la escena del pipeline |
| `*_operations` | Llamadas FRB observadas durante carga de vista o construcción completa; se esperan cuatro por cada una |
| `rss_bytes` | RSS actual del proceso tras la muestra; el máximo observado se informa como cota inferior de pico |

La API actual no instrumenta por separado análisis, transporte y proyección dentro de `scene_build_ns`; el layout
aislado usa un modelo generado por el protocolo y no se presenta como latencia de la ruta completa. El pintor registra
comandos en un `PictureRecorder`: no se mide rasterización GPU, presentación de frame, interacción ni dispositivo
físico. Esta limitación impide certificar latencia de pantalla. No hay presupuesto aprobado para estas métricas.

## 3. Material para el estudio humano

### Preparación y asignación

- Reclutar al menos 12 principiantes solo con participantes y consentimiento gestionados por la persona responsable.
- No iniciar sesiones sin consentimiento. No pedir nombre, correo ni otros datos identificables al guardar resultados;
  el código de participante se asigna fuera de este repositorio.
- Elegibilidad: no haber usado PseudoLearn antes; experiencia de programación inicial; comprensión suficiente del idioma
  de interfaz asignado. Registrar experiencia en categorías, sin texto libre identificable.
- Separar perfil del documento y lengua de interfaz. Asignar tres plazas a cada celda: perfil es / interfaz es, perfil es
  / interfaz en, perfil en / interfaz es y perfil en / interfaz en. Informar denominador por celda; no combinar celdas
  para esconder diferencias.
- Mostrar el archivo fixture correspondiente al perfil asignado. En la tarea de realización inválida, presentar una
  copia donde `Escritor/Writer` declara y devuelve `Entero`/`integer` en vez de `Resultado<Entero, Cadena>`/`result<integer, string>`.
  No revelar la clave hasta acabar las tareas.
- Contrabalancear las cinco tareas usando los diez órdenes abajo. Asignar órdenes 1–10 y repetir 1 y 2 para las plazas
  11 y 12. Distribuirlos consecutivamente entre las cuatro celdas de idioma; registrar el orden realmente usado.
- No dar feedback de acierto durante las tareas. Registrar tiempo solo si el mismo método se aplica a todas las personas.

| Orden | Secuencia | Orden | Secuencia |
|---:|---|---:|---|
| 1 | T1, T2, T5, T3, T4 | 6 | T4, T3, T5, T2, T1 |
| 2 | T2, T3, T1, T4, T5 | 7 | T5, T4, T1, T3, T2 |
| 3 | T3, T4, T2, T5, T1 | 8 | T1, T5, T2, T4, T3 |
| 4 | T4, T5, T3, T1, T2 | 9 | T2, T1, T3, T5, T4 |
| 5 | T5, T1, T4, T2, T3 | 10 | T3, T2, T4, T1, T5 |

### Instrucciones y preguntas

Leer la instrucción en el idioma de interfaz asignado. La persona puede inspeccionar el mismo archivo, pero no ejecutarlo.
No se puntúa velocidad. Para cada respuesta, registrar texto literal anonimizado, acierto, petición de ayuda y tiempo si
se habilitó.

| Tarea | Español | English |
|---|---|---|
| T1 | En el diagrama, ¿cuáles elementos describen un contrato y cuáles son clases concretas? ¿Se crea un objeto `Legible` al declarar la interfaz? | In the diagram, which elements describe a contract and which are concrete classes? Does declaring the interface create a `Readable` object? |
| T2 | Compara las dos relaciones en la escena original y en la variante. ¿Qué implementación cambió? ¿Qué evidencia te permite distinguir una realización inválida de una válida? | Compare the two relations in the original and variant scenes. Which implementation changed? What evidence lets you distinguish an invalid realization from a valid one? |
| T3 | ¿Qué valor y qué error produce cada llamada? ¿Qué ramas de `Segun`/`switch` los representan? | What value and error does each call produce? Which `Segun`/`switch` branches represent them? |
| T4 | ¿Qué valor conserva la clausura al crear el incrementador? ¿Qué resultados produce para 2 y 4? ¿La captura del entero es por copia del vínculo o por alias mutable? | Which value does the closure keep when the incrementer is created? What does it return for 2 and 4? Is the integer capture a copied binding or a mutable alias? |
| T5 | ¿En qué orden recorre los valores? ¿Dónde existe el vínculo del iterador? ¿Qué ocurre si la colección está vacía? | In what order are the values visited? Where does the iterator binding exist? What happens if the collection is empty? |

### Clave y puntuación previa

Cada tarea vale dos puntos, un punto por cada proposición:

| Tarea | Respuestas esperadas |
|---|---|
| T1 | `Legible`/`Readable` es interfaz/contrato; Lector/Reader y Escritor/Writer son clases concretas. La interfaz no es un valor y no se instancia. |
| T2 | La variante cambia Escritor/Writer. En el original las dos firmas coinciden. En la variante, `interfaceMethodSignatureMismatch` invalida solo esa realización; la escena conserva el diagnóstico y su origen. El color sin etiqueta no basta como respuesta. |
| T3 | Lector/Reader con entrada 4 devuelve Exito/success con 5; Escritor/Writer devuelve Error/failure con `bloqueado`/`blocked`. La rama de error es necesaria además de éxito. |
| T4 | La clausura conserva `base`/`captured` igual a 3 por valor. Las entradas 2 y 4 producen 5 y 7; no se crea un alias mutable del entero. |
| T5 | Orden 2 y luego 4. El vínculo es inmutable y visible solo dentro del cuerpo. Una colección vacía ejecuta cero cuerpos. |

Registrar por tarea el puntaje 0–2 y las confusiones observadas. Para la afirmación candidata sobre interfaz frente a
instancia, informar cantidad correcta y denominador, además del puntaje por idioma de interfaz y perfil. El 80 % es un
resultado humano descriptivo, no una propiedad que puedan probar estos tests. No inferir comprensión de espera/paralelo:
esa tarea dinámica se reserva a PG-B.

### Hoja vacía de captura

Evidencia de participantes: [ ] Doce sesiones consentidas y registradas. Estado actual: **Diferido** por la decisión del
2026-10-22; esta casilla no se sustituye por tests automatizados.

| Código seudónimo | Consentimiento verificado fuera del repositorio | Experiencia inicial | Perfil es/en | Interfaz es/en | Orden |
|---|---|---|---|---|---|
|  | Sí / no |  |  |  |  |

| Tarea | Respuesta anonimizada | Puntaje 0–2 | Ayuda solicitada | Tiempo, si aplica |
|---|---|---:|---|---:|
| T1 |  |  |  |  |
| T2 |  |  |  |  |
| T3 |  |  |  |  |
| T4 |  |  |  |  |
| T5 |  |  |  |  |

## 4. Resultado y procedencia

El resultado humano se registra como **Diferido** por la decisión complementaria aprobada el 2026-10-22. No se
recibieron participantes, consentimiento ni resultados; la casilla de evidencia humana sigue sin cumplir y no se afirma
eficacia pedagógica. El kit queda listo para uso futuro. La medición automatizable obligatoria se completó en diez
procesos independientes.

### Registro automatizable

| Campo | Resultado |
|---|---|
| Fecha local | 2026-11-01 a 2026-11-02, America/Lima |
| Revisión base | `2ad9ac4abb3b5a8f01410e7e30ca5f3ffb24db77`; árbol con los cambios de PG-A.09 sin commit |
| Host/build | Mac14,3, macOS 27.0.1, 8 CPUs lógicas, 16 GiB; Flutter 3.47.5, Dart 3.13.4, test mode; no build Release |
| Procesos / iteraciones | 10 PID distintos / 30 muestras por tamaño y proceso; 900 muestras en total |
| Tamaños | 1, 10 y 100 implementaciones de una interfaz |
| Resolución observada | Ticks monotónicos calibrados por proceso; resolución observada de 41 ticks (aprox. 41 ns), valores por muestra en JSONL |
| Operaciones del puente | 4 por carga de vista y 4 por construcción completa en las 900 muestras |
| Salidas crudas | `e-pg-12-estatico-raw/process-01.jsonl` a `process-10.jsonl`, 90 filas por archivo; hashes en el manifiesto |
| Resumen recalculable | `e-pg-12-estatico-resumen.json`; SHA-256 `3b10de367ba4b56b89f0f48af0fe9534a926291c80b0df87ad9302466ac77c1c` |
| Identidades y omisiones | 2/11/101 marcos y 1/10/100 relaciones respectivamente en todas las muestras; cero relaciones omitidas |
| Límites de la muestra | No mide rasterización GPU ni interacción; el build del test no es Release. `scene_build_ns` no separa las etapas internas. Sin presupuesto aprobado |

Resultados descriptivos sobre las 300 muestras por tamaño; no son umbrales de aceptación:

| Implementaciones | Carga de vista mediana / p95 (ms) | Escena completa mediana / p95 (ms) | Layout sintético mediana / p95 (ms) | Registro de pintor mediana / p95 (ms) | Máximo RSS muestreado (bytes) |
|---:|---:|---:|---:|---:|---:|
| 1 | 1.205 / 1.722 | 1.139 / 5.221 | 0.020 / 0.062 | 0.148 / 0.350 | 271,286,272 |
| 10 | 5.608 / 10.491 | 5.790 / 10.065 | 0.042 / 0.174 | 0.750 / 1.316 | 272,138,240 |
| 100 | 92.106 / 110.222 | 90.810 / 98.372 | 0.365 / 1.119 | 23.688 / 29.388 | 271,646,720 |

IC bootstrap del 95 % sobre las medias de proceso para construcción de escena: 1 implementación, 1.846–2.540 ms;
10, 6.809–7.084 ms; 100, 91.542–93.798 ms. El detector encontró candidatos de punto de cambio en 4 segmentos de
`scene_build_ns` para 100 implementaciones, 390 para `layout_ns` (10 y 100) y 153 para `paint_record_ns` (10 y 100).
Se conservaron todos y no se afirma estado estacionario. Los logs `process-01.log` a `process-10.log` contienen CPU y
memoria del proceso Flutter completo, incluidos arranque y test runner; no se atribuyen esos recursos a una etapa.

Un primer intento sin permiso de escritura de la cache externa del SDK terminó antes de ejecutar el arnés. Su log se
conserva como `e-pg-12-estatico-raw/pre-campaign-sdk-cache-denied.log`; no es una muestra. Los diez procesos oficiales
se ejecutaron después con salida cero.

Verificación reproducible: los 88 tests dirigidos de escenas, identidad, layout, routing, accesibilidad, Semantics,
render y puente pasaron; `test_bridge.sh` pasó 20 tests del puente; los tests nuevos de estímulos y resumen pasaron.
También pasaron `flutter analyze --fatal-infos --fatal-warnings`, `dart run tool/check_limits.dart`,
`dart run tool/check_syntax_coverage.dart` (78/78) y las 24 pruebas de arquitectura/cobertura. La suite Flutter
completa no se repitió: permanecen como contexto los 29 fallos heredados con nombre ya registrados arriba. No hubo
fallos nuevos en esta selección.

El punto PG-A.09 se registra como satisfecho en su parte automatizable y como **Diferido** en su parte humana, conforme
a la decisión previa. La fase PG-A y sus cierres comunes permanecen abiertos.
