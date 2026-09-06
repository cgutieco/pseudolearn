# pseudolearn_brand

Motor paramétrico de la identidad visual de PseudoLearn. Fuente de verdad técnica de este paquete y de
la marca: el símbolo, el logotipo, los lockups, los íconos de aplicación y el documento de lineamientos.
Aquí vive el *por qué* de cada medida, para que ningún archivo generado necesite comentarios que lo
expliquen.

Este paquete **no** decide tokens de interfaz. El color, la tipografía y los radios que consume salen de
`apps/pseudolearn_app/docs/fundamentos-visuales.md`, que sigue siendo la fuente de verdad de esos
valores; lo que se documenta aquí es cómo se combinan para formar una marca, y las medidas propias de la
marca que ninguna tabla de aquel documento cubre.

**Estado:** Motor completo. Doce vectores maestros, un módulo de TypeScript y el documento de
lineamientos salen de un único catálogo declarativo, y un verificador falla cuando un consumidor deja de
seguirlos. Cableado completado para iOS y macOS: los conjuntos `AppIcon.appiconset` de ambas plataformas
se generaron desde `app-icon.svg` con Xcode y se verificaron con su compilador nativo (`actool`). La
aplicación de Flutter consume la marca por su tercera vía —geometría redibujada en Dart, §4.7—, con la
que además se rasteriza la pantalla de lanzamiento de iOS. El sitio web consume el módulo de TypeScript
que este paquete emite. Los `mipmap` de Android y el resto de `web/icons` siguen pendientes.

---

## 1. Qué es y qué no es

### 1.1 Propósito y problema que resuelve

Da a la aplicación una identidad reconocible en la pantalla de inicio del sistema, donde compite con
íconos que no controlamos, y una firma tipográfica para cualquier superficie donde el nombre aparezca
escrito. Resuelve dos problemas, y el segundo es el que justifica que esto sea un paquete y no una
carpeta de vectores:

1. **Un ícono entregado como imagen es un callejón sin salida.** No se reescala sin pérdida, no se
   recolorea, no se audita contra el sistema de diseño y no se regenera cuando cambia una medida. Todo
   lo que este paquete produce es geometría paramétrica.
2. **Una marca tiene cuatro consumidores que hablan idiomas distintos** —vectores para las herramientas
   de plataforma, TypeScript para el sitio, constantes de Dart para la aplicación, y un documento HTML
   para quien la usa— y cada uno de ellos es una oportunidad de que alguien pegue una copia que deja de
   seguir al maestro. El motor emite cada idioma desde la misma geometría, y el verificador convierte
   esa divergencia en un fallo mecánico en vez de en un defecto que se descubre a ojo.

### 1.2 Responsabilidades primarias

1. **Geometría de la marca** (`model/`): el símbolo como parámetros, los contornos reales de IBM Plex, y
   las medidas derivadas de ambos —caja de tinta, escala de inscripción, layout de los dos lockups—.
2. **Catálogo de variantes** (`brand.json`): qué composiciones existen, con qué lienzo, con qué tinta y
   hacia qué destino. Añadir una variante es añadir una entrada, nunca una rama en el código.
3. **Emisión por consumidor** (`render/`): un documento SVG, un fragmento SVG en línea, un módulo de
   TypeScript, las constantes que la aplicación redibuja, y el documento de lineamientos.
4. **Verificación** (`pipeline/`, `tool/`): que ningún consumidor guarde una copia que el motor ya no
   produce, y que este paquete respete sus propias capas y límites.

### 1.3 Fuera de alcance a propósito (`SCOPE-YAGNI`)

- **Activos rasterizados.** No hay PNG aquí. Los pide cada plataforma en su propio formato y tamaño; se
  generan en el paso de cableado, no aquí (§2.4).
- **Íconos de interfaz.** El set de trazo de la app se rige por §6 de `fundamentos-visuales.md`, con
  rejilla, grosores y ángulos propios. La marca no pertenece a ese set y no debe usarse como un ícono más.
- **Variantes de campaña, animaciones y superficies de marketing.** La app no tiene superficie de
  marketing (`fundamentos-visuales.md` §2.1, que por eso descarta una familia tipográfica de display).
- **Monograma alternativo, isotipo secundario o versión apilada del símbolo.** Ninguna fase los pide.
- **Emisión de código Dart.** El motor **verifica** las constantes que la aplicación redibuja; no las
  escribe. El porqué está en §4.8.

---

## 2. Guía operativa

### 2.1 Requisitos previos

Python 3.9 o superior con `fonttools`. Ninguna otra dependencia: las dos caras de IBM Plex de las que se
contornea el logotipo viajan dentro del paquete (§4.2).

```bash
python3 -m pip install fonttools
```

### 2.2 Regenerar todos los artefactos

Cualquier cambio de geometría se hace en `brand.json` o en `pseudolearn_brand/`, nunca editando un
archivo generado. Un archivo generado que se edita a mano se pierde en la siguiente ejecución y deja de
coincidir con el resto de la familia.

```bash
(cd packages/pseudolearn_brand && python3 -m pseudolearn_brand build)
```

Escribe quince artefactos: los doce vectores maestros y el documento de lineamientos en `out/`, que no se
versiona, y los dos artefactos que un consumidor necesita tener versionados (§4.5).

### 2.3 Verificación

```bash
(cd packages/pseudolearn_brand && python3 -m pseudolearn_brand check && python3 tool/check_limits.py && python3 -m unittest discover -s test -t .)
```

La matriz completa de qué detecta cada verificador está en §7.1.

Además de lo mecánico, una modificación de la geometría se mira antes de darla por buena. La comprobación
visual tiene cuatro pasos y ninguno es opcional:

1. **Reducción.** El ícono se mira a 16, 24, 32 y 48 px. A 16 px la bandera se empasta un poco con el
   asta: eso es correcto y está previsto. Lo que no se admite es que los tres giros dejen de contarse,
   porque entonces la ruta se vuelve una mancha en zigzag.
2. **Máscaras de Android.** El par `app-icon-android-*` se compone y se recorta con círculo, squircle y
   cuadrado. El símbolo no puede tocar ningún borde en ninguna de las tres.
3. **Fondo claro y oscuro.** Los cuatro lockups se miran sobre `neutral-0` y sobre `neutral-950`.
4. **Registro de capas.** Las dos capas de `icon-composer/` se superponen y tienen que coincidir al
   píxel con `app-icon.svg`. Ambas se colocan por la caja de tinta de la marca entera, nunca por la
   suya propia, y por eso comparten `transform` idéntico. Esto además está cubierto por un test.

`out/guidelines.html` es el documento con el que se hacen los cuatro pasos: reúne las treinta figuras
sobre fondo claro y oscuro.

### 2.4 Rasterizar para una plataforma

Ninguna plataforma consume SVG. Cada activo rasterizado se produce en el paso de cableado, no aquí, y
cada destino tiene un procedimiento distinto porque las herramientas que los aceptan son distintas.

| destino                                | procedimiento                                                                                                             |
|----------------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| Ícono de iOS y de macOS                | Xcode: se importa `out/app-icon.svg`, y él rellena y compila los tamaños de `AppIcon.appiconset`. Verificado con `actool` |
| Ícono por capas de iOS, iPadOS y macOS | Icon Composer, con las dos capas de `out/icon-composer/` y los fondos declarados en §4.6                                  |
| Pantalla de lanzamiento de iOS         | `flutter test tool/generate_launch_images.dart` desde `apps/pseudolearn_app/`                                             |

El catálogo resultante se comprueba con el mismo compilador que usa Xcode, que es lo que detecta un
`Contents.json` mal formado o una variante de aspecto que el sistema no reconocería:

```bash
xcrun actool --compile /tmp/actool-check --platform iphoneos --minimum-deployment-target 13.0 \
  --target-device iphone --output-format human-readable-text --notices --warnings \
  apps/pseudolearn_app/ios/Runner/Assets.xcassets
```

**Por qué la pantalla de lanzamiento no pasa por el SVG.** El primer fotograma que dibuja la app es la
misma figura, y el sistema la sustituye por la app sin transición: cualquier diferencia de escala, de
color o de suavizado entre las dos se ve como un salto. Generarla con el mismo motor que dibuja el
fotograma siguiente hace que no pueda haber diferencia. El generador de la app escribe también los
`Contents.json` del imageset y del color de fondo, así que la variante clara y la oscura no se editan a
mano.

### 2.5 Despliegue y distribución

Este paquete no se publica ni se compila. Se ejecuta a mano cuando la marca cambia, y su salida versionada
viaja dentro de los repositorios de sus consumidores.

---

## 3. Arquitectura y modelo del sistema

### 3.1 Paradigma arquitectónico

Tres capas concéntricas, en la dirección de siempre: los datos y las medidas no saben nada de cómo se
dibujan, los dibujantes no saben nada de dónde se escriben, y solo la capa exterior toca el disco fuera
de este paquete.

```
┌──────────────────────────────────────────────┐
│ pipeline/   qué se escribe y qué se verifica │
└───────────────────────┬──────────────────────┘
                        ▼
┌──────────────────────────────────────────────┐
│ render/     un emisor por idioma de destino  │
└───────────────────────┬──────────────────────┘
                        ▼
┌──────────────────────────────────────────────┐
│ model/      geometría, tipografía, catálogo  │
└──────────────────────────────────────────────┘
```

### 3.2 Catálogo de carpetas, responsabilidades e invariantes

| Directorio                    | Responsabilidad única                                                             | Puede importar                              | Prohibido importar                                   |
|:------------------------------|:----------------------------------------------------------------------------------|:--------------------------------------------|:-----------------------------------------------------|
| `pseudolearn_brand/model/`    | Geometría del símbolo, contornos de IBM Plex, catálogo tipado y medidas derivadas | — (solo la librería estándar y `fontTools`) | `render/`, `pipeline/`                               |
| `pseudolearn_brand/render/`   | Un emisor por idioma de destino: SVG, TypeScript, constantes de Dart, HTML        | `model/`                                    | `pipeline/`, escritura en disco                      |
| `pseudolearn_brand/pipeline/` | Resolución de la raíz del monorepo, plan de artefactos, escritura y verificación  | `model/`, `render/`                         | —                                                    |
| `brand.json`                  | Catálogo declarativo de variantes y destinos                                      | — (datos)                                   | Cualquier detalle de implementación                  |
| `templates/`                  | Plantilla del documento de lineamientos, con huecos que rellena el motor          | — (datos)                                   | Geometría escrita a mano (`BRAND-TEMPLATE-GEOMETRY`) |
| `assets/fonts/`               | Las dos caras de IBM Plex de las que se contornea el logotipo                     | —                                           | —                                                    |
| `out/`                        | Salida no versionada                                                              | —                                           | —                                                    |

Las reglas que el verificador ejecuta viven en `architecture.json`, y son la única definición que
`tool/check_limits.py` lee.

### 3.3 El símbolo

**La ruta que recorre un algoritmo, desde donde arranca hasta donde llega.** Sale de un nodo terminal,
gira tres veces en ángulo recto y termina en una bandera. No hay ninguna letra.

| pieza           | qué es                     | de dónde sale                                          |
|-----------------|----------------------------|--------------------------------------------------------|
| punto de salida | nodo terminal              | `flow.node.radius.terminal` — el terminal es circular  |
| los tres giros  | conectores del ordinograma | ángulos de 0° y 90°, uniones redondas                  |
| la bandera      | la meta                    | única pieza que no viene del ordinograma; da el porqué |

**Por qué una figura y no una inicial.** Ninguno de los íconos que una persona reconoce de un vistazo en
su pantalla de inicio es una letra: son un molinete, un pin, un avión, un corazón. Una inicial obliga a
saber ya el nombre para descifrarla, que es justo lo contrario de lo que un ícono tiene que hacer.

**Por qué esta figura y no un diagrama.** Un ordinograma dibujado —nodos y conectores— se lee como
organigrama, y unas barras indentadas se leen como «alinear texto»: son esquemas, y un esquema parece
un ícono de barra de herramientas. Una ruta es una cosa, no un esquema, y sus giros en ángulo recto son
literalmente los conectores del ordinograma de la app.

### 3.4 Geometría, en unidades de la rejilla

Todo se mide contra una rejilla cuadrada de **96**. Nada es arbitrario y nada se ajusta «a ojo»:

| medida           | valor | por qué ese valor                                                                  |
|------------------|-------|------------------------------------------------------------------------------------|
| rejilla          | 96    | unidad base; 4 × la rejilla de 24 del sistema de íconos                            |
| grosor del trazo | 14    | por debajo de esto los giros se cierran entre sí a 16 px                           |
| tramo            | 26    | los **seis** tramos miden lo mismo, y por eso los giros se leen como pasos iguales |
| nodo de salida   | r 10  | más gordo que el trazo, para que se lea como nodo y no como remate                 |
| bandera          | 26×26 | mismo módulo que el tramo; el asta es el sexto tramo, no una pieza aparte          |
| caja de tinta    | 95×95 | consecuencia de lo anterior, no una elección: la figura sale cuadrada              |

Terminaciones y uniones **redondas**, y las tres esquinas de la bandera van a radio 3: no queda ni un
ángulo agudo en toda la marca, porque un ángulo agudo pierde nitidez en cuanto el sistema reduce el
ícono. Solo hay ángulos de 0° y 90°: la única diagonal es la de la bandera.

**La marca son contornos rellenos, no trazos.** Cada tramo es un rectángulo de esquinas redondeadas
—radio igual a la mitad del grosor, que es lo que produce el remate semicircular— y todos los subtrazados
giran en el mismo sentido, así que la regla de relleno «non-zero» los une. Un trazo obligaría a la
herramienta a interpretarlo, y una capa con opacidad menor que uno oscurecería el doble donde dos tramos
se solapan.

### 3.5 El logotipo

«Pseudo» en **IBM Plex Mono Medium** y «Learn» en **IBM Plex Sans Bold**, contorneadas a `path`. La
palabra dice la tesis del producto: lo que es código va en monoespaciada, lo que es aprendizaje va en
prosa. Ambas familias comparten métricas verticales y altura de x, así que las dos mitades se apoyan en
la misma línea base sin compensación óptica.

Dos ajustes, ambos con motivo:

- **`Learn` lleva tracking −1.5** (sobre cuerpo 100), la proporción de `heading-1`. La monoespaciada **no
  lleva tracking**: cerrarla destruiría la rejilla de paso constante, que es exactamente la señal que la
  hace leer como código.
- **La costura entre las dos mitades se cierra 6 unidades.** Con el avance nominal, el hueco de tinta
  entre la `o` y la `L` mide 13.2, casi el doble del hueco interno de la monoespaciada. Cerrado a 7.2,
  la palabra se lee como una sola.

### 3.6 Composiciones autorizadas

Hay tres, y ninguna más: los dos lockups y la firma. Un lockup lleva siempre la placa; la firma es el
símbolo solo y por eso no es un lockup, es la excepción acotada que se describe al final.

| archivo             | placa            | hueco           | cuándo                                           |
|---------------------|------------------|-----------------|--------------------------------------------------|
| `lockup-horizontal` | 1.75 × versalita | 0.24 × la placa | barra superior, pie, cabecera de documento       |
| `lockup-vertical`   | 2.40 × versalita | 0.32 × la placa | pantalla de bienvenida, portada, espacio angosto |

**El lockup usa la placa, nunca el símbolo suelto.** La placa es lo que la persona ya reconoce de su
pantalla de inicio; suelto sobre blanco, el mismo trazo se lee como un ícono de interfaz cualquiera y
pierde el color de marca, que es la mitad de la señal.

**Espacio libre mínimo:** el ancho del asta del símbolo al tamaño en uso — 0.23 × la altura de la placa.
Ningún otro elemento entra en ese margen.

**La firma: símbolo solo, y no es un lockup.** Es la marca en tinta plana como rúbrica permanente de un
armazón de interfaz —la cabecera del raíl de navegación, la pantalla de lanzamiento—. No lleva placa por
dos razones: ahí no hay nada de qué distinguirla, porque es la única marca en pantalla, y a 28 px la
placa se leería como un ícono de aplicación incrustado en la interfaz. Fuera de esas condiciones vuelve
a mandar la regla de arriba y va un lockup.

| composición | qué es                  | tamaño mínimo | dónde                                                         |
|-------------|-------------------------|---------------|---------------------------------------------------------------|
| firma       | símbolo solo, sin placa | 24 px         | cabecera de armazón, pantalla de lanzamiento, portada de paso |

Tres condiciones, y si alguna no se cumple va un lockup y no una firma: **no es interactiva** —no es un
botón ni un destino—, **no acompaña a texto** como si fuera su ícono, y **no aparece dos veces** en la
misma pantalla.

### 3.7 Íconos de aplicación

| variante                   | lienzo | esquinas         | para qué                                                           |
|----------------------------|--------|------------------|--------------------------------------------------------------------|
| `icon-composer/01-ruta`    | 1024   | ninguna          | capa de fondo a frente, sin fondo propio, para Icon Composer       |
| `icon-composer/02-bandera` | 1024   | ninguna          | capa delantera; se compone sobre la anterior                       |
| `app-icon`                 | 1024   | ninguna          | versión aplanada: iOS, iPadOS, macOS, App Store, *maskable* de web |
| `app-icon-android-*`       | 108    | ninguna          | par adaptativo; recorta el lanzador, con su forma                  |
| `favicon`                  | 64     | 22.37 % del lado | el navegador no enmascara                                          |

**iOS, iPadOS y macOS toman el mismo cuadrado a sangre y sin enmascarar.** Los tres dibujan la forma
redondeada ellos mismos, y una forma cocida en el activo pelea con la máscara y con el reflejo especular
que el sistema pone en el borde. `app-icon.svg` sirve además como ícono *maskable* de web: su contenido
cabe holgado en el círculo del 80 % que esa especificación exige.

El **símbolo se inscribe en una caja de 0.64 × 0.55 del área visible**, ajustado al límite que primero lo
restrinja — siendo la marca cuadrada, la altura. Son dos límites y no uno porque una marca ancha se ve
tan grande como una alta con menos altura; con un solo número, una variante ancha saldría desproporcionada.

El **0.55 está derivado, no elegido**: una marca cuadrada inscrita en el círculo seguro del 80 % que un
ícono *maskable* de web puede recortar no puede pasar de 0.566 del lado, y 0.55 deja margen en vez de
apoyarse en el límite. A 1024 la marca mide 563 y su media diagonal es 398.2 contra un radio seguro de
409.6. Al ser la misma regla en las cuatro plataformas, los íconos se ven del mismo tamaño puestos uno
al lado del otro. El catálogo declara los dos números y el círculo seguro, y el motor **rechaza cargar**
un catálogo cuya altura de inscripción se salga de ese techo (`BRAND-CATALOG`): la relación es una regla
verificada, no un comentario.

---

## 4. Decisiones de diseño y fundamentos técnicos

### 4.1 La marca es vectorial y paramétrica, no una imagen

- **Problema:** un ícono entregado como PNG o generado por un modelo de imagen no se puede reescalar sin
  pérdida, recolorear, auditar contra el sistema de diseño ni regenerar cuando cambia una medida.
- **Elección:** toda la geometría vive en `model/` como funciones con parámetros nombrados, y los
  archivos son su salida. Los contornos del logotipo se extraen de los `.ttf` con `fontTools`, así que
  son la letra real de IBM Plex, no un trazado aproximado.
- **Consecuencia:** cambiar el grosor del trazo o el peso de la monoespaciada es cambiar un valor y
  volver a ejecutar. A cambio, este paquete introduce Python en un monorepo que por lo demás es Dart y
  TypeScript; se acepta porque no participa en ningún build y se ejecuta a mano cuando la marca cambia.
- **Descartado:** dibujar los SVG a mano. La familia tiene doce archivos que comparten geometría; a mano,
  divergen en el primer retoque que alguien no propague a los otros once.

### 4.2 El paquete es autosuficiente: las fuentes viajan dentro

- **Problema:** la versión anterior de este generador resolvía las caras de IBM Plex contando directorios
  hacia arriba hasta `apps/pseudolearn_app/assets/fonts/`. Eso ataba la marca a los activos de una
  aplicación —la dirección de dependencia contraria a la que el monorepo declara— y se rompía en cuanto
  el generador cambiaba de sitio.
- **Elección:** las dos caras de las que se contornea el logotipo se copian dentro de `assets/fonts/`, y
  la raíz del monorepo se localiza buscando el marcador `.git` hacia arriba, nunca contando niveles.
- **Consecuencia:** el paquete se ejecuta desde cualquier ubicación y no depende de ningún consumidor. A
  cambio, dos archivos binarios existen dos veces en el repositorio. El verificador `BRAND-FONT-DRIFT`
  compara los bytes de ambas copias, así que la duplicación no puede divergir en silencio.
- **Descartado:** un enlace simbólico a los activos de la app, que reintroduce la dependencia invertida y
  no sobrevive a un `git clone` en Windows.

### 4.3 El catálogo es un dato, no un guion

- **Problema:** el generador anterior era un guion imperativo con once bloques numerados a mano. Añadir
  una variante era editar código y ramificar sobre «qué configuración es», que es justo lo que el
  principio de abierto/cerrado pide evitar.
- **Elección:** `brand.json` declara cada variante —composición, lienzo, área visible, esquinas, tinta,
  identificador de degradado y destino— y `render/` tiene un dibujante por composición. El catálogo se
  carga a tipos con `dataclass`, y una clave que el esquema no conoce es un error, no un valor ignorado.
- **Consecuencia:** añadir `app-icon-android-monochrome` es añadir una entrada. Ninguna función del motor
  pregunta por el nombre de una variante.
- **Descartado:** YAML, que sería consistente con los `architecture.yaml` del resto del monorepo, pero
  obliga a instalar un analizador de terceros para leer cuarenta líneas de configuración desde una
  herramienta que por lo demás solo necesita la librería estándar. Dart trae YAML de serie y Python trae
  JSON de serie; cada paquete usa el formato que su intérprete ya sabe leer. Por la misma razón las
  reglas de este paquete están en `architecture.json` y no en `architecture.yaml`.

### 4.4 Contornos, no `<text>`

- **Problema:** un logotipo con `<text font-family="IBM Plex Mono">` cae a la fuente del sistema en
  cualquier máquina que no la tenga instalada, y lo hace en silencio.
- **Elección:** cada glifo es un `path`.
- **Consecuencia:** el logotipo no es editable como texto ni buscable. Se acepta: es una marca, no un
  párrafo. `wordmark.svg` lleva un elemento `<title>` para la accesibilidad.

### 4.5 La salida no se versiona; lo que un build necesita, sí

- **Problema:** doce vectores versionados son doce archivos derivados que alguien puede editar a mano, y
  que ensucian cada revisión con ruido generado. Pero no todo lo que este motor produce es material de
  referencia: `apps/fe-pseudolearn/public/favicon.svg` entra en el paquete que se despliega a Cloudflare,
  y su compilación no puede depender de que haya un Python con `fontTools` en el CI.
- **Elección:** dos destinos con reglas distintas. Los **vectores maestros** y el documento de
  lineamientos van a `out/`, ignorado por git, y son la referencia de diseño con la que se rasteriza cada
  plataforma. Los **artefactos que un build consume** —hoy el favicon del sitio y el módulo de TypeScript
  del símbolo— los escribe el motor directamente en su ubicación versionada, y `check` falla si alguno
  deja de coincidir con lo que el motor produce hoy.
- **Consecuencia:** la carpeta del paquete solo contiene el motor, y ningún consumidor necesita Python
  para compilar. A cambio, dos artefactos generados sí aparecen en revisiones; se aceptan porque son la
  frontera del motor con un build ajeno, y porque el verificador los cubre.
- **Descartado:** ignorar también los artefactos de consumidor y regenerarlos en cada build, que mete
  Python y `fontTools` en el CI de un sitio de Astro para producir dos archivos que casi nunca cambian.

### 4.6 Íconos por capas, y no una imagen aplanada

- **Problema:** desde junio de 2025 el ícono de iOS, iPadOS, macOS y watchOS es **por capas**. El sistema
  le aplica atributos de Liquid Glass —reflejo especular, refracción, translucidez— que responden al
  entorno y al gesto, y genera solo las variantes de aspecto que uno no entrega. Un único archivo
  aplanado renuncia a todo eso.
- **Elección:** exportar la marca partida en dos capas, de atrás hacia delante, en `icon-composer/`. La
  ruta detrás, la bandera delante. Se importan a **Icon Composer**, que viene con Xcode.
- **Consecuencia:** los solapes entre la bandera y el asta pasan a ser material de profundidad —Apple
  recomienda explícitamente formas macizas que se solapan— y el fondo deja de estar cocido en el activo.
- **Qué se declara dentro de Icon Composer y no aquí:** la herramienta pide expresamente que el material
  llegue **sin** fondo, sin degradado, sin desenfoque, sin sombra y sin ajustes de opacidad, porque esos
  los aplica ella y los previsualiza. El fondo se define ahí como degradado vertical:

| aspecto     | de        | a         | color de la marca       |
|-------------|-----------|-----------|-------------------------|
| por defecto | `#195C5F` | `#0F4346` | `#FFFFFF` (`neutral-0`) |
| oscuro      | `#0F4346` | `#072D2F` | `#D7F1F2` (`brand-100`) |

El aspecto oscuro parte del claro y solo baja un peldaño la escala, como pide la guía: mismos rasgos,
colores complementarios, nada excesivamente brillante. El contraste sigue siendo de 12.45:1. Las
variantes *clear* y *tinted* las genera el sistema a partir del canal alfa de las capas, que en esta
marca es una silueta maciza de una sola tinta: el caso más favorable posible.

- **Se conserva `app-icon` aplanado** porque la propia guía lo admite, y porque de él salen los activos
  de Android, de web y de la App Store.
- **Descartado:** `app-icon-macos` con su recuadro de 824 sobre 1024 y esquinas propias. Esa era la
  convención de macOS anterior; hoy macOS comparte cuadrado a sangre con iOS y enmascara él mismo, y
  entregar una máscara ya dibujada degrada el reflejo especular y deja los bordes dentados.

### 4.7 Dentro de la app la marca se redibuja, no se carga

- **Problema:** la aplicación de Flutter no lleva renderizador de SVG, y `pubspec.yaml` no puede declarar
  activos fuera del directorio de su paquete, así que los vectores de este paquete son literalmente
  inalcanzables desde ella.
- **Elección:** la app redibuja el símbolo con las mismas primitivas que usa `model/geometry.py` —seis
  rectángulos de esquinas redondeadas, un círculo y un triángulo de esquinas a radio 3— y compone el
  logotipo con las dos caras de IBM Plex que ya empaqueta.
- **Consecuencia:** cero dependencias nuevas, cero activos copiados, y la marca sigue siendo geometría
  paramétrica también dentro de la app. A cambio, las medidas del símbolo existen en dos idiomas: aquí en
  Python y allí en Dart.
- **Descartado:** añadir `flutter_svg` y copiar los vectores a los activos de la app, que mete una
  dependencia de terceros y un artefacto generado copiado a mano.

### 4.8 A la app se le verifica, al sitio se le emite

- **Problema:** los dos consumidores de código tienen la geometría duplicada, pero por motivos distintos.
  El sitio pegaba literalmente el `d` del símbolo dentro de un componente de Astro —una copia sin ninguna
  razón de ser—. La aplicación declara veintiséis constantes que **redibuja** con las primitivas de
  Flutter, y esa duplicación sí tiene un motivo (§4.7).
- **Elección:** al sitio se le **emite** `symbol-path.generated.ts`, y su componente lo importa. A la app
  no se le escribe nada: `check` lee `brand_metrics.dart`, compara las veintiséis medidas que el motor
  deriva y falla si alguna no coincide, dejando intactas las que la aplicación tiene en propiedad —los
  tamaños de uso, por ejemplo—.
- **Consecuencia:** la copia sin razón desaparece; la copia con razón queda vigilada de verdad. Antes, el
  README de la marca afirmaba que una prueba de la app comparaba sus medidas «contra los `viewBox` que
  este generador escribe», pero esa prueba comparaba contra números literales y nadie leía la salida del
  generador: cambiar un valor aquí no rompía nada. Ahora sí.
- **Descartado:** emitir también el archivo de Dart. Metería un generador de código en un repositorio que
  no tiene ninguno y obligaría a recordar ejecutarlo antes de cada compilación de la app; verificar da la
  misma garantía sin ninguno de los dos costes. Y al revés, verificar el módulo del sitio en vez de
  emitirlo dejaría a una persona escribiendo a mano una cadena de mil caracteres.

### 4.9 El documento de lineamientos también se genera

- **Problema:** `guidelines.html` tenía treinta figuras SVG escritas dentro del propio documento, con la
  geometría de la marca pegada en cada una. Era la quinta copia y la más difícil de auditar a ojo.
- **Elección:** el documento pasa a ser una plantilla en `templates/` con huecos `{{svg:variante}}` y
  `{{path:pieza}}` que el motor rellena. Un hueco que nombra una variante que el catálogo no declara es un
  error, no un hueco vacío.
- **Consecuencia:** la plantilla bajó de 99 KB a 36 KB, veintinueve de las treinta figuras salen del
  motor, y la que queda —el diagrama de construcción, con sus guías de rejilla— toma la geometría por un
  hueco `{{path:symbol}}`. El verificador `BRAND-TEMPLATE-GEOMETRY` rechaza que vuelva a aparecer un `d`
  largo escrito a mano en la plantilla.
- **Descartado:** dejar el documento como estaba y verificarlo. Comparar treinta bloques de HTML contra
  treinta fragmentos generados exige normalizar espacios y sangrías, y el resultado sería un verificador
  frágil que resuelve peor el mismo problema.

---

## 5. Reglas de uso de la marca

- El símbolo no se rota, no se estira, no se inclina y no cambia de proporción interna.
- La ruta no se recorta: los tres giros y los dos remates van siempre juntos. Media ruta no es una
  versión reducida autorizada de la marca.
- El símbolo no lleva sombra, contorno ni brillo.
- La bandera no cambia de color respecto del trazo. La marca es de una sola tinta, y eso es lo que le
  permite funcionar bordada, grabada o en negativo.
- El logotipo no se compone escribiendo «PseudoLearn» con una fuente: se usa `wordmark.svg`. **Única
  excepción, la aplicación de Flutter:** empaqueta IBM Plex Mono Medium e IBM Plex Sans Bold, que son las
  dos caras exactas de las que se contornea el vector, y un verificador comprueba en cada compilación que
  siguen empaquetadas. Ahí el motivo de la regla —que la fuente puede no estar instalada y la caída es
  silenciosa— no se cumple. La excepción no se extiende a ninguna otra superficie.
- No se crean composiciones nuevas fuera del catálogo. Si hace falta otra, se añade a `brand.json` y se
  documenta aquí en el mismo cambio.

---

## 6. Reglas de legibilidad y estructura de código

- **Idioma:** todo el código, los nombres de test y los mensajes de commit en inglés (`LANG-EN-CODE`).
  Esta documentación, en español (`LANG-ES-DOCS`).
- **Comentarios:** ninguno. `tool/check_limits.py` rechaza cualquier `#` en `pseudolearn_brand/`
  (`BRAND-NO-COMMENTS`). El *qué* lo dicen los nombres; el *por qué* vive en este README. Se admite un *docstring* por
  módulo, por clase y por función, que describe la responsabilidad, nunca la
  implementación ni una referencia a este documento.
- **Límites métricos:** los declara `architecture.json` y los ejecuta `tool/check_limits.py`: 170 líneas
  por archivo, 40 por función, 6 parámetros posicionales y 3 niveles de anidamiento. Un `elif` cuenta
  como una rama más de la misma decisión, nunca como un nivel más.
- **Dirección de capas:** `model/` no importa nada del paquete; `render/` importa de `model/`;
  `pipeline/` importa de ambos. Verificado (`BRAND-LAYER-DIRECTION`).

---

## 7. Verificación, testing y aseguramiento de calidad

### 7.1 Matriz de verificadores mecánicos

| Verificador              | Comando                                      | Qué detecta                                                                                                            | Dónde vive la regla                           |
|:-------------------------|:---------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------|:----------------------------------------------|
| Artefactos de consumidor | `python3 -m pseudolearn_brand check`         | `BRAND-COPY-STALE`, `BRAND-TS-STALE`: una copia versionada que el motor ya no produce, o que desapareció               | `brand.json`                                  |
| Medidas redibujadas      | `python3 -m pseudolearn_brand check`         | `BRAND-DART-DRIFT`: una de las 26 medidas que la app redibuja dejó de coincidir con la geometría                       | `brand.json`, §4.8                            |
| Caras tipográficas       | `python3 -m pseudolearn_brand check`         | `BRAND-FONT-DRIFT`: la cara empaquetada aquí y la que empaqueta la app divergieron                                     | §4.2                                          |
| Pureza de la plantilla   | `python3 -m pseudolearn_brand check`         | `BRAND-TEMPLATE-GEOMETRY`: geometría escrita a mano dentro del documento de lineamientos                               | §4.9                                          |
| Coherencia del catálogo  | `python3 -m pseudolearn_brand check`         | `BRAND-CATALOG`: variante duplicada, composición desconocida, clave no declarada, inscripción fuera del círculo seguro | `brand.json`, §3.7                            |
| Capas y límites          | `python3 tool/check_limits.py`               | `BRAND-LAYER-*`, `BRAND-SIZE-*`, `BRAND-NO-COMMENTS`, `BRAND-FORBIDDEN-IMPORT`                                         | `architecture.json`                           |
| Tests                    | `python3 -m unittest discover -s test -t .`  | Regresiones de geometría, tipografía, composición, emisión y verificación                                              | `test/`                                       |
| Marca pegada en el sitio | `cd apps/fe-pseudolearn && pnpm check:brand` | `FE-BRAND-GENERATED`: geometría de marca escrita a mano en un componente en vez de importada                           | `apps/fe-pseudolearn/scripts/check-brand.mjs` |

El último vive en el sitio y no aquí a propósito: es el único que tiene que correr en un CI que no tiene
Python, y no necesita recalcular la geometría para hacer su trabajo —le basta con detectar que alguien
volvió a pegar un `d` largo dentro de `src/`—.

### 7.2 Estrategia de pruebas

- `test/` refleja la estructura de `pseudolearn_brand/`, más `test/tool/` para el verificador de límites
  (`TEST-MIRROR`). Cada carpeta lleva su `__init__.py`: no es ceremonia, es requisito de
  `unittest discover`, que en Python 3.9 solo importa el directorio de arranque y sus subcarpetas si son
  paquetes. Sin ellos la suite no arranca; por eso cada uno declara en una frase qué prueba la carpeta,
  igual que los del código declaran qué hace la capa.
- Cada pieza se prueba en camino feliz y camino infeliz, con casos límite explícitos: una ruta de cero
  giros, un texto vacío, un carácter que la cara no contiene, una cara que no existe, un lado de cero,
  un catálogo con una clave inventada (`TEST-BOTH-PATHS`).
- **Los verificadores se prueban con violaciones deliberadas.** `test/fixtures/broken_package/` es un
  paquete falso con un import que sube de capa, un import prohibido, un comentario, una función larga,
  demasiados parámetros y anidamiento de más; el test exige que cada una de esas seis reglas se dispare.
  `test/pipeline/test_artefacts.py` copia los tres artefactos de consumidor a un árbol temporal, los
  altera y exige el fallo correspondiente. Un verificador que nunca falla no verifica nada.

### 7.3 Señales de alerta al revisar

Un cambio se rechaza si:

- Añade una rama al motor que pregunta por el nombre de una variante en vez de leer un campo del catálogo.
- Edita un archivo de `out/` o un artefacto generado de consumidor en lugar de la geometría que lo produce.
- Pega geometría de la marca en un consumidor —un componente, una plantilla, un documento— en vez de
  importarla o generarla.
- Cambia una medida sin que este README cambie en el mismo commit (`DOC-README-TRUTH`).
- Hace que la marca dependa de un consumidor: cualquier ruta de este paquete hacia `apps/` que no sea un
  destino declarado en `brand.json`.

---

## 8. Fuentes consultadas y genealogía conceptual

- Apple Human Interface Guidelines, *App icons* (revisión del 8 de junio de 2026) — íconos por capas,
  lienzo de 1024 para iOS, iPadOS y macOS, ausencia de máscara en el activo, aspectos por defecto,
  oscuro, *clear* y *tinted*, y la advertencia contra trazos finos y ángulos agudos.
- Apple, *Creating your app icon using Icon Composer* — exportar capas en SVG con el texto y el trazo
  convertidos a contorno, nombres numerados de atrás hacia delante, máximo cuatro grupos, y sin fondo,
  degradado, desenfoque, sombra ni opacidad.
- Android Developers, *Adaptive icons* — lienzo de 108 dp, área visible de 72 dp y círculo seguro de
  66 dp.
- W3C, *Web Application Manifest* / `maskable` — círculo seguro del 80 % del lienzo.
- IBM Plex, SIL Open Font License 1.1 — permiso para empaquetar, para derivar contornos y para copiar las
  dos caras dentro de este paquete.

Ninguna de estas fuentes es normativa: fijan los requisitos mecánicos de cada plataforma, no las
decisiones de diseño, que están en §4 de este documento.
