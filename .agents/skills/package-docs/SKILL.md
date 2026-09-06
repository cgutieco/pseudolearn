---
name: package-docs
description: Estándar y metodología para redactar y mantener el README.md de un paquete, aplicación o raíz del monorepo, como única fuente de verdad técnica autosustentable. Cubre la estructura obligatoria de ocho secciones, la guía operativa (build, test, deploy, entornos), arquitectura, decisiones de diseño integradas (sin archivos externos), reglas de legibilidad y código, y verificación.
---

# Documentación de Paquete, Aplicación y Raíz

## Por qué existe esta skill

El código de este proyecto lleva casi ningún comentario. Eso solo funciona si el *por qué* está escrito en otro sitio, y
ese sitio es el `README.md` del paquete o aplicación. Un componente sin README no es un componente con documentación
pendiente: es un componente cuyo código ya perdió la mitad de su información (`DOC-README-TRUTH`).

PseudoLearn es un proyecto de código cerrado con rigor de ingeniería. No requiere insignias (badges), logotipos
decorativos ni prosa de marketing. Requiere documentación técnica operativa, exacta, directa y autosustentable.

**Reglas fundamentales que rigen este estándar:**

1. **`DOC-README-TRUTH`:** Quien cambia una decisión de arquitectura o diseño actualiza el README **en el mismo cambio
   **, no al terminar la fase ni en un commit posterior.
2. **`DOC-NO-ORPHAN-DECISION`:** Ninguna decisión de diseño vive solo en el código o en un mensaje de commit.
3. **Autosustentabilidad total (Cero referencias externas):** Todo README debe ser completamente autosustentable. **No
   se admiten carpetas de decisiones externas (como `docs/decisions/`) ni enlaces a archivos huérfanos.** Todas las
   decisiones de arquitectura, fundamentos visuales, catálogo de componentes, especificación de pantallas y algoritmos
   viven directamente en el propio `README.md`.
4. **Presente normativo atemporal (Sin arqueología de versiones):** El README es la ley actual del sistema, no su diario
   de desarrollo ni su crónica histórica. Prohibido escribir frases de evolución como «debido a tal situación se tuvo
   que tomar esta decisión», «anteriormente se hacía X pero en el bloque Y se cambió a Z», o «dejó de estar fuera de
   alcance tras la fase N». Si una decisión se adoptó o reemplazó, se redacta en presente afirmativo como si el sistema
   hubiera sido ideado así desde el origen. El control de versiones (`git`) guarda la historia; el README contiene
   únicamente la verdad vigente.
5. **Máxima densidad técnica y lectura mecánica por IA (Cero relleno, máxima precisión):** La documentación debe poder
   ser leída y procesada a máxima velocidad por un agente de IA o un ingeniero. Prohibidas las decoraciones
   gramaticales, metáforas, preámbulos literarios y párrafos de relleno. Cada línea aporta una restricción, un contrato,
   un tipo o un invariante. **La concisión se logra eliminando el ruido retórico y la narrativa, NUNCA omitiendo
   detalles técnicos, invariantes o casos límite.**
6. **Un estándar para tres niveles:** La estructura de 8 secciones es idéntica para la raíz del monorepo (`/README.md`),
   los paquetes de librería pura (`packages/pseudolearn_core/README.md`) y las aplicaciones clientes (
   `apps/pseudolearn_app/README.md`).

---

## Estructura obligatoria de 8 secciones

Todo `README.md` tiene exactamente estas ocho secciones, en este orden:

### 1. Qué es y qué no es

- **Propósito y problema que resuelve:** Qué resuelve la pieza, a quién sirve y quién la consume dentro del monorepo.
- **Responsabilidades primarias:** Qué le pertenece de forma exclusiva.
- **Fuera de alcance a propósito (`SCOPE-YAGNI`):** Delimitación actual y tajante, sin narrar si estuvo o no antes.
  Dividido estrictamente entre:
    - *De producto:* Capacidades que deliberadamente no existen en el diseño actual y por qué.
    - *De implementación técnica:* Tecnologías, librerías o patrones no permitidos en el diseño (p. ej. sin isolates,
      sin tematización arbitraria, sin backends externos en fase local).
- **Casos de uso principales:** Flujos clave exactos soportados actualmente.
- **Pendientes técnicos declarados:** Tabla con lo que la arquitectura requiere pero aún no está implementado, con su
  dependencia técnica y estado.

### 2. Guía operativa y ciclo de vida

Comandos directos y exactos, reproducibles sin dependencias ocultas:

- **Requisitos previos y plataformas:** SDKs (versiones mínimas exactas), sistemas operativos soportados (macOS, iOS,
  Web/WASM) y variables/flags requeridos.
- **Preparación e instalación:** Comandos exactos de dependencias (`pub get`) y generadores (`build_runner`).
- **Ejecución en desarrollo:** Comandos exactos para levantar localmente (ej. `flutter run -d macos`).
- **Compilación y build de producción:** Comandos exactos de release (ej. `flutter build macos --release`) y rutas de
  salida de artefactos.
- **Pruebas y verificación inmediata:** Comandos de tests unitarios, integración y verificación mecánica.
- **Despliegue y distribución:** Canales de entrega (TestFlight, empaquetado DMG directo, CDN) y checklist de release.

### 3. Arquitectura y modelo del sistema

- **Paradigma arquitectónico:** El patrón base (Arquitectura Hexagonal en app, Pipeline por etapas en el núcleo,
  Monorepo estructurado en la raíz).
- **Diagrama de capas y dirección de dependencias (`LAYER-DIRECTION`):** Flujo unidireccional estricto donde las capas
  internas nunca conocen a las externas.
- **Catálogo de carpetas e invariantes:** Tabla exhaustiva de cada carpeta (`path` bajo `lib` o raíz):
    - Responsabilidad única.
    - Qué puede importar (`may_import`).
    - **Qué tiene terminantemente prohibido importar o contener** (`forbidden_imports`).
- **Flujo de datos y ciclo de vida:** Ciclo exacto de cómo viaja un dato/evento a través de las capas.
- **Concurrencia, asincronía y modelo de threading:** Política de hilos, determinismo y restricciones sobre `Isolate` o
  ejecución síncrona.

### 4. Decisiones de diseño y fundamentos técnicos (Autosustentables)

Cada decisión técnica vive en este documento, redactada en presente normativo (la ley vigente) bajo la **terna
obligatoria**:

1. **Problema:** La tensión, limitación técnica o requerimiento estructural que motiva la regla.
2. **Elección:** La solución implementada y su mecánica exacta.
3. **Alternativas descartadas y por qué:** Qué otras alternativas técnicas se rechazaron y el motivo técnico de su
   descarte.

*Integración sin archivos externos:*

- En la aplicación, esta sección absorbe con máximo detalle técnico los fundamentos visuales (tokens, escalas de color,
  tipografía, espacios, lienzo), pantallas, catálogo de componentes, algoritmos de layout de diagramas (ordinograma,
  estructograma, clases) y la base de conocimiento con sus ejercicios.
- Prohibido delegar a carpetas como `docs/decisions/`. Todo vive aquí de forma autosustentable.

### 5. Reglas de legibilidad, estilo y estructura de código

- **Filosofía de código auto-explicativo:** Una sola responsabilidad por archivo (describible en una frase sin
  conjunciones copulativas "y"). Nombres descriptivos sin comentarios redundantes.
- **Límites métricos obligatorios:** Los valores enforceados mecánicamente por `architecture.yaml` (líneas por archivo,
  líneas por función, líneas por método `build`, parámetros posicionales, niveles de anidación, métodos públicos por
  clase).
- **Política estricta de comentarios:**
    - *Prohibido (`QUALITY-NO-NOISE-COMMENTS`, `QUALITY-NO-DOC-REFS`):* Comentarios que repiten lo que el código hace,
      traducciones de identificadores al español, referencias a documentos (`// ver README`), código comentado, TODOs
      sin responsable.
    - *Admisible (`QUALITY-WHY-ONLY`):* Únicamente un *por qué* local, no evidente y contraintuitivo.
- **Convenciones técnicas y anti-patrones prohibidos:** Reglas de widgets (prohibición de widgets adaptativos como
  `Switch.adaptive`, prohibido `await` en capa de presentación, prohibido filtrar o derivar colecciones dentro del árbol
  de widgets).
- **Gestión tipada de errores:** Ninguna excepción no controlada cruza fronteras públicas; uso de tipos explícitos de
  retorno para fallos.

### 6. Decisiones de producto que condicionan el código

Reglas pedagógicas, contractuales o de producto que justifican implementaciones técnicas que de otro modo parecerían
atípicas o subóptimas. Se enuncian como leyes vigentes del producto para blindarlas ante refactorizaciones
involuntarias.

### 7. Verificación, testing y aseguramiento de calidad

- **Comandos de verificación inmediata:** Ejecución directa de verificadores sin dependencias de máquina.
- **Matriz de verificadores mecánicos:** Tabla que detalla qué herramienta (Lints, tests de capas, scripts en `tool/`,
  `check_limits.dart`, `check_content.dart`) valida qué regla y qué archivo.
- **Estrategia y pirámide de pruebas:**
    - Estructura espejo (`TEST-MIRROR`): `test/` replica exactamente `lib/`.
    - Doble camino (`TEST-BOTH-PATHS`): camino feliz, camino infeliz y casos límite explícitos (entradas vacías, bordes
      numéricos, nulos).
    - Pruebas negativas de verificadores: validar que el verificador detecta la violación deliberada.
- **Señales de alerta al revisar (Code Review Checklist):** Olores de código concretos que ameritan rechazo inmediato de
  un cambio.

### 8. Fuentes consultadas y genealogía conceptual

Registro riguroso de fuentes externas analizadas (PSeInt, estándares Cambridge, OCR, algoritmos de grafos, etc.):

- **Qué se tomó:** Conceptos o especificaciones adaptadas.
- **Qué se rechazó deliberadamente y por qué:** Justificación técnica del rechazo, acreditando la autoría propia y las
  diferencias deliberadas.

---

## Adaptación por Nivel en el Monorepo

| Sección                       | Raíz del Monorepo (`/README.md`)                                                   | Paquete Motor (`pseudolearn_core`)                                                     | Aplicación Cliente (`pseudolearn_app`)                                                            |
|:------------------------------|:-----------------------------------------------------------------------------------|:---------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------|
| **1. Qué es y qué no es**     | Ecosistema global de PseudoLearn, alcance del monorepo                             | Motor de lenguaje puro, agnóstico de UI/IO, compilable a nativo/JS/WASM                | Cliente interactivo Flutter (macOS, iOS), editor y visualizaciones                                |
| **2. Guía operativa**         | Bootstrap del monorepo, tooling global, comandos transversales                     | `dart test`, `dart analyze`, `dart compile js/wasm`, scripts de tool/                  | `flutter run`, `flutter build macos/ipa`, empaquetado, perfiles                                   |
| **3. Arquitectura**           | Mapa de paquetes (`packages/` vs `apps/`), dependencias inter-proyectos            | Pipeline concéntrico (`domain` → `syntax` → `semantic` → `evaluation` → `diagnostics`) | Arquitectura Hexagonal (`domain`, `engine`, `data`, `application`, `presentation`, `composition`) |
| **4. Decisiones de diseño**   | Monorepo git puro, symlinks de tooling (`.agents/skills`), gestión de dependencias | AST sellado, gramática determinista, diagnósticos independientes de l10n               | BLoC/Cubit, lienzo fluido, tokens visuales, layout de diagramas (RFC 001-008 integrados)          |
| **5. Reglas de código**       | Convenciones transversales, idioma (código EN, docs ES)                            | Límites de core (`file_lines: 300`, `params: 4`, imports relativos)                    | Límites de app (`file_lines: 250`, reglas de widgets, prohibición `await` en UI)                  |
| **6. Decisiones de producto** | Filosofía educativa de PseudoLearn                                                 | Determinismo de ejecución, lenguaje estructurado sin saltos                            | Presentación no punitiva, sincronización de las 4 superficies por `NodeId`                        |
| **7. Verificación**           | Pipeline de verificación completa de todos los paquetes                            | Matriz de verificadores de arquitectura de lenguaje y límites                          | Verificadores de arquitectura hexagonal, límites de widget, lints de strings                      |
| **8. Fuentes consultadas**    | Herramientas de monorepos analizadas                                               | Gramáticas PSeInt, Cambridge, OCR, literatura de compiladores                          | HIG/Material adaptados a tokens propios, Sugiyama, Nassi-Shneiderman                              |

---

## Reglas de redacción

- **En español (`LANG-ES-DOCS`):** El código va en inglés; la documentación, en español.
- **Sin arqueología ni crónica de evolución:** Prohibido relatar la historia del cambio o narrar versiones pasadas. Toda
  decisión se redacta como la regla actual y definitiva desde su origen. La historia pertenece al log de `git`, no a la
  documentación técnica.
- **Alta densidad técnica y economía de prosa:** Escribir pensando en que un modelo de IA o un ingeniero pueda ingerir y
  verificar las restricciones con rapidez. Cero retórica, cero decoraciones gramaticales, pero con el 100 % de los
  detalles técnicos, firmas, tipos y contratos intactos.
- **Sin capturas ni duplicaciones de código:** El README explica el *por qué*; el código muestra el *cómo*. Un fragmento
  de código solo es admisible si ilustra un contrato o estructura de datos que la prosa no transmite con claridad.
- **Sin números duplicados:** Si un valor lo evalúa un verificador mecánico, vive en `architecture.yaml` y el README lo
  explica conceptualmente. Un número en dos sitios diverge.
- **Sin referencias a numeraciones de otros documentos:** Los documentos se reordenan. Se nombra el concepto o la regla
  por su identificador estable, nunca por su número de sección en otro archivo.
- **Sin futuro condicional:** «Se hará» o «implementaría» no informa. O está decidido y se documenta en presente
  afirmativo, o está pendiente y se lista formalmente en la tabla de *Pendientes declarados*.
- **Prosa afirmativa y concreta:** Si una frase se puede borrar sin perder información técnica o una restricción, se
  borra.

---

## Antes de dar el README por terminado (Checklist de Validación)

1. ¿Están presentes las ocho secciones obligatorias en su orden exacto?
2. ¿El texto está completamente libre de narrativas históricas («se cambió», «debido a tal situación se decidió», «en la
   fase X se reemplazó») y redactado en presente normativo como la ley actual?
3. ¿Cada sección va directo al grano, con máxima densidad técnica y sin adornos gramaticales ni omisión de detalles
   esenciales?
4. ¿Cada decisión de diseño cuenta con su problema, elección y alternativas descartadas y por qué?
5. ¿El documento es 100 % autosustentable y carece de enlaces a carpetas externas de decisiones (`docs/decisions/`)?
6. ¿Los comandos de la guía operativa (build, test, run, deploy) son exactos y reproducibles sin depender de rutas
   absolutas?
7. ¿La tabla de carpetas e invariantes especifica claramente qué tiene prohibido importar y contener cada directorio?
8. ¿Los límites métricos coinciden con los declarados en `architecture.yaml`?
9. ¿Un nuevo desarrollador o un agente de IA sabría exactamente dónde colocar un nuevo archivo sin romper la
   arquitectura?
10. ¿Queda alguna decisión de diseño que solo exista en el código o en un commit? Si es así, incorpórala antes de
    cerrar.

---

## Recurso: Plantilla Estándar

Para iniciar o refactorizar cualquier `README.md`, utiliza como base el archivo:
`resources/readme-standard-template.md` ubicado en esta misma skill.
