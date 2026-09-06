# Fundamentos visuales de pseudolearn_app

Sistema de tokens de aspecto de la app: color, tipografía, espaciado, radios, elevación, iconografía,
movimiento, apilamiento, bordes y las medidas propias del editor, el ordinograma y la tabla de traza.
Cubre valores, nunca estructura de componente. Ningún widget, ninguna variante y ninguna composición de
pantalla se decide aquí.

Los tokens están implementados en `lib/presentation/theme/`; la sección 13 mapea cada tabla de este
documento a su archivo. Este documento es la fuente de verdad de los valores; el código es la fuente de
verdad de que esos valores se aplican.

## 0. Cómo se usa este documento

Crear un elemento de interfaz no requiere decidir nada de aspecto. Quien construye un botón, un campo,
una tarjeta o un panel no elige un color, un radio ni un espacio: los consulta aquí. Si una pregunta
razonable sobre aspecto no tiene respuesta en estas tablas, es un defecto de este documento y se corrige
aquí, no improvisando en el widget.

**Tres reglas de lectura.**

1. **Nada fuera de las escalas.** Un valor que no aparezca en una tabla de este documento no se usa. No
   hay «casi 12», no hay «un gris un poco más claro». Si hace falta un valor nuevo, se añade aquí con su
   razón.
2. **Los widgets consumen tokens semánticos, nunca primitivas.** La paleta primitiva es materia prima:
   solo la lee la capa de tokens semánticos. Un widget que menciona `blue-700` está saltándose el sistema
   aunque el color acabe siendo correcto.
3. **Nombres en inglés, prosa en español.** Los nombres de token son identificadores de Dart y siguen la
   regla de idioma del monorepo. Este documento los explica en español.

**Unidades.** Toda medida está en **unidades del lienzo de diseño** (`dp` lógicos del lienzo), no en
píxeles del dispositivo. El armazón aplica un único factor de escala uniforme al árbol completo, así que
un token de 16 vale 16 en el lienzo y 19.2 en pantalla cuando el factor es 1.2. Ninguna capa por debajo
del armazón conoce ese factor.

**Prohibiciones que atraviesan todas las secciones.** No existe en este sistema ni un gradiente, ni un
color de neón, ni morado o violeta como color de marca, ni superficie translúcida con desenfoque, ni un
emoji como valor o ejemplo de token, ni un radio completo aplicado por defecto, ni una sombra idéntica
repetida en todos los niveles. Cada una de estas ausencias es deliberada.

---

## 1. Color

### 1.1 De dónde sale esta paleta

Cuatro decisiones la determinan, en este orden.

**(a) El color carga significado, no decoración.** Esta app enseña un lenguaje. En la superficie
central —el editor— el color distingue categorías léxicas y severidades de diagnóstico. Un color
elegido por gusto en cualquier otra parte de la app compite con esos significados. Por eso la interfaz
neutra es realmente neutra: casi todo es tinta sobre papel, y el color aparece donde significa algo.

**(b) La paleta se construye en OKLCH y se publica en sRGB.** Cada escala se genera recorriendo una
rampa de luminosidad perceptual constante entre escalas, con la croma subiendo hacia el centro de la
rampa y bajando en los extremos. Consecuencia práctica: **el paso `-700` de cualquier escala tiene
aproximadamente el mismo peso visual que el `-700` de otra**, y por eso los estados de interacción se
derivan como «un paso más» en vez de como un porcentaje de opacidad improvisado. Los valores
hexadecimales de las tablas son el resultado de esa conversión con reducción de croma hasta entrar en
gamut sRGB; son la fuente de verdad, y el OKLCH es la explicación de cómo se obtuvieron.

**(c) El tono de marca se deriva por descarte, no por gusto.** Cuatro tonos están comprometidos con
significados que el usuario ya trae aprendidos: rojo para error, ámbar para advertencia, verde para
acierto, azul para información. Situados en el círculo de OKLCH (27°, 82°, 148°, 258°), el hueco angular
más grande que queda entre ellos —descontando el arco morado/violeta, prohibido— está centrado en **200°**: un azul
verdoso, teal. Ese es el tono de marca, y su justificación es geométrica y verificable,
no estética.

**(d) La marca se reconoce por croma y por papel, no por tono.** La escala `brand` tiene croma máxima
0.085, alrededor de la mitad que cualquier escala de acento (0.14–0.19). Es un color de tinta, no de
señal. La regla operativa que se desprende: **en el editor, la marca solo aparece como geometría**
—cursor, banda de línea en ejecución, selección, anillo de foco— y **nunca como color de un glifo**; el
color de glifo pertenece a la paleta de sintaxis.

**Descartado el color dinámico de Material 3.** Genera la paleta a partir del fondo de pantalla del
usuario. Es incompatible con que dos dispositivos de la misma clase se vean igual, y con que el
resaltado de sintaxis tenga contraste verificado: una paleta que cambia por dispositivo no se puede
verificar.

**Descartada la inversión automática para el modo oscuro.** El modo oscuro tiene su propio mapa
semántico, tabla por tabla. Una inversión mecánica produce texto blanco puro sobre negro puro —que
provoca halo en tipografía fina— y superficies elevadas más oscuras que su base, que es lo contrario de
lo que la elevación significa.

### 1.2 Paleta primitiva

Ocho escalas, en `tokens/color_primitives.dart`. La neutra tiene quince pasos porque las superficies del
modo oscuro necesitan resolución fina cerca del extremo inferior; las de acento tienen once.

**`neutral` — pizarra.** Tono 215°, croma entre 0.004 y 0.016. No es un gris puro: lleva una desviación
fría mínima que lo emparenta con la marca sin que se lea como color.

| token          | hex       | uso principal                                              |
|----------------|-----------|------------------------------------------------------------|
| `neutral-0`    | `#FFFFFF` | superficie del editor y de tarjeta en claro                |
| `neutral-25`   | `#F7FBFC` | texto sobre superficie invertida en claro                  |
| `neutral-50`   | `#F1F5F6` | lienzo de la app en claro · línea activa del editor        |
| `neutral-100`  | `#E6ECED` | superficie tenue en claro · texto primario en oscuro       |
| `neutral-200`  | `#D3DBDD` | borde por defecto en claro · identificador en oscuro       |
| `neutral-300`  | `#BBC5C7` | borde invertido en oscuro                                  |
| `neutral-400`  | `#A1ABAE` | texto secundario en oscuro                                 |
| `neutral-500`  | `#828F92` | borde fuerte en ambos modos · texto deshabilitado en claro |
| `neutral-600`  | `#657174` | texto terciario en claro · texto deshabilitado en oscuro   |
| `neutral-700`  | `#515D60` | texto secundario en claro                                  |
| `neutral-800`  | `#3D494C` | borde por defecto en oscuro                                |
| `neutral-850`  | `#2F3A3D` | superficie flotante y modal en oscuro                      |
| `neutral-900`  | `#222C2E` | texto primario en claro · superficie de tarjeta en oscuro  |
| `neutral-950`  | `#151D20` | lienzo de la app en oscuro                                 |
| `neutral-1000` | `#091113` | superficie del editor en oscuro · color base de sombra     |

**`brand` — teal 200°, croma máx. 0.085.** Acción, foco, selección, señalamiento del sistema.

| token       | hex       | | token       | hex       |
|-------------|-----------|-|-------------|-----------|
| `brand-50`  | `#EBF9FA` | | `brand-500` | `#4AA4A8` |
| `brand-100` | `#D7F1F2` | | `brand-600` | `#338C91` |
| `brand-200` | `#B9E4E6` | | `brand-700` | `#247378` |
| `brand-300` | `#95D1D4` | | `brand-800` | `#195C5F` |
| `brand-400` | `#6EBBBF` | | `brand-900` | `#0F4346` |
|             |           | | `brand-950` | `#072D2F` |

**`red` — 27°, croma máx. 0.190.** Error y acción destructiva.

| token     | hex       | | token     | hex       |
|-----------|-----------|-|-----------|-----------|
| `red-50`  | `#FFF3F1` | | `red-500` | `#F2594F` |
| `red-100` | `#FFE4E0` | | `red-600` | `#D5413B` |
| `red-200` | `#FFCCC5` | | `red-700` | `#B3312C` |
| `red-300` | `#FFACA2` | | `red-800` | `#902421` |
| `red-400` | `#FF8175` | | `red-900` | `#6C1815` |
|           |           | | `red-950` | `#4A0D0B` |

**`orange` — 55°, croma máx. 0.165.** Literales numéricos y lógicos en el editor.

| token        | hex       | | token        | hex       |
|--------------|-----------|-|--------------|-----------|
| `orange-50`  | `#FFF3EC` | | `orange-500` | `#DE7302` |
| `orange-100` | `#FFE6D5` | | `orange-600` | `#BD6102` |
| `orange-200` | `#FFCFAF` | | `orange-700` | `#9C4F01` |
| `orange-300` | `#FFB07A` | | `orange-800` | `#7D3E00` |
| `orange-400` | `#F29045` | | `orange-900` | `#5C2C00` |
|              |           | | `orange-950` | `#3F1C00` |

**`amber` — 82°, croma máx. 0.150.** Advertencia y capa procedimental.

| token       | hex       | | token       | hex       |
|-------------|-----------|-|-------------|-----------|
| `amber-50`  | `#FFF5E2` | | `amber-500` | `#BD8A03` |
| `amber-100` | `#FCE9C8` | | `amber-600` | `#A17501` |
| `amber-200` | `#F4D69F` | | `amber-700` | `#855F00` |
| `amber-300` | `#E8BE70` | | `amber-800` | `#6A4C01` |
| `amber-400` | `#D6A335` | | `amber-900` | `#4E3600` |
|             |           | | `amber-950` | `#342400` |

**`green` — 148°, croma máx. 0.140.** Confirmación y literales de texto.

| token       | hex       | | token       | hex       |
|-------------|-----------|-|-------------|-----------|
| `green-50`  | `#EBFBEC` | | `green-500` | `#4EAB60` |
| `green-100` | `#D8F4DB` | | `green-600` | `#37934B` |
| `green-200` | `#BAE8BF` | | `green-700` | `#28793B` |
| `green-300` | `#97D7A0` | | `green-800` | `#1D612D` |
| `green-400` | `#71C27E` | | `green-900` | `#12471F` |
|             |           | | `green-950` | `#092F12` |

**`blue` — 258°, croma máx. 0.165.** Información y capa estructurada.

| token      | hex       | | token      | hex       |
|------------|-----------|-|------------|-----------|
| `blue-50`  | `#F0F6FF` | | `blue-500` | `#4E92F7` |
| `blue-100` | `#E0ECFF` | | `blue-600` | `#397BDB` |
| `blue-200` | `#C4DCFF` | | `blue-700` | `#2A64B8` |
| `blue-300` | `#A1C7FF` | | `blue-800` | `#1F5095` |
| `blue-400` | `#76ADFF` | | `blue-900` | `#14396F` |
|            |           | | `blue-950` | `#0B264D` |

**`rose` — 352°, croma máx. 0.150.** Capa de orientación a objetos. El tono está en 352° y no en 330°
para que no derive hacia la ciruela: es un rosa vinoso, no un morado apagado.

| token      | hex       | | token      | hex       |
|------------|-----------|-|------------|-----------|
| `rose-50`  | `#FFF2F7` | | `rose-500` | `#D7699D` |
| `rose-100` | `#FFE2EE` | | `rose-600` | `#BC5386` |
| `rose-200` | `#FFC8DF` | | `rose-700` | `#9D416E` |
| `rose-300` | `#FBA8CC` | | `rose-800` | `#7E3258` |
| `rose-400` | `#EC86B5` | | `rose-900` | `#5E2340` |
|            |           | | `rose-950` | `#40152B` |

**Tintes tenues del modo oscuro.** No salen de las rampas: se generan aparte en OKLCH con L = 0.265 y
croma 0.048 sobre el tono de cada familia, porque el paso `-950` de una rampa de acento es demasiado
saturado para funcionar como fondo de un contenedor de mensaje.

| token              | hex       | tono |
|--------------------|-----------|------|
| `tint-red-dark`    | `#391B18` | 27°  |
| `tint-amber-dark`  | `#312305` | 82°  |
| `tint-blue-dark`   | `#16253C` | 258° |
| `tint-green-dark`  | `#132C17` | 148° |
| `tint-orange-dark` | `#371E0C` | 55°  |
| `tint-rose-dark`   | `#371B28` | 352° |

### 1.3 Tokens semánticos de superficie, texto y borde

Implementados en `tokens/color_semantic.dart` (`SurfaceColors`, `TextColors`, `BorderColors`). Cada
token tiene valor propio en cada modo; ninguno se deriva del otro por inversión.

| token                 | claro     | oscuro    | uso                                                                    | nota                                                                                                                                                                              |
|-----------------------|-----------|-----------|------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `surface.canvas`      | `#F1F5F6` | `#151D20` | fondo de pantalla, detrás de todo                                      | en claro es hueso, no blanco: reduce el deslumbramiento en una app de uso prolongado                                                                                              |
| `surface.default`     | `#FFFFFF` | `#222C2E` | tarjeta, panel, hoja de contenido                                      | en oscuro es **más claro** que el lienzo: la elevación se lee como superficie                                                                                                     |
| `surface.subtle`      | `#E6ECED` | `#091113` | pozo: cabecera de tabla, campo deshabilitado, fondo de código en línea | en oscuro es **más oscuro** que la tarjeta; hundido, no elevado                                                                                                                   |
| `surface.raised`      | `#FFFFFF` | `#2F3A3D` | menú, desplegable, emergente, autocompletado                           | en claro se distingue por sombra; en oscuro por superficie                                                                                                                        |
| `surface.overlay`     | `#FFFFFF` | `#2F3A3D` | diálogo, hoja inferior                                                 | mismo valor que `raised`, distinto nivel de sombra y de apilamiento                                                                                                               |
| `surface.editor`      | `#FFFFFF` | `#091113` | lienzo del editor de pseudocódigo                                      | es el papel: en claro el punto más brillante, en oscuro el más profundo                                                                                                           |
| `surface.inverse`     | `#222C2E` | `#E6ECED` | información de contraste alto sobre el contenido                       | reservado a la superficie de tooltip                                                                                                                                              |
| `surface.brandSubtle` | `#D7F1F2` | `#072D2F` | indicador de estado de marca, pestaña activa, chip seleccionado        | nunca como fondo de un bloque de texto largo                                                                                                                                      |
| `text.primary`        | `#222C2E` | `#E6ECED` | cuerpo, títulos, valores                                               | en oscuro **no es blanco puro**: evita el halo de la tipografía fina                                                                                                              |
| `text.secondary`      | `#515D60` | `#A1ABAE` | texto de apoyo, subtítulo, descripción                                 |                                                                                                                                                                                   |
| `text.tertiary`       | `#657174` | `#828F92` | metadatos, marcador de posición, texto de ayuda                        | piso de 4.5:1 sostenido también sobre `surface.canvas`                                                                                                                            |
| `text.disabled`       | `#828F92` | `#657174` | texto de un control inactivo                                           | queda en 3.04:1 y 3.39:1 — ver la nota de exención en la tabla de contrastes                                                                                                      |
| `text.onBrand`        | `#FFFFFF` | `#091113` | texto e íconos sobre relleno de marca                                  | en oscuro el relleno de marca es claro, así que el texto encima es oscuro                                                                                                         |
| `text.inverse`        | `#F7FBFC` | `#222C2E` | texto sobre `surface.inverse`                                          |                                                                                                                                                                                   |
| `text.link`           | `#247378` | `#95D1D4` | enlace dentro de un párrafo                                            | el subrayado es obligatorio: el color no puede ser el único indicio                                                                                                               |
| `border.subtle`       | `#E6ECED` | `#2F3A3D` | separador **dentro** de un contenedor                                  | decorativo, sin exigencia de contraste                                                                                                                                            |
| `border.default`      | `#D3DBDD` | `#3D494C` | contorno de una tarjeta o panel en reposo                              | decorativo: la tarjeta ya se distingue por superficie y sombra                                                                                                                    |
| `border.strong`       | `#828F92` | `#828F92` | contorno de un control operable: campo, casilla, selector              | ≥3:1 sobre toda superficie donde puede aparecer. Mismo valor en los dos modos: `neutral-500` es el único paso que satisface 3:1 tanto contra papel claro como contra papel oscuro |
| `border.focus`        | `#338C91` | `#6EBBBF` | anillo de foco                                                         | ver 9.2 para grosor y desplazamiento                                                                                                                                              |
| `border.inverse`      | `#515D60` | `#BBC5C7` | separador sobre superficie invertida                                   |                                                                                                                                                                                   |

### 1.4 Estados de interacción

**Regla de derivación, única para todo el sistema.** Un estado **no** es una opacidad aplicada al color
base. Un estado es **un paso de la escala primitiva en la dirección que aumenta el contraste con la
superficie que hay debajo**. Porque las rampas son de luminosidad perceptual regular, esa dirección
tiene una magnitud constante y comprobable:

| estado     | derivación en modo claro                    | derivación en modo oscuro                   | ΔL en OKLCH |
|------------|---------------------------------------------|---------------------------------------------|-------------|
| `default`  | paso base                                   | paso base                                   | —           |
| `hover`    | un paso **más oscuro**                      | un paso **más claro**                       | ±0.076      |
| `pressed`  | dos pasos **más oscuro**                    | dos pasos **más claro**                     | ±0.160      |
| `focus`    | relleno de `default` **más anillo**         | relleno de `default` **más anillo**         | 0           |
| `disabled` | tokens neutros propios, sin opacidad        | tokens neutros propios, sin opacidad        | —           |
| `selected` | `surface.brandSubtle` más indicador de 2 dp | `surface.brandSubtle` más indicador de 2 dp | —           |

Que `focus` no altere el relleno es intencional: un elemento puede estar enfocado y a la vez en `hover`,
y si los dos modificaran el relleno el resultado sería ambiguo. El foco vive en el anillo, que es un
canal libre.

Implementados en `tokens/color_semantic_actions.dart` (`ActionColors` y sus cuatro variantes).

**`action.primary` — acción principal, relleno sólido.**

| token                        | claro                     | ratio con `text.onBrand` | oscuro                    | ratio con `text.onBrand` |
|------------------------------|---------------------------|--------------------------|---------------------------|--------------------------|
| `action.primary.bg.default`  | `#247378` (`brand-700`)   | 5.53:1                   | `#6EBBBF` (`brand-400`)   | 8.65:1                   |
| `action.primary.bg.hover`    | `#195C5F` (`brand-800`)   | 7.67:1                   | `#95D1D4` (`brand-300`)   | 11.21:1                  |
| `action.primary.bg.pressed`  | `#0F4346` (`brand-900`)   | 10.99:1                  | `#B9E4E6` (`brand-200`)   | 13.90:1                  |
| `action.primary.bg.disabled` | `#D3DBDD` (`neutral-200`) | —                        | `#3D494C` (`neutral-800`) | —                        |
| `action.primary.fg.default`  | `#FFFFFF`                 | —                        | `#091113`                 | —                        |
| `action.primary.fg.disabled` | `#828F92` (`neutral-500`) | 2.15:1 sobre su relleno  | `#657174` (`neutral-600`) | 2.28:1 sobre su relleno  |

`brand-600` no puede ser el relleno por defecto: con texto blanco da 3.96:1 y no alcanza el piso de
4.5:1. Es el motivo por el que la acción principal arranca en `-700` y no en `-600`.

**`action.secondary` — acción de apoyo, contorno.**

| token                              | claro                       | oscuro                    | nota                                      |
|------------------------------------|-----------------------------|---------------------------|-------------------------------------------|
| `action.secondary.bg.default`      | `#FFFFFF`                   | `#222C2E`                 | igual a `surface.default`                 |
| `action.secondary.bg.hover`        | `#EBF9FA` (`brand-50`)      | `#072D2F` (`brand-950`)   | el relleno aparece; el contorno no cambia |
| `action.secondary.bg.pressed`      | `#D7F1F2` (`brand-100`)     | `#0F4346` (`brand-900`)   |                                           |
| `action.secondary.bg.disabled`     | `#F1F5F6` (`neutral-50`)    | `#151D20` (`neutral-950`) |                                           |
| `action.secondary.border.default`  | `#828F92` (`border.strong`) | `#828F92`                 | 3.34:1 y 4.29:1                           |
| `action.secondary.border.disabled` | `#D3DBDD`                   | `#3D494C`                 |                                           |
| `action.secondary.fg.default`      | `#247378` (`brand-700`)     | `#95D1D4` (`brand-300`)   | 5.53:1 y 8.41:1                           |
| `action.secondary.fg.disabled`     | `#828F92`                   | `#657174`                 |                                           |

**`action.tertiary` — acción de baja jerarquía, sin contorno.**

| token                         | claro                     | oscuro                    | nota                                                                   |
|-------------------------------|---------------------------|---------------------------|------------------------------------------------------------------------|
| `action.tertiary.bg.default`  | transparente              | transparente              |                                                                        |
| `action.tertiary.bg.hover`    | `#E6ECED` (`neutral-100`) | `#3D494C` (`neutral-800`) | capa neutra, no de marca: es la acción menos importante de la pantalla |
| `action.tertiary.bg.pressed`  | `#D3DBDD` (`neutral-200`) | `#515D60` (`neutral-700`) |                                                                        |
| `action.tertiary.fg.default`  | `#247378`                 | `#95D1D4`                 |                                                                        |
| `action.tertiary.fg.disabled` | `#828F92`                 | `#657174`                 |                                                                        |

**`action.destructive` — borrado y acciones irreversibles.**

| token                            | claro                 | ratio con blanco | oscuro                | ratio con `#091113` |
|----------------------------------|-----------------------|------------------|-----------------------|---------------------|
| `action.destructive.bg.default`  | `#B3312C` (`red-700`) | 6.19:1           | `#FF8175` (`red-400`) | 7.85:1              |
| `action.destructive.bg.hover`    | `#902421` (`red-800`) | 8.54:1           | `#FFACA2` (`red-300`) | 10.60:1             |
| `action.destructive.bg.pressed`  | `#6C1815` (`red-900`) | 11.80:1          | `#FFCCC5` (`red-200`) | 13.34:1             |
| `action.destructive.bg.disabled` | `#D3DBDD`             | —                | `#3D494C`             | —                   |
| `action.destructive.fg.default`  | `#FFFFFF`             |                  | `#091113`             |                     |

**Estado `error` de un control de entrada.** No es un estado de relleno sino de contorno y de mensaje:
`border` pasa a `severity.error.fg`, el grosor a 2 dp, y aparece un texto de apoyo con el token
`severity.error.fg`. El relleno del campo no se tiñe: un campo con fondo rojo es ilegible mientras se
escribe en él, que es exactamente cuando hay que leerlo.

**Prohibiciones de esta sección.** No existe `Color.withOpacity` aplicado a un color de acción para
fabricar un estado. No existe una capa de estado (*state layer*) con alfa sobre el relleno. No existe un
estado que solo cambie la opacidad del contenido. Los tres son la vía por la que un sistema pierde el
control del contraste sin que ningún verificador lo note.

### 1.5 Severidad de diagnóstico

El núcleo modela **cuatro** severidades —`error`, `warning`, `info`, `hint`— y la app expone las cuatro
tal como las produce el núcleo, sin colapsar `hint` sobre `info`: colapsar sería la app decidiendo sobre
el lenguaje, que no es su rol, y `hint` propone un cambio mientras `info` describe el programa —fundirlas
le quita al estudiante la señal que distingue ambas cosas.

`success` no es una severidad del núcleo: es un estado de interfaz —ejecución terminada correctamente— y
está aquí porque comparte forma con las otras, no porque el núcleo lo produzca. Ningún diagnóstico puede
tener severidad `success`.

Implementado en `tokens/color_semantic_severity.dart` (`SeverityColors`).

| severidad          | fg claro  | superficie clara | ratio  | fg oscuro | superficie oscura | ratio  | borde de contenedor           |
|--------------------|-----------|------------------|--------|-----------|-------------------|--------|-------------------------------|
| `severity.error`   | `#B3312C` | `#FFE4E0`        | 5.14:1 | `#FFACA2` | `#391B18`         | 8.69:1 | `red-600` / `red-500`         |
| `severity.warning` | `#6A4C01` | `#FCE9C8`        | 6.66:1 | `#E8BE70` | `#312305`         | 8.76:1 | `amber-600` / `amber-500`     |
| `severity.info`    | `#2A64B8` | `#E0ECFF`        | 4.87:1 | `#A1C7FF` | `#16253C`         | 8.89:1 | `blue-600` / `blue-500`       |
| `severity.hint`    | `#515D60` | `#E6ECED`        | 5.70:1 | `#A1ABAE` | `#2F3A3D`         | 4.99:1 | `neutral-600` / `neutral-500` |
| `severity.success` | `#28793B` | `#D8F4DB`        | 4.60:1 | `#97D7A0` | `#132C17`         | 8.96:1 | `green-600` / `green-500`     |

La versión `fg` es la saturada y sirve para texto, ícono, subrayado y barra de canal lateral. La versión
de superficie es la tenue y sirve de fondo de contenedor de mensaje y de fila en la lista de
diagnósticos. El paso de superficie clara es `-100` y no `-50` a propósito: sobre `surface.canvas`, un
`-50` da 1.01:1 y es literalmente invisible; el `-100` da 1.07–1.10:1, que ya se percibe como una franja.

**Regla de doble canal, obligatoria.** La severidad **nunca** se comunica solo con tono. Cada aparición
lleva al menos un canal no cromático:

| aparición                        | canal cromático          | canal no cromático obligatorio                                                                                                       |
|----------------------------------|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| subrayado en el editor           | `severity.*.fg`          | forma del trazo: error = onda continua, advertencia = onda discontinua (4/2), información = punteado (1/3), pista = punteado de 1 dp |
| marca en el canal lateral        | `severity.*.fg`          | glifo distinto por severidad, tamaño `icon-sm`                                                                                       |
| fila de la lista de diagnósticos | superficie tenue         | glifo de severidad más etiqueta textual de severidad                                                                                 |
| contenedor de mensaje            | superficie tenue y borde | glifo más título textual                                                                                                             |

Esto no es una concesión: es el requisito de que el color no sea el único medio de transmitir
información, y es lo que hace que el sistema siga funcionando cuando un tono de severidad coincide con
un tono de sintaxis, que es inevitable con seis tonos y once significados.

### 1.6 Resaltado de sintaxis

Implementado en `tokens/syntax_colors.dart` (`AppSyntaxColors`).

**Regla de asignación: el tono codifica la capa del lenguaje a la que pertenece la construcción, y nada
más.** No codifica la función gramatical. Por eso `Entero` y `Mientras` comparten color —ambas son
vocabulario de la capa estructurada— aunque una sea un tipo y la otra un control de flujo. Un aprendiz
que abre un programa ve de un vistazo cuánto del programa vive en cada capa, que es exactamente lo que
esta app enseña.

Excepción única y declarada: **los literales se pintan como dato, no como capa**. `Verdadero` es una
palabra reservada de la capa estructurada y aun así lleva color de literal, porque lo que el aprendiz
tiene que reconocer ahí es que es un valor escrito a mano.

| token                       | claro     | ratio sobre editor | oscuro    | ratio sobre editor | `TokenType` del núcleo que lo produce                                                                                                                                                                                                                                    |
|-----------------------------|-----------|--------------------|-----------|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `syntax.keyword.structured` | `#1F5095` | 7.96:1             | `#A1C7FF` | 11.01:1            | `algorithm`, `endAlgorithm`, `declare`, `typeConnector`, `dimension`, los cinco tipos primitivos, `read`, `write`, `withoutNewline`, `assignment`, `ifKeyword`…`endIf`, `switchKeyword`…`endSwitch`, `whileKeyword`…`endWhile`, `repeat`, `until`, `forKeyword`…`endFor` |
| `syntax.keyword.procedural` | `#6A4C01` | 7.93:1             | `#E8BE70` | 10.92:1            | `subroutine`, `endSubroutine`, `byReference`, `byValue`, `returnKeyword`                                                                                                                                                                                                 |
| `syntax.keyword.oop`        | `#7E3258` | 8.45:1             | `#FBA8CC` | 10.51:1            | `classKeyword`, `endClass`, `inheritsFrom`, `method`, `endMethod`, `constructor`, `publicVisibility`, `privateVisibility`, `newInstance`, `thisObject`, `superClass`                                                                                                     |
| `syntax.identifier`         | `#222C2E` | 14.31:1            | `#D3DBDD` | 13.57:1            | `identifier`                                                                                                                                                                                                                                                             |
| `syntax.literal.number`     | `#7D3E00` | 8.20:1             | `#FFB07A` | 10.66:1            | `integerLiteral`, `realLiteral`                                                                                                                                                                                                                                          |
| `syntax.literal.text`       | `#1D612D` | 7.50:1             | `#97D7A0` | 11.39:1            | `stringLiteral`, `characterLiteral`, `quote`                                                                                                                                                                                                                             |
| `syntax.literal.boolean`    | `#7D3E00` | 8.20:1             | `#FFB07A` | 10.66:1            | `booleanTrue`, `booleanFalse`                                                                                                                                                                                                                                            |
| `syntax.ink`                | `#515D60` | 6.81:1             | `#A1ABAE` | 8.13:1             | operadores aritméticos, relacionales y lógicos; `dot`; paréntesis, corchetes, `comma`, `semicolon`, `branchSeparator`                                                                                                                                                    |
| `syntax.comment`            | `#515D60` | 6.81:1             | `#A1ABAE` | 8.13:1             | ninguno hoy — el lexer del núcleo descarta los comentarios, ver nota abajo                                                                                                                                                                                               |
| `syntax.invalid`            | `#B3312C` | 6.19:1             | `#FFACA2` | 10.60:1            | tramo cubierto por un diagnóstico del lexer                                                                                                                                                                                                                              |

**Por qué el identificador es tinta y no color.** Los identificadores son las palabras que pone el
aprendiz. Dejarlas en el color de texto primario dice, sin decirlo, que el color señala el lenguaje y la
tinta señala lo propio. Es la decisión pedagógica más importante de esta paleta.

**Por qué operadores, signos de puntuación y comentarios comparten `syntax.ink`.** Un editor que atenúa
los signos convierte la precedencia en algo invisible justo cuando se está enseñando la precedencia. Y
un editor de enseñanza que atenúa los comentarios se contradice: el comentario es instrucción, no ruido.
Se distinguen entre sí por peso y estilo, no por color: operador en peso 600, comentario en cursiva,
puntuación en peso normal.

**`syntax.comment` no es alcanzable hoy.** El token está definido y verificado, pero el lexer del núcleo
descarta los comentarios: no hay `TokenType` de comentario y `LexerResult` solo devuelve tokens y
diagnósticos, así que la app no recibe ningún tramo que pintar. Reconocer el marcador de comentario con
una expresión regular en la app está prohibido por el verificador del paquete en `engine`, `application`
y `presentation`, porque reimplementaría léxico fuera del núcleo. Hasta que el núcleo exponga los tramos
de comentario, los comentarios se dibujan con `syntax.ink` y sin cursiva.

**Regla de contraste bajo fondos del editor.** Todo token de sintaxis mantiene ≥4.5:1 sobre **los cuatro
fondos** que puede tener una línea: papel, línea activa, selección y banda de ejecución. El peor caso
medido es 4.68:1, en `syntax.ink` sobre selección en modo oscuro. Ningún token de sintaxis puede añadirse
sin repetir esta comprobación contra los cuatro fondos.

| fondo de línea                 | claro     | oscuro    | perceptibilidad contra el papel |
|--------------------------------|-----------|-----------|---------------------------------|
| papel del editor               | `#FFFFFF` | `#091113` | —                               |
| línea activa (cursor)          | `#F1F5F6` | `#151D20` | 1.10:1 / 1.12:1                 |
| banda de ejecución paso a paso | `#EBF9FA` | `#072D2F` | 1.08:1 / 1.29:1                 |
| selección de texto             | `#D7F1F2` | `#0F4346` | 1.18:1 / 1.74:1                 |

Las tres bandas están ordenadas por intensidad y no se suman: si una línea es a la vez activa, en
ejecución y seleccionada, gana la selección, luego la ejecución, luego la activa. La banda de ejecución
lleva además una barra de 3 dp en `brand-600` / `brand-400` en el margen izquierdo, que es lo que
realmente la hace visible; el fondo solo la acompaña.

### 1.7 Contrastes verificados

Calculados sobre los valores hexadecimales publicados, con la fórmula de luminancia relativa de WCAG.
Piso exigido: **4.5:1 para texto**, **3:1 para texto grande y para límites de componente operable**.

| combinación                                          | ratio claro | ratio oscuro | piso | cumple                                                                       |
|------------------------------------------------------|-------------|--------------|------|------------------------------------------------------------------------------|
| `text.primary` sobre `surface.canvas`                | 13.03:1     | 14.31:1      | 4.5  | AAA                                                                          |
| `text.primary` sobre `surface.default`               | 14.31:1     | 11.98:1      | 4.5  | AAA                                                                          |
| `text.secondary` sobre `surface.canvas`              | 6.20:1      | 7.29:1       | 4.5  | AAA                                                                          |
| `text.secondary` sobre `surface.default`             | 6.81:1      | 6.10:1       | 4.5  | AAA                                                                          |
| `text.tertiary` sobre `surface.canvas`               | 4.59:1      | 5.12:1       | 4.5  | AA                                                                           |
| `text.tertiary` sobre `surface.default`              | 5.04:1      | 4.29:1       | 4.5  | AA en claro; en oscuro **`text.tertiary` no se usa sobre `surface.default`** |
| `text.disabled` sobre `surface.canvas`               | 3.04:1      | 3.39:1       | —    | exento                                                                       |
| `text.link` sobre `surface.default`                  | 5.53:1      | 8.41:1       | 4.5  | AAA                                                                          |
| `text.inverse` sobre `surface.inverse`               | 13.73:1     | 11.98:1      | 4.5  | AAA                                                                          |
| `border.strong` sobre `surface.default`              | 3.34:1      | 4.29:1       | 3.0  | AA                                                                           |
| `border.focus` sobre `surface.canvas`                | 3.61:1      | 7.75:1       | 3.0  | AA                                                                           |
| `border.focus` sobre `surface.default`               | 3.96:1      | 6.49:1       | 3.0  | AA                                                                           |
| `text.onBrand` sobre `action.primary.bg.default`     | 5.53:1      | 8.65:1       | 4.5  | AAA                                                                          |
| `text.onBrand` sobre `action.destructive.bg.default` | 6.19:1      | 7.85:1       | 4.5  | AAA                                                                          |
| peor token de sintaxis sobre el peor fondo de línea  | 5.23:1      | 4.68:1       | 4.5  | AA                                                                           |
| peor `severity.*.fg` sobre su superficie tenue       | 4.60:1      | 4.99:1       | 4.5  | AA                                                                           |

**Dos excepciones, ambas declaradas.**

`text.disabled` queda por debajo de 4.5:1 en los dos modos. Es la exención explícita de WCAG para
componentes inactivos, y aquí se acepta con una condición: **un control deshabilitado siempre lleva un
segundo indicio no cromático** —cursor no interactivo, ausencia de anillo de foco en el recorrido de
tabulación, y estado anunciado a la capa de accesibilidad. Un elemento cuya única señal de deshabilitado
sea el color es un defecto.

`border.default` y `border.subtle` están muy por debajo de 3:1 y eso es correcto: son separadores
decorativos. **Ningún límite de un control operable puede usarlos.** El límite de un control usa
`border.strong` o `border.focus`. Esta distinción es la razón por la que existen tres tokens de borde en
vez de uno.

### 1.8 Opacidades permitidas

Implementado en `tokens/color_semantic_severity.dart` (`OpacityMetrics`). La opacidad no es un mecanismo
de estado en este sistema —los estados son tokens de color— y por eso la escala es minúscula y cerrada.
Cualquier valor de alfa que no esté aquí es una violación.

| token                     | valor                    | uso                                            | nota                                                                       |
|---------------------------|--------------------------|------------------------------------------------|----------------------------------------------------------------------------|
| `opacity.scrim`           | 0.48 claro · 0.64 oscuro | velo bajo un modal, sobre `neutral-1000`       | en oscuro hace falta más alfa porque el contraste bajo el velo ya es menor |
| `opacity.dragGhost`       | 0.80                     | elemento mientras se arrastra                  |                                                                            |
| `opacity.canvasWatermark` | 0.06                     | trama del lienzo del ordinograma, si se dibuja | único uso decorativo autorizado                                            |

---

## 2. Tipografía

Implementada en `tokens/typography.dart` (`TypographyTokens`, `AppTextStyleSpec`, `AppTypography`).

### 2.1 Familias

Dos familias, del mismo superfamiliar, empaquetadas en `assets/fonts/` y declaradas en `pubspec.yaml` en
los pesos 400/500/600/700 (más itálica en 400). La decisión no es de gusto: es de **métrica compartida**.

| rol                                                   | familia           | por qué esta |
|-------------------------------------------------------|-------------------|--------------|
| `font.ui` — títulos, interfaz, cuerpo                 | **IBM Plex Sans** | ver abajo    |
| `font.code` — editor, código en línea, tabla de traza | **IBM Plex Mono** | ver abajo    |

**Por qué IBM Plex Mono para el código.** Dos razones concretas, ninguna estética.

La primera es que **no tiene ligaduras de programación**. En PseudoLearn eso no es una preferencia: es
una necesidad pedagógica. Una fuente con ligaduras convierte `<-` en una flecha de un solo trazo y `<=`
en un símbolo compuesto, y un aprendiz que está descubriendo que la asignación son dos caracteres ve en
pantalla algo que no puede teclear.

La segunda es la desambiguación de glifos confundibles —cero contra o mayúscula, uno contra ele minúscula
contra i mayúscula—, que en un editor donde los identificadores los inventa quien aprende determina si un
error de tecleo se ve o no se ve.

**Por qué IBM Plex Sans para todo lo demás.** Porque es la hermana de Plex Mono: mismas métricas
verticales, misma altura de x, mismo esqueleto. La app mezcla prosa y fragmentos de código
constantemente —la base de conocimiento, los mensajes de diagnóstico con nombres de variable dentro, la
tabla de traza— y con familias emparentadas un fragmento monoespaciado dentro de un párrafo se apoya en
la misma línea base sin compensación óptica.

Ambas están bajo licencia SIL Open Font License 1.1, que permite empaquetarlas en los activos —requisito
no negociable del paquete, porque la tipografía del sistema está prohibida—, y cubren completo el
repertorio necesario para español e inglés.

**No hay tercera familia para títulos.** Un display distinto añadiría un activo, un riesgo de
rasterización y una decisión más, a cambio de un carácter que esta app no necesita: no tiene superficie
de marketing. Los títulos son la misma familia en peso 700.

**Descartadas Inter, Poppins, Manrope y Plus Jakarta Sans.** Inter no tiene monoespaciada hermana, así
que el emparejamiento con el editor sería arbitrario justo donde más importa. Poppins es geométrica de
`a` de un piso: mala para leer prosa larga en español y con desambiguación pobre. Manrope y Plus Jakarta
Sans tampoco tienen monoespaciada del mismo diseño y su prueba de idioma es menor.

**Si un rol de fuente no está empaquetado.** `familyFor` devuelve `null` y Flutter usa la pila del
sistema declarada como respaldo (`SF Pro Text`/`Segoe UI`/`Roboto`/`Noto Sans` para `ui`; `SF
Mono`/`Cascadia Mono`/`Consolas`/`Roboto Mono`/`Noto Sans Mono` para `code`). Un verificador rechaza
declarar como empaquetada una familia que no esté en `pubspec.yaml` con sus ficheros en disco, porque esa
inconsistencia hace caer la app en la pila del sistema en silencio.

### 2.2 Escala tipográfica

Formato de cada celda: **tamaño / interlineado · peso · tracking**. Tamaño e interlineado en unidades del
lienzo; tracking en unidades del lienzo, positivo abre y negativo cierra.

| token          | familia | compact (lienzo 360) | medium (lienzo 600)  | expanded (lienzo 960) | para qué                                                                                   |
|----------------|---------|----------------------|----------------------|-----------------------|--------------------------------------------------------------------------------------------|
| `display`      | ui      | 30 / 36 · 700 · −0.3 | 32 / 38 · 700 · −0.3 | 32 / 38 · 700 · −0.3  | número grande de un estado vacío o de una portada de módulo. Uno por pantalla como mucho   |
| `heading-1`    | ui      | 24 / 30 · 700 · −0.2 | 25 / 32 · 700 · −0.2 | 22 / 28 · 700 · −0.2  | título de pantalla                                                                         |
| `heading-2`    | ui      | 20 / 26 · 600 · −0.1 | 21 / 28 · 600 · −0.1 | 19 / 25 · 600 · −0.1  | título de sección dentro de una pantalla; título de diálogo                                |
| `heading-3`    | ui      | 17 / 23 · 600 · 0    | 18 / 24 · 600 · 0    | 16 / 22 · 600 · 0     | título de tarjeta; cabecera de panel                                                       |
| `heading-4`    | ui      | 15 / 21 · 600 · +0.1 | 16 / 22 · 600 · +0.1 | 14 / 20 · 600 · +0.1  | subtítulo dentro de una tarjeta; agrupador de lista                                        |
| `body-large`   | ui      | 17 / 26 · 400 · 0    | 17 / 26 · 400 · 0    | 16 / 24 · 400 · 0     | párrafo de la base de conocimiento; texto de lectura sostenida                             |
| `body-default` | ui      | 15 / 23 · 400 · 0    | 15 / 23 · 400 · 0    | 14 / 21 · 400 · 0     | cuerpo por defecto de la interfaz; mensaje de diagnóstico                                  |
| `body-small`   | ui      | 13 / 20 · 400 · 0    | 13 / 20 · 400 · 0    | 13 / 19 · 400 · 0     | texto secundario, descripción bajo un título                                               |
| `label`        | ui      | 13 / 16 · 600 · +0.2 | 13 / 16 · 600 · +0.2 | 13 / 16 · 600 · +0.2  | etiqueta de campo, rótulo de botón, pestaña, destino de navegación                         |
| `caption`      | ui      | 12 / 16 · 400 · +0.2 | 12 / 16 · 400 · +0.2 | 12 / 16 · 400 · +0.2  | texto de ayuda, metadato, contador, mensaje de error de campo                              |
| `overline`     | ui      | 11 / 14 · 700 · +0.8 | 11 / 14 · 700 · +0.8 | 11 / 14 · 700 · +0.8  | antetítulo de sección, en versales. Prohibido para cualquier texto de más de tres palabras |
| `code-editor`  | code    | 14 / 22 · 400 · 0    | 14 / 22 · 400 · 0    | 13 / 21 · 400 · 0     | el editor de pseudocódigo                                                                  |
| `code-inline`  | code    | 14 / 23 · 400 · 0    | 14 / 23 · 400 · 0    | 13 / 21 · 400 · 0     | fragmento de código dentro de un párrafo                                                   |
| `code-caption` | code    | 12 / 18 · 400 · 0    | 12 / 18 · 400 · 0    | 12 / 18 · 400 · 0     | números de línea, celdas de la tabla de traza, valores en el ordinograma                   |

`code-inline` es un punto más pequeño que `body-default` porque a igual tamaño la monoespaciada se ve
más grande y rompe el color del párrafo. `label` y `caption` no cambian entre clases porque están atados
a controles cuyo tamaño tampoco cambia. Los tamaños de `expanded` son menores que los de `medium` porque
el factor de escala del lienzo ya es mayor ahí, y el tamaño efectivo en pantalla acaba siendo comparable:

| clase    | ventana de referencia | factor de escala | `body-default` efectivo | `code-editor` efectivo |
|----------|-----------------------|------------------|-------------------------|------------------------|
| compact  | 390 dp                | 1.083            | 16.3                    | 15.2                   |
| medium   | 834 dp                | 1.20 (tope)      | 18.0                    | 16.8                   |
| expanded | 1440 dp               | 1.20 (tope)      | 16.8                    | 15.6                   |

### 2.3 Escalado del sistema operativo y accesibilidad

| token                        | valor | uso                                                                                       |
|------------------------------|-------|-------------------------------------------------------------------------------------------|
| `text.scale.min`             | 0.85  | suelo del factor de escala de texto del sistema                                           |
| `text.scale.max`             | 2.00  | techo del factor de escala de texto del sistema                                           |
| `text.scale.reflowThreshold` | 1.30  | por encima de este factor, la región flexible declarada de la pantalla pasa a desplazarse |
| `editor.fontSize.min`        | 11    | tamaño mínimo del editor, en unidades de lienzo                                           |
| `editor.fontSize.max`        | 24    | tamaño máximo del editor                                                                  |
| `editor.fontSize.step`       | 1     | granularidad del ajuste                                                                   |

---

## 3. Espaciado y layout

Implementado en `tokens/spacing.dart` (`SpacingTokens`, `LayoutMetrics`, `ContentMeasure`).

### 3.1 Escala

Base de 4. **El número del token es el valor dividido por 4**, así que el nombre dice el valor y nadie
tiene que memorizar la tabla.

| token        | valor | regla de uso                                                                                                                         |
|--------------|-------|--------------------------------------------------------------------------------------------------------------------------------------|
| `space-half` | 2     | solo corrección óptica: alinear un ícono con la línea base de su rótulo, ajustar un trazo. Nunca como espacio de composición         |
| `space-1`    | 4     | dentro de un elemento indivisible: entre un ícono y su rótulo, entre un campo y su mensaje de error, relleno interno de un indicador |
| `space-2`    | 8     | entre partes de un mismo componente: etiqueta y campo, título y subtítulo. Relleno vertical de un control pequeño                    |
| `space-3`    | 12    | relleno horizontal de un control estándar. Entre elementos hermanos de una lista densa                                               |
| `space-4`    | 16    | relleno interior de una tarjeta o de un panel. Entre componentes de un mismo grupo. Margen lateral en `compact`                      |
| `space-5`    | 20    | relleno interior de una tarjeta en `expanded` cuando contiene otra tarjeta                                                           |
| `space-6`    | 24    | entre grupos de componentes dentro de una sección. Margen lateral en `medium`                                                        |
| `space-8`    | 32    | entre secciones de una pantalla                                                                                                      |
| `space-10`   | 40    | entre regiones mayores; separación superior de un bloque de acciones final                                                           |
| `space-12`   | 48    | separación entre regiones estructurales de la pantalla                                                                               |
| `space-16`   | 64    | respiración superior de un estado vacío                                                                                              |
| `space-20`   | 80    | ritmo vertical entre capítulos de la base de conocimiento                                                                            |

**Regla de proximidad, que es la que hace todo lo anterior verificable.** El espacio entre dos elementos
declara su relación, y la relación tiene que ser estrictamente creciente: dentro de un componente < entre
componentes de un grupo < entre grupos < entre secciones. Si en una pantalla el espacio entre dos
secciones es menor o igual que el espacio entre dos componentes de una de ellas, la pantalla está mal
compuesta aunque cada valor individual esté en la escala.

### 3.2 Layout: márgenes, riel de navegación y anchos máximos por contenido

`LayoutMetrics` es una clase por tamaño de dispositivo (`.compact()`, `.medium()`, `.expanded()`) que
agrupa el margen de pantalla, el escalado de densidad, el ancho del riel de navegación y los anchos
máximos de contenido:

| propiedad      | compact (< 600 dp) | medium (600–959 dp) | expanded (≥ 960 dp) |
|----------------|--------------------|---------------------|---------------------|
| `screenMargin` | 16                 | 24                  | 32                  |
| `densityScale` | 1.00               | 1.00                | 1.05                |
| `navWidth`     | 0 (barra inferior) | 80 (riel)           | 88 (riel)           |
| `cardColumns`  | 1                  | 2                   | 3                   |
| `readingMax`   | 680                | 680                 | 720                 |
| `formMax`      | 480                | 520                 | 560                 |
| `wideMax`      | 1080               | 1080                | 1440                |

`densityScale` multiplica el espaciado base en `expanded` para que una pantalla más grande no se lea
como la misma composición simplemente estirada; en `compact` y `medium` no se aplica.

**El contenido es fluido con techo, no de lienzo fijo.** Cada región de la pantalla declara qué contiene
—`ContentMeasure.reading` para un párrafo, `.form` para un formulario, `.wide` para una tabla o un panel
denso, `.full` para lo que debe ocupar todo el ancho disponible— y `LayoutMetrics.maxWidthFor(measure)`
devuelve el ancho máximo correspondiente a la clase actual. Por debajo de ese techo, la región ocupa el
ancho disponible menos los márgenes; por encima, se centra y el sobrante queda en blanco a los lados. Un
párrafo y una tabla no quieren el mismo ancho máximo, y esta distinción evita que cada pantalla resuelva
el suyo por accidente.

Esto reemplaza un diseño anterior de lienzo de ancho fijo con un único factor de escala uniforme por
clase: ese diseño entregaba un ancho de contenido que dependía linealmente del ancho de ventana dentro de
una misma clase, y en monitores de escritorio grandes llegaba a colapsar a cero. `LayoutMetrics` fija el
margen y la densidad por clase — independientes del ancho exacto de la ventana — y dejar que el
contenido fluya hasta su techo por tipo de región.

### 3.3 Objetivos táctiles y de puntero

| token                | valor | uso                                                                                                          | nota                                                                          |
|----------------------|-------|--------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `target.touch.min`   | 48    | área activa mínima de cualquier elemento interactivo en `compact` y `medium`                                 | satisface a la vez el mínimo de 44 de las guías de iOS y el de 48 de Material |
| `target.pointer.min` | 32    | área activa mínima en `expanded`                                                                             |                                                                               |
| `target.spacing.min` | 8     | separación mínima entre dos áreas activas adyacentes                                                         |                                                                               |
| `target.inline.min`  | 24    | excepción para un objetivo dentro de un renglón de texto —un enlace, una marca del canal lateral del editor— | es el mínimo de WCAG 2.5.8; por debajo no baja nunca                          |

**El área activa no es el tamaño visible.** Un ícono de 20 dentro de un botón de icono cumple con
`target.touch.min` porque el área activa se expande alrededor. La regla es sobre el área activa, y el
componente decide su tamaño visible dentro de ella.

---

## 4. Radios de borde

Implementado en `tokens/radii.dart` (`RadiusTokens`). Escala cerrada: nada fuera de esta tabla se usa en
ningún punto de la app.

| token         | valor | categoría de elemento                                                                                                              |
|---------------|-------|------------------------------------------------------------------------------------------------------------------------------------|
| `radius-none` | 0     | superficie del editor, celda de tabla, separador, franja a sangre, rombo de decisión del ordinograma                               |
| `radius-xs`   | 2     | indicador, distintivo, etiqueta de estado, marca del canal lateral del editor                                                      |
| `radius-sm`   | 4     | control pequeño: casilla, botón de icono de hasta 32, punta del anillo de progreso                                                 |
| `radius-md`   | 8     | control estándar: botón, campo de entrada, selector, elemento de menú, nodo de proceso del ordinograma                             |
| `radius-lg`   | 12    | contenedor: tarjeta, panel, emergente, menú, notificación, contenedor de mensaje de diagnóstico                                    |
| `radius-xl`   | 16    | contenedor de nivel de pantalla: diálogo, hoja inferior                                                                            |
| `radius-full` | 9999  | **solo elementos geométricamente circulares**: botón de radio, punto de estado, avatar, extremos del nodo terminal del ordinograma |

**Dos reglas de decisión.**

**El radio crece con el elemento.** Un radio pequeño en un contenedor grande parece un error de recorte;
uno grande en un control pequeño se come el contenido. La tabla ya codifica esa progresión: si alguien
duda entre dos filas, decide el tamaño del elemento, no su importancia.

**Anidamiento: el radio interior es el exterior menos el relleno, ajustado al paso más cercano de la
escala.** Una tarjeta de `radius-lg` con `space-4` de relleno contiene elementos de `radius-sm`
(12 − 16 → 0, ajustado al mínimo útil de 4). Un radio interior mayor o igual que el exterior produce el
efecto de esquina desalineada que delata un sistema sin regla.

**`radius-full` está prohibido por defecto.** No existe ningún botón en forma de pastilla en esta app. Si
un elemento nuevo quiere `radius-full`, tiene que ser circular por geometría, no por moda.

**Una sola excepción a la escala cerrada: la placa de la marca**, cuya esquina mide el 22.37 % del lado.
No es un contenedor de interfaz: es el ícono de aplicación reproducido dentro de la app, y esa fracción
es la esquina continua que el sistema operativo dibuja en la pantalla de inicio. Ajustarla al paso más
cercano de la tabla rompería el parecido con el objeto que la persona ya reconoce, que es justamente la
mitad de la señal que la placa aporta. La excepción no se hereda: nada que no sea la placa la usa.

---

## 5. Elevación y profundidad

Implementado en `tokens/elevation.dart` (`AppElevation`). **En claro la elevación es sombra. En oscuro es
superficie.** Una sombra sobre un fondo oscuro casi no se ve, así que en modo oscuro el nivel se comunica
subiendo el paso de superficie, y la sombra queda solo como refuerzo en los dos niveles más altos, para
separarlos del velo.

Los cuatro niveles tienen **desenfoque, desplazamiento y opacidad distintos**: una sombra idéntica
repetida en todo elimina la información que la sombra debía dar.

| token         | sombra en modo claro                                             | superficie y sombra en modo oscuro                                                  | qué elemento                                                                                     |
|---------------|------------------------------------------------------------------|-------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `elevation-0` | ninguna                                                          | `surface.canvas` / `surface.editor`, sin sombra                                     | contenido base, lienzo del editor, fondo de pantalla                                             |
| `elevation-1` | `0 1 2 0 rgba(9,17,19,0.06)` + `0 1 3 -1 rgba(9,17,19,0.05)`     | superficie `neutral-900`, sin sombra                                                | tarjeta en reposo, contenedor de mensaje, cabecera fija de una tabla                             |
| `elevation-2` | `0 2 4 -1 rgba(9,17,19,0.07)` + `0 4 6 -2 rgba(9,17,19,0.05)`    | superficie `neutral-900` más borde superior `border.subtle`                         | tarjeta bajo el puntero o arrastrándose; barra de navegación cuando el contenido pasa por debajo |
| `elevation-3` | `0 4 8 -2 rgba(9,17,19,0.09)` + `0 10 16 -4 rgba(9,17,19,0.07)`  | superficie `neutral-850` más `0 4 8 -2 rgba(0,0,0,0.40)`                            | menú, desplegable, emergente, autocompletado del editor, tooltip, notificación                   |
| `elevation-4` | `0 8 16 -4 rgba(9,17,19,0.12)` + `0 20 32 -8 rgba(9,17,19,0.10)` | superficie `neutral-850` más `0 12 24 -6 rgba(0,0,0,0.55)` y borde `border.default` | diálogo, hoja inferior, cualquier cosa que vaya acompañada de velo                               |

El color de sombra en modo claro es `neutral-1000` (`#091113`), no negro puro: comparte el tono frío de
la escala neutra y la sombra no se lee como una mancha ajena a la paleta. En modo oscuro sí es negro
puro, porque ahí la sombra funciona por sustracción de luz y cualquier tono la ensucia.

**Cada nivel es un salto de dos escalones en desenfoque, no de uno.** 2 → 4 → 8 → 16 en el desplazamiento
principal. Un sistema con niveles demasiado próximos obliga a comparar dos sombras para saber qué está
encima, que es exactamente lo que la elevación tenía que resolver de un vistazo.

---

## 6. Iconografía

Implementado en `tokens/icon_metrics.dart` (`IconMetricsTokens`).

### 6.1 Tamaños

| token     | valor | uso                                                                                                                   |
|-----------|-------|-----------------------------------------------------------------------------------------------------------------------|
| `icon-xs` | 16    | ícono dentro de `caption` o `code-caption`; marca del canal lateral del editor; adorno de un indicador                |
| `icon-sm` | 20    | ícono junto a `body-default`, `body-small` o `label`; ícono dentro de un botón estándar; ícono de un elemento de menú |
| `icon-md` | 24    | destino de navegación; ícono de una acción de barra superior; ícono de un botón de icono independiente                |
| `icon-lg` | 32    | ícono principal de un diálogo o de un contenedor de mensaje grande                                                    |
| `icon-xl` | 40    | ilustración de un estado vacío                                                                                        |

**Regla de emparejamiento, que es la que garantiza la proporción entre clases.** El tamaño del ícono que
acompaña a un texto es `redondeo(tamaño de fuente × 1.30)` ajustado al paso más cercano de la escala.
Como la escala tipográfica ya está definida por clase, el ícono queda determinado por clase sin ninguna
decisión adicional:

| token de texto                | compact        | medium         | expanded       |
|-------------------------------|----------------|----------------|----------------|
| `caption` (12)                | `icon-xs` (16) | `icon-xs` (16) | `icon-xs` (16) |
| `label` (13)                  | `icon-xs` (16) | `icon-xs` (16) | `icon-xs` (16) |
| `body-small` (13)             | `icon-xs` (16) | `icon-xs` (16) | `icon-xs` (16) |
| `body-default` (15 / 15 / 14) | `icon-sm` (20) | `icon-sm` (20) | `icon-sm` (20) |
| `body-large` (17 / 17 / 16)   | `icon-md` (24) | `icon-md` (24) | `icon-sm` (20) |
| `heading-3` (17 / 18 / 16)    | `icon-md` (24) | `icon-md` (24) | `icon-sm` (20) |
| destino de navegación         | `icon-md` (24) | `icon-md` (24) | `icon-md` (24) |

El destino de navegación es la única excepción a la regla del 1.30 y está fijado en `icon-md` en las tres
clases: es un objetivo táctil primario, y su tamaño lo manda el dedo, no el rótulo.

### 6.2 Construcción

| propiedad                   | valor               | nota                                                                                                      |
|-----------------------------|---------------------|-----------------------------------------------------------------------------------------------------------|
| rejilla de dibujo           | 24 × 24             | todo ícono se dibuja aquí y se escala; a 16 se redibuja en rejilla de 16 si el trazo escalado baja de 1.0 |
| `icon.stroke.default`       | 1.5                 | a tamaños 20 y 24                                                                                         |
| `icon.stroke.small`         | 1.25                | a tamaño 16                                                                                               |
| `icon.stroke.large`         | 2.0                 | a tamaños 32 y 40                                                                                         |
| terminación de trazo        | redonda             |                                                                                                           |
| unión de trazo              | redonda             |                                                                                                           |
| radio de esquina del dibujo | 2 en rejilla de 24  | coincide con `radius-xs`: el ícono y el indicador que lo contiene comparten el mismo lenguaje de esquina  |
| ángulos permitidos          | 0°, 45°, 90°        | ninguna diagonal libre                                                                                    |
| relleno                     | ninguno por defecto | el estilo del set es de trazo; el relleno se reserva a los glifos de severidad, que deben leerse a 16     |

**Regla de consistencia, aplicable también a lo vendorizado.** Un ícono de terceros que no cumpla rejilla,
grosor y radio de esquina **se redibuja o no se usa**. Un set mezclado se reconoce de inmediato y es el
defecto visual más caro de arreglar después, porque para entonces está en cincuenta sitios.

**El símbolo de la marca no pertenece a este set y no cuenta como ícono.** Tiene rejilla propia de 96,
grosor 14 y contornos rellenos en vez de trazo, así que ninguna fila de la tabla de tamaños le aplica y
la regla de emparejamiento con el texto tampoco. En consecuencia no sustituye a un `Icon` en ningún
sitio: ni destino de navegación, ni ilustración de estado vacío, ni ícono de botón. Las superficies
donde sí aparece, y por qué solo esas, están en el `README.md` del paquete.

### 6.3 Color de ícono

Un ícono nunca lleva un valor de color propio. Toma uno de estos tokens, según el contexto:

| contexto                                          | token                            | nota                                                    |
|---------------------------------------------------|----------------------------------|---------------------------------------------------------|
| ícono de interfaz, jerarquía normal               | `text.secondary`                 | el caso por defecto                                     |
| ícono de interfaz que acompaña a texto primario   | `text.primary`                   | cuando el ícono es parte del significado, no un adorno  |
| ícono en un control deshabilitado                 | `text.disabled`                  | siempre con el segundo indicio no cromático del control |
| ícono sobre relleno de marca o destructivo        | `text.onBrand`                   |                                                         |
| ícono dentro de una acción secundaria o terciaria | el `fg` del estado de esa acción | sigue el estado del control, no un token fijo           |
| ícono de severidad                                | `severity.*.fg`                  | acompañado siempre de glifo distinto por severidad      |
| ícono de destino de navegación activo             | `text.link`                      | inactivo: `text.secondary`                              |
| ícono decorativo del lienzo del ordinograma       | `border.strong`                  |                                                         |

---

## 7. Movimiento

Implementado en `tokens/motion.dart` (`MotionTokens`, `MotionSpeed`).

### 7.1 Duraciones

| token            | valor  | qué transición                                                                                       | curva                                    |
|------------------|--------|------------------------------------------------------------------------------------------------------|------------------------------------------|
| `motion.instant` | 0 ms   | cambio que no debe percibirse como animación: reordenar, aplicar un filtro                           | —                                        |
| `motion.step`    | 90 ms  | desplazamiento del resalte de ejecución paso a paso, en el editor y en el ordinograma                | `ease.standard`                          |
| `motion.fast`    | 120 ms | cambio de estado de un control: hover, pulsación, aparición del anillo de foco, marca de una casilla | `ease.standard`                          |
| `motion.default` | 180 ms | despliegue y plegado en el sitio, indicador de pestaña, revelado en línea                            | `ease.standard`                          |
| `motion.panel`   | 240 ms | entrada y salida de panel, menú, emergente, tooltip, notificación                                    | entrada `ease.enter`, salida `ease.exit` |
| `motion.screen`  | 300 ms | transición entre pantallas, hoja inferior, diálogo                                                   | entrada `ease.enter`, salida `ease.exit` |

`motion.tooltipWait` (500 ms) no es una animación: es la espera antes de mostrar una ayuda contextual, el
tiempo que se le concede al puntero para pasar de largo.

**Regla de asimetría.** La entrada usa `ease.enter` con la duración de su token; la salida usa
`ease.exit` con **el token inmediatamente más rápido**. Un elemento tarda más en llegar que en irse,
porque a la llegada hay que seguirlo con la vista y a la salida no.

`motion.step` es deliberadamente más corto que `motion.fast`: la ejecución paso a paso puede disparar
muchos pasos seguidos y una animación que no termine antes del paso siguiente convierte la ejecución en
un borrón. Nunca se encola: si llega un paso con el anterior en curso, el anterior salta a su destino.

### 7.2 Curvas

| token           | definición                             | Flutter                         | uso                                     |
|-----------------|----------------------------------------|---------------------------------|-----------------------------------------|
| `ease.standard` | `cubic-bezier(0.20, 0.00, 0.00, 1.00)` | `Cubic(0.20, 0.00, 0.00, 1.00)` | todo lo que empieza y acaba en pantalla |
| `ease.enter`    | `cubic-bezier(0.05, 0.70, 0.10, 1.00)` | `Cubic(0.05, 0.70, 0.10, 1.00)` | lo que entra: desacelera al llegar      |
| `ease.exit`     | `cubic-bezier(0.30, 0.00, 0.80, 0.15)` | `Cubic(0.30, 0.00, 0.80, 0.15)` | lo que sale: acelera al irse            |
| `ease.linear`   | lineal                                 | `Curves.linear`                 | **solo** indicadores de progreso        |

### 7.3 Movimiento reducido

Cuando el sistema operativo pide movimiento reducido:

| token            | comportamiento con movimiento reducido                                                                                 |
|------------------|------------------------------------------------------------------------------------------------------------------------|
| `motion.instant` | sin cambio                                                                                                             |
| `motion.step`    | **0 ms**: el resalte salta a la línea de destino                                                                       |
| `motion.fast`    | **120 ms, sin cambio**: son transiciones de color y de opacidad, no de posición, y son las que hacen legible el estado |
| `motion.default` | 100 ms, solo opacidad; sin cambio de altura ni de escala                                                               |
| `motion.panel`   | 100 ms, solo opacidad; sin desplazamiento ni escala                                                                    |
| `motion.screen`  | 100 ms, fundido cruzado de opacidad; sin deslizamiento lateral                                                         |

**Dos reglas que no dependen del ajuste del sistema.** Nada que aparece o desaparece baja de 100 ms: una
aparición instantánea desorienta más que un movimiento corto, y por eso movimiento reducido no significa
duración cero salvo para lo que solo se desplaza. Y no existe en esta app **ninguna animación decorativa
en bucle** —nada que lata, respire o brille— con ajuste del sistema o sin él; los indicadores de progreso
indeterminado se mantienen porque transmiten información.

---

## 8. Capas de apilamiento

Implementado en `tokens/layers.dart` (`LayerTokens`). Escala cerrada. El valor numérico existe para
razonar y para ordenar; el mecanismo de Flutter que le corresponde está en la última columna, porque
Flutter no tiene `z-index` y confundir el nivel con la técnica es la vía más rápida a un panel que tapa
lo que no debía.

| token                | valor | qué vive aquí                                                                          | mecanismo                                                                                     |
|----------------------|-------|----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `layer.base`         | 0     | contenido de la pantalla, editor, ordinograma, tabla de traza                          | orden natural del árbol                                                                       |
| `layer.sticky`       | 100   | cabecera fija de sección, cabecera fija de la tabla de traza, canal lateral del editor | `Stack` dentro de la página                                                                   |
| `layer.chrome`       | 200   | barra inferior de navegación, riel, barra superior                                     | armazón adaptativo                                                                            |
| `layer.floating`     | 300   | menú, desplegable, autocompletado del editor, emergente, franja de comandos desplegada | entrada de `Overlay`                                                                          |
| `layer.scrim`        | 400   | velo bajo un elemento modal                                                            | ruta modal                                                                                    |
| `layer.modal`        | 500   | diálogo, hoja inferior                                                                 | ruta modal, por encima de su propio velo                                                      |
| `layer.tooltip`      | 600   | tooltip                                                                                | entrada de `Overlay`, por encima de lo modal: un tooltip dentro de un diálogo tiene que verse |
| `layer.notification` | 700   | notificación efímera, aviso de guardado                                                | entrada de `Overlay` de la raíz                                                               |
| `layer.debug`        | 900   | superposición de diagnóstico de desarrollo                                             | nunca activa en una compilación de publicación                                                |

Dos consecuencias que resuelven las dudas habituales sin discusión: **el tooltip está por encima del
modal**, porque un control dentro de un diálogo también necesita explicarse; y **la notificación está
por encima del tooltip**, porque informa de algo que ocurrió y no puede quedar oculta por algo que solo
describe.

---

## 9. Bordes, trazos y foco

Implementado en `tokens/border_metrics.dart` (`BorderMetricsTokens`).

### 9.1 Grosores

| token                   | valor | uso                                                                                                                              |
|-------------------------|-------|----------------------------------------------------------------------------------------------------------------------------------|
| `border.width.hairline` | 1     | separador, contorno de tarjeta, contorno de control en reposo                                                                    |
| `border.width.emphasis` | 2     | contorno de control en estado de error o seleccionado; anillo de foco                                                            |
| `border.width.channel`  | 3     | barra de canal lateral: línea en ejecución, acento de capa de un nodo del ordinograma, borde inicial de un contenedor de mensaje |

### 9.2 Foco

El foco es el único estado que el sistema garantiza visible en **todos** los controles, incluidos los que
no tienen relleno.

| token               | valor                                              | nota                                                                                    |
|---------------------|----------------------------------------------------|-----------------------------------------------------------------------------------------|
| `focus.ring.width`  | 2                                                  | `border.width.emphasis`                                                                 |
| `focus.ring.offset` | 2                                                  | separación entre el borde del elemento y el anillo                                      |
| `focus.ring.color`  | `border.focus`: `#338C91` claro · `#6EBBBF` oscuro | 3.61:1 y 7.75:1 sobre el lienzo; 3.96:1 y 6.49:1 sobre tarjeta                          |
| `focus.ring.radius` | radio del elemento + `focus.ring.offset`           | un anillo concéntrico con el elemento, nunca un rectángulo alrededor de algo redondeado |

**Reglas.** El anillo **no sustituye** al estado de hover ni al de pulsación: se dibuja encima y
coexiste. El anillo **no se suprime nunca** para elementos que reciben foco con teclado. Un elemento que
solo se puede activar con puntero y que por tanto no aparece en el recorrido de tabulación es un defecto
de accesibilidad, no un caso donde el anillo sobre.

### 9.3 Separadores

| caso                                                         | token                  | inserción lateral                         |
|--------------------------------------------------------------|------------------------|-------------------------------------------|
| separador entre elementos de una lista dentro de una tarjeta | `border.subtle`, 1 dp  | igual al relleno horizontal de la tarjeta |
| separador entre secciones de una pantalla                    | `border.default`, 1 dp | a sangre, sin inserción                   |
| separador entre paneles en `expanded`                        | `border.default`, 1 dp | a sangre, en el centro del medianil de 16 |

---

## 10. Tokens del editor de pseudocódigo

Implementado en `tokens/editor_metrics.dart` (`EditorMetricsTokens`, `EditorColors`). El editor es la
superficie central de la app y la que más medidas repetidas produciría si no estuvieran aquí.

| token                              | compact               | medium    | expanded  | uso                                                                                       |
|------------------------------------|-----------------------|-----------|-----------|-------------------------------------------------------------------------------------------|
| `editor.gutter.width`              | 48                    | 48        | 48        | canal de números de línea, para hasta cuatro dígitos                                      |
| `editor.gutter.widthPerExtraDigit` | 8                     | 8         | 8         | incremento a partir del quinto dígito                                                     |
| `editor.gutter.padding`            | 8                     | 8         | 8         | relleno a cada lado del número de línea                                                   |
| `editor.content.paddingLeft`       | 12                    | 12        | 12        | separación entre el canal y el primer carácter                                            |
| `editor.content.paddingTop`        | 8                     | 8         | 8         |                                                                                           |
| `editor.line.height`               | 22                    | 22        | 21        | igual al interlineado de `code-editor`; el resalte de línea ocupa exactamente esta altura |
| `editor.caret.width`               | 2                     | 2         | 2         | color `brand-600` / `brand-400`                                                           |
| `editor.caret.blinkPeriod`         | 1000 ms               | 1000 ms   | 1000 ms   | 500 encendido, 500 apagado; con movimiento reducido, cursor fijo sin parpadeo             |
| `editor.indent.columns`            | 4                     | 4         | 4         | columnas por nivel de indentación                                                         |
| `editor.indent.guide`              | 1 dp, `border.subtle` | igual     | igual     | una guía por nivel                                                                        |
| `editor.squiggle.stroke`           | 1.5                   | 1.5       | 1.5       |                                                                                           |
| `editor.squiggle.amplitude`        | 1.5                   | 1.5       | 1.5       |                                                                                           |
| `editor.squiggle.wavelength`       | 6                     | 6         | 6         |                                                                                           |
| `editor.marker.width`              | 3                     | 3         | 3         | barra de canal lateral, `border.width.channel`                                            |
| `editor.marker.icon`               | `icon-xs`             | `icon-xs` | `icon-xs` | glifo de severidad en el canal                                                            |

| token                      | claro                  | oscuro    | uso                                                                                                                          |
|----------------------------|------------------------|-----------|------------------------------------------------------------------------------------------------------------------------------|
| `editor.surface`           | `#FFFFFF`              | `#091113` | papel                                                                                                                        |
| `editor.gutter.surface`    | `#F1F5F6`              | `#091113` | en oscuro el canal no se separa por color, sino por el separador de 1 dp                                                     |
| `editor.gutter.text`       | `#828F92`              | `#657174` | número de línea en reposo                                                                                                    |
| `editor.gutter.textActive` | `#222C2E`              | `#E6ECED` | número de la línea del cursor                                                                                                |
| `editor.line.active`       | `#F1F5F6`              | `#151D20` | línea del cursor                                                                                                             |
| `editor.line.execution`    | `#EBF9FA`              | `#072D2F` | línea que el intérprete está ejecutando, con barra de 3 dp en `brand-600` / `brand-400`                                      |
| `editor.selection`         | `#D7F1F2`              | `#0F4346` | selección de texto, color sólido y no alfa: el fondo del editor es uniforme y un color sólido permite verificar el contraste |
| `editor.bracket.match`     | `border.strong` a 1 dp | igual     | recuadro sobre el par de delimitadores correspondiente                                                                       |

**Prioridad de fondos de línea**, de mayor a menor: selección, ejecución, línea activa. No se suman ni se
mezclan por alfa. Es lo que permite que la tabla de contrastes de la sección de sintaxis sea exhaustiva
con cuatro fondos y no con todas sus combinaciones.

**Ausencia de contorno de formulario.** El lienzo del editor de pseudocódigo no es un campo de
formulario y carece de contorno (`InputBorder.none` en todos los estados del input). El foco no se
encierra en una caja: se expresa exclusivamente mediante el fondo de la línea activa (`editor.line.active`)
y la presencia del cursor (`editor.caret`).

---

## 11. Tokens del ordinograma y de la tabla de traza

Implementado en `tokens/editor_metrics.dart`. Ambas superficies se dibujan con `CustomPainter`, que es
donde un sistema visual se rompe primero porque no hay widget que imponga un valor.

### 11.1 Ordinograma

| token                       | valor                                                                 | uso                                                                                 |
|-----------------------------|-----------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| `flow.node.width`           | 200                                                                   | ancho estándar de nodo                                                              |
| `flow.node.minHeight`       | 48                                                                    | coincide con `target.touch.min`: un nodo es tocable                                 |
| `flow.node.padding`         | 12                                                                    | `space-3`                                                                           |
| `flow.node.gapVertical`     | 24                                                                    | `space-6`, entre nodos consecutivos                                                 |
| `flow.node.gapHorizontal`   | 32                                                                    | `space-8`, entre ramas de una decisión                                              |
| `flow.node.radius.process`  | `radius-md`                                                           | nodo de proceso y de llamada                                                        |
| `flow.node.radius.decision` | `radius-none`                                                         | rombo                                                                               |
| `flow.node.radius.io`       | `radius-none`                                                         | paralelogramo de entrada y salida                                                   |
| `flow.node.radius.terminal` | `radius-full`                                                         | inicio y fin                                                                        |
| `flow.node.surface`         | `surface.default`                                                     |                                                                                     |
| `flow.node.border`          | `border.strong`, 1 dp                                                 |                                                                                     |
| `flow.node.label`           | `body-small`                                                          |                                                                                     |
| `flow.node.value`           | `code-caption`                                                        | fragmento de pseudocódigo dentro del nodo                                           |
| `flow.node.layerAccent`     | 3 dp en `syntax.keyword.*` de la capa del nodo                        | ata el ordinograma a los colores del editor: un nodo de método lleva el rosa de POO |
| `flow.connector.stroke`     | 1.5                                                                   | `border.strong`                                                                     |
| `flow.connector.arrow`      | 8 de largo, 6 de ancho                                                |                                                                                     |
| `flow.connector.label`      | `caption`                                                             | rótulos de rama, verdadero y falso                                                  |
| `flow.execution.active`     | fondo `editor.line.execution`, borde `brand-600` / `brand-400` a 2 dp | mismo lenguaje que la banda del editor                                              |

### 11.2 Tabla de prueba de escritorio

| token                   | compact                                            | medium | expanded | uso                                                                                  |
|-------------------------|----------------------------------------------------|--------|----------|--------------------------------------------------------------------------------------|
| `trace.row.height`      | 40                                                 | 36     | 32       | en `compact` la fila es también objetivo táctil                                      |
| `trace.cell.paddingX`   | 12                                                 | 12     | 12       | `space-3`                                                                            |
| `trace.cell.paddingY`   | 8                                                  | 8      | 8        | `space-2`                                                                            |
| `trace.column.minWidth` | 88                                                 | 88     | 88       |                                                                                      |
| `trace.header.height`   | 40                                                 | igual  | igual    | fija en `layer.sticky`                                                               |
| `trace.header.text`     | `label`                                            | igual  | igual    |                                                                                      |
| `trace.cell.text`       | `code-caption` con cifras tabulares                | igual  | igual    | los valores son datos del programa: van en monoespaciada                             |
| `trace.identity.badge`  | `radius-xs`, `surface.brandSubtle`, `code-caption` | igual  | igual    | identidad de objeto, que el núcleo incluye en su instantánea y que la app no colapsa |

Las columnas de paso, línea, ámbito y variable tienen ancho fijo propio (`traceStepColumnWidth` 64,
`traceLineColumnWidth` 56, `traceScopeColumnWidth` 96, `traceVariableColumnWidth` 136); el resto de
columnas usa `trace.column.minWidth`.

---

## 12. Botón — color aquí, estructura en el archivo de métricas

`action.primary`, `action.secondary`, `action.tertiary` y `action.destructive` (sección 1.4) son mapas
semánticos de color; el botón los consume sin que este documento necesite saber que existe un botón. Los
dos únicos valores geométricos que ninguna escala general cubre —`buttonMinWidth` (64) y
`buttonIconOnlyMinSize` (32)— viven en `tokens/button_metrics.dart` junto con el resto de tokens de
estructura de componente que este documento no redeclara: `card_metrics.dart`, `list_item_metrics.dart`,
`dialog_metrics.dart` (radio, relleno, separaciones y anchos mínimo y máximo para acotar los modales al
ancho de formulario), `field_metrics.dart` (altura estándar y compacta, rellenos horizontal y vertical,
radio y tamaños de ícono de un campo de entrada), `grid_metrics.dart` y `component_metrics.dart` (métricas
puntuales de widgets concretos: franja de comandos, lienzo del ordinograma, menú contextual, barra
inferior, panel de salida). Cada uno de esos archivos es autosuficiente: declara constantes con nombre
propio y no requiere una tabla aparte para interpretarse.

**Regla geométrica universal de campos de entrada.** Todo campo con contorno redondeado (`radius-md` = 8 dp)
exige un relleno horizontal no inferior a `space-3` (12 dp), tanto en su variante estándar como en la compacta.
Esta holgura garantiza que el primer carácter y el cursor comiencen en la zona recta interior del control,
sin sobreponerse con la curva del radio de 8 dp ni con el grosor del contorno enfocado. La variante compacta (36 dp de
altura) emplea un relleno vertical de 6 dp para evitar colisiones verticales con los bordes superior
e inferior del campo.

---

## 13. Contrato de implementación

Esto no es una recomendación de estructura: es lo que hace que las tablas anteriores sean verificables en
vez de aspiracionales.

### 13.1 Dónde viven los tokens

Todo bajo `lib/presentation/theme/`.

| archivo                               | contenido                                                                                                                              |
|---------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `tokens/color_primitives.dart`        | las ocho escalas y los tintes oscuros, más los colores base de sombra. **Único archivo autorizado a contener un literal `Color(0x…)`** |
| `tokens/color_semantic.dart`          | `SurfaceColors`, `TextColors`, `BorderColors` y `AppSemanticColors`; reexporta actions y severity                                      |
| `tokens/color_semantic_actions.dart`  | `ActionColors` y sus cuatro variantes (primary, secondary, tertiary, destructive)                                                      |
| `tokens/color_semantic_severity.dart` | `SeverityColors` y `OpacityMetrics`                                                                                                    |
| `tokens/syntax_colors.dart`           | `AppSyntaxColors`, resaltado de sintaxis                                                                                               |
| `tokens/typography.dart`              | familias, pesos y la escala tipográfica por clase de lienzo                                                                            |
| `tokens/spacing.dart`                 | escala de espaciado, objetivos táctiles, `LayoutMetrics`                                                                               |
| `tokens/radii.dart`                   | escala de radios                                                                                                                       |
| `tokens/elevation.dart`               | las sombras de cada nivel en cada modo                                                                                                 |
| `tokens/motion.dart`                  | duraciones y curvas, más la variante de movimiento reducido                                                                            |
| `tokens/icon_metrics.dart`            | tamaños y grosores de trazo                                                                                                            |
| `tokens/layers.dart`                  | escala de apilamiento                                                                                                                  |
| `tokens/border_metrics.dart`          | grosores de borde y anillo de foco                                                                                                     |
| `tokens/editor_metrics.dart`          | los tokens del editor, del ordinograma y de la tabla de traza                                                                          |
| `tokens/button_metrics.dart`          | `buttonMinWidth`, `buttonIconOnlyMinSize`                                                                                              |
| `tokens/card_metrics.dart`            | radios, relleno y separación interna de tarjeta                                                                                        |
| `tokens/list_item_metrics.dart`       | altura, relleno y tamaños de ícono de un elemento de lista                                                                             |
| `tokens/dialog_metrics.dart`          | anchos máximo y mínimo, radio, relleno y separaciones de un diálogo                                                                    |
| `tokens/field_metrics.dart`           | altura, rellenos horizontal y vertical, radio y tamaños de ícono de un campo de entrada                                                |
| `tokens/grid_metrics.dart`            | medianiles y alturas de tarjeta de la biblioteca                                                                                       |
| `tokens/component_metrics.dart`       | métricas puntuales de widgets concretos que no forman una escala propia                                                                |
| `app_color_scheme.dart`               | deriva el `ColorScheme` de Material desde `AppSemanticColors`                                                                          |
| `app_component_themes.dart`           | construye los `ThemeData` de los widgets Material de fábrica que la app usa                                                            |
| `app_theme.dart`                      | `AppThemeExtension`, comportamiento de scroll y de transición de página, y `AppTheme.light()` / `AppTheme.dark()`                      |

### 13.2 Reglas de consumo

- Un widget consume **tokens semánticos** a través de `AppThemeExtension.of(context)`. Nunca una
  primitiva, nunca `Colors.*` de Flutter, nunca un literal.
- La selección entre modo claro y oscuro ocurre **una vez**, en la construcción del tema. Ningún widget
  ramifica por modo, igual que ninguno ramifica por plataforma.
- La selección de la tabla tipográfica y de `LayoutMetrics` por clase de dispositivo ocurre **una vez**,
  en el armazón, junto a la decisión de densidad que el paquete ya centraliza ahí.

### 13.3 Verificadores que este documento hace posibles

| verificación                                                                         | qué detecta                                      |
|--------------------------------------------------------------------------------------|--------------------------------------------------|
| literal de color fuera de `theme/tokens/color_primitives.dart`                       | un color inventado                               |
| número usado como medida de relleno, margen, radio o tamaño fuera de `theme/tokens/` | una medida fuera de escala                       |
| `Duration(` fuera de `theme/tokens/motion.dart`                                      | una animación con duración propia                |
| identificador `Colors` en cualquier archivo de `lib/`                                | uso de la paleta de Material en vez de la propia |
| todo par texto/fondo del mapa semántico calculado y contrastado contra su piso       | una regresión de contraste al tocar un token     |
| todo token de sintaxis contrastado contra los cuatro fondos de línea del editor      | un color de sintaxis nuevo sin verificar         |

Los dos últimos son tests de datos puros sobre las tablas de tokens: no necesitan renderizar nada, y son
los que impiden que este documento envejezca en silencio. Como todo verificador del monorepo, cada uno
lleva su caso negativo con una violación deliberada. El comando que ejecuta el conjunto completo está en
la sección «Cómo se verifica» del `README.md` del paquete.

---

## 14. Fuera de alcance a propósito

No hay modo de contraste alto ni soporte de colores forzados del sistema operativo: son un mapa semántico
adicional completo. No hay tematización por el usuario más allá de claro y oscuro. No hay temas de
sintaxis alternativos.

---

## 15. Fuentes consultadas

| fuente                                          | qué se tomó                                                                                                                                                       | qué no se adopta                                                                                   |
|-------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| WCAG 2.2                                        | los pisos de contraste 4.5:1 y 3:1, la exención de componentes inactivos, el mínimo de 24 de objetivo táctil y el requisito de que el color no sea el único canal | el nivel AAA como piso general: se alcanza donde sale, no se exige                                 |
| Oklab / OKLCH (Björn Ottosson)                  | el espacio de color en el que se generan las rampas y se derivan los estados                                                                                      | nada más: la conversión y la reducción a gamut son propias                                         |
| Clases de tamaño de ventana de Material 3       | el corte de 600 dp entre `compact` y `medium`, ya adoptado por el paquete                                                                                         | color dinámico, paletas tonales HCT, capas de estado con alfa y la escala de elevación de Material |
| Guías de interfaz humana de Apple               | el mínimo de 44 de objetivo táctil, como cota inferior a superar                                                                                                  | los controles adaptativos y la tipografía del sistema, prohibidos por el paquete                   |
| IBM Plex Sans e IBM Plex Mono, bajo SIL OFL 1.1 | las dos familias, empaquetadas en los activos                                                                                                                     | ningún token de color, tamaño o espaciado del sistema de diseño de IBM                             |

Todo valor numérico de este documento —cada hexadecimal, cada ratio de contraste, cada tamaño— es propio
de este proyecto y está calculado, no copiado. Las coincidencias con sistemas existentes en la elección
de tono para error, advertencia e información son deliberadas y su razón está escrita: son convenciones
que el usuario ya trae aprendidas y romperlas costaría comprensión sin ganar nada.
