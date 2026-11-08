# Agente de IA integrado, ejercicios del usuario y créditos — plan de ejecución

## 0. Metadatos y contrato de ejecución

- Fecha: 2026-11-08, America/Lima. HEAD al redactar: `c7b283d7e762648267742769306646a18cba589c`. Rama:
  `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`). Árbol limpio.
- Petición: integrar en `apps/pseudolearn_app` un agente de IA que explique, escriba código verificado y opere la app
  mediante casos de uso, con contexto de la pantalla actual y conocimiento de cómo funciona la app; un botón flotante
  con glifo propio que despliega un chat; ejercicios creados por el usuario; monetización por créditos con prueba
  gratuita, **simulada pero lista para integrar**; el agente **listo para recibir la clave del proveedor**, que pone
  el propietario en el servidor. El usuario final nunca introduce una clave.
- Referencia de diseño: el agente Maestro de `~/Personal/traceiron` (app Apple, proxy `maestro-api-typescript`), en
  producción con `gpt-6-luna`. Se reutilizan su ciclo de herramientas, sus confirmaciones, su fórmula de créditos y su
  política de proxy. **No** se reutiliza su identidad por StoreKit: PseudoLearn tiene cuentas de Supabase y se
  distribuye en iOS, macOS y Windows.
- Documento transitorio: ningún README, especificación ni código fuera de `docs/` lo cita (`DOC-NO-TRANSIENT-REFS`).
  Cada decisión se traslada a su dueño en el mismo cambio (`DOC-README-TRUTH`, `DOC-NO-ORPHAN-DECISION`).

### 0.1 Reglas para quien ejecute

1. Antes de tocar un miembro, releer `AGENTS.md`, su README y su archivo de reglas (`architecture.yaml` en la app,
   `architecture.json` en el backend y en VS Code), y comprobar rama, HEAD y diff.
2. Por punto: README (decisión) → tests que detectan la ausencia → código → verificación. En Rust y en el corpus rige
   `SPEC-FIRST` (especificación → casos → tests → código).
3. Cero comentarios en código, identificadores y mensajes de commit en inglés, documentación en español.
4. Nada de formateadores masivos ni reescrituras JSON de ida y vuelta: ediciones quirúrgicas.
5. Toda pieza con camino feliz, camino infeliz y límites (`TEST-BOTH-PATHS`); tests espejo de `lib/` (`TEST-MIRROR`).
6. Una contradicción entre fuentes se reporta y se espera respuesta (`CONFLICT-REPORT`).
7. Al cerrar cada fase: verificadores del miembro en verde, informe, commit con la skill `commit-message`, push
   ordinario y **parada** hasta autorización nueva (`PHASE-GREEN`, `PHASE-STOP`).
8. Ningún secreto en el repositorio. Ninguna llamada real al proveedor en tests: se usan puertos falsos.

## 1. Alcance

**Dentro:** casos de uso de escritura y aviso de cambios; ejercicios del usuario (manual y por agente); ficha del
lenguaje generada y manual de la app; proxy del modelo y libro de créditos en Supabase; agente con herramientas,
contexto de pantalla y verificación con el motor; glifo, botón flotante y chat; oferta, prueba, consentimiento y
compras simuladas; `llms.txt`, servidor MCP de la CLI y registro en VS Code; benchmark del agente.

**Fuera (`SCOPE-YAGNI`):** compartir ejercicios entre usuarios o docentes; imágenes en la narrativa; argumentos de
programa en los casos de un ejercicio (`ExerciseCase` no los tiene); ajuste fino de un modelo propio; decodificación
restringida por gramática; adaptadores de compra reales (quedan declarados como pendientes, §8); voz.

## 2. Decisiones

| ID | Decisión | Por qué |
|---|---|---|
| D-01 | Nombre provisional del agente: **Nodo**, siempre acompañado de la etiqueta «IA» en la interfaz («Nodo · IA»). Vive solo en las cadenas l10n (`agentName`), nunca en código. Confirmación en AG-0. | Sale del nodo terminal del símbolo de la marca; la etiqueta hace explícito que es una IA, importante con estudiantes. |
| D-02 | Glifo «nodo con destello»: círculo terminal con dos ojos mínimos, conector en ángulo recto y destello de cuatro puntas. No es una mascota animada ni un personaje: un glifo con estados (reposo, pensando, respuesta nueva, sin créditos). | El destello dice «IA»; el nodo y el conector dicen «PseudoLearn». |
| D-03 | **Paridad:** el agente no tiene ninguna capacidad que la interfaz no ofrezca. Toda herramienta de escritura llama al mismo caso de uso que la acción manual. | Lo que solo hace el agente no se puede corregir a mano ni probar. |
| D-04 | Los comandos y consultas de negocio viven en `application/<feature>/use_cases/` como clases puras con un método público `call`. El Cubit orquesta el estado de la vista y llama a casos de uso. Se extraen **solo** los que necesita una herramienta o una pantalla nueva de este plan. El README de la app reescribe §4.1 y §3 en el mismo cambio. | El agente es el segundo cliente de la lógica; un Cubit solo existe con su pantalla montada. |
| D-05 | `DocumentRepository` expone `Stream<DocumentChange> changes()`, y el repositorio de ejercicios del usuario hace lo mismo. Los Cubits de biblioteca y editor se suscriben. | Sin este aviso, lo que escribe el agente o la sincronización no se ve hasta recargar. |
| D-06 | Las herramientas son datos: un archivo por herramienta en `application/agent/tools/`, con nombre, esquema JSON, nivel de riesgo (`read`, `write`, `destructive`), política de confirmación y clave l10n de su paso visible. Un registro las compone en `composition/`. Añadir una herramienta no modifica el bucle. | Abierto/cerrado; mismo patrón que la caja de herramientas de Maestro. |
| D-07 | Contexto de pantalla: puerto `ScreenContextSource` con un proveedor por pantalla que publica un `ScreenContextSnapshot` mínimo (§6). El texto completo se pide con la herramienta `get_screen_context`. Solo se lee al enviar un mensaje. | Precisión sin pagar tokens de más; privacidad. |
| D-08 | El bucle del agente corre **en el cliente**: el modelo responde con llamadas a herramientas y la app las ejecuta localmente (motor por el puente Rust, repositorios locales). Límite de 14 llamadas al modelo por turno. | El motor y los datos están en el dispositivo; el servidor solo media el modelo y cobra. |
| D-09 | Proveedor del modelo detrás de un proxy propio: Edge Function `agent-responses` en `apps/pseudolearn_backend`, que reenvía el cuerpo de la Responses API de OpenAI. El modelo lo fija el servidor (`AGENT_MODEL`, por defecto `gpt-6-luna`), con `store: false`, salida ≤ 4 000 tokens y sin esfuerzo de razonamiento alto. La clave es el secreto `OPENAI_API_KEY`. Sin clave: 503 `model_unconfigured`. El cliente no elige modelo ni herramientas con coste propio. | Mismas garantías que Maestro: la app nunca tiene la clave. |
| D-10 | Identidad: el JWT de la sesión de Supabase. El agente exige cuenta iniciada; sin cuenta se muestra la oferta con «Inicia sesión». | Hay tres plataformas y una sola identidad común. |
| D-11 | Créditos: libro en Postgres por `auth.users.id`, débito atómico por RPC `security definer` y lectura con RLS. Fórmula de Maestro: `ceil((1,25 × entrada sin caché + 0,1 × entrada en caché + 5 × salida) / 10 000)` en milicréditos, según el `usage` real. Si el modelo falla, no se descuenta. Tope de 15 créditos por petición del usuario y 60 llamadas por minuto. Cifras de §7, provisionales. | Probado en producción y entendible para el usuario. |
| D-12 | Compras: puerto de servidor `PurchaseVerifier` con un adaptador por tienda, y puerto de cliente `PurchaseStore`. En este plan solo existe el adaptador **simulado** en ambos lados, activo únicamente con `AGENT_PURCHASES=simulated`. En producción el valor por defecto es `disabled`, nunca `simulated`. | Listo para integrar sin regalar créditos por error. |
| D-13 | Conocimiento del lenguaje: una **ficha para agentes** (`es` y `en`) generada desde la exportación SEE (vocabulario, gramática resumida, firmas de biblioteca, diferencias con PSeInt y ejemplos canónicos del corpus que se ejecutan al generar). Se versiona solo donde un build la consume: assets de la app y `llms.txt` de la web (`GEN-NO-HAND-COPY`). | Los modelos conocen PSeInt y no PseudoLearn; los falsos amigos (base cero, `;`, `Con Paso`, parámetros tipados) se corrigen con contexto. |
| D-14 | Conocimiento de la app: **manual de usuario** bilingüe en `apps/pseudolearn_app/assets/manual/{es,en}/`, una entrada por funcionalidad con id estable y la `Key` del widget que la ancla. Un verificador exige correspondencia en ambos sentidos y tiene caso negativo. El README técnico **no** se usa como conocimiento del agente. | Respuestas correctas como «¿para qué sirve el campo de argumentos?». |
| D-15 | Recuperación local por palabras clave (sin embeddings) sobre el manual, el libro de referencia y los casos del corpus, con la herramienta `search_knowledge`. | Suficiente para empezar; no añade servicios. |
| D-16 | Código verificado: todo bloque de código PseudoLearn de una respuesta pasa por `ProgramAnalyzer` antes de mostrarse. La interfaz lo marca como «Verificado» o «Con errores», y solo el verificado ofrece «Insertar en el editor». La extracción de bloques es un adaptador de `data/`, porque `application` no puede usar `RegExp`. El prompt exige usar `check_program` antes de responder con código y generar en el perfil del documento, o en `es` y luego traducir con la herramienta de traducción. | El analizador es el oráculo; nunca se enseña código inválido. |
| D-17 | **Modo tutor** en ejercicios de la ruta y del usuario: pistas graduadas con las `hints` existentes, sin la solución. Solo la revela tras tres intentos fallidos y una petición explícita. El progreso registra `assisted: true`, y el panel de progreso lo distingue. | La app enseña; las métricas no deben mentir. |
| D-18 | Ejercicio del usuario = misma forma que un ejercicio `solve` de la ruta: título, narrativa en texto, enunciado, restricciones, pistas, `CasesEvaluation` (casos visibles, ocultos y aserciones estructurales) y solución de referencia obligatoria. Se publica solo si la solución de referencia pasa todos los casos con `ExerciseChecker`. Los intentos son documentos con `exerciseId` prefijado (`route:` o `user:`). | Reutiliza el modelo, el evaluador y la pantalla de ejercicio. |
| D-19 | Interfaz común `ExerciseContent` consumida por la pantalla y el evaluador. `RouteExercise` y `UserExercise` la implementan. | Es el mismo concepto dicho dos veces; duplicación real. |
| D-20 | Consentimiento previo al primer mensaje: nombra a OpenAI, qué se envía (mensajes, código, contexto de pantalla, progreso resumido) y la retención. Se puede retirar en Ajustes → Nodo. Sin red: estado «Necesita conexión», sin cobrar. | Guía 5.1.2(i) y uso por menores. |
| D-21 | El glifo choca con `fundamentos-visuales.md` §6.2 (destello relleno y curvo). Por defecto se documenta allí una **excepción acotada** para este glifo, como la de los glifos de severidad. La persona lo confirma en AG-0. | `CONFLICT-REPORT`: la decisión es de la persona. |
| D-22 | El comportamiento del agente en la app se documenta en el README de la app. El corpus solo se toca para el subcomando `pseudo mcp` (§4, AG-9), que es una herramienta del núcleo. | `SPEC-BEHAVIOR-TRUTH` cubre el núcleo; la salida de un modelo no es determinista. |
| D-23 | Los textos visibles del agente pasan por l10n (`es` y `en`). El prompt del sistema vive en assets por idioma, no en código Dart. | Literales para personas solo en su capa. |

## 3. Arquitectura objetivo

**App (`apps/pseudolearn_app/lib/`).** Respeta las capas de `architecture.yaml`. `presentation` no importa
`ports`, así que la navegación del agente es un puerto implementado en `composition/`.

```text
domain/model/agent/        AgentMessage, ToolCall, ToolResult, ToolRisk, ScreenContextSnapshot, AgentTurnStep
domain/model/credits/      CreditBalance, CreditFailure (subscriptionRequired, creditsExhausted, requestCap, rateLimited,
                           modelUnconfigured, offline, upstream), Entitlement, TrialState
domain/model/exercises/    UserExercise, ExerciseContent, UserExerciseDraft, ExercisePublication
domain/ports/              AgentModelGateway, CreditsGateway, PurchaseStore, ScreenContextSource, KnowledgeIndex,
                           ReplyCodeBlockReader, AppNavigator, UserExerciseRepository, AgentConsentStore
application/<feature>/use_cases/   CreateDocument, RenameDocument, DeleteDocument, SaveDocumentSource,
                           SetExecutionArguments, CreateUserExercise, UpdateUserExercise, DeleteUserExercise,
                           ValidateUserExercise, RunProgram, CheckProgram, TranslateProgram, FormatProgram
application/agent/         AgentSessionCubit, AgentLoop, ToolRegistry, ConfirmationPolicy, PromptAssembler,
                           tools/<tool>.dart (uno por herramienta)
application/credits/       CreditsCubit, PurchaseCubit
data/agent/                ProxyAgentModelGateway (HTTP), FakeAgentModelGateway, MarkdownCodeBlockReader,
                           AssetKnowledgeIndex
data/credits/              ProxyCreditsGateway, SimulatedPurchaseStore
data/exercises/            SqfliteUserExerciseRepository, SyncingUserExerciseRepository
presentation/agent/        AgentLauncher (botón flotante), AgentGlyph (geometría), AgentChatSheet, AgentComposer,
                           AgentConfirmationBar, AgentStepList, VerifiedCodeBlock, AgentOfferView, AgentConsentView,
                           AgentCreditsPanel
presentation/exercises/    UserExerciseEditor (crear y editar), lista en Biblioteca
composition/               registro de herramientas, GoRouterAppNavigator, selección Fake/Proxy por dart-define
```

**Backend (`apps/pseudolearn_backend/supabase/`).** Capas `domain → application → infrastructure → http` y
límite de 120 líneas por archivo.

```text
functions/agent-responses/   domain: créditos, política del cuerpo, errores · application: AgentService ·
                             infrastructure: openai_responses, postgres_ledger · http: router y sobre de errores
functions/agent-credits/     GET saldo · POST /purchases (PurchaseVerifier: simulated | disabled)
migrations/<fecha>_agent_credits.sql   agent_ledger_periods, agent_ledger_top_ups, agent_ledger_events,
                             RPC agent_authorize, agent_debit, agent_grant_purchase (idempotente por transacción), RLS
migrations/<fecha>_user_exercises_sync.sql   user_exercises + push_user_exercises, mismo patrón que documents
```

Errores del proxy: `{"error": {"code", "retryable", "requestId", "detail"?}}` con los códigos de Maestro más
`unauthenticated` (401) y `model_unconfigured` (503). Saldo en las cabeceras `X-PseudoLearn-Credits-{Remaining,
Allowance,Top-Up,Renews-At,Trial}`.

## 4. Fases

Cada fase cierra con los verificadores del miembro: en la app, `flutter test`, el test de arquitectura, el script de
límites y la compilación de la biblioteca nativa; en el backend, `deno task verify`; en Rust, `cargo xtask verify`;
en la web, `pnpm check:all`; en VS Code, `pnpm check:types`, los verificadores, `pnpm test` y `pnpm build`.

**AG-0 · Línea base y decisiones abiertas.** Ejecutar todos los verificadores y registrar los resultados en §9.
Preguntar a la persona: nombre (D-01), excepción del glifo (D-21), edad mínima de los usuarios, cifras de §7.
Sin código. Cierre: respuestas registradas en §2 y §10.

**AG-1 · Casos de uso y aviso de cambios.**
1. Extraer de `LibraryCubit` y `EditorCubit` los casos de uso de escritura listados en §3 (validación de título, id,
   reloj y guardado incluidos). Los Cubits pasan a llamarlos sin cambiar su comportamiento.
2. Añadir `changes()` a `DocumentRepository` y a sus adaptadores (local y con sincronización, que emite también al
   aplicar cambios remotos). `LibraryCubit` y `EditorCubit` se suscriben y cancelan al cerrarse.
3. Casos de uso de solo lectura que consume el agente: `ListDocuments`, `LoadDocument`, `CheckProgram`, `RunProgram`
   (con los límites de sentencias, profundidad y celdas), `TranslateProgram`, `FormatProgram`.
4. README de la app: reescribir §3 y §4.1 (el caso de uso es la unidad de negocio y el Cubit orquesta la vista), con
   las alternativas descartadas (llamar a los Cubits, llamar a los repositorios).
Cierre: los tests de los Cubits existentes siguen en verde sin cambios de aserción; tests nuevos por caso de uso.

**AG-2 · Ejercicios del usuario (manual).**
1. Modelo `UserExercise` e interfaz `ExerciseContent` (D-18, D-19); `RouteExercise` la implementa sin cambiar su
   origen.
2. Puerto y adaptadores (sqflite, sincronización, migración `user_exercises` con RLS y `push_user_exercises`).
   Prefijos `route:` y `user:` en `exerciseId`, con migración de los ids existentes a `route:`.
3. Casos de uso de crear, actualizar, borrar y validar. Validar ejecuta la solución de referencia con
   `ExerciseChecker` contra todos los casos y devuelve qué caso falla.
4. Interfaz: en Biblioteca, «Nuevo ejercicio» y la sección «Mis ejercicios»; editor con narrativa, enunciado,
   restricciones, pistas, casos visibles y ocultos, aserciones y solución de referencia; publicar solo si valida. La
   pantalla de ejercicio existente resuelve ambos orígenes; ruta nueva `/biblioteca/ejercicio/:id`.
5. README de la app y del backend actualizados; l10n `es` y `en`.
Cierre: crear, resolver y borrar un ejercicio manualmente; tests de validación con solución fallida, casos vacíos y
narrativa vacía.

**AG-3 · Conocimiento.**
1. Ficha para agentes (D-13): nuevo destino de `see export` en `packages/pseudolearn_spec`, con `--check` y caso
   negativo. Cada ejemplo de la ficha se ejecuta al generar y la sección «Diferencias con PSeInt» se deriva de
   reglas con id. README de SEE actualizado.
2. Manual de la app (D-14): una entrada por funcionalidad visible, incluida «Opciones de ejecución» (argumentos,
   repetir la última cinta, carpeta de archivos), y verificador `tool/check_manual.dart` con casos negativos (entrada
   huérfana y funcionalidad sin entrada).
3. `AssetKnowledgeIndex` sobre el manual, el libro de referencia empaquetado y los casos del corpus exportados, con
   puntuación por palabras clave y resultados que citan el id de la sección o entrada.
Cierre: `see export --check` y el verificador del manual en verde; tests de recuperación con consulta vacía, sin
resultados e idioma cruzado.

**AG-4 · Backend: proxy y créditos simulados.**
1. Migración del libro y RPC atómicas (D-11): periodo mensual, prueba y recargas que no caducan y se gastan después
   del plan; idempotencia por `requestId` y por transacción.
2. `agent-responses`: valida el JWT, autoriza el saldo, sanea el cuerpo (modelo del servidor, `store: false`, tope de
   salida, sin herramientas con coste propio), llama a OpenAI, debita según `usage` y devuelve las cabeceras de saldo.
   No registra contenido: solo evento, estado, código y duración.
3. `agent-credits`: saldo y `POST /purchases` con `PurchaseVerifier` simulado (otorga el producto pedido: `trial`,
   `monthly` o `top_up`), activo solo con `AGENT_PURCHASES=simulated`.
4. Tests con `fake_ports` y `fake_fetcher`: sin clave, JWT inválido, sin saldo, tope por petición, fallo del
   proveedor sin débito, compra repetida y compra simulada con el adaptador desactivado.
5. README del backend: endpoints, secretos (`OPENAI_API_KEY`, `AGENT_MODEL`, `AGENT_PURCHASES`), entornos y la guía
   de §8.
Cierre: `deno task verify` en verde y `supabase functions serve` local respondiendo `model_unconfigured` sin clave.

**AG-5 · Núcleo del agente.**
1. `AgentModelGateway` con dos adaptadores: `ProxyAgentModelGateway` (Responses API vía el proxy, el JWT y el id de
   petición) y `FakeAgentModelGateway` (respuestas guionizadas para tests y demo). Se eligen con
   `--dart-define=AGENT_BACKEND=fake|proxy` y `AGENT_PROXY_URL`.
2. `AgentLoop`: historial, llamadas a herramientas, máximo de 14 ciclos, suspensión a la espera de confirmación, y un
   rechazo que no se reintenta en el mismo turno.
3. `PromptAssembler`: prompt del sistema desde assets por idioma, ficha del lenguaje (bloque estable primero para el
   caché), resumen del manual, contexto de pantalla y reglas de D-16 y D-17.
4. Proveedores de contexto por pantalla (§6) y herramientas de lectura (§5).
5. `MarkdownCodeBlockReader` y verificación de bloques (D-16).
Cierre: tests del bucle con el gateway falso (herramienta desconocida, argumentos inválidos, límite de ciclos,
confirmación rechazada, error de créditos a mitad de turno).

**AG-6 · Herramientas de acción y modo tutor.** Herramientas de escritura de §5 sobre los casos de uso de AG-1 y AG-2,
confirmación para `destructive` y para reemplazar todo el contenido de un documento, `navigate` con `AppNavigator`, y
modo tutor (D-17) con `assisted` en el progreso local y sincronizado (migración si hace falta). Cierre: cada
herramienta probada con la interfaz reflejando el cambio vía `changes()`.

**AG-7 · Glifo, botón flotante y chat.**
1. `AgentGlyph` redibujado en Dart sobre la rejilla de 24, con trazo de 1,5 (1,25 a 16 px), uniones redondas y
   destello relleno según D-21. Tamaños: 24 dentro de un botón de 56 (compacto) o 48 (escritorio). Color `brand-600` y
   glifo en `text.onBrand`. Excepción documentada en `fundamentos-visuales.md`.
2. Estados animados con las duraciones y curvas existentes; con movimiento reducido no hay giro ni parpadeo.
3. `AgentLauncher` sobre el armazón (`presentation/shell/`), sin tapar la barra inferior ni el pie de ejecución del
   editor; se oculta en el onboarding.
4. Chat en hoja (compacto) o panel lateral (expandido): burbujas, Markdown, `VerifiedCodeBlock`, pasos desplegables,
   barra de confirmación, compositor y enlaces a secciones de la especificación y de la ruta. Accesibilidad:
   etiquetas semánticas, foco, contraste verificado y objetivos táctiles.
Cierre: tests de widgets con fakes, test de goldens del glifo en sus estados y verificadores de tokens en verde.

**AG-8 · Monetización en la app.** `CreditsCubit` (saldo desde las cabeceras y `GET`), `PurchaseCubit` con
`SimulatedPurchaseStore`, oferta (`AgentOfferView`, con prueba de 7 días), consentimiento (`AgentConsentView`), panel
de créditos en Ajustes → Nodo (restante, renovación, recarga, gasto de la última petición, retirar consentimiento),
panel de créditos agotados en lugar del compositor, y traducción de cada `CreditFailure` a un mensaje l10n. Cierre:
recorrido completo simulado (sin cuenta → oferta → prueba → conversación → agotado → recarga → conversación).

**AG-9 · Ecosistema externo.**
1. `apps/fe-pseudolearn`: publicar `llms.txt` y `llms-full.txt` desde el módulo generado de la ficha.
2. `pseudo mcp` en `apps/pseudolearn_cli`, con `SPEC-FIRST`: especificación `TOOL.MCP` en el corpus con reglas y casos
   (herramientas `check`, `run` con límites y sin capacidades por defecto, `format`, `translate`, `explain`,
   `search_reference`, `example`; la ficha como recurso). Después tests y código.
3. `apps/pseudolearn_vscode`: registrar el servidor MCP del binario incluido mediante el proveedor de definiciones de
   servidores MCP de la API de VS Code, y añadir una plantilla `AGENTS.md` y `.github/copilot-instructions.md` para
   proyectos del usuario.
Cierre: `see validate`, conformidad del nuevo subcomando y verificadores de la CLI, la web y VS Code en verde.

**AG-10 · Benchmark y revisión integral.** En `packages/pseudolearn_benchmarks`, un conjunto de unas 100 tareas tomadas
de ejercicios de la ruta, medido contra el gateway real solo cuando la persona lo autorice y con su clave: porcentaje
que compila a la primera y tras el bucle, con y sin ficha, con y sin recuperación, y créditos medios por petición.
Después, revisión integral contra §2, `grep` de cierre de referencias a este documento fuera de `docs/`, y
actualización final de README.

## 5. Catálogo de herramientas v1

| Herramienta | Caso de uso o puerto | Riesgo | Fase |
|---|---|---|---|
| `get_screen_context` | `ScreenContextSource` | read | AG-5 |
| `search_knowledge` | `KnowledgeIndex` | read | AG-5 |
| `list_documents`, `get_document` | `ListDocuments`, `LoadDocument` | read | AG-5 |
| `check_program` | `CheckProgram` | read | AG-5 |
| `run_program` (argumentos y entradas) | `RunProgram` | read | AG-5 |
| `translate_program`, `format_program` | `TranslateProgram`, `FormatProgram` | read | AG-5 |
| `get_route_progress`, `get_lesson`, `get_exercise` | repositorios de la ruta y del progreso | read | AG-5 |
| `explain_diagnostic` | `SyntaxHelpSource` | read | AG-5 |
| `create_document`, `rename_document` | `CreateDocument`, `RenameDocument` | write | AG-6 |
| `edit_document` (inserción o parche) | `SaveDocumentSource` | write | AG-6 |
| `replace_document_content` | `SaveDocumentSource` | destructive | AG-6 |
| `delete_document` | `DeleteDocument` | destructive | AG-6 |
| `set_execution_arguments` | `SetExecutionArguments` | write | AG-6 |
| `create_user_exercise`, `update_user_exercise` | `CreateUserExercise`, `UpdateUserExercise` (con validación) | write | AG-6 |
| `delete_user_exercise` | `DeleteUserExercise` | destructive | AG-6 |
| `give_hint`, `reveal_solution` | modo tutor (D-17) | read / write | AG-6 |
| `navigate` | `AppNavigator` | write | AG-6 |
| `set_theme`, `set_interface_language`, `set_profile` | casos de uso de ajustes | write | AG-6 |

## 6. Contexto por pantalla

| Pantalla (ruta) | Instantánea mínima | Bajo demanda |
|---|---|---|
| Especificación (`/conocimiento/especificacion/:id`) | id y título de la sección, fragmento visible | texto completo de la sección |
| Lección (`/conocimiento/ruta/:leccion`) | id, título, bloque visible | lección completa |
| Ejercicio (`…/:ejercicio`, `/biblioteca/ejercicio/:id`) | id, origen, tipo, intentos, pista actual, último veredicto | enunciado y casos visibles, nunca los ocultos |
| Editor (`/biblioteca/documento/:id`) | id, título, perfil, selección, diagnósticos, argumentos, última ejecución (estado, salida truncada, error) | fuente completa |
| Biblioteca, Progreso, Ajustes | nombre de la pantalla y filtros | listas resumidas |

Siempre se incluyen: idioma de interfaz, perfil por defecto, fecha y plataforma. Nunca se incluyen el correo ni los
tokens de sesión.

## 7. Créditos (provisionales, se confirman en AG-0)

| Concepto | Valor |
|---|---|
| Plan mensual | 300 créditos, sin acumulación |
| Prueba | 7 días, 40 créditos, una vez por cuenta |
| Recarga | 150 créditos, no caducan, se gastan después del plan |
| Tope | 15 créditos por petición del usuario; salida ≤ 4 000 tokens; 60 llamadas por minuto |
| Productos | `pseudolearn.plus.monthly`, `pseudolearn.plus.topup150` (ids provisionales) |

## 8. Puesta en producción (lo que hace el propietario después del plan)

1. `supabase secrets set OPENAI_API_KEY=<clave> AGENT_MODEL=gpt-6-luna AGENT_PURCHASES=disabled`.
2. `supabase db push` y `supabase functions deploy agent-responses agent-credits`.
3. Compilar la app con `--dart-define=AGENT_BACKEND=proxy` y `AGENT_PROXY_URL=<url de functions>`.
4. Para pruebas internas con compras simuladas, un proyecto de Supabase distinto con `AGENT_PURCHASES=simulated`.
5. Pendientes declarados en los README: adaptadores `PurchaseVerifier` reales (App Store Server API, Microsoft Store,
   Stripe para la descarga directa de macOS y Windows); dentro de iOS, la venta tiene que ser compra integrada.
   Notificaciones de reembolso. Segundo proveedor de modelo opcional.

## 9. Línea base (se completa en AG-0)

Ejecutada el 2026-11-08 sobre `d28fabd8`, antes de cualquier cambio.

| Miembro | Verificadores | Resultado |
|---|---|---|
| `apps/pseudolearn_app` | `flutter analyze --fatal-infos --fatal-warnings`, `tool/check_limits.dart`, `tool/check_design_system.dart`, `flutter test` | Verde: 2284 tests, 2 omitidos |
| `apps/pseudolearn_backend` | `deno task verify` | Verde: 71 tests |
| `packages/pseudolearn_spec` | `cargo xtask verify` | Verde: 3370 observaciones, 0 divergencias |
| `apps/pseudolearn_cli` | `cargo xtask verify` | Verde |
| `apps/fe-pseudolearn` | `pnpm check:all` | Verde |
| `apps/pseudolearn_vscode` | `pnpm check:types`, `pnpm test` | Verde |

### 9.1 Decisiones abiertas resueltas en AG-0

La persona pidió ejecutar todas las fases sin preguntas y con la opción recomendada en cada caso:

- D-01: nombre **Nodo** con la etiqueta «IA».
- D-21: excepción acotada del glifo documentada en `fundamentos-visuales.md`.
- Edad mínima: 13 años. El consentimiento se redacta para adolescentes; menores de 13 quedan fuera del agente.
- §7: cifras confirmadas tal como están.

## 10. Riesgos y preguntas abiertas

- Edad mínima de los usuarios: resuelta en AG-0 (13 años, §9.1).
- Coste: el prompt del sistema puede pesar entre 15k y 25k tokens; depende del caché y de recuperar por partes. AG-10
  lo mide.
- Falsos amigos de PSeInt que el analizador no detecta (base cero): la mitigación es ejecutar casos de prueba en
  `run_program`, y en los ejercicios el `ExerciseChecker`.
- Que un ejercicio generado por el agente sea poco pedagógico aunque sea válido: se muestra vista previa y el usuario
  confirma.
- Inyección de instrucciones desde el contenido de un documento: los resultados de herramientas se marcan como datos
  y las destructivas siempre piden confirmación en la interfaz.
- Choque del glifo con §6.2 de fundamentos visuales (D-21): resuelto en AG-0 con la excepción acotada (§9.1).
