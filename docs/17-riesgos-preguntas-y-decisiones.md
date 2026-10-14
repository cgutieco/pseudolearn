# 17 · Conflictos, decisiones, riesgos y preguntas abiertas

> **Estado:** investigación, no normativo. Este documento **no decide nada**: reporta conflictos según
> `CONFLICT-REPORT` y enumera las decisiones que la persona responsable tiene que tomar. Las
> recomendaciones son propuestas con sus condiciones.

---

## 1. Conflictos entre fuentes

`AGENTS.md` (§3) exige reportar los conflictos en vez de resolverlos. Se ordenan por impacto.

<a id="c-01"></a>

### C-01 · El criterio de desempate presupone que PseudoLearn no es el destino

- **Fuentes.** Skill `language-spec-authoring`: «la que prepara mejor para el lenguaje real… Este
  lenguaje existe para que el salto siguiente sea corto». Visión (V-04): quien aprende puede seguir con
  PseudoLearn para construir software real.
- **Por qué importa.** Decisiones vigentes (límite de recursión de 1 000 «porque es el de Python», forma
  del retorno, base cero) se justificaron con ese criterio; las futuras no tendrían referente.
- **Qué hace falta.** [D-02](#d-02). Propuesta de orden alternativo en
  [04](04-filosofia-y-modelo-del-lenguaje.md) §1.2.

<a id="c-02"></a>

### C-02 · La skill `package-docs` frente a especificaciones versionadas

- **Fuentes.** `package-docs`, regla 3: «No se admiten carpetas de decisiones externas (como
  `docs/decisions/`)… Prohibido delegar». Regla 4: «Presente normativo atemporal (sin arqueología de
  versiones)». Visión (V-45, V-52 a V-55): especificaciones completamente versionadas, con detección y
  clasificación de cambios.
- **Por qué importa.** Un sistema versionado necesita registrar versiones anteriores, deprecaciones y
  migraciones, que es exactamente la «arqueología» que la regla 4 prohíbe en los `README.md`.
- **Matiz sobre esta propia investigación.** Este conjunto de documentos vive en `docs/` porque la
  visión lo pide y porque **no contiene decisiones** (solo propuestas). Si alguna propuesta se aprueba,
  según las reglas vigentes tendría que trasladarse al `README.md` o a la especificación del paquete
  correspondiente en el mismo cambio que la implemente.
- **Qué hace falta.** [D-09](#d-09).

<a id="c-03"></a>

### C-03 · `DOC-README-TRUTH` frente a especificaciones como base verificable

- **Fuentes.** `AGENTS.md` §2 (`DOC-README-TRUTH`) y §3 (precedencia, con `language-spec.md` en el nivel
  4). Visión (V-62, V-63).
- **Qué hace falta.** [D-09](#d-09); análisis de opciones en
  [11](11-especificaciones-ejecutables-diseno.md#transicion-readme). Esta investigación **no** cambia
  las reglas ni declara resuelta la transición.

<a id="c-05"></a>

### C-05 · Licencia propietaria frente a una comunidad

- **Fuentes.** Commit `b44b2dd` («switch project license to proprietary») y `README.md` raíz §6.2
  («proyecto de código cerrado»). Visión (V-02): comunidad orientada a quienes programan en español.
- **Qué hace falta.** [D-01](#d-01).

<a id="c-06"></a>

### C-06 · `docs/` en la raíz no figura en el catálogo del `README.md` raíz

- **Fuentes.** `README.md` raíz §3.3 (catálogo de directorios) y §7.3 (rechazar carpetas de primer nivel
  sin registrarlas); `DOC-README-TRUTH`. `AGENTS.md` (`LANG-ES-DOCS`) sí menciona «los documentos de
  `docs/`».
- **Situación.** `docs/` existía vacía; esta investigación la llena por encargo explícito. No se ha
  modificado el `README.md` raíz para no cambiar contratos vigentes.
- **Qué hace falta.** Decidir si `docs/` se conserva y registrarla en el catálogo del `README.md` raíz
  (cambio pequeño, que la persona responsable puede autorizar).

<a id="c-07"></a>

### C-07 · Exclusiones vigentes que la visión contradice

| Exclusión o regla vigente                                                         | Visión que la contradice                            | Dónde se analiza |
|-----------------------------------------------------------------------------------|-----------------------------------------------------|------------------|
| Límite de recursión de 1 000 como regla del lenguaje (§10.8 de la especificación) | Propósito general (V-01)                             | [D-17](#d-17)    |
| Tope de 10 000 micro-pasos en la app                                              | Ejecutar software real desde la app (V-24, V-25)     | [06](06-ejecucion-pedagogica-y-app.md) §5.2 |
| Prohibición de `Isolate` en la app                                                | Ídem                                                 | [06](06-ejecucion-pedagogica-y-app.md) §5.2 |
| Interfaces, genéricos, constantes, enumerados excluidos (`README.md` del núcleo §1.3) | V-11, V-15                                        | [04](04-filosofia-y-modelo-del-lenguaje.md) |
| Sin orquestador ni CI (`README.md` raíz §1.3)                                     | Especificaciones ejecutables (V-45)                  | [D-23](#d-23)    |

Por la precedencia de `AGENTS.md`, la instrucción de la persona responsable prevalece; pero la visión
también pide **no** modificar contratos durante esta investigación. Se reportan, no se resuelven.

<a id="c-08"></a>

### C-08 · Excepciones ya existentes a la fuente única

- `packages/pseudolearn_brand/README.md` remite los tokens de color y tipografía a
  `apps/pseudolearn_app/docs/fundamentos-visuales.md`, un documento fuera del `README.md` (contra la
  regla 3 de `package-docs`).
- `apps/fe-pseudolearn/README.md` lleva insignias y prosa promocional (contra §6.2 del `README.md` raíz).
- No afectan a la investigación, pero muestran que la regla de fuente única ya tiene excepciones de
  hecho (H-29), algo a tener en cuenta en [D-09](#d-09).

---

## 2. Decisiones que requieren a la persona responsable

Formato: pregunta, opciones, recomendación de esta investigación (propuesta), y qué fases bloquea
(fases de [15](15-evolucion-y-hoja-de-ruta.md)).

<a id="d-01"></a>

### D-01 · Licencia y modelo de comunidad

- **Pregunta.** ¿Qué partes serán abiertas, si alguna?
- **Opciones.** (a) Todo propietario. (b) Lenguaje, especificación, compilador, servicio de lenguaje y
  biblioteca estándar abiertos; app propietaria. (c) Todo abierto.
- **Evidencia.** Los lenguajes de propósito general con comunidad amplia de las últimas dos décadas tienen
  implementaciones abiertas; Swift (2015) y .NET (2014) se abrieron para crecer más allá de su empresa.
  1C:Enterprise muestra que una plataforma propietaria puede tener una comunidad grande, en un nicho
  empresarial.
- **Recomendación.** (b), si la comunidad es un objetivo real; condiciona la disposición del monorepo
  ([13](13-arquitecturas-candidatas.md) §5).
- **Bloquea.** F9 (comunidad); influye en F3 y F6.

<a id="d-02"></a>

### D-02 · Puente o destino

- **Pregunta.** ¿PseudoLearn es el destino de quien aprende (y por tanto deja de imitar «el siguiente
  lenguaje»)?
- **Recomendación.** Sí, con el orden de desempate de [04](04-filosofia-y-modelo-del-lenguaje.md) §1.2.
- **Bloquea.** Toda especificación nueva del lenguaje (F4, F7).

<a id="d-03"></a>

### D-03 · Alcance de «propósito general» en la primera versión

- **Opciones.** (a) Aplicaciones, herramientas, servicios y bibliotecas. (b) Además, sistemas y
  embebidos. (c) Solo scripting.
- **Recomendación.** (a) ([04](04-filosofia-y-modelo-del-lenguaje.md) §2).
- **Bloquea.** D-04, D-07; biblioteca estándar.

<a id="d-04"></a>

### D-04 · Modelo de memoria base

- **Opciones.** Trazado; conteo con recolector de ciclos; propiedad; valores mutables; referencias
  generacionales.
- **Recomendación.** Memoria administrada por trazado, con `Registro` como tipo valor y propiedad
  opcional como horizonte ([09](09-gestion-de-memoria.md) §5). Condicionada a E-11, E-12, E-13.
- **Bloquea.** F6, F7.

<a id="d-05"></a>

### D-05 · Arquitectura y lenguajes de implementación

- **Opciones.** A1 a A5 de [13](13-arquitecturas-candidatas.md).
- **Recomendación.** Trayectoria A3 empezando por la mitad común en Dart; condicionada a E-03 y E-08.
- **Bloquea.** F5, F6.

<a id="d-06"></a>

### D-06 · Primer backend nativo

- **Opciones.** Emisión de C; traducción a Go; Cranelift; LLVM; Wasm.
- **Recomendación.** Decidir con E-02 y E-05 entre C y Go.
- **Bloquea.** F6.

<a id="d-07"></a>

### D-07 · Definición de la aspiración de rendimiento

- **Pregunta.** ¿Qué niveles (N1 a N3), suite, plataformas y umbrales se aceptan como definición?
- **Recomendación.** La de [05](05-rendimiento-motor-y-compilacion.md) §2 como punto de partida,
  revisada tras E-02.
- **Bloquea.** Criterios de aceptación de F5 y F6.

<a id="d-08"></a>

### D-08 · Qué significa «evitar el tree shaking»

- **Pregunta.** ¿Cuál de las seis interpretaciones TS-1 a TS-6 (o qué combinación) expresa la intención?
- **Recomendación.** TS-3 + TS-2 + TS-4 por omisión, TS-5 como modo opcional
  ([08](08-modulos-paquetes-y-monorepos.md#tree-shaking)). **Requiere respuesta explícita.**
- **Bloquea.** Diseño de módulos (F4) e inicialización.

<a id="d-09"></a>

### D-09 · Transición de la fuente de verdad

- **Opciones.** R1 a R4 de [11](11-especificaciones-ejecutables-diseno.md#transicion-readme).
- **Recomendación.** R2 (comportamiento en especificaciones; arquitectura y operación en `README.md`),
  tras validar el sistema con E-15.
- **Bloquea.** F1 (en su versión completa); cambios en `AGENTS.md` y skills.

<a id="d-10"></a>

### D-10 · Paquete del sistema de especificaciones y de benchmarks

- **Recomendación.** `packages/pseudolearn_spec` en Dart, sin dependencias de otros miembros
  ([11](11-especificaciones-ejecutables-diseno.md) §11). Los benchmarks, en un miembro propio o dentro de
  la futura CLI.
- **Bloquea.** F1.

<a id="d-11"></a>

### D-11 · Política de evolución

- **Pregunta.** ¿Ediciones por paquete, promesa de compatibilidad acotada y ciclo de deprecación de
  [04](04-filosofia-y-modelo-del-lenguaje.md) §5.3?
- **Recomendación.** Sí; la primera edición numerada sería la del lenguaje vigente.
- **Bloquea.** F4 y todo cambio incompatible.

<a id="d-12"></a>

### D-12 · Ámbitos de bloque

- **Pregunta.** ¿Se introducen ámbitos de bloque (cambio incompatible) como prerrequisito de closures?
- **Recomendación.** Sí, con edición y migración ([04](04-filosofia-y-modelo-del-lenguaje.md#ambitos)).
- **Bloquea.** Closures (F7).

<a id="d-13"></a>

### D-13 · Palabras reservadas

- **Preguntas.** ¿Vocabulario nuevo contextual? ¿Reabrir `Y` y `O` como contextuales (decisión 4.12
  vigente del núcleo)? ¿Mecanismo de escape de identificadores?
- **Recomendación.** Contextual para lo nuevo; reabrir `Y`/`O` con datos de E-10; escape solo para
  interoperabilidad y migración ([03](03-identidad-bilingue-y-gramatica.md#presupuesto-reservado)).

<a id="d-14"></a>

### D-14 · Identificadores Unicode

- **Preguntas.** ¿Normalizar a NFC? ¿Admitir `ñ` y tildes en el perfil estricto?
- **Recomendación.** NFC sí (compatible); `ñ` en estricto, reabrir con datos
  ([03](03-identidad-bilingue-y-gramatica.md) §6).

<a id="d-15"></a>

### D-15 · Modelo de errores

- **Recomendación.** `Resultado` con propagación explícita para errores recuperables; defectos del
  programa detienen con diagnóstico ([04](04-filosofia-y-modelo-del-lenguaje.md#errores)).

<a id="d-16"></a>

### D-16 · Interfaces y rasgos de Dart

- **Recomendación.** Interfaces nominales explícitas; no adoptar la interfaz implícita de cada clase;
  adoptar `Sellada` ([04](04-filosofia-y-modelo-del-lenguaje.md) §3).

<a id="d-17"></a>

### D-17 · Límites de recursos

- **Pregunta.** ¿El límite de profundidad (1 000) y el tamaño de arreglos son reglas del lenguaje o
  límites de recursos del entorno?
- **Recomendación.** Límites de recursos con mínimo garantizado y diagnóstico; la app conserva 1 000
  ([04](04-filosofia-y-modelo-del-lenguaje.md) §4.11). Es un cambio de significado: requiere edición
  (ejemplo de clasificación en [12](12-especificaciones-ejecutables-ejemplos.md) §9).

<a id="d-18"></a>

### D-18 · Contrato de observación

- **Pregunta.** ¿Se especifica el «paso observable» y el estado observable como contrato
  ([06](06-ejecucion-pedagogica-y-app.md) §1–2)?
- **Recomendación.** Sí; es prerrequisito de la VM y de la reproducción.
- **Bloquea.** F5.

<a id="d-19"></a>

### D-19 · Aliases y manifiesto

- **Recomendación.** Forma de importación por alias en el lenguaje; mapa solo en manifiestos; un único
  resolutor ([08](08-modulos-paquetes-y-monorepos.md) §5).

<a id="d-20"></a>

### D-20 · Idioma de los identificadores de especificación

- **Opciones.** Mnemónicos en inglés (coherentes con `DOC-README-TRUTH` y con `LANG-EN-CODE`) o en
  español (coherentes con la identidad).
- **Recomendación.** Inglés ASCII, por coherencia con los identificadores de reglas vigentes; los títulos
  en español.

<a id="d-21"></a>

### D-21 · Bilingüismo de APIs, mezcla de idiomas y herramientas

- **Preguntas.** ¿Biblioteca estándar bilingüe por construcción? ¿Nombres bilingües opcionales para
  terceros? ¿Un perfil por archivo? ¿Idioma canónico de la CLI y del manifiesto?
- **Recomendación.** Sí, sí (opcional y verificado), sí; idioma canónico por decidir con alias en el otro
  ([03](03-identidad-bilingue-y-gramatica.md) §7).

<a id="d-22"></a>

### D-22 · Corrección de los hallazgos actuales

- **Pregunta.** ¿Cuáles de H-01 a H-37 se corrigen antes de evolucionar, y en qué fase?
- **Recomendación.** Corregir en F0–F2 los que afectan a contratos o a la frontera pública (H-05, H-06,
  H-07, H-08, H-09, H-10, H-18, H-25, H-27, H-37) y la documentación derivada (H-01, H-02, H-03, H-28),
  convirtiendo cada corrección en un caso de especificación.

<a id="d-23"></a>

### D-23 · Integración continua

- **Recomendación.** CI que ejecute los verificadores de todos los miembros y la conformidad, antes o a
  la vez que F1. Sin CI, ninguna especificación es «ejecutable» en la práctica (H-33).

<a id="d-24"></a>

### D-24 · Revisión de exclusiones pedagógicas para propósito general

- **Preguntas.** ¿Salida anticipada de bucles con nombre de construcción (`Salir Para`)? ¿Aviso por
  falta de marca de sobrescritura? ¿Constantes de módulo (sin globales mutables)?
- **Recomendación.** Evaluar las tres con E-14; constantes de módulo, sí
  ([04](04-filosofia-y-modelo-del-lenguaje.md) §4.7, §4.10).

---

## 3. Riesgos

Probabilidad e impacto: **B**aja, **M**edia, **A**lta.

| ID   | Riesgo                                                                                                   | P | I | Mitigación                                                                                          | Señal temprana                                                  |
|------|----------------------------------------------------------------------------------------------------------|---|---|-----------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|
| R-01 | El alcance (lenguaje de propósito general + app + herramientas + especificaciones) excede al equipo       | A | A | Fases con cierre explícito; mitad común primero; backends por traducción; experimentos antes de construir | Fases que se alargan; experimentos que no se cierran             |
| R-02 | El bilingüismo fragmenta bibliotecas, ejemplos y ayuda                                                    | M | A | Un perfil por archivo; biblioteca estándar bilingüe; traducción sin pérdida; documentación generada en ambos idiomas | Bibliotecas de terceros solo en un idioma; preguntas duplicadas |
| R-03 | Cambios incompatibles rompen documentos de usuarios y ejercicios                                          | M | A | Ediciones; migración automática; ejercicios anclados a edición                                      | Documentos que dejan de analizar tras una actualización         |
| R-04 | Los motores divergen                                                                                      | M | A | Contrato de traza; conformidad diferencial; oráculo de referencia                                   | Casos verdes en un motor y rojos en otro                         |
| R-05 | El sistema de especificaciones se vuelve burocracia y se abandona                                         | M | A | Producto mínimo; medir coste de autoría (E-15); herramientas que andamien; empezar por lo que ya falla | Reglas nuevas que se escriben fuera del corpus                  |
| R-06 | Dependencia de cadenas externas (compilador C, Go, LLVM) y de su distribución                              | M | M | Empaquetar (`zig cc`, Go como dependencia declarada); RI como contrato para poder cambiar             | Instalaciones fallidas; tamaño de distribución                   |
| R-07 | Restricciones de plataforma (iOS sin JIT, firma en Windows, web sin enteros de 64 bits)                   | A | M | Sin JIT; VM en todas; Wasm en web; firma planificada                                                | Funcionalidad que solo existe en una plataforma                  |
| R-08 | La licencia cerrada limita la adopción                                                                     | A | A | D-01                                                                                                | Ausencia de contribuciones o de bibliotecas externas             |
| R-09 | La semántica pedagógica impide el rendimiento aspirado                                                    | M | A | E-02 antes de invertir en backend                                                                   | Techo semántico por encima de N2                                 |
| R-10 | El lenguaje pierde su identidad pedagógica al crecer                                                      | M | A | Niveles como subconjuntos; reglas de estilo EST; principios F-xx                                    | Construcciones nuevas con símbolos o con varias formas           |
| R-11 | Cadena de suministro de paquetes y confundibles Unicode                                                   | M | A | Identificadores ASCII de paquete; UTS #39; hashes y firma                                          | Paquetes con nombres casi idénticos                              |
| R-12 | El vocabulario reservado crece hasta incomodar                                                            | A | M | Palabras contextuales; métrica de presupuesto (E-10)                                                | Quejas por nombres prohibidos; diagnósticos `reservedLexemeUsedAsName` frecuentes |
| R-13 | Benchmarks malinterpretados o publicitados sin método                                                     | M | M | Protocolo de [16](16-experimentos-y-benchmarks.md) §2; publicar todo                                | Afirmaciones de rendimiento sin nivel ni familia                 |
| R-14 | Implementación, pruebas y especificación comparten un error                                               | M | A | Política de oráculos independientes (§10 de [11](11-especificaciones-ejecutables-diseno.md))        | Puntuación de mutación baja; reglas que ningún caso detecta      |
| R-15 | Agentes de IA generan código o especificaciones sin revisión independiente                                | A | M | El sistema exige origen de los valores esperados y revisión distinta para estabilizar                | Valores `capturado` sin revisor; especificaciones sin casos      |
| R-16 | Sin CI, la conformidad no es continua                                                                      | A | A | D-23                                                                                                | Regresiones descubiertas tarde                                   |
| R-17 | Concentración del conocimiento en pocas personas                                                          | ? | A | Especificaciones y `README.md` como memoria del proyecto; skills                                     | — (el tamaño del equipo no consta en el repositorio)            |

---

## 4. Preguntas abiertas de investigación

| ID   | Pregunta                                                                                                   | Dónde se plantea |
|------|------------------------------------------------------------------------------------------------------------|------------------|
| Q-01 | ¿Un carácter es un punto de código o un grupo de grafemas?                                                 | [04](04-filosofia-y-modelo-del-lenguaje.md) §4.8 |
| Q-02 | ¿Registros inmutables por omisión?                                                                         | [04](04-filosofia-y-modelo-del-lenguaje.md) §4.7 |
| Q-03 | ¿Qué modelo de concurrencia, y cuándo?                                                                     | [04](04-filosofia-y-modelo-del-lenguaje.md) §4.12 |
| Q-04 | ¿Forma y garantías de la interoperabilidad con C?                                                          | [09](09-gestion-de-memoria.md) §4 |
| Q-05 | ¿Alcance inicial de la biblioteca estándar?                                                                | [04](04-filosofia-y-modelo-del-lenguaje.md) §2 |
| Q-06 | ¿Formato y claves del manifiesto?                                                                          | [08](08-modulos-paquetes-y-monorepos.md) §4 |
| Q-07 | ¿Cómo conviven niveles pedagógicos y perfiles de rigor en la app y en el compilador?                       | [04](04-filosofia-y-modelo-del-lenguaje.md) §1.3 |
| Q-08 | ¿Se publica el corpus de especificaciones a la comunidad, en qué idiomas?                                  | [11](11-especificaciones-ejecutables-diseno.md) |
| Q-09 | ¿Nombres del sistema de especificaciones, de la CLI y de las ediciones?                                    | [11](11-especificaciones-ejecutables-diseno.md), [07](07-herramientas-y-autocompletado.md) §7 |
| Q-10 | ¿Reales no finitos permitidos en un modo de cálculo científico?                                            | [04](04-filosofia-y-modelo-del-lenguaje.md) §4.8 |
| Q-11 | ¿Proceso de propuestas de la comunidad (estilo RFC o PEP) si el lenguaje se abre?                          | D-01 |
| Q-12 | ¿Concordancia de género en palabras como `Nuevo`/`Nueva` y en nombres de la biblioteca estándar?            | [03](03-identidad-bilingue-y-gramatica.md) §8.4 |
| Q-13 | ¿Se modela la semántica central con un DSL ejecutable tipo SpecTec a largo plazo?                          | [10](10-especificaciones-ejecutables-fundamentos.md) §4 |
