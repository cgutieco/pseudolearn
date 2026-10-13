# 15 · Estrategia de evolución y hoja de ruta

> **Estado:** investigación, no normativo. La hoja de ruta es una **propuesta**; ninguna fase está
> aprobada ni empezada. Cada fase se cierra según `PHASE-STOP` y `PHASE-GREEN`: al terminarla se para y
> se espera confirmación explícita antes de la siguiente.

Responde a V-71 (estrategia de evolución; hoja de ruta por fases con dependencias y criterios de
aceptación).

---

## 1. Estrategia

### 1.1 Principios

1. **Sustitución progresiva, nunca reescritura total.** Cada fase deja la app publicable y los
   documentos `.pseudo` de las personas usuarias funcionando. Los componentes nuevos crecen junto a los
   viejos y los reemplazan cuando la conformidad lo demuestra (patrón de la «higuera estranguladora»).
2. **Contrato antes que código.** Lo que se construye en una fase está especificado en el corpus
   antes de implementarse (extensión de la regla vigente «especificar antes del parser»).
3. **Medir antes de invertir.** Los experimentos que pueden invalidar una dirección (E-02, E-03, E-05,
   E-08, E-15) van antes de la fase que construye esa dirección.
4. **Lo común primero.** La mitad compartida por todas las arquitecturas candidatas (front-end,
   servicio de lenguaje, VM en Dart) se construye antes de elegir backend.
5. **Ediciones para lo incompatible.** Todo cambio de significado espera a una edición, con migración
   automática.
6. **Cada hallazgo corregido se convierte en caso.** Ninguna corrección de H-xx entra sin el caso de
   especificación que la habría detectado.

### 1.2 Del sistema actual al propuesto

| Componente actual                                      | Destino                                                                | Cuándo        |
|--------------------------------------------------------|------------------------------------------------------------------------|---------------|
| `language-spec.md`                                     | Corpus de especificaciones (migración por secciones)                   | F1 → F4       |
| Tests del núcleo (772)                                 | Siguen; los casos de especificación se suman; vínculos en archivo de conformidad | F1 en adelante |
| Lexer y parser con pérdida                             | Front-end sin pérdida e incremental, mismo diagnóstico                 | F3            |
| Fragmentos de lenguaje en la app (`completion/`, `editing/`, `printing/`) | Servicio de lenguaje                                         | F3            |
| Intérprete de tareas                                   | Oráculo de referencia; la VM lo sustituye en la app cuando iguala la conformidad | F5   |
| `StepBatchRunner` con tope de micro-pasos              | Ritmos sobre eventos observables; límites en unidades con sentido       | F5            |
| `PseudoInteger` con `BigInt` en todo objetivo          | Representación por objetivo                                            | F2 (E-04) o F5 |
| Emisores de Python y Rust                              | Se conservan como contraste pedagógico                                 | —             |
| `CHANGELOG.json` del par (app, núcleo)                 | Versionado ampliado (edición, cadena, biblioteca estándar, app)         | F4            |

---

## 2. Fases

```
F0 ─► F1 ─► F2 ─┬─► F3 ─────────────┐
                │                    ├─► F7 ─► F8 ─► F9
                └─► F4 ─► F5 ─► F6 ──┘
                          ▲
                   (E-03, E-06, E-07)
F10: horizonte, sin fecha
```

F3 y F4 pueden avanzar en paralelo tras F2 si hay capacidad; F5 necesita F4 (la RI cubre lo que el
lenguaje tenga en ese momento) y F7 necesita F3 (el migrador necesita el árbol sin pérdida) y F5.

### F0 · Decisiones fundacionales e integración continua

- **Objetivo.** Tomar las decisiones que bloquean todo lo demás y hacer continua la verificación que ya
  existe.
- **Entradas.** Esta investigación.
- **Contenido.** Decisiones [D-01](17-riesgos-preguntas-y-decisiones.md#d-01),
  [D-02](17-riesgos-preguntas-y-decisiones.md#d-02), [D-03](17-riesgos-preguntas-y-decisiones.md#d-03),
  [D-08](17-riesgos-preguntas-y-decisiones.md#d-08), [D-10](17-riesgos-preguntas-y-decisiones.md#d-10),
  [D-11](17-riesgos-preguntas-y-decisiones.md#d-11), [D-22](17-riesgos-preguntas-y-decisiones.md#d-22),
  [D-23](17-riesgos-preguntas-y-decisiones.md#d-23); provisionalmente D-09. CI que ejecuta, en cada
  cambio, los verificadores de los cinco miembros (§2.5 del `README.md` raíz).
- **Criterios de aceptación.**
  1. Cada decisión tomada está registrada donde las reglas vigentes lo exigen (`README.md`, `AGENTS.md`)
     en el mismo cambio que la introduce.
  2. La CI falla ante una violación deliberada en cada miembro (caso negativo por verificador).
  3. Ningún cambio en el lenguaje ni en la app.
- **Experimentos.** E-01 (línea base).

### F1 · Sistema de especificaciones: producto mínimo

- **Depende de.** F0 (D-10, CI).
- **Contenido.** `packages/pseudolearn_spec` con lo marcado «en el mínimo» en
  [11](11-especificaciones-ejecutables-diseno.md) §14; adaptador del núcleo; migración de tres secciones
  (E-15).
- **Criterios de aceptación.**
  1. El validador rechaza, con caso negativo cada una: identificador duplicado, regla huérfana, valor
     `capturado` sin revisor, hash de contenido que no coincide con la versión, ciclo de dependencias.
  2. El ejecutor corre todos los casos migrados en **los dos perfiles** contra el núcleo y produce la
     matriz regla × sujeto en la CI.
  3. El informe de impacto se genera para un cambio de prueba y lista dependientes, vínculos y
     documentación afectados.
  4. Criterio de éxito de E-15 cumplido o, si no, informe de por qué y propuesta de ajuste.
  5. `PHASE-GREEN` en el paquete nuevo y en el núcleo.

### F2 · Saneamiento del núcleo bajo contrato

- **Depende de.** F1.
- **Contenido.** Corrección de los hallazgos aprobados en D-22, cada uno con su caso: recuperación
  sintáctica (H-05, H-06), advertencia de variable de control (H-37), frontera pública sin excepciones
  (H-08, H-09), instantáneas completas e inmutables (H-10), representación textual única (H-25),
  ejecución de JS y Wasm en la verificación de objetivos (H-27), documentación derivada (H-01, H-02,
  H-03, H-07, H-28). E-04 y E-06 si caben.
- **Criterios de aceptación.**
  1. Las reglas afectadas pasan de `pendiente` a `cumple` en la matriz.
  2. Prueba de robustez de la API pública: ninguna excepción escapa ante programas generados y entradas
     extremas (tamaños, profundidades, texto vacío, Unicode descompuesto).
  3. La traza de la app muestra arreglos y valores con la representación de la especificación.
  4. El corpus se ejecuta en nativo, JavaScript y Wasm con resultados idénticos.

### F3 · Front-end sin pérdida, servicio de lenguaje y editores

- **Depende de.** F2.
- **Contenido.** Árbol sin pérdida con comentarios; análisis incremental e identidad estable (E-08);
  gramática formal especificada (§14 de la especificación vigente) y gramáticas de tree-sitter generadas
  por perfil (E-18); motor de autocompletado de [07](07-herramientas-y-autocompletado.md) §4;
  formateador y traductor entre perfiles; `pseudo lsp`; extensión de VS Code; integración en IntelliJ
  por su API LSP; la app consume el servicio.
- **Criterios de aceptación.**
  1. Latencias de [05](05-rendimiento-motor-y-compilacion.md) §7 cumplidas en hardware de referencia, o
     informe de E-08 con la decisión consiguiente (E-21).
  2. `APP.EDITOR.COMPLETION` en `cumple`: 100 % de plantillas válidas; métricas de E-09 publicadas como
     línea base.
  3. Traducción español ↔ inglés sin pérdida (comentarios incluidos) en todo el corpus; doble traducción
     idéntica al original.
  4. Las gramáticas generadas coinciden con el parser de referencia en el corpus.
  5. La extensión de VS Code ofrece diagnósticos, autocompletado, formateo e ir a definición.

### F4 · Edición A: fundamentos de propósito general (compatibles)

- **Depende de.** F2; decisiones D-11, D-13, D-14, D-15, D-16, D-19, D-21.
- **Contenido.** Mecanismo de ediciones en el manifiesto; módulos e importación con visibilidad de
  módulo; constantes; enumerados, `Opcional` y `Segun` exhaustivo; registros como tipos valor; errores
  con `Resultado`; interfaces; normalización NFC; vocabulario nuevo contextual; biblioteca estándar
  inicial (texto, matemáticas, archivos según D-03).
- **Criterios de aceptación.**
  1. Cada construcción tiene especificación `estable` con casos en ambos perfiles, impacto en el
     presupuesto reservado medido (E-10) y reglas EST-01 a EST-10 superadas o justificadas.
  2. Todos los programas válidos de la edición vigente siguen siendo válidos y con el mismo significado
     (cambios solo compatibles) — verificado sobre el corpus y los documentos de ejemplo.
  3. Diagnósticos con código propio y ficha bilingüe para cada caso inválido.

### F5 · Representación intermedia y VM observable

- **Depende de.** F4 (para cubrir el lenguaje vigente en ese momento); D-05, D-18; E-03.
- **Contenido.** Especificación `IR.*`; traducción del AST a RI; VM de registros en Dart; contrato
  `ENG.TRACE.*` con instantáneas incrementales; reproducción determinista (E-07); la app ejecuta en la
  VM con ritmos sobre eventos y sin tope de micro-pasos en modo no observado.
- **Criterios de aceptación.**
  1. Conformidad de la VM igual a la del intérprete de referencia en todo el corpus, incluidas las
     trazas.
  2. Nivel N1 de rendimiento en la suite y latencia por paso observado ≤ 1 ms en el dispositivo de
     referencia más modesto.
  3. `Fib(20)` y los ejercicios de la base de conocimiento corren completos en la app.
  4. Retroceso de un paso en la app mediante reproducción, si E-07 lo aprobó.

### F6 · Primer backend nativo y runtime

- **Depende de.** F5; D-04, D-06, D-07; E-02, E-05.
- **Contenido.** Backend elegido; runtime con el modelo de memoria decidido; `pseudo compilar`;
  conformidad del AOT; protocolo de benchmarks de [16](16-experimentos-y-benchmarks.md) §2.
- **Criterios de aceptación.**
  1. Conformidad del AOT igual a la de la VM en el corpus (salidas, diagnósticos de ejecución,
     terminación).
  2. Informe de rendimiento publicado según el protocolo, con el nivel alcanzado por familia y
     plataforma, incluidos los resultados desfavorables.
  3. `MEM.MANAGED.UNOBSERVABLE#Q1` en `cumple`.

### F7 · Edición B: cambios incompatibles y abstracción

- **Depende de.** F3 (migrador), F5, F6; D-12, D-17, D-24.
- **Contenido.** Ámbitos de bloque; funciones como valores y closures; genéricos y colecciones de la
  biblioteca estándar; `Para Cada`; límites de recursos; salida anticipada si se aprueba; `pseudo
  migrar` de la edición A a la B.
- **Criterios de aceptación.**
  1. Migración automática de todo el corpus y de los ejemplos de la base de conocimiento, con revisión de
     las diferencias.
  2. Programas de edición A y B enlazados en un mismo programa.
  3. Especificaciones de closures, ámbitos y genéricos en `estable` con dos sujetos (VM y AOT).
  4. La app visualiza entornos capturados y tipos genéricos.

### F8 · Paquetes, espacios de trabajo, aliases y eliminación de código

- **Depende de.** F4 (módulos), F6 (artefactos); D-08, D-19.
- **Contenido.** Manifiesto, espacio de trabajo, archivo de bloqueo con hashes, resolutor único con
  aliases, eliminación de código según D-08 con informe de tamaño (E-19); dependencias de un registro si
  D-01 lo contempla.
- **Criterios de aceptación.**
  1. Compilador, servidor de lenguaje y app resuelven igual todo el corpus de resolución (casos de
     `TOOL.RESOLVE.*`).
  2. La garantía semántica de la eliminación (TS-3) verificada: mismos resultados con y sin eliminación.

### F9 · Comunidad y gobernanza

- **Depende de.** D-01.
- **Contenido.** Publicación del corpus y de la documentación generada en ambos idiomas; proceso de
  propuestas (estados de [11](11-especificaciones-ejecutables-diseno.md) §2 abiertos a la comunidad);
  guía de contribución; registro de paquetes.
- **Criterios de aceptación.** A definir con D-01.

### F10 · Horizonte

Concurrencia estructurada; interoperabilidad con C; autoalojamiento; JIT de escritorio si algún
experimento la justifica; propiedad opcional; semántica central en un DSL ejecutable. Sin fecha: cada
punto entra en la hoja de ruta solo con una especificación en estado `propuesta` y un experimento.

---

## 3. Qué no hace esta hoja de ruta

- No fija fechas ni tamaño de equipo: el repositorio no da información para estimarlos con honestidad.
- No autoriza ninguna fase: cada una empieza con un mensaje explícito de la persona responsable.
- No sustituye las decisiones de [17](17-riesgos-preguntas-y-decisiones.md): varias fases cambian de
  contenido según cómo se resuelvan.
