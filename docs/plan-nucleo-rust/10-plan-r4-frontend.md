# 10 · Plan de R4 · Front-end de Clepsidra

> **Estado:** propuesta detallada; R4 pendiente de autorización explícita (`PHASE-STOP`).
> Rama: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
>
> Este documento concreta [R4](07-fases.md), sobre la arquitectura de
> [Clepsidra](09-plan-r3-motor-clepsidra.md). Preparar y corregir el plan no inicia la fase.
> No hay código del motor ni resultados de rendimiento producidos por esta preparación.

## 0. Contrato de ejecución

R4 implementa el análisis completo de la edición 2026: fuente → vocabulario → tokens → árbol sin
pérdida → resolución de nombres → tipos → HIR → API → consumidores. Se conserva la gramática vigente.

Los bloques B0–B8 se ejecutan en orden después de autorizar R4. Dentro de la fase no hay una
autorización adicional por bloque. Un conflicto nuevo se reporta y se espera respuesta
(`CONFLICT-REPORT`); una aceptación fallida se resuelve antes del cierre (`PHASE-GREEN`).
La autorización de R4 debe confirmar las recomendaciones D-R4 de este documento o indicar cambios;
la autorización de esta preparación documental no las convierte en implementación aprobada.

El corpus es la autoridad sobre comportamiento. Los README de los miembros y crates son la autoridad
sobre arquitectura y operación. Este documento transitorio organiza trabajo: ningún consumidor lo
importa ni lo cita como dependencia (`DOC-NO-TRANSIENT-REFS`). Al adoptar una decisión propuesta, su
fundamento se incorpora al README dueño antes de escribir el código correspondiente.

### 0.1 Lecturas previas

- `AGENTS.md`, README raíz y este documento completo.
- README y reglas de `pseudolearn_engine`, cada crate de R4, `pseudolearn_spec`,
  `pseudolearn_rust_checks`, `pseudolearn_benchmarks` y `pseudolearn_cli`.
- Corpus `LANG`, `DIAG`, firmas de `LIB`, contratos estáticos `API`, contratos de comprobación e idioma
  `TOOL.CLI`, `TOOL.SERVICE.LOSSLESS-TREE`, `PERF.PROTOCOL` y `PERF.FRONTEND.THROUGHPUT`.
- Skills `layer-boundaries`, `code-quality`, `package-docs`, `language-spec-authoring`,
  `diagnostics-authoring`, `commit-message` y `phase-gate`, según la responsabilidad que se modifica.

### 0.2 Alcance y prohibiciones

| En R4 | Fuera de R4 |
|---|---|
| source, diagnostics, lexicon, syntax, semantic | Ejecución de programas, VM, runtime y recolector |
| API de análisis, errores, modelo, versionado e intercambio aplicable al análisis | API de ejecución y consulta de estado de ejecución |
| Adaptador engine y evidencia estática | Conformidad de execute, trace e ir, correspondiente a R5 |
| comprobar/check y preferencias/preferences | ejecutar/run, ri/ir, compilar/build, formatear, traducir y LSP |
| Firmas de incorporadas para comprobar llamadas | Implementaciones ejecutables de library |
| E-08 de reanálisis completo y throughput | Incrementalidad, salsa e identidad entre ediciones de R7 |
| Generación y propiedades necesarias para la aceptación estática | Nuevas construcciones o cambios del núcleo Dart congelado |

Se permite desarrollar en SEE el soporte mínimo para registrar sujetos Rust, seleccionar el alcance
estático y ejecutar las propiedades exigidas por R4. No se construye un sistema universal de generación
de programas, ni se importa el motor como dependencia Cargo de SEE. Cada miembro usa su cadena propia.
Las dependencias externas nuevas requieren necesidad concreta, declaración y auditoría; no hay
`unsafe`, `unwrap`, `expect`, índices sin comprobación ni comentarios de código.

## 1. Propuesta técnica

El diferencial es un análisis bilingüe que conserva los bytes de entrada, comparte identidades
abstractas y produce diagnósticos pedagógicos sin cascadas, con estructuras contiguas medibles.
Se combinan técnicas conocidas; no se atribuye novedad algorítmica ni superioridad sin medición.

```text
exportación del corpus ──► generadores de vocabulario, diagnósticos y vistas
                                      │
bytes ─► fuente UTF-8 verificada ─► tokens originales ─► árbol postorden recuperable
                                      │                         │
                              reimpresión exacta          esquema sintáctico
                                                                │
                                         sin errores léxicos ni sintácticos
                                                                ▼
                                  ámbitos y símbolos ─► tipos ─► HIR tipado
                                                                │
                                                     API de análisis pública
                                                       │               │
                                                adaptador engine    CLI pseudo
```

El esquema de unidades se obtiene de sintaxis aunque haya errores recuperables (`API.ANALYZE`).
El árbol recuperado no habilita análisis semántico cuando hay errores léxicos o sintácticos
(`DIAG.CLASSES`). Un HIR utilizable por R5 solo se entrega si se cumplen sus invariantes estáticos.

### 1.1 Propiedad de responsabilidades

| Dueño | Responsabilidad e imports internos permitidos |
|---|---|
| source | Bytes válidos, tramos, líneas y claves normalizadas; ninguna capa interna |
| diagnostics | Códigos, argumentos, orden y presentación generada; source |
| lexicon | Identidades y vocabularios generados por perfil; source |
| syntax | Lexer, árbol postorden, vistas y recuperación; source, diagnostics, lexicon |
| semantic | Ámbitos, símbolos, tipos y HIR; source, diagnostics, lexicon, syntax |
| api | Recursos públicos y operaciones estáticas; solo capas existentes que necesita el análisis |
| conformance | Adaptación por proceso; únicamente api |
| CLI | Argumentos, archivos, entorno, preferencias y presentación; únicamente API pública del motor |
| SEE | Corpus, selección, transporte, comparación y evidencia; sin imports de sujetos |
| benchmarks | Medición y estadística; sin duplicar semántica del lenguaje |

Los permisos exactos siguen en los archivos de reglas. Que api tenga permiso futuro para importar
runtime no exige crear runtime en R4. Antes de cada archivo se responden capa, imports y dueño
(`LAYER-DIRECTION`, `SCOPE-YAGNI`). Los tests reflejan módulos; los casos del corpus se ejecutan como
datos y no se copian como tests Rust.

## 2. Decisiones técnicas propuestas

### 2.1 Fuente, Unicode y límites representables

**Problema.** Normalizar el almacenamiento destruye posiciones y reimpresión; aceptar bytes inválidos
con sustituciones altera la entrada. Los desplazamientos compactos pueden desbordarse.

**Elección.** Validar UTF-8 en el borde de entrada y conservar el texto sin modificaciones. source
indexa los inicios de línea, trata CRLF como un salto y convierte bytes a posiciones del corpus bajo
demanda. Cada tramo se construye con extremos válidos y ordenados. NFC produce claves de comparación;
la grafía original sigue disponible para mensajes y tramos. El camino ASCII evita normalización
innecesaria. Las reglas de caja y acentos son las del perfil, sin un pliegue universal de nombres.

Antes de estrechar una longitud o índice a `u32`, comprobar representabilidad y reservas de memoria.
Una entrada no representable produce un error tipado de entrada o recurso conforme a `API.ERRORS`;
si falta ese contrato, se especifica y prueba antes de implementar. No se reutiliza un límite de
recursión de ejecución como límite del parser. Los números de `ENG.LIMITS` describen ejecución.

**BOM.** `LANG.SOURCE.ENCODING` excluye el BOM inicial de los tokens del lenguaje;
`TOOL.SERVICE.LOSSLESS-TREE` exige conservar sus bytes. Se almacena como prefijo de fuente, recuperado
por la reimpresión junto con los fragmentos del árbol, sin convertirlo en una palabra o terminal del
parser. Esta distinción queda explícita en LOSSLESS-TREE 0.2.0 y su dependencia SOURCE.ENCODING.
UTF-8 inválido falla antes de construir el árbol;
la propiedad sobre todo texto se aplica a texto fuente válido, no a una decodificación con pérdida.

**Alternativas descartadas.** Normalizar la fuente completa, usar columnas UTF-16 por conveniencia de
un cliente futuro o sustituir bytes inválidos. Cada una cambia un observable o mezcla responsabilidades.

### 2.2 Generación reproducible

**Problema.** Copiar vocabulario, firmas o diagnósticos crea fuentes divergentes; cargar Markdown
durante el análisis introduce I/O y acopla el motor a SEE.

**Elección.** Consumir `see-export/1` como datos. Los `build.rs` responsables producen Rust en
`OUT_DIR`, con orden estable e identidad de las entradas. No ejecutan SEE ni descargan recursos.
Los catálogos versionados que consuma otro build se materializan mediante el generador y se verifican.

| Datos del corpus | Salida consumidora | Verificación negativa |
|---|---|---|
| vocabulary, alias y aperturas | Identidades y reconocimiento por perfil | Colisión o identidad duplicada |
| functions | Firmas estáticas de incorporadas | Firma o tipo desconocido |
| diagnostics y plantillas | Códigos, argumentos tipados y presentación bilingüe | Argumento ausente o paridad rota |
| grammar | Clases y vistas sintácticas, relaciones estructurales | Producción o referencia no resuelta |

La gramática exportada contiene EBNF como cadenas: exportar esos datos no genera por sí solo un
parser ni vistas. R4 implementa su lector validado para el subconjunto EBNF ya normativo. Las vistas
no afirman cardinalidades que la recuperación no puede garantizar; sus accesos recuperables son
opcionales o retornan errores tipados. El parser de descenso recursivo implementa decisiones de
contexto y recuperación explícitas; no hay un segundo vocabulario literal en él.

El hash perfecto se conserva como objetivo de lexicon aprobado en R3. La construcción es determinista,
comprueba ausencia de colisiones y tiene un límite de búsqueda que falla claramente al agotarse;
el análisis no busca semillas ni construye tablas. Los nombres de incorporadas se distinguen de
palabras reservadas según el corpus. No se introduce una dependencia no declarada para generarlo.

**Alternativas descartadas.** Copias manuales, generadores que interpretan prosa, parser PEG/LALR nuevo
y generación de todo el analizador semántico. No resuelven la necesidad acotada de R4.

### 2.3 Tokens, árbol y recorrido

**Problema.** La recuperación debe conservar entradas erróneas sin construir grafos enlazados ni
duplicar texto; guardar tokens por separado no demuestra que el árbol los cubra.

**Elección.** Lexer por clases de byte con salida Unicode explícita; columnas de clases e inicios de
token y extremo final verificable. Los fragmentos cubren el texto sin huecos ni solapamientos,
descontado el prefijo BOM conservado. Espacios, comentarios, saltos y fragmentos inválidos conservan
sus rangos originales. EOF no consume bytes ni participa dos veces en reimpresión.

El parser emite nodos postorden con clase, primer token y tamaño de subárbol, como fija syntax.
Una pila temporal de construcción cierra cada nodo una vez. Las operaciones de rango y recorrido
comprueban índices y aritmética; no hay punteros ni referencias a elementos que se invaliden al crecer.
El extremo de tokens de cada nodo se registra o deriva mediante una regla inequívoca documentada en
el README; `subtree_size` cuenta nodos y no sustituye la longitud de tokens. La elección concreta se
valida con nodos vacíos, errores, hermanos y trivia antes de fijar la representación.

La reimpresión recorre la cobertura del árbol y sus fragmentos originales: no devuelve directamente
el texto almacenado para fingir que comprobó el árbol. Se verifican dos propiedades independientes:
cobertura exacta de bytes y estructura postorden válida. Los accesores recuperables no suponen que un
nodo con error tiene todos los hijos obligatorios de la gramática válida.

**Alternativas descartadas.** Un AST enlazado paralelo, perder comentarios y reconstruir espacios,
rowan como requisito de R4, o afirmar cero asignaciones. Se miden bytes por token/nodo y reservas
reales; el árbol contiguo por sí solo no demuestra el coste del análisis completo.

### 2.4 Recuperación con progreso garantizado

**Problema.** Una sincronización genérica puede consumir el cierre del padre, duplicar diagnósticos,
entrar en bucle o agotar la pila del anfitrión.

**Elección.** Cada contexto registra inicio, cierre esperado y conjunto de sincronización. Cada paso
consume un token, cierra un contexto o devuelve control al dueño de un cierre; se verifica este
invariante con pruebas de progreso. Tokens omitidos se conservan en nodos de error. Los elementos
ausentes se representan sin inventar bytes. No se deduplican diagnósticos al final para esconder
errores del parser: la regla que detecta el error conserva su responsabilidad al recuperar.

La precedencia y asociatividad provienen de `LANG.OPS.PRECEDENCE` y `LANG.SYNTAX.GRAMMAR`; no se
resuelven discrepancias introduciendo una regla propia. Se atienden explícitamente literales con
signo, unarios, potencia, accesos, llamadas y terminadores según los contratos existentes.

Las cadenas de operadores se procesan iterativamente cuando sea posible. La profundidad se comprueba
antes de cada descenso recursivo, también en paréntesis, unarios, potencia y bloques; el umbral seguro
y su respuesta pública se especifican antes del código si el corpus no los fija. El recorrido y la
destrucción del árbol no vuelven a introducir recursión proporcional a la entrada. Un desbordamiento
de pila no se considera capturable mediante la barrera de pánicos de la API.

**Alternativas descartadas.** Un único descarte hasta salto de línea, emitir un error por cada bloque
exterior al llegar a EOF, o ejecutar semántica sobre sintaxis inválida. Contradicen recuperación y
`DIAG.CLASSES`.

### 2.5 Semántica y HIR

**Problema.** Los nombres adelantados, las clases y los errores previos exigen más que un recorrido
que resuelve y tipa cada nodo de inmediato.

**Elección.** Arenas con índices tipados y orden determinista de inserción. Primero registrar las
unidades y firmas que el corpus permite referenciar; después resolver ámbitos, nombres y miembros;
por último comprobar tipos, flujo e invariantes estáticos. La visibilidad y herencia siguen sus
reglas, incluidos ciclos y receptores conocidos. No se inventa una regla de declaraciones adelantadas.

Un símbolo inválido conserva identidad y causa de invalidez. No se transforma en una declaración
válida ni elimina posiciones de una firma duplicada: se evita generar errores derivados de aridad,
tipo o inicialización, conservando errores independientes. La inicialización y los retornos se
comprueban con el flujo exigido por el corpus; no basta el orden textual para ramas y bucles.

El HIR contiene referencias resueltas, tipos, tramos y distinción entre designador y valor. Conserva
lo necesario para arreglos, paso por referencia, llamadas, clases y conversiones permitidas.
La clase escalar/referencia es una decisión estática; no exige implementar ABI, registros ni valores
del runtime. La resolución de destinos por jerarquía cerrada se limita a lo demostrable estáticamente;
no se añade un optimizador de ejecución. Identidades de nodo son locales al análisis; su persistencia
entre ediciones pertenece a R7.

**Alternativas descartadas.** `Rc<RefCell<…>>`, identificadores por dirección, orden de diagnósticos
dependiente de tablas hash o implementar library para conocer sus firmas.

### 2.6 API y fronteras

**Elección.** `API.ANALYZE` recibe vocabulario y rigor explícitos; no inspecciona entorno ni infiere
idioma del programa. Devuelve árbol presente, esquema y diagnósticos ordenados incluso con errores
recuperables. Los recursos tienen identidad comprobada y errores de acceso tipados. Versionado y
formatos de intercambio se implementan para los datos disponibles en R4, sin anunciar capacidades de
ejecución, trazas o estado que todavía no existen. Los contratos de eventos siguen asignados a R5.

El adaptador solo usa api. La CLI decide vocabulario por apertura o bandera, y el idioma de interfaz
por bandera > entorno > preferencias > sistema > español. La orden inglesa no cambia idioma.
`comprobar/check`, `preferencias/preferences`, ayuda, JSON, errores de archivo y códigos de salida
siguen `TOOL.CLI.*`. El esquema usa claves estables; la presentación traduce plantillas y nunca
identificadores del usuario. I/O y preferencias pertenecen al borde.

La captura de un defecto interno es una última barrera, no un camino de recuperación del usuario.
Los tests de robustez requieren ausencia de pánicos, no solo ausencia de un pánico que escape.

## 3. Discrepancias resueltas y preparación pendiente

| Asunto | Resolución de esta preparación | Evidencia que sigue perteneciendo a R4 |
|---|---|---|
| Conversión de throughput a tiempo | 790 000 líneas/s equivalen a unos 12,7 ms por 10 000 líneas; la revisión previa que decía 127 ms era incorrecta | Medir p95; el promedio teórico no lo garantiza |
| E-08 planteado sobre Dart incremental | Experimento sobre reanálisis completo Rust; informa R7 | Ejecutar con datos crudos y todas las configuraciones |
| LOSSLESS-TREE declaraba solo service y mezclaba BOM con tokens | Versión 0.2.0 añade engine, conserva service y explicita BOM como prefijo y dominio UTF-8; cambio clasificado | Ejecutar P1/P2, sin convertir presencia de árbol en prueba de igualdad |
| CLI resumida únicamente como check en 07 | Se explicitan comprobar/check y preferencias/preferences | Implementar alias y precedencias ya aprobados |
| SEE acepta únicamente reference | Dependencia explícita en B1/B6 | Registro de engine y cli, selección estática y evidencia por sujeto |
| SEE ejecuta casos, no propiedades generativas | Dependencia explícita en B1/B7 | Ejecutor de propiedades requerido por la aceptación y matriz con evidencia |
| LANG/DIAG aún declaran reference | Activación de engine y revisión de vínculos en B1 | Sin selección vacía ni exenciones heredadas de Dart |

La corrección de sujetos no prueba cumplimiento. Los resultados previos de R3 se conservan como
evidencia histórica; no se editan para aparentar que ejecutaron engine. Cambios de hash requieren
evidencia nueva cuando un consumidor los contraste.

## 4. Plan de ejecución B0–B8

Cada casilla incluye las verificaciones que la acompañan. Los archivos de evidencia propuestos llevan
prefijo `r4-` bajo `packages/pseudolearn_spec/results/`; su esquema se documenta en el README del dueño
al implementarlo. No se crean ahora archivos con resultados ficticios.

### B0 · Preparación y alcance ejecutable

- [ ] **B0.1** Confirmar autorización de R4 y recomendaciones D-R4; registrar cualquier cambio antes
  del código. Comprobar rama única, estado de trabajo y punto de partida remoto sin sobrescribir
  cambios ajenos.
- [ ] **B0.2** Inventariar todas las reglas/casos/propiedades estáticos de LANG, DIAG, firmas de LIB,
  API y TOOL pertinentes. Registrar combinaciones declaradas de perfil y rigor y exclusiones
  normativas existentes. No forzar combinaciones que un caso excluye justificadamente.
- [ ] **B0.3** Separar aceptación por operación y por elemento: una regla que tiene análisis y
  ejecución no queda completamente en cumple por aprobar solo analyze. Los casos execute/trace/ir
  quedan visibles con fase R5, sin contarse como aceptación estática ni como errores ocultos.
- [ ] **B0.4** Guardar inventario y correspondencia de cada criterio de 07 con verificación,
  ejecutor y artefacto. Cualquier criterio sin ejecutor bloquea su aceptación.

### B1 · Contratos, generación e infraestructura

- [ ] **B1.1** Activar engine en los contratos estáticos aplicables sin retirar reference. Versionar,
  clasificar impacto y regenerar anclaje/exportación mediante SEE. Crear vínculos de conformidad del
  motor por elemento; ninguna exención de reference se traslada a engine.
- [ ] **B1.2** Comprobar las aclaraciones de BOM y UTF-8 de LOSSLESS-TREE 0.2.0 y concretar en corpus
  los vacíos observables necesarios: límites de análisis y errores de recursos.
  Especificación → casos/propiedades → tests → código. No cambiar la gramática para
  acomodar la implementación ni debilitar el requisito de conservación.
- [ ] **B1.3** Diseñar el registro de sujetos por proceso y la evidencia separada por sujeto en SEE.
  La configuración selecciona ejecutable y argumentos sin shell ni imports del motor; se valida
  identidad, capacidades y ubicación de evidencia. El modo reference conserva su funcionamiento.
- [ ] **B1.4** Definir el transporte mínimo de las propiedades estáticas inventariadas, incluidas
  reimpresión, esquema, modelo de recursos, errores, versionado e intercambio aplicable al análisis.
  Semilla, generador, versiones/hashes, número de muestras, configuración y contraejemplo quedan en
  datos. Si falta una operación en el protocolo, se especifica y negocia antes de programarla; no se
  añaden campos ad hoc ni se confunde un resultado estructural con una observación ejecutada.
- [ ] **B1.5** Crear workspace Cargo del motor con las capas de R4, tooling y versión exacta común;
  mantener R5 documentada sin implementaciones vacías de VM/runtime. Revisar la transición del modo
  declarativo del verificador para validar capas presentes y pendientes de forma explícita, sin
  desactivar comprobaciones de imports o exigir código anticipado. Cada cambio del verificador tiene
  fixture negativo y README actualizado.
- [ ] **B1.6** Preparar build reproducible desde exportación; lectores y generadores con casos
  felices, referencias rotas, duplicados y entradas truncadas. Dos generaciones de la misma entrada
  producen la misma salida; una exportación desactualizada hace fallar la puerta.
- [ ] **B1.7** Declarar antes del código las reglas de la CLI y su tooling, y las dependencias
  externas efectivamente necesarias. Actualizar README de los dueños con cada decisión adoptada.

### B2 · Fuente y diagnósticos

- [ ] **B2.1** Implementar fuente, validación UTF-8, líneas, tramos y claves NFC. Comprobar vacío,
  BOM, CR/LF/CRLF, caracteres suplementarios, nombres de un carácter, NFC/NFD, extremos e índices
  fuera de rango. No modificar literales ni comentarios.
- [ ] **B2.2** Generar códigos y plantillas de diagnósticos con argumentos tipados. Implementar
  orden del corpus y separación de idioma de interfaz y vocabulario. Rechazar argumentos o códigos
  inválidos por valores de retorno; probar la conservación de la grafía del usuario.
- [ ] **B2.3** Verificar bytes inválidos y tamaños no representables en los bordes que los reciben;
  no pasar por JSON para simular bytes que JSON no puede representar como texto válido.

### B3 · Lexicon y lexer

- [ ] **B3.1** Implementar tablas bilingües, alias, firmas estáticas y hash perfecto generado.
  Comprobar todas las entradas del recurso, desconocidos, colisiones, aperturas y diferencias entre
  nombres de funciones y palabras reservadas.
- [ ] **B3.2** Implementar lexer con columnas y trivia conservada. Cubrir literales, escapes,
  comentarios, operadores, Unicode y fragmentos inválidos conforme al corpus; EOF no pierde texto.
- [ ] **B3.3** Verificar progreso y partición exacta de la fuente, incluido BOM como prefijo;
  conversions y reservas comprobadas. El camino infeliz no genera un token que el parser interpreta
  como válido para producir una segunda causa artificial.

### B4 · Parser, postorden y recuperación

- [ ] **B4.1** Implementar construcción/recorrido del árbol y vistas generadas antes de consumirlo
  desde semantic. Verificar tamaños de subárbol, extremos de tokens, orden de hijos, nodos vacíos,
  rangos corruptos y conservación de fragmentos de error.
- [ ] **B4.2** Cubrir expresiones, sentencias, bloques, arreglos, subprogramas y clases de la edición
  vigente, con precedencia, rigor, contexto y terminadores normativos. No dejar construcciones de
  análisis para R5 por el hecho de que su ejecución todavía no exista.
- [ ] **B4.3** Implementar recuperación por contexto y probar cierres inesperados, EOF, listas rotas,
  literales inválidos y ausencia de progreso. Comparar diagnósticos completos, sin deduplicarlos.
- [ ] **B4.4** Comprobar límites seguros en todas las rutas recursivas y recorridos de destrucción.
  Ejecutar profundidad extrema en procesos aislados para detectar abortos o bloqueos; capturar un
  defecto como INTERNAL-FAULT no convierte el ensayo en éxito.
- [ ] **B4.5** Producir esquema sintáctico aun con errores recuperables y bloquear semántica ante
  errores léxicos/sintácticos. Árbol y esquema vacío son resultados válidos donde lo exige el corpus.

### B5 · Nombres, tipos y HIR

- [ ] **B5.1** Implementar arenas e índices tipados; registro de unidades y firmas, ámbitos,
  resolución de nombres y miembros. Probar duplicados, ocultamiento permitido/prohibido, nombres
  Unicode equivalentes, herencia, privacidad, Este/Super y firmas inválidas según contratos.
- [ ] **B5.2** Implementar tipos y rigor: operadores, conversiones, inferencia, incorporadas,
  arreglos, llamadas, paso por referencia, retorno, inicialización y restricciones del control de
  bucles. Cada regla exigible tiene una verificación; no se compara solo cantidad de errores.
- [ ] **B5.3** Producir HIR tipado con tramos y referencias válidos. Probar que símbolos inválidos
  impiden cascadas derivadas sin eliminar errores independientes. Repetir un análisis produce el
  mismo orden y los mismos resultados públicos.
- [ ] **B5.4** Resolver los hallazgos estáticos asignados a R4 del README de SEE, incluidos H-05,
  H-06, H-37, inicialización flexible, símbolos inválidos, recuperación estructural, BOM/NFC,
  miembros privados/inexistentes y carácter suplementario. La prueba de ejecución del último sigue
  en R5; se aporta evidencia estática específica sin afirmar que ya ejecutó CodigoDe.

### B6 · API, adaptadores y CLI

- [ ] **B6.1** Implementar la API estática con modelo, errores, versionado y wire format aplicables.
  Probar recursos inválidos, liberados o de otro análisis, entrada inválida, negociación incompatible,
  esquema recuperado, orden de diagnósticos y separación de idiomas. Ejecutar las propiedades API del
  inventario estático, incluida inyección controlada de fallos internos; distinguir estas pruebas
  deliberadas de las cargas ordinarias, donde INTERNAL-FAULT es siempre un defecto.
- [ ] **B6.2** Implementar adaptador engine por stdio sobre api y conectar el registro de sujetos
  de SEE. Anunciar únicamente capacidades disponibles. Probar JSON inválido, EOF, timeout, identidad
  equivocada, capacidad ausente y respuesta fuera de contrato; logs solo por stderr.
- [ ] **B6.3** Implementar comprobar/check y preferencias/preferences. Probar apertura precedida por
  BOM/trivia, vocabulario forzado, texto vacío, precedencia completa de idioma, alias equivalentes,
  ayuda, JSON, errores de archivo/preferencias y códigos de salida. El perfil de la API es explícito.
- [ ] **B6.4** Conectar conformidad de CLI mediante el binario pseudo. La capa conformance no importa
  CLI ni crates internos para reproducir su lógica. Verificar las dos interfaces lingüísticas sin
  que la forma de la orden cambie el idioma de salida.

### B7 · Conformidad, propiedades y E-08

- [ ] **B7.1** Ejecutar todos los casos analyze del alcance B0 con sus combinaciones declaradas;
  guardar esperados, observados, diferencias y hashes. Resultado sin incumple, pendiente ni no
  aplicable dentro de la aceptación estática exigible. Informar por separado lo asignado a R5.
- [ ] **B7.2** Ejecutar P1/P2 de LOSSLESS-TREE y la propiedad de esquema de API.ANALYZE. Usar todos
  los programas del corpus, incluso fuentes de casos execute, como textos para conservación, sin
  intentar ejecutarlos. Mutaciones con semilla reproducible; guardar contraejemplos y repetirlos.
- [ ] **B7.3** Ejecutar robustez con entradas vacías, solo trivia, binario inválido, Unicode NFD,
  texto aleatorio y anidación extrema. Validar terminación y ausencia de pánico/aborto/bloqueo;
  INTERNAL-FAULT nunca es un resultado aceptable del corpus ni de estas cargas válidas de prueba.
- [ ] **B7.4** Medir throughput y E-08 conforme a §5, con manifiesto y datos crudos. Comprobar
  resultado de cada análisis fuera del intervalo medido, también cuando contiene errores esperados.
- [ ] **B7.5** Contrastar Dart solo donde resulte pertinente, en el mismo hardware, conservando sus
  exenciones y resultados adversos. Los esperados provienen del corpus, no de la salida congelada.
- [ ] **B7.6** Publicar conclusiones sobre reanálisis completo, memoria e identidad para R7.
  Si falla un umbral normativo, optimizar dentro del diseño o reportar para decisión explícita antes
  de cambiar contrato; no cerrar por el solo hecho de haber tomado mediciones.

### B8 · Cierre de R4

- [ ] **B8.1** Revisar README, reglas y conformidad de todos los miembros afectados. Toda decisión
  adoptada es autosustentable en su dueño; ningún código o corpus cita este plan como autoridad.
- [ ] **B8.2** Ejecutar las puertas completas de motor, CLI, SEE y cada miembro de tooling/benchmarks
  modificado. Verificar casos negativos, formato, análisis estático, límites, nombres, seguridad,
  dependencias, generación y tests. Conservar comandos y cantidades reales.
- [ ] **B8.3** Comprobar la tabla de §7 con evidencia. Ningún fallo obligatorio es un pendiente
  justificable. Declarar para R5/R7 solo responsabilidades fuera del alcance con condición de entrada.
- [ ] **B8.4** Publicar commits coherentes mediante push ordinario en la rama única; comprobar HEAD
  local/remoto. No usar coautoría ni atribución de IA. Las comprobaciones remotas solo se ejecutan si
  están autorizadas; los workflows manuales no se presuponen disparados por el push.
- [ ] **B8.5** Actualizar casillas e informe de R4 en 07 después de reunir la evidencia, publicarlos
  y volver a comprobar igualdad local/remoto. Informar implementación, tests, verificadores,
  observaciones, pendientes y publicación.
- [ ] **B8.6** Parar. R5 requiere un mensaje nuevo de autorización. La revisión de memoria previa a
  R5 que dejó E-02 sigue abierta y no se resuelve implementando runtime en R4.

### 4.1 Interfaz de verificación que R4 debe habilitar

Los siguientes comandos de SEE ya existen y se usan desde `packages/pseudolearn_spec`:

```bash
cargo run -p see_cli --bin see -- validate
cargo run -p see_cli --bin see -- lock --check
cargo run -p see_cli --bin see -- export --check
cargo xtask verify
```

B1/B6 deben habilitar explícitamente selección por operación y sujeto para estos comandos nuevos;
no funcionan todavía ni se presentan como evidencia de esta preparación:

```bash
cargo run -p see_cli --bin see -- conform --subject engine --operation analyze
cargo run -p see_cli --bin see -- conform --subject cli --operation cli
cargo run -p see_cli --bin see -- matrix --subject engine --operation analyze
```

`--operation` filtra casos y conserva la identificación de elementos no cubiertos; no declara reglas
enteras cumplidas. La matriz conserva el ámbito del filtro. Sin filtro se preserva la interfaz vigente
de reference. El ejecutor de propiedades incorpora sus observaciones al mismo informe por sujeto y
elemento, con comando exacto documentado al definir su protocolo en B1. No se amplía `--operation`
con un valor que aún no tenga contrato.

Desde los miembros motor y CLI, B8 exige `cargo xtask verify` y `cargo build --release` una vez creados
en B1. Desde cada miembro adicional modificado se ejecuta su puerta documentada; los comandos del
arnés E-08 se registran con su esquema de resultados al implementarlo. El informe de cierre incluye
las invocaciones reales, no sustituye el ensayo por esta lista de comandos objetivo.

## 5. Medición y decisiones de E-08

### 5.1 Cargas y protocolo

La medición normativa sigue `PERF.PROTOCOL`, incluida la procedencia anterior al build, al menos diez
procesos independientes, treinta iteraciones por proceso, semilla fija, memoria máxima muestreada
como cota inferior e intervalos de confianza calculados sobre procesos. Las repeticiones por proceso
no se presentan como máquinas independientes.

| Eje | Cargas mínimas |
|---|---|
| Tamaño | 1 000, 10 000 y 50 000 líneas; registrar también bytes, tokens y nodos |
| Configuración | es/en × estricto/flexible; programas equivalentes válidos para cada rigor |
| Edición | Insertar, borrar y reemplazar al inicio, centro y final |
| Estado | Programa válido, escritura incompleta, cierre ausente y error léxico |
| Semántica | Expresiones, ámbitos, muchos usos de un nombre, clases, llamadas y arreglos |
| Unicode/trivia | ASCII, NFC/NFD, caracteres suplementarios, comentarios, BOM y saltos de línea |

No se concatena sin más un conjunto de programas completos para declararlo un programa válido de un
algoritmo: el corpus concatenado de throughput se identifica como carga concreta y se verifican sus
diagnósticos esperados. Los archivos generados válidos ejercitan también semantic, evitando que una
salida temprana por error sintáctico aparente acelerar el análisis completo.

Preparar cargas, ediciones y esperados fuera del intervalo. Medir cada nuevo análisis desde la fuente
resultante hasta los datos finales exigidos por la API estática, con estado nuevo; lectura de disco,
arranque de proceso e impresión se informan por separado. Las mediciones por etapa usan ensayos
separados para no contaminar el total con instrumentación. Publicar por configuración p50, p95,
throughput, memoria y resolución de reloj; conservar todas las muestras y casos lentos.

### 5.2 Qué decide cada resultado

| Observación | Consecuencia |
|---|---|
| Un millón de líneas/s en el protocolo y Apple M2 | Evidencia para PERF.FRONTEND.THROUGHPUT; no demuestra p95 |
| p95 ≤ 16 ms por carga de 10 000 líneas | Apoya reanálisis completo para esas cargas y máquina |
| Throughput cumple, p95 no | Optimizar y registrar dónde falla; R7 decide incrementalidad |
| Throughput no cumple | Fallo normativo provisional; no se rebaja el umbral automáticamente |
| No hay Apple M2 disponible | Informar hardware real sin atribuir cumplimiento al objetivo M2; la aceptación correspondiente sigue abierta |
| 50 000 líneas fuera del presupuesto | Registrar límite de la hipótesis; no convertir 50 000 líneas en un umbral de producto inventado |

16 ms es el criterio experimental de E-08. El millón de líneas/s es el umbral normativo provisional
del corpus. Cambiar cualquiera exige una decisión explícita y su documentación correspondiente.
No se declara que el front-end supera a rowan/salsa sin una comparación controlada de alternativas;
esa comparación no es obligatoria para demostrar conformidad de R4.

## 6. Decisiones a confirmar al autorizar R4

| ID | Recomendación | Fundamento y alternativa descartada |
|---|---|---|
| D-R4-01 | Conservar postorden y estructuras contiguas de R3 | Concretar rangos e invariantes; no sustituir la arquitectura por preferencia |
| D-R4-02 | Reanálisis completo como primera implementación | E-08 decide su suficiencia; incrementalidad y salsa permanecen en R7 |
| D-R4-03 | Añadir soporte acotado de sujetos y propiedades a SEE | Es imprescindible para aceptación; no basta declarar vínculos cumple |
| D-R4-04 | Distinguir prefijo BOM, texto válido y fallos de entrada | Conservar bytes sin admitir decodificación con pérdida ni BOM gramatical |
| D-R4-05 | Especificar límites de análisis antes de implementarlos | Evitar desbordamientos sin confundirlos con marcos/celdas de ejecución |
| D-R4-06 | HIR estático completo, sin infraestructura de ejecución | Soportar la edición vigente sin anticipar ABI, VM o biblioteca ejecutable |
| D-R4-07 | CLI con comprobar y preferencias, alias ingleses totales | Implementa la frontera de idioma ya aprobada; no añade otros comandos |
| D-R4-08 | Cierre por evidencia estática y propiedades ejecutadas | Resultados R5 visibles y separados; una matriz parcial no prueba reglas completas |

No se requiere elegir nuevamente español/inglés, Rust o la gramática. Una discrepancia normativa
descubierta durante B1 se reporta con propuesta concreta; la autorización general no permite cambiar
el lenguaje en silencio.

## 7. Correspondencia con la aceptación de R4

| Criterio de 07 | Bloques | Evidencia exigida |
|---|---|---|
| Crates estáticos y conformance | B1–B6 | Reglas de capas, build y tests por dueño |
| Generación desde corpus | B1, B2, B3, B4 | Exportación vigente, repetibilidad y fallos negativos |
| CLI comprobar/check | B6 | Casos cli, alias, preferencias e idiomas |
| Todos los analyze LANG/DIAG | B0, B5, B7 | Inventario completo y observaciones de engine por perfil/rigor |
| LOSSLESS-TREE cumple | B4, B7 | P1/P2 ejecutadas sobre reimpresión desde árbol y fragmentos |
| PERF.FRONTEND.THROUGHPUT | B7 | Datos crudos, resumen, procedencia y comparación válida |
| Robustez sin pánicos | B2–B7 | Procesos y cargas adversas; cero INTERNAL-FAULT en corpus |
| cargo xtask verify verde | B8 | Puertas completas de miembros afectados y sus casos negativos |
| Experimento E-08 | B7 | p50/p95 por carga y conclusión explícita para R7 |
| Publicación y parada | B8 | Commit, igualdad local/remoto, informe y R5 sin iniciar |

La evidencia de propiedades y mediciones se vincula a elementos y hashes, aunque use un ejecutor
distinto de los casos analyze. Un resultado no aplicable por falta de ejecutor nunca satisface una
aceptación obligatoria. Los casos de APIs mixtas se dividen por operaciones implementadas, sin marcar
un contrato completo en cumple por una porción verificada.

## 8. Riesgos y pendientes delimitados

| Riesgo | Control dentro de R4 | Destino fuera de R4 |
|---|---|---|
| Soporte de SEE aparenta conformidad sin ejecutar | Rechazos por selección vacía, propiedad sin evidencia y capacidad ausente | Generación universal y reducción avanzada no exigida quedan fuera |
| Postorden conserva texto pero rompe hijos | Invariantes estructurales más reimpresión independiente | Identidad estable entre ediciones, R7 |
| Profundidad hostil agota pila | Guardas antes del descenso y procesos de robustez | Recursión de programas ejecutados, R5 |
| Rendimiento depende de errores que omiten semantic | Cargas válidas e inválidas y resultados por etapa | Incrementalidad, R7 tras E-08 |
| HIR acopla análisis a runtime | Tipos e identidades estáticos; sin objetos ejecutables | Lowering y ejecución, R5 |
| Verificadores exigen todas las capas futuras | Transición explícita y fixtures sin debilitar imports | R5 activa sus capas al implementarlas |
| Política de memoria Clepsidra necesita revisión | Mantener la observación de E-02 visible | Decisión previa a R5, fuera del análisis |

## 9. Fuentes y fundamento de la propuesta

La propuesta se deriva del corpus y los README existentes del repositorio. Conserva las decisiones
de estructuras contiguas, recuperación y arenas ya tomadas en R3. No incorpora una biblioteca ni una
regla de lenguaje externa nueva. La genealogía de técnicas que el diseño adopte permanece en el
README de cada dueño, con problema, elección y alternativas descartadas (`DOC-README-TRUTH`).

No hay resultados de implementación que informar en este documento: las casillas pendientes describen
evidencia exigida para ejecutar R4, no trabajo ya completado.
