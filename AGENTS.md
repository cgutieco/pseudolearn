# AGENTS.md — Reglas transversales del monorepo PseudoLearn

Este documento vale para **todos** los paquetes del repositorio. No contiene arquitectura de ningún
paquete concreto: las capas, los límites numéricos y las decisiones de diseño de un paquete viven en
el `README.md` de ese paquete, porque el núcleo del lenguaje y la app de Flutter no comparten
arquitectura ni criterios.

---

## 1. Antes de tocar cualquier archivo

En este orden, sin saltarse ninguno:

1. **Localizá el paquete** al que pertenece el archivo (`packages/<nombre>/` o `apps/<nombre>/`).
2. **Leé el `README.md` de ese paquete.** Es la fuente de verdad técnica: arquitectura, capas,
   decisiones y su por qué. Si el paquete no tiene `README.md`, no escribas código: escribí primero
   el README.
3. **Leé el archivo de reglas de ese paquete**, si existe: `architecture.yaml`, o `architecture.json`
   donde el intérprete del paquete no lee YAML sin dependencias añadidas. Contiene las reglas que los
   verificadores ejecutan: capas, matriz de imports permitidos, imports prohibidos y límites de tamaño.
4. **Respondé estas tres preguntas** antes de la primera línea:
    - ¿En qué capa vive este archivo?
    - ¿Qué puede importar esa capa, y qué tiene prohibido importar?
    - ¿La responsabilidad que estoy a punto de escribir ya tiene un archivo dueño, o estoy creando una
      segunda razón de cambio en un archivo que ya tenía una?

Si la respuesta a la tercera es «estoy mezclando», el código va en un archivo nuevo en la capa que le
corresponde — no en el archivo que tenías abierto porque era cómodo.

---

## 2. Contrato de reglas

Cada regla tiene un ID estable. Usá el ID al reportar una violación o al justificar una decisión, en
vez de parafrasear la regla.

| ID                          | Regla                                                                                                                                                                                                                                                                                     | Cómo se verifica                                                                                                                                             |
|-----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DOC-README-TRUTH`          | El `README.md` de cada paquete es la fuente de verdad de arquitectura, operación y por qué de su implementación; el corpus es la fuente de verdad del comportamiento observable. Un cambio de arquitectura o de decisión de diseño actualiza el README **en el mismo cambio**, no después | Revisión del cambio                                                                                                                                          |
| `DOC-NO-TRANSIENT-REFS`     | Ningún archivo fuera de la carpeta documental transitoria de la raíz cita sus documentos, secciones o decisiones como dependencia; corpus y README son autosustentables. Se permiten enlaces internos en esa carpeta y documentación propia de paquetes                                   | Puerta local de referencias con casos negativos                                                                                                              |
| `DOC-NO-ORPHAN-DECISION`    | Ninguna decisión de diseño vive solo en el código o solo en un mensaje de commit                                                                                                                                                                                                          | Revisión del cambio                                                                                                                                          |
| `LANG-EN-CODE`              | Todo el código —identificadores, nombres de test, comentarios, mensajes de commit— en inglés                                                                                                                                                                                              | Revisión del cambio                                                                                                                                          |
| `LANG-ES-DOCS`              | `AGENTS.md`, los `README.md`, las skills, el corpus de especificaciones y los documentos de `docs/` en español                                                                                                                                                                            | Revisión del cambio                                                                                                                                          |
| `QUALITY-NO-COMMENTS`       | Prohibido cualquier tipo de comentario en archivos de código. El código se explica con nombres, tipos y funciones pequeñas; el por qué vive en el `README.md`. En Python se admite un *docstring* por módulo, clase y función, que declara la responsabilidad y nunca la implementación   | Script de límites del paquete (`tool/check_limits.dart`, `tool/check_limits.py`, `scripts/check-no-comments.mjs`, `rust-checks comments`) y su caso negativo |
| `QUALITY-NO-NOISE-COMMENTS` | Prohibido el comentario que repite lo que el código ya dice. El código se explica con nombres y funciones pequeñas                                                                                                                                                                        | Revisión del cambio                                                                                                                                          |
| `QUALITY-NO-DOC-REFS`       | Prohibido citar un documento o una sección desde el código (`// ver AGENTS.md §2`, `// según el README`). Se describe la restricción, nunca dónde está escrita                                                                                                                            | `grep` en revisión                                                                                                                                           |
| `QUALITY-WHY-ONLY`          | El por qué, incluso local, se documenta en el README; no habilita comentarios en código                                                                                                                                                                                                   | Revisión del cambio                                                                                                                                          |
| `LAYER-DIRECTION`           | Una capa solo importa de sí misma o de las capas que el archivo de reglas del paquete le permite. Cero excepciones                                                                                                                                                                        | Test de arquitectura del paquete                                                                                                                             |
| `LAYER-DECLARED`            | Toda carpeta de capa existe declarada en el archivo de reglas del paquete, y toda capa declarada tiene su carpeta                                                                                                                                                                         | Test de arquitectura del paquete                                                                                                                             |
| `SIZE-*`                    | Los límites de tamaño de archivo, función, parámetros, anidación y métodos públicos son los del archivo de reglas del paquete                                                                                                                                                             | Script de límites del paquete                                                                                                                                |
| `GEN-NO-HAND-COPY`          | Un artefacto que un generador del monorepo produce no se edita, ni se pega, ni se reescribe a mano en un consumidor. Se importa, se genera o se verifica                                                                                                                                  | Verificador del generador y del consumidor (`BRAND-*-STALE`, `FE-BRAND-GENERATED`)                                                                           |
| `TEST-BOTH-PATHS`           | Cada pieza se prueba en camino feliz **y** camino infeliz, más casos límite explícitos                                                                                                                                                                                                    | Revisión del cambio                                                                                                                                          |
| `TEST-MIRROR`               | La carpeta de tests refleja la de código. Nada de un `all_tests.dart` común                                                                                                                                                                                                               | Revisión del cambio                                                                                                                                          |
| `SCOPE-YAGNI`               | No se implementa lo que ninguna fase aprobada pide. Si una abstracción solo tiene sentido para soportar algo fuera de alcance, no se escribe                                                                                                                                              | Revisión del cambio                                                                                                                                          |
| `GIT-SINGLE-BRANCH`         | Todo cambio posterior se realiza en `feature/agregar-ruta-de-especificacion`; no se crean ramas de trabajo adicionales. La publicación usa push ordinario a esa misma rama                                                                                                                | `git branch --show-current` y revisión del destino de push                                                                                                   |
| `PHASE-STOP`                | Al cerrar una fase se para y se espera confirmación explícita en un mensaje nuevo. Terminar de describir una fase no es luz verde para la siguiente                                                                                                                                       | Disciplina de trabajo                                                                                                                                        |
| `PHASE-GREEN`               | Ninguna fase se da por cerrada sin tests en verde y todos los verificadores del paquete en verde                                                                                                                                                                                          | Verificación de fase                                                                                                                                         |
| `CONFLICT-REPORT`           | Ante un conflicto entre fuentes, se reporta a la persona en vez de resolverlo por cuenta propia                                                                                                                                                                                           | Disciplina de trabajo                                                                                                                                        |
| `SPEC-BEHAVIOR-TRUTH`       | El comportamiento observable del núcleo vive en el corpus de especificaciones                                                                                                                                                                                                             | Conformidad desde R1                                                                                                                                         |
| `SPEC-FIRST`                | Especificación → casos → tests → código; sin motor Rust antes del hito de R3                                                                                                                                                                                                              | Revisión y conformidad                                                                                                                                       |
| `SPEC-NO-ORPHAN-RULE`       | Cada regla tiene casos o propiedades que la cubren                                                                                                                                                                                                                                        | `see validate` desde R1                                                                                                                                      |
| `SPEC-BINDING-AS-DATA`      | Los vínculos regla–código viven en archivos de conformidad, nunca en código                                                                                                                                                                                                               | Revisión                                                                                                                                                     |
| `SPEC-CHANGE-CLASSIFIED`    | Con el versionado reabierto, cada cambio declara clasificación e impacto; durante el congelamiento rige `SPEC-VERSION-FREEZE`                                                                                                                                                             | `see validate` desde R1                                                                                                                                      |
| `SPEC-INDEPENDENT-ORACLE`   | Los resultados esperados se derivan de la regla; capturas requieren revisión                                                                                                                                                                                                              | Revisión del corpus                                                                                                                                          |
| `SPEC-SELF-CONTAINED`       | El corpus no enlaza ni cita documentación externa; puede enlazar identidades internas del propio corpus                                                                                                                                                                                   | `see validate` y caso negativo                                                                                                                                 |
| `SPEC-VERSION-FREEZE`       | Hasta autorización explícita, estados y versiones permanecen congelados; el texto oficial se edita en la misma especificación, sin `cambio`, y se reancla                                                                                                                                 | Revisión y validación del corpus                                                                                                                             |
| `QUALITY-SEMANTIC-NAMES`    | En Rust nombres por papel, mínimo tres caracteres salvo id/io/ir/vm/gc/os; sin abreviaturas, relleno ni archivos utils/helpers/common/misc                                                                                                                                                | `rust-checks names`                                                                                                                                          |
| `QUALITY-NO-PANIC`          | En Rust sin unwrap/expect, panic/todo/unimplemented/unreachable, índices inseguros, aritmética implícita ni conversiones numéricas con pérdida                                                                                                                                            | Clippy estricto                                                                                                                                              |

---

## 3. Orden de precedencia ante conflictos

De mayor a menor autoridad:

1. Instrucción directa de la persona en la conversación.
2. `AGENTS.md` (este documento).
3. Corpus de especificaciones para comportamiento observable y `README.md` del paquete para arquitectura, operación y
   por qué; sus ámbitos son disjuntos. Si chocan se reporta una clasificación incorrecta.
4. Documentación de terceros consultada.

Dos obligaciones que acompañan a esta lista:

- **Reportar, no resolver.** Si dos fuentes del mismo nivel se contradicen, o una de nivel superior
  contradice a una inferior de forma que cambia el trabajo, se dice explícitamente y se espera
  respuesta. No se elige en silencio.
- **La documentación de terceros no es normativa.** Es referencia consultada. PseudoLearn es dueño de
  su motor y de su gramática; se inspira en herramientas existentes, no las calca. Cuando una fuente
  externa aporte algo, se registra en el README del paquete qué se tomó y qué se rechazó.

---

## 4. Calidad de código

La política de comentarios y la de documentación son una sola decisión, y hay que entenderla completa
o degenera: **el código lleva cero comentarios porque el *por qué* está en el `README.md` del
paquete.** Quitar los comentarios sin escribir el README no es limpieza, es pérdida de información.

- **Cero comentarios en código (`QUALITY-NO-COMMENTS`):** Todo comentario de cualquier tipo (`//`,
  `/* */`, `///`, `#`) está prohibido y es rechazado mecánicamente por el verificador de cada paquete.
  Única excepción, y solo donde el lenguaje la usa como contrato y no como comentario: un *docstring* de
  Python por módulo, clase y función, que declara la responsabilidad en una frase.
- El código se explica solo: nombres completos, funciones pequeñas, tipos explícitos, una sola
  responsabilidad por archivo. El *qué* lo expresa el código; el *por qué* vive en el `README.md`.
- Nunca una referencia a un documento o a una sección: los documentos se reordenan y la referencia
  queda mintiendo.
- Un `TODO` en el código está prohibido: los pendientes técnicos se registran en la sección de pendientes
  declarados del `README.md` del paquete.

---

En Rust también se prohíben comentarios de documentación y `#[doc]`, `#[allow]` y `#[expect]`.
No existe excepción de docstring para Rust. `unsafe` solo se permite en los crates declarados por
`architecture.yaml`, dentro de funciones breves cuyo nombre expresa el invariante y que tienen una
fila en la tabla «Invariantes de `unsafe`» de su README. El verificador exige correspondencia en ambos
sentidos. Los demás crates declaran `#![forbid(unsafe_code)]`.

## 5. Testing como parte de la arquitectura

- La carpeta de tests refleja la estructura del código, y el test vive junto al comportamiento que
  prueba.
- Camino feliz y camino infeliz para cada pieza, más casos límite explícitos: entradas vacías,
  colecciones de tamaño cero, recursión profunda, bordes numéricos, identificadores de un carácter,
  programas vacíos.
- Ninguna excepción sin control cruza la frontera pública de un paquete. Un fallo esperable es un
  valor de retorno, no una excepción que escapa.
- Un test que necesita instanciar tres o cuatro clases para probar una está avisando de acoplamiento
  que la inyección de dependencias debería haber evitado.
- Los verificadores mecánicos también se prueban: un verificador que nunca falla no verifica nada, así
  que cada uno lleva un caso negativo con una violación deliberada.

---

En Rust, los tests de caja negra viven en `tests/` espejo de `src/`; los internos en archivos hermanos
`<módulo>_tests.rs`, declarados con `#[cfg(test)]`, nunca en línea. Los casos del corpus no se duplican
como tests de Rust. Los fixtures de violaciones deliberadas se excluyen del recorrido ordinario y se
verifican como casos negativos.

## 6. Principios, como preguntas verificables

No son mantras: son la checklist antes de dar un archivo por terminado.

- **Una responsabilidad.** ¿Puedo describir qué hace este archivo en una frase sin usar «y»?
- **Abierto/cerrado.** ¿Añadir un caso nuevo me obliga a modificar este archivo, o solo a añadir uno
  al lado? Las variantes de comportamiento se inyectan como datos, nunca se ramifican con un
  condicional sobre «qué configuración es».
- **Contratos consistentes.** Si mañana añado una segunda implementación de esta interfaz, ¿se rompe
  un consumidor existente?
- **Interfaces segregadas.** ¿Esta interfaz obliga a implementar métodos que un consumidor concreto no
  necesita?
- **Dependencias invertidas.** ¿Este módulo depende de una implementación concreta cuando podría
  depender de una interfaz? Si un test necesita montar infraestructura real para ejercitar lógica, la
  respuesta es sí.
- **YAGNI.** ¿Esto lo pide una fase aprobada, o lo estoy añadiendo porque «seguro hace falta después»?
- **DRY con límite.** ¿Estas dos piezas son duplicación real —el mismo concepto dicho dos veces— o
  coincidencia superficial? Antes una duplicación pequeña y honesta que una abstracción prematura que
  une dos conceptos que van a divergir.

---

## 7. Señales de alerta al revisar

No hace falta leer cada línea. Estas señales delatan casi siempre una capa mezclada:

- Un archivo que importa de una capa que su `architecture.yaml` no le permite.
- Un `switch` sobre el mismo tipo de dato repetido en más de dos lugares para la misma preocupación:
  falta una abstracción de recorrido, o se está copipegando en vez de reutilizar.
- Un literal de texto destinado a una persona fuera de la capa que tiene esa responsabilidad.
- Un archivo que al abrirlo no se puede resumir en una frase sin «y».
- Una función con más parámetros posicionales de los que permite el límite del paquete.
- Un comentario que explica *qué* hace la línea siguiente.
- Un cambio de arquitectura sin cambio correspondiente en el `README.md`.

---

## 8. Skills disponibles

En `.agents/skills/`:

| Skill                         | Cuándo usarla                                                                  |
|-------------------------------|--------------------------------------------------------------------------------|
| `commit-message`              | Formato de los mensajes de commit del repositorio y sus paquetes               |
| `update-pseudolearn-vscode`   | Instalar y verificar la extensión local en el perfil personal de VS Code       |

---

## 9. Entorno

- El núcleo del lenguaje es Rust. El sujeto `reference` está retirado; su manifiesto y resultados
  históricos se conservan en el sistema de especificaciones, sin ejecutor instalado. El corpus es el
  oráculo normativo y cada cambio observable sigue especificación → casos → tests → código.
- Cada fase resuelve sus observaciones pertinentes, informa implementación, pruebas, verificadores y
  pendientes justificados, y publica su rama con push ordinario comprobado. Sin coautoría ni atribución
  de autoría de IA en commits. `PHASE-GREEN` exige verificaciones locales en verde; también la comprobación remota
  cuando la fase
  la pide y la persona la autoriza. `PHASE-STOP` exige autorización nueva. GitHub Actions se reserva
  para despliegues productivos y comprobaciones puntuales manuales; no verifica cada push o PR.


- El monorepo sostiene cinco cadenas de herramientas, y cada miembro usa solo la suya: `dart` y `flutter`
  para los recolectores de métricas y la app, `python3` con `fonttools` para el motor de marca, `deno` con la CLI de
  `supabase` para el backend (`apps/pseudolearn_backend`), y `node` con `pnpm` para el frontend web
  (`apps/fe-pseudolearn`) y para la extensión (`apps/pseudolearn_vscode`, Node 22.23.3 y pnpm 12.8.1).
  La quinta es `cargo` y `rustup` para los verificadores Rust, `pseudolearn_spec`,
  `pseudolearn_engine`, `pseudolearn_cli` y los puentes. Cada miembro Rust fija la misma versión exacta en
  `rust-toolchain.toml`; no hay workspace Cargo raíz. Todas están en el `PATH`; los comandos se documentan sin rutas
  absolutas.
- `packages/` aloja lo reutilizable que no se despliega, en el lenguaje que a cada miembro le
  corresponda; `apps/` aloja lo que se despliega. El criterio es el papel del miembro, no su lenguaje (`README.md` de la
  raíz §3.1 y §4.5).
- El repositorio es un monorepo git. Los paquetes de librería no versionan su `pubspec.lock`; las
  aplicaciones sí. La salida de un generador no se versiona salvo que un build ajeno la consuma.
- Los comandos concretos de cada paquete están en su `README.md`, sección «Cómo se verifica».

## 10. Congelamiento de versiones de especificación

Las versiones y los estados del corpus quedan congelados mientras no haya autorización explícita para iniciar la publicación de una versión del lenguaje. Las ediciones futuras se redactan como texto oficial en la especificación existente y conservan su identidad, estado y versión; no añaden campos `cambio`. Cuando corresponda, se actualiza el anclaje normativo para esa misma versión. El versionado y la clasificación estrictos solo se reactivan con autorización explícita de la persona.
