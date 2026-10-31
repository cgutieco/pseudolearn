# Fase PG-6A · Servicio y extensión inicial — plan de ejecución

## 0. Metadatos

- Fase: `PG-6A` · Servicio y extensión inicial. Requisitos `R-03`, `R-14`, `R-15`, `R-18` y `R-20`;
  capacidades `C-11` y parte de escritorio de `C-12`. Decisiones rectoras `ADR-08` y `ADR-09`;
  relacionadas `ADR-04` (proyectos), `ADR-07` (hábitos seguros) y `ADR-13` (ayuda compartida).
- Riesgos principales: `K-03` (archivo o revisión equivocados) y `K-10` (distribución y host del editor).
  Experimento obligatorio: `E-PG-02`. `PERF.PG.SERVICE` sigue siendo una métrica candidata.
- Fecha de preparación: `2026-10-30`, zona `America/Lima`.
- Revisión inicial: `e028faa6f7fb95870ded39e58f7f081f34db6329`; árbol limpio al comenzar.
- Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- Encargo: crear el plan detallado para usar el lenguaje como extensión de VS Code antes de producción,
  sin enviarlo a revisión; conservar tareas ligeras primero y verificaciones pesadas posteriores,
  acotadas a lo desarrollado, como en PG-5.
- Aclaración de la persona en este chat: «Exacto, cada cambio debe ser la versión oficial sin importar
  breaking changes». Confirma el retiro del migrador y de la retrocompatibilidad decidido en PG-2.
- Estado de ejecución: **PG-6A.01 a PG-6A.11 implementadas**. Las verificaciones pesadas `.07` se ejecutaron el
  2026-10-30 en la máquina descrita en §11.4, salvo `PG-6A.10.07` (campaña E-PG-02 en curso o sin resumen
  aprobado, ver §11.4). Dos puertas dependen de una persona y no se atribuyen: la revisión independiente que SEE exige
  para validar, reanclar y dar conformidad al corpus (`SEE-STATE: independent review required`) y la revisión del plan
  (`PG-6A.C02`). Por eso `PHASE-GREEN` no se declara. No se avanza a PG-6B (`PHASE-STOP`).
- Dependencias del plan general: PG-1, PG-2 y PG-H. PG-5 fue cerrada por la persona el 2026-10-30;
  sus pendientes se conservan en §1.3. El cierre de PG-6A no certifica el lanzamiento de ENT-1.

### 0.1 Cinco constancias que rigen el plan

**1. Uso local desde el primer incremento.** La entrega es una extensión de escritorio que se puede
probar con F5 en Extension Development Host y luego instalar como `.vsix` en el VS Code habitual.
VS Code documenta ambas rutas sin publicar en Marketplace ([F5](https://code.visualstudio.com/api/get-started/your-first-extension),
[VSIX local](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#packaging-extensions)).
No se necesitan una cuenta de publicación, un token de Marketplace ni una revisión del lenguaje para
ese uso local. Las posibles políticas del equipo o de una organización se comprueban en el equipo
objetivo. No se desactivan controles de VS Code para instalarlo.

**2. Un VSIX funcional permite validar el lenguaje antes de lanzarlo.** El paquete de la plataforma
ensayada incluye su ejecutable Rust compilado y sus recursos; usarlo no requiere Cargo, Rust, Node,
pnpm, `cc` ni el checkout. Estas herramientas pertenecen a la construcción. El override de ejecutable
es una comodidad explícita de desarrollo. Una instalación limpia debe usar el binario empaquetado.
Una extensión instalada localmente sigue siendo software previo al lanzamiento; sus pruebas no
convierten automáticamente al lenguaje en apto para producción.

**3. Ligero primero, pesado al final.** Cada punto conserva `.01` contrato, `.02` casos, `.03` tests,
`.04` implementación, `.05` documentación, `.06` verificación ligera y `.07` verificación pesada.
Las iteraciones 1–6 solo ejecutan `.06` sobre lo tocado; todas las `.07`, los hosts reales, los procesos
reales, `E-PG-02` y la instalación limpia se ejecutan en la iteración 7. Los lanzamientos manuales con
F5 o VSIX se ofrecen desde temprano para uso de la persona; no se presentan como evidencia automática
ni reemplazan la calificación final. `PHASE-GREEN` solo se evalúa después de esa calificación.

**4. Un solo lenguaje, varios bordes.** El corpus define comportamiento; Rust analiza, resuelve,
formatea, traduce y explica. La extensión transporta texto, revisiones, comandos y resultados.
TextMate es una proyección de resaltado generada, no un parser normativo. LSP nunca ejecuta programas;
la ejecución vive en otro proceso de la CLI y usa la API pública de la VM.

**5. Edición oficial única.** No hay migrador, selector de compatibilidad ni soporte de la sintaxis
anterior. Se conserva la edición 2026. Los estados y versiones del corpus siguen congelados
(`SPEC-VERSION-FREEZE`); una corrección se escribe en la misma identidad y se reancla. La versión
del VSIX identifica un artefacto instalable y puede avanzar sin publicar una versión del lenguaje.

Documento transitorio de `docs/`. Desarrolla el [plan general](plan-ejecucion-proposito-general.md) y la
[hoja de ruta](../hoja-de-ruta-proposito-general.md), con el estilo del [plan de PG-5](fase-pg-5-plan-ejecucion.md).
Ningún archivo fuera de `docs/` lo cita (`DOC-NO-TRANSIENT-REFS`). Las decisiones aprobadas pasan a los
README dueños; los contratos observables, al corpus, sin depender de este documento.

## 1. Punto de partida

### 1.1 Qué existe y qué se reutiliza

| Pieza | Dueño actual | Aporte y límite comprobado |
|---|---|---|
| Proyecto en memoria | `packages/pseudolearn_engine/crates/pseudolearn_project` | Catálogo inmutable, rutas portables, manifiesto `pseudolearn.toml`, lock, grafo acíclico y selección de entrada; sin E/S |
| Análisis de proyecto | `pseudolearn_semantic` y `pseudolearn_api/src/project_operations.rs` | Imports, visibilidad, diagnósticos e identidad compuesta; la API puede analizar y ejecutar proyectos |
| Sesión documental | `pseudolearn_service/src/document_session.rs`, `unit_partition.rs`, `symbol_index.rs` | Texto, CST, análisis e índice por documento; huellas de firma/cuerpo; reconstruye el documento tras editar, sin caché semántica de workspace |
| LSP documental | `pseudolearn_service/src/lsp_session.rs`, `lsp_documents.rs`, `lsp_queries.rs` | Ciclo de vida, sincronización incremental, diagnósticos, completado, hover, firmas, navegación local, símbolos, formato y asistencia al teclear |
| Ayuda común | `help_resolution.rs`, `help_content.rs`, `help_rendering.rs`, `lsp_help.rs` | Catálogo de PG-H generado; hover y `pseudolearn.explain` comparten contenido, idioma de interfaz y control de versión |
| Transporte LSP | `apps/pseudolearn_cli/src/lsp_command.rs` | `pseudo lsp` por stdio; lectura y análisis síncronos. No tiene límite de `Content-Length` ni recepción concurrente de cancelación |
| CLI de proyecto | `project_files.rs`, `project_session.rs`, `project_command.rs` | Carga confinada, manifiestos, lock, comprobar/ejecutar/compilar y entrada seleccionada. `execute_run` llama al proyecto de forma inmediata |
| VM interactiva de archivo suelto | `run_command.rs`; API `start`, `advance`, `input`, cancelación | Ejecuta por lotes, presenta salida incremental y atiende `Leer`; reutilizar el recurso y el bombeo, no construir otra VM |
| Ejecución de proyecto actual | API `project_operations.rs::run` | Construye `ExecuteRequest` con valores por omisión y ejecuta hasta terminar; falta una sesión pública de proyecto con entrada/cancelación |
| Generación | Exportación SEE, léxico, gramática y catálogo de ayuda | Fuentes únicas para resaltado y ayuda; hoy no existe una gramática TextMate de extensión |
| Extensión | No existe miembro en `apps/` | Hay que crear README, reglas, verificadores, cliente y empaquetado |

### 1.2 Diferencias entre lo existente y la puerta de PG-6A

- Faltan instantáneas de workspace coordinadas, overlays de documentos abiertos, consulta de archivos
  cerrados, invalidación por dependencia y resincronización si se pierde un evento.
- Faltan navegación entre archivos desde LSP, rename/prepareRename, símbolos del workspace,
  tokens semánticos, configuración por raíz y cancelación atendible durante una consulta.
- `didClose` elimina hoy la sesión y publica diagnósticos vacíos (`TOOL.LSP.CAPABILITIES#R2`). Para
  un archivo que sigue perteneciendo al proyecto habrá que editar esa regla y sus casos: cerrar la
  pestaña vuelve a la fuente del disco y conserva el archivo en el índice. Un documento suelto sí se libera.
- El idioma del editor no puede seguir siendo el respaldo que decide el perfil de un módulo.
  `API.PROJECT.MANIFEST` y el resolutor existente son los dueños de perfiles y procedencias.
- La extensión debe poder seleccionar entrada, comprobar, ejecutar, aportar entrada, detener,
  formatear, traducir y explicar; no basta conectar el LSP documental actual.
- No hay artefacto instalable, matriz de host ni procedimiento de actualización local verificados.

### 1.3 Pendientes heredados que no se ocultan ni se convierten en trabajo de esta fase

PG-5 registra `PERF.SUITE.CORE` en 1,0443 frente a 1,02, tareas AOT no implementadas
(`nativeTasksUnsupported`), propiedades `IR.LOWERING#P1`–`P3` y `TOOL.CLI.IR#P1`, Firefox no lanzable
en el entorno y aprobación pendiente de `PERF.PG.HTTP`. Se conserva su procedencia.

PG-6A usa VM por omisión y no añade depuración ni compilación AOT desde el editor. No reabre esas
campañas, no usa esos fallos como justificación de un error nuevo y no anuncia que los resolvió.
Una regresión nueva en una frontera modificada sí bloquea su cierre. Un fallo heredado solo puede
quedar diferido mediante el tratamiento y la aprobación correspondientes; nunca se informa verde ficticio.

## 2. Lectura realizada

Lectura en la revisión inicial de §0:

- `AGENTS.md` y README raíz: reglas, toolchains por miembro, `apps/`, documentación y verificación local.
- Plan general: §2, §4.0, §4.8 y §5; PG-5: estructura, selección de pruebas y pendientes del cierre.
- Hoja de ruta: `C-11`, `C-12`, PG-6A/6B/7, `E-PG-02`, `ADR-08`, `ADR-09`, `ADR-13`, `K-03`,
  `K-10`, fronteras LSP y `CF-20`.
- Plan de PG-2: `D-PG2-16`, retiro de `PG-2.15` y decisión de la persona sobre versión oficial sin migradores.
- README y reglas de `packages/pseudolearn_engine`, `packages/pseudolearn_spec` y
  `apps/pseudolearn_cli`; README de `pseudolearn_project`, `pseudolearn_service` y `pseudolearn_api`.
- Corpus: reglas de `TOOL.LSP.CAPABILITIES`, `TOOL.SERVICE.INCREMENTAL`, `TOOL.SERVICE.NAVIGATION`,
  `API.PROJECT`, `API.PROJECT.MANIFEST` y `LANG.PROFILE.TRANSLATION`; catálogo y contratos de formato,
  traducción, ejecución e identidad relacionados. La lista exacta de bloques a editar se fija en la iteración 1.
- Código de las piezas de §1.1, declaración de dependencias del servicio y verificador documental de SEE.
- Documentación oficial de VS Code y LSP consultada el 2026-10-30, enlazada en §3.7.

No existe README ni archivo de reglas del miembro nuevo. `PG-6A.02` los escribe antes de su código.
La tabla de §5 contesta capa, imports y dueño para cada familia de archivos propuesta.

## 3. Decisiones de diseño

### 3.1 Opciones, recomendación y reversión

Las propuestas que dependen de `PG-6A.01` se confirman antes de crear el miembro. Una autorización que
acepte este plan y sus opciones concretas puede resolverlas juntas; no se vuelve a pedir lo ya autorizado.

| ID | Opciones y criterio | Propuesta o decisión vigente | Reversión y dueño documental |
|---|---|---|---|
| `D-PG6A-01` Miembro | App nueva o incrustar cliente en engine/frontend; distribución y separación de cadenas | Proponer `apps/pseudolearn_vscode`, TypeScript, Node y pnpm, `architecture.json`; resolver `CF-20` con la persona | Cambiar ruta/cadena antes del código si la persona elige otra; README raíz, AGENTS y miembro |
| `D-PG6A-02` Derechos | Abrir licencia ahora o conservar decisión de PG-0 | Proponer derechos reservados para extensión propia de uso local; inventariar licencias de dependencias y binarios. Licencia abierta y publicación siguen en PG-7.07 | Solo decisión expresa sobre licencia; README del miembro y avisos del paquete |
| `D-PG6A-03` Canal | F5, VSIX local o Marketplace pre-release | F5 para desarrollo y VSIX para uso cotidiano; sin publicación. Pre-release de Marketplace sigue siendo publicación | Cambio de canal en PG-7 autorizado; README del miembro |
| `D-PG6A-04` Binario | Buscar en PATH, descargar al activar o incluir CLI | VSIX por SO/arquitectura con `pseudo` incluido; override absoluto de usuario solo para desarrollo confiable. Sin búsqueda en proyecto ni descarga al abrir | Cambiar estrategia si tamaño/licencia/plataforma falla, antes de afirmar instalación completa; README extensión/CLI |
| `D-PG6A-05` Cliente | SDK LSP mantenido o implementar JSON-RPC en TS | `vscode-languageclient/node` fijado; cliente fino. Versión exacta, compatibilidad y dependencias se verifican en la iteración 2 | Sustituir dependencia solo con evidencia; README extensión |
| `D-PG6A-06` Servicio | Llevar ejecución al servicio, llamar API desde servicio o componer capas inferiores | Workspace en `pseudolearn_service`; permitir explícitamente `pseudolearn_project` antes de importarlo; semántica compartida desde su dueño | Refactor en capa inferior si hay duplicación; nunca dependencia inversa service → API/VM/CLI |
| `D-PG6A-07` Invalidación | Reanalizar todo siempre, framework nuevo o dependencias explícitas | Empezar con snapshot correcto y comparación fría; registrar firmas/cuerpos y dependientes. Reutilización acotada al índice necesario para E-PG-02 | Optimizar únicamente el cuello medido; sin Salsa/Rowan ni cachés generales; README service/semantic |
| `D-PG6A-08` Ejecución | Terminal con shell, reutilizar protocolo de tests o borde mínimo de CLI | Proceso VM separado, sin shell; modo de control de editor candidato en la CLI, sobre sesiones API existentes. §3.4 delimita su contrato | Si basta un borde menor con igual entrada/cancelación verificables, reducirlo antes de fijar contrato; README CLI/API |
| `D-PG6A-09` Texto al ejecutar | Correr silenciosamente disco, guardar todo o aceptar confirmación de guardado | Comprobar por LSP el overlay vigente; ejecutar únicamente snapshot guardado de la raíz seleccionada. Si hay cambios sin guardar, ofrecer guardar o cancelar, sin guardado silencioso | Ejecutar overlays sería otra decisión y contrato; README extensión |
| `D-PG6A-10` Hosts | Prometer todos por API disponible o calificar host concreto | Escritorio local y plataforma realmente probada. `extensionKind: workspace` candidato; virtuales sin archivos y hosts remotos sin evidencia muestran limitación explícita | Añadir host solo con binario y prueba real; README y manifiesto extensión |
| `D-PG6A-11` Migración | Restaurar migrador de la lista antigua o conservar decisión posterior | **Confirmado por la persona el 2026-10-30:** sin migradores ni compatibilidad; solo versión oficial aunque haya cambios incompatibles | Solo si la persona reabre alcance; se actualiza la mención antigua de PG-6A.07 |

### 3.2 Instantánea y revisión del workspace

1. El anfitrión CLI lee fuentes/manifiestos/lock bajo raíces explícitas, con el confinamiento existente.
   El servicio recibe datos; no hace `read_dir`, no sigue symlinks por su cuenta ni observa el entorno.
2. Cada proyecto tiene identidad y revisión coordinadas; cada fuente conserva `source_id` y revisión.
   Dos raíces con la misma ruta relativa no comparten identidad. Los enteros u64 del wire se conservan
   como cadenas decimales donde ya lo exige la API; TS no los convierte a `Number`.
3. Un documento abierto sustituye el texto de disco solo en su overlay. Cambios de watcher sobre ese
   archivo actualizan la base de disco sin borrar la edición abierta. Al cerrar se restaura la base
   actual o se informa eliminación; no se conserva una copia anterior al último evento.
4. Importadores y exportaciones se indexan por identidad semántica. Cambiar una firma invalida sus
   dependientes; cambiar un cuerpo no obliga a invalidar firmas ajenas. Si no se puede demostrar una
   reutilización correcta, se reconstruye lo afectado; nunca se entrega un resultado obsoleto.
5. Un evento perdido, secuencia inválida, reinicio de watcher o cambio de manifiesto/lock invalida la
   vista correspondiente. Se toma otra instantánea y se reconcilian overlays por revisión antes de
   publicar resultados. El host no presupone un contador de eventos ni una notificación de pérdida:
   reconcilia contenidos/digests de cada raíz activa periódicamente (intervalo candidato de 5 s), al
   recuperar foco y antes de proponer mutaciones o ejecutar. No basta comparar mtime/tamaño. La
   prueba omite un evento sin emitir una señal adicional y exige recuperación dentro del intervalo.
   Habrá además una acción explícita de resincronización; se mide su coste fuera de la consulta pura.
6. Diagnósticos y consultas llevan su revisión. Una respuesta calculada sobre una revisión anterior se
   descarta o responde `ContentModified`; jamás se reetiqueta con la nueva. Los diagnósticos relacionados
   resuelven su URI, rango y texto desde la fuente que posee su identidad.

### 3.3 LSP 3.17, capacidades y ediciones

Base interoperable: LSP 3.17, sin afirmar que sea la versión más reciente. UTF-16 es la codificación
inicial; se negocia lo que se implementa. Bytes UTF-8, escalares y unidades UTF-16 son unidades distintas.
CRLF, NFC/NFD y caracteres no BMP deben conservar rangos sobre los bytes originales, sin normalizar el programa.

| Superficie | Contrato de PG-6A |
|---|---|
| Inicialización | Raíces/workspace folders, configuración y capacidades efectivas; no anunciar providers antes de implementarlos |
| Sincronización | `didOpen`, cambios incrementales, guardado, cierre, create/change/delete y cambio de raíces; rechazo y resync de versiones no monótonas |
| Diagnósticos | Por fuente y revisión, incluidos archivos cerrados del proyecto y `relatedInformation` si el cliente lo admite |
| Navegación | Definición, referencias, document/workspace symbols y resaltado por identidad; privados, alias y reexportaciones respetados |
| Rename | `prepareRename`, validación de nombre/colisiones y `WorkspaceEdit.documentChanges` con versiones; análisis del conjunto antes de devolver cualquier edición |
| Formato | Usar formateador común; respetar contrato vigente ante error sintáctico; no sobrescribir disco desde servidor |
| Tokens semánticos | Leyenda estable generable y `full` inicialmente; no anunciar `delta`/`range` si no existen; complemento de TextMate |
| Asistencia | Conservar completion, snippets, firmas y on-type existentes, negociando soporte de snippets |
| Ayuda | Hover y `pseudolearn.explain` existente; mismo catálogo, identidad, idioma y revisión |
| Cancelación | `$/cancelRequest` procesable mientras trabaja la consulta; respuesta única y sin publicación tardía; cola y cierre acotados |

**Atomicidad y archivos cerrados.** No se promete que cualquier cliente o sistema de archivos aplique
un rename multiarchivo como una transacción. Se requieren `documentChanges` y `failureHandling`
`transactional` o `textOnlyTransactional`, con un conjunto exclusivamente de ediciones de texto.
La garantía es todo o nada sobre los modelos del editor y el snapshot preparado; el rename no guarda
archivos automáticamente ni promete una transacción con escritores externos del disco.

Para documentos abiertos se comprueba su versión. Para cerrados, LSP permite `version: null`, que no
expresa una precondición de contenido: releer huellas antes de aplicar no elimina esa carrera. El
cliente materializa/sincroniza los documentos afectados como modelos y recalcula la propuesta con
versiones antes de aplicar. Se verifica en el SDK fijado cuándo valida esas versiones y qué garantía
conserva al convertir a `WorkspaceEdit` de VS Code. Ante un cambio detectado se rechaza/recalcula el
conjunto completo; si el host no puede ofrecer las precondiciones necesarias, se rechaza la operación
en vez de aplicarla parcialmente. No se afirma exclusión de toda carrera externa. Los dos clientes
prueban tanto la ruta soportada como el rechazo de capacidades insuficientes
([API applyEdit](https://code.visualstudio.com/api/references/vscode-api#workspace.applyEdit),
[capacidades LSP](https://github.com/microsoft/language-server-protocol/blob/gh-pages/_specifications/lsp/3.17/types/workspaceEdit.md)).

No se reescriben imports/rutas al renombrar un archivo en esta fase salvo que el contrato del rename
de símbolo ya lo exija. Refactors, búsqueda textual y rename de archivos no se anuncian por asociación.

### 3.4 Ejecutar, detener y aportar entrada sin DAP

`PG-6A.07` incluye esta frontera porque el proyecto actual no ofrece una sesión interactiva completa.
No se habilita `--nativo`, depuración ni acceso a memoria desde VS Code.

- Extender la API pública para preparar/iniciar una ejecución de proyecto conservando `PreparedProgram`,
  identidad de todas las fuentes y el `ExecutionResource` existente. Las operaciones `advance`, `input`,
  cancelación y liberación siguen teniendo un solo dueño. No duplicar el compilador de proyectos en service.
- Reutilizar en la CLI el bombeo VM por lotes del archivo suelto. Separarlo por responsabilidad antes
  de añadir proyecto; preservar salida, códigos y opciones de las órdenes existentes.
- Proponer un modo explícito de editor de `run`, con handshake de esquema/versión/capacidades,
  mensajes de entrada/cancelación/cierre y eventos de estado/salida/diagnóstico/fin, identificados por
  sesión. Su nombre y campos son candidatos hasta la iteración 1. Solo transportar lo necesario;
  no exponer el protocolo SEE como API de producto ni crear un depurador paralelo.
- Mantener salida del programa como texto dentro del evento de salida: un programa que imprime JSON
  no puede fabricar un evento. Stderr es técnico, separado y acotado. No inferir `awaiting_input`
  mediante expresiones regulares sobre la salida del estudiante.
- «Entrada» envía una línea a la sesión que espera; entrada vacía es una línea válida. Cancelar el
  cuadro de entrada no equivale a enviar cadena vacía. «Elegir entrada» selecciona un punto de entrada
  declarado del proyecto; no confundir ambos comandos. EOF, cierre de ventana y segunda ejecución
  tienen desenlace explícito; una sesión activa por raíz en la primera entrega.
- Cancelar se atiende entre lotes y durante espera de entrada/efecto mediante recepción separada.
  Detener primero solicita cancelación al recurso; un proceso que no responde se termina tras un
  plazo declarado. La terminación forzada se presenta como aborto del anfitrión, sin inventar limpieza
  de lenguaje ni cinta reproducible. Ningún proceso ajeno se mata.
- Permisos y orígenes proceden de concesiones explícitas del usuario/anfitrión, nunca de confiar el
  workspace ni de una solicitud del manifiesto. Por omisión no hay archivos ni red concedidos.
  Las pruebas básicas usan consola/entrada y efectos falsos; los transportes de PG-5 se reutilizan.

### 3.5 Configuración, confianza y límites de host

`pseudolearn.toml` conserva su esquema 1. **No se añaden** `edition`, `language` ni `ui`: el contrato
oficial `API.PROJECT.MANIFEST#R2` los rechaza. Tampoco se crean un manifiesto alternativo en `.vscode`
ni una segunda tabla de perfiles. La precedencia se resuelve por campo, con su procedencia:

| Grupo | Precedencia o regla |
|---|---|
| Perfil por archivo | `profile` del archivo de la petición > excepción de ruta/directorio más cercano del manifiesto > perfil declarado del paquete > apertura inequívoca > `profile` global de petición > es. El global/`--vocabulario` es respaldo, no override de los anteriores. Una discrepancia configurada se diagnostica y se analiza con la apertura, según `LANG.PROFILE.MODEL` |
| Entrada, rigor y límites solicitados | Invocación explícita > manifiesto cuando tenga ese campo > valor por omisión documentado; no inventar campos que el esquema no admite |
| Autoridad | Intersección de permisos solicitados/concedidos y mínimo de límites; una precedencia nunca amplifica autoridad |
| Idioma de interfaz | Preferencia personal explícita > idioma de VS Code normalizado a es/en > español; se entrega a la CLI sin heredar una preferencia contradictoria del entorno |
| Ejecutable y concesiones | Preferencia de usuario confiable o binario incluido; valores del proyecto que elijan ejecutable, shell o credenciales se rechazan |

El contrato común expresa rigor y demás opciones ausentes del manifiesto como opciones de invocación,
sin forzar una ampliación del manifiesto. Configuración inválida produce diagnóstico; no se ignora.

Restricted Mode: resaltado declarativo y análisis mediante binario incluido verificado bajo raíces
limitadas; bloquear ejecución, concesiones y override sensible hasta confianza explícita. Declarar
`untrustedWorkspaces` con soporte limitado y `restrictedConfigurations`; volver a comprobar confianza
al invocar el comando. Si el análisis no puede garantizar lectura confinada, limitarlo al documento
abierto. No ejecutar hooks, herramientas del workspace, comandos `command:` ni scripts del proyecto.

Declarar soporte de virtual workspaces según la evidencia: en PG-6A, no tratar URI virtual como ruta
local. En Remote/WSL/contenedor el binario debe corresponder al host de extensión, no al equipo de la
ventana; sin binario y ensayo de ese host, informar falta de soporte y no iniciar un ejecutable incorrecto.

### 3.6 Artefactos locales e instalación

El manifiesto propone `languageId: pseudolearn`, asociación `.pseudo`, nombre de extensión e identidad
`publisher.name` locales estables, `main` de escritorio, `engines.vscode`, licencia/derechos y contribuciones
de lenguaje, gramática, comandos y configuración. Publisher es metadata necesaria; no implica cuenta
registrada ni publicación. No hay `browser` ni contribución de debugger en PG-6A.

El paquete contiene bundle de extensión, gramática generada, configuración declarativa de lenguaje,
binario de plataforma, README operativo y avisos/licencias. Un registro de artefacto conserva revisión
Git, hash de corpus/exportación/gramática/binario, target, toolchains, versión VSIX y VS Code probado.
Un hash detecta diferencias respecto de un registro confiable; no se presenta como firma ni prueba
de autenticidad por sí solo. La identidad del binario y el protocolo se verifican antes de aceptar la sesión.

Con pnpm se ensaya primero el bundle: `vscode` externo al bundle, dependencias de runtime incluidas,
tipos comprobados por separado y lista explícita de contenido. `vsce --no-dependencies` solo se usa
si el bundle realmente contiene lo necesario. No empaquetar `node_modules` del monorepo por accidente,
fuentes privadas, `.git`, credenciales, cintas, resultados, fixtures adversarios ni toolchains.
Sourcemaps solo si no filtran rutas/fuentes excluidas. Una modificación deliberada del binario o
una dependencia omitida debe hacer fallar la puerta del paquete.

Se versionan lock de app y generados que otro build consuma, con verificador de vigencia. Binarios,
VSIX y evidencia de ejecución se producen localmente bajo rutas ignoradas; no se versionan por comodidad.

### 3.7 Referencias consultadas y límites de adopción

| Fuente oficial | Qué se toma | Qué no se adopta |
|---|---|---|
| [Primer desarrollo](https://code.visualstudio.com/api/get-started/your-first-extension) | F5 y Extension Development Host | Scaffolding con comentarios o publicación automática |
| [Manifiesto](https://code.visualstudio.com/api/references/extension-manifest) | Metadata, engines y contribuciones | Declarar capacidades solo porque el esquema las permite |
| [Guía LSP](https://code.visualstudio.com/api/language-extensions/language-server-extension-guide) y [LSP 3.17](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/) | Cliente mantenido, protocolo y negociación | Parser/semántica del lenguaje ejemplo ni exigencia de la versión más reciente |
| [Empaquetado](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#packaging-extensions) y [targets](https://code.visualstudio.com/api/working-with-extensions/publishing-extension#platform-specific-extensions) | VSIX local y paquete por plataforma | Marketplace o pre-release como condición para probar |
| [Bundling](https://code.visualstudio.com/api/working-with-extensions/bundling-extension) y [VSCE](https://github.com/microsoft/vscode-vsce#requirements) | Bundle y requisitos de la versión fijada; al consultar, VSCE exige Node ≥22 | Suponer que pnpm tiene el mismo descubrimiento de dependencias que npm/yarn |
| [Trust](https://code.visualstudio.com/api/extension-guides/workspace-trust) | Restricted Mode y configuración sensible | Equiparar confianza con permisos de ejecución del lenguaje |
| [Hosts](https://code.visualstudio.com/api/advanced-topics/extension-host) y [virtuales](https://code.visualstudio.com/api/extension-guides/virtual-workspaces) | Distinguir host, plataforma y URI | Prometer web/remoto por instalar un VSIX desktop |
| [Tests](https://code.visualstudio.com/api/working-with-extensions/testing-extension) y [CLI VS Code](https://code.visualstudio.com/docs/configure/command-line#_working-with-extensions) | Host real, perfiles/directorios aislados e instalación local | Suites de todos los productos del monorepo |

Al implementar, trasladar toma/rechazo a los README dueños (`DOC-README-TRUTH`) y verificar las APIs
contra las versiones exactas fijadas; las fuentes externas no son normativa de PseudoLearn.

## 4. Desglose por punto

Convención heredada de PG-5: `.01` contrato → `.02` casos derivados → `.03` tests espejo → `.04` código
→ `.05` README/reglas → `.06` ligera → `.07` pesada. Los puntos de decisión/documentación no inventan
una regla de lenguaje para rellenar la plantilla: su contrato y evidencia son documentales.
Las casillas describen el alcance planificado. El resultado ejecutado y la puerta pendiente se registran
en §0.2.

### 0.2 Resultado de PG-6A.01 a PG-6A.03

La extensión privada `pseudolearn.pseudolearn-vscode` quedó implementada para uso local, con Node
22.23.3, pnpm 12.8.1, TypeScript 6.0.3, VS Code mínimo `^1.144.0`, VSIX `0.1.0` y binario incluido
solo para `darwin-arm64`. Se reservaron los derechos del código propio; el empaquetado genera avisos de
dependencias desde el grafo Cargo y conserva los textos de licencia disponibles. La activación no
inicia procesos. El override del binario requiere ruta absoluta y `NODE_ENV=development`.

El servicio Rust ahora ofrece una sesión persistente de workspace separada de `document_session`.
Recibe snapshots y datos de revisión, conserva overlays y módulos cerrados, invalida dependencias y
permite resincronizar comparando contenido completo. La E/S y el confinamiento permanecen en la CLI.
`API.PROJECT` y `TOOL.SERVICE.INCREMENTAL` conservan identidad, estado y versión; se añadió
`TOOL.SERVICE.WORKSPACE` estable `1.0.0` porque el contrato persistente no cabía en los existentes.
La dependencia `service → project` quedó declarada antes de usarla.

La extensión pasó verificadores propios, negativos, tests, build, empaquetado e instalación local en
F5 y VS Code Stable 1.144.0. Los tests dirigidos del servicio, API, propiedades SEE, validación de
recursos y exportación pasaron; también pasó una lectura/resincronización real aislada. La suite amplia
`pseudolearn_api` conserva un fallo ajeno al cambio en `historical_collection_state_contains_ordered_contents`.
`see validate`, el reanclaje y `see conform` no pueden pasar hasta que una persona complete la revisión
independiente y se registre en `revisado_por`; no se atribuye esa revisión en esta implementación.
La sesión recibe datos y el adaptador de conformidad se probó en proceso aislado; no se agregó un puerto lector
falso porque la capa del servicio no realiza E/S.

### PG-6A.01 · Decidir miembro, cadena, derechos y alcance local

- [x] `PG-6A.01.01` Presentar a la persona `D-PG6A-01`–`04`: ruta propuesta, Node/pnpm/TypeScript,
  ampliación de `AGENTS.md` §9, derechos reservados locales y publicación diferida. Registrar su
  decisión literal sobre `CF-20`; no crear la app ni instalar sus dependencias antes de esa decisión.
- [x] `PG-6A.01.02` Inventariar escenarios: desarrollo F5, uso VSIX sin red, host/arquitectura soportados,
  máquina sin toolchains, override local, plataforma incompatible y actualización/reversión.
- [x] `PG-6A.01.03` Definir criterios de comprobación de metadata, identidad, binario y licencias,
  incluyendo negativo de target incorrecto, sin diseñar un publicador ni una plataforma de releases.
- [x] `PG-6A.01.04` Fijar versiones exactas de Node/pnpm/TypeScript/SDK/VSCE compatibles entre sí y con
  VS Code mínimo y Stable elegidos; proponer identidad local y esquema de versión VSIX. No subir al registro.
- [x] `PG-6A.01.05` Actualizar README raíz y AGENTS solo con lo autorizado; separar derechos del código
  propio de obligaciones de redistribución de dependencias. Registrar migrador retirado por la decisión vigente.
- [x] `PG-6A.01.06` Ligera: revisar decisión registrada, rama, metadata propuesta y diff documental;
  comprobar que no se atribuyeron autorizaciones, licencias abiertas ni plataformas inexistentes.
- [x] `PG-6A.01.07` Pesada, iteración 7: contrastar decisiones con el contenido real del VSIX,
  dependencias/avisos y matriz ensayada; ninguna afirmación más amplia que su evidencia.

### PG-6A.02 · README, reglas, verificadores y esqueleto de extensión

- [x] `PG-6A.02.01` Escribir primero README y `architecture.json` del miembro aprobado: responsabilidad,
  matriz de capas de §5, límites, errores públicos, toolchain y «Cómo se verifica» con selección por archivo.
- [x] `PG-6A.02.02` Definir fixtures mínimos válido/roto para comentario TS/JS, import inverso, capa no
  declarada, función/archivo excesivos y paquete con secreto o recurso excluido. Texto dentro de una
  cadena no es comentario; el scanner debe distinguirlo.
- [x] `PG-6A.02.03` Escribir tests espejo de verificadores y lógica de activación mediante puertos
  falsos; incluir activación fallida y desactivación repetida, sin arrancar VS Code todavía.
- [x] `PG-6A.02.04` Crear manifiesto, lock, configuración TS/bundle y adaptador de activación mínimo,
  scripts ligeros independientes y configuración F5. La extensión no inicia programas al abrir.
  Implementar verificadores propios; no importar reglas del frontend como si fueran su arquitectura.
- [x] `PG-6A.02.05` Documentar arranque de desarrollo, comandos exactos existentes, tipos de error y
  estructura. El código nuevo lleva cero comentarios, incluidos scaffolding y declaraciones propias.
- [x] `PG-6A.02.06` Ligera: instalación con lock fijado, tipos, lint, unitarias filtradas y negativos
  de verificadores del miembro; build de bundle. Preparar un primer VSIX sin exigir aún funciones pendientes.
- [x] `PG-6A.02.07` Pesada, iteración 7: arrancar host mínimo y Stable, activar/desactivar y comprobar
  ausencia de procesos huérfanos y capacidad de carga del bundle fuera del `node_modules` de desarrollo.

### PG-6A.03 · Servicio persistente de workspace y archivos cerrados

- [x] `PG-6A.03.01` Editar contratos existentes `API.PROJECT` y `TOOL.SERVICE.INCREMENTAL`; proponer
  `TOOL.SERVICE.WORKSPACE` solo para la responsabilidad persistente no cubierta. Fijar snapshot,
  revisiones, overlay, cierre, dependencias y resync de §3.2; no cambiar semántica de imports.
- [x] `PG-6A.03.02` Casos: dos módulos y un importado cerrado; overlay que corrige error; cambio de
  cuerpo/firma; archivo borrado mientras está abierto; vuelta a disco al cerrar; create/delete;
  evento omitido sin aviso de pérdida, con igual mtime/tamaño pero contenido distinto; cambio de
  manifiesto/lock; dos raíces homónimas; cero archivos y programa vacío.
  Añadir propiedades de igualdad con análisis frío y de independencia del orden de entrega de archivos.
- [x] `PG-6A.03.03` Tests espejo de snapshot/índice/invalidación y lectura del adaptador con puertos
  falsos. Reutilizar fixtures bilingües de proyecto; no duplicar los casos del corpus como Rust.
- [x] `PG-6A.03.04` Declarar antes la dependencia service → project en Cargo/reglas/README. Crear
  módulos de workspace separados de `document_session`; reutilizar `analyze_project` semántico y el
  resolutor de manifiesto/perfiles. Extraer responsabilidades de análisis comunes de API cuando sea
  necesario para que API y servicio no produzcan dos políticas de proyecto. E/S confinada en CLI.
- [x] `PG-6A.03.05` README de engine, service, project, semantic/API y CLI tocados: revisión, vida de
  recursos, invalidación y coste real. Retirar la descripción desactualizada de extensión «opcional».
- [x] `PG-6A.03.06` Ligera: casos/propiedades definidos y validados; tests filtrados con proyectos
  pequeños; `cargo check`, Clippy y reglas de crates tocados. No ejecutar todavía campañas de 1000 archivos.
- [x] `PG-6A.03.07` Pesada, iteración 7: conformidad dirigida, propiedades por secuencias de edición,
  archivos cerrados y resync con proceso real; comparación exacta frío/incremental de §7.3.

### PG-6A.04 · LSP de proyecto con capacidades reales y cancelación

- [x] `PG-6A.04.01` Editar `TOOL.LSP.CAPABILITIES`, `TOOL.SERVICE.NAVIGATION` e identidad/rangos que
  realmente cambien: declarar los métodos de §3.3, cierre de archivo de proyecto, capacidades del
  cliente, rename seguro, tokens y cancelación. Definir límites de framing/cola y errores de protocolo.
- [x] `PG-6A.04.02` Casos es/en: navegación a cerrado, homónimos/sombreado, alias/reexportación,
  privado no visible, rename válido/colisión/palabra reservada, versión vieja y cambio concurrente;
  UTF-16 no BMP, NFC/NFD, CRLF, offset inválido, cliente sin snippets/documentChanges y cancelación.
- [x] `PG-6A.04.03` Tests de mensajes en memoria y transporte por lector/escritor falsos: encabezado
  fragmentado, dos mensajes juntos, longitud en bytes, duplicada/inválida/excesiva, cuerpo truncado,
  JSON inválido, inicialización repetida, método desconocido, EOF y salida sin `shutdown`.
- [x] `PG-6A.04.04` Implementar handlers por responsabilidad; índice multiarchivo y edición propuesta
  completos antes de responder. El transporte CLI recibe cancelaciones y respuestas del cliente
  mientras el trabajador procesa consultas; una cola acotada y comprobaciones cooperativas evitan que
  `$/cancelRequest` espere detrás de la consulta a cancelar. stdout solo protocolo; errores en stderr.
- [x] `PG-6A.04.05` README service/API/CLI: capacidades exactas, negociación, límites, orden de
  publicación, fuente obsoleta y garantía real de aplicación de ediciones de cada cliente.
- [x] `PG-6A.04.06` Ligera: tests filtrados de handlers/transporte en memoria, tipos y reglas; comparar
  capabilities con handlers cubiertos. Verificar regresión pequeña de hover/completado/formato existentes.
- [x] `PG-6A.04.07` Pesada, iteración 7: proceso `pseudo lsp` real, cancelación en análisis costoso,
  desconexión/reinicio, batería rename multiarchivo y corpus de contratos tocados; equivalencia en dos clientes.

### PG-6A.05 · Configuración declarativa, confianza y selección de binario

- [x] `PG-6A.05.01` Fijar contrato común por campo según §3.5, procedencia y errores. Editar
  `API.PROJECT.MANIFEST`, convenciones CLI o contrato de workspace solo donde cambie comportamiento;
  conservar edición única y rechazo de `edition/language/ui`. Declarar configuración sensible VS Code.
- [x] `PG-6A.05.02` Casos: opción explícita/perfil por ruta, rigor inválido, idioma UI distinto del
  programa, raíces múltiples, grant ausente/recortado, intento de conceder desde `.vscode`, binario
  incompatible, override relativo o apuntado por proyecto, modo restringido y URI virtual.
- [x] `PG-6A.05.03` Tests espejo del resolutor común y selección de ejecutable mediante puertos;
  cubrir cambios de configuración sin guardar, retirada de confianza y reinicio que no ejecuta programas.
- [x] `PG-6A.05.04` Implementar adaptadores de configuración hacia el resolutor único; validación
  de binario incluido/override de usuario y protocolo, lectura confinada y degradación declarada.
  No leer secretos ambientales ni convertir rutas del proyecto en órdenes de shell.
- [x] `PG-6A.05.05` README con tabla de precedencia y procedencia, Restricted Mode, hosts admitidos,
  límites de permisos y forma explícita de elegir binario de desarrollo. Mensajes UI localizados es/en.
- [x] `PG-6A.05.06` Ligera: validación de metadata/configuración y tests con puertos falsos; corpus
  de integridad si se modificó; negativos que prueben que el workspace no elige su propio ejecutable.
- [x] `PG-6A.05.07` Pesada, iteración 7: hosts separados confiable/restringido, ruta con espacios,
  symlink de escape, cambio de confianza, binario/target erróneo y persistencia de la selección entre sesiones.

### PG-6A.06 · Gramática y configuración de lenguaje generadas

- [x] `PG-6A.06.01` Inventariar vocabulario, alias, operadores, formas compuestas/contextuales,
  comentarios/literales y reglas de delimitación desde el corpus/exportación. Definir contrato de
  generación y hash de entrada; cualquier dato adicional pertenece al dueño del corpus, no a una lista TS.
- [x] `PG-6A.06.02` Casos de ambos perfiles: acentos/caja admitidos, nombre que contiene una keyword,
  cadenas escapadas, comentarios, keyword compuesta, prefijo incompleto y nombre contextual del usuario.
  El resaltado tolerante no afirma validez ni cambia identidad semántica.
- [x] `PG-6A.06.03` Tests del generador y tokenización de la gramática con motor TextMate real en
  proceso de test pequeño; negativos por keyword agregada al corpus sin regenerar y archivo generado alterado.
- [x] `PG-6A.06.04` Implementar generador sobre exportación anclada y proyección de scopes; emitir
  gramática y pares/comentarios/autocierre declarativos derivados. Si el dueño requiere cambiar
  `see_export`, hacerlo allí; el consumidor no analiza Markdown normativo ni copia tablas a mano.
- [x] `PG-6A.06.05` README con origen, comando de regeneración/check, salidas consumidas por otro
  build y límites de TextMate frente a tokens semánticos. Describir alternativas descartadas.
- [x] `PG-6A.06.06` Ligera: regeneración reproducible, check de vigencia, tokenización de fixtures
  pequeños y negativos; no arrancar Electron para comprobar una expresión de gramática.
- [x] `PG-6A.06.07` Pesada, iteración 7: resaltado antes del LSP y tras tokens semánticos en host real,
  muestra de todas las familias incorporadas y rechazo del paquete con generados obsoletos.

### PG-6A.07 · Cliente desktop y ciclo completo de ejecución

- [x] `PG-6A.07.01` Especificar la extensión mínima de sesión pública de proyecto y borde CLI de §3.4
  en `API.PROJECT`, `API.EXECUTE`, `TOOL.CLI.RUN` y, si no cabe en esos contratos, identidad candidata
  `TOOL.CLI.EDITOR`. Fijar entrada/EOF/cancelación/fin, límites de mensajes/salida y estado de sesión.
  El migrador queda retirado; no se agrega orden ni API para él.
- [x] `PG-6A.07.02` Casos: archivo suelto y proyecto que importan/leen/imprimen; entrada vacía, dos
  lecturas, EOF, tipo inválido, módulo con error, ejecución con cambios sin guardar, dos entradas,
  bucle infinito, cancelación esperando entrada/efecto, cierre de ventana y segunda ejecución.
  El esperado sale de la regla, no de la salida capturada de VS Code.
- [x] `PG-6A.07.03` Tests espejo API/CLI del inicio de proyecto y recursos; tests unitarios de los
  comandos TS con puertos de procesos/documentos falsos. Incluir argumentos con espacios/metacaracteres,
  evento falso impreso por el programa, sesión anterior que responde tarde y servidor caído.
- [x] `PG-6A.07.04` Crear cliente `vscode-languageclient/node`, ciclo inicio/parada/reinicio acotado,
  command handlers y vistas mínimas de estado/salida. Implementar sesión de proyecto en API y borde
  CLI común con archivo suelto. Comprobar usa overlay de LSP; ejecutar exige snapshot guardado de la
  raíz/entrada elegidas. Formato/traducción producen ediciones revisables y deshacibles sobre la
  revisión vigente; colisión de traducción no escribe nada. Cada proceso tiene propietario y cierre.
- [x] `PG-6A.07.05` README operativos de extensión/API/CLI con IDs definitivos de comandos, ejemplos
  de archivo/proyecto y entrada, permisos, cancelación, logs, errores y límites. No presentar salida
  técnica como explicación del estudiante ni describir comandos aún ausentes.
- [x] `PG-6A.07.06` Ligera: tipos, unitarias por handler/módulo, build del bundle y formato/reglas de
  Rust tocado. Preparar F5 y VSIX incremental para que la persona pueda usar lo ya implementado.
- [x] `PG-6A.07.07` Pesada, iteración 7: host real y CLI real, completar/diagnosticar/navegar/renombrar,
  ejecutar/importar/Leer/detener, traducción/formato y limpieza tras crash/cierre; probar sin toolchains.

### PG-6A.08 · Ayuda PG-H en hover y explicar

- [x] `PG-6A.08.01` Conservar `TOOL.SERVICE.CATALOG`, `TOOL.SERVICE.HOVER` y comando existente.
  Solo editar contrato si cambia selección por identidad/revisión dentro del workspace; no inventar
  otra API de ayuda para TS ni fichas sobre sintaxis inexistente.
- [x] `PG-6A.08.02` Casos: keyword/operador compuesto, símbolo del usuario, función de biblioteca,
  comentario/cadena sin ficha, programa incompleto, perfil es con UI en, Unicode y consulta obsoleta.
- [x] `PG-6A.08.03` Tests de igualdad hover/explicar por ficha/rango, ausencia de ayuda y escape.
  Ampliar el verificador de fuente única para que recorra el miembro nuevo; copia deliberada debe fallar.
- [x] `PG-6A.08.04` Conectar hover estándar y comando explícito en el cursor al resultado común;
  permitir teclado y paleta. Representar Markdown como no confiable, sin HTML, URI activos, recursos
  remotos ni ejecución de ejemplos. Contenido demasiado grande conserva el aviso del servicio.
- [x] `PG-6A.08.05` README con separación entre etiquetas de UI localizadas y prosa del catálogo;
  forma de acceder y comportamiento sin ayuda. Fichas se generan; nunca se pegan al bundle como tabla propia.
- [x] `PG-6A.08.06` Ligera: tests filtrados de ayuda/escape/fuente única y unitarias del handler.
- [x] `PG-6A.08.07` Pesada, iteración 7: hover/explicar desde host real y desde segundo cliente;
  conformidad dirigida de catálogo/hover y paridad pública sobre ambos perfiles.

### PG-6A.09 · Interoperabilidad con dos clientes LSP

- [x] `PG-6A.09.01` Fijar superficie común y normalización permitida: IDs de transporte y prefijo
  temporal de URI. No normalizar códigos, mensajes, rangos, revisiones, símbolos ni ediciones distintas.
- [x] `PG-6A.09.02` Fixture de proyecto bilingüe con cerrado, alias, sombra, error relacionado y
  carácter no BMP; secuencia initialize/open/change/query/rename/config/resync/shutdown/exit.
- [x] `PG-6A.09.03` Tests de comparación con negativos: alterar un rango UTF-16, perder archivo,
  cambiar símbolo o aceptar edición obsoleta debe producir diferencia, aunque el texto visible coincida.
- [x] `PG-6A.09.04` Preparar cliente A: extensión VS Code. Cliente B: arnés independiente con otra
  implementación del cliente/transporte, escrito en la cadena ya declarada de CLI, sin importar
  `vscode-languageclient` ni llamar `LspServer` en memoria. Habla con `pseudo lsp` como proceso.
  No se crea un plugin de otro editor; si se usa un editor real como B, fijar su versión y alcance.
- [x] `PG-6A.09.05` Documentar secuencia, cliente B, versiones y qué prueba interoperabilidad frente
  a corrección normativa. Ambos clientes comparten motor; no son un oráculo independiente de semántica.
- [x] `PG-6A.09.06` Ligera: tests del comparador y fixtures de mensajes sin lanzar los dos hosts.
- [x] `PG-6A.09.07` Pesada, iteración 7: ejecutar misma secuencia en ambos, comparar exactamente
  resultados normalizados, negociar capacidades inferiores y conservar transcripts sin datos privados.

### PG-6A.10 · E-PG-02 y coste del servicio

- [x] `PG-6A.10.01` Leer `PERF.PROTOCOL`; fijar propuesta `PERF.PG.SERVICE` con unidad, reloj,
  calentamiento, control, salida y criterios de §6/§7.3. No convertir la propuesta en presupuesto
  normativo nuevo antes de aprobación. Umbrales de E-PG-02 se evalúan tal como ya están definidos.
- [x] `PG-6A.10.02` Cargas deterministas de 10/100/1000 archivos, control de 10 000 líneas totales y
  carga ampliada identificada; cambios de cuerpo, firma, manifiesto, cerrado y fuente obsoleta.
  Incluir Unicode/UTF-16, nombres cortos válidos y proyecto vacío fuera del muestreo de latencia.
- [x] `PG-6A.10.03` Tests del generador/medidor/comparador con fixtures pequeños y reloj inyectado;
  negativo que cambie un resultado y otro que exceda el umbral. No ejecutar todavía la campaña.
- [x] `PG-6A.10.04` Implementar subcomando específico del trabajador de benchmarks existente y
  control frío sobre el mismo snapshot. Métricas del servicio separadas del RTT del host/proceso;
  instrumentación fuera del camino normal cuando no se solicita.
- [x] `PG-6A.10.05` README del trabajador/service: comando exacto, fuentes, semillas, máquina, coste
  de caché, hashes y límites. No escribir «incremental» como sinónimo de «evita reanalizar todo» sin evidencia.
- [x] `PG-6A.10.06` Ligera: compilar y probar solo módulos del generador/medidor; validar formato y
  procedencia de una muestra sintética, sin medir campañas ni optimizar por intuición.
- [ ] `PG-6A.10.07` Pesada, iteración 7: 30 muestras por proceso × 10 procesos por carga/escenario
  definido; p95 diagnóstico incremental ≤100 ms y rename ≤500 ms en la máquina identificada;
  equivalencia exacta con frío. Registrar resultados crudos y decisión de la persona sobre la métrica.

### PG-6A.11 · VSIX autónomo, instalación limpia y uso privado

- [x] `PG-6A.11.01` Fijar contrato de artefacto local: identidad y versión, VS Code mínimo/Stable,
  target, ejecutable/gramática, licencia, hashes y compatibilidad. Seleccionar solo plataformas
  disponibles para ensayo real; las restantes quedan sin afirmar soporte.
- [x] `PG-6A.11.02` Preparar ejemplos mínimos reproducibles de archivo y proyecto con importado,
  entrada, salida y error. Añadir casos de binario ausente/alterado, target equivocado, gramática
  vieja, dependencia runtime ausente, instalación anterior y directorio con espacios/acentos.
- [x] `PG-6A.11.03` Tests de ensamblado/lista de contenidos/hash y negativos de exclusiones. El
  empaquetado debe fallar si el binario no tiene procedencia o si la gramática requiere regenerarse.
- [x] `PG-6A.11.04` Construir CLI `--release --locked`, bundle y VSIX por plataforma mediante scripts
  de construcción del miembro; Cargo sigue ejecutándose en la CLI, nunca como toolchain interna
  de TS. Empaquetar únicamente artefactos declarados. Preparar los comandos locales de §7.4 y su reversión.
- [x] `PG-6A.11.05` README «Uso antes del lanzamiento»: F5, instalación VSIX, seleccionar entrada,
  ejecutar/Leer/detener, actualizar/revertir/desinstalar y obtener logs/versión. Indicar estado previo
  a producción y plataformas ensayadas sin afirmar que instalarlo certifica el lenguaje.
- [x] `PG-6A.11.06` Ligera: lista de contenido, metadata, hashes, avisos y bundle; producir VSIX sin
  ejecutar aún host limpio, campaña de instalación o publicación. Registrar nombre/ruta/hash reales.
- [x] `PG-6A.11.07` Pesada, iteración 7: instalar desde cero en directorios aislados y en el VS Code
  habitual cuando la persona lo use; comprobar proyecto sencillo sin Rust/Node/Cargo/checkout,
  sin red de instalación, actualizar, revertir a VSIX anterior compatible y desinstalar. Conservar
  paquete calificado e instrucciones; no ejecutar `vsce publish`, Open VSX ni workflow productivo.

## 5. Capas y archivos

Esta tabla responde las tres preguntas de `AGENTS.md` §1. Los nombres nuevos son candidatos; la
responsabilidad y el sentido de los imports son obligatorios. Se conservan archivos dueños existentes
cuando ya hacen esa tarea; no se concentra el workspace en `lsp_session.rs` por comodidad.

| Familia de archivos | Capa y responsabilidad única | Puede importar | Prohibido / dueño que se conserva |
|---|---|---|---|
| `docs/plan-ejecucion-proposito-general/fase-pg-6a-plan-ejecucion.md` y referencias del plan general | Documentación transitoria de raíz | Enlaces internos de docs y fuentes consultadas | No ser dependencia de corpus/código/README |
| AGENTS y README raíz | Política e inventario | Describir miembros/cadenas autorizados | No lógica de producto; solo cambiar tras `PG-6A.01` |
| `pseudolearn_spec/specifications/{api,tool,perf}/` y datos de conformidad | Corpus: contratos/casos/vínculos | Identidades internas del corpus | Sin enlaces externos/docs; congelamiento y oráculo independiente |
| `pseudolearn_spec/crates/{see_model,see_format,see_validation,see_conformance,see_export}/` si hace falta | Esquema, validación, proyección de caso y exportación, cada uno en su dueño | Matriz actual de `architecture.yaml` | Sin importar motor ni clientes; no sumar un sujeto VS Code si bastan host tests |
| `pseudolearn_engine/crates/pseudolearn_project/src/` | Catálogo, manifiesto y resolución pura | `pseudolearn_source` | Sin disco, semántica ni service; reutilizar rutas y autoridad existentes |
| `pseudolearn_semantic/src/project*.rs` y nuevo índice si procede | Identidad semántica de declaraciones/usos entre módulos | Dependencias actuales de su capa, incluido project | Sin service/API/UI; no duplicar resolución de símbolos en cliente |
| `pseudolearn_service/src/workspace_*.rs` | Snapshot, overlay, dependencias e invalidación | Source, diagnostics, lexicon, syntax, semantic y project **tras declararlo** | Sin VM/runtime/AOT/API/CLI ni E/S de host |
| `pseudolearn_service/src/lsp_*.rs`, `workspace_rename.rs`, `semantic_tokens.rs` | Adaptación de consultas y propuesta de ediciones | Servicio y capas permitidas | Sin ejecutar ni escribir archivos; separar transporte de semántica |
| `pseudolearn_api/src/project_*.rs`, nuevo `project_execution.rs` si corresponde | Frontera pública total de proyecto/sesión VM | Matriz vigente de API | Sin consumidores ni E/S; `ExecutionResource` sigue siendo dueño de la sesión |
| `apps/pseudolearn_cli/src/lsp_*.rs`, `project_*.rs`, `editor_*.rs` | Transporte, carga confinada y control de procesos/sesiones | Solo API pública y dependencias CLI permitidas | Sin internos de engine; ampliar una dependencia externa exige revisar reglas y licencias |
| `pseudolearn_bench_worker/src/` y README | Medición dirigida de workspace | Imports ya declarados del trabajador | Sin instrumentación obligatoria en el camino normal ni otra suite general |
| `apps/pseudolearn_vscode/src/contracts/` propuesto | Tipos de sesión/configuración y puertos propios | Tipos TS y datos de contrato | Sin `vscode`, Node de host ni implementación de Rust |
| `apps/pseudolearn_vscode/src/application/` propuesto | Casos de uso: comandos/ciclo de sesión | Contracts y puertos inyectados | Sin `vscode`, `child_process`, fs ni dependencias inversas |
| `apps/pseudolearn_vscode/src/adapters/` propuesto | Adaptadores editor, LSP, procesos y artefactos, en archivos separados | Contracts/application; `vscode`, SDK LSP y Node según adaptador | Sin parser propio; ningún adaptador importa activación |
| `apps/pseudolearn_vscode/src/activation/` propuesto | Composición y registro/desregistro | Capas inferiores de la app | Sin política semántica ni estado global compartido entre raíces |
| `apps/pseudolearn_vscode/scripts/`, `syntaxes/`, recursos, pruebas | Generación/paquete, datos generados y tests espejo | Exportación/artefactos declarados; herramientas de build fijadas | Sin depender de frontend ni regenerar sintaxis a mano |

Límites vigentes de Rust: archivo 300 líneas, función 40, cuatro parámetros posicionales, anidación 3
y siete métodos públicos; nombres semánticos y sin los componentes prohibidos del archivo de reglas.
Rust nuevo declara `#![forbid(unsafe_code)]` donde corresponde. No se requiere `unsafe` nuevo.

Para TS se propone el mismo máximo de 300 líneas/40 por función, cuatro parámetros, anidación 3 y
siete métodos públicos, con verificador propio que también cuente callbacks. Excepciones de generados
solo para rutas declaradas y comprobadas por su generador; nunca excluir código propio por su nombre.
La persona puede elegir límites más estrictos en `PG-6A.02.01`; no se copian los del frontend a ciegas.

Tests de caja negra en `tests/` espejo; internos Rust en `<module>_tests.rs`. Verificadores con
fixtures negativos fuera del recorrido normal. Ayuda, gramática y tablas generadas conservan dueño único.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Coste y controles

| Dimensión | Puerta o medición | Control y consecuencia |
|---|---|---|
| Diagnóstico incremental | E-PG-02: p95 ≤100 ms | Misma máquina/carga/configuración, igualdad con frío; incumplir bloquea el experimento |
| Rename | E-PG-02: p95 ≤500 ms | Incluir producción del conjunto completo; no medir solo búsqueda de un nombre |
| Frío/caliente | Medir carga, primera consulta, firma/cuerpo/manifiesto por separado | Sin atribuir arranque de Electron al compilador ni excluir trabajo de indexación diferido |
| Memoria y cachés | Medir RSS y bytes retenidos por snapshot/índice y tras cerrar raíces | Cantidad de revisiones y peticiones retenidas acotada; ninguna caché infinita |
| Arranque/VSIX | Medir activación, arranque LSP, primer diagnóstico, bytes VSIX/binario/bundle | Baseline del primer artefacto mínimo y candidato final en mismo host; sin umbral normativo inventado |
| Cancelación | Propuesta operativa: confirmar solicitud/fin en ≤2 s en fixture costoso | Tiempo de servicio separado del límite de terminación forzada; si no cumple, corregir antes de host tests |
| Artefactos existentes | Mantener presupuestos vigentes cuando el cambio alcance su build | Grafo y medición del artefacto afectado; no recompilar Wasm/iOS por agregar archivos TS |

Los valores nuevos de la siguiente tabla son **candidatos operativos del borde**, que se validan con
las cargas antes de fijar contrato. No reducen máximos del lenguaje ni recortan programas silenciosamente.

| Recurso | Propuesta inicial | Exceso o saturación |
|---|---|---|
| Mensaje LSP/editor | 16 MiB de cuerpo, 8 KiB de cabeceras LSP | Rechazo/cierre controlado; validar tamaño antes de reservar memoria |
| Cola de peticiones | 128 pendientes; coalescer notificaciones redundantes solo si se preserva revisión | Contrapresión o resync explícito; nunca perder una edición y seguir como si nada |
| Salida visible | 1 MiB retenido por sesión, con lectura continua del pipe | Aviso de límite; seguir drenando o terminar según contrato, sin bloquear al hijo ni cortar UTF-8 |
| Revisiones | Snapshot actual, anterior necesario y los fijados por trabajo vivo | Liberar al cancelar/terminar; bloquear retención indefinida |
| Reinicio de LSP | Hasta 3 intentos en 60 s | Detener reinicio automático, mostrar error y permitir acción manual |
| Proceso sin respuesta | Cancelación cooperativa; terminación del hijo propio tras 2 s de gracia | Informar aborto y limpiar recursos del cliente |

Si la carga de 1000 archivos no cabe en 16 MiB de un mensaje, usar la sincronización ya dividida por
documentos/snapshot o revisar el límite con evidencia; no rebajar E-PG-02 para hacer verde la campaña.

### 6.2 Seguridad verificable

- Texto, manifiesto, URI, configuración y salida del programa se tratan como entradas no confiables.
  Ninguna de ellas puede elegir shell, ejecutable, argumento de instalación ni script automático.
- Procesos con ruta y vector de argumentos, sin shell. LSP y ejecución usan pipes separados; nombres
  de archivo con comillas, `;`, `$` o espacios siguen siendo argumentos, no código.
- Lectura bajo capacidades/raíces explícitas; symlinks, rutas portables, Unicode y colisiones usan
  dueño existente. Revalidar después de resync; un prefijo textual de ruta no es confinamiento.
- Límite comprobado antes de asignar buffers de framing; JSON inválido, EOF y errores de E/S producen
  fallos tipados o errores de protocolo, sin pánico ni promesas rechazadas sin atender.
- No telemetría añadida ni envío de fuentes/cintas. Logs técnicos locales acotados; no registrar
  entrada del estudiante, cabeceras sensibles ni variables de entorno completas por omisión.
- Markdown de ayuda sin confianza, HTML ni comandos activos; ejemplos nunca se ejecutan al mostrarse.
- Semilla, límites y autoridad se entregan explícitamente. Ningún permiso se gana por instalar el VSIX.

## 7. Pruebas y experimentos

### 7.1 Política de selección y comandos

**Ligeras, iteraciones 1–6.** Solo las que correspondan al cambio de esa iteración:

- Documentación: diff, enlaces, IDs/casillas y puerta `DOC-NO-TRANSIENT-REFS` con sus negativos.
- Corpus tocado: `see validate`, `see lock --check`, `see export --check` desde el miembro spec;
  refrescar solo anclajes editados y regenerar exportación cuando corresponda. No ejecutar conformidad.
- Rust tocado: `cargo check --locked -p <crate>`, `cargo test --locked -p <crate> --lib <filter>` o
  binario espejo concreto, Clippy del crate con sus targets pertinentes y reglas de capas/nombres/
  comentarios/límites. El filtro debe ejecutar al menos un test; registrar cantidad y no aceptar cero
  como evidencia. Rustfmt solo comprueba/formatea archivos tocados según operación requerida.
- TS tocado: tipos, lint, tests unitarios filtrados y reglas del miembro. La iteración 2 define scripts
  separados de tipos, reglas, unitarias, generación/check, bundle, package, host e integración; no se
  presume que esos nombres de comandos existen antes de crearlos y documentarlos.
- Generadores/paquete: fixtures pequeños, negativos, reproducibilidad, inspección de contenido y
  hashes. Construir un bundle o empaquetar un VSIX no equivale a probar el host instalado.
- Gráficos de dependencias y licencias cuando cambie una dependencia; lock de aplicación actualizado
  y comprobación congelada. La descarga inicial de herramientas/VS Code de tests es preparación;
  las pruebas de producto no dependen de Internet.

**Pesadas, solo iteración 7.** Unión de todas las `.07`, una vez cada frontera cubierta: corpus de
IDs tocados, propiedades dirigidas, CLI/LSP reales, dos clientes, host Electron, seguridad del borde,
E-PG-02 y VSIX limpio. Reutilizar evidencia de una misma corrida para varios puntos; no repetirla once veces.

**Nunca por defecto.** `cargo test --workspace`, `cargo xtask verify` global, conformidad de todos
los IDs/sujetos, suites Flutter/web/backend/brand, diferencial AOT general, campañas HTTP o benchmarks
puros. Las órdenes globales actuales encadenan trabajo ajeno: descomponer las puertas pertinentes
y conservar todos los verificadores afectados, sin llamar «verificación completa» a la selección.

**Disparadores cerrados de ampliación:** cambio de esquema SEE → formato/validación/exportación y
proyección del sujeto afectado; cambio de identidad/coordenadas → API+LSP y consumidor de esa coordenada;
cambio del bombeo VM → pruebas de archivo suelto y proyecto; cambio de gramática/exportación → generador
y léxico consumidor; fallo dirigido → ampliar solo a sus dependencias y llamadores. Si un cambio común
alcanza Wasm o puente, probar esa frontera y medir su artefacto; no ignorarla por pertenecer a otra fase.

### 7.2 Matriz mínima de caminos felices, fallos y bordes

| Superficie | Feliz | Infeliz | Límite explícito |
|---|---|---|---|
| Snapshot | Importado cerrado aparece y navega | Watcher perdido o manifiesto inválido | Sin archivos, raíz borrada, dos raíces con mismo nombre |
| Edición | Overlay manda sobre disco | Versión repetida/antigua, respuesta tardía | Cierre durante análisis, Unicode no BMP y CRLF |
| Resolución | Símbolo público por alias | Privado/sombreado/colisión de rutas | Nombre de un carácter y caminos NFC/NFD |
| Rename | Cambia declaración y todos sus usos | Colisión, keyword, cambio concurrente o cliente sin garantía | Sin referencias, cerrado modificado, cero ediciones parciales |
| LSP | Initialize/query/shutdown/exit | Framing/JSON inválido, crash/EOF | Máximo de cuerpo y máximo + 1; cola llena y cancelación |
| Configuración | Campo resuelto con procedencia | Esquema/campo inválido y permiso no concedido | Dos raíces distintas; UI es y código en |
| Gramática | Ambos perfiles y compuestos | Generado viejo o keyword dentro de nombre | Cadena/comentario incompletos, fuente vacía |
| Ejecución | Proyecto con import y Leer/Escribir | Error de módulo, permiso denegado, binario incompatible | Entrada vacía/EOF, infinito, cancelación esperando entrada |
| Comandos | Formato idempotente/traducción revisable | Colisión o revisión obsoleta | Cancelar guardado, selección ausente y documento sin ruta |
| Ayuda | Hover/explicar misma identidad/rango | Consulta vieja y marcado activo | Sin entidad y contenido superior al límite existente |
| Paquete | VSIX autónomo carga y ejecuta | Falta binario/dependencia o hash incorrecto | Ruta con espacios, modo offline, usuario sin toolchains |
| Ciclo de vida | Reinicio recupera overlays | Bucle de reinicios | Cierre repetido y salida tardía del hijo anterior |

Fixtures de infraestructura están en tests espejo; casos normativos viven en corpus. No se usa una
captura del comportamiento actual como esperado de una regla nueva.

### 7.3 E-PG-02: protocolo completo

1. Registrar CPU, RAM, SO, arquitectura, estado de energía, versiones/toolchain, revisiones y hashes,
   configuración, semilla y condiciones de medición según `PERF.PROTOCOL`. No medir con compilaciones
   u otra campaña pesada simultáneas. Conservar las muestras originales.
2. Generar proyectos válidos en ambos perfiles con 10/100/1000 archivos. Mantener control de 10 000
   líneas totales al variar número de archivos; declarar por separado carga ampliada, tamaños y
   topología de dependencias. No sustituir 1000 por 100 ni sumar muestras de cargas distintas.
3. Por carga medir frío, edición de cuerpo, edición de firma exportada, cambio de manifiesto y
   consulta/rename que alcanza un cerrado. Para cada revisión, producir el control frío completo
   fuera del intervalo incremental y exigir diagnósticos, símbolos, referencias y ediciones iguales.
4. Preparar secuencias Unicode/UTF-16, evento omitido, revisión obsoleta y cancelación como pruebas
   de corrección; no mezclar su tiempo de rechazo con la latencia de una consulta exitosa.
5. Ejecutar 30 muestras por proceso en 10 procesos para cada carga/escenario definido, con
   calentamiento separado conforme a `PERF.PROTOCOL`; alternar candidato/control donde corresponda.
   Informar distribución y p95, sin sustituirlo por promedio ni eliminar muestras lentas sin causa registrada.
6. Diagnóstico incremental ≤100 ms y rename ≤500 ms son los umbrales de E-PG-02 en la máquina
   identificada. Medir por separado el RTT de `pseudo lsp` y del host VS Code. No vender la medición
   en proceso como latencia de toda la UI.
7. Si falla igualdad, corregir antes de interpretar rendimiento. Si falla latencia, perfilar e
   introducir únicamente reutilización por dependencia justificada; repetir escenarios afectados y
   sentinelas de resultado, sin imponer un límite nuevo al programa para ocultar el coste.
8. Registrar conclusión, alcance de plataforma y decisión sobre `PERF.PG.SERVICE`. Un umbral nuevo
   no se da por aprobado porque el candidato lo cumpla; el resultado favorable tampoco certifica otro SO.

### 7.4 Uso local sin publicación y ensayo de instalación

Los nombres finales de scripts/artefactos se escriben en el README al implementarlos. Estas son
operaciones de la ruta de prueba, no comandos que ya funcionen en el repositorio actual:

1. **Desarrollo:** generar exportación/gramática, compilar CLI con su Cargo y bundle con la cadena del
   miembro; seleccionar configuración de extensión en VS Code y pulsar F5. Se abre Extension
   Development Host. Abrir ejemplo válido/inválido y comprobar que no se ejecuta al abrirlo.
2. **Empaquetado:** ejecutar VSCE local fijado, equivalente a `pnpm exec vsce package --target <target>`
   con opciones de bundling validadas. Inspeccionar primero con `vsce ls`, registrar ruta y SHA-256.
3. **Instalación aislada:** usar directorios temporales propios con `code --user-data-dir <user-dir>
   --extensions-dir <extensions-dir> --install-extension <archivo.vsix>`. Abrir la misma instancia
   aislada con el proyecto de prueba. No compartir directorios de perfil con la sesión habitual.
4. **Comprobación funcional:** diagnosticar error y corregirlo, completar, navegar a cerrado, rename,
   formato, traducción, hover/explicar, elegir entrada, ejecutar, aportar línea y detener. Ensayar
   Restricted Mode por separado, sin desactivar Workspace Trust para hacer pasar la prueba.
5. **Autonomía:** ocultar las toolchains y checkout del entorno del proceso de test sin cambiar el
   PATH del sistema; usar solo VS Code, VSIX y ejemplos copiados. Deshabilitar descarga del producto
   durante el ensayo; no basta tener un binario de desarrollo disponible por casualidad.
6. **Uso habitual de la persona:** `Extensions: Install from VSIX…` o `code --install-extension
   <archivo.vsix>`. No se hace esta modificación de su perfil habitual sin que la persona lo pida;
   la instalación aislada ya deja un resultado concreto y revisable.
7. **Actualización y reversión:** instalar el VSIX nuevo con la misma identidad y comprobar estado;
   conservar paquete anterior compatible, desinstalar/reinstalar explícitamente para la reversión.
   Volver al VSIX anterior no implica soporte de sintaxis anterior. Desinstalar extensión cierra sus
   procesos y no borra los programas del usuario.

La documentación distingue el aviso de confianza sobre un VSIX local de un envío a revisión de
Marketplace. No se promete saltar restricciones administrativas del equipo. La preparación de los
hosts de test puede necesitar descargar VS Code una vez; la instalación del VSIX final no descarga el motor.

### 7.5 Selección pesada y procedencia

Antes de la iteración 7 cerrar una lista de **IDs realmente editados**, crates, tests y consumidores.
Como base, incluir `API.PROJECT`, `API.PROJECT.MANIFEST`, `TOOL.SERVICE.INCREMENTAL`,
`TOOL.SERVICE.NAVIGATION`, `TOOL.LSP.CAPABILITIES` y contratos nuevos de workspace/control que se
hayan creado. Añadir `API.EXECUTE`, `TOOL.CLI.RUN`, formato/traducción/catálogo/hover e identidad
solo en sus sujetos activos y fronteras efectivamente tocadas. No inventar un filtro inexistente.

Desde `packages/pseudolearn_spec`, por ID y sujeto declarado: `cargo run --locked -p see_cli --bin see
-- conform --subject <subject> --only <ID>`. Propiedades dirigidas con `--operation properties` y
el filtro soportado, comprobando que el sujeto realmente las ejecutó. Conservar cada resultado con
su hash antes de la siguiente orden, porque las salidas de conformidad pueden sobrescribirse.

AOT no es sujeto de LSP ni del modo editor de VM: no añadirlo para rellenar una matriz. Si se toca
una función de compilación compartida, activar sus casos ejecutables AOT por ese motivo concreto.
Las comprobaciones mecánicas de miembros afectados siguen en verde aunque la selección funcional
sea parcial. Registrar explícitamente lo omitido y su razón.

Cada evidencia indica tarea(s), orden exacta, cwd, revisión, versión/hashes de herramientas,
resultado/cantidad, salida guardada y límites. El VSIX calificado debe coincidir con el binario y
gramática probados; si cambia después, repetir la validación de esa frontera y su instalación.

## 8. Riesgos y señales tempranas

| Riesgo | Señal temprana | Tratamiento y dueño |
|---|---|---|
| `K-03` Fuente/revisión incorrecta | Definición apunta a otra raíz o edición vieja | Identidad compuesta, validación de revisiones y prueba frío/incremental; source/service/API |
| `K-10` VSIX solo funciona en checkout | Falta SDK runtime o binario en host limpio | Bundle inspeccionado, binario incluido y ensayo sin toolchains; extensión |
| Cancelación aparente | UI dice detenido pero proceso continúa | Recepción separada, lotes, recurso cancelado y plazo del hijo; CLI/extensión |
| Rename parcial | Un cerrado cambia entre cálculo/aplicación | Modelos sincronizados/versionados, edición solo textual y capacidad transaccional; rechazo de cambios detectados; sin prometer transacción de disco |
| Configuración amplía permisos | Workspace selecciona binario o red | Config sensible de usuario y autoridad del anfitrión; extensión/CLI |
| Gramática/editor se apartan del lenguaje | Keyword nueva sin color o tabla manual TS | Generación y negativos de obsolescencia; corpus/generador |
| Ayuda duplicada | Prosa editorial aparece en bundle propio | Consulta común y scanner extendido al miembro; service/extensión |
| Caché incorrecta | Latencia mejora y cambia un diagnóstico | Igualdad exacta con frío antes de medir; service/semantic |
| Coste fuera de alcance | Se modifica VM/AOT para acelerar LSP | Recortar al índice/dependencia medidos; optimización general sigue fuera |
| Confusión entre preview y privacidad | Se propone `vsce publish --pre-release` para probar | Usar F5/VSIX; publicación pertenece a fase futura |
| Target/host erróneo | VSIX macOS intenta arrancar en remoto Linux | Identificar host real y rechazar compatibilidad ausente; empaquetado |
| Disco insuficiente | Compilación CLI/Electron ocupa espacio restante | Medición previa, cachés compartidas y limpieza acotada de §13 |

## 9. Dependencias de la persona

| Momento | Decisión o aportación |
|---|---|
| Este encargo | Creación documental autorizada; retiro del migrador reconfirmado. No preguntar otra vez |
| Antes de implementar | Revisar plan y autorizar punto/iteración o grupo concreto; aceptación expresa puede cubrir varias iteraciones |
| `P1` | Resolver `CF-20`: ruta/cadena/derechos de `PG-6A.01`; confirmar identidad local y plataforma(s) que realmente puede probar |
| Corpus | Revisión independiente y reanclaje según política vigente; no atribuir `revisado_por` a la persona sin evidencia. Identidades existentes conservan estado/versión |
| Preparación de herramientas | Si el entorno requiere aprobación de red/instalación para dependencias o hosts de test, solicitarla con versiones/tamaño concretos; no volver a pedir una autorización vigente |
| Uso diario | Instalar el paquete en su perfil habitual solo si lo pide; las pruebas usan directorios aislados y no necesitan alterar sus extensiones |
| `P7` | Revisar evidencia/pending de plataforma, resolver métrica candidata y autorizar publicación Git del cierre cuando no esté ya incluida en la autorización |

No son dependencias de PG-6A: cuenta Marketplace, token de publicador, revisión pública, licencia
abierta global, dispositivos físicos ni participantes. Publicación de extensión y lenguaje queda fuera.

## 10. Orden de ejecución y puntos de control

Antes de cada iteración: rama única, estado Git conocido, trabajo ajeno preservado y espacio en disco.
Se puede autorizar una iteración, puntos sueltos o un grupo. La IA respeta el alcance autorizado;
un punto de control no obliga a pedir otra vez decisiones ya aceptadas. Al terminar el alcance pedido,
informa y se detiene. El cierre de fase siempre exige nuevo mensaje antes de la siguiente (`PHASE-STOP`).

| Iteración | Trabajo concreto | Verificación inmediata | Punto de control |
|---|---|---|---|
| **1 · Decisiones y contratos** | `PG-6A.01`; `.01`/`.02` de `.03`–`.11`; casos derivados y mapa de contratos | Documentación e integridad del corpus tocado; ninguna campaña | **P1:** CF-20/identidad/derechos, revisión del contrato y anclajes antes de código dependiente |
| **2 · Miembro mínimo y color** | `.02` completo hasta `.06`, `.06` hasta `.06`, bases de `.05` y `.11` necesarias para paquete mínimo | Tipos, unitarias/negativos, gramática vigente, bundle y contenido VSIX | **P2:** artefacto temprano disponible para F5/VSIX, con funciones pendientes identificadas |
| **3 · Workspace común** | `.03.03`–`.06`; extracción compartida de semantic/API y carga confinada CLI; configuración común `.05` | Tests pequeños filtrados y reglas de crates tocados | **P3:** cerrado/overlay/resync correctos en memoria; registrar coste aún no medido |
| **4 · LSP de proyecto** | `.04.03`–`.06`, parte de `.08`, arnés/comparador `.09.03`–`.06` | Mensajes/framing falsos, fuente única y tests de handlers | **P4:** capacidades honestas, Unicode y ediciones seguras; sin lanzar campañas |
| **5 · Ejecución y comandos** | `.07.03`–`.06`, API/CLI de sesión, completar `.05`/`.08` hasta `.06` | Tests dirigidos API/CLI/TS; bundle y verificadores pertinentes | **P5:** comandos implementados y paquete de desarrollo disponible; sin migrador ni DAP |
| **6 · Arnés y artefacto candidato** | `.10.03`–`.06`, `.11.03`–`.06`, negativos de paquete, congelar selección pesada | Tests del medidor con reloj falso, ensamblado, hashes y avisos | **P6:** candidato identificable, matriz de pruebas final cerrada |
| **7 · Pesadas acotadas y cierre** | Todas las `.07`; §7.2–§7.5; cierre común C01–C13 | Corpus dirigido, procesos, hosts, dos clientes, E-PG-02 y VSIX limpio | **P7:** evidencia completa, pendientes tratados, Git y parada |

El primer VSIX de la iteración 2 es un incremento para comprobar construcción y facilitar uso,
no cumple `PG-6A.11` antes de ejecutar la instalación limpia de la iteración 7. Así las tareas
ligeras no esconden integración pesada en cada iteración.

Si falla una pesada: aislar el fallo, determinar dueño, derivar cualquier corrección del caso desde
la regla, corregir y repetir el test fallido con los sentinelas de su frontera. Repetir otra selección
solo si la corrección invalida su evidencia. No relanzar todas las pesadas tras una corrección de prosa.
No relajar umbrales, omitir cerrados ni eliminar escenarios para cerrar verde.

### 10.1 Cierre común verificable

- [x] `PG-6A.C01` Autorización explícita de implementación registrada.
- [ ] `PG-6A.C02` Plan detallado revisado por la persona; crearlo no equivale a aprobarlo.
- [x] `PG-6A.C03` SPEC-FIRST y congelamiento respetados.
- [x] `PG-6A.C04` Reglas nuevas con cobertura y vínculos como datos.
- [x] `PG-6A.C05` Feliz/infeliz/límites en carpetas espejo.
- [x] `PG-6A.C06` Capas, imports y límites comprobados, incluido miembro nuevo.
- [x] `PG-6A.C07` Código en inglés, sin comentarios/TODO, pánicos ni unsafe nuevo.
- [x] `PG-6A.C08` README/reglas actualizados y autosustentables, sin dependencia de docs.
- [x] `PG-6A.C09` Ayuda compartida integrada; no hay sintaxis nueva que exija fichas inventadas.
- [ ] `PG-6A.C10` Riesgos revisados, E-PG-02 reproducible y pendientes tratados por la persona.
- [ ] `PG-6A.C11` Tests seleccionados y todos los verificadores afectados en verde, con selección declarada.
- [x] `PG-6A.C12` Commit con skill `commit-message`, sin atribución de IA; push ordinario comprobado
  a `origin/feature/agregar-ruta-de-especificacion`. Ningún push publica un VSIX.
- [x] `PG-6A.C13` Resúmenes actualizados, paquete/ruta/hash e informe entregados; parada antes de PG-6B.

## 11. Resumen de ejecución

**PG-6A implementada; cierre formal pendiente de dos revisiones humanas y de la campaña E-PG-02.** Las `.07` se
ejecutaron salvo `PG-6A.10.07` (§11.4).
SEE exige revisión independiente antes de validar y reanclar el corpus, así que no se declara
`PHASE-GREEN` para las fases afectadas.

| Punto | Estado inicial de sus `.01`–`.07` | Evidencia | Motivo o comentario |
|---|---|---|---|
| `PG-6A.01` | No cumplido | | Requiere decisión de la persona sobre CF-20; propuestas concretas en §3 |
| `PG-6A.02` | No cumplido | | README/reglas antes de código; miembro aún inexistente |
| `PG-6A.03` | No cumplido | | Workspace y resync por implementar |
| `PG-6A.04` | `.01`–`.06` cumplidas localmente; `.07` ejecutada (§11.4) | Casos bilingües, handlers, framing y cliente stdio independiente; `lsp_process` 2/2 | SEE requiere revisión independiente; faltan host VS Code y pruebas pesadas completas |
| `PG-6A.05` | `.01`–`.06` cumplidas | Resolver, metadata, Restricted Mode, override de usuario y pruebas; manifiesto schema 1 conserva rechazos existentes | Sin host confiable/restringido real; revisión SEE común pendiente |
| `PG-6A.06` | `.01`–`.06` cumplidas localmente | Generación reproducible, `check:grammar`, pruebas TextMate real y negativos | SEE export check pasa; validación/reanclaje espera revisión independiente; host real pendiente |
| `PG-6A.07` | `.01`–`.06` cumplidas localmente; `.07` ejecutada (§11.4) | `start_project` (7 tests API), `--editor` (22 unitarias y 7 de proceso real), 51 tests TS, bundle y VSIX `darwin-arm64` generados; `TOOL.CLI.RUN#R7` y `API.PROJECT#R4` con casos C20–C22 y C18–C20, esquema SEE con `start_project` | Validar falla solo por `TOOL.SERVICE.WORKSPACE` sin revisión independiente (de PG-6A.03); la evidencia de propiedades de `API.PROJECT` queda obsoleta hasta la campaña pesada; sin host real de VS Code; migración retirada por la persona |
| `PG-6A.08` | `.01`–`.06` cumplidas localmente; `.07` ejecutada (§11.4) | `lsp_help_cases` 6/6, `lsp_help` 7/7, auditoría de fuente única recorre `apps/pseudolearn_vscode/src` con negativo `.ts`; comando `pseudolearn.explain` y 4 tests TS | Sin contrato nuevo (catálogo, hover y comando existentes); sin host real ni segundo cliente |
| `PG-6A.09` | `.01`–`.06` cumplidas localmente; `.07` ejecutada (§11.4) | Secuencia única de 25 pasos (`tests/fixtures/lsp_interop/sequence.json`), cliente B stdio independiente, normalizador (solo id de transporte y prefijo de URI) y comparador exacto con negativos; `cargo test --test lsp_interop` 15/15 | Sin transcripción del cliente A ni comparación A↔B (host real); sin corpus nuevo; ambos clientes comparten motor |
| `PG-6A.10` | `.01`–`.06` cumplidas localmente; `.07` pendiente | `service workspace plan\|run\|summary` en el trabajador; cargas 10/100/1000 (+ ampliada), 5 escenarios muestreados y 4 de corrección; 30 pruebas nuevas de generador/medidor/comparador con reloj y transporte falsos (158/158 del trabajador); `plan` determinista comprobado dos veces | Campaña 30×10 sin ejecutar; solo RTT de `pseudo lsp` (medición en proceso del servicio pendiente por imports del trabajador); propuesta `PERF.PG.SERVICE` sin aprobar |
| `PG-6A.11` | `.01`–`.06` cumplidas localmente; `.07` ejecutada (§11.4) | `artifact.contract.json`, `build-cli.mjs` (`cargo build --locked --release`), verificación de procedencia/contenido/bundle/hash en el empaquetado, 73 tests TS (22 nuevos con negativos), ejemplos validados con `pseudo`; VSIX `darwin-arm64` generado, sha256 `6bb1d67e…dd07f` | Sin instalación en VS Code, sin host limpio ni VSIX anterior para revertir; árbol Git sucio al construir; no es paquete calificado |

### 11.1 Registro obligatorio por tarea al ejecutar

| Tarea individual | Estado de §2.2 del plan general | Orden/evidencia y resultado | Omisiones, motivo y consecuencia |
|---|---|---|---|
| `PG-6A.04.01`–`.05` | Cumplido | Contratos LSP/navegación, casos bilingües y README actualizados | Conformidad/reanclaje SEE pendiente de revisión independiente |
| `PG-6A.04.03`–`.04` | Cumplido | Handlers, transporte 8 KiB/8 MiB, cola 8, cancelación prioritaria; pruebas espejo | Host VS Code y campaña completa quedan en `.07` |
| `PG-6A.04.06` | Cumplido localmente | `cargo check`, Clippy, rust-checks y pruebas dirigidas; stdio independiente pasa 2/2 | 12 pruebas de red de la suite CLI dieron `EPERM`; pruebas LSP afectadas pasan |
| `PG-6A.04.07` | Cumplido (§11.4) | Proceso `pseudo lsp` real (cwd `apps/pseudolearn_cli`, rev `055ee879` + árbol sin commit): `cargo test --locked --test lsp_process --test lsp_process_rename --test lsp_process_lifecycle` pasa 1+1+4. Cancelación de rename sobre 600 archivos abiertos responde `-32800` no más tarde que la consulta completa y la sesión sigue útil; cancelar id desconocido es inocuo; EOF sin `exit` termina con código 1 y un proceso nuevo recupera; rename válido produce `documentChanges` multiarchivo y palabra reservada/identificador inválido/vacío devuelven `-32602` sin ediciones | Falta el host VS Code y la equivalencia en dos clientes: la extensión no tiene cliente LSP. Hallazgo corregido: más de ~8 notificaciones `didOpen` seguidas desbordaban la cola compartida y el servidor salía con código 1 sin diagnóstico. Ahora las notificaciones tienen límite propio de 256 (consultas siguen en 8); pruebas `open_notification_burst_does_not_end_the_session` y `notifications_burst_beyond_the_query_limit_until_the_message_limit`, README del CLI actualizado. La prueba de 600 archivos sigue sincronizando cada apertura por superar 256 |
| `PG-6A.05.01`–`.05` | Cumplido | Configuración por procedencia, settings y adaptador de VS Code documentados | API de proyecto no cambió; TOML schema 1 conserva su contrato |
| `PG-6A.05.06` | Cumplido | Tipos, arquitectura, comentarios, tamaño, paquete y tests de extensión; 21 tests pasan | Revisión SEE común pendiente |
| `PG-6A.05.07` | Cumplido (§11.4) | Casos de resolver cubren Restricted Mode y revocación de confianza | No ejecutable aún: la extensión no arranca ni selecciona binario, así que no hay host confiable/restringido, persistencia de selección ni symlink real que probar. VS Code 1.144.0 está instalado en `/Applications` para cuando exista |
| `PG-6A.06.01`–`.05` | Cumplido | Exportador SEE alimenta gramática TextMate y configuración declarativa con hash | Datos léxicos nuevos residen en el corpus/exportador |
| `PG-6A.06.06` | Cumplido localmente | `see export --check`, `check:grammar`, TextMate real y negativos pasan | `see conform`/validación bloqueados hasta revisión independiente |
| `PG-6A.06.07` | Cumplido (§11.4) | Tokenización real en prueba aislada; con `media/pseudolearn.tmLanguage.json` alterado, `pnpm check:grammar` falla (código 1) y con el original restaurado pasa; `pnpm package` encadena ese check vía `build`, `check:package` por sí solo no lo detecta | Resaltado en host real y tras tokens semánticos no ejecutado: no hay proveedor semántico ni cliente en la extensión |
| `PG-6A.09.01`–`.06` | Cumplido localmente | `cargo test --locked --test lsp_interop` (cwd `apps/pseudolearn_cli`): 15 pasan; Clippy y `rust-checks all .` en verde | Cliente A y comparación A↔B en `.07`; fixture con errores fuera del snapshot porque un proyecto inválido no responde consultas |
| `PG-6A.10.01`–`.06` | Cumplido localmente | `cargo test --locked -p pseudolearn_bench_worker` (cwd `packages/pseudolearn_engine`): 158 pasan (30 nuevos); Clippy y `rust-checks all .` en verde; `service workspace plan` dos veces con igual resultado y rechazo de sobrescritura | Sin campaña; umbrales 100/500 ms evaluados tal como están, sin crear umbrales nuevos |
| `PG-6A.11.01`–`.06` | Cumplido localmente | `pnpm check:types`, `check:architecture`, `check:comments`, `check:size`, `check:package`, `test` (73) y `package` en verde; VSIX `apps/pseudolearn_vscode/.artifacts/pseudolearn-0.1.0-darwin-arm64.vsix`, 7101360 bytes, sha256 completo `6bb1d67e06ce4c83c4ea76e83fa4f97e88977956527791c8e328c16e102dd07f` | Binario compilado con `--release --locked`; árbol sucio (cambios sin commit); instalación y host limpio en `.07` |

Añadir una fila por `.nn.mm` y por `Cnn` con evidencia nueva. Usar únicamente Cumplido, No cumplido,
Diferido, No aplica o Retirado, con sus condiciones. Una autorización humana no se infiere del silencio.

Revisión Git de cierre: **pendiente**. Verificadores: extensión (tipos, arquitectura, comentarios,
tamaño, paquete, gramática y build) en verde; `rust-checks all .` y Clippy en verde; pruebas dirigidas
Rust y CLI en verde salvo pruebas de red bloqueadas por `EPERM`; `see export --check` en verde.
`see validate`/`see conform` y reanclaje esperan revisión independiente. No se produjo un VSIX calificado;
publicación Marketplace fuera de alcance.

### 11.4 Verificación pesada de la iteración 7

Máquina: macOS (Darwin 27.0.0), Apple silicon, VS Code Stable 1.144.0, Rust 1.99.0, Node 22.23.3, pnpm 12.8.1. Revisión base
`4b3629a4` con cambios sin commit hasta el commit de cierre.

| Tarea | Orden y resultado | Límites y consecuencia |
|---|---|---|
| `PG-6A.04.07` | `cargo test --locked --test lsp_process --test lsp_process_rename --test lsp_process_lifecycle --test lsp_interop` (cwd `apps/pseudolearn_cli`): 1+1+5+15 pasan, incluida cancelación de rename en 600 archivos, EOF sin `exit`, ráfaga de `didOpen` y batería de rename con rechazo sin ediciones; host real: definición a archivo cerrado, rename multiarchivo como una edición y revertido, rechazo de palabra reservada | La conformidad dirigida por ID no se ejecuta: `see validate` falla con `SEE-STATE: independent review required`; hasta esa revisión no se reancla ni se concede conformidad |
| `PG-6A.05.07` | Host real `tests/host/run-host.mjs restricted` (4/4: sin confianza, activación, análisis con binario incluido, ejecución rechazada) y `trusted` (20/20); ruta con espacios y acentos en directorio de usuario y extensiones; raíz con symlink de escape rechazada por `pseudo comprobar --proyecto`; binario alterado y gramática obsoleta rechazados por `scripts/package.mjs`; override relativo o de workspace rechazado por pruebas unitarias | El modo `trusted` usa `--disable-workspace-trust` (sembrar la confianza en `state.vscdb` no surtió efecto); la persistencia de la entrada elegida entre sesiones depende de `workspaceState` y solo tiene prueba unitaria; cambio de confianza en caliente, manual |
| `PG-6A.06.07` | `pnpm check:grammar`, tokenización con motor TextMate real y rechazo de paquete con gramática alterada; host real: tokens semánticos `full` devueltos por el servidor sobre el proyecto de ejemplo | El color renderizado en la ventana no se observa por API: revisión visual manual de una muestra de cada familia |
| `PG-6A.07.07` | Host real: diagnóstico desde overlay sin guardar, formato idempotente, hover, completado, símbolos, ejecutar proyecto con entrada elegida y detenerlo sin procesos restantes, ejecutar archivo con `Leer` y detener, ejecución rechazada con cambios sin guardar, reinicio del servidor con un solo hijo; entorno con `PATH=/usr/bin:/bin` | Escribir un valor concreto en el cuadro de entrada y la traducción con selector se comprueban a mano |
| `PG-6A.08.07` | Host real: hover y `pseudolearn.explainAtCursor` responden; `lsp_help` y `lsp_help_cases` de la entrega ligera | Conformidad de catálogo/hover bloqueada por la misma revisión SEE; paridad con segundo cliente cubierta por la repetición de `.09.07` |
| `PG-6A.09.07` | `PSEUDOLEARN_HOST_TRANSCRIPT` captura el tráfico real del cliente A; `tests/host/replay-transcript.mjs` lo reenvía a un `pseudo lsp` nuevo: 2 sesiones, 36 respuestas y diagnósticos finales idénticos, 0 diferencias; el cliente B stdio comparte la secuencia de `lsp_interop` (15/15) | La secuencia de VS Code la genera el SDK, no coincide paso a paso con la del cliente B; la equivalencia exigida es de respuestas y diagnósticos, no de transcripción completa. Ambos clientes comparten motor |
| `PG-6A.10.07` | `service workspace plan/run 0..9/summary` sobre el binario release de la CLI (Apple M2, 16 GiB, Rust 1.99.0, semilla 42, 30 muestras × 10 procesos × 4 cargas × 5 escenarios); crudos y `summary.json` en `packages/pseudolearn_spec/results/pg-6a-e-pg-02/` (ruta ignorada por Git) | **No cumple los umbrales.** Equivalencia exacta con el control frío: sí (ninguna muestra abortó). Rename: p95 ≤ 2,6 ms en las cuatro cargas, dentro de 500 ms, pero la medición solo cubre la petición cuando todos los documentos afectados ya estaban abiertos (la lectura sin ellos responde `-32803`; ver nota). Diagnóstico tras edición (100 ms): `files-100` 94,7–95,7 ms y `files-1000` 86,3–91,7 ms pasan; `files-10` (10 archivos de ~1000 líneas) 509–604 ms y `files-1000-extended` 1846–1933 ms **fallan**. El candidato cuesta lo mismo que el control frío (más 20–60 ms) en `files-10` y el doble en `files-1000-extended`: hoy cada edición reanaliza todo el proyecto, tal como el README del trabajador advertía |
| `PG-6A.11.07` | `code --user-data-dir --extensions-dir --install-extension` en directorios aislados con `env -i PATH=/usr/bin:/bin`: instalar VSIX anterior, actualizar (hash del binario instalado igual al del paquete), revertir a la anterior, desinstalar (`--list-extensions` vacío); host con el VSIX activa y diagnostica sin Rust, Node ni checkout | Misma versión `0.1.0` en ambos paquetes: la actualización se hizo con `--force`; no se instaló en el VS Code habitual (solo si la persona lo pide); sin red de instalación no se aisló a nivel de sistema, la prueba no descarga nada |

Defectos hallados por el host real y corregidos: el SDK añadía `--stdio` y `pseudo lsp` lo rechaza (el LSP nunca arrancaba);
el comando `pseudolearn.explain` del servidor colisionaba con el de la extensión (renombrada a `pseudolearn.explainAtCursor`);
nadie enviaba el snapshot de workspace al servicio (nuevo `lsp_workspace_loader.rs` en la CLI, con
`initializationOptions` de perfil y rigor desde la extensión). Verificadores tras la corrección: `pnpm check:*` y 73 pruebas TS,
7 pruebas nuevas del cargador, Clippy `-D warnings` y `rust-checks all` de la CLI en verde.

**E-PG-02, lectura honesta.** `all_within_threshold` es `false`. El coste crece con las líneas por archivo y con el total, no con
el número de archivos: 10 000 líneas repartidas en 10 archivos tardan ~480 ms en frío y en 1000 archivos ~27 ms, así que el cuello es
reanalizar documentos grandes completos en cada edición. Reutilizar por dependencia (firma frente a cuerpo, `D-PG6A-07`) es el trabajo
que el protocolo prescribe y no se hizo en esta fase; los umbrales no se relajan. La campaña corrió mientras se compilaba y se ejecutaban
pruebas del host en la misma máquina, lo que pudo añadir ruido; la diferencia con los umbrales es de 5× a 19×, mucho mayor que ese ruido.
Además el escenario `rename` no mide el rename con dependientes cerrados: el servidor exige documentos sincronizados y abiertos, y la
extensión los abre antes de renombrar; esa apertura (hasta 1000 `didOpen`) queda fuera de la medición y hay que incluirla al repetir la campaña.
La métrica candidata `PERF.PG.SERVICE` no se aprueba.

Defectos adicionales hallados por el uso manual y el host y corregidos: carpeta de archivos sueltos sin manifiestos recibía un snapshot
vacío y no mostraba diagnósticos (commit `26313c76`); el rename con dependientes cerrados fallaba en VS Code porque la extensión no
abría los documentos cerrados (ahora lo hace antes de cada rename, y la prueba de host ya no los abre a mano); el filtro de procesos de la
prueba de host contaba procesos de otras instalaciones. VSIX final de esta fase: `apps/pseudolearn_vscode/.artifacts/pseudolearn-0.1.0-darwin-arm64.vsix`,
sha256 `608472505e6c880748c4cd575b7d2d73f296a53340ee4fe8d0e2080f297ab378` (se vuelve a calcular si se reconstruye).

### 11.2 Decisiones ya confirmadas al preparar

| Fecha | Decisión | Consecuencia |
|---|---|---|
| 2026-10-30 | Cada cambio es oficial aunque sea incompatible; sin migrador ni retrocompatibilidad | `D-PG6A-11` vigente; se corrige mención antigua del plan general |

### 11.3 Verificación de la preparación documental

El 2026-10-30 se comprobaron 77 subtareas (once puntos por siete tareas), los trece cierres comunes,
las catorce secciones y los enlaces locales; ninguna tarea de implementación está marcada cumplida.
La puerta real `DOC-NO-TRANSIENT-REFS` del `xtask` de SEE se ejecutó mediante un lanzador temporal
compilado con el mismo Rust 1.99.0, sin encadenar la suite global; pasó en el repositorio actual.
También pasaron sus tres tests existentes, incluidos los negativos de referencias prohibidas,
y `git diff --check`. Se revisaron arquitectura/alcance y hechos de VS Code con fuentes oficiales.
No se ejecutaron tests del lenguaje ni se produjo un VSIX: todavía no se cambió código de producto.

## 12. Protocolo operativo para la IA ejecutora

1. Leer README/reglas de cada miembro antes de editar; contestar capa, imports y dueño de §5.
2. No crear la app antes de resolver CF-20. No repetir la pregunta sobre migradores: ya está resuelta.
3. Contrato → casos derivados → tests → código → README → ligera. Nuevas identidades del corpus
   estables `1.0.0`, sin `cambio`; existentes conservan identidad/estado/versión y se reanclan.
4. Editar bloques concretos del corpus, sin reserializar documentos completos. No capturar esperados
   del motor ni de VS Code; una captura solo aporta evidencia de integración revisada.
5. No copiar gramática, ayuda ni vocabulario. Los generados se generan y se comprueban, también en VSIX.
6. No implementar VM, parser, resolutor ni política de perfiles en TS. No importar API/VM desde service.
7. Mantener archivos pequeños, cero comentarios, código/IDs/tests en inglés y documentación en español.
8. No anunciar providers, hosts, platforms o garantías que los tests no cubren. Rechazar de forma
   visible lo no disponible, incluida plataforma del ejecutable y garantía insuficiente de rename.
9. No mezclar protocolo con salida del programa ni logs; acotar recursos antes de reservar y limpiar
   cada proceso, watcher, sesión y suscripción al detener/desactivar/cerrar.
10. Iteraciones 1–6 solo ligeras correspondientes. Todas las `.07` en 7, sin suites globales por rutina.
11. Si dos fuentes chocan, citar IDs y pedir decisión (`CONFLICT-REPORT`); continuar solo trabajo
    independiente. Las decisiones directas registradas de la persona no se reabren por una lista antigua.
12. Herramientas/dependencias fijadas y leídas en su versión exacta; registrar en README qué se toma
    y qué se descarta. Sin nuevas cadenas ni dependencias de otro miembro por conveniencia.
13. Fuera de alcance: Marketplace/Open VSX, `browser`/Wasm, DAP, dispositivos, otro plugin de editor,
    IDE propio, registro de paquetes, migradores y optimizaciones generales. PG-6B/PG-7 tienen sus puertas.
14. Sin ramas/worktrees adicionales, force push, limpieza indiscriminada ni commit espontáneo del plan.
    El cierre de implementación usa la skill de commits y autorización Git vigente.
15. Informar implementación, verificación, artefacto y límites; no equiparar paquete instalable con
    producción. Al terminar el alcance autorizado, parar; después del cierre no iniciar PG-6B.

## 13. Espacio en disco y procesos de prueba

Al preparar este plan, `df -h /` mostró aproximadamente **21 GiB disponibles**. Es una observación,
no una garantía para la ejecución. Electron, los binarios Rust y targets de plataforma pueden cambiarla.

Antes de cada build release, descarga de VS Code o campaña: medir `df` y tamaños de `target`, caché
de hosts y artefactos del miembro; estimar la operación con margen. Mantener solo las versiones de
VS Code de la matriz y reutilizar descargas entre tests. No construir todas las plataformas por rutina.

Se puede retirar incremental/caché regenerable identificada del trabajo propio que no tenga procesos
en uso. No borrar fuentes, locks, cambios ajenos, paquetes calificados ni resultados que sostengan una
comparación. Una limpieza que exceda esos artefactos necesita decisión concreta; sin espacio suficiente,
reducir compilaciones simultáneas o detener esa operación y reportar la necesidad.

Los directorios de usuario/extensiones de tests son temporales y propios; comprobar su ruta antes
de limpiarlos. Registrar espacio antes/después y procesos cerrados. No manipular el perfil habitual
del usuario para obtener un host «limpio».
