# Web 2.0.0 — mapa de cambios y propuesta de rediseño

Documento transitorio de planificación (`DOC-NO-TRANSIENT-REFS`): ningún README, código ni especificación lo cita.
Cada decisión aprobada se traslada al `README.md` de `apps/pseudolearn_web` en el mismo cambio que la implementa.

Fecha: 2026-11-09. Rama: `feature/agregar-ruta-de-especificacion`. Alcance: solo análisis y propuesta; no hay código.

---

## 1. Qué cuenta hoy la web y qué es verdad hoy

| Tema | Lo que dice la web | Lo que es verdad en el monorepo | Dónde está la verdad |
|:--|:--|:--|:--|
| Qué es PseudoLearn | «Editor de pseudocódigo» para aprender | Un lenguaje completo (tipos, módulos, objetos, funciones de orden superior, tareas y canales, biblioteca de archivos/JSON/HTTP) con motor Rust, CLI `pseudo`, LSP, DAP, MCP y extensión de VS Code; la app es uno de sus entornos | `packages/pseudolearn_spec`, `apps/pseudolearn_cli`, `apps/pseudolearn_vscode` |
| Ruta de aprendizaje | 15 módulos `CON-A1…C5` en 3 tramos (A/B/C), 95 ejercicios | 7 partes por paradigma (0 Empezar de cero · I Imperativo · II Procedimental · III Objetos · IV Funcional · V Concurrente · VI Mundo exterior), **41 lecciones**, **224 ejercicios** (125 obligatorios), 11 tipos de ejercicio, 3 niveles (Semilla, Brote, Árbol), ~25 h, un hilo narrativo (el kiosco) con proyectos por parte | `apps/pseudolearn_app/assets/route/*/toc.json` |
| Cómo se aprende | «explica una idea, la muestra, ejercicios» | Cada lección parte de un problema concreto («¿Cuántas pizzas pedir?») y recorre Entender → Planear → Escribir → Probar → Mejorar, con ficha del problema (entra/sale/relación), «Bajo el capó», «Recuerda» y enlaces a la especificación | l10n `route*` de la app |
| Progreso | «Sin notas, sin porcentajes de logro» | Panel «Mi progreso» con anillos, porcentaje de ruta, radar de habilidades, cobertura de la especificación, actividad semanal y siguiente paso | `presentation/dashboard` |
| Ejecución | Paso a paso en 4 superficies | Se mantiene, y se suman la pestaña **Tareas** (línea temporal, tarjetas de estado y narración por evento de cada tarea concurrente), **argumentos de ejecución** y diagrama de clases | `presentation/execution`, `executionArguments*` |
| Especificación | «11 documentos de especificación» en el contacto y las métricas | 105 secciones en 13 partes + 6 apéndices; ya publicada en `/spec` | `entities/specification/generated` |
| Monetización | «No hay edición de pago» (Versiones) | **Nodo · IA**: prueba de 7 días (40 créditos), plan mensual de 300 créditos, recargas de 150; checkout con Paddle (que la web ya aloja en `/checkout`) | `presentation/agent`, `domain/model/credits` |
| Plataformas | macOS, iOS, Windows; Linux/Android «en preparación» | Más VS Code (escritorio y web) y la CLI `pseudo` | READMEs de VS Code y CLI |
| Capturas | `editor-desktop/mobile-{light,dark}` | Muestran el selector «Flexible» (modo eliminado), `Definir Mutable` (ya no está en el demo), la barra lateral antigua y nada de Tareas, Progreso ni Nodo | `src/assets/product`, `tool/generate_product_shot.dart` |
| Versión | 1.1.1 · núcleo 0.1.0 | Sale 2.0.0 | `CHANGELOG.json` |
| Legal | Privacidad y términos sin mención de IA ni suscripción | Nodo envía mensajes, código, contexto de pantalla y progreso resumido a OpenAI vía el servidor; edad mínima 13; renovación automática | `agentConsentBody`, `agentOfferLegal` |

### 1.1 Textos concretos que hoy son falsos o engañosos

- `home.track.*`, `home.metrics.*`, `entities/learning-module/model/curriculum.ts` y `metrics.ts`: cifras 15/95/86/11 escritas a mano.
- `home.track.footer`: «sin porcentajes de logro».
- `versions.current.lead`: «no hay edición de pago».
- `home.features.projection`: «Del pseudocódigo a Python y a Rust» — confirmar destinos actuales del código equivalente.
- `contact.branch.question.*` y `module.CON-*`: el selector de dudas ofrece 15 módulos que ya no existen y 11 documentos.
- `appArea.*`: faltan Tareas, Progreso, Ruta, Nodo, VS Code, CLI; sobra «Base de conocimiento» como nombre.
- `contact.branch.error.versionPlaceholder`: `v1.0.0`.
- `home.hero.requirements`, `versions.current.requirements`: no nombran VS Code.
- `home.closing`: «Empieza por el Tramo A. Son dos módulos.»

---

## 2. Diagnóstico

1. **El sitio vende una app, no un lenguaje.** El héroe, el SEO y el pie hablan de «editor de pseudocódigo». La 2.0.0
   necesita contar dos cosas a la vez: *un lenguaje de verdad* y *el mejor lugar para aprenderlo*.
2. **Menú con enlaces disfrazados.** De los cinco enlaces del encabezado, tres son anclas de la portada
   (`El editor`, `Ruta de aprendizaje`, `Descargas`) y el botón «Descargar» es la misma ancla otra vez. Visualmente
   son idénticos a «Contacto» y «Versiones», que sí cambian de página. La especificación —la página más grande del
   sitio— no está en el encabezado.
3. **Se cuenta en vez de mostrar.** «Errores que explican», «ruta con orden», «los objetos dejan de ser magia» son
   frases; la app nueva es narrativa y gráfica, y la web no enseña ni una lección, ni un ejercicio, ni el panel de
   progreso, ni Tareas, ni a Nodo.
4. **La guía de SmartScreen pesa más que el producto.** Es el único bloque de la sección de descargas con fondo,
   borde de marca e icono, cuatro pasos numerados y nota; con Microsoft Store disponible es un caso secundario.
5. **Cifras a mano.** Todo número del currículo está escrito en TypeScript o en i18n; por eso quedó desfasado. Viola el
   espíritu de `GEN-NO-HAND-COPY` aunque hoy no lo detecte ningún verificador.
6. **Legal desalineado con la oferta de pago.** Promocionar Nodo sin actualizar privacidad y términos no es opcional.

---

## 3. Propuesta

### 3.1 Principios del rediseño

- **Misma identidad**: tokens `pl-`, el campo de color de marca, IBM Plex Sans/Mono, el símbolo de la escalera y su
  ruta. Lo fresco viene de composición, no de otra paleta: más aire, tarjetas con radios ya existentes, ilustración
  SVG del símbolo como hilo conductor y piezas de producto reales en lugar de párrafos.
- **Hechos, no adjetivos**: cada promesa de la portada se demuestra con un artefacto real generado (una lección, un
  ejercicio con su retroalimentación, una línea temporal de tareas, una conversación de Nodo con su bloque
  «Verificado»). Si no se puede mostrar, no se dice.
- **Todo número sale de un generador**: lecciones, ejercicios, tipos, secciones de la especificación y versión.
- **Presupuesto intacto**: 10 KiB de JS por ruta. Las demostraciones son SVG + CSS + `<details>`/`:target`; el
  único JS nuevo admisible es un avance paso a paso mínimo, y solo si cabe.

### 3.2 Mapa del sitio y navegación

Encabezado solo con **páginas** (ninguna ancla), agrupadas por intención:

```text
[símbolo] PseudoLearn   Lenguaje   Aprender   Nodo·IA   Especificación        [tema][idioma] [Descargar →]
```

| Ruta (`es` / `en`) | Página | Contenido |
|:--|:--|:--|
| `/` | Portada | Héroe dual (lenguaje + aprendizaje), prueba visible de cada pilar y enlaces a cada página |
| `/lenguaje` · `/en/language` | **Nueva** | Qué es el lenguaje: paradigmas con un programa real por parte, perfiles español/inglés, entornos (app, VS Code escritorio y web, CLI con LSP/DAP/MCP), determinismo y diagnósticos |
| `/aprender` · `/en/learn` | **Nueva** | La ruta: 7 partes, el kiosco como hilo, las 5 fases, los 11 tipos de ejercicio, niveles, panel de progreso |
| `/nodo` · `/en/nodo` | **Nueva** | El agente: qué hace, qué no hace (no da la respuesta), paridad con la interfaz, confirmaciones, planes, privacidad |
| `/descargar` · `/en/download` | **Nueva** | Tiendas, `.exe`, VSIX, CLI; requisitos; guía de SmartScreen plegada |
| `/spec` | Existente | Se enlaza desde el encabezado |
| `/versions`, `/contact`, legales, `/checkout` | Existentes | Versiones y Contacto pasan al pie |

Reglas para distinguir enlaces:

- El encabezado **nunca** lleva anclas. Las anclas viven dentro de cada página en un índice local («En esta página»)
  pegajoso bajo el héroe, con estilo de pestañas/chips, distinto del menú global.
- `aria-current="page"` con subrayado de marca para la página actual; el botón «Descargar» es una página.
- En el pie, columnas `Producto` (Lenguaje, Aprender, Nodo, Descargar), `Referencia` (Especificación, Versiones,
  `llms.txt`), `Soporte` (Contacto, Privacidad, Términos). Se eliminan «Reportar» y «Preguntas frecuentes», que hoy
  apuntan los tres a `/contacto`.
- En móvil, el menú usa los mismos cuatro destinos + Descargar como botón.

Efecto en arquitectura: cuatro rutas nuevas por idioma (paridad de `check:routes`), cuatro vistas en `src/views`,
`navigation.ts` deja de construir anclas; `ANCHORS` se reduce a anclas internas de cada vista.

### 3.3 Portada

| Orden | Bloque | Hecho visible |
|:--|:--|:--|
| 1 | Héroe | «Aprende a pensar como programador. Con un lenguaje de verdad.» Captura nueva con editor + Tareas o lección; CTA «Descargar» y «Ver una lección» |
| 2 | Barra de entornos | Logos de texto: macOS · Windows · iPhone/iPad · VS Code · Terminal (reemplaza «Disponibilidad») |
| 3 | Una lección, de verdad | Tarjeta de la lección 0.1 «Tu primer problema — ¿Cuántas pizzas pedir?» con las 5 fases como pasos clicables (`:target`/`details`) y su ficha Entra/Sale/Relación |
| 4 | Un ejercicio que te responde | Ejercicio «Romperlo» o «Encontrar el error» con la retroalimentación real del motor («Con esa entrada los dos programas responden lo mismo…») |
| 5 | Ver lo que hace tu programa | Las 4 superficies actuales, condensadas, + la nueva pestaña Tareas (línea temporal SVG) y argumentos |
| 6 | Un lenguaje completo | Siete mini-programas por paradigma en pestañas CSS, coloreados con el mismo tono que `/spec` |
| 7 | Nodo · IA | Conversación estática: pregunta del estudiante → pasos («Leer la pantalla», «Comprobar el programa») → bloque «Verificado» → pista sin solución. CTA a `/nodo` |
| 8 | Tu progreso, a la vista | Captura del panel (anillos, radar, siguiente paso) |
| 9 | Cierre | «Empieza por la Parte 0: cuatro lecciones, ~1 h» (cifras generadas) + descargar |

Se eliminan de la portada: la sección completa de descargas (pasa a `/descargar`; queda un bloque corto con botón
por plataforma detectada) y la cuadrícula «Seis cosas que un papel no puede hacer», cuyas ideas se convierten en los
bloques 3–8.

### 3.4 `/aprender`

- Mapa de la ruta como **la escalera del símbolo estirada**: 7 peldaños-parte, cada uno con su lema
  («Darle órdenes a una máquina con memoria», «Divide y vencerás»…) y sus lecciones con su problema breve.
- El kiosco como protagonista: los cinco proyectos (P·I…P·F) muestran cómo el mismo problema crece por paradigma.
- Las 5 fases (Entender, Planear, Escribir, Probar, Mejorar) como diagrama, explicando por qué no se empieza por el
  código: aquí aparece «pensar como programador» como método, no como lema.
- Los 11 tipos de ejercicio con un ejemplo real cada uno y su recuento; niveles Semilla/Brote/Árbol.
- Progreso: qué mide el panel y la regla de completado («una lección se completa cuando resuelves sus obligatorios»).
- Se reescribe `home.track.footer`: el panel sí muestra porcentajes; la promesa honesta es que **no hay notas ni
  castigos por intentos**, si eso sigue siendo cierto (confirmar).

### 3.5 `/lenguaje`

- «Un programa, cuatro lugares»: el mismo `.pseudo` abierto en la app, en VS Code, en la terminal (`pseudo run`) y
  en VS Code para la Web.
- Paradigmas con un programa por parte del corpus y enlace a su sección de `/spec`.
- Perfiles español/inglés lado a lado (ya está en la especificación 0.5).
- Herramientas del ecosistema: LSP, depurador, formateador, traducción de vocabulario, compilación a nativo, MCP para
  asistentes (enlace a `llms.txt`).
- Edición del lenguaje (2026) frente a versión de la app (2.0.0), explicado en una línea para que no se confundan.

### 3.6 `/nodo`

- Qué es: «Nodo · IA», el glifo con sus estados, abierto desde cualquier pantalla.
- Qué hace, mostrado con tres escenas: explica un diagnóstico, comprueba código con el motor («Verificado» / «Con
  errores»), guía un ejercicio con pistas sin dar la respuesta, crea ejercicios propios. Cada acción de escritura pide
  permiso («Nodo quiere editar un algoritmo · Permitir / No permitir»).
- Qué no hace: no tiene capacidades que la interfaz no tenga; no ve nada sin consentimiento; es una IA y puede
  equivocarse.
- Planes: prueba 7 días / 40 créditos, mensual 300 créditos, recarga 150; precio «en tu moneda al pagar» (Paddle y
  tiendas). Sin precio fijo escrito a mano hasta que exista una fuente generada.
- Privacidad resumida (OpenAI vía servidor, qué se envía, retirar consentimiento, 13+) con enlace a la política.

### 3.7 `/descargar`

- Tarjetas por entorno con el mismo peso: macOS, iPhone/iPad, Windows (Microsoft Store), VS Code, CLI.
- El instalador `.exe` es una acción secundaria dentro de la tarjeta de Windows. La guía de SmartScreen pasa a un
  `<details>` cerrado («¿Windows muestra un aviso azul?») con tres pasos y sin estilo de alerta de marca.
- Requisitos y versión generados desde `CHANGELOG.json` y la plataforma.

### 3.8 Contacto y Versiones

- Selector de dudas generado desde la ruta (partes → lecciones) y la especificación (partes), no desde `CON-*`.
- Áreas de la app: Editor, Diagramas, Tareas, Prueba de escritorio, Código equivalente, Ruta, Progreso, Nodo,
  Especificación, Ajustes; plataformas: añadir VS Code y CLI.
- Versiones: retirar «no hay edición de pago» y explicar que la app es gratuita y Nodo es opcional de pago.

### 3.9 Imágenes

Regenerar con `tool/generate_product_shot.dart` (y `tool/product/`), sin editar PNG a mano:

| Escena | Variantes |
|:--|:--|
| Editor + Diagramas (héroe actual, sin «Flexible») | escritorio/móvil × claro/oscuro × es/en |
| Tareas (línea temporal de un programa con canales) | escritorio × claro/oscuro × es/en |
| Lección de la ruta (fase Planear con ficha del problema) | escritorio y móvil |
| Panel Mi progreso | escritorio |
| Nodo abierto con bloque Verificado y barra de confirmación | escritorio y móvil |
| VS Code con diagnósticos y ejecución | captura manual (Flutter no la genera); se versiona como activo fuente, no como salida de un generador |

Formato: AVIF/WebP vía `astro:assets` (ya hay `sharp`), `srcset` y `ProductPreviewPreload` solo para la imagen del
héroe.

### 3.10 Datos generados que hacen falta

| Artefacto | Productor propuesto | Consumidor |
|:--|:--|:--|
| Índice de la ruta (partes, lecciones, problema, minutos, ejercicios por tipo/nivel) | Exportador nuevo desde `apps/pseudolearn_app/assets/route` o desde su fuente original | `entities/learning-route/generated/` |
| Lección y ejercicio de muestra (contenido completo de 0.1 y uno de «Romperlo») | Mismo exportador | Bloques 3 y 4 de la portada |
| Programas por paradigma | Corpus de `pseudolearn_spec` (ya exporta secciones) | `/lenguaje` |
| Métricas (lecciones, ejercicios, secciones, tipos) | Derivadas en `entities/*/model` de lo anterior | Toda la web |

`curriculum.ts` y `metrics.ts` desaparecen; un verificador nuevo (o `check:brand` extendido) comprueba que los
artefactos generados estén frescos, como ya pasa con la especificación.

---

## 4. Conflictos que necesitan decisión (`CONFLICT-REPORT`)

1. **VS Code.** El usuario quiere promocionar la extensión como disponible en 2.0.0; `apps/pseudolearn_vscode` dice
   «versión previa a producción para uso privado», solo `darwin-arm64`, sin Marketplace ni Open VSX, y Firefox,
   WebKit y Windows sin verificar. ¿Se publica en Marketplace/Open VSX, se ofrece el VSIX desde la web (¿qué
   plataformas?), o se anuncia como «próximamente»?
2. **CLI `pseudo`.** ¿Se distribuye a usuarios en 2.0.0 (binarios, Homebrew, winget) o solo va empaquetada dentro del
   VSIX?
3. **Compras de Nodo.** La app muestra «Compras simuladas: no se cobra dinero» y las compras reales siguen
   pendientes de sandbox. ¿La 2.0.0 sale con cobro real? Si no, la web debe decir «próximamente» o no mostrar planes.
4. **Precio.** ¿Hay precio de referencia publicable (USD) o la web solo dice «precio en tu moneda al pagar»?
5. **Legal.** Privacidad y términos deben incorporar Nodo (OpenAI como encargado, datos enviados, retención, 13+,
   suscripción, renovación, reembolsos por tienda). Lo redacta la persona o se propone borrador.
6. **Nombre del producto de pago.** Los identificadores dicen `pseudolearn.plus.*`; la interfaz dice «Nodo · IA».
   ¿Existe una marca «PseudoLearn Plus» o se vende solo como Nodo?
7. **Ruta «sin notas».** ¿Se mantiene la promesa de no calificar ni guardar historial de intentos? El panel nuevo
   cuenta ejercicios resueltos y semanas activas.
8. **Código equivalente.** ¿Siguen siendo Python y Rust los destinos? La pestaña existe pero hay un texto
   «Disponible cuando el motor de exportación esté listo».
9. **Núcleo en el changelog.** `CHANGELOG.json` lleva `core: 0.1.0`; ¿qué versión de núcleo acompaña a la app 2.0.0?

---

## 5. Borrador del changelog 2.0.0

Entrada propuesta para `CHANGELOG.json` (se edita a mano porque es fuente, no salida de generador; texto a
confirmar):

- **Titular**: «PseudoLearn 2.0: un lenguaje de programación completo, para aprender a pensar como programador».
- **Resumen**: PseudoLearn deja de ser un ejecutor de algoritmos sueltos: es un lenguaje con módulos, objetos,
  funciones, concurrencia y biblioteca, que corre en la app, en VS Code y en la terminal. La ruta se reescribe
  alrededor de problemas, y llega Nodo, un asistente de IA opcional.
- **Cambios** (`kind`):
  - `feature` — Lenguaje completo: tipos compuestos, módulos, objetos e interfaces, funciones de orden superior,
    resultado/opcional, tareas y canales, archivos, JSON y HTTP.
  - `feature` — Nueva ruta: 7 partes, 41 lecciones y 224 ejercicios de 11 tipos, con el método Entender → Planear →
    Escribir → Probar → Mejorar.
  - `feature` — Pestaña Tareas: línea temporal y estado de cada tarea concurrente.
  - `feature` — Argumentos de ejecución.
  - `feature` — Mi progreso rediseñado.
  - `feature` — Especificación ilustrada dentro de la app y en `pseudolearn.app/spec`.
  - `feature` — Nodo · IA (suscripción opcional, prueba de 7 días).
  - `feature` — Ejercicios propios.
  - `platform` — Extensión de VS Code (según decisión 4.1) y CLI (según 4.2).
  - `fix` — Eliminación del modo flexible (si se considera cambio visible para usuarios de 1.x).
  - Nota de migración: programas 1.x que usaban sintaxis retirada (`Mutable`, modo flexible) y cómo los trata la app.

---

## 6. Fases propuestas

Cada fase cierra con `pnpm check:all`, `test:e2e`, `test:a11y`, `test:visual` en verde, README actualizado, commit y
parada (`PHASE-GREEN`, `PHASE-STOP`).

| Fase | Contenido |
|:--|:--|
| W0 | Decisiones de §4 y copia final de titulares |
| W1 | Generadores de datos (ruta, muestras, métricas) y retirada de cifras a mano; contacto y versiones corregidos |
| W2 | Navegación nueva (encabezado de páginas, índice local, pie), rutas vacías `/lenguaje`, `/aprender`, `/nodo`, `/descargar` |
| W3 | Portada nueva con bloques 1–9 y presupuesto de JS verificado |
| W4 | `/aprender` y `/lenguaje` |
| W5 | `/nodo`, legales actualizados, enlace con `/checkout` |
| W6 | `/descargar` con SmartScreen plegado; capturas regeneradas |
| W7 | Changelog 2.0.0, `llms.txt`, SEO/datos estructurados (`SoftwareApplication` + `offers`), sitemap |

---

## 7. Decisiones tomadas (2026-11-09)

1. VS Code: «Próximamente», sin descarga.
2. CLI: «Próximamente»; hoy solo se compila desde el código.
3. Nodo sale con cobro real.
4. Precio: «en tu moneda» en cada tienda; la web no muestra importes.
5. Legales: redactados en este cambio (privacidad §04 y términos §08).
6. Producto: se vende solo Nodo; identificadores `pseudolearn.nodo.*` en app, backend y tiendas.
7. Se mantiene la promesa «sin notas ni castigos por intentos».
8. Código equivalente: Python y Rust siguen; el aviso «Disponible cuando el motor de exportación esté listo» se sustituyó
   por un aviso neutro cuando la exportación no devuelve código ni motivo.
9. Núcleo de 2.0.0 en el changelog: `1.0.0`, primera edición completa del lenguaje, incompatible con el núcleo `0.1.0`
   de la 1.x.
