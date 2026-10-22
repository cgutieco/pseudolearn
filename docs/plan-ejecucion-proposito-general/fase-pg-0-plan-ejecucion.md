# Fase PG-0 · Decisiones y línea base — plan de ejecución

## 0. Metadatos

Fase: PG-0. Fecha: 2026-10-22. Revisión inicial: `cf2825f6afd10e9b8fe9c27ff9e3daa933198ea9`.
Rama: `feature/agregar-ruta-de-especificacion`. Árbol inicial limpio, comprobado con `git status --short`.
Autorización y revisión C02: mensaje de la persona «Implementa en una sola iteración este plan», recibido el 2026-10-22.
Estado: ejecución de PG-0 en curso; C01 y C02 satisfechos. Este documento no certifica campañas no ejecutadas ni autoriza fases posteriores.

## 1. Punto de partida

SEE crea contratos con `borrador` y `0.1.0` en `crates/see_cli/src/templates.rs`.
Su validador permite promociones y avances de estado durante el congelamiento en
`crates/see_validation/src/lifecycle.rs`. Ambos pertenecen a `packages/pseudolearn_spec`.
El manifiesto `specifications/features/language-2026.yaml` declara `estado_agregado: experimental`.
`LANG.EDITION.MODEL`, `PERF.PROTOCOL`, `PERF.AOT.LEVEL` y `PERF.ARTIFACT.SIZE` declaran estable 1.0.0.
La evidencia histórica no certifica esta revisión. Host capturado antes de las campañas: macOS 27.0.1,
arm64, Mac mini M2 (Mac14,3), 8 núcleos y 16 GB. Toolchains observadas: Rust/Cargo 1.99.0,
Node 22.23.3 y pnpm 12.8.1; Deno no está instalado. La lectura de Flutter no pudo completar porque
el SDK intentó escribir en su caché fuera del espacio permitido. La campaña de app queda sin ejecutar.

## 2. Lectura realizada

Se consultaron AGENTS.md, README raíz, hoja de ruta y plan general; README y reglas de spec;
README operativos de CLI, benchmarks, trabajador de medición, engine y app; contratos de edición,
ciclo de vida y rendimiento; creación y validación de ciclo de vida de SEE. No se modificaron engine,
benchmarks, CLI de producto ni app. Los miembros Rust de SEE se leyeron antes de editarlos.

## 3. Decisiones de diseño

Estas elecciones proceden de las respuestas de la persona durante la preparación del plan.

| Decisión | Opciones consideradas | Criterio y elección | Reversión |
|---|---|---|---|
| Edición | Nueva edición optativa; conservar 2026 | Conservar 2026; admitir cambios necesarios antes de publicar, documentando impacto y preservando la esencia | Autorización de la persona |
| Contratos nuevos | Borrador; experimental; estable | Estable 1.0.0, sin cambio; misma identidad y versión para correcciones oficiales | Reapertura explícita |
| Existentes | Normalizar; auditar | Auditar; no promover ni corregir CF-12 automáticamente | Autorización específica tras informe |
| Congelamiento | Excepciones; estricto | Eliminar avances automáticos; conservar revisión independiente, casos y evidencia | Reapertura explícita |
| Licencia | Resolver ahora; diferir | Derechos reservados; diferir PG-0.05 a PG-7.07, antes del cierre final o publicación | Elección expresa de licencia |
| D-xx y TS-3 | Aportar origen; reconstruir | Propuestas nuevas con origen histórico no verificado | Fuente verificable posterior |
| Evidencia física/humana | Obligatoria; complementaria | Opcional, sin bloquear cierres; ausencia explícita y sin atribuir eficacia pedagógica | Nuevo encargo explícito |
| SEE en PG-0 | Solo documentación; excepción | Adaptación acotada de SEE, contratos de proceso, tests y README | Conflicto o ampliación requiere consulta |

No se inventan revisores. Los requisitos de estabilidad siguen vigentes. Un contrato estable puede tener
implementación incumplida: el estado no sustituye la conformidad. No se cambia semántica del lenguaje en PG-0.
Los documentos de docs/ pueden enlazarse entre sí; ningún archivo externo dependerá de ellos.

## 4. Desglose por punto

### PG-0.01 · CF-19 y herramientas SEE

- [x] `PG-0.01.01` Especificación: Formalizar creación estable 1.0.0, ausencia de cambio y congelamiento estricto en contratos de proceso existentes.
- [x] `PG-0.01.02` Casos: Derivar creación válida, estados/versiones iniciales inválidos, transiciones prohibidas y reanclaje oficial.
- [x] `PG-0.01.03` Tests: Añadir cobertura espejo de creación y validación, incluidos revisión ausente, identidades terminales y límites.
- [x] `PG-0.01.04` Código: Adaptar creación y validación en sus capas actuales; no importar sujetos ni modificar el motor.
- [x] `PG-0.01.05` Documentación: Actualizar README de spec y crates afectados, sin referencias a docs/.
- [ ] `PG-0.01.06` Verificación: Ejecutar tests dirigidos, validate, lock --check, export --check y cargo xtask verify; conservar salidas y hashes.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.02 · Tratamiento de conflictos

- [x] `PG-0.02.01` Registro: Completar matriz CF-01–CF-18 con fuente, decisión, estado, responsable, fase y evidencia.
- [x] `PG-0.02.02` Documentación: Actualizar hoja de ruta y plan general según las decisiones de esta conversación; conservar el rastro de opciones.
- [x] `PG-0.02.03` Verificación: Comprobar que cada conflicto tiene tratamiento y que CF-20 sigue reservado a PG-6A.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.03 · Agregación CF-12

- [x] `PG-0.03.01` Auditoría: Leer consumidor y validación de estado_agregado, contrastar manifiesto y estados individuales.
- [x] `PG-0.03.02` Informe: Clasificar discrepancia y proponer tratamiento sin cambiar estados; cualquier corrección requiere autorización concreta.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.04 · Procedencia

- [x] `PG-0.04.01` Registro: Inventariar D-01/03/04/08/12/14/15/16/19 y TS-3 como procedencia NV.
- [x] `PG-0.04.02` Propuestas: Reconstruir solo decisiones necesarias con opciones y justificación; no atribuir aprobación histórica.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.05 · Licencia

- [x] `PG-0.05.01` Registro: Registrar diferimiento autorizado a PG-7.07 y conservación de derechos reservados.
- [x] `PG-0.05.02` Puerta: Actualizar cierre de PG-7 para exigir elección y comprobación antes del cierre final o publicación.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.06 · Edición 2026

- [x] `PG-0.06.01` Documentación: Revisar ADR-05, CF-03, PG-0.06 y referencias a edición GP: desarrollo oficial en 2026 sin publicación nueva.
- [x] `PG-0.06.02` Verificación: Buscar contradicciones en documentos transitorios; trasladar política autosuficiente a README dueño sin alterar semántica en PG-0.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.07 · Conformidad actual

- [ ] `PG-0.07.01` Preparación: Capturar fuentes, corpus, configuración, plataforma y toolchains antes del build; generar exportación y compilar adaptadores actuales.
- [ ] `PG-0.07.02` Campaña: Desde spec ejecutar conform --subject para engine, aot, service, cli y app, con casos y propiedades según operaciones admitidas.
- [ ] `PG-0.07.03` Informe: Conservar salida, código de retorno, binarios y hashes; producir matrices de reglas y separar incumple, pendiente, exento y no aplicable.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.08 · Rendimiento

- [ ] `PG-0.08.01` Preparación: Identificar CPU, RAM, SO, energía, toolchain, semilla y hashes; preparar artefactos release y controles equivalentes.
- [ ] `PG-0.08.02` Medición: Ejecutar paired del trabajador existente en directorio nuevo; verificar diez procesos y treinta iteraciones, salida y terminación por carga.
- [ ] `PG-0.08.03` Artefactos: Construir e inspeccionar biblioteca ios-arm64 depurada y Wasm optimizado con Brotli quality 11/lgwin 22; no requiere teléfono.
- [ ] `PG-0.08.04` Informe: Verificar todos los presupuestos vigentes y resumen recalculable; conservar crudos y resultados desfavorables sin reinterpretar históricos.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.09 · Discrepancias

- [x] `PG-0.09.01` Clasificación: Por hallazgo registrar contrato aplicable, dato observado, categoría, impacto, propietario y evidencia.
- [x] `PG-0.09.02` Control: No alterar esperados ni umbrales para obtener verde; incumplimiento obligatorio mantiene fase abierta y reparación del motor exige ampliación expresa.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.10 · Capacidades y oráculos

- [x] `PG-0.10.01` Catálogo: Proponer consola, aleatoriedad, archivos, red y tiempo como clases candidatas, con autoridad, límites y reproducción; no implementarlas.
- [x] `PG-0.10.02` Oráculos: Derivar esperados del corpus y controles independientes; VM/AOT compartidos aportan integración, no independencia; no reinstalar reference.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.11 · Recursos experimentales

- [x] `PG-0.11.01` Matriz: Para E-PG-01–12 registrar control, fase, carga, semilla, plataforma, procedencia, criterio y disponibilidad.
- [x] `PG-0.11.02` Obligatoriedad: Mantener pruebas automatizadas y mediciones sin dispositivos como obligatorias; marcar físicos y pilotos humanos complementarios, sin fabricar evidencia.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.12 · Trazabilidad

- [x] `PG-0.12.01` Matriz: Completar punto base → R-xx → C-xx → fase → paquete y recorrido inverso, justificando relaciones no aplicables.
- [ ] `PG-0.12.02` Dependencias: Recalcular camino crítico sobre el DAG y sus estimaciones, declarar empates e incertidumbre; no autorizar paralelismo ni fases siguientes.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

## 4.1 Tratamiento de conflictos CF-01–CF-20

La fuente y descripción originales permanecen en la matriz de conflictos de la hoja de ruta, §11.
Esta tabla fija su tratamiento para PG-0, el estado de la decisión, su dueño y el punto de seguimiento.

| ID | Tratamiento concreto | Estado | Dueño / fase | Evidencia o condición |
|---|---|---|---|---|
| CF-01 | Solo capacidades con entrada/salida grabable; efectos que no puedan reproducirse quedan fuera | Resuelto conceptualmente; contrato pendiente | SEE/engine, PG-3/5 | ADR-02/03 y RT.HOST.INTERFACE existente; formalizar antes del motor |
| CF-02 | Aplicar congelamiento literal; crear contratos solo bajo regla inicial aprobada, sin transiciones automáticas | Resuelto | SEE, PG-0 | SEE.LIFECYCLE y SEE.VERSIONING; pruebas de lifecycle |
| CF-03 | Mantener 2026 como edición única; cambios prepublicación pueden ser incompatibles si se documenta impacto y se preserva su esencia | Resuelto | SEE/engine, PG-0/1 | ADR-05 y C-03 actualizados; contratos de cada cambio siguen SPEC-FIRST |
| CF-04 | D-xx/TS-3 sin fuente verificable son propuestas reconstruidas, nunca aprobación histórica | Resuelto como método | Hoja de ruta, PG-0 | Inventario de procedencia en §4.2 |
| CF-05 | Calificar contratos actuales, separar deuda de requisitos retirados/exentos; no reinstalar reference | Pendiente, parcialmente observado | SEE/engine, PG-0 | Campañas de cuatro sujetos archivadas; hay bindings `cumple` sin casos en engine, AOT y service; app no inició |
| CF-06 | Medir PERF.AOT.LEVEL y PERF.ARTIFACT.SIZE con hashes/plataforma actuales; no elegir entre afirmaciones históricas | Pendiente, parcialmente medido | Benchmarks/engine, PG-0 | Wasm pasa tamaño; paired falló al capturar procedencia y iOS no se construyó |
| CF-07 | Frontera de commit lógico explícita; un fallo externo puede dejar resultado incierto, no se promete rollback remoto | Resuelto conceptualmente | SEE/engine, PG-3/5 | ADR-02 y casos antes de contrato HTTP |
| CF-08 | Extensión de VS Code forma parte de ENT-1; su miembro y cadena se concretan en PG-6A | Diferido | Responsable de distribución, PG-6A | Camino de extensión y herramienta declarados antes de crear miembro |
| CF-09 | Documentos del repositorio en español; textos de canal/IDE pueden localizarse fuera de la documentación de arquitectura | Resuelto como principio; detalle pendiente | Extensión, PG-6A/7 | Definir miembro/canales y auditar licencia antes de distribuir |
| CF-10 | App mantiene archivo único y no ofrece rebobinado; el cliente de extensión puede consultar seek si su capacidad lo admite | Resuelto conceptualmente | App/extensión, PG-A/B/6B | ADR-12 y límite operativo del README de app |
| CF-11 | Garantía de fallos cubre errores controlados dentro de límites; caída del proceso/host se informa como terminación, no como Result fingido | Pendiente | API/engine, PG-3/5 | Delimitar frontera y casos antes de ampliar efectos/FFI |
| CF-12 | No modificar estado agregado. El manifiesto y su criterio conservan experimental aunque el comando muestre estable | Clasificado; corrección pendiente de autorización | SEE, PG-0 | `see feature language-2026` devuelve JSON con `"state": "estable"`; `language-2026.yaml` declara `estado_agregado: experimental` |
| CF-13 | No inferir compatibilidad de toda una familia de IDE; fijar producto y build reales durante el spike | Diferido | Extensión, PG-6A | Matriz de producto/build en la fase propietaria |
| CF-14 | Ensayos físicos son complementarios; registrar ausencia, sin afirmar cobertura telefónica | Diferido con autorización | Extensión, PG-6B | Persona indica que hardware no es requisito de cierre; E-PG-08 físico no evaluado |
| CF-15 | Código/herramientas en inglés; programas y ejemplos siguen el perfil de idioma del lenguaje | Resuelto como interpretación | Dueños de código/corpus, PG-1/7 | Regla LANG-EN-CODE aplicada por ámbito; no cambiar AGENTS.md |
| CF-16 | App sigue siendo herramienta didáctica de un archivo; proyecciones nuevas no la convierten en IDE de proyectos | Resuelto conceptualmente | App, PG-A/B | ADR-12; cada construcción futura requiere modelo/proyección |
| CF-17 | Ayuda como catálogo de datos común resuelto por árbol/rol; sin parser ni texto normativo duplicado en cliente | Resuelto conceptualmente | SEE/service/app, PG-H | ADR-13 y requisito R-20; cobertura aún pendiente |
| CF-18 | Cada emisor declara equivalencia validada o indisponibilidad; no presenta salida parcial como equivalente | Resuelto conceptualmente | App, PG-A/B/7 | Contrato y matriz por emisor en fases propietarias |
| CF-19 | Contratos nuevos estables 1.0.0, sin `cambio` ni `reviewed_by` inventado; revisión independiente real obligatoria | Resuelto | SEE, PG-0 | Cambio SEE.LIFECYCLE/GENERATION/VERSIONING; tests y conformance.yaml |
| CF-20 | No ampliar aún AGENTS.md; elegir ruta/cadena del nuevo miembro antes de implementarlo | Diferido | Persona, PG-6A | Decisión requerida al iniciar PG-6A |

## 4.2 Procedencia de D-xx y TS-3

La hoja base y `docs/pendientes-rezagados.md` nombran estas decisiones sin fuente normativa ni aprobación
histórica recuperable (H-16/CF-04). Los tratamientos siguientes son propuestas reconstruidas; los IDs de
origen no se presentan como decisiones aprobadas.

| Referencia | Procedencia histórica | Propuesta reconstruida / destino | Dueño y condición |
|---|---|---|---|
| D-01 · registro | NV; aparece ligado a distribución de paquetes | Registro público futuro FUT-11; no es requisito de ENT-1 ni del lock local | Producto de paquetes; fuera del alcance inicial |
| D-01 · licencia | NV; la misma clave aparece asociada a F9 | Elección y auditoría diferidas con autorización a PG-7.07; derechos reservados mientras tanto | Persona y distribución; antes de cierre final/publicación |
| D-03 · archivos, texto y matemática | NV; no existe vínculo verificable con una regla vigente | Archivos/texto/bytes se proponen para PG-3/5; matemática vigente conserva su contrato; ampliación adicional FUT-14 | SEE/library/host; contrato por operación antes de implementación |
| D-04 · registros | NV | Registros por valor con layout compartido y límite finito; E-PG-03 | SEE/ABI/runtime; PG-2 |
| D-08 · tree shaking | NV | FUT-04 excluido; no se añaden optimizaciones por esta referencia | IR/codegen; nueva autorización si cambia alcance |
| D-12 · ámbito de bloque | NV | Propuesta para PG-2; si rompe programas, registrar incompatibilidad de 2026 y migración asistida solo si hace falta | SEE/semantic/CLI; SPEC-FIRST |
| D-14 · alfabeto español | NV | Propuesta de alfabeto español estricto conservando NFC; comprobar homógrafos y documentar cambios incompatibles | SEE/source/lexicon; PG-1/2 |
| D-15 · Resultado | NV | Tipo de resultado con propagación explícita y rechazo del descarte silencioso | SEE/semantic/IR; PG-2/3 |
| D-16 · interfaces | NV | Interfaces nominales mínimas como restricciones, sin herencia múltiple de implementación | SEE/semantic/IR; PG-2 |
| D-19 · manifiesto | NV | Manifiesto declarativo, versionado y no ejecutable | SEE/CLI; PG-1 |
| TS-3 | No hay artefacto que confirme su contenido o aprobación | Se mantiene asociada provisionalmente al tema tree shaking solo como pista; FUT-04 excluido | No atribuir como decisión; reabrir únicamente con fuente verificable |

## 4.3 Capacidades candidatas y oráculos

El siguiente catálogo alimenta el diseño de PG-3; no introduce APIs ni concede acceso por sí mismo.

| Capacidad candidata | Autoridad y límite | Reproducción / resultado esperado |
|---|---|---|
| Consola | Host dueño de stdin/stdout/stderr y códigos; límites de bytes y solicitudes | Entradas/salidas ordenadas en cinta; misma semilla y cinta producen observables iguales |
| Aleatoriedad | Fuente provista por host con semilla explícita; no usar aleatoriedad ambiental oculta | Semilla y estado de generador ligados a configuración; replay usa la cinta o estado fijado |
| Archivos | Raíz/capacidad concedida externamente y operaciones por ruta; cuota y reglas de symlink | Registrar lecturas y commits; replay no toca disco y rechaza ruta fuera de permiso |
| Red | Adaptador nativo o Fetch con destinos concedidos, límites de cuerpo y timeout | Solicitud/respuesta grabada en prueba local; replay no emite red y rechaza divergencias |
| Tiempo | Host devuelve tiempo como dato; timer lógico avanza por eventos/agenda | Tiempo observado registrado; nunca programar puntos de observación por reloj físico |

El oráculo observable sale de regla/caso y propiedades, no de la salida del motor. Cálculos esperados se
derivan manualmente de la regla o de un calculador independiente; capturas requieren revisión humana.
VM y AOT comparten RI/runtime y son contraste de integración, no oráculos independientes. No se reinstala
`reference`. Para medidas, entradas/control, binarios y plataforma se conservan hashes y datos crudos.

## 4.4 Catálogo de experimentos E-PG-01–E-PG-12

Los protocolos y criterios numéricos completos son los de la hoja de ruta, §6.3. Este catálogo fija
control, dueño, recursos y disponibilidad para PG-0. Toda ejecución futura fija y registra su semilla,
hashes antes del build, plataforma, toolchain, muestras crudas y validador; los IDs son propuestas, no
contratos SEE. No se simulan participantes ni dispositivos.

| Experimento | Control / carga definida | Fase dueña | Recursos y disponibilidad |
|---|---|---|---|
| E-PG-01 | Perfiles de archivo frente a módulo/mezcla; 100 módulos, colisiones y pares canónicos | PG-1 | Sintético local; sin participante ni dispositivo; semilla y corpus versionados al ejecutar |
| E-PG-02 | Reanálisis frío frente a incremental; 10/100/1000 archivos y 10 000 líneas | PG-1/6A | Host identificado, 10 procesos × 30 muestras; sin participante |
| E-PG-03 | Combinaciones genéricas/registros frente a control no genérico de misma semántica | PG-2 | Build VM/AOT local, casos de límite y hash de inputs; sin participante |
| E-PG-04 | Clausuras/entornos/GC forzado frente a llamada directa | PG-2 | Requiere runtime y GC; carga sintética determinista; sin participante |
| E-PG-05 | Grabación frente a replay con adaptador que rechaza E/S; 1000 guiones y fallos en fronteras | PG-3 | Adaptadores locales controlados; sin Internet; semilla y cinta guardadas privadamente |
| E-PG-06 | VM frente a AOT bajo 10 000 agendas sembradas, cancelación, colas y GC forzado | PG-4 | Rust local, semilla y secuencias completas; sin dispositivo/participante |
| E-PG-07 | Adaptador nativo frente a navegador con servicio HTTPS local y respuestas preparadas | PG-5 | Chromium/WebKit/Firefox y host nativo disponibles según matrices futuras; sin servicio externo |
| E-PG-08 | VSIX web y ciclo editar/guardar/ejecutar/detener en Safari iPhone y Chrome Android | PG-6B | Teléfonos físicos no disponibles/requeridos en este cierre; ensayo queda no evaluado, no se extrapola |
| E-PG-09 | 1000 rutas hostiles, enlaces, redirects/DNS privado, paquetes y cintas manipulados | PG-5 | Fixtures locales hostiles; DNS/servidor de prueba controlados; sin Internet abierto |
| E-PG-10 | Errores/inmutabilidad frente a diseño actual, tareas bilingües contrabalanceadas | PG-2 | ≥12 principiantes, consentimiento y revisión; participantes no disponibles/requeridos en PG-0 |
| E-PG-11 | Ayuda por posición/API/LSP/app; roles ambiguos, Unicode, sombreado y edición obsoleta | PG-H | Corpus 2026 local y puente real; sin humanos ni dispositivos |
| E-PG-12 | Escenas de interfaz/tareas comparadas con oráculo manual y cinta, más tareas de comprensión | PG-A/B | Pruebas automatizables obligatorias; ≥12 principiantes complementarios, sin reclutar/simular en PG-0 |

E-PG-08 y los pilotos humanos E-PG-10/12 son complementarios por autorización expresa; su falta se
reporta como ausencia de evidencia. Pruebas automatizadas de geometría, accesibilidad, simulador y calidad
siguen obligatorias donde el plan propietario las requiere.

## 4.5 Trazabilidad y camino crítico

La hoja de ruta §12.1 conserva cada subpunto de `pendientes-rezagados.md`; se añade aquí el cruce con
capacidades C-xx y paquetes dueños. Para capacidades extendidas, el cierre corresponde a todas las fases
indicadas en §5 de la hoja de ruta. Los destinos FUT quedan excluidos y no se convierten en implementación.

| Punto base | R-xx / C-xx | Fase | Paquete/rol dueño |
|---|---|---|---|
| F4 edición | R-03/04, C-03 | PG-0/1 | spec, source, syntax, semantic, API, CLI |
| F4 módulos/visibilidad | R-01/02, C-01/02 | PG-1 | spec, semantic, API, CLI |
| F4 constantes/enumerados | R-05, C-04 | PG-2 | spec, syntax, semantic, lowering, runtime/codegen |
| F4 Opcional | R-05/08, C-04 | PG-2 | spec, semantic, ABI/runtime |
| F4 Resultado (D-15) | R-08, C-04/07 | PG-2/3 | spec, semantic, IR, VM/AOT |
| F4 registros (D-04) | R-05/12, C-04 | PG-2 | spec, ABI, runtime, lowering, codegen |
| F4 patrones/Segun | R-05/08, C-04 | PG-2 | spec, syntax, semantic, lowering |
| F4 interfaces (D-16) | R-05/19, C-05/15 | PG-2/A | spec, semantic, IR/codegen, app |
| F4 Unicode/NFC (D-14) | R-03/04/17, C-03/11 | PG-1/2/6A | spec, source, lexicon, syntax, service |
| F4 archivos/texto/matemática (D-03) | R-09/11/12, C-07/10 | PG-3/5 | spec, library, API, host CLI/web |
| F7 ámbitos (D-12) | R-04/06, C-03/05 | PG-2 | spec, semantic, service, CLI |
| F7 funciones/clausuras | R-06, C-05 | PG-2 | spec, semantic, ABI/runtime/VM/codegen |
| F7 genéricos | R-05, C-05 | PG-2 | spec, semantic, lowering/codegen |
| F7 colecciones | R-07/11, C-06/10 | PG-2/5 | spec, library/runtime, VM/AOT |
| F7 Para Cada | R-07, C-06 | PG-2 | spec, syntax, semantic, lowering |
| F7 retorno/limpieza | R-08/10, C-06/09 | PG-2/3/4 | spec, lowering, VM/AOT, host |
| F7 migración asistida | R-04/14/17, C-03/11 | PG-2/6A | spec, service, API, CLI |
| F8 manifiesto (D-19) | R-02/03, C-01/14 | PG-1 | spec, resolver, API/CLI |
| F8 workspace | R-01/02/14, C-01/11 | PG-1/6A | spec, semantic/service, CLI |
| F8 lock | R-02/13, C-01/14 | PG-1 | spec, resolver/CLI |
| F8 resolver/aliases | R-02, C-01/02 | PG-1 | spec, resolver/CLI |
| F8 tree shaking (D-08/TS-3) | R-12, FUT-04 | Excluido | IR/codegen/benchmarks solo con autorización futura |
| F8 registry (D-01) | R-02/13/18, FUT-11 | Excluido | Producto de paquetes/CLI/spec si se activa |
| F9 licencia (D-01) | R-15/18, C-14 | PG-0/7 | Persona, miembro de extensión y distribución |
| F9 gobernanza/RFC | R-18, FUT-12 | Excluido | Persona y futuros mantenedores |
| F9 guía de contribución | R-03/18, C-14 | PG-7/FUT-12 | Documentación de miembros/publicación |
| F10 concurrencia | R-10, C-09 | PG-4 | spec, IR, runtime, VM/AOT, API |
| F10 C FFI | R-13, FUT-08 | Excluido | ABI/host futuro con decisión de seguridad |
| F10 self-hosting | R-18, FUT-09 | Excluido | Futuro compilador/bootstrap |
| F10 JIT | R-12, FUT-01 | Excluido | codegen/runtime/benchmarks si se activa |
| F10 DSL semántico | R-18, FUT-10 | Excluido | spec/oráculos futuros |

El DAG vigente da como cadenas estructuralmente más largas PG-0 → PG-1 → (PG-2 o PG-3) → PG-4 →
PG-5 → (PG-6B o PG-B) → PG-7. Hay empate en cantidad de fases entre los brazos que terminan en PG-6B
y PG-B; PG-3 puede quedar en la rama larga porque PG-4 depende tanto de PG-2 como de PG-3. PG-H/PG-A
y PG-6A son ramas necesarias para sus consumidores, pero más cortas en número de nodos. No existe
estimación temporal numérica: S/M/L/XL mide tamaño relativo y no duración. Por tanto este es un camino
crítico estructural, no una predicción de calendario; mediciones de spikes y recursos pueden cambiarlo.
No autoriza trabajo paralelo ni inicio de fases posteriores.

## 4.6 Discrepancias y línea base disponible

| Hallazgo | Observación reproducible | Clasificación e impacto | Tratamiento |
|---|---|---|---|
| CF-12 agregado de 2026 | `see feature language-2026` emite JSON con `"state": "estable"`; `specifications/features/language-2026.yaml` declara `estado_agregado: experimental` y criterio experimental | Inconsistencia agregada; no se puede afirmar estabilidad de todo 2026 desde el manifiesto | Reportar; conservar estados y criterio hasta autorización explícita |
| Ancla local PERF | `cargo run --locked -p see_cli --bin see -- lock --check` y `lock --refresh SEE.GENERATION,SEE.LIFECYCLE,SEE.VERSIONING` fallan con `SEE-HASH: immutable version PERF.SUITE.CORE@1.0.0` | La caché ignorada de lock no coincide con la especificación PERF actual; bloquea la comprobación integral de anclas y el reanclaje SEE en esta ejecución | No se modificó, borró ni reescribió PERF ni su lock local; hace falta revisar ese ancla antes de regenerar el lock |
| Conformidad engine | Casos exit 1; 182 reglas `cumple`, 27 `sin evidencia`, 2 `no aplicable`; propiedades 30/30 cumplen. Logs y matrices en `packages/pseudolearn_spec/results/pg0-campaign-2026-10-22/` | Hay reglas estables ligadas a `cumple` sin casos; no es divergencia observada en la salida del motor | CF-05 pendiente; conservar la falta de evidencia y no relajar los bindings |
| Conformidad aot | Casos exit 1; 50 reglas `cumple`, 12 `sin evidencia`, 84 `no aplicable`, 2 `pendiente`; propiedades 13 cumplen y 3 quedan pendientes | Bindings estables `cumple` carecen de casos; propiedades no disponibles se separan como pendientes | CF-05 pendiente; mantener exenciones/deuda actuales y no corregir motor aquí |
| Conformidad service | Casos exit 1; 43 reglas `cumple`, 2 `sin evidencia`; propiedades 7/7 cumplen | Dos bindings `cumple` no tienen caso que los evidencie | CF-05 pendiente; requiere cobertura de corpus en su fase dueña |
| Conformidad cli | Casos 26/26 cumplen; propiedad 1/1 cumple; código de salida 0 | Línea base ejecutable para las operaciones declaradas del sujeto CLI | Evidencia local registrada; no certifica reglas fuera de las operaciones observadas |
| Conformidad app | Casos y propiedades no pudieron iniciar sesión; Flutter intentó escribir `engine.stamp` y `engine.realm` en su caché fuera del espacio de escritura y recibió `Operation not permitted`; matriz no producida | Fallo operativo del adaptador en este entorno, no un resultado de comportamiento de la app | CF-05 permanece pendiente; no elevar permisos ni declarar exención del producto |
| Paired `PERF.AOT.LEVEL` | `cargo run --release --locked -p pseudolearn_bench_worker -- paired …` terminó antes de las muestras: `sysctl … Operation not permitted`; código 1, log archivado | No hay resultado ni se alcanzó a capturar procedencia; no se afirma cumplimiento o incumplimiento del nivel AOT | CF-06 pendiente; no inyectar datos del host ni alterar umbrales |
| `PERF.ARTIFACT.SIZE` Wasm | `bash tool/wasm.sh build` reproducible; módulo procesado 2 391 389 B, Brotli Q11/lgwin22 530 080 B (517.66 KiB) de 614 400 B; hash y flujo comprimido archivados | `PERF.ARTIFACT.SIZE#R1` cumple por M2 en este build local | Resultado Wasm válido para esta revisión/plataforma; no sustituye iOS |
| iOS arm64 | No se generó `pseudolearn_bridge.framework` ni dSYM; Flutter no puede actualizar su caché bajo los permisos actuales | M1 no evaluada; no se certifica el presupuesto móvil | CF-06 continúa pendiente |
| Deno | `deno` no está en PATH | Sin efecto en campañas previstas de los cinco sujetos; sí limita validaciones del backend, que no es miembro de esta fase | No instalar ni usar otra cadena |

Verificaciones ya observadas: `cargo test --locked -p see_model -p see_validation -p see_cli`, Clippy,
formato, `see validate` (158 especificaciones), `see export --check` y `rust-checks all .` pasaron.
`cargo xtask verify` del motor pasó completo con `cargo-deny --offline` y su base advisory local temporal.
El xtask integral SEE no se lanzó porque intenta crear resultados en rutas `results/` ocupadas por evidencia
local previa; esos resultados se preservaron y se ejecutaron las puertas independientes. `see lock --check`
sigue fallando por `PERF.SUITE.CORE@1.0.0`; no se alteró el lock. CF-05/06 conservan pendientes donde faltó
evidencia, sin atribuir las reglas sin casos a divergencias de salida del motor.

## 5. Capas y archivos

Este archivo y los ajustes de los dos planes pertenecen a documentación transitoria raíz: sin imports,
responsabilidad de planificación y trazabilidad. No son dueños normativos del lenguaje.
La política pertenece al corpus de proceso y README de spec. Creación pertenece a see_cli;
validación a see_validation. Cada capa conserva exclusivamente los imports de architecture.yaml;
quedan prohibidos internos de sujetos y motor. Tests espejo, fixtures excluidos del recorrido ordinario.
No se añaden capas. Cualquier responsabilidad nueva se separará en archivo propio dentro de su capa.
Los README de engine, CLI, app y benchmarks solo se ajustarán si la campaña revela declaraciones
operativas desactualizadas, sin inventar resultados ni introducir dependencias de docs/.

## 6. Presupuestos de rendimiento y seguridad

PERF.AOT.LEVEL: razón por familia ≤1,70 frente a V1F, aceleración sobre VM en las diez cargas y
emisión mediana ≤15 ms por carga. PERF.ARTIFACT.SIZE: ios-arm64 ≤3 MiB y Wasm Brotli ≤600 KiB.
Aplicar PERF.PROTOCOL: diez procesos, treinta iteraciones cuando corresponda, estado nuevo,
validación fuera del reloj, semilla fija, intervalos del 95 %, resolución y puntos de cambio;
no descartar muestras ni mezclar hardware. Tamaños son mediciones de bytes, no campañas temporales.
No modificar presupuestos ni reactivar métricas retiradas. No ampliar permisos del host ni ejecutar
red externa como efecto de una prueba. Las capacidades futuras siguen siendo propuestas.

## 7. Pruebas y experimentos

SEE: éxito de contrato completo, rechazo de plantilla incompleta como estable, revisión ausente,
versión/estado inicial incorrecto, cambio presente, transición no autorizada, lápida reutilizada,
reanclaje ausente y conservación del mismo contrato oficial. Probar cada nueva restricción con negativo.
No rellenar revisado_por automáticamente con la identidad de la persona.

Campañas: casos, propiedades y matrices actuales de cinco sujetos. Datos faltantes, operación
no soportada o artefacto ausente se informan como tales, nunca como cumplimiento.
E-PG-01–12 se preparan aquí y se ejecutan en sus fases propietarias; no se exige implementarlos en PG-0.
E-PG-08 físico y pilotos E-PG-10/12 son complementarios. Pruebas de navegador, simulador,
semántica, accesibilidad y geometría automatizables siguen siendo exigibles en su fase.

## 8. Riesgos

| Riesgo | Señal temprana | Control |
|---|---|---|
| K-01 Alcance | Nuevas capacidades implementadas en PG-0 | Excepción limitada a SEE |
| K-02 Edición | Persisten promesas incompatibles de edición GP | Revisar trazabilidad y registrar impacto en 2026 |
| K-12 Evidencia histórica | Informe sin hash actual | Captura antes del build y hashes posteriores |
| Revisión ficticia | Plantilla atribuye aprobación humana | Revisor vacío hasta evidencia real |
| Evidencia opcional confundida | Ausencia presentada como éxito | Informar no evaluado y límites de cobertura |

## 9. Dependencias de la persona

Revisión independiente real de contratos cuando corresponda; autorización para corregir estados
existentes o ampliar alcance ante incumplimientos. La solicitud directa de implementar este plan
satisface su revisión previa y la autorización de inicio.
Licencia pendiente de elección en PG-7.07. Dispositivos y participantes son aportes opcionales;
no condicionan el cierre ni se simulan sus resultados. Sin publicación externa autorizada.

## 10. Orden de ejecución y puntos de control

1. Registrar C01/C02 y alinear documentación con las decisiones explícitas.
2. Formalizar política de proceso, casos, tests y adaptación SEE; verificar antes de campañas.
3. Capturar procedencia y obtener conformidad y mediciones actuales sin modificar el motor.
4. Clasificar discrepancias, completar catálogo, recursos y trazabilidad; verificar miembros afectados.
5. Completar resúmenes, commit con skill commit-message y push ordinario comprobado a la rama única.
6. Informar cierre y detenerse; PG-H y PG-1 requieren mensaje nuevo (PHASE-STOP).

Si falta una herramienta o falla una comprobación obligatoria, registrar dato y consecuencia;
no cerrar la fase ni expandir silenciosamente el alcance.

### Cierre común

- [x] `PG-0.C01` Autorización explícita registrada.
- [x] `PG-0.C02` Plan revisado por la persona.
- [x] `PG-0.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-0.C04` Reglas con casos y vínculos de conformidad.
- [x] `PG-0.C05` Tests felices, infelices y límite en espejo.
- [x] `PG-0.C06` Capas, imports y límites verificados.
- [x] `PG-0.C07` Código inglés, sin comentarios, pánicos ni unsafe ajeno.
- [x] `PG-0.C08` README y reglas autosuficientes actualizados.
- [x] `PG-0.C09` Sin sintaxis nueva: justificar ausencia de fichas de ayuda.
- [x] `PG-0.C10` Riesgos revisados y protocolos preparados; evidencia complementaria identificada.
- [ ] `PG-0.C11` Tests y verificadores obligatorios en verde.
- [ ] `PG-0.C12` Commit con skill y push ordinario comprobado.
- [x] `PG-0.C13` Resumen completo, informe y parada.

## 11. Resumen de ejecución

La implementación autorizada de política SEE, documentación, pruebas y catálogos está realizada. El resumen distingue los puntos cerrados de los intentos bloqueados; la fase permanece abierta por PHASE-GREEN.

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-0.01.01 | Cumplido | `SEE.LIFECYCLE`, `SEE.VERSIONING`; `see_validation/src/lifecycle.rs` | Contratos actuales expresan creación estable y congelamiento estricto |
| PG-0.01.02 | Cumplido | `see_validation/tests/lifecycle.rs` | Casos válidos, inválidos, de transición y borde |
| PG-0.01.03 | Cumplido | `cargo test --locked -p see_model -p see_validation -p see_cli` | Tests de espejo aprobados; incluidos revisión ausente y tombstone |
| PG-0.01.04 | Cumplido | `see_cli/src/templates.rs`, `see_validation/src/lifecycle.rs`, `see_model/src/lib.rs` | Creación, validación y omisión de `cambio: null` adaptadas |
| PG-0.01.05 | Cumplido | READMEs de spec, see_cli, see_validation y see_model | Decisión autosuficiente; sin referencias a docs/ |
| PG-0.01.06 | No cumplido | Tests, Clippy, rust-checks, validate/export pasaron; `cargo xtask verify` del motor pasó; `see lock --check` falla | Caché local de lock choca con `PERF.SUITE.CORE@1.0.0`; no se reescribió. El xtask integral SEE no se lanzó porque escribe rutas fijas `results/` ocupadas por evidencia local previa; se ejecutaron sus verificaciones independientes |
| PG-0.02.01 | Cumplido | Matriz CF-01–CF-20 en §4.1 | Tratamiento, estado, dueño/fase y condición registrados |
| PG-0.02.02 | Cumplido | Hoja de ruta y plan general actualizados | CF-03/19, C-03, PG-0.05/06 y situación de PG-0 sincronizados |
| PG-0.02.03 | Cumplido | Matriz §4.1, fila CF-20 | CF-20 sigue reservado para PG-6A; no se modificó AGENTS.md |
| PG-0.03.01 | Cumplido | `see feature language-2026`; `features/language-2026.yaml`; `see validate` | Consumidor devuelve agregado estable mientras manifiesto y criterio declaran experimental |
| PG-0.03.02 | Cumplido | CF-12 en §4.1 y decisión en plan general | Clasificado; se preserva el manifiesto y no se cambia ningún estado |
| PG-0.04.01 | Cumplido | Inventario D-01/03/04/08/12/14/15/16/19 y TS-3 en §4.2 | Origen marcado NV para todas las referencias |
| PG-0.04.02 | Cumplido | Propuestas y destinos en §4.2 | Ninguna propuesta se presenta como aprobación histórica |
| PG-0.05.01 | Cumplido | Plan general, decisión del 2026-10-22 | Diferimiento expreso a PG-7.07; derechos reservados mientras tanto |
| PG-0.05.02 | Cumplido | `PG-7.07` en plan general y §4.2 | Elección y auditoría de licencias exigidas antes del cierre final/publicación |
| PG-0.06.01 | Cumplido | ADR-05, CF-03, C-03 y PG-0.06 actualizados | 2026 queda como edición única; sin edición GP |
| PG-0.06.02 | Cumplido | Búsqueda de contradicciones y README de spec | La política técnica vive en su dueño; docs no se citan desde fuera |
| PG-0.07.01 | Parcial | Manifest de campaña con commit, export hash, fuentes, plataforma y toolchains; `see export --check`; engine/aot/service/cli lanzados | App no se pudo iniciar por escritura denegada en la caché de Flutter |
| PG-0.07.02 | Parcial | `conform` de los cinco sujetos, casos y propiedades, con salidas y códigos en `packages/pseudolearn_spec/results/pg0-campaign-2026-10-22/logs/` | Cuatro sujetos completaron sus propiedades; app no abrió sesión y tres sujetos reportan bindings sin casos; CF-05 no se cierra |
| PG-0.07.03 | Parcial | Matrices y evidencia cruda de engine, aot, service y cli; manifest con hashes SHA-256 de 2 816 fuentes y binarios usados; app logs preservados | No hay matriz de comportamiento para app ni hash de binario Flutter ejecutado |
| PG-0.08.01 | Parcial | Plataforma/toolchains, semilla fija 42 en protocolo paired y hashes de fuentes capturados en el manifest; Wasm Release reproducible | El paired no superó captura de hardware por `sysctl`; energía y controles pareados no se midieron |
| PG-0.08.02 | No cumplido | Log de paired en `results/pg0-campaign-2026-10-22/logs/performance-paired.json` | Captura de procedencia terminó antes de muestras por `Operation not permitted`; cero procesos/iteraciones observados |
| PG-0.08.03 | Parcial | Wasm final 2 391 389 B; Brotli Q11/lgwin22 530 080 B, bajo 614 400 B; hash y binario preservados | iOS arm64 y dSYM no se construyeron porque Flutter no puede actualizar su caché |
| PG-0.08.04 | Parcial | M2 de `PERF.ARTIFACT.SIZE#R1` cumple en Wasm; resumen recalculable del tamaño en `performance/wasm-measurement.json` | M1 iOS y `PERF.AOT.LEVEL` sin medición; CF-06 sigue pendiente |
| PG-0.09.01 | Cumplido | Tabla de discrepancias en §4.6 | Hallazgos observados clasificados; CF-05/06 permanecen pendientes de campañas |
| PG-0.09.02 | Cumplido | Cambios de esta iteración y tabla §4.6 | No se cambiaron esperados ni umbrales; PERF local no fue reanclado |
| PG-0.10.01 | Cumplido | Catálogo en §4.3 | Cinco capacidades con autoridad, límites y replay, sin implementación |
| PG-0.10.02 | Cumplido | Política de oráculos en §4.3 | Corpus/manual independiente; VM/AOT no presentados como oráculos; reference no reinstalado |
| PG-0.11.01 | Cumplido | Matriz E-PG-01–12 en §4.4 | Control, fase, recursos y disponibilidad registrados; protocolo completo enlazado internamente |
| PG-0.11.02 | Cumplido | §4.4 y decisión de la persona | Automatización sigue obligatoria; teléfono y pilotos humanos son complementarios y no simulados |
| PG-0.12.01 | Cumplido | Cruce base→R/C→fase→paquete en §4.5; inverso en hoja de ruta §12.3 | Exclusiones FUT justificadas y fases enlazadas con dueños |
| PG-0.12.02 | No cumplido | DAG, cadenas estructurales empatadas e incertidumbre en §4.5 | El plan solo da tallas S/M/L/XL, no estimaciones de duración; no se inventa calendario ni peso numérico |

Discrepancias observadas y sus consecuencias están registradas en §4.6. La campaña SEE conserva resultados
de cuatro sujetos y el fallo operativo del quinto; Wasm cumple su presupuesto, pero paired e iOS no produjeron
mediciones. Sigue pendiente la verificación integral SEE por el ancla local PERF. La fase no se cierra.
Revisión Git de cierre, commit y push: pendientes. Tests SEE, Clippy, formato, validate/export y verificadores
de capas pasaron; `cargo xtask verify` del motor pasó en modo advisory offline. `see lock --check` mantiene
la fase abierta.
