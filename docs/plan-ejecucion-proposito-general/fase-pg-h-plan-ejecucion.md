# Fase PG-H · Catálogo y ayuda temprana — plan de ejecución

## 0. Metadatos

- Fase: PG-H; requisitos R-17, R-18 y R-20; capacidad C-16; ADR-13; riesgos K-16 y K-17;
  experimento E-PG-11; tratamiento de CF-17.
- Fecha de preparación: 2026-10-22. Fecha de inicio de implementación: 2026-10-22.
- Alcance autorizado en mensaje nuevo del 2026-10-22: implementación de `PG-H.04 · Cobertura editorial 2026`
  en una iteración; no autoriza `PG-H.05` ni cierra PG-H.
- Revisión de esta preparación: `2f5fccb6d046edfbaa054a2160b116259a1cd61b`; árbol limpio al comenzar la lectura.
  El borrador anterior se preparó sobre `d42a9e3047ebe664b74a709336934bc20ab8a916`, antes del cierre de PG-0.
- Rama: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- Encargo de preparación: «Crea el plan de ejecución para `PG-H · Catálogo y ayuda temprana`»;
  autorizó solo esta preparación documental. Encargos de implementación del 2026-10-22:
  «implementa `PG-H.02` de `fase-pg-h-plan-ejecucion.md` en una sola iteración» y
  «implementa `PG-H.03 · Resolución por posición` en una sola iteración» y
  «Implementa `PG-H.04 · Cobertura editorial 2026` en una sola iteración»; el mensaje más reciente
  autoriza `.04`, no puntos posteriores ni el cierre de PG-H.
- Dependencia satisfecha: PG-0 cerrada el 2026-10-22 en la revisión de esta preparación,
  con campañas y verificadores en verde según su resumen de cierre. Las autorizaciones de implementación
  cubren `.02` y, en el mensaje nuevo, `.03`; los puntos posteriores requieren autorización propia.
- Estado: `PG-H.01`, `PG-H.02`, `PG-H.03` y `PG-H.04` completos. `PG-H.C01` queda satisfecho para la
  autorización concreta de `.04`; la revisión integral del plan (`PG-H.C02`) sigue pendiente. PG-H permanece abierta.

Documento transitorio de `docs/`, dependiente del [plan general](plan-ejecucion-proposito-general.md)
y de la [hoja de ruta](../hoja-de-ruta-proposito-general.md). Ningún archivo fuera de `docs/`
puede citarlo (`DOC-NO-TRANSIENT-REFS`). Las decisiones se incorporarán a los README dueños y el
comportamiento al corpus durante la implementación, con texto autosuficiente.

## 1. Punto de partida

| Observación en la revisión inicial | Consecuencia para PG-H |
|---|---|
| `TOOL.SERVICE.HOVER@1.0.0`, estable, exige firma/descripción en R2; C4 solo comprueba que Longitud es intrínseca | Ampliar evidencia de contenido, idioma y sombreado; C4 no demuestra cobertura editorial |
| `pseudolearn_service/src/hover.rs` resuelve símbolos, keywords y lógicos; incorporadas usan firma generada | Conservar tipos y firmas del usuario; añadir operadores y roles con el mismo análisis |
| `src/keyword_help.rs` contiene 29 descripciones bilingües y una descripción genérica; el idioma depende del perfil | Migrar contenido útil a datos; separar idioma de interfaz y perfil sintáctico |
| `src/query_context.rs::token_at` usa tramos semiabiertos y un candidato al final del token, omitiendo trivia | Especificar fronteras antes de reutilizar esa selección para ayuda; no alterar otras consultas por accidente |
| `src/lsp_queries.rs::handle_hover` arma Markdown desde la respuesta actual, sin rango de hover | Derivar contenido y rango de la consulta común; proteger interpolaciones del programa |
| `pseudolearn_api/src/service_operations.rs` ofrece sesiones de edición, completado y vocabulario, sin consulta contextual de ayuda | Añadir operación y capacidad negociable; mantener errores y ciclo de vida públicos |
| `see_export/src/resources.rs` exporta objetos `valor` de definiciones por `termino`, rechazando duplicados | Reutilizar ese camino para el catálogo; no presuponer un nuevo bloque see/1 ya soportado |
| `RustSyntaxReferenceSource` enumera tipos, keywords e incorporadas y resuelve marcadores; no consulta por cursor | Conservar referencia curricular y añadir un puerto específico de ayuda contextual |
| `RustEditAssistSource` ya sincroniza texto/revisión y convierte posiciones mediante `SourceOffsetIndex` | Aprovechar los contratos existentes de sesión y coordenadas sin crear otro parser ni una copia del búfer en aplicación |
| El puente usa llamadas JSON propias y síncronas; los enlaces FRB son generados | Probar la nueva operación atravesando el puente real; regenerar enlaces solo si cambia su interfaz fuente |

Las rutas Rust abreviadas de servicio y API corresponden a
`packages/pseudolearn_engine/crates/<crate>/`; las de Flutter a `apps/pseudolearn_app/lib/`.
No se midió latencia ni se ejecutaron campañas funcionales durante la redacción.

### Línea base heredada de PG-0

Estas evidencias pertenecen al cierre anterior; sirven de control y no certifican una implementación
de PG-H. La procedencia y los resultados completos están en [el resumen de PG-0](fase-pg-0-plan-ejecucion.md).

| Evidencia registrada | Uso durante PG-H |
|---|---|
| SEE: 158 especificaciones; 30 propiedades y 1550 observaciones del motor, sin divergencias; verificación integral SEE y motor en verde | Comparar el corpus y ejecutar de nuevo las puertas de los miembros afectados |
| Service: 7/7 propiedades y 45/45 vínculos cumplen; app: 2/2 propiedades, 45 cumplen y 2 no aplicables | Control de regresiones previo a añadir casos de ayuda; no sustituye E-PG-11 |
| `PERF.ARTIFACT.SIZE`: iOS 2 985 792 B; Wasm Brotli 530 599 B, Apple M2 Mac14,3 | Repetir captura con catálogo incluido y mismo objetivo; iOS conserva solo un 5 % de margen |
| Edición única 2026; contratos nuevos estables 1.0.0, sin `cambio`; contratos existentes congelados | Editar texto oficial y reanclar identidades afectadas, sin reabrir estados/versiones |
| CF-12 sigue declarado: el agregado consultado y el manifiesto no coinciden | No corregir estados automáticamente ni usar el agregado como prueba de estabilidad de 2026 |

Alcance: edición 2026 vigente; catálogo, validación/exportación, consulta común, hover/comando LSP y
consulta por teclado/tacto de la app. Sin sintaxis nueva, extensión distribuible de VS Code,
proyectos multiarchivo, IDE nuevo, cambios a ejecución VM/AOT ni fichas de construcciones futuras.
PG-6A integrará esta ayuda en su extensión; PG-A ampliará cobertura a su sintaxis. No se difiere a
esas fases el hover ni la consulta de la app que PG-H ya exige.

## 2. Lectura realizada

Lectura del borrador contrastada con la revisión de esta preparación, enfocada en las responsabilidades afectadas:

- [x] `AGENTS.md`, README raíz, plan general §4.2 y §5, hoja de ruta R-17/18/20,
  C-16, PG-H, ADR-13, CF-17, K-16/17 y E-PG-11; estado de PG-0 y decisiones del 2026-10-22.
- [x] README y `architecture.yaml` de `packages/pseudolearn_spec` y
  `packages/pseudolearn_engine`; README de `see_model`, `see_validation`, `see_export`,
  `pseudolearn_service` y `pseudolearn_api`.
- [x] README de `apps/pseudolearn_app`: verificación, capas, conocimiento, puente y asistencia
  de edición; `architecture.yaml` de app; README y reglas de `native/`.
- [x] Corpus: `LANG.PROFILE.VOCABULARY`, `LANG.SYNTAX.GRAMMAR`, `LIB.MODEL`,
  `LANG.CONTROL.FOR`, `LANG.CONTROL.REPEAT`, `TOOL.SERVICE.HOVER`,
  `TOOL.SERVICE.INCREMENTAL`, `TOOL.LSP.CAPABILITIES`, `API.MODEL`, `API.ANALYZE`,
  `API.VERSIONING`, `API.ERRORS`, `API.WIRE-FORMAT`, `SEE.FORMAT`, `SEE.GENERATION`,
  `SEE.VALIDATION` y `PERF.PROTOCOL`: contratos estables en 1.0.0.
- [x] Código: hover, descripciones, contexto y consultas/protocolo LSP del servicio;
  operaciones públicas de servicio; exportador de recursos; referencia de sintaxis y adaptador
  de asistencia de edición de Flutter.

Durante la ejecución se leerá el README de cualquier crate adicional antes de modificarlo. La
matriz de imports de `architecture.yaml` es la autoridad ejecutable; las listas resumidas de README
no habilitan dependencias adicionales. Este cambio solo escribe documentación raíz: sin imports,
sin capa de producto ni responsabilidad normativa. Su dueño es este archivo nuevo, separado de PG-0.

## 3. Decisiones de diseño

Son elecciones propuestas para implementar ADR-13. Las decisiones e identidades del catálogo de
`PG-H.01` quedaron fijadas en `TOOL.SERVICE.CATALOG`; las decisiones de consulta, resolución, render
y app siguen propuestas y se confirmarán en el corpus antes del código. No se presentan como
capacidades existentes.

| Decisión | Opciones y criterio | Elección propuesta | Reversión y dueño documental |
|---|---|---|---|
| Datos de ficha | Nuevo bloque see/1 o recurso en `definicion.valor`; mínima extensión verificable | Recurso tipado en contrato propio, exportado por el camino actual; esquema explícito, sin lexemas/firmas copiados | Cambiar formato solo si no representa los datos con validación clara; README spec/export |
| Materialización | Lectura de archivos en runtime o generación en build; portabilidad y determinismo | Generar tablas del servicio desde exportación verificada, sin acceso ambiental en consulta | Revisar si tamaño/arranque refutan la elección; README service/engine |
| Unidad editorial | Ficha por grafía o identidad con construcción/rol | Tema estable, identidad léxica y relaciones de rol; alias comparten ficha, prosa es/en editorial | Desdoblar solo si las reglas distinguen temas; README spec/service |
| Contexto | Regex del cliente, análisis por consulta o sesión preparada | CST y resolución semántica existentes; ayuda léxica explícita si no se prueba el rol | Si el contexto no basta, mejorar recuperación en su dueño tras especificarlo; nunca inferir en clientes; README service |
| Frontera | Operación sin estado o sesión con revisión | Recurso de documento/sesión existente, revisión exigida y respuesta propia; consulta no muta texto ni ejecución | Ajustar adaptación entre recursos solo si se demuestra incompatibilidad; README API |
| Fronteras de token | Semiintervalos puros o compatibilidad del cursor final | Interior primero; candidato al final únicamente en frontera permitida y sin entrar en trivia/literal; fijar casos antes de código | Si contradice contrato vigente, `CONFLICT-REPORT` antes de elegir; README service |
| Presentación | Markdown libre o subconjunto cerrado | Secciones estructuradas; Markdown/texto solo como proyección segura, enlaces únicamente a identidades internas admitidas | Ampliar subconjunto tras casos adversarios y revisión; README service/app |
| Estado de ayuda en app | Más responsabilidades en EditorCubit o componente específico | Estado de consulta separado que recibe texto/revisión/selección del editor dueño; puerto pequeño y adaptador Rust | Revisar si obliga a duplicar búfer o excede límites; README app |

Toda ficha declarará disponibilidad por edición, perfil y rigor; título, resumen, propósito, partes,
restricciones, errores comunes, anclajes y ejemplos por idioma. Formas canónicas y firmas se obtienen
de sus fuentes normativas. Las exclusiones tendrán identidad, motivo tipado y condición de aplicación;
no se admite excluir un rol activo para disimular contenido pendiente.

La consulta separará documento/revisión, posición/unidad, idioma y detalle de perfil/rigor/edición
resueltos. La respuesta declarará tema, token cuando exista, construcción/rol, certeza contextual,
rangos léxico y envolvente, secciones y ejemplos. Ausencia de ficha, contexto parcial, posición
inválida, capacidad ausente y revisión obsoleta tendrán resultados distintos y verificables.
Los símbolos de usuario conservarán su firma/tipo sin atribuirles intención pedagógica inventada.

## 4. Desglose por punto

El orden de cada lista es especificación → casos → tests → código/datos → documentación →
verificación. Las dependencias entre puntos se concretan en §10. `PG-H.01` se completó;
los puntos `PG-H.05`–`.12` siguen pendientes.

### Trazabilidad de entregables y aceptación

Cada fila corresponde al punto del plan general con el mismo ID. Sus seis subtareas detallan cómo
producir y verificar la evidencia; completar este documento no satisface ninguna de ellas.

| Punto | Entregable revisable | Condición para marcarlo cumplido |
|---|---|---|
| PG-H.01 | Contrato de catálogo, esquema y recurso exportado | Validación, anclaje y exportación deterministas; la prosa queda cubierta por el hash |
| PG-H.02 | Contrato y operación pública de consulta | Negociación y ciclo de recursos probados, incluida revisión obsoleta |
| PG-H.03 | Contrato y resolutor por posición | Matriz de fronteras, compuestos, roles y sombreado sin asignaciones erróneas |
| PG-H.04 | Inventario y fichas editoriales es/en de 2026 | 100 % de identidades/roles activos con ficha o exclusión tipada válida |
| PG-H.05 | Correspondencia de ayuda anterior y datos nuevos | Las 29 entradas tienen destino revisado; ningún contenido útil queda perdido |
| PG-H.06 | Índice ficha → regla/caso → ejemplo/esperado | Todos los ejemplos se verifican en su perfil/rigor con esperado independiente |
| PG-H.07 | Verificador y fixtures negativos | Cada violación se rechaza por su diagnóstico y la puerta integral los ejecuta |
| PG-H.08 | Hover y comando LSP sobre la consulta común | Paridad de identidad/rol/rangos/ejemplos con API; navegación conservada |
| PG-H.09 | Acción y panel de app con puerto propio | Acceso por teclado/tacto, selección y foco conservados, puente real en verde |
| PG-H.10 | Auditoría de consumidores y prueba de generación | Sin prosa normativa duplicada ni reconocimiento del lenguaje en clientes |
| PG-H.11 | Política de render y proyecciones seguras | Casos hostiles inertes o rechazados en LSP y app, sin efectos externos |
| PG-H.12 | Campaña E-PG-11 y resumen recalculable | Cobertura y paridad completas; latencia, coste frío, memoria y bytes informados |

### PG-H.01 · Catálogo normativo

- [x] `PG-H.01.01` Especificar identidad de ficha/rol, esquema, disponibilidad, anclajes, idiomas,
  ejemplos y exclusiones; proponer contrato propio sin convertir docs/ en dependencia.
- [x] `PG-H.01.02` Derivar casos de ficha completa, mínima, duplicada, vacía e incompatible con edición/rigor.
- [x] `PG-H.01.03` Preparar tests espejo de modelo, carga, exportación y preservación del contenido editorial.
- [x] `PG-H.01.04` Añadir datos y soporte mínimo de recurso/esquema/exportación; comprobar que su hash cubre
  también la prosa editorial normativa, sin depender de párrafos Markdown excluidos del anclaje.
- [x] `PG-H.01.05` Documentar formato, dueño y generación en los README spec y crates afectados.
- [x] `PG-H.01.06` Validar, reanclar solo contratos afectados conservando versiones/estados y verificar exportación reproducible.

### PG-H.02 · Consulta pública

- [x] `PG-H.02.01` Especificar operación y capacidad, entrada/salida, ciclo de recursos, unidades,
  índices de línea/columna, detalle, idioma, revisión y errores en el corpus API.
- [x] `PG-H.02.02` Añadir casos de documento vigente, obsoleto/liberado/ajeno, capacidad ausente,
  posición inválida, idioma independiente del perfil y enteros transportados sin pérdida.
- [x] `PG-H.02.03` Preparar tests de negociación, serialización y consulta sin efectos sobre recursos vivos.
- [x] `PG-H.02.04` Implementar DTO y operación en API sobre el servicio; adaptar conformidad y anunciar
  capacidad únicamente al estar implementada. Reutilizar sesiones sin exponer índices del CST.
- [x] `PG-H.02.05` Documentar operación, vigencia y errores en README API/engine.
- [x] `PG-H.02.06` Ejecutar casos API y pruebas de cierre/revisión; comprobar listado y negociación de operaciones.

### PG-H.03 · Resolución por posición

- [x] `PG-H.03.01` Especificar prioridad token/símbolo/construcción, fronteras, final del token,
  compuestos, trivia, recuperación y ausencia de ayuda; mantener texto original.
- [x] `PG-H.03.02` Derivar casos en cada componente y espacio/tab de Con Paso y Por Referencia;
  Hacer en Para/Mientras/Segun, Hasta y Hasta Que, aliases, operadores, literales, comentarios,
  salto de línea, EOF, truncamiento y builtin sombreado.
- [x] `PG-H.03.03` Preparar tests espejo del resolutor y conversiones Unicode/CRLF en ambas direcciones.
- [x] `PG-H.03.04` Implementar resolutor CST/semántico, certeza parcial y rangos completos sin cambiar el lexer
  para extender alcance ni reconocer palabras cercanas a una posición sin token.
- [x] `PG-H.03.05` Documentar prioridades, fronteras y recuperación en README service/source si corresponde.
- [x] `PG-H.03.06` Ejecutar matriz es/en × estricto/flexible y regresiones de hover, navegación y completado.

### PG-H.04 · Cobertura editorial 2026

- [x] `PG-H.04.01` Definir inventario exigible desde vocabulario, operadores, incorporadas y roles
  de gramática; declarar explícitamente roles pedagógicos sin pretender derivarlos de la EBNF sola.
- [x] `PG-H.04.02` Añadir casos de alias, rol sin ficha, exclusión válida/abusiva y traducción faltante.
- [x] `PG-H.04.03` Preparar tests de denominador, unicidad de identidad y cobertura de ambos idiomas.
- [x] `PG-H.04.04` Redactar fichas es/en y exclusiones justificadas; generar formas/firmas desde sus dueños.
- [x] `PG-H.04.05` Documentar autoría editorial, revisión y mantenimiento del inventario en README spec.
- [x] `PG-H.04.06` Producir matriz identidad/rol → ficha o exclusión; exigir 100 % sin usar fallback genérico como cobertura.

### PG-H.05 · Migración de ayuda incrustada

- [ ] `PG-H.05.01` Fijar en el contrato que la descripción útil tiene dueño único de datos, sin alterar semántica.
- [ ] `PG-H.05.02` Inventariar las 29 entradas y fallback actuales, relacionando cada dato útil con destino,
  corrección editorial justificada o reemplazo específico; derivar casos de preservación.
- [ ] `PG-H.05.03` Preparar tests de materialización desde exportación y ausencia de tablas editoriales paralelas.
- [ ] `PG-H.05.04` Migrar/revisar contenido y retirar `keyword_help.rs` o reducirlo a acceso a datos generados;
  separar locale de perfil sin perder las firmas de usuario.
- [ ] `PG-H.05.05` Documentar generación y motivos de correcciones en README service, sin referencias transitorias.
- [ ] `PG-H.05.06` Revisar correspondencia completa origen/destino y ejecutar regresiones bilingües.

### PG-H.06 · Ejemplos derivados

- [ ] `PG-H.06.01` Especificar referencias versionadas a reglas/casos, perfil/rigor y resultado esperado;
  distinguir ejemplo ejecutable, diagnóstico deliberado y plantilla incompleta rotulada.
- [ ] `PG-H.06.02` Derivar ejemplos mínimos desde reglas, incluyendo paso cero/dirección y modos de paso;
  registrar cálculo independiente de esperados y traducciones con colisión rechazada.
- [ ] `PG-H.06.03` Preparar tests de vínculo, perfil, rigor y rechazo de esperado/formato incorrectos.
- [ ] `PG-H.06.04` Añadir casos que falten y enlazar fichas a sus fuentes; extender comparación de conformidad
  solo lo necesario. La ejecución verifica, nunca produce el esperado.
- [ ] `PG-H.06.05` Documentar procedencia y validación en README spec/conformance.
- [ ] `PG-H.06.06` Validar todos los ejemplos aplicables y sus negativos; preservar fallos reales y evidencia por sujeto.

### PG-H.07 · Verificador del catálogo

- [ ] `PG-H.07.01` Especificar invariantes y diagnósticos estables del verificador y la separación
  entre integridad estructural, ejecución de ejemplos y revisión editorial independiente.
- [ ] `PG-H.07.02` Crear fixtures negativos aislados: ficha huérfana, anclaje roto/retirado, forma retirada,
  ejemplo inválido, traducción ausente, identidad duplicada, exclusión abusiva y recurso demasiado profundo.
- [ ] `PG-H.07.03` Preparar tests que exijan el diagnóstico correcto por fixture y aceptación del catálogo válido.
- [ ] `PG-H.07.04` Implementar verificación en see_validation y ejecución de ejemplos por conformidad/CLI;
  no importar ni ejecutar el motor dentro del validador estructural.
- [ ] `PG-H.07.05` Documentar reglas, límites y comando de verificación en README spec/validation.
- [ ] `PG-H.07.06` Integrar en `cargo xtask verify`; demostrar rechazo individual y fallo de exportación obsoleta.

### PG-H.08 · Servicio, API y LSP comunes

- [ ] `PG-H.08.01` Ampliar TOOL.SERVICE.HOVER y TOOL.LSP.CAPABILITIES: contenido/rango,
  idioma y comando de explicar con argumentos/revisión; no sobrecargar signatureHelp.
- [ ] `PG-H.08.02` Derivar conversaciones initialize/open/hover/explicar/change/close, texto o Markdown,
  comando desconocido, revisión vieja y preservación de navegación a definición.
- [ ] `PG-H.08.03` Preparar tests de adaptadores que contrasten la misma identidad, rol, rangos y ejemplo con API.
- [ ] `PG-H.08.04` Conectar hover y comando al resolutor común; anunciar solo comandos implementados,
  usando conversión de coordenadas compartida y locale de sesión.
- [ ] `PG-H.08.05` Documentar capacidades y formato seguro en README service/API.
- [ ] `PG-H.08.06` Ejecutar conformidad service y API más regresiones de LSP; comprobar que no hay una tabla paralela.

### PG-H.09 · Consulta de la app por puente

- [ ] `PG-H.09.01` Especificar contrato APP de consulta, accesibilidad, vigencia, apertura/cierre y
  selección conservada; consulta explícita aun con asistencia automática desactivada.
- [ ] `PG-H.09.02` Derivar escenarios de teclado, menú/pulsación mantenida, cursor normal, selección,
  composición IME, scroll, cambio de documento, fallo de puente y respuesta obsoleta.
- [ ] `PG-H.09.03` Preparar tests de puerto/estado, widgets semánticos, foco/geometría y transporte real.
- [ ] `PG-H.09.04` Añadir modelo, puerto, adaptador y estado específicos; integrar panel/acción en editor
  sin parser, nueva fuente de texto ni método extra que exceda el límite de EditorCubit.
- [ ] `PG-H.09.05` Documentar flujo y límites en README app; documentar/regenerar puente solo si su firma cambia.
- [ ] `PG-H.09.06` Ejecutar widgets y FFI real, conformidad app, accesibilidad y humo automatizable en simulador;
  registrar por separado cualquier cobertura física ausente.

### PG-H.10 · Fuente única en consumidores

- [ ] `PG-H.10.01` Especificar propiedad de paridad y ausencia de reconocimiento/prosa normativa duplicados.
- [ ] `PG-H.10.02` Añadir casos de locale distinto del perfil y negativos de copia local/regex de lenguaje.
- [ ] `PG-H.10.03` Preparar prueba de arquitectura con violaciones deliberadas y equivalencia de respuesta normalizada.
- [ ] `PG-H.10.04` Sustituir descripciones locales por consulta; mantener solo etiquetas de interfaz localizadas y
  narrativa curricular propia, enlazando fichas compartidas cuando expongan semántica del lenguaje.
- [ ] `PG-H.10.05` Documentar límites entre currículo, interfaz y catálogo en README app/service.
- [ ] `PG-H.10.06` Auditar consumidores alcanzables y demostrar que una modificación de ficha llega a todos por generación.

### PG-H.11 · Render seguro

- [ ] `PG-H.11.01` Especificar subconjunto admitido, escape de texto fuente, enlaces internos y límites
  de bytes/secciones/profundidad; sin HTML activo, imágenes remotas, ejecución ni enlaces arbitrarios.
- [ ] `PG-H.11.02` Derivar casos de etiquetas HTML, URI command/javascript/data/file, enlaces codificados,
  cercas Markdown en nombres/textos, contenido excesivo y referencias internas inexistentes.
- [ ] `PG-H.11.03` Preparar tests adversarios de validación y de los renderizadores LSP/app, incluido texto plano.
- [ ] `PG-H.11.04` Implementar saneamiento y proyección acotada en sus dueños; contenido del usuario nunca se interpreta
  como marcado confiable. Una consulta no ejecuta sus ejemplos.
- [ ] `PG-H.11.05` Documentar política y límites elegidos en README service/app, junto a la prueba que los exige.
- [ ] `PG-H.11.06` Verificar que todos los intentos hostiles se rechazan o muestran como texto inerte sin abrir recursos.

### PG-H.12 · E-PG-11 y evidencia de salida

- [ ] `PG-H.12.01` Formalizar protocolo, métricas candidatas, controles y manifest de procedencia conforme a §6–7;
  los presupuestos PERF vigentes no se sustituyen por el objetivo candidato de ayuda.
- [ ] `PG-H.12.02` Congelar conjunto y resultados derivados de la matriz 2026 de §7, semilla y cantidades;
  incluir ausencias válidas y fallos, sin recortar corpus para obtener cobertura.
- [ ] `PG-H.12.03` Preparar tests del arnés: respuesta incorrecta, muestra faltante, revisión cruzada,
  fallo de reloj y resumen alterado deben invalidar la campaña.
- [ ] `PG-H.12.04` Implementar modo acotado del trabajador sobre API pública y comparación por LSP/puente;
  capturar muestras y resultados crudos en directorio nuevo, preservando campañas anteriores.
- [ ] `PG-H.12.05` Documentar reproducción en README del trabajador y miembros afectados, sin citar este plan.
- [ ] `PG-H.12.06` Ejecutar, recalcular e informar cobertura, errores, p95 caliente, coste frío y bytes;
  aplicar éxito/descarte, completar resumen y revisar riesgos sin declarar mediciones no realizadas.

## 5. Capas y archivos

Mapa previsto; archivos nuevos son propuestas, no archivos existentes. Cada nombre se confirmará al
iniciar su tarea. Tests en `tests/` espejo de Rust o `test/` espejo de Dart; fixtures deliberados
fuera del recorrido ordinario. Ninguna capa nueva es necesaria inicialmente.

| Archivos nuevos o modificados | Capa y responsabilidad dueña | Imports permitidos y prohibidos |
|---|---|---|
| Este archivo y enlace en plan general | Documentación transitoria raíz; planificación | Sin imports; solo referencias internas de docs/ |
| `specifications/tool/tool.help.catalog.md`, `api/api.syntax.help.md`, `app/app.editor.help.md` nuevos; contratos HOVER/LSP/API/SEE afectados; recursos en `specifications/cases/` | Corpus spec; comportamiento, datos y casos | Solo identidades del corpus; sin código, URLs externas ni docs/ |
| `schemas/` y `fixtures/` de spec; `crates/see_model/src/` si necesita tipos | Datos/modelo; forma del recurso | Modelo sin imports internos; serde/serde_json; sin validación ni sujetos |
| `crates/see_validation/src/help_catalog.rs` nuevo y registro existente | Integridad del catálogo | model, graph, change, format; semver/serde_json; sin engine ni procesos |
| `crates/see_export/src/resources.rs` y módulo nuevo si precisa proyección específica | Exportación determinista; no validación semántica del programa | model, change, format y serde_json; sin sujetos ni CLI |
| `see_conformance/src/` y `see_cli/src/` en módulos específicos si faltan operaciones | Comparación/ejecución por protocolo y orquestación | Solo listas de cada crate en architecture.yaml; validación nunca importa conformance |
| `crates/pseudolearn_service/build.rs` nuevo y generador separado; `src/help_catalog.rs`, `help_resolution.rs`, `help_rendering.rs` nuevos; hover y sesiones existentes | service; materialización, resolución y proyección en archivos separados | source, diagnostics, lexicon, syntax, semantic; serde/serde_json; sin runtime, VM, API ni SEE como crate |
| `pseudolearn_service/src/lsp_queries.rs`, sesión/protocolo y módulo nuevo del comando | service; adaptación LSP del resultado común | Misma matriz del servicio; sin UI ni E/S del transporte |
| `crates/pseudolearn_api/src/syntax_help.rs` nuevo; `service_operations.rs`, capacidades y sesiones | API; contrato público y validación de recursos | Capas públicas declaradas, incluido service; serde/serde_json/sha2; sin consumidores ni SEE |
| `crates/pseudolearn_conformance/src/` si falta proyección de consulta | Adaptador de conformidad | API, serde/serde_json; sin internos de service ni oráculos locales |
| `crates/pseudolearn_bench_worker/src/` modo nuevo de ayuda | Tooling; E-PG-11 | API y demás imports ya declarados; sin importar service directamente ni Flutter |
| `lib/domain/model/help/` y `lib/domain/ports/syntax_help_source.dart` nuevos | App model y ports; respuesta inmutable y consulta pequeña | model sin otras capas; ports solo model; ambos sin Flutter, Rust, bloc ni E/S |
| `lib/engine/rust/rust_syntax_help_source.dart` nuevo; índices/transporte existentes solo si hace falta | App engine; mapear DTO y coordenadas | model/ports y propia capa; sin application, presentation, data, Flutter, dart:io/ui ni RegExp |
| `lib/application/editor/` módulos de ayuda nuevos, integración mínima en estado editor | App application; vigencia y estado de vista, sin otro dueño del búfer | model/ports y propia capa; sin engine, widgets, RegExp ni infraestructura |
| `lib/presentation/editor/` panel/acción nuevos y componentes de entrada; l10n | App presentation; interacción accesible y dibujo | model/application y propia capa; sin ports/engine/data, RegExp, await ni derivación de colecciones |
| `lib/composition/` ensamblado | App composition; inyectar puerto | Todas las capas declaradas; sin ramas de selección dinámica |
| `native/src/api.rs` y tests solo si la operación requiere adaptar el sobre | Puente; transporte sin lógica de ayuda | pseudolearn_api, flutter_rust_bridge, serde_json; sin service ni dominio app |
| README de cada miembro/crate modificado; architecture.yaml cuando cambie una regla | Documentación técnica y contrato mecánico | Autosuficientes, sin citar docs/ ni atribuir resultados inexistentes |

`keyword_help.rs` ya es dueño del texto incrustado, pero no será dueño de fichas editoriales nuevas:
estas viven en spec. `hover.rs` conservará adaptación de símbolos; el resolutor de roles tendrá archivo
propio. `service_operations.rs` solo despacha, y EditorCubit no absorberá la nueva responsabilidad.
No se escriben a mano FRB ni tablas generadas. Si aparece un cambio de grafo o capa, se declara antes
del código y se actualiza el README correspondiente (`LAYER-DECLARED`, `DOC-README-TRUTH`).

Límites actuales: Rust 300 líneas/archivo, 40/función, 4 parámetros posicionales, anidación 3 y
7 métodos públicos; Dart 250/archivo, 40/función, 30/build, 3 parámetros posicionales, anidación 3
y 5 miembros públicos. Rigen las excepciones declaradas de generados, sin extenderlas a código propio.

## 6. Presupuestos de rendimiento y seguridad

- E-PG-11 propone p95 de consulta caliente ≤20 ms en host identificado con contexto preparado;
  coste frío de apertura/análisis/generación de respuesta se informa separado. `PERF.PG.SERVICE`
  sigue siendo candidato hasta aprobación específica; no se inventa un contrato PERF vigente.
- Mantener `PERF.ARTIFACT.SIZE`: iOS arm64 ≤3 MiB y Wasm Brotli ≤600 KiB. Medir bytes antes/después
  en el mismo build objetivo, incluyendo el catálogo; no extrapolar Wasm a iOS. Si el grafo de
  dependencias afecta ejecución, comprobar presupuestos activos sin tratar ayuda como exención AOT.
- Mantener ayuda fuera del camino de ejecución sin consultas. Medir tamaño del catálogo, respuesta
  breve/ampliada y memoria retenida tras consultas/apertura/cierre; no prometer coste cero sin medir.
- Fijar en corpus límites de respuesta y detalle antes de implementar, compatibles con el MiB por
  petición/respuesta de conformidad. Límite excedido devuelve valor tipado, sin truncado silencioso.
- Ninguna consulta abre archivos, red, comandos o ejemplos. Sin HTML activo, URI externas,
  identificadores numéricos con pérdida ni normalización del texto fuente que cambie sus rangos.
- Sin pánicos ni unsafe propios; frontend y puente conservan aislamiento respecto de Cranelift/AOT.

## 7. Pruebas y experimentos

### 7.1 Matriz funcional y adversaria

Cruzar perfiles es/en, rigores estricto/flexible e idioma de interfaz es/en independientemente.
Inventariar todas las identidades, roles y alias activos, sin fijar una cantidad inferida del texto.
Consultar cada palabra y blanco interno permitido de compuestos, su primer/último punto y fronteras
adyacentes. Incluir asignación frente a comparación, nombres de un carácter y homónimos de builtin.

Casos sin ayuda o parciales: documento vacío, solo trivia, comentario/cadena con palabras reservadas,
operador o keyword truncados, bloques sin cierre y expresión inválida. No buscar el token más cercano.
Casos de coordenadas: BOM, LF/CRLF, tabulaciones, NFC/descompuesto, emoji antes de la consulta,
UTF-8/puntos de código/UTF-16, posición entre sustitutos, fuera de línea y EOF. Ninguna conversión
inválida se ajusta silenciosamente para devolver otra ficha.

Comparar API, LSP y app por identidad, rol, ejemplos, certeza y rangos convertidos a una unidad
común. La igualdad entre transportes verifica integración del mismo núcleo; el resultado correcto
proviene del corpus y revisión editorial independiente, no del acuerdo entre tres clientes.

Probar petición obsoleta y respuesta que llega tras edición/cambio de documento; conservar selección,
foco, scroll, navegación, IME y aceptación de completado. Widgets verifican semántica accesible,
teclado, menú/tacto y ausencia de desbordes con escalado. El transporte real no se sustituye por dobles.
Cada verificador nuevo tiene negativo que falla por su diagnóstico previsto, más test del rechazo.

### 7.2 Protocolo E-PG-11

1. Antes del build capturar revisión, árbol/diff y hashes de fuentes, corpus/exportación, inventario,
   toolchains, OS y hardware; después, hashes de binarios y biblioteca FRB usados. Semilla propuesta 42.
2. Congelar dataset de cobertura completa y posiciones derivadas; control actual de hover sobre los
   temas que ya soporta, más control de respuesta estructurada esperada. Comparar costes solo sobre
   operaciones semánticamente equivalentes; informar aparte la cobertura añadida.
3. Campaña funcional exhaustiva en las combinaciones de §7.1; registrar número de consultas esperadas,
   completadas, sin ayuda válida, parciales y erróneas por transporte. Medir latencia en documento
   pequeño y contexto de 10 000 líneas, con misma consulta/posición y estado inicial en cada variante.
4. Diez procesos independientes y al menos treinta iteraciones por proceso/carga, conforme a
   PERF.PROTOCOL. Preparar contexto fuera del reloj de consulta caliente; usar estado nuevo por iteración.
   Cronometrar frío en serie separada. Validar resultados fuera del reloj, sin E/S en el intervalo;
   informar núcleo y transporte/render por separado cuando se midan.
5. Publicar resolución de reloj, muestras crudas, p95 y cálculo reproducible, intervalos del 95 %,
   bootstrap sembrado y puntos de cambio; no descartar muestras ni mezclar máquinas. Retener fallos,
   memoria como cota observada y bytes, sin seleccionar solo posiciones rápidas.
6. Éxito funcional: cero fichas/roles erróneos, 100 % del inventario cubierto o exclusión válida,
   ejemplos válidos y paridad de identidad/rango/ejemplo. Criterio temporal candidato: p95 caliente
   ≤20 ms; frío se informa sin umbral inventado. Si falla rol, usar fallback léxico declarado solo
   donde el contrato lo permite; no contar ese fallback como cobertura de rol resuelto.
7. Ante fallo, registrar qué hipótesis se refuta y su consecuencia; corregir y repetir campaña con
   manifiesto nuevo, o solicitar decisión si exige cambiar alcance/criterio. No cerrar por promedios
   favorables ni por ausencia de infraestructura. El ensayo no mide eficacia pedagógica humana.

La campaña se guardará en ruta local nueva bajo `results/`, con manifest, consultas, respuestas,
muestras, resumen y comandos. El modo exacto nuevo del trabajador se documentará al implementarlo;
no se cita aquí como comando ya disponible.

### 7.3 Puertas de verificación previstas

| Directorio | Comandos existentes y evidencia |
|---|---|
| `packages/pseudolearn_spec` | `cargo xtask verify`; además conformidad `service`, `engine` y `app` con `cargo run --locked -p see_cli --bin see -- conform --subject <sujeto>` y propiedades mediante `--operation properties`; conservar matrices y resultados crudos |
| `packages/pseudolearn_engine` | `cargo xtask verify`; suites espejo de service/API/adaptador/trabajador; `bash tool/wasm.sh build` y `bash tool/wasm.sh test` para comprobar grafo y frontera pública afectados |
| `apps/pseudolearn_app` | `flutter analyze --fatal-infos --fatal-warnings`, `dart run tool/check_limits.dart`, `dart run tool/check_content.dart`, `dart run tool/check_design_system.dart`, build nativo release previo a `flutter test`, `bash tool/test_bridge.sh` y `bash tool/bridge.sh check`; humo de simulador según README |
| `apps/pseudolearn_app/native` | `cargo fmt --all --check`, `cargo clippy --all-targets`, `cargo test`, `cargo deny check` y `rust-checks all .` con la invocación de su README; aislamiento y regeneración si la interfaz cambia |

Registrar comando exacto, directorio, versión, salida y código. No sustituir la puerta integral por
una selección favorable de pruebas. Si un fallo heredado persiste, se informa y mantiene abierta la
fase hasta su resolución o decisión explícita pertinente; no se borran locks ni resultados previos.
No se despachan GitHub Actions ni despliegues como parte automática de esta fase.

## 8. Riesgos

| Riesgo | Señal temprana | Control y criterio |
|---|---|---|
| K-16 Deriva editorial | Ficha contradice regla, alias duplicado o falta idioma | Fuente única, anclajes, revisión independiente y negativos; no publicar cobertura incompleta |
| K-17 Rol equivocado | Hacer genérico, Hasta mal asignado, builtin sombreado | CST/símbolo, casos de frontera y revisión; certeza parcial explícita sin inferencia textual |
| Inicio sin autorización | Se interpreta el cierre de PG-0 o la preparación del plan como permiso | PG-0 ya cerrada; registrar autorización nueva antes de editar corpus/motor |
| Prosa fuera del hash | Cambiar resumen no altera exportación/ancla | Texto editorial dentro del recurso contractual; test de cambio de hash |
| Inyección de marcado | Identificador o ficha activa enlace/HTML | Subconjunto cerrado y negativos por renderizador |
| Tamaño/latencia | Catálogo duplica firmas o encarece arranque | Generación compartida, bytes y frío/caliente separados; sin crear caché de fases futuras |
| Estado duplicado en app | Otro búfer o revisión independiente del editor | Un dueño del texto, puerto pequeño y rechazo de resultados caducos |
| Evidencia incompleta | Se declara app cubierta usando un doble | FFI real, widgets y matrices separados; límite físico declarado |

## 9. Dependencias de la persona

Para implementar: dependencia PG-0 ya satisfecha, revisión de este plan y autorización explícita en mensaje nuevo
(`PG-H.C01/C02`, `PHASE-STOP`). Este documento no vuelve a pedir aprobación conceptual de ADR-13.
La revisión independiente requerida por los contratos debe existir y registrarse de verdad, sin
rellenar revisores automáticamente. Si la revisión la realiza la persona, requiere su intervención.

Una discrepancia con un contrato, cambio de alcance o alteración de un criterio aprobado exige
`CONFLICT-REPORT` antes del trabajo dependiente. Las métricas candidatas requieren aprobación para
convertirse en contratos oficiales. No se solicitan cuentas ni publicación externa para PG-H.
Dispositivos físicos son evidencia complementaria; registrar su ausencia sin afirmar cobertura física.
E-PG-11 automatizable, puente real y verificadores siguen siendo obligatorios.

## 10. Orden de ejecución y puntos de control

1. Puerta previa: comprobar cierre efectivo de PG-0 y registrar revisión/autorización nueva.
   El cierre de PG-0 consta en la revisión de preparación; preparar este plan no inicia PG-H.
2. Contratos primero: especificar catálogo/consulta/resolución/render, escenarios APP/LSP e invariantes
   de cobertura/ejemplos. Derivar casos y revisión independiente; conservar 2026, estados y versiones.
   Nuevas identidades estables 1.0.0 sin `cambio`; no cambiar CF-12 ni reabrir versionado.
3. PG-H.01/04/05/06/07: tests antes de implementación SEE y autoría de fichas. Verificar cobertura,
   negativos, anclajes y exportación antes de consumir sus datos en el motor.
4. PG-H.02/03/08/11: tests antes de resolutor, API y render LSP; confirmar paridad y ausencia de
   regresiones de símbolos/navegación. Actualizar README en el mismo cambio de cada decisión.
5. PG-H.09/10/11: pruebas de puerto/estado/widgets antes de integrar app, luego FFI real y auditoría
   de fuente única. Regenerar únicamente artefactos cuyo dueño cambió y verificar frescura.
6. PG-H.12: cerrar dataset y protocolo, ejecutar E-PG-11, tamaños y puertas completas de miembros.
   Toda falla conserva evidencia; no se avanza al cierre mientras falte una puerta obligatoria.
7. Completar resumen por tarea y trasladar al plan general solo puntos con evidencia. Aplicar skill
   `commit-message` al escribir el commit de implementación; push ordinario comprobado a la rama única,
   sin atribución de IA. No crear rama ni worktree con rama adicional.
8. Informar implementación, pruebas, verificadores y pendientes; detenerse (`PHASE-STOP`).
   El cierre de PG-H no autoriza PG-1, PG-6A ni PG-A.

### Dependencias y evidencia entre bloques

| Bloque | Depende de | Evidencia antes de continuar |
|---|---|---|
| Contratos de los doce puntos | Autorización y revisión del plan | Reglas, casos derivados y revisión independiente real; parámetros de render y protocolo concretados |
| Datos y validación: .01/.04/.05/.06/.07 | Contratos y tests propios | Catálogo íntegro, migración trazada, ejemplos correctos, negativos y exportación en verde |
| Servicio y API: .02/.03/.08/.11 | Exportación verificada y contratos de consulta/render | Resolución, revisión, coordenadas, proyecciones LSP y regresiones en verde |
| App y consumidores: .09/.10/.11 | Consulta pública operativa y catálogo verificado | Widgets, arquitectura, accesibilidad y transporte real en verde |
| Experimento: .12 | Integración completa y dataset congelado | Manifiesto, crudos, resumen reproducible, tamaños y puertas integrales |
| Cierre común | Doce puntos con evidencia exigida | Resúmenes sincronizados, commit/push comprobados e informe de cierre |

Las referencias abreviadas `.nn` son puntos `PG-H.nn`. Los contratos se preparan primero para todos
los bloques; la secuencia no autoriza programar un bloque antes de sus casos y tests. No se requiere
un mensaje de aprobación entre estos bloques internos: la parada de fase se produce al cerrar PG-H,
salvo un conflicto de fuentes o cambio de alcance que active `CONFLICT-REPORT`.

### Cierre común

- [ ] `PG-H.C01` Autorización de implementación registrada en mensaje nuevo, tras cierre de PG-0.
- [ ] `PG-H.C02` Plan preparado y revisado por la persona.
- [ ] `PG-H.C03` SPEC-FIRST, oráculos independientes y congelamiento respetados.
- [ ] `PG-H.C04` Reglas con casos/propiedades y vínculos regla–código en conformidad.
- [ ] `PG-H.C05` Camino feliz, infeliz y límites en tests espejo.
- [ ] `PG-H.C06` Capas/imports/límites declarados y verificados.
- [ ] `PG-H.C07` Código inglés sin comentarios/TODO/pánicos ni unsafe ajeno.
- [ ] `PG-H.C08` README y reglas actualizados en el mismo cambio, sin referencias a docs/.
- [ ] `PG-H.C09` Catálogo 2026 completo; registrar que la fase no incorpora sintaxis nueva.
- [ ] `PG-H.C10` K-16/17 revisados y E-PG-11 con procedencia y resultados.
- [ ] `PG-H.C11` Todas las puertas de miembros afectados en verde.
- [ ] `PG-H.C12` Commit conforme a skill y push ordinario comprobado a la rama única.
- [ ] `PG-H.C13` Resumen completo, informe y parada hasta autorización nueva.

## 11. Resumen de ejecución

`PG-H.01` quedó completo: el contrato estable `1.0.0` tiene revisión humana registrada, el anclaje se
refrescó y `see export --check` confirmó la exportación determinista. `PG-H.02` quedó completo tras
ejecutar sus casos: `API.MODEL` produjo 7 observaciones y `API.VERSIONING` 2, sin divergencias.
`PG-H.03` quedó completo con las reglas `TOOL.SERVICE.HOVER` R4 y `API.MODEL` R5, 24 y 11
observaciones SEE sin divergencias, matriz bilingüe de servicio y regresiones.

`PG-H.04` quedó completo con 47 identidades de keyword, 17 de operador, 18 incorporadas y 38 roles
pedagógicos; la matriz validada contiene 143 filas identidad/rol, todas asignadas a una ficha o
exclusión válida. No se necesitó excluir elementos del inventario activo. Se registró R4 como prueba
estructural en el sujeto `service`. La prueba de matriz incluye conteos por categoría, alias, unicidad
de rol, ausencia de ficha, exclusión válida/abusiva y traducción faltante.

`see validate` pasó (159 especificaciones), `see lock --check` confirmó el anclaje y `see export --check`
confirmó la salida generada. `cargo xtask verify` terminó en verde: formato, Clippy, tests del workspace,
`cargo deny`, verificadores Rust y de cadena, 30 propiedades del motor sin pendientes y 1 563
observaciones sin divergencias. Las propiedades del sujeto `service` produjeron 7 resultados sin
pendientes; su conformidad integral produjo 110 observaciones sin divergencias. PG-H permanece abierta;
`.05`–`.12` y el cierre común siguen pendientes.

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| PG-H.01.01 | Cumplido | `TOOL.SERVICE.CATALOG` R1–R3 y `schemas/help-catalog-1.schema.json` | Identidad/papel, disponibilidad, anclajes, idiomas, ejemplos y exclusiones; sin dependencia de `docs/`. |
| PG-H.01.02 | Cumplido | `crates/see_validation/tests/resources/help_catalog.rs` | Casos completos, mínimos, vacíos, duplicados, traducciones y disponibilidad inválidas. |
| PG-H.01.03 | Cumplido | Tests `see_model`, `see_format`, `see_validation`, `see_export` | Preservación, carga, validación de referencias, exportación determinista y contenido editorial. |
| PG-H.01.04 | Cumplido | `crates/see_validation/src/resources/help_catalog/`; `crates/see_change/tests/locking.rs`; `crates/see_export/tests/resources.rs`; `specifications/cases/catalogs.json` | Esquema, validador, exportación del recurso y hash sensible a la prosa de `valor`. |
| PG-H.01.05 | Cumplido | README de `pseudolearn_spec`, `see_model`, `see_format`, `see_validation`, `see_export`, `see_change` y `pseudolearn_service` | Dueño, formato, referencias, hash y pendiente del consumidor documentados. |
| PG-H.01.06 | Cumplido | `see validate` (159 especificaciones), `see lock --refresh TOOL.SERVICE.CATALOG`, `see export --check` | Revisión humana registrada; anclaje refrescado y exportación reproducible. `cargo xtask verify` alcanzó `cargo deny`, que requiere una actualización remota no disponible en este entorno; la comprobación con base local y `--offline` pasó. |
| PG-H.02.01 | Cumplido | `API.MODEL` R3–R4; `API.VERSIONING` R1–R2 | Operación, capacidad, ciclo de recurso, coordenadas, detalle, idioma, revisión y errores; versiones y estados congelados. |
| PG-H.02.02 | Cumplido | `API.MODEL` C3–C9; `API.VERSIONING` C3–C4 | Vigente, revisión obsoleta, recurso liberado/de tipo incorrecto, posiciones/unidades inválidas, paridad de idiomas, revisión `u64::MAX`, desbordamiento/formato no canónico y negociación. |
| PG-H.02.03 | Cumplido | Casos SEE de `api`; `see_conformance` y adaptador `pseudolearn_conformance` | Casos de serialización, secuencias de recursos vivos, consulta sin cambios, cierre, revisión y negociación ejecutados sin divergencias. |
| PG-H.02.04 | Cumplido | `pseudolearn_api::{service_help, service_operations, versioning}`; `pseudolearn_conformance`; `see_conformance` | DTO y operación sobre hover del servicio, capacidad `service_help`, secuencias API y referencias a recursos; sin índices CST. |
| PG-H.02.05 | Cumplido | README de `pseudolearn_api`, `pseudolearn_engine`, `pseudolearn_spec` y `see_conformance` | Contrato público, vigencia, errores, formato de casos y límites documentados. |
| PG-H.02.06 | Cumplido | `see conform --subject engine --only API.MODEL` (7 observaciones); `see conform --subject engine --only API.VERSIONING` (2); tests y verificadores de ambos workspaces | Cierre/liberación, revisión obsoleta, límites de posición y enteros, listado de operaciones y negociación pasaron sin divergencias. `cargo deny --offline check` pasó en ambos miembros. |
| PG-H.03.01 | Cumplido | `TOOL.SERVICE.HOVER` R4; `API.MODEL` R5 | Selección, límites, compuestos, prioridad semántica, recuperación parcial y rangos originales. |
| PG-H.03.02 | Cumplido | `TOOL.SERVICE.HOVER` C5–C14; `API.MODEL` C10–C13 | Componentes compuestos, espacios/tabuladores, roles, alias, operadores, literales, trivia, EOF, truncamiento y sombreado. |
| PG-H.03.03 | Cumplido | `pseudolearn_service/tests/help_resolution.rs`, `positions.rs`; `pseudolearn_api/tests/service_help.rs` | Resolución y conversiones de ida y vuelta con Unicode, UTF-16 y CRLF; negativos y límites. |
| PG-H.03.04 | Cumplido | `pseudolearn_service/src/help_resolution.rs` y submódulos | Resolver desde CST y semántica, certeza parcial y rangos completos; sin cambios al lexer ni inferencia por texto vecino. |
| PG-H.03.05 | Cumplido | README de `pseudolearn_service`, `pseudolearn_api` y `pseudolearn_conformance` | Prioridades, rangos, respuesta pública y proyección documentados; `pseudolearn_source` no requirió cambios. |
| PG-H.03.06 | Cumplido | `see conform --subject service --only TOOL.SERVICE.HOVER` (24); `see conform --subject engine --only API.MODEL` (11); `cargo xtask verify` hasta cargo-deny; `cargo deny --offline check` | Sin divergencias; español/inglés × estricto/flexible y regresiones de hover, navegación y completado en verde. El chequeo normal no adquirió el lock global de la base de avisos. |
| PG-H.04.01 | Cumplido | `TOOL.SERVICE.CATALOG` R4; `coverage_inventory.rs`; `coverage.rs` | Palabras reservadas desde vocabulario, operadores desde gramática, incorporadas desde biblioteca y 38 roles declarados como inventario pedagógico. |
| PG-H.04.02 | Cumplido | `tests/resources/help_catalog/coverage.rs`; `resources/help_catalog/shape.rs` | Casos aceptan alias tipado y rechazan rol sin ficha, exclusión que cambia tokens, identidad fuera del inventario y traducción faltante. |
| PG-H.04.03 | Cumplido | `produces_complete_2026_identity_role_matrix`; `rejects_missing_token_translation_and_duplicate_role_identity` | Denominador: 47 keywords, 17 operadores, 18 incorporadas y 38 roles; 143 filas identidad/rol completas, con contenido es/en. |
| PG-H.04.04 | Cumplido | `TOOL.SERVICE.CATALOG` D1; `specifications/cases/catalogs.json` | Fichas bilingües usan identidades fuente; formas y firmas siguen generadas desde sus dueños. No hay exclusiones activas en 2026. |
| PG-H.04.05 | Cumplido | README de `pseudolearn_spec` y `see_validation` | Autoría editorial, revisión y mantenimiento del inventario documentados junto al paquete dueño. |
| PG-H.04.06 | Cumplido | `coverage_matrix`; `see validate` (159 especificaciones); `see conform --subject service` (110 observaciones, 0 divergencias) | Matriz identidad/rol → ficha con 143/143 destinos presentes; R4 estructural con anclaje vigente y sin fallback genérico como cobertura. |
| PG-H.05.01 | | | Pendiente de ejecución |
| PG-H.05.02 | | | Pendiente de ejecución |
| PG-H.05.03 | | | Pendiente de ejecución |
| PG-H.05.04 | | | Pendiente de ejecución |
| PG-H.05.05 | | | Pendiente de ejecución |
| PG-H.05.06 | | | Pendiente de ejecución |
| PG-H.06.01 | | | Pendiente de ejecución |
| PG-H.06.02 | | | Pendiente de ejecución |
| PG-H.06.03 | | | Pendiente de ejecución |
| PG-H.06.04 | | | Pendiente de ejecución |
| PG-H.06.05 | | | Pendiente de ejecución |
| PG-H.06.06 | | | Pendiente de ejecución |
| PG-H.07.01 | | | Pendiente de ejecución |
| PG-H.07.02 | | | Pendiente de ejecución |
| PG-H.07.03 | | | Pendiente de ejecución |
| PG-H.07.04 | | | Pendiente de ejecución |
| PG-H.07.05 | | | Pendiente de ejecución |
| PG-H.07.06 | | | Pendiente de ejecución |
| PG-H.08.01 | | | Pendiente de ejecución |
| PG-H.08.02 | | | Pendiente de ejecución |
| PG-H.08.03 | | | Pendiente de ejecución |
| PG-H.08.04 | | | Pendiente de ejecución |
| PG-H.08.05 | | | Pendiente de ejecución |
| PG-H.08.06 | | | Pendiente de ejecución |
| PG-H.09.01 | | | Pendiente de ejecución |
| PG-H.09.02 | | | Pendiente de ejecución |
| PG-H.09.03 | | | Pendiente de ejecución |
| PG-H.09.04 | | | Pendiente de ejecución |
| PG-H.09.05 | | | Pendiente de ejecución |
| PG-H.09.06 | | | Pendiente de ejecución |
| PG-H.10.01 | | | Pendiente de ejecución |
| PG-H.10.02 | | | Pendiente de ejecución |
| PG-H.10.03 | | | Pendiente de ejecución |
| PG-H.10.04 | | | Pendiente de ejecución |
| PG-H.10.05 | | | Pendiente de ejecución |
| PG-H.10.06 | | | Pendiente de ejecución |
| PG-H.11.01 | | | Pendiente de ejecución |
| PG-H.11.02 | | | Pendiente de ejecución |
| PG-H.11.03 | | | Pendiente de ejecución |
| PG-H.11.04 | | | Pendiente de ejecución |
| PG-H.11.05 | | | Pendiente de ejecución |
| PG-H.11.06 | | | Pendiente de ejecución |
| PG-H.12.01 | | | Pendiente de ejecución |
| PG-H.12.02 | | | Pendiente de ejecución |
| PG-H.12.03 | | | Pendiente de ejecución |
| PG-H.12.04 | | | Pendiente de ejecución |
| PG-H.12.05 | | | Pendiente de ejecución |
| PG-H.12.06 | | | Pendiente de ejecución |
| PG-H.C01 | Cumplido | Mensaje nuevo de ejecución del 2026-10-22 | Autoriza la implementación de `PG-H.04`; no autoriza `.05` ni el cierre de PG-H. |
| PG-H.C02 | | | Pendiente de ejecución |
| PG-H.C03 | | | Pendiente de ejecución |
| PG-H.C04 | | | Pendiente de ejecución |
| PG-H.C05 | | | Pendiente de ejecución |
| PG-H.C06 | | | Pendiente de ejecución |
| PG-H.C07 | | | Pendiente de ejecución |
| PG-H.C08 | | | Pendiente de ejecución |
| PG-H.C09 | | | Pendiente de ejecución |
| PG-H.C10 | | | Pendiente de ejecución |
| PG-H.C11 | | | Pendiente de ejecución |
| PG-H.C12 | | | Pendiente de ejecución |
| PG-H.C13 | | | Pendiente de ejecución |

PG-H no se cierra ni publica con este punto. Para `PG-H.01`, las pruebas dirigidas, Clippy, formato,
`rust-checks all .`, validación, refresco del anclaje y comprobación de exportación están en verde.
`cargo xtask verify` de `.01` queda parcialmente limitado por la actualización remota de `cargo deny`; su
modo `--offline` pasó. Para `.02`, los casos API, las pruebas y las verificaciones de ambos miembros
están en verde; el chequeo offline de `cargo deny` pasó con su lock temporal disponible. Para `.03`,
`rust-checks all .`, `see validate`, conformidad, las pruebas del workspace, Clippy, formato y
`cargo deny check` están en verde. `PG-H.C02` conserva pendiente la revisión integral del plan.
Las seis subtareas de `.01`–`.04` están cumplidas; `.05`–`.12` siguen pendientes y PG-H
permanece abierta.

Comprobaciones de preparación documental del 2026-10-22: `git diff --check` en verde;
72 subtareas únicas, 13 puntos de cierre y sus 85 filas de resumen comprobados; enlaces locales
resueltos. La puerta existente `xtask/src/documentation.rs::check` de spec se ejecutó desde un
lanzador temporal sobre el repositorio y pasó `DOC-NO-TRANSIENT-REFS`. Estas comprobaciones
validan el documento; no son evidencia de implementación ni cierran `PG-H.C11`.
