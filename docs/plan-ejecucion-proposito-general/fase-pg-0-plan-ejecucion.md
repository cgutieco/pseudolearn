# Fase PG-0 · Decisiones y línea base — plan de ejecución

## 0. Metadatos

Fase: PG-0. Fecha: 2026-10-22. Revisión inicial: `37a3da6a9dc377378ea14541250e28390bc5350d`.
Rama: `feature/agregar-ruta-de-especificacion`. Árbol inicial limpio, comprobado con `git status --short`.
Autorización: «Empecemos con la implementación de PG-0» y posterior «PLEASE IMPLEMENT THIS PLAN».
Estado: plan preparado para revisión; PG-0.C02 pendiente. Este documento no certifica campañas ni autoriza fases posteriores.

## 1. Punto de partida

SEE crea contratos con `borrador` y `0.1.0` en `crates/see_cli/src/templates.rs`.
Su validador permite promociones y avances de estado durante el congelamiento en
`crates/see_validation/src/lifecycle.rs`. Ambos pertenecen a `packages/pseudolearn_spec`.
El manifiesto `specifications/features/language-2026.yaml` declara `estado_agregado: experimental`.
`LANG.EDITION.MODEL`, `PERF.PROTOCOL`, `PERF.AOT.LEVEL` y `PERF.ARTIFACT.SIZE` declaran estable 1.0.0.
La evidencia histórica no certifica esta revisión. El host inspeccionado es macOS 27.0.1, arm64;
modelo de CPU, memoria, configuración y toolchains deben capturarse antes de compilar.

## 2. Lectura realizada

Se consultaron AGENTS.md, README raíz, hoja de ruta y plan general; README y reglas de spec;
README de CLI, benchmarks, trabajador de medición y secciones operativas de engine y app;
contratos de edición, ciclo de vida y rendimiento; creación y validación de ciclo de vida de SEE.
Antes de modificar cada miembro se completará la lectura de su README y reglas vigentes,
incluidos los README de los crates afectados. No se presume lectura completa de la app.

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

- [ ] `PG-0.01.01` Especificación: Formalizar creación estable 1.0.0, ausencia de cambio y congelamiento estricto en contratos de proceso existentes.
- [ ] `PG-0.01.02` Casos: Derivar creación válida, estados/versiones iniciales inválidos, transiciones prohibidas y reanclaje oficial.
- [ ] `PG-0.01.03` Tests: Añadir cobertura espejo de creación y validación, incluidos revisión ausente, identidades terminales y límites.
- [ ] `PG-0.01.04` Código: Adaptar creación y validación en sus capas actuales; no importar sujetos ni modificar el motor.
- [ ] `PG-0.01.05` Documentación: Actualizar README de spec y crates afectados, sin referencias a docs/.
- [ ] `PG-0.01.06` Verificación: Ejecutar tests dirigidos, validate, lock --check, export --check y cargo xtask verify; conservar salidas y hashes.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.02 · Tratamiento de conflictos

- [ ] `PG-0.02.01` Registro: Completar matriz CF-01–CF-18 con fuente, decisión, estado, responsable, fase y evidencia.
- [ ] `PG-0.02.02` Documentación: Actualizar hoja de ruta y plan general según las decisiones de esta conversación; conservar el rastro de opciones.
- [ ] `PG-0.02.03` Verificación: Comprobar que cada conflicto tiene tratamiento y que CF-20 sigue reservado a PG-6A.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.03 · Agregación CF-12

- [ ] `PG-0.03.01` Auditoría: Leer consumidor y validación de estado_agregado, contrastar manifiesto y estados individuales.
- [ ] `PG-0.03.02` Informe: Clasificar discrepancia y proponer tratamiento sin cambiar estados; cualquier corrección requiere autorización concreta.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.04 · Procedencia

- [ ] `PG-0.04.01` Registro: Inventariar D-01/03/04/08/12/14/15/16/19 y TS-3 como procedencia NV.
- [ ] `PG-0.04.02` Propuestas: Reconstruir solo decisiones necesarias con opciones y justificación; no atribuir aprobación histórica.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.05 · Licencia

- [ ] `PG-0.05.01` Registro: Registrar diferimiento autorizado a PG-7.07 y conservación de derechos reservados.
- [ ] `PG-0.05.02` Puerta: Actualizar cierre de PG-7 para exigir elección y comprobación antes del cierre final o publicación.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.06 · Edición 2026

- [ ] `PG-0.06.01` Documentación: Revisar ADR-05, CF-03, PG-0.06 y referencias a edición GP: desarrollo oficial en 2026 sin publicación nueva.
- [ ] `PG-0.06.02` Verificación: Buscar contradicciones en documentos transitorios; trasladar política autosuficiente a README dueño sin alterar semántica en PG-0.

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

- [ ] `PG-0.09.01` Clasificación: Por hallazgo registrar contrato aplicable, dato observado, categoría, impacto, propietario y evidencia.
- [ ] `PG-0.09.02` Control: No alterar esperados ni umbrales para obtener verde; incumplimiento obligatorio mantiene fase abierta y reparación del motor exige ampliación expresa.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.10 · Capacidades y oráculos

- [ ] `PG-0.10.01` Catálogo: Proponer consola, aleatoriedad, archivos, red y tiempo como clases candidatas, con autoridad, límites y reproducción; no implementarlas.
- [ ] `PG-0.10.02` Oráculos: Derivar esperados del corpus y controles independientes; VM/AOT compartidos aportan integración, no independencia; no reinstalar reference.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.11 · Recursos experimentales

- [ ] `PG-0.11.01` Matriz: Para E-PG-01–12 registrar control, fase, carga, semilla, plataforma, procedencia, criterio y disponibilidad.
- [ ] `PG-0.11.02` Obligatoriedad: Mantener pruebas automatizadas y mediciones sin dispositivos como obligatorias; marcar físicos y pilotos humanos complementarios, sin fabricar evidencia.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

### PG-0.12 · Trazabilidad

- [ ] `PG-0.12.01` Matriz: Completar punto base → R-xx → C-xx → fase → paquete y recorrido inverso, justificando relaciones no aplicables.
- [ ] `PG-0.12.02` Dependencias: Recalcular camino crítico sobre el DAG y sus estimaciones, declarar empates e incertidumbre; no autorizar paralelismo ni fases siguientes.

Aceptación: todas las tareas tienen evidencia reproducible o una disposición autorizada registrada; no basta con redactar el informe.

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

Revisión de este archivo antes de implementar (C02); revisión independiente real de contratos cuando
corresponda; autorización para corregir estados existentes o ampliar alcance ante incumplimientos.
Licencia pendiente de elección en PG-7.07. Dispositivos y participantes son aportes opcionales;
no condicionan el cierre ni se simulan sus resultados. Sin publicación externa autorizada.

## 10. Orden de ejecución y puntos de control

1. Revisar este archivo y registrar C02. Alinear documentación con decisiones explícitas.
2. Formalizar política de proceso, casos, tests y adaptación SEE; verificar antes de campañas.
3. Capturar procedencia y obtener conformidad y mediciones actuales sin modificar el motor.
4. Clasificar discrepancias, completar catálogo, recursos y trazabilidad; verificar miembros afectados.
5. Completar resúmenes, commit con skill commit-message y push ordinario comprobado a la rama única.
6. Informar cierre y detenerse; PG-H y PG-1 requieren mensaje nuevo (PHASE-STOP).

Si falta una herramienta o falla una comprobación obligatoria, registrar dato y consecuencia;
no cerrar la fase ni expandir silenciosamente el alcance.

### Cierre común

- [ ] `PG-0.C01` Autorización explícita registrada.
- [ ] `PG-0.C02` Plan revisado por la persona.
- [ ] `PG-0.C03` SPEC-FIRST y congelamiento respetados.
- [ ] `PG-0.C04` Reglas con casos y vínculos de conformidad.
- [ ] `PG-0.C05` Tests felices, infelices y límite en espejo.
- [ ] `PG-0.C06` Capas, imports y límites verificados.
- [ ] `PG-0.C07` Código inglés, sin comentarios, pánicos ni unsafe ajeno.
- [ ] `PG-0.C08` README y reglas autosuficientes actualizados.
- [ ] `PG-0.C09` Sin sintaxis nueva: justificar ausencia de fichas de ayuda.
- [ ] `PG-0.C10` Riesgos revisados y protocolos preparados; evidencia complementaria identificada.
- [ ] `PG-0.C11` Tests y verificadores obligatorios en verde.
- [ ] `PG-0.C12` Commit con skill y push ordinario comprobado.
- [ ] `PG-0.C13` Resumen completo, informe y parada.

## 11. Resumen de ejecución

Preparación documental realizada; tareas de ejecución pendientes. «No cumplido» indica que todavía no se ejecutó, no un resultado de fallo observado.

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-0.01.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.01.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.01.03 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.01.04 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.01.05 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.01.06 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.02.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.02.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.02.03 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.03.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.03.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.04.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.04.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.05.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.05.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.06.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.06.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.07.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.07.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.07.03 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.08.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.08.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.08.03 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.08.04 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.09.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.09.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.10.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.10.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.11.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.11.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.12.01 | No cumplido | — | Pendiente de ejecución tras revisión C02 |
| PG-0.12.02 | No cumplido | — | Pendiente de ejecución tras revisión C02 |

PG-0.05: diferimiento autorizado a PG-7.07 en la conversación; registrar formalmente durante ejecución.
Revisión Git de cierre: pendiente. Verificadores de fase: no ejecutados. Puntos cerrados: ninguno.
