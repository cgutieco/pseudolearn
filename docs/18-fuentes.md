# 18 · Fuentes

> **Estado:** investigación, no normativo. Fecha de consulta de todas las fuentes externas:
> 2026-10-13.

**Marcas de verificación**

- **[V]** Verificada en esta investigación (búsqueda o lectura el 2026-10-13): existencia, autoría,
  fecha y afirmación usada.
- **[C]** Referencia bibliográfica conocida y estable; el enlace o algún detalle no se comprobó en esta
  sesión. Antes de citarla en un documento normativo conviene verificarla.

**Tipo:** P = fuente primaria (especificación, artículo original, documentación oficial, notas de
versión); S = secundaria (resumen, blog de terceros, prensa).

---

## 1. Repositorio (fuentes internas, todas leídas o ejecutadas)

| Fuente                                                         | Uso                                                                  |
|----------------------------------------------------------------|----------------------------------------------------------------------|
| `AGENTS.md`                                                    | Reglas transversales, precedencia, `CONFLICT-REPORT`                 |
| `README.md` (raíz)                                             | Mapa del monorepo, versión de producto, exclusiones                  |
| `packages/pseudolearn_core/README.md` y `architecture.yaml`    | Arquitectura del núcleo, decisiones, exclusiones                     |
| `packages/pseudolearn_core/docs/language-spec.md`             | Gramática y semántica vigentes                                       |
| `packages/pseudolearn_core/lib/` y `test/`                     | Verificación de comportamientos; 772 tests ejecutados               |
| `apps/pseudolearn_app/README.md`, `architecture.yaml`, `lib/engine/`, `lib/application/execution/`, `tool/content/` | Integración con el núcleo, ejecución, autocompletado, contenido; 458 tests ejecutados |
| `README.md` de `pseudolearn_backend`, `pseudolearn_brand`, `fe-pseudolearn` | Mapa y excepciones a la fuente única                       |
| `.agents/skills/*/SKILL.md`                                    | Reglas de especificación, documentación y cierre de fase             |
| `.github/workflows/*.yml`                                      | Ausencia de CI de verificación                                       |
| `CHANGELOG.json`                                               | Versionado del par (app, núcleo)                                     |

---

## 2. Bilingüismo, localización y pedagogía

| Fuente | Tipo | Fecha | Enlace | Usada para | Límite | Estado |
|---|---|---|---|---|---|---|
| A. van Wijngaarden et al., *Revised Report on the Algorithmic Language ALGOL 68* | P | 1975–76 | [Kestrel (PDF)](https://www.kestrel.edu/people/meertens/publications/papers/Revised_Report_on_the_Algorithmic_Language_ALGOL_68.pdf); [GCC Algol 68: representation languages](https://snapshots.sourceware.org/gcc/docs/latest/ga68/Representation-languages.html) | Precedente del modelo de dos planos | Histórico; sin datos de adopción por idioma | [V] |
| 1C:Enterprise 8.3.23, *Developer Guide*, §4.1 | P | 2023 | [kb.1ci.com](https://kb.1ci.com/1C_Enterprise_Platform/Guides/Developer_Guides/1C_Enterprise_8.3.23_Developer_Guide/Chapter_4._1C_Enterprise_language/4.1._Purpose_and_brief_description_of_1C_Enterprise_language) | Operadores bilingües mezclables | Plataforma propietaria de dominio empresarial | [V] |
| 1C:Language Tool | P | 2019 | [1c-dn.com](https://1c-dn.com/news/1c_language_tool_has_become_available/) | Traducción de código y metadatos | — | [V] |
| W. R. Cook, «AppleScript», HOPL III | P | 2007 | [PDF](https://pdos.csail.mit.edu/6.828/2007/readings/applescript.pdf) | Dialectos de AppleScript | El motivo del abandono procede de fuentes secundarias | [V] |
| MacScripter, «AppleScript Not Necessarily in English» | S | — | [macscripter.net](https://www.macscripter.net/viewtopic.php?id=24589) | Abandono de dialectos en Mac OS 8.5 y su motivo | Foro | [V] |
| F. Hermans, «Hedy: An Inclusive, Multi-Lingual, and Gradual Programming Language», ICPEC | P | 2024 | [Dagstuhl](https://drops.dagstuhl.de/entities/document/10.4230/OASIcs.ICPEC.2024.1) | Palabras clave en decenas de idiomas | Resumen de charla invitada | [V] |
| M. Gilsing, J. Pelay, F. Hermans, «Design, implementation and evaluation of the Hedy programming language», *J. Computer Languages* | P | 2022 | [PDF](https://hedy.org/research/Design_Implementation_and_evaluation_of_the_Hedy_programming_language_2022.pdf) | Gradualidad; deseo de localizar palabras clave | Lenguaje para niños | [V] |
| S. Dasgupta, B. M. Hill, «Learning to Code in Localized Programming Languages», L@S | P | 2017 | [DOI 10.1145/3051457.3051464](https://doi.org/10.1145/3051457.3051464) | Localización y aprendizaje | Bloques (Scratch), no texto; aprendizaje, no producción | [V] |
| P. J. Guo, «Non-Native English Speakers Learning Computer Programming», CHI | P | 2018 | [DOI 10.1145/3173574.3173970](https://doi.org/10.1145/3173574.3173970) | Barreras de quien no es nativo en inglés | Encuesta | [V] |
| A. Stefik, S. Siebert, «An Empirical Investigation into Programming Language Syntax», TOCE 13(4) | P | 2013 | [DOI 10.1145/2534973](https://doi.org/10.1145/2534973) | Método para evaluar sintaxis con novatos | Debate sobre generalización | [V] |
| Rest of World, sobre Lenguaje Latino | S | 2022 | [restofworld.org](https://restofworld.org/2022/tech-workers-latin-america-programming-spanish/) | Precedente monolingüe en español | Prensa | [V] |
| J. Sorva, «Notional Machines and Introductory Programming Education», TOCE 13(2) | P | 2013 | [DOI 10.1145/2483710.2483713](https://doi.org/10.1145/2483710.2483713) | Máquina nocional | — | [C] |
| P. J. Guo, «Online Python Tutor», SIGCSE | P | 2013 | [PDF](https://pg.ucsd.edu/publications/Online-Python-Tutor-web-based-program-visualization_SIGCSE-2013.pdf) | Visualización de ejecución | — | [V] |
| B. A. Becker et al., «Compiler Error Messages Considered Unhelpful», ITiCSE-WGR | P | 2019 | [DOI 10.1145/3344429.3372508](https://doi.org/10.1145/3344429.3372508) | Diagnósticos para novatos | Revisión de literatura | [V] |
| W. Crichton, G. Gray, S. Krishnamurthi, «A Grounded Conceptual Model for Ownership Types in Rust», OOPSLA | P | 2023 | [Brown CEL](https://cel.cs.brown.edu/paper/ownership-conceptual-model/) | Aprendibilidad de la propiedad | Población de quienes aprenden Rust | [V] |
| Pyret | P | — | [pyret.org](https://pyret.org) | Pruebas en el lenguaje con origen pedagógico | — | [C] |

## 3. Unicode, identificadores y palabras clave

| Fuente | Tipo | Fecha | Enlace | Usada para | Estado |
|---|---|---|---|---|---|
| Unicode UAX #31, *Unicode Identifiers and Syntax*, rev. 43 (Unicode 17.0) | P | 2025-08 | [unicode.org/reports/tr31](https://www.unicode.org/reports/tr31/) | Sintaxis de identificadores | [V] |
| Unicode UTS #39, *Unicode Security Mechanisms* (17.0) | P | 2025 | [unicode.org/reports/tr39](https://www.unicode.org/reports/tr39/) | Confundibles y mezcla de escrituras | [V] |
| PEP 3131, *Supporting Non-ASCII Identifiers* | P | 2007 | [peps.python.org/pep-3131](https://peps.python.org/pep-3131/) | NFKC en Python | [C] |
| Rust RFC 2457, *Non-ASCII identifiers* | P | 2018 | [rust-lang.github.io/rfcs/2457](https://rust-lang.github.io/rfcs/2457-non-ascii-idents.html) | NFC y avisos de confundibles | [C] |
| Rust RFC 2151, *Raw identifiers* | P | 2017 | [rust-lang.github.io/rfcs/2151](https://rust-lang.github.io/rfcs/2151-raw-identifiers.html) | Escape de identificadores | [C] |
| PEP 634, *Structural Pattern Matching* (palabras clave blandas) | P | 2020 | [peps.python.org/pep-0634](https://peps.python.org/pep-0634/) | Palabras clave contextuales | [C] |

## 4. Evolución y gobierno de lenguajes

| Fuente | Tipo | Fecha | Enlace | Usada para | Estado |
|---|---|---|---|---|---|
| R. Cox, «Backward Compatibility, Go 1.21, and Go 2» | P | 2023-08-14 | [go.dev/blog/compat](https://go.dev/blog/compat) | Promesa de compatibilidad, `GODEBUG` | [V] |
| D. Chase, R. Cox, «Fixing For Loops in Go 1.22» | P | 2023-09-19 | [go.dev/blog/loopvar-preview](https://go.dev/blog/loopvar-preview) | Variable de bucle por iteración; cambio atado a versión | [V] |
| Rust 1.85.0 y edición 2024 | P | 2025-02-20 | [blog.rust-lang.org](https://blog.rust-lang.org/2025/02/20/Rust-1.85.0/) | Ediciones | [V] |
| *The Rust Edition Guide* | P | — | [doc.rust-lang.org/edition-guide](https://doc.rust-lang.org/edition-guide/) | Migración entre ediciones | [C] |
| Versionado de lenguaje de Dart | P | — | [dart.dev/language/versions](https://dart.dev/language/versions) (verificado en su réplica dart.cn) | Versión por paquete y anulación por biblioteca | [V] |
| Modificadores de clase de Dart | P | 2023– | [dart.dev/language/class-modifiers](https://dart.dev/language/class-modifiers); [referencia](https://dart.dev/language/modifier-reference) | Rasgos de Dart | [V] |
| PEP 387, *Backwards Compatibility Policy* | P | — | [peps.python.org/pep-0387](https://peps.python.org/pep-0387/) | Deprecación | [C] |
| JEP 12, *Preview Features* | P | — | [openjdk.org/jeps/12](https://openjdk.org/jeps/12) | Funcionalidades en vista previa | [C] |
| Proceso de TC39 | P | — | [tc39.es/process-document](https://tc39.es/process-document/) | Etapas; dos implementaciones para aprobar | [C] |
| test262 | P | — | [github.com/tc39/test262](https://github.com/tc39/test262) | Suite de conformidad con metadatos de sección | [C] |
| «Announcing Swift 6» | P | 2024 | [swift.org/blog/announcing-swift-6](https://swift.org/blog/announcing-swift-6/) | Modo de lenguaje con ausencia de carreras | [V] |
| SE-0390, *Noncopyable structs and enums* | P | 2023 | [foro de Swift](https://forums.swift.org/t/second-review-se-0390-noncopyable-structs-and-enums/63866) | Propiedad opcional sobre ARC | [V] |
| SE-0377, *borrowing and consuming parameter ownership modifiers*; SE-0413, *Typed throws* | P | 2023 | [swift-evolution](https://github.com/swiftlang/swift-evolution) | Propiedad opcional; errores tipados | [C] |
| R. Griesemer et al., «Featherweight Go», OOPSLA | P | 2020 | [arXiv 2005.11710](https://arxiv.org/abs/2005.11710) | Genéricos mínimos | [C] |
| J. Duffy, «The Error Model» | P | 2016 | [joeduffyblog.com](https://joeduffyblog.com/2016/02/07/the-error-model/) | Errores recuperables frente a defectos | [C] |
| B. Meyer, «Applying "Design by Contract"», *IEEE Computer* 25(10) | P | 1992 | — | Contratos | [C] |
| L. Mikhajlov, E. Sekerinski, «A Study of the Fragile Base Class Problem», ECOOP | P | 1998 | — | Marca de sobrescritura | [C] |
| N. J. Smith, «Notes on structured concurrency» | P | 2018 | [vorpus.org](https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/) | Concurrencia estructurada | [C] |
| E. Lippert, «Closing over the loop variable considered harmful» | P | 2009 | [ericlippert.com](https://ericlippert.com/2009/11/12/closing-over-the-loop-variable-considered-harmful-part-one/) | Cambio de C# 5 en `foreach` | [C] |
| Ley de Hyrum | S | — | [hyrumslaw.com](https://www.hyrumslaw.com/) | Todo comportamiento observable acaba siendo dependido | [C] |

## 5. Rendimiento, ejecución y compilación

| Fuente | Tipo | Fecha | Enlace | Usada para | Límite | Estado |
|---|---|---|---|---|---|---|
| S. Marr, B. Daloze, H. Mössenböck, «Cross-Language Compiler Benchmarking: Are We Fast Yet?», DLS | P | 2016 | [stefan-marr.de](https://stefan-marr.de/papers/dls-marr-et-al-cross-language-compiler-benchmarking-are-we-fast-yet/) | Suite de referencia | Subconjunto común de lenguajes OO | [V] |
| E. Barrett et al., «Virtual Machine Warmup Blows Hot and Cold», OOPSLA | P | 2017 | [arXiv 1602.00602](https://arxiv.org/abs/1602.00602) | Calentamiento y estado estable | Micro-pruebas | [V] |
| A. Georges, D. Buytaert, L. Eeckhout, «Statistically Rigorous Java Performance Evaluation», OOPSLA | P | 2007 | [DOI 10.1145/1297027.1297033](https://doi.org/10.1145/1297027.1297033) | Estadística de benchmarks | — | [C] |
| T. Kalibera, R. Jones, «Rigorous Benchmarking in Reasonable Time», ISMM | P | 2013 | [DOI 10.1145/2464157.2464160](https://doi.org/10.1145/2464157.2464160) | Diseño de repeticiones | — | [C] |
| T. Mytkowicz et al., «Producing Wrong Data Without Doing Anything Obviously Wrong!», ASPLOS | P | 2009 | [DOI 10.1145/1508244.1508275](https://doi.org/10.1145/1508244.1508275) | Sesgos de medición | — | [C] |
| Computer Language Benchmarks Game | S | — | [benchmarksgame-team.pages.debian.net](https://benchmarksgame-team.pages.debian.net/benchmarksgame/) | Programas de referencia | Programas optimizados por implementación | [C] |
| U. Hölzle, C. Chambers, D. Ungar, «Debugging Optimized Code with Dynamic Deoptimization», PLDI | P | 1992 | [Self bibliography](https://bibliography.selflanguage.org/dynamic-deoptimization.html) | Desoptimización para observar | — | [V] |
| U. Hölzle, C. Chambers, D. Ungar, cachés en línea polimórficas, ECOOP | P | 1991 | — | Cachés en línea | — | [C] |
| C. Chambers, D. Ungar, E. Lee, «An Efficient Implementation of SELF», OOPSLA | P | 1989 | — | Mapas / clases ocultas | — | [C] |
| V8, «Maglev — V8's Fastest Optimizing JIT» y resumen de 2023 | P | 2023 | [v8.dev/blog/maglev](https://v8.dev/blog/maglev); [v8.dev/blog/holiday-season-2023](https://v8.dev/blog/holiday-season-2023) | Escalonamiento de JIT | — | [V] |
| H. Xu, F. Kjolstad, «Copy-and-Patch Compilation», OOPSLA | P | 2021 | [arXiv 2011.13127](https://arxiv.org/abs/2011.13127) | JIT base de bajo coste | — | [V] |
| PEP 744, *JIT Compilation* | P | 2024 | [peps.python.org/pep-0744](https://peps.python.org/pep-0744/) | JIT de CPython | Borrador informativo | [V] |
| PEP 659, *Specializing Adaptive Interpreter* | P | 2021 | [peps.python.org/pep-0659](https://peps.python.org/pep-0659/) | Especialización en intérpretes | — | [C] |
| T. Würthinger et al., «Practical Partial Evaluation for High-Performance Dynamic Language Runtimes», PLDI | P | 2017 | [DOI 10.1145/3062341.3062381](https://doi.org/10.1145/3062341.3062381) | Evaluación parcial | — | [V] |
| A. Gal et al., «Trace-based Just-in-Time Type Specialization for Dynamic Languages», PLDI | P | 2009 | — | JIT por trazas | — | [C] |
| C. F. Bolz et al., «Tracing the Meta-Level: PyPy's Tracing JIT Compiler», ICOOOLPS | P | 2009 | — | Meta-trazas | — | [C] |
| Y. Shi, D. Gregg, A. Beatty, M. A. Ertl, «Virtual Machine Showdown: Stack Versus Registers», VEE | P | 2005 | — | VM de registros | — | [C] |
| R. Ierusalimschy, L. H. de Figueiredo, W. Celes, «The Implementation of Lua 5.0», *J.UCS* | P | 2005 | — | VM de registros | — | [C] |
| M. A. Ertl, D. Gregg, «The Structure and Performance of Efficient Interpreters», JILP | P | 2003 | — | Despacho en intérpretes | — | [C] |
| J. Hennessy, «Symbolic Debugging of Optimized Code», TOPLAS | P | 1982 | — | Depuración de código optimizado | — | [C] |
| WebAssembly 3.0 | P | 2025-09-17 | [webassembly.org](https://webassembly.org/news/2025-09-17-wasm-3.0) | Wasm GC, memoria de 64 bits, excepciones | — | [V] |
| Apple, BrowserEngineKit; *App Review Guidelines* | P | 2024– | [BrowserEngineKit](https://developer.apple.com/documentation/browserenginekit); [guías](https://developer.apple.com/app-store/review/guidelines/) | Generación de código en iOS | — | [C] |
| Cranelift; LLVM; QBE | P | — | [cranelift.dev](https://cranelift.dev); [llvm.org](https://llvm.org); [c9x.me/compile](https://c9x.me/compile/) | Backends | — | [C] |
| CISA y socios, «The Case for Memory Safe Roadmaps» | P | 2023-12 | [cisa.gov](https://www.cisa.gov/case-memory-safe-roadmaps) | Lenguajes con seguridad de memoria | — | [V] |

## 6. Gestión de memoria

| Fuente | Tipo | Fecha | Enlace | Usada para | Límite | Estado |
|---|---|---|---|---|---|---|
| Notas de versión de Go 1.26 (Green Tea) | P | 2026 | [go.dev/doc/go1.26](https://go.dev/doc/go1.26) | Recolector de Go | Cifras estimadas por el equipo de Go | [V] |
| *A Guide to the Go Garbage Collector* | P | — | [go.dev/doc/gc-guide](https://go.dev/doc/gc-guide) | `GOGC`, `GOMEMLIMIT` | — | [C] |
| S. M. Blackburn, K. S. McKinley, «Immix», PLDI | P | 2008 | [DOI 10.1145/1375581.1375586](https://doi.org/10.1145/1375581.1375586) | Diseño de montón | — | [C] |
| W. Zhao, S. M. Blackburn, K. S. McKinley, «Low-Latency, High-Throughput Garbage Collection» (LXR), PLDI | P | 2022 | [arXiv 2210.17175](https://arxiv.org/abs/2210.17175) | Conteo en montón Immix | Evaluación en la JVM | [V] |
| MMTk | P | — | [mmtk.io](https://www.mmtk.io) | Recolectores como biblioteca | — | [C] |
| D. F. Bacon, P. Cheng, V. T. Rajan, «A Unified Theory of Garbage Collection», OOPSLA | P | 2004 | [PDF](https://web.eecs.umich.edu/~weimerw/2014-4610/reading/bacon-garbage.pdf) | Dualidad trazado/conteo | — | [V] |
| A. Reinking, N. Xie, L. de Moura, D. Leijen, «Perceus», PLDI | P | 2021 | [Microsoft Research](https://www.microsoft.com/en-us/research/publication/perceus-garbage-free-reference-counting-with-reuse/) | Conteo con reutilización | Sin ciclos | [V] |
| S. Ullrich, L. de Moura, «Counting Immutable Beans», IFL | P | 2019 | [arXiv 1908.05647](https://arxiv.org/abs/1908.05647) | Conteo en Lean 4 | Lenguaje puro | [V] |
| Nim, gestión de memoria (ORC, `acyclic`) | P | — | [nim-lang.org/docs/mm.html](https://nim-lang.org/docs/mm.html) | Conteo con recolector de ciclos | — | [C] |
| D. Racordon et al., «Implementation Strategies for Mutable Value Semantics», JOT 21 | P | 2022 | [preprint](https://daveabrahams.com/wp-content/uploads/2022/02/implementation_strategies_for_mutable_value_semantics-preprint.pdf) | Valores mutables | — | [V] |
| E. Ovadia, «Generational References» | P | 2021– | [vale.dev](https://vale.dev/blog/generational-references) | Referencias generacionales | Cifras del autor, una carga | [V] |
| M. Tofte, J.-P. Talpin, «Region-Based Memory Management», *Information and Computation* | P | 1997 | — | Regiones | — | [C] |
| D. Grossman et al., «Region-Based Memory Management in Cyclone», PLDI | P | 2002 | — | Regiones con tipos | — | [C] |
| JEP 401, *Value Classes and Objects* | P | — | [openjdk.org/jeps/401](https://openjdk.org/jeps/401) | Tipos valor en lenguaje con recolector | — | [C] |

## 7. Herramientas de lenguaje

| Fuente | Tipo | Fecha | Enlace | Usada para | Estado |
|---|---|---|---|---|---|
| Language Server Protocol (3.17 estable; 3.18 «actual, en desarrollo») | P | — | [microsoft.github.io/language-server-protocol](https://microsoft.github.io/language-server-protocol/) | Protocolo de edición | [V] |
| Debug Adapter Protocol | P | — | [microsoft.github.io/debug-adapter-protocol](https://microsoft.github.io/debug-adapter-protocol/) | Depuración y paso a paso | [C] |
| JetBrains, «The LSP API is now available to all IntelliJ IDEA users and plugin developers» | P | 2025-09 | [blog.jetbrains.com](https://blog.jetbrains.com/platform/2025/09/the-lsp-api-is-now-available-to-all-intellij-idea-users-and-plugin-developers/) | Integración con IntelliJ | [V] |
| JetBrains, «Open-Sourcing the LSP Client API in IntelliJ IDEA 2026.2» | P | 2026-06 | [blog.jetbrains.com](https://blog.jetbrains.com/platform/2026/06/open-sourcing-the-lsp-client-api-in-intellij-idea-2026-2/) | Solo el título verificado | [V] |
| IntelliJ Platform SDK, LSP | P | — | [plugins.jetbrains.com/docs/intellij/language-server-protocol.html](https://plugins.jetbrains.com/docs/intellij/language-server-protocol.html) | IDE compatibles | [V] |
| LSP4IJ (Red Hat) | P | — | [github.com/redhat-developer/lsp4ij](https://github.com/redhat-developer/lsp4ij) | Alternativa para versiones anteriores | [C] |
| rust-analyzer, *Architecture* | P | — | [github.com/rust-lang/rust-analyzer](https://github.com/rust-lang/rust-analyzer) (`docs/dev/architecture.md`, verificado en réplicas) | Árbol sin pérdida, salsa, análisis que nunca falla | [V] |
| salsa; rowan | P | — | [github.com/salsa-rs/salsa](https://github.com/salsa-rs/salsa); [github.com/rust-analyzer/rowan](https://github.com/rust-analyzer/rowan) | Incrementalidad; árbol | [C] |
| E. Lippert, «Persistence, façades and Roslyn's red-green trees» | P | 2012 | [ericlippert.com](https://ericlippert.com/2012/06/08/red-green-trees/) | Árboles rojo-verde | [C] |
| A. Kladov, «Resilient LL Parsing Tutorial» | P | (fecha no verificada) | [matklad.github.io](https://matklad.github.io/2023/05/21/resilient-ll-parsing-tutorial.html) | Análisis resiliente | [C] |
| tree-sitter | P | — | [tree-sitter.github.io](https://tree-sitter.github.io/tree-sitter/) | Gramáticas para editores | [C] |
| T. A. Wagner, S. L. Graham, «Efficient and Flexible Incremental Parsing», TOPLAS | P | 1998 | — | Reanálisis incremental | [C] |
| R. O'Callahan et al., «Engineering Record and Replay for Deployability», USENIX ATC | P | 2017 | [rr-project.org](https://rr-project.org) | Grabación y reproducción | [C] |

## 8. Módulos, paquetes y eliminación de código

| Fuente | Tipo | Fecha | Enlace | Usada para | Estado |
|---|---|---|---|---|---|
| Go Modules Reference; espacios de trabajo | P | 2022– | [go.dev/ref/mod](https://go.dev/ref/mod); [go.dev/doc/tutorial/workspaces](https://go.dev/doc/tutorial/workspaces) | Módulos y espacios de trabajo | [C] |
| R. Cox, «Minimal Version Selection» | P | 2018 | [research.swtch.com/vgo-mvs](https://research.swtch.com/vgo-mvs) | Selección de versiones | [C] |
| Cargo, *Workspaces* | P | — | [doc.rust-lang.org/cargo/reference/workspaces.html](https://doc.rust-lang.org/cargo/reference/workspaces.html) | Archivo de bloqueo compartido | [C] |
| Dart, *Pub workspaces*; «Announcing Dart 3.6» | P | 2024 | [dart.dev/tools/pub/workspaces](https://dart.dev/tools/pub/workspaces) (verificado en réplica dart.cn) | Espacios de trabajo en Dart | [V] |
| TypeScript, `paths` | P | — | [typescriptlang.org/tsconfig/#paths](https://www.typescriptlang.org/tsconfig/#paths) | Aliases | [C] |
| Node.js, *Subpath imports* | P | — | [nodejs.org/api/packages.html#subpath-imports](https://nodejs.org/api/packages.html#subpath-imports) | Aliases resueltos por el entorno | [C] |
| WHATWG, *Import maps* | P | — | [html.spec.whatwg.org](https://html.spec.whatwg.org/multipage/webappapis.html#import-maps) | Mapas de importación | [C] |
| Rollup, *Tree-shaking* | P | — | [rollupjs.org](https://rollupjs.org/introduction/#tree-shaking) | Origen del término | [C] |
| Dart SDK, `vm:entry-point` | P | — | [github.com/dart-lang/sdk](https://github.com/dart-lang/sdk/blob/main/runtime/docs/compiler/aot/entry_point_pragma.md) | Raíces explícitas en AOT | [C] |
| GraalVM Native Image, compatibilidad y metadatos de alcanzabilidad | P | — | [graalvm.org](https://www.graalvm.org/dev/reference-manual/native-image/metadata/Compatibility/) | Mundo cerrado | [V] |
| Android, reducción de código con R8 | P | — | [developer.android.com/build/shrink-code](https://developer.android.com/build/shrink-code) | Reglas `keep` | [C] |
| Sigstore | P | — | [sigstore.dev](https://www.sigstore.dev) | Firma de paquetes | [C] |

## 9. Especificaciones ejecutables, pruebas y trazabilidad

| Fuente | Tipo | Fecha | Enlace | Usada para | Límite | Estado |
|---|---|---|---|---|---|---|
| B. Böckeler, «Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl» | S (análisis experto) | 2025-10-15 | [martinfowler.com](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) | Niveles de SDD | Herramientas de IA en evolución | [V] |
| GitHub Spec Kit (anuncio y repositorio) | P | 2025-09-02 | [github.com/github/spec-kit](https://github.com/github/spec-kit); [Microsoft Developer Blog](https://developer.microsoft.com/blog/spec-driven-development-spec-kit) | SDD | — | [V] |
| Kiro; Tessl | P | 2025 | [kiro.dev](https://kiro.dev); [tessl.io](https://tessl.io) | SDD | — | [C] |
| D. Youn et al., «Bringing the WebAssembly Standard up to Speed with SpecTec», PLDI | P | 2024 | [DOI 10.1145/3656440](https://doi.org/10.1145/3656440) | Especificación como fuente única ejecutable | Dominio Wasm | [V] |
| J. Park et al., «JEST: N+1-version Differential Testing of Both JavaScript Engines and Specification», ICSE | P | 2021 | [arXiv 2102.07498](https://arxiv.org/abs/2102.07498) | Diferencial con la especificación | Dominio ECMAScript | [V] |
| ESMeta | P | — | [github.com/es-meta/esmeta](https://github.com/es-meta/esmeta) | Semántica mecanizada de ECMAScript | — | [C] |
| Rust Project, «Adopting the FLS» | P | 2025-03-26 | [blog.rust-lang.org](https://blog.rust-lang.org/2025/03/26/adopting-the-fls/) | Especificación de Rust | — | [V] |
| K Framework; PLT Redex; Ott | P | — | [kframework.org](https://kframework.org); [redex.racket-lang.org](https://redex.racket-lang.org); [Ott](https://www.cl.cam.ac.uk/~pes20/ott/) | Semántica ejecutable | — | [C] |
| Gherkin (Cucumber), incluida la localización al español | P | — | [cucumber.io/docs/gherkin/reference](https://cucumber.io/docs/gherkin/reference/) | Formato de casos | — | [C] |
| G. Adzic, *Specification by Example* (Manning) | P | 2011 | — | Ejemplos como contrato | — | [C] |
| K. Claessen, J. Hughes, «QuickCheck», ICFP | P | 2000 | — | Pruebas por propiedades | — | [C] |
| OpenFastTrace | P | — | [github.com/itsallcode/openfasttrace](https://github.com/itsallcode/openfasttrace); [uso en JabRef](https://devdocs.jabref.org/requirements) | Identificadores con revisión y cobertura | Detalle de la revisión inferido del uso | [V] |
| Sphinx-needs; StrictDoc; Doorstop | P | — | [sphinx-needs](https://sphinx-needs.readthedocs.io); [strictdoc](https://strictdoc.readthedocs.io); [doorstop](https://doorstop.readthedocs.io) | Trazabilidad de requisitos | — | [C] |
| JSON Schema; CUE; Pkl | P | — | [json-schema.org](https://json-schema.org); [cuelang.org](https://cuelang.org); [pkl-lang.org](https://pkl-lang.org) | Validación estructural | — | [C] |
| cargo-semver-checks; Elm (`elm diff`); `apidiff` de Go | P | — | [cargo-semver-checks](https://github.com/obi1kenobi/cargo-semver-checks); [elm](https://package.elm-lang.org); [apidiff](https://pkg.go.dev/golang.org/x/exp/apidiff) | Clasificación de cambios | Solo API | [C] |
| RFC 2119 y RFC 8174 | P | 1997, 2017 | [rfc-editor.org/rfc/rfc2119](https://www.rfc-editor.org/rfc/rfc2119); [rfc8174](https://www.rfc-editor.org/rfc/rfc8174) | Fuerza normativa | — | [C] |
| J. C. Knight, N. G. Leveson, «An Experimental Evaluation of the Assumption of Independence in Multiversion Programming», IEEE TSE 12(1) | P | 1986 | [DOI 10.1109/TSE.1986.6312924](https://doi.org/10.1109/TSE.1986.6312924) | Errores compartidos | Un solo programa | [V] |
| X. Yang, Y. Chen, E. Eide, J. Regehr, «Finding and Understanding Bugs in C Compilers» (Csmith), PLDI | P | 2011 | — | Programas aleatorios | — | [C] |
| V. Le, M. Afshari, Z. Su, «Compiler Validation via Equivalence Modulo Inputs», PLDI | P | 2014 | [PDF](https://www.cs.ucdavis.edu/~su/publications/emi.pdf) | EMI | — | [V] |
| W. M. McKeeman, «Differential Testing for Software», *Digital Technical Journal* | P | 1998 | — | Pruebas diferenciales | — | [C] |
| A. Pnueli, M. Siegel, E. Singerman, «Translation Validation», TACAS | P | 1998 | — | Validación de la traducción | — | [C] |
| Y. Jia, M. Harman, «An Analysis and Survey of the Development of Mutation Testing», IEEE TSE | P | 2011 | — | Pruebas de mutación | — | [C] |
