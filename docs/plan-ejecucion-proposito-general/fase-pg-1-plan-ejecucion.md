# Fase PG-1 · Identidad y proyectos — plan de ejecución

## 0. Metadatos

- Fase: PG-1; requisitos R-01–R-04, R-14 y R-18; capacidades C-01–C-03.
- Decisiones rectoras: ADR-01, ADR-04 y ADR-05, con las decisiones posteriores del 2026-10-22.
- Riesgos principales: K-02 y K-03. Experimentos: E-PG-01 y parte de proyecto de E-PG-02.
- Fecha de preparación: 2026-10-23, zona America/Lima.
- Revisión inicial: `aff252c841e846097f8e0b794063966121bc0ed9`; árbol limpio al comenzar.
- Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- Autorización documental: «Crea el plan de ejecución detallado para `PG-1 · Identidad y proyectos`
  considera que se deben seguir las mejores practicas de programación y microarquitectonicas para
  obtener le mejor rendimiento, pero sin poner limites absurdos o imposibles de cumplir como test.»
- Estado: el mensaje de la persona «Implementa en una iteración `PG-1.01 · Identidad de fuente de
  extremo a extremo`» del 2026-10-23 autorizó PG-1.01. La respuesta «Sí, sincroniza y continúa»
  autorizó alinear el estado global de PG-0 con su registro de cierre. El mensaje «implementa
  `PG-1.02 · Modelo de módulo, paquete, workspace y entrada` y `PG-1.03 · Imports, aliases,
  visibilidad y reexportación` en una sola iteración» del 2026-10-23 autoriza únicamente esos dos
  puntos. El mensaje «implementa `PG-1.04 · Rechazo determinista de ciclos` y `PG-1.05 · Manifiesto
  declarativo y autoridad externa` en una sola iteración» del 2026-10-23 autoriza únicamente esos dos
  puntos. PG-1.06 en adelante, `PG-1.C01`/`C02`, el cierre de la fase y las fases siguientes
  permanecen sin autorizar.
- Dependencia satisfecha: el registro de cierre de PG-0 declara la fase cerrada el 2026-10-22. La
  tabla global estaba obsoleta; se sincroniza a `Cerrada · PG-0.01–.12` por instrucción explícita.

Documento transitorio de `docs/`. Desarrolla el [plan general](plan-ejecucion-proposito-general.md)
y la [hoja de ruta](../hoja-de-ruta-proposito-general.md). Ningún archivo fuera de `docs/` lo cita
(`DOC-NO-TRANSIENT-REFS`). Las decisiones aceptadas se trasladarán a los README dueños; el
comportamiento observable, al corpus, sin depender de este texto.

## 1. Punto de partida

| Estado comprobado en la revisión inicial | Consecuencia |
|---|---|
| `pseudolearn_source/src/span.rs` representa inicio y fin con dos `u32`; `SourceText` conserva texto e índice de líneas, sin identidad de archivo/proyecto | Conservar offsets locales compactos y añadir contexto de procedencia sin insertar URI en cada token |
| `pseudolearn_ir/src/span.rs::IrSpan` guarda cuatro coordenadas, sin archivo | Ampliar mapas, verificación, lectura e impresión de RI; no atribuir instrucciones de distintas unidades al mismo texto |
| `pseudolearn_api/src/model.rs::AnalyzeRequest` recibe un texto, perfil y rigor; `analyze.rs` construye una sola fuente | Añadir operaciones de proyecto que reciban fuentes explícitas; conservar la ruta de archivo suelto |
| `pseudolearn_service/src/document_session.rs` reconstruye árbol/análisis/índice en cada edición; huellas informan cambios, sin reutilización semántica | No afirmar que existe un índice incremental de proyecto; medir el reanálisis antes de añadir cachés |
| `pseudolearn_api/src/native_build.rs` recibe `program`, `profile` y `source_name`; `pseudolearn_codegen/src/fault_table.rs` guarda rangos por sitio | Compilar un grafo cerrado y llevar archivo/perfil de origen a las trampas, en lugar de un único nombre/perfil global |
| `pseudolearn_api/src/event_binary.rs` usa PLEV versión 1; el pool conserva `data` y `source` | Especificar negociación y versiones nuevas cuando cambie el significado; no reinterpretar lotes existentes |
| `apps/pseudolearn_cli/src/check_command.rs` recorre archivos y analiza cada uno aisladamente; `build_command.rs` lee un texto | Un directorio de archivos comprobados no constituye todavía un proyecto resuelto |
| `LANG.LEXICAL.IDENTIFIER#R1` admite ASCII en estricto y alfabeto español adicional en flexible; NFC precede a la comprobación | PG-1.10 requiere ampliar la regla y añadir casos, preservando los esperados previos |
| `LANG.EDITION.MODEL`, `LANG.PROFILE.MODEL`, `LANG.SOURCE.POSITION`, `DIAG.ORDERING`, `IR.SOURCE-MAP` y `API.WIRE-FORMAT` están estables en 1.0.0 | Conservar identidades, estados y versiones; editar texto oficial y reanclar solo las identidades afectadas |
| La matriz de engine no declara un crate de proyecto; CLI solo puede importar `pseudolearn_api` | Declarar dueño y dependencias antes del código; ninguna resolución semántica propia en CLI |
| El puente recibe sobres JSON; `RustDiagnosticProjection` usa un índice de offsets del documento, y `RustEvent` extrae solo `node_id` | Probar que una procedencia ajena nunca se convierte con el índice del documento activo |
| PG-H entrega consulta común y catálogo generado; su cierre declara margen iOS de aproximadamente 0,32 % | Añadir ayuda de módulos desde el corpus y medir tamaño temprano; no asumir que el margen histórico alcanza |

Alcance: fuentes con identidad compuesta; proyectos locales y dependencias de contenido fijado;
módulos, visibilidad y reexportación; manifiesto/lock declarativos; perfiles es/en por archivo;
alfabeto español estricto; check/run/build multiarchivo por API y CLI; compatibilidad de consumidores.

Fuera de alcance: registro público, descarga automática, rangos/MVS, compilación separada, carga
dinámica, efectos nuevos, tareas, genéricos, IDE, DAP y servicio LSP de workspace completo.
PG-6A completa rename, watchers y dos clientes; PG-A completa las vistas didácticas nuevas.
Aquí se entregan los datos de proyección y ayuda que esas superficies necesitarán, sin anunciarlas
como ya implementadas.

## 2. Lectura realizada

Lectura focalizada en responsabilidades afectadas, sobre la revisión inicial:

- [x] `AGENTS.md` y `README.md` raíz; plan general §4.3 y §5; hoja de ruta R-01–04/14/18,
  C-01–03, ADR-01/04/05/06/08, K-02/03, E-PG-01/02 y decisiones del 2026-10-22.
- [x] README y `architecture.yaml` de `packages/pseudolearn_spec`,
  `packages/pseudolearn_engine` y `apps/pseudolearn_cli`.
- [x] README de `pseudolearn_source`, `pseudolearn_service` y `pseudolearn_bench_worker`;
  README de app: alcance, frontera Rust, identidad, tamaños y verificación; reglas de app;
  README y reglas de `apps/pseudolearn_app/native`.
- [x] Corpus: `LANG.SOURCE.POSITION`, `LANG.LEXICAL.IDENTIFIER`, `LANG.PROFILE.MODEL`,
  `LANG.EDITION.MODEL`, `DIAG.ORDERING`, `IR.SOURCE-MAP`, `API.WIRE-FORMAT`,
  `PERF.PROTOCOL` y `PERF.ARTIFACT.SIZE`.
- [x] Código de span/texto/normalización; análisis y modelos API; sesión documental; mapas RI;
  petición AOT y tabla de fallos; códec PLEV; check/build CLI; constructor de peticiones SEE;
  proyección Dart de diagnósticos/eventos y frontera `native/src/api.rs`.

Al comenzar cada tarea se leerán el README del crate y los contratos adicionales que efectivamente
modifique: gramática/vocabulario, resolución, formato lógico, API de recursos/versionado, eventos,
CLI, catálogo y protocolo SEE. Se ampliará el inventario de §5 antes de editar archivos no previstos.
La lectura preparatoria no constituye evidencia de conformidad ni de rendimiento actual.

## 3. Decisiones de diseño propuestas

Las formas de sintaxis, nombres de manifiesto/lock e identidades nuevas de contratos son candidatas
hasta redactarlas y revisarlas en el corpus. No se crea un selector de edición por paquete:
2026 es la única edición; una etiqueta incompatible en datos de entrada se rechaza explícitamente.

| Decisión | Opciones | Criterio | Elección propuesta y dueño | Condición de reversión |
|---|---|---|---|---|
| D-PG1-01 Procedencia | URI por tramo; identidad compacta más tabla | Exactitud y tamaño | IDs tipados de proyecto/revisión/archivo; span local más localización compuesta; tabla inmutable. README source/API/IR | Coste medido o identidad insuficiente; cambiar representación conservando contrato |
| D-PG1-02 Resolución | Checker con disco; CLI con semántica; capa pura | Una responsabilidad y portabilidad Wasm | Nuevo `pseudolearn_project` entre syntax y semantic: modelos, manifiesto/lock como datos, grafo y nombres lógicos. Host entrega bytes verificados; semantic resuelve tipos y visibilidad. README engine y crate nuevo | Una dependencia crea ciclo; rediseñar frontera antes de implementar |
| D-PG1-03 Almacenamiento | Objetos enlazados; tablas contiguas | Localidad y préstamo simple | Vectores con índices tipados para fuentes, módulos, símbolos y aristas; nombres normalizados una vez por revisión. README project/semantic | Perfilado demuestra que otro diseño mejora una carga representativa |
| D-PG1-04 Orden | Iteración de mapas/disco; orden explícito | Reproducibilidad | IDs opacos separados de claves de orden portables; ordenar frontera pública/lock por claves canónicas. README project/diagnostics | Coste dominante demostrado; preservar exactamente el orden observable |
| D-PG1-05 Compilación | Concatenar textos; vincular unidades tipadas | Identidad, perfiles y mundo cerrado | Analizar cada unidad con su perfil, registrar firmas y vincular un HIR/RI común; sin efectos de import ni búsqueda en ejecución. README semantic/lowering/API | Error de semántica o de disposición; nunca abrir el mundo para evitar resolverlo |
| D-PG1-06 Manifiesto | Formato propio; parser declarativo existente | Esquema, diagnósticos y dependencia justificable | Evaluar TOML para `pseudolearn.toml`; campos desconocidos/duplicados y versión no soportada con rechazo definido. Parser sin ejecución. README project/CLI | El parser no conserva procedencias o aumenta excesivamente artefactos; comparar alternativas antes de fijar formato |
| D-PG1-07 Lock local | Rutas absolutas; origen lógico y contenido | Portabilidad e integridad | Origen relativo a raíz concedida, contenido y aristas canónicos; hash de bytes y rutas normativas; escritura explícita y atómica, nunca actualización silenciosa durante check/run/build. README project/CLI | El esquema no distingue dos orígenes o impide reproducir sin red |
| D-PG1-08 Revisiones | Estado mutable compartido; snapshot | Consistencia de vistas y ejecución | Snapshot dueño de fuentes/configuración/lock; una ejecución conserva su snapshot; edición crea revisión nueva. README source/API/service | Retención desmedida; liberar por vida de recursos sin reciclar identidades observables |
| D-PG1-09 Caché | Caché universal; reanálisis inicial | Complejidad justificada por datos | Empezar por análisis frío correcto; añadir reutilización por archivo/dependencia solo si E-PG-02 la justifica y tras documentar clave e invalidación. README service/project | Beneficio no medible o resultado diferente del frío; retirar caché |
| D-PG1-10 Rutas | Prefijos de cadenas; raíz como capacidad | Evitar escapes y carreras | Adaptador host con apertura confinada a raíz y lectura desde el descriptor autorizado; núcleo solo recibe contenido. Evaluar dependencia segura compatible con toolchain/licencias. README CLI | No puede demostrarse confinamiento en plataforma objetivo; no anunciar esa garantía allí |
| D-PG1-11 Intercambio | Añadir campos con significado nuevo a versión anterior; negociar | Compatibilidad explícita | Nuevo contrato de payload multiarchivo y versión PLEV cuando corresponda; mantener ruta de documento único o rechazo tipado de versión. README API/puentes | Complejidad innecesaria demostrada por auditoría de compatibilidad, sin reinterpretar bytes |

### 3.1 Criterios de programación y microarquitectura

1. Resolver imports, aliases, permisos y perfiles antes de generar código. El despacho rápido no
   busca rutas, nombres, manifiestos ni hashes. Un fallo o evento materializa su ubicación desde
   el identificador del sitio; el mapa permanece fuera de los operandos calientes cuando sea viable.
2. Conservar tokens en columnas, árbol plano, HIR con índices, bancos tipados, mapas de raíces y
   representación común VM/AOT. No añadir etiquetas universales ni indirecciones por archivo a cada valor.
3. Recorrer tablas contiguas y tomar préstamos del snapshot para no clonar fuentes por arista.
   Reservar memoria a partir de cantidades verificadas; no reservar según tamaños hostiles sin comprobarlos.
4. Normalizar nombres/rutas de comparación una vez; conservar bytes originales para posiciones,
   hashes y mensajes. URI y prosa se construyen al presentar, sin repetirse en todas las estructuras.
5. Grafo con listas de adyacencia y recorrido iterativo para evitar agotamiento de pila del host.
   Previsión: O(V+E) para validar ciclos después de construir el grafo. Canonización puede añadir
   O(V log V + E log E); análisis y hashing dependen además de bytes y símbolos. No prometer
   complejidad lineal de toda compilación ni medirla con un cronómetro unitario.
6. Primero medir CPU, memoria, asignaciones y copias; después inspeccionar perfil y disposición.
   Contadores de caché/ramas son diagnóstico opcional si la máquina los ofrece. No exigir un
   número de fallos L1, ciclos de CPU o tamaño de caché universal como test.
7. Conservar errores y construcción de diagnósticos fuera del camino habitual. No usar `unsafe`,
   SIMD manual, alineación de caché, hashers débiles, paralelismo o nuevos allocators por intuición.
   Un cambio ajeno a esta fase sigue siendo FUT-04 y requiere autorización propia.

Como referencia de método, se toma perfilado de asignaciones y evaluación de contenedores del
[Rust Performance Book](https://nnethercote.github.io/perf-book/heap-allocations.html), sin adoptar
sus cifras como presupuestos de PseudoLearn. Para rutas se toma la advertencia de carreras de
[la biblioteca estándar Rust](https://doc.rust-lang.org/std/fs/index.html#time-of-check-to-time-of-use-toctou):
consultar metadatos y abrir después no prueba confinamiento. No se presupone disponibilidad de APIs
experimentales. Estas referencias y lo adoptado/rechazado se registrarán en el README dueño al implementar.

## 4. Desglose por punto

Cada bloque sigue especificación → casos → tests → código → documentación → verificación.
Las tareas entre bloques se ejecutan según §10: no es necesario implementar un bloque completo
antes de especificar el siguiente. Los tests de comportamiento del lenguaje viven en el corpus;
los tests Rust prueban algoritmos, invariantes y fronteras, sin duplicar esos programas.

### PG-1.01 · Identidad de fuente de extremo a extremo

- [x] `PG-1.01.01` Especificar proyecto, snapshot/revisión, archivo, nodo y tramo; vida útil, rechazo de revisión ajena y conversiones de coordenadas. Ampliar `LANG.SOURCE.POSITION`, `IR.SOURCE-MAP`, API, eventos, trampas AOT y negociación de formatos sin cambiar versiones congeladas de especificación.
- [x] `PG-1.01.02` Derivar casos con dos archivos de igual nombre/offset, revisión antigua, UTF-8/UTF-16, CRLF, BOM, texto vacío, caracteres suplementarios y relacionados en otro archivo; incluir fallos AOT en biblioteca.
- [x] `PG-1.01.03` Escribir tests espejo de identidad, lookup de fuente, validez de rangos y códecs; negativos de fuente inexistente, versión desconocida, lote truncado y revisión cruzada.
- [x] `PG-1.01.04` Implementar IDs/localizaciones, tablas de fuente y propagación por diagnóstico, HIR/RI/bytecode, sitio de fallo, evento y vista pública; adaptar lectores de documento único y consumidores reales.
- [x] `PG-1.01.05` Actualizar README de source, diagnostics, IR, ejecución, API, service y puentes afectados; documentar compatibilidad y reglas de import necesarias.
- [x] `PG-1.01.06` Verificar ida/vuelta JSON/binario/RI, procedencia exacta de fallo y evento, aislamiento Wasm/móvil y no reciclaje entre revisiones; medir bytes de mapa frente a base.

### PG-1.02 · Modelo de módulo, paquete, workspace y entrada

- [x] `PG-1.02.01` Especificar archivo=módulo, raíz y pertenencia de paquete, workspace local, biblioteca sin algoritmo y selección de una sola entrada por aplicación. Mantener el contrato del programa suelto.
- [x] `PG-1.02.02` Derivar casos de tres módulos y biblioteca local, workspace vacío, paquete biblioteca, entrada ausente/duplicada/inexistente y módulo perteneciente ambiguamente a raíces.
- [x] `PG-1.02.03` Probar construcción de snapshot y catálogo de módulos con fuentes en memoria; rechazo sin infraestructura real de disco.
- [x] `PG-1.02.04` Declarar y crear crate project, modelos y catálogo; exponer operación pública de proyecto y enlace a una entrada, sin concatenar textos.
- [x] `PG-1.02.05` Escribir primero README del crate nuevo y matriz engine; actualizar README API/semantic y registro de dependencias Cargo.
- [x] `PG-1.02.06` Verificar proyecto mínimo, biblioteca sin entrada y errores de aplicación; ejecutar arquitectura antes de integrar CLI.

### PG-1.03 · Imports, aliases, visibilidad y reexportación

- [x] `PG-1.03.01` Especificar import nominal y alias, privado por defecto para módulos nuevos, público explícito, export/reexport solo de símbolos públicos y sin comodines ni inicialización con efectos; delimitar visibilidad heredada de archivo único.
- [x] `PG-1.03.02` Derivar casos de nombre ausente/privado, alias de dependencia y símbolo, colisión local, reexport encadenado/ambiguo, público homónimo en paquetes distintos e import sin efecto observable.
- [x] `PG-1.03.03` Probar tablas de símbolos y firmas importadas, unicidad de identidad tras alias y rechazo de RI/enlace con referencia no resuelta; negativos de cobertura de ayuda.
- [x] `PG-1.03.04` Ampliar gramática/vocabulario mediante generadores, resolver nombres/visibilidad en semantic y vincular HIR/RI cerrado; añadir roles, fichas es/en y datos públicos de dependencias.
- [x] `PG-1.03.05` Documentar dueño de símbolos, orden de registro y preservación de desvirtualización; actualizar catálogo y matriz de proyección sin implementar vistas de PG-A.
- [x] `PG-1.03.06` Verificar corpus positivo/negativo, identidad de alias, cero ejecución al importar y generación vigente; no introducir constantes o mecanismos de PG-2 para resolver inicialización.

### PG-1.04 · Rechazo determinista de ciclos

- [x] `PG-1.04.01` Especificar qué aristas forman ciclos y cómo se elige/muestra una cadena completa reproducible con sus ubicaciones; preservar recursión mutua dentro del módulo.
- [x] `PG-1.04.02` Derivar autociclo, dos módulos, ciclo de paquetes, varios ciclos, diamante válido, arista repetida y cadena profunda; esperado calculado desde el grafo.
- [x] `PG-1.04.03` Probar recorrido iterativo, cadena completa y equivalencia ante permutación de vértices/aristas, con grafos pequeños exhaustivos y generados sembrados.
- [x] `PG-1.04.04` Implementar validación del grafo en project y diagnósticos relacionados; impedir enlace parcial de grafo inválido.
- [x] `PG-1.04.05` Documentar coste, orden de recorrido y propiedad de aristas en README project; sin habilitar SCC como excepción semántica.
- [x] `PG-1.04.06` Verificar rechazo antes de compilar y que grafos acíclicos profundos no desbordan la pila; separar estrés de la suite corta.

### PG-1.05 · Manifiesto declarativo y autoridad externa

- [x] `PG-1.05.01` Especificar esquema versionado, nombre/raíz, perfiles por defecto/excepciones, entradas, dependencias fijadas, solicitudes de límites/permisos y procedencia de cada campo. Sin selector de otra edición ni idioma personal de interfaz.
- [x] `PG-1.05.02` Derivar datos válidos, archivo vacío/malformado, duplicados, campos/versión desconocidos, ruta inválida, solicitudes sin concesión y concesión más amplia que solicitud.
- [x] `PG-1.05.03` Probar parser y configuración resuelta como valores; prueba de intersección/no amplificación y negativos de esquema con ubicación de campo.
- [x] `PG-1.05.04` Implementar lectura declarativa pura y cálculo de autoridad; host aporta concesiones explícitas. Solo modelar permisos necesarios, sin implementar efectos de PG-3/5.
- [x] `PG-1.05.05` Registrar formato, parser elegido, precedencia y valores heredados en README project/CLI y sus reglas/dependencias.
- [x] `PG-1.05.06` Verificar que abrir/check/build no ejecutan scripts ni conceden permisos por el contenido del proyecto; comprobar idioma de interfaz independiente.

### PG-1.06 · Lock canónico y contenido verificado

- [ ] `PG-1.06.01` Especificar identidad de origen/contenido, versión de esquema, aristas, orden canónico, algoritmo/dominio de hash, exclusiones del árbol y actualización explícita; distinguir dependencia local editable de contenido bloqueado.
- [ ] `PG-1.06.02` Derivar lock idéntico tras reordenar entradas, checkout reubicado, contenido alterado, entrada/arista ausente, hash falso, caché incompleta/corrupta, mismo nombre con dos orígenes y versión no soportada.
- [ ] `PG-1.06.03` Probar serialización canónica, hashing de bytes leídos y publicación atómica; usar fixture con digest derivado independientemente y negativo de resumen/manifiesto alterado.
- [ ] `PG-1.06.04` Implementar resolución exacta local/caché, verificación previa a compilar y escritura explícita del lock; compilar los mismos bytes que se verificaron. Sin red, scripts ni actualización implícita.
- [ ] `PG-1.06.05` Documentar qué se incluye en hash, política de cambios locales y permisos de escritura en README project/CLI; lock del lenguaje distinto de los `Cargo.lock` del repositorio.
- [ ] `PG-1.06.06` Verificar reproducción offline con lock/caché completos, rechazo con datos incompletos y estabilidad de bytes al permutar orden; un hash verifica integridad, no autenticidad del origen.

### PG-1.07 · Perfiles por archivo e imports bilingües

- [ ] `PG-1.07.01` Ampliar `LANG.PROFILE.MODEL` y contratos de proyecto: perfil por archivo, precedencia explícita, discrepancia con ambas procedencias y alias obligatorio si el nombre es reservado en destino. Fijar formato lógico y conversiones según archivo de la operación.
- [ ] `PG-1.07.02` Derivar imports es→en/en→es, biblioteca sin apertura, configuración contradictoria, nombre reservado con/sin alias, palabra extranjera como nombre legal y salida lógica desde módulos de ambos perfiles.
- [ ] `PG-1.07.03` Probar selección de tablas por unidad, identidad semántica independiente de lexema, traducción sin renombrar símbolos y perfil de formateo en llamada cruzada VM/AOT.
- [ ] `PG-1.07.04` Propagar perfil por unidad y sitio de operación hasta lowering/ejecución; resolver alias por identidad. No depender del único perfil global de la petición AOT actual.
- [ ] `PG-1.07.05` Documentar precedencia y formato de valores en README lexicon/syntax/semantic/API/CLI; generar formas y ayuda desde el corpus.
- [ ] `PG-1.07.06` Verificar paridad de firmas/códigos/argumentos entre perfiles, salida lógica correcta y E-PG-01; idioma de interfaz no altera programa ni lock.

### PG-1.08 · Orden público de diagnósticos

- [ ] `PG-1.08.01` Ampliar `DIAG.ORDERING`: clave de paquete/módulo canónico y orden local vigente, empates, diagnósticos sin fuente y ubicación de campos del manifiesto/lock.
- [ ] `PG-1.08.02` Derivar varios errores en archivos con offsets iguales, principales/relacionados, causas independientes y múltiples órdenes de descubrimiento.
- [ ] `PG-1.08.03` Probar permutaciones de carga e igualdad exacta de diagnósticos, sin comparar el valor literal de IDs opacos entre sesiones; preservar alias e identidades mediante correspondencia biyectiva.
- [ ] `PG-1.08.04` Centralizar comparación y presentación de resultados en sus dueños; no ordenar de nuevo con reglas propias en CLI o cliente.
- [ ] `PG-1.08.05` Documentar clave portable y separación entre identidad y orden en README diagnostics/project/API.
- [ ] `PG-1.08.06` Verificar mismo orden en API y CLI, mismo conjunto de causas y relacionados al variar inserción e idioma de interfaz; comprobar orden documental existente.

### PG-1.09 · Rutas portables y confinamiento

- [ ] `PG-1.09.01` Especificar rutas lógicas relativas, política de caja/NFC, separadores, componentes prohibidos, raíces externas concedidas y tratamiento de symlinks; no confundir canonicalización con autorización.
- [ ] `PG-1.09.02` Derivar colisiones de caja/NFC, `..`, ruta absoluta, prefijos parecidos, symlink en componente intermedio/final, ciclo de enlaces y dependencia fuera de raíz sin/con concesión independiente.
- [ ] `PG-1.09.03` Probar normalización con fuentes virtuales y confinamiento con directorios efímeros reales; sustitución coordinada de enlace entre validación/apertura, sin esperar que el azar reproduzca una carrera.
- [ ] `PG-1.09.04` Implementar claves portables en project y apertura confinada en el adaptador CLI; mantener descriptor/bytes verificados hasta construir snapshot. Rechazar rutas no representables sin conversión silenciosa con pérdida.
- [ ] `PG-1.09.05` Documentar garantías y plataformas realmente comprobadas; declarar dependencia segura del host antes de usarla, sin extender `unsafe` propio al resolver.
- [ ] `PG-1.09.06` Verificar que ningún rechazo lee contenido externo ni deja salida parcial; simular colisiones en memoria donde el filesystem local no permita crearlas. No declarar soporte de otro SO por analogía.

### PG-1.10 · Alfabeto español en rigor estricto

- [ ] `PG-1.10.01` Editar `LANG.LEXICAL.IDENTIFIER#R1` para admitir alfabeto español en estricto con NFC, conservando sensibilidad a caja/acentos y perfil independiente del rigor; no extender a XID completo.
- [ ] `PG-1.10.02` Añadir casos para ñ/Ñ, vocales acentuadas, ü/Ü, formas descompuestas, nombre de un carácter, marca aislada y letra fuera del alfabeto; conservar casos previos.
- [ ] `PG-1.10.03` Probar tokenización de nombre completo, normalización y validación posterior; distinguir rechazo léxico de nombre reservado y de colisión canónica.
- [ ] `PG-1.10.04` Ajustar validación en source/lexicon/syntax según dueño actual; mantener camino ASCII y texto original sin normalizar.
- [ ] `PG-1.10.05` Documentar ampliación de entradas aceptadas, alfabeto exacto y límites en README/corpus; actualizar ayuda sin prometer homógrafos generales.
- [ ] `PG-1.10.06` Verificar ambos perfiles/rigores, rangos originales, igualdad NFC y ausencia de cambios en resultados previos; incluir Unicode en medición léxica.

### PG-1.11 · Compatibilidad de archivo suelto 2026

- [ ] `PG-1.11.01` Fijar equivalencia de programa/configuración/observables previos: sin manifiesto ni imports obligatorios, sin migración al abrir y sin cambio de esperados. Nuevas reservadas no pueden romper nombres de programas sueltos silenciosamente.
- [ ] `PG-1.11.02` Inventariar casos existentes y añadir colisiones de palabras nuevas, biblioteca pegada sin proyecto, archivo vacío y nombres antes legales; esperados derivados de reglas, nunca capturas del motor nuevo.
- [ ] `PG-1.11.03` Preparar regresiones por API/CLI y transporte real de app, incluida identidad/foco con dos sentencias en una línea y rechazo de revisión ajena.
- [ ] `PG-1.11.04` Conservar entrada de documento único y adaptar únicamente lectura/proyección/versionado de consumidores que lo necesiten; ninguna administración de proyectos en la app.
- [ ] `PG-1.11.05` Actualizar README de consumidores afectados y registrar impacto de gramática. Ante contradicción inevitable con `.03` o `.10`, reportar casos exactos y esperar decisión; no fabricar otro modo ni editar esperados para obtener verde.
- [ ] `PG-1.11.06` Ejecutar conformidad previa íntegra de engine/aot/service/cli/app con capacidades reales, más puente y Wasm; comparar fallos, salida, traza y vistas aplicables, sin anunciar observe en AOT.

### PG-1.12 · Integración pública y CLI

- [ ] `PG-1.12.01` Especificar selección explícita de proyecto/entrada en check/run/build, alias es/en, respuesta JSON, códigos de salida, errores operativos y política de salida AOT; gramática CLI definitiva desde corpus.
- [ ] `PG-1.12.02` Derivar caso integrador de tres módulos, dos perfiles y biblioteca local, invocado desde otro directorio; incluir error en biblioteca, lock alterado, permiso denegado, entrada inválida y enlazador fallido.
- [ ] `PG-1.12.03` Escribir tests de procesos reales para check/run/build y ejecutable autónomo; proteger archivo de salida previo y comprobar limpieza temporal en éxito/fallo.
- [ ] `PG-1.12.04` Conectar adaptadores host a operaciones públicas de proyecto; compilar RI común y presentar diagnósticos de su fuente real. Mantener CLI sin imports de internos del motor.
- [ ] `PG-1.12.05` Actualizar README CLI/API, mensajes generados y datos de conformidad; documentar invocaciones finales reproducibles, incluida generación explícita del lock.
- [ ] `PG-1.12.06` Verificar resultado derivado igual en VM y binario AOT real, con proyecto reubicado/cwd ajeno y entorno controlado; probar fallo dentro de módulo importado y formato lógico de origen.

### PG-1.13 · Experimentos y presupuesto observado

- [ ] `PG-1.13.01` Fijar protocolo, cargas, controles y criterios E-PG-01/E-PG-02 de proyecto; separar presupuestos candidatos de contratos PERF vigentes antes de medir.
- [ ] `PG-1.13.02` Preparar datasets canónicos sembrados, grafos cadena/estrella/diamante y controles semánticamente equivalentes, con resultados derivados del corpus.
- [ ] `PG-1.13.03` Probar arnés/resumen con salida incorrecta, proceso/muestra ausente, datos alterados y mezcla de máquinas/protocolos; ninguna campaña inválida produce verde.
- [ ] `PG-1.13.04` Ampliar tooling existente con trabajadores de perfiles/proyecto/resolución y campaña reproducible; recoger datos crudos y perfil diagnóstico separado.
- [ ] `PG-1.13.05` Documentar comandos reales y definiciones de intervalo en README del trabajador; registrar resultados, limitaciones y decisiones de la persona en este resumen.
- [ ] `PG-1.13.06` Ejecutar campañas, recalcular resúmenes, medir tamaño de artefactos y regresión pura; reportar umbrales no alcanzados sin reducir tamaños del programa ni alterar controles.

## 5. Capas y archivos

Las rutas siguientes son relativas al monorepo. `E` abrevia
`packages/pseudolearn_engine/crates`, `S` abrevia `packages/pseudolearn_spec` y
`A` abrevia `apps/pseudolearn_app`. «Nuevo» es propuesta, no un archivo ya existente.
Los grupos enumeran una misma responsabilidad; antes de cada lote se registrará su lista concreta
de archivos y se responderán de nuevo capa, imports y dueño. No autorizan cambios indiscriminados.

| Archivos nuevos o modificados previstos | Capa; qué puede importar / qué tiene prohibido | Dueño y motivo; puntos |
|---|---|---|
| Este archivo; enlace de PG-1 en plan general | Documentación transitoria; referencias internas de docs / sin dependencia inversa desde código o README | Plan detallado nuevo, separado del checklist general; preparación |
| `S/specifications/lang/`: contratos actuales de fuente/perfil/identificador/gramática y nuevos de módulos/proyecto; `diag/diag.ordering.md`, `ir/ir.source-map.md`, `api/`, `tool/`, `rt/`, `eng/` afectados | Datos normativos; identidades internas del corpus / sin código, docs transitorios ni enlaces externos | Corpus dueño de conducta; `.01`–`.12`. Nuevos IDs definitivos tras auditoría de dueños |
| `S/specifications/cases/`, `S/schemas/`, `S/fixtures/`; manifiestos de conformidad de miembros | Datos de casos/esquemas/vínculos / sin esperados capturados ni referencias transitorias | Proyectos y procedencias múltiples; `.01`–`.13` |
| `S/crates/see_model/src/`, `see_validation/src/`, `see_conformance/src/requests.rs` y nuevos módulos `project_requests.rs`, `project_comparison.rs`; `see_export/src/` solo si falta exportar datos | Matriz SEE: model sin capas internas; validation → model/graph/change/format; conformance → model/translation/format/generators/oracles; export → model/change/format / sin imports engine, CLI de producto ni procesos en validation | Modelo valida forma; conformance arma/compara peticiones, no implementa resolutor; `.01`, `.02`, `.05`, `.06`, `.12` |
| `E/pseudolearn_source/src/{span,source_text,normalizer}.rs`; nuevos `source_identity.rs`, `source_snapshot.rs`, `located_span.rs` | Nivel 0; sin imports internos; Unicode ya permitido / sin syntax, project, API ni acceso ambiental | Identidad y texto fuente, no grafo ni filesystem; `.01`, `.10` |
| `E/pseudolearn_project/{README.md,Cargo.toml,src/lib.rs}`; nuevos `src/{project_model,module_graph,module_catalog,manifest_model,manifest_parser,lock_model,lock_encoding,content_identity,logical_path}.rs` | Nueva capa propuesta tras syntax: source/diagnostics/lexicon/syntax; dependencias externas de parser/hash declaradas tras evaluación / sin semantic, API, runtime, CLI ni E/S ambiental | Único dueño de resolución estructural pura; `.02`, `.04`–`.09` |
| `E/pseudolearn_diagnostics/src/`; lexicon/syntax y generadores dueños de formas/gramática | diagnostics → source; lexicon → source; syntax → source/diagnostics/lexicon / sin project, semantic, consumidores ni tablas copiadas | Representación/orden local; tokens y árbol sin resolver imports; `.01`, `.03`, `.07`, `.08`, `.10` |
| `E/pseudolearn_semantic/src/{checker,unit_resolver,service_analysis}.rs`; nuevos `project_analysis.rs`, `module_symbols.rs`, `module_visibility.rs` | Matriz actual más project propuesto / sin filesystem, CLI, runtime ni codegen | Tipado y resolución semántica; reutilizar dueños actuales para semántica local; `.02`, `.03`, `.07` |
| `E/pseudolearn_ir/src/span.rs` y dueños actuales de modelo/parser/impresor/verificador; lowering y bytecode, nuevo módulo de mapa por unidad cuando corresponda | IR → source/abi; lowering → source/semantic/ir/diagnostics; bytecode → ir/source / sin project host ni API | Enlace/mapas verificados con IDs compactos; `.01`, `.03`, `.07` |
| `E/pseudolearn_codegen/src/fault_table.rs`, `pseudolearn_aot_rt` sitios/configuración; VM/timeline eventos y formato lógico | codegen → ir/diagnostics/aot_rt; aot_rt → source/abi/diagnostics/runtime/library; VM → bytecode/runtime/library/diagnostics/vm_dispatch; timeline → vm/runtime/bytecode/diagnostics / sin resolver imports, disco ni clientes | Mantener sitio/perfil original y reconstrucción; `.01`, `.07`, `.11`, `.12` |
| `E/pseudolearn_service/src/document_session.rs`; nuevo `project_session.rs` y consulta de proyecto; ayuda existente | Matriz actual más project propuesto / sin VM, AOT, CLI ni DAP | Snapshot e índice semántico mínimo, sin implementar LSP workspace de PG-6A; `.01`, `.03`, `.07`, `.13` |
| `E/pseudolearn_api/src/{model,analyze,native_build,event_codec,event_binary}.rs`, wire/vistas y recursos; nuevos `project_resource.rs`, `project_operations.rs`, `project_build.rs`, `source_conversion.rs` | Matriz API actual más project propuesto; feature native conserva frontera / sin consumidores ni acceso ambiental | Operaciones públicas totales y negociación; separar tipos de proyecto para no engordar model; `.01`–`.12` |
| `E/pseudolearn_conformance/src/`, `pseudolearn_wasm/src/` | Solo API y dependencias actuales / sin import de project ni backend nativo directo | Transporte/negociación; no un segundo resolutor; `.01`, `.11`, `.12` |
| `E/pseudolearn_bench_worker/src/`: nuevos módulos de cargas/medición/resumen de proyecto; `tool/` campaña | Tooling con matriz existente; pruebas públicas por API / sin semántica alternativa ni dependencias internas nuevas por comodidad | Mediciones y procedencia; `.13` |
| `apps/pseudolearn_cli/src/{options,check_command,run_command,build_command}.rs`; nuevos `project_input.rs`, `project_files.rs`, `project_lock_command.rs` | Adaptador CLI; solo API pública y dependencias externas declaradas / sin imports source/project/semantic/VM | Entrada host, lectura confinada, presentación y escritura explícita; `.05`, `.06`, `.09`, `.12` |
| `A/lib/engine/rust/{rust_diagnostic_projection,rust_wire_models,rust_program_view}.dart`, nuevo `rust_source_location.dart` si lo exige el payload; tests espejo | engine → model/ports y propia capa / sin Flutter, dart:io, presentación ni parsers | Adaptar transporte y comprobar pertenencia antes de proyectar offsets; `.01`, `.11` |
| `A/native/src/api.rs` solo si cambia negociación; `native/tests/` frontera; bindings generados solo por generador | bridge → API/FRB/serde_json / sin internos engine ni modelos Flutter | Transporte real y propiedad de buffers; `.01`, `.11` |
| README de cada miembro/crate tocado, Cargo/dependencias/locks y reglas de esos miembros | Documentación y configuración dueñas / sin citar este plan ni docs transitorios | Decisiones autosuficientes y capas declaradas antes del código; todos |

Cada fuente nueva tiene test espejo en `tests/`; tests internos en hermanos `*_tests.rs`, nunca
en línea. Dart refleja `lib/` en `test/`. Los archivos generados de léxico/gramática/mensajes/FRB
se regeneran desde su dueño (`GEN-NO-HAND-COPY`). No se modifica el paquete de verificadores Rust
para acomodar este diseño: sus reglas actuales bastan salvo necesidad demostrada y revisada.

Cambios de matriz propuestos: registrar project y sus dependencias; permitir project a semantic,
service y API. Los demás imports siguen su lista actual. Si se requiere acceso directo adicional,
se documenta y verifica antes del código; nunca se obtiene transitivamente por suposición.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Qué bloquea y qué se mide

| Tipo | Criterio y control | Tratamiento |
|---|---|---|
| Corrección obligatoria | Resultados derivados de reglas; proyecto/archivo/revisión exactos; no autoridad amplificada; lock/RI inválidos rechazados | Pruebas deterministas; un incumplimiento bloquea el punto |
| Contratos PERF vigentes | `PERF.AOT.LEVEL`, `PERF.ARTIFACT.SIZE`, `PERF.PROTOCOL`; controles y plataformas definidos por corpus | Se respetan y vuelven a medir cuando el cambio los afecta; no se rebajan por este plan |
| E-PG-02 de proyecto | p95 diagnóstico incremental ≤100 ms en máquina identificada; mismo resultado que reanálisis frío | Criterio conceptual heredado, se mide en campaña; si falla, investigar/revisar con evidencia antes del cierre, sin imponer máximo de archivos |
| E-PG-02 rename | p95 ≤500 ms y edición atómica multiarchivo | Pertenece a PG-6A; PG-1 registra el reparto, no declara haberlo demostrado |
| `PERF.PG.LEXICON` candidato | Throughput, bytes y asignaciones de ambos perfiles/Unicode frente a perfil único de igual semántica | Sin ratio inventado. Publicar diferencias e intervalo; persona revisa presupuesto en PG-7 |
| `PERF.PG.PROJECT` candidato | Análisis frío, revisión, memoria, bytes de mapas y coste de enlace frente a control equivalente | Separar carga, parseo, resolución, tipado, lowering y presentación; sin exigir tiempo constante al crecer entradas |
| `PERF.PG.RESOLVE` candidato | Tiempo de resolución/hashing/canonización en grafos de V/E/bytes conocidos y repetibilidad del lock | Informar escalado y lecturas; sin red. No exigir O(V+E) a ordenación/hashing globales |
| Diagnóstico microarquitectónico | Disposición de estructuras, asignaciones/copias, perfil CPU; caché/ramas si hay acceso | Sesión separada de la campaña; ninguna dependencia de permisos privilegiados para un test funcional |

No se exige 100 % de cobertura de líneas, cero asignaciones totales, mismo RSS exacto, mejoras en
todas las cargas, duración exacta de tests, ni equivalencia de rendimiento entre máquinas distintas.
La equivalencia semántica sí es exacta. Los percentiles no se comprueban en `cargo test` con un
cronómetro susceptible a carga del anfitrión; se comprueban en la campaña controlada de `.13`.

Los límites `SIZE-*` existentes se respetan; esta planificación no añade límites físicos nuevos
ni reduce los actuales para forzar archivos artificialmente pequeños. Si una restricción vigente
impide una solución clara, se presenta el caso concreto para revisión, sin omitir el verificador.

### 6.2 Recursos y fronteras

- Limitar recursos de carga: bytes por fuente/manifiesto/lock, bytes totales del snapshot, módulos,
  aristas y revisiones retenidas. Los valores se fijan con cargas representativas y capacidades
  del host; no se inventan aquí topes permanentes de programas. Pruebas de frontera inyectan
  presupuestos pequeños y comprueban justo debajo/en el límite/encima, sin asignar gigabytes.
- Rechazo tipado y terminación definida ante tamaño no representable, presupuesto agotado, formato
  no soportado o grafo inválido. Comprobar sumas/multiplicaciones antes de reservar o decodificar.
- Snapshot inmutable de los bytes efectivamente hasheados. No reabrir por ruta un archivo ya
  verificado; una modificación posterior origina revisión nueva, no una compilación mezclada.
- Raíces de dependencias locales concedidas explícitamente. No heredar búsqueda desde `cwd`,
  `PATH`, variables de entorno o configuración del editor. El enlazador host mantiene su contrato
  operativo; sus herramientas no forman parte de la resolución de módulos.
- Sin red ni scripts al resolver. Una caché incompleta devuelve error; no activa descarga ni
  ejecución de contenido. Solicitud de permisos nunca equivale a concesión.
- Nuevos crates con `#![forbid(unsafe_code)]`; no ampliar las excepciones ABI/puente existentes.
  Las pruebas de carrera usan puntos de coordinación controlados, no repetición estadística.

## 7. Pruebas y experimentos

### 7.1 Matriz mínima de comportamiento

| Área / punto | Feliz | Infeliz | Límite explícito |
|---|---|---|---|
| Identidad `.01` | Localización y relacionados conservados hasta AOT/evento/vista | Fuente o revisión ajena; versión desconocida | Mismo offset en dos archivos; emoji, CRLF/BOM; cierre/reapertura |
| Modelo `.02` | Aplicación y biblioteca local sin algoritmo | Entrada ambigua/inexistente | Workspace vacío; biblioteca sola; módulo vacío |
| Nombres `.03` | Import/alias/reexport público con una identidad | Privado, ausente, comodín o colisión | Alias igual a nombre; reexport repetido; homónimos entre paquetes |
| Grafo `.04` | Cadena y diamante | Autociclo y ciclo entre paquetes | Grafo sin aristas, aristas duplicadas y cadena profunda |
| Manifiesto `.05` | Campos válidos y autoridad intersectada | Campo/versión desconocidos o permiso sin concesión | Archivo vacío, duplicado y presupuesto inyectado |
| Lock `.06` | Mismos bytes tras permutar/reubicar | Hash/caché/arista alterados | Dependencias cero; contenido vacío; nombre repetido con otro origen |
| Perfil `.07` | Imports cruzados y formato lógico de origen | Perfil contradictorio; reservado sin alias | Sin apertura inequívoca; nombre de un carácter; cadena ya formateada |
| Orden `.08` | Lista canónica independiente del recorrido | Relacionado asignado a documento activo | Errores en misma posición; diagnósticos sin fuente |
| Rutas `.09` | Raíz autorizada y dependencia concedida | Escape por enlace, `..`, absoluta o colisión | Nombres NFC descompuestos; prefijos de raíz parecidos |
| Alfabeto `.10` | Español estricto/flexible es/en | Letra no admitida; marca aislada | ñ de un carácter, forma combinada y nombre reservado |
| Compatibilidad `.11` | Corpus previo sin esperados alterados | Revisión obsoleta; colisión con forma nueva | Texto vacío y dos sentencias en una línea |
| CLI `.12` | check/run/build reales desde otro directorio | Fuente/lock/enlazador inválidos, sin salida parcial | Entorno vacío; salida previa; fallo dentro de biblioteca |
| Campaña `.13` | Datos y resumen recalculables | Resultado incorrecto/muestra faltante/crudo alterado | Menos procesos; tiempo bajo resolución; dataset vacío |

Los negativos de validadores nuevos/ampliados cubren al menos esquema de proyecto, referencias
a fuente inexistente, arista/entrada inválida, versión de payload, hash, vínculo/catálogo de ayuda y
resumen de campaña. Cada fixture debe fallar con su código concreto; «falló cualquier cosa» no
demuestra que el control funcione. No se exige un nuevo verificador cuando uno existente ya cubre
la regla. Semillas reproducibles complementan casos pequeños razonados, sin cantidades masivas
arbitrarias ni tests que repliquen línea a línea el algoritmo de producción.

### 7.2 E-PG-01 · Perfiles

1. Preparar 100 módulos sintéticos y 20 pares canónicos de ambos perfiles, con las formas generadas
   del corpus y colisiones explícitas; guardar semilla y hashes. No traducir nombres del usuario.
2. Ejecutar ida/vuelta de formas y resolución de imports es↔en; comparar identidad, firma, resultado,
   diagnósticos y perfil del formato lógico con el oráculo derivado.
3. Control: mismo cálculo y declaraciones en un perfil; igual rigor y volumen comparable de tokens.
   Medir selección léxica/normalización y asignaciones, con ASCII y español, separado del enlazador.
4. Éxito funcional: cero cambios de identidad, cero renombrados automáticos y ninguna doble
   interpretación válida. Una ambigüedad se corrige en especificación/casos antes del código.
   No se ensaya mezcla libre como nueva capacidad del lenguaje.

### 7.3 E-PG-02 · Parte de proyecto

1. Cargas de 10/100/1000 archivos: serie de aproximadamente 10 000 líneas totales de control,
   registrando el total exacto, y otra con volumen creciente. Variar V, E y bytes por separado para
   distinguir coste por archivo, dependencia y texto. Incluir cadena, estrella, diamante y biblioteca.
2. Comparar análisis frío de snapshot nuevo, revisión sin cambios, edición de cuerpo y edición de
   firma; misma configuración, entradas y resultado esperado. Cada muestra comienza desde estado
   preparado nuevo; la revisión comienza desde una base preparada, sin acumular ediciones entre muestras.
3. Llamar a API de proyecto/servicio mínima, sin LSP ni rename. La latencia incremental incluye
   actualizar snapshot, resolver/analizar lo necesario y producir diagnósticos. Control frío incluye
   todo el análisis equivalente; no excluir trabajo solo del candidato.
4. Si el reanálisis no alcanza el criterio conceptual de 100 ms, perfilar antes de introducir
   invalidación: cuerpo invalida al menos unidad propia; firma/export/perfil/manifest/lock invalida
   dependientes transitivos pertinentes. Comparar siempre resultados con análisis frío.
5. Registrar p50/p95, medias por proceso, intervalos, CPU, memoria muestreada y bytes de mapas.
   Canonización/hashing se miden con bytes en memoria; la prueba de carga desde disco se informa
   aparte como latencia de producto, con régimen de caché del SO explícito y sin atribuirla al núcleo.
6. Rename, atómicidad de WorkspaceEdit y dos clientes quedan identificados como trabajo de PG-6A;
   esta entrega no los marca cumplidos ni declara E-PG-02 completo.

### 7.4 Procedencia y regresión

Capturar revisión/estado de fuentes, toolchain exacto, flags, binarios/hashes, hardware/SO, semilla,
cargas y configuración antes de compilar. Campañas en release, al menos 10 procesos × 30 muestras
por carga/configuración, validación fuera del intervalo, sin E/S en el intervalo del núcleo.
Publicar crudos y resumen recalculable, bootstrap 95 % sobre medias por proceso y cocientes
emparejados cuando exista emparejamiento real; informar resolución del reloj y candidatos de cambio
sin descartar muestras (`PERF.PROTOCOL`). El p95 debe declarar población y método de cálculo;
no confundir su objetivo con el intervalo sobre medias por proceso.

Separar creación de snapshot, análisis, serialización y ejecución preparada. Un control de un solo
archivo equivalente a un proyecto solo es válido si conserva declaraciones y observables, incluida
salida lógica; no concatenar textos de perfiles distintos como supuesto oráculo. Para regresión pura,
usar cargas existentes con misma RI/semántica y comparar ejecución preparada, no su tiempo de carga.

Repetir tamaños finales iOS/Wasm según `PERF.ARTIFACT.SIZE` y AOT según `PERF.AOT.LEVEL` cuando
se afecten sus rutas. Una discrepancia es resultado a informar y resolver, no motivo para borrar
casos, rebajar controles ni excluir módulos del dataset. Las órdenes nuevas de campaña no existen
todavía: se publicarán y verificarán en README del trabajador antes de ejecutarlas.

## 8. Riesgos y señales tempranas

| Riesgo | Señal temprana | Mitigación y evidencia |
|---|---|---|
| K-02 Compatibilidad 2026 | Nueva reservada invalida nombre previo; expansión de alfabeto cambia esperado | Auditoría de colisiones y corpus íntegro en `.10`/`.11`; conflicto concreto a la persona |
| K-03 Fuente/revisión equivocada | Dos módulos con mismo rango comparten nodo, diagnóstico o trampa | Identidad compuesta, snapshots y negativos cruzados; E-PG-02 y puente real |
| K-01 Alcance | Aparece registro, efecto, LSP completo o optimización FUT-04 | Trazabilidad de cada tarea a `.01`–`.13`; retirar propuesta fuera de fase |
| K-16/K-17 Ayuda | Ficha sin ejemplo o palabra nueva interpretada por consumidor | Generación y consulta común; negativos de cobertura/rol y revisión obsoleta |
| K-07 Rutas, aplicado a carga de proyecto | Prefix-check acepta raíz parecida; cambio de symlink modifica bytes leídos | Apertura confinada, descriptor y prueba coordinada de carrera; sin adelantar E-PG-09 de efectos |
| PG1-R01 Memoria/mapas | URI o fuente clonada por nodo/arista | Tablas compactas y medición de asignaciones/bytes por fuente/arista, no objetivo universal de cero copias |
| PG1-R02 Caché obsoleta | Edición de firma da menos errores que análisis frío | Claves completas e invalidación comprobada; descartar caché ante divergencia |
| PG1-R03 Perfil global de ejecución | Booleano de biblioteca inglesa se imprime español en ambos motores | Perfil del sitio de operación y caso cruzado específico VM/AOT |
| PG1-R04 Artefacto supera presupuesto | Crecimiento con parser/tabla/ayuda, margen iOS escaso | Medir temprano y separar dependencias de host; no rebajar presupuesto vigente |
| PG1-R05 Evidencia incompleta | Caso multiarchivo no enviado al sujeto; capacidad ausente marcada cumple | Negativos de ejecutor/capacidad y matriz de vínculos; ningún verde por ausencia de ejecución |

No se reduce probabilidad o impacto por haber escrito estas mitigaciones: el cierre requiere su
evidencia. La discrepancia documental de PG-0 quedó sincronizada con su registro de cierre por
instrucción de la persona; los riesgos técnicos de PG-1 requieren la evidencia de sus puntos dueños.

## 9. Dependencias de la persona

| Momento | Dependencia | Efecto |
|---|---|---|
| PG-1.01 | Solicitud explícita de implementación y confirmación para sincronizar PG-0, 2026-10-23 | Autoriza solamente `.01`; no completa la revisión integral del plan ni autoriza `.02` en adelante |
| Antes de PG-1.06 o puntos posteriores | Autorización explícita de la persona en mensaje nuevo y revisión del plan | No iniciar los puntos restantes por inferencia de esta iteración |
| Revisión normativa | Revisión independiente real de contratos nuevos y autorización del reanclaje concreto de existentes | Nunca atribuir revisor ni refrescar todos los anclajes para silenciar cambios |
| Si aparece conflicto | Colisión demostrada entre preservar archivo suelto y sintaxis/visibilidad nueva | Detener trabajo dependiente y presentar fuentes/casos; continuar solo trabajo independiente autorizado |
| Antes de campaña final | Identificar máquina de referencia y accesos locales necesarios para ejecutar procesos/medir artefactos | No exigir privilegios ni dispositivos físicos para tests unitarios |
| Ante métrica fallida | Revisar evidencia y decidir corrección o cambio explícito de criterio/alcance | No declarar cierre ni diferimiento por iniciativa del agente |
| Al cerrar | Aceptar pendientes/diferimientos que correspondan; publicación de rama según reglas y parada | Ninguna autorización implícita para PG-2/3/6A/PG-A |

No hacen falta cuentas, credenciales, servicios públicos, participantes humanos ni dispositivos
físicos para los experimentos de PG-1. Las comprobaciones de artefactos requieren toolchains/SDK
de destino, no el teléfono. Si el entorno restringe un comando, se concreta la necesidad con la
acción preparada y se sigue el mecanismo de aprobación disponible.

## 10. Orden de ejecución y puntos de control

| Paso | Tareas y dependencia | Evidencia para continuar |
|---|---|---|
| 0 Autorización acotada | Los mensajes del 2026-10-23 cubren PG-1.01 a PG-1.05; PG-0 quedó sincronizada; C01/C02 de la fase completa siguen pendientes | Implementar solamente `.01`–`.05`; revisar el plan y recibir nueva autorización antes de `.06` |
| 1 Contratos y casos | `.01`–`.11` tareas `.01`/`.02`, contrato CLI `.12.01`/`.02`, protocolo `.13.01`/`.02` | Revisión de sintaxis/perfiles/procedencia/lock y fronteras; ningún esperado previo cambiado |
| 2 Soporte de conformidad y capas | Tests de schema/códec/negativos antes de implementarlos; README/matriz del crate nuevo antes de sus fuentes | Formato y referencias válidas, ejecutor capaz de rechazar un proyecto incorrecto, capas sin ciclos |
| 3 Identidad y Unicode | `.01`, `.10`; consumidores mínimos de `.11` | Ubicación exacta y negociación probadas, archivo suelto y puente sin regresión |
| 4 Proyecto local | `.02`, `.05`, `.06`, `.09`, con pruebas antes de cada implementación | Snapshot confinado y hasheado; lock determinista, offline y sin scripts |
| 5 Resolución semántica | `.03`, `.04`, `.07`, `.08` | Grafo/ciclos/visibilidad/perfiles/diagnósticos correctos; RI común verificada |
| 6 Integración | `.12` y `.11` integral, ayuda/datos de proyección y documentación de todos los puntos | CLI y binario reales; fuente y formato lógico correctos; sujetos activos sin regresiones |
| 7 Campaña | `.13`, tamaños y controles vigentes | Crudos válidos, resumen recalculado y resultado aunque sea desfavorable |
| 8 Cierre | C03–C13; completar resúmenes por tarea y del plan general | Puertas verdes, decisiones pendientes resueltas, commit/push ordinario comprobado y parada |

Los pasos son puntos de control internos de una fase, no fases nuevas. La autorización recibida cubre
solo PG-1.01 y permite completar ese punto sin dar por satisfechas C01/C02 de la fase completa. Se
detiene al terminar la iteración; los demás puntos requieren autorización propia (`PHASE-STOP`).

### 10.1 Verificaciones ejecutables al implementar

Usar los comandos de README vigentes; registrar directorio, revisión y resultado. Desde cada
miembro Rust afectado (`pseudolearn_spec`, `pseudolearn_engine`, `pseudolearn_cli`):
`cargo xtask verify`. No hay workspace Cargo raíz. Los tests dirigidos durante desarrollo acotan
retroalimentación; al cierre se ejecutan puertas completas, sin repetirlas si no cambió su entrada.

Desde `packages/pseudolearn_spec`:

- `cargo run --locked -p see_cli --bin see -- validate`
- `cargo run --locked -p see_cli --bin see -- lock --check`
- `cargo run --locked -p see_cli --bin see -- export --check`
- `cargo run --locked -p see_cli --bin see -- conform --subject engine`
- `cargo run --locked -p see_cli --bin see -- conform --subject aot`
- `cargo run --locked -p see_cli --bin see -- conform --subject service`
- `cargo run --locked -p see_cli --bin see -- conform --subject cli`
- `cargo run --locked -p see_cli --bin see -- conform --subject app`

Ejecutar también propiedades con `--operation properties` para cada sujeto activo que las anuncie;
registrar capacidades ausentes como tales. El reanclaje usa solo IDs revisados/autorizados con
`lock --refresh ID,ID`; después `lock --check`, nunca regeneración indiscriminada.
La validación de contratos nuevos requiere revisión independiente; un borrador no revisado no
permite afirmar que `validate` esté verde.

Desde `packages/pseudolearn_engine`, `bash tool/wasm.sh test` para la frontera real afectada;
medición AOT `cargo run --release -p pseudolearn_bench_worker -- paired <directorio-nuevo>`
con el protocolo de su README. Desde app: `bash tool/bridge.sh check` antes de compilar,
`bash tool/test_bridge.sh`, biblioteca release actualizada, `flutter test`,
`flutter analyze --fatal-infos --fatal-warnings`, `dart run tool/check_limits.dart`,
`dart run tool/check_content.dart` y `dart run tool/check_design_system.dart`;
las pruebas de arquitectura están incluidas en la suite. En `native/`: rustfmt, Clippy, tests,
cargo-deny y `rust-checks all` con los comandos exactos de su README.

Si cambian generación o configuración del puente, ejecutar también
`bash tool/bridge.sh clean-checkout`: el script actual usa un clon temporal compartido y aplica
los cambios locales, sin crear una rama de trabajo adicional. Sus dependencias de generación
deben estar preparadas. No se despachan Actions ni publicaciones externas como parte de los tests locales.

## 11. Resumen de ejecución

### 11.1 Registro por tarea

Las tareas `.nn.mm` de §4 se registran con evidencia al ejecutarse. PG-1.01 se completó en la iteración
anterior; las iteraciones del 2026-10-23 posteriores completan PG-1.02, PG-1.03, PG-1.04 y PG-1.05;
las restantes no se consideran iniciadas. Se usan exclusivamente los estados del
plan general: Cumplido, No cumplido, Diferido, No aplica y Retirado.

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-1.01.01 | Cumplido | `LANG.SOURCE.POSITION`, `IR.SOURCE-MAP` y `API.WIRE-FORMAT` especifican identidad, coordenadas, procedencia y compatibilidad | Versiones conservadas en `1.0.0`; lock reanclado para las tres identidades autorizadas |
| PG-1.01.02 | Cumplido | Casos de identidad, revisión, límites UTF-8/UTF-16, BOM, CRLF, texto vacío, Unicode suplementario y fallo AOT | Casos agregados al corpus existente sin cambiar versiones ni esperados previos |
| PG-1.01.03 | Cumplido | Tests espejo de tabla y conversión de coordenadas, spans, API, códec de eventos y fallos negativos | Cubre fuente ausente, rango inválido, revisión cruzada, versión desconocida y registro truncado |
| PG-1.01.04 | Cumplido | Identidad propagada por source, sintaxis, lowering, RI, bytecode, diagnósticos, AOT, API, vistas, eventos y puente nativo | Formato standalone preservado; eventos con identidad usan PLEV2 |
| PG-1.01.05 | Cumplido | README de source, IR, bytecode, diagnostics, VM, AOT runtime, codegen, API, service y puente nativo actualizados | Incluye compatibilidad, límites y decisiones de representación |
| PG-1.01.06 | Cumplido | Roundtrip JSON/binario/RI, procedencia de fallos y eventos, tests Wasm y nativos; `IrSpan` medido en 20 bytes frente a 16 | Wasm: cuatro pruebas Chrome; app nativa y verificadores de paquetes en verde |
| PG-1.02.01 | Cumplido | `LANG.MODULE.MODEL` R1–R3 | Identidad nueva en estable 1.0.0 con `revisado_por` vacío: pendiente de revisión independiente |
| PG-1.02.02 | Cumplido | 14 casos del contrato: tres módulos y biblioteca, workspace vacío, biblioteca sola, entrada ausente/duplicada/inexistente, raíces ambiguas y fuera de raíz, dependencia inexistente, archivo suelto | Esperados derivados de las reglas |
| PG-1.02.03 | Cumplido | 16 tests de `pseudolearn_project` con fuentes en memoria, incluidos rechazos sin disco | Entradas mal formadas son fallo de uso, no error de proyecto |
| PG-1.02.04 | Cumplido | Crate `pseudolearn_project` y operaciones `analyze_project`/`execute_project` | Sin concatenar textos; HIR y RI únicos |
| PG-1.02.05 | Cumplido | README del crate escrito antes del código; matriz y README de engine, syntax, semantic, lowering y API; dependencias Cargo | Sin dependencias externas nuevas |
| PG-1.02.06 | Cumplido | Casos del contrato con proyecto mínimo, biblioteca sin entrada y errores de aplicación; `rust-checks all` y Clippy del workspace | CLI no integrada (`.12`) |
| PG-1.03.01 | Cumplido | `LANG.MODULE.IMPORT` R1–R5 | Alias de módulo solo para subprogramas; clases por símbolo |
| PG-1.03.02 | Cumplido | 19 casos del contrato (ausente, privado, alias, colisión, reexport encadenado, ambiguo y repetido, homónimos, sin efectos, sin comodines) | Esperados derivados de las reglas |
| PG-1.03.03 | Cumplido | 11 tests semánticos de identidad tras alias, tablas y diagnósticos; 7 tests de API | Rechazo de RI con referencia no resuelta cubierto por el verificador de RI existente |
| PG-1.03.04 | Cumplido | Vocabulario, gramática y diagnósticos generados; resolución en semantic; fichas de ayuda es/en | Sin vistas de PG-A |
| PG-1.03.05 | Cumplido | README de semantic y lowering: dueño de símbolos, orden de registro, identidad compartida de clases importadas | Ciclos entre módulos terminan sin colgarse; su rechazo es `PG-1.04` |
| PG-1.03.06 | Cumplido con salvedad | Conformidad del motor: todos los casos nuevos cumplen; sin ejecución al importar | Conformidad `app` y pruebas Wasm no ejecutadas; el sujeto `aot` figura pendiente hasta `PG-1.12` |
| PG-1.04.01 | Cumplido | `LANG.MODULE.IMPORT` R6, `LANG.MODULE.MODEL` R4 y `chain` en `API.PROJECT` R1 | Aristas por `Importar`/`Exportar` hacia el módulo nombrado aunque falte el símbolo; cadena más corta con desempate por menor secuencia |
| PG-1.04.02 | Cumplido | 11 casos de importación (C20–C30) y 5 de paquetes (C15–C19) | Esperados derivados de la regla; cadena de 12 módulos |
| PG-1.04.03 | Cumplido | Oráculo de fuerza bruta sobre todos los grafos de hasta 4 vértices, 200 semillas con permutación, cadenas de 10 000, 7 pruebas de paquetes, 5 de módulos, 8 semánticas, 2 de API | El exhaustivo de 4 vértices tarda unos 3 s |
| PG-1.04.04 | Cumplido | `dependency_graph`, `package_cycles`, `module_cycles` en project; `module_cycles` en semantic; `importCycle`; tramos relacionados con su propia fuente | Con ciclo no hay HIR ni análisis de cuerpos |
| PG-1.04.05 | Cumplido | README de project, semantic y API | Coste, orden de recorrido y propiedad de aristas; sin SCC como excepción |
| PG-1.04.06 | Cumplido | Rechazo antes de compilar probado; estrés de un millón de vértices con `--ignored` en release (0,25 s) | Suite corta con cadenas de 10 000 |
| PG-1.05.01 | Cumplido | `API.PROJECT.MANIFEST` R1–R5 | Contrato nuevo en estable 1.0.0 con `revisado_por` vacío; sin edición ni idioma de interfaz |
| PG-1.05.02 | Cumplido | 22 casos (C1–C22) | Esperados derivados de la regla |
| PG-1.05.03 | Cumplido | 17 pruebas de resolución con posición exacta, 6 de autoridad (propiedad sembrada de no amplificación), 4 de varios manifiestos | Presupuesto probado debajo, en y sobre el límite |
| PG-1.05.04 | Cumplido | Analizador del subconjunto TOML, esquema, autoridad, `resolve_manifest`, `manifests` y `grants` en proyecto | Solo límites; permisos como vocabulario cerrado vacío |
| PG-1.05.05 | Cumplido | README de project, API y CLI | Parser propio frente a `toml` y JSON; precedencia y valores heredados |
| PG-1.05.06 | Cumplido | 8 pruebas de API: contenido tipo script rechazado como campo desconocido, límites no concedidos no se aplican, idioma de interfaz sin efecto | Presupuesto de bytes del transporte es un valor candidato |

### 11.2 Cierre común de PG-1

- [ ] `PG-1.C01` Autorización de implementación en mensaje nuevo y dependencia confirmada.
- [ ] `PG-1.C02` Plan detallado revisado por la persona antes de especificación/código.
- [ ] `PG-1.C03` SPEC-FIRST y congelamiento respetados; esperados independientes.
- [ ] `PG-1.C04` Reglas cubiertas y vínculos como datos, con evidencia por sujeto.
- [ ] `PG-1.C05` Feliz/infeliz/límites, tests espejo y negativos de verificadores.
- [ ] `PG-1.C06` Capas/imports declarados y SIZE-* vigentes en verde.
- [ ] `PG-1.C07` Inglés en código, español en documentos, sin comentarios/TODO/pánicos/unsafe propio nuevo.
- [ ] `PG-1.C08` README/reglas actualizados y autosuficientes, sin citar docs transitorios.
- [ ] `PG-1.C09` Fichas es/en y datos de proyección de formas nuevas; sin anunciar vistas aún pendientes.
- [ ] `PG-1.C10` Riesgos revisados y E-PG-01/02 de proyecto con procedencia o diferimiento explícito.
- [ ] `PG-1.C11` Tests/verificadores de todos los miembros afectados en verde.
- [ ] `PG-1.C12` Commit con skill `commit-message`, sin atribución de IA, y push ordinario comprobado a rama única.
- [ ] `PG-1.C13` Resumen por tarea/punto y plan general actualizados; informe y parada.

Revisión Git de cierre: sin cierre de fase, commit ni push. Verificadores ejecutados para este punto:
`cargo xtask verify` del motor (tests y `rust-checks` en verde; `cargo deny check` pasó al repetirlo
con acceso a su caché de avisos), `rust-checks toolchain`, tests del puente nativo, `cargo fmt --check`,
`rust-checks all` e `isolation` de la app, cuatro pruebas Chrome Wasm, `see validate`, `lock --check`,
`export --check`, propiedades del motor y conformidad estructural de los tres contratos. `git diff
--check` sin errores. Pendientes justificados: PG-1.02–.13, revisión integral del plan y cierre común
C01–C13; requieren autorización nueva. PG-1.01.01–.06 cumplidos; no se cierra PG-1.

Revisión Git de la iteración PG-1.02/PG-1.03: sin cierre de fase, commit ni push. Verificadores
ejecutados: Clippy estricto y `cargo test` del workspace del motor, `cargo fmt --check`, `rust-checks all`
y `toolchain`, `cargo deny check`; en `apps/pseudolearn_cli`, Clippy, tests y `rust-checks all`;
`cargo check` del puente nativo; `see lock --check`, `export --check` y `validate` (solo
`SEE-STATE`: las tres identidades nuevas necesitan revisión independiente); conformidad `engine`
(1618 observaciones, todos los casos nuevos cumplen), `service`, `cli` y `aot` (1233 observaciones) sin divergencias. Hallazgos ajenos a esta iteración, corregidos por instrucción de la persona: `API.VERSIONING` C3 omitía
las capacidades `source_identity` y `event_binary` (texto de R2 y esperado actualizados) y `API.WIRE-FORMAT`
C4 suponía identificadores de recurso de una sesión nueva (esperado independiente de la numeración);
`engine` queda en 1618 observaciones sin divergencias. `pseudolearn_cli` no compilaba desde PG-1.01 por
el campo `source`, corregido aquí. No ejecutados:
conformidad `app`, pruebas Wasm en Chrome y medición de tamaños. Para obtener evidencia se usó un
marcador transitorio de revisor, revertido tras cada ejecución; ninguna revisión fue atribuida.
Pendientes justificados: PG-1.04–.13, revisión integral del plan, cierre común C01–C13 y la revisión
independiente de `LANG.MODULE.MODEL`, `LANG.MODULE.IMPORT` y `API.PROJECT`.

Revisión Git de la iteración PG-1.04/PG-1.05: sin cierre de fase, commit ni push. Verificadores ejecutados en
`packages/pseudolearn_engine`: `cargo xtask verify` en verde (formato, Clippy estricto, tests, `rust-checks`,
toolchain y `cargo deny`) y el estrés de un millón de vértices; en `apps/pseudolearn_cli`, Clippy y tests;
en `packages/pseudolearn_spec`, `validate`, `lock --check` y `export --check`, y conformidad `engine` (1656
observaciones, 0 divergencias, 38 casos nuevos). Reanclados con `lock --refresh` solo `API.PROJECT`,
`LANG.MODULE.MODEL`, `LANG.MODULE.IMPORT`, `DIAG.CATALOG` e `IR.INSTRUCTIONS`; el contrato nuevo se registró con
`lock`. Se usó un marcador transitorio de revisor, revertido tras cada ejecución; ninguna revisión fue atribuida.
Se añadió `resolve_manifest` a la lista de operaciones de `schemas/see-1.schema.json`. No ejecutados: pruebas Wasm,
puente nativo y app. Pendientes justificados: PG-1.06–.13, cierre común C01–C13 y la revisión independiente de
`LANG.MODULE.MODEL`, `LANG.MODULE.IMPORT`, `API.PROJECT` y `API.PROJECT.MANIFEST`.

Al cerrar se consignarán comandos/resultados, hashes de campañas y artefactos, pendientes aprobados,
decisiones de la persona y revisión remota de la rama. La fase siguiente requiere autorización nueva.
