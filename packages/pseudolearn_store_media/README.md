# pseudolearn_store_media

Motor que produce de forma determinista los assets de las tiendas donde se publica PseudoLearn: capturas, vídeos de
encabezado y de búsqueda e imagen universal de App Store, capturas, arte y tráiler de Microsoft Store, y capturas de
teléfono, gráfico destacado e icono de Google Play. Compone en HTML
con HyperFrames, sintetiza la banda sonora, codifica con FFmpeg y audita cada pieza contra el catálogo de su ranura.

**No hace:** generar imagen, vídeo ni audio con IA, inventar interfaz (la UI real llega como placas que graba la app),
subir nada a las tiendas ni producir *app previews* de App Store.

## Dónde encaja

```mermaid
flowchart BT
    brand["packages/pseudolearn_brand<br/>brand.generated.ts y fuentes IBM Plex"] --> media["packages/pseudolearn_store_media"]
    app["apps/pseudolearn_app<br/>placas y timeline.json"] -.-> media
    tools["FFmpeg y ffprobe<br/>dependencias del sistema"] --> media
    media -.-> appTool["apps/pseudolearn_app/tool<br/>lee slots.json, historia y contrato"]
    media --> out["build/<br/>piezas y manifiestos"]
```

Las líneas punteadas son contratos de datos, no imports: la app graba las placas que el motor lee, y su herramienta
`store_plates` lee de este paquete `catalog/slots.json`, `stories/app-store-screenshots.json` y
`tests/contracts/plate-timeline.json`.

## Arquitectura

```mermaid
flowchart BT
    catalog --> story & layout
    story --> audio
    layout --> audit
    story & layout --> compose
    audio & audit & compose --> pipeline
    pipeline --> render
    pipeline & render --> cli
```

Se omiten las aristas hacia `catalog`, que todas las capas importan, las de `story` y `layout` hacia `pipeline` y la de
`audit` hacia `render`.

| Capa       | Qué hace                                                                                                                          |
|:-----------|:----------------------------------------------------------------------------------------------------------------------------------|
| `catalog`  | Lee y valida `catalog/slots.json` y `catalog/lexicon.json`: ranuras, dispositivos, perfiles de códec y sonoridad                  |
| `story`    | Guiones con hitos e historias de capturas, de la lente y del tráiler; lectura del `timeline.json` de las placas                   |
| `layout`   | Zonas seguras, recorte por dispositivo, muestreo de fotogramas, ajuste de titulares, anclaje de anotaciones y geometría de lentes |
| `audio`    | Partitura, síntesis, ganancia y codificación WAV, sin dependencias                                                                |
| `audit`    | Hallazgos con regla estable sobre medidas, alfa, códec, fps, duración, audio, bucle, placa, léxico, contraste, ajuste y entrega   |
| `compose`  | Composiciones HTML: calibración, capturas editoriales y de escritorio, lente, lente muda, tráiler e icono de tienda              |
| `pipeline` | Plan ranura × idioma y producción de capturas, imágenes y vídeo, expresada contra los puertos de `ports.ts`                       |
| `render`   | Adaptadores de los puertos: HyperFrames, FFmpeg y ffprobe, ensamblado de placas, archivos y catálogo                              |
| `cli`      | Los nueve comandos de `pnpm media`                                                                                                |

## Flujo principal

Flujo de datos de una pieza de vídeo, no de dependencias.

```mermaid
flowchart LR
    slot["ranura del catálogo"] --> story["guion y hitos"]
    story --> html["composición HTML"]
    html --> safe{"zona segura y léxico"}
    safe --> frames["HyperFrames<br/>PNG por fotograma"]
    story --> score["banda sonora"]
    frames & score --> encode["FFmpeg"]
    encode --> audit{"auditoría del archivo"}
    audit --> manifest["manifiesto con SHA-256"]
```

Flujo de una captura fija:

```mermaid
flowchart LR
    story["historia: textos es/en,<br/>paleta y anotación"] --> fit["ajuste de textos"]
    plate["placa y timeline.json"] --> pin["anotación sobre la UI real"]
    fit & pin --> check{"placa, zona, léxico,<br/>contraste y ajuste"}
    check --> still["HyperFrames<br/>un fotograma"]
    still --> flat["FFmpeg: PNG opaco"]
    flat --> audit{"medidas y alfa"}
    audit --> manifest["manifiesto por imagen"]
```

Si falla una regla previa al render (placa ausente o de otra medida, texto fuera de margen, léxico, contraste o
titular que no cabe), la imagen no se renderiza.

## Reglas que conviene saber

- Las capas solo importan lo que permite `architecture.json`; `node:`, `@hyperframes/` y `hyperframes` solo se importan
  desde `render` y `cli`.
- Archivos de 200 líneas, funciones de 40, 4 parámetros, 3 niveles de anidamiento y 7 métodos públicos por clase;
  rigen también en `tests/` y `scripts/`. Sin comentarios en ningún archivo de código.
- Un fallo esperable es un valor (`Outcome`, `Parsed`, `Finding`), no una excepción que cruce el CLI.
- `src/compose/brand.generated.ts` lo escribe `pseudolearn_brand`; está en el `.gitignore` y no se edita.
- Añadir una ranura es añadir una entrada a `catalog/slots.json`; el parser rechaza lo que no reconoce.
- Cada ranura declara su formato de píxel (`pixelFormat`, `rgb` si no lo dice). Solo el icono de Google Play pide `rgba`:
  Play exige un PNG de 32 bits con alfa, y el resto de las ranuras rechaza la transparencia.
- Google Play pide evitar la imagen de dispositivos y que el texto no ocupe más del 20 % de una captura. Por eso el
  dispositivo `android-phone` no lleva marco (la placa va como una tarjeta redondeada) y su historia,
  `stories/google-play-screenshots.json`, solo tiene los capítulos con la interfaz, sin el manifiesto. Las capturas son
  9:16 (1440×2560), dentro de los 320–3840 px y la proporción máxima de 2,3 que acepta Play y por encima de los 1080 px
  que pide para recomendaciones. El gráfico destacado es la lente muda de Microsoft a 1024×500, sin texto ni interfaz,
  con lo esencial en el centro; el icono es el SVG `app-icon` que genera la marca, el mismo de los lanzadores, a
  pantalla completa porque Play recorta las esquinas. El techo de 8 MB del gráfico destacado es propio: la ayuda de
  Play no publica uno.
- El léxico de Google Play añade a las reglas comunes las otras plataformas y lo que Play prohíbe en sus gráficos:
  reconocimientos de la tienda, «nuevo», «top», «popular», rebajas y cifras de descargas.
- Toda dependencia nueva debe llevar al menos 14 días publicada (`minimumReleaseAge` en `pnpm-workspace.yaml`).

## Comandos útiles

| Para qué                            | Comando                                                                          |
|:------------------------------------|:---------------------------------------------------------------------------------|
| Instalar dependencias               | `pnpm install`                                                                   |
| Generar el módulo de marca          | `pnpm generate:brand`                                                            |
| Tipos, capas, comentarios y tamaños | `pnpm check`                                                                     |
| Tests                               | `pnpm test`                                                                      |
| Listar las ranuras por idioma       | `pnpm media plan --lang es`                                                      |
| Calibración de una ranura de vídeo  | `pnpm media calibrate --slot apple.header.video --lang es`                       |
| Auditar una imagen                  | `pnpm media audit-image --slot apple.mac.screenshot --file x.png`                |
| Capturas de App Store y Google Play | `pnpm media screenshots` (`--slot`, `--lang`, `--story`, `--plates`, `--guides`) |
| Encabezado, búsqueda y universal    | `pnpm media creative` (`--slot`, `--lang`, `--story`)                            |
| Capturas de escritorio de Microsoft | `pnpm media desktop-screenshots` (`--lang`, `--story`, `--plates`)               |
| Héroe, póster y caja de Microsoft   | `pnpm media hero` (`--slot`, `--lang`)                                           |
| Gráfico destacado de Google Play    | `pnpm media hero --slot google-play.feature-graphic`                             |
| Icono de Google Play                | `pnpm media icon --slot google-play.app-icon`                                    |
| Capturas de teléfono de Google Play | `pnpm media screenshots --slot google-play.phone.screenshot`                     |
| Tráiler de Microsoft con miniatura  | `pnpm media trailer` (`--lang`, `--plates`)                                      |

Sin `--story`, `screenshots` elige la historia de cada tienda (`app-store-screenshots.json` o
`google-play-screenshots.json`), y sin `--slot` produce las ranuras de captura de ambas. `screenshots` y
`desktop-screenshots` leen por defecto las placas de `../../apps/pseudolearn_app/build/store-plates`;
`trailer`, las de `build/trailer-plates` de la app. `creative` y `hero` no necesitan placas.

Requisitos: Node 22.23.3, pnpm 12.8.1, FFmpeg y ffprobe en el `PATH` con `aac_at` (solo macOS) para el tráiler de
Microsoft, y Python 3 con `fonttools` para generar la marca. Las salidas quedan en `build/`, fuera de git.

## Pendientes declarados

- Las ranuras de búsqueda y universal de App Store no tienen perfiles de recorte medidos (`viewportProfiles` solo
  existe en `apple.header.video`); su revisión final es humana, en Preview de App Store Connect.
