# 02 — Formato fuente y verificadores

El formato extiende el de la Especificación (`packages/pseudolearn_reference/README.md` §3.2). Todo lo que allí existe
sigue valiendo igual: código en línea, `**fuerte**`, `*énfasis*`, tablas, listas, cercas `programa`, `salida`,
`entrada`, `diagnosticos`, `anfitrion` y `figura`, y los recuadros `analogia`, `docentes`, `por-dentro`, `nota`,
`resumen`. Aquí solo se describe lo nuevo.

---

## 1. `partes.json` y `terminos.json`

```json
[
  { "id": "parte-inicio", "numero": "0", "prefijo": "0", "titulo": "Empezar de cero",
    "lema": "", "resumen": "Qué es un problema, el primer programa y cómo saber si está bien." }
]
```

`lema` es la frase corta del paradigma («Darle órdenes a una máquina con memoria»). Va vacío en la Unidad 0.

```json
{
  "caso-borde": { "etiqueta": "caso borde", "formas": ["caso borde", "casos borde"], "estricto": true, "receta": false },
  "acumulador": { "etiqueta": "acumulador", "formas": ["acumulador", "acumuladores"], "estricto": true, "receta": true }
}
```

| Campo | Significado |
|---|---|
| `etiqueta` | Cómo se muestra el término en chips y tarjetas |
| `formas` | Formas de superficie que se buscan en la prosa (singular, plural) |
| `estricto` | `true` si el término no tiene un uso cotidiano que se confunda. Solo los estrictos se buscan sin marcado (`RUTA-TERM-ORDER`) |
| `receta` | `true` si nombrarlo en un enunciado regala la solución (`RUTA-STATEMENT-NO-RECIPE`) |

El catálogo completo, con dueño, `estricto` y `receta`, está en `04-terminos-maquina-figuras.md` §1.

---

## 2. Lección: `leccion.md`

### 2.1 Cabecera

```yaml
---
id: imperativo.mientras
numero: "1.3"
tipo: leccion
titulo: Repetir mientras haga falta
duracion: 25
problema_breve: La alcancía de Lucía
necesita: [inicio.nombres, inicio.preguntar, inicio.errores, imperativo.decidir]
introduce: [bucle, vuelta, mientras, contador, acumulador, tabla-por-vuelta, invariante, bucle-infinito, centinela]
usa: [variable, asignar, condicion, caso-borde, ficha-del-problema, leer, ejemplo-a-mano]
pieza: 4
---
```

| Campo | Regla |
|---|---|
| `tipo` | `leccion`, `apertura` (primera lección de un paradigma: exige el bloque `paradigma`) o `proyecto` |
| `necesita` | Solo lecciones anteriores en el orden del índice |
| `introduce` | Términos de los que esta lección es dueña. Cada término tiene exactamente un dueño en todo el libro |
| `usa` | Términos de lecciones anteriores que la lección da por sabidos. Cada uno genera, como mínimo, la posibilidad de una tarjeta de recuerdo |
| `pieza` | Opcional. Número de la pieza de la máquina nocional que esta lección introduce |
| `menciones_cotidianas` | Opcional. Términos estrictos que el problema usa con su sentido cotidiano antes de su dueña («la clase de quinto»). Ver 04 §1 |

### 2.2 Recuadros nuevos

| Recuadro | Cuerpo | Publica |
|---|---|---|
| `::: frase` | Una o dos oraciones | `phrase` |
| `::: problema` | Párrafos. Los datos van en **fuerte** y la pregunta en un párrafo propio en **fuerte** | `problem` |
| `::: intento` seguido **inmediatamente** de `::: respuesta` | Consigna; respuesta oculta | `attempt` |
| `::: ficha` | Líneas `entra:`, `sale:`, `relacion:` y una lista bajo `ejemplos:` | `brief` |
| `::: roles` | Un ítem por rol: `- contador \| ruta-rol-contador \| descripción` | `roles` |
| `::: paradigma` | Líneas `pregunta:`, `metafora:`, `historia:`, `costo:` | `paradigm` |
| `::: recuerda termino=<id>` | Vacío: el texto se genera | `recall` |
| `::: especificacion` | Lista de ids de sección (`- control.mientras`) | `spec_links` |
| `::: profundizar titulo="…"` | Cualquier contenido; plegado | `callout` plegable |
| `::: practica` | Lista ordenada de ids de ejercicio | `practice` |
| `::: siguiente` | Una oración de enganche | `next` (la lección siguiente sale del índice) |

`::: por-dentro` se titula «Bajo el capó» en la ruta y **solo** puede contener párrafos breves y un bloque
`::: especificacion`: lo de abajo del motor lo explica la Parte XIII de la Especificación (`RUTA-NO-SPEC-DUP`).

### 2.3 Encabezados de fase

```markdown
## Entender {#entender fase=1}
## Entender y planear {#entender-planear fase=1-2}
```

El atributo `fase` hace que el compilador publique la tira del ciclo (`cycle`) y el encabezado con insignia
(`phase_heading`). Las fases van en orden y no se repiten.

### 2.4 Cercas nuevas

````markdown
```figura-especificacion seccion=control.mientras figura=mientras-ciclo
```
````

Copia la figura resuelta de esa sección, con capas, pasos y pie. No admite cuerpo.

### 2.5 En línea

| Sintaxis | Significado |
|---|---|
| `[[def:caso-borde\|casos borde]]` | Primera aparición y definición del término en su lección dueña. Exactamente una por término `introduce` |
| `[[caso-borde\|casos borde]]` | Mención marcada de un término; respeta el orden de dueños |
| `[texto](especificacion:control.si)` | Enlace a una sección de la Especificación |
| `[texto](ruta:imperativo.decidir)` | Enlace a otra lección |

### 2.6 Resumen etiquetado

Cada ítem de `::: resumen` lleva entre llaves los términos que resume:

```markdown
::: resumen
- {contador,acumulador} Un contador avanza lo mismo en cada vuelta; un acumulador va juntando.
- {centinela} Un centinela es un valor especial que avisa que se terminaron los datos.
:::
```

La frase del ítem es la que aparece en las tarjetas «Recuerda» de ese término en otras lecciones. Cada término de
`introduce` aparece en exactamente un ítem (`RUTA-RECALL-SOURCE`).

### 2.7 Orden de bloques (anatomía)

| Orden | Bloque | `leccion` | `apertura` | `proyecto` |
|---|---|---|---|---|
| 1 | `frase` | sí | sí | sí |
| 2 | `## El problema` + `problema` | sí | sí | sí |
| 3 | `## Inténtalo` + `intento` + `respuesta` | sí | sí | sí |
| 4 | `## Un paradigma nuevo` + `paradigma` | — | sí | — |
| 5 | Fases 1 y 2 (separadas o `1-2`, según el andamiaje de 03 §3) | sí | sí | separadas |
| 6 | `## La herramienta nueva` con un programa ejecutado y `::: especificacion` | si `introduce` contiene una construcción | igual | — |
| 7 | Fase 3, fase 4 y fase 5 | sí | sí | sí |
| 8 | `## Lo que aprendiste` + `resumen` | sí | sí | sí |
| 9 | `## Practica` + `practica` | sí | sí | sí |
| 10 | `docentes` | recomendado | recomendado | recomendado |
| 11 | `por-dentro` (Bajo el capó) | opcional | opcional | — |
| 12 | `siguiente` | sí, salvo la última | sí | sí |

`figura`, `figura-especificacion`, `programa`, `recuerda`, `ficha`, `roles`, `analogia` y `profundizar` pueden ir donde
las fichas de lección lo indiquen.

---

## 3. Ejercicio: `ejercicios/<NN-slug>.md`

### 3.1 Cabecera

```yaml
---
id: imperativo.mientras.alcancia-tomas
leccion: imperativo.mientras
tipo: romperlo
nivel: brote
obligatorio: true
titulo: La alcancía de Tomás
---
```

`tipo`: `predecir`, `rastrear`, `ordenar`, `encontrar-error`, `romperlo`, `disenar-pruebas`, `modificar`, `resolver`,
`comparar`, `clasificar`, `explicar`. `nivel`: `semilla`, `brote`, `arbol`.

### 3.2 Bloques comunes

| Bloque | Uso |
|---|---|
| `::: enunciado` | El problema. Lo revisa `RUTA-STATEMENT-NO-RECIPE` |
| `::: restriccion` | Condición estructural explícita («sin escribir el cálculo más de una vez»). No lo revisa el verificador de recetas, porque nombrar la restricción es su función |
| `::: pistas` | Lista ordenada de **exactamente cuatro** pistas, en la escalera de 03 §6 |
| `::: variante` | El problema extra que cierra la cuarta pista |
| `::: explicacion` | Lo que se muestra tras responder (tipos de opción y predicción) |
| `::: docentes` | Solución comentada, errores frecuentes, casos ocultos |

### 3.3 Bloques por tipo

| Tipo | Bloques obligatorios | Qué verifica el compilador (`RUTA-EXERCISE-VERIFIED`) |
|---|---|---|
| `predecir` | `programa` (`rol=objeto`), `entrada` opcional, `salida` | La salida prometida coincide con la ejecución en los dos perfiles |
| `rastrear` | `programa`, cerca `vueltas marca=<línea> columnas=<v1,v2,…>` | Se inserta `Escribir v1, "\|", v2…;` antes de la línea `marca`, se ejecuta y cada fila coincide. Una celda que empieza por `?` es la que completa la persona. La fila `antes` se verifica con la misma inserción antes del bucle |
| `ordenar` | `programa rol=referencia` y `casos`, **o** una cerca `pasos` con frases en lenguaje natural en su orden correcto | Con programa: la referencia pasa los casos; cada línea no vacía entre cabecera y cierre es un bloque; la cabecera y el cierre van fijos; hay al menos 4 bloques. Con `pasos`: se evalúa el orden exacto |
| `encontrar-error` | `programa rol=inicial`, `programa rol=referencia`, `casos` | La referencia pasa todos los casos; la inicial falla al menos uno, o no compila, o falla al ejecutar |
| `romperlo` | `programa rol=defectuoso`, `programa rol=referencia`, `casos` (visibles), cerca `rompe` | Los dos pasan los casos visibles; cada entrada de `rompe` hace que difieran |
| `disenar-pruebas` | `programa rol=referencia`, al menos tres `programa rol=mutante id=…`, cerca `casos-solucion`, atributos `minimo` y `maximo` | `casos-solucion` pasa en la referencia y mata a todos los mutantes; ningún mutante es equivalente a la referencia en todos los casos visibles y ocultos de la lección |
| `modificar` | `programa rol=inicial`, `programa rol=referencia`, `casos` | La referencia pasa; la inicial falla al menos un caso oculto (si no, no hay nada que modificar) |
| `resolver` | `programa rol=referencia`, `casos` (≥ 2 visibles, ≥ 3 ocultos), `programa rol=inicial` opcional | La referencia pasa |
| `clasificar` | cerca `categorias`, cerca `elementos` (`texto \| categoría`) | Toda categoría tiene al menos un elemento |
| `explicar`, `comparar` | cerca `opciones` (`- [x] texto \| justificación`, una sola marcada) | Hay una sola correcta y todas tienen justificación |

**Excepciones por alcance.** Antes de la lección 0.3 no existe `Leer`: un `resolver`, `modificar` o `encontrar-error`
de las lecciones 0.1 y 0.2 tiene un único caso visible, sin entradas, y ningún oculto. `rastrear` solo existe desde la
lección 1.3, dueña de la tabla por vuelta. `romperlo` y `disenar-pruebas` solo existen desde la 0.4, dueña del caso de
prueba, y necesitan programas con `Leer`.

### 3.4 Formato de casos

````markdown
```casos
visible | 50 | Día 9 con 54 monedas
oculto  | 54 | Día 9 con 54 monedas
oculto  | 14 ; 17 ; 11 ; -1 | 14.0
```
````

- Columnas: visibilidad, entradas separadas por ` ; ` (una por `Leer`), salida con líneas separadas por ` ⏎ `.
- La comparación usa la normalización actual de la app (espacios, finales de línea y tolerancia `1e-9` en números).
- `rompe` y `casos-solucion` usan el mismo formato sin la primera columna (`rompe` sin salida).

### 3.5 Ejercicio publicado

`exercises/<id>.json` lleva cabecera, enunciado y restricción en corridas, pistas, variante, explicación, docentes y
los datos de evaluación de su tipo (01 §5.3). Los programas se publican tokenizados para el perfil de la edición. Los
mutantes, el defectuoso y la referencia se publican aparte de los bloques visibles, en un objeto `evaluacion`, y la
app nunca los pinta.

---

## 4. Proyectos

Un proyecto es una lección de tipo `proyecto`. Diferencias:

- Las cinco fases van **separadas y completas**, como en la Unidad 0.
- `::: ficha` y el plan se piden a la persona: el proyecto incluye un ejercicio `clasificar` para la ficha (cada dato
  del enunciado en entra, sale o no importa) y un ejercicio `ordenar` cuyos bloques son **pasos del plan en lenguaje
  natural** (cerca `pasos` con el orden correcto; se evalúa por orden exacto).
- El programa final es un ejercicio `resolver` de nivel `arbol`, obligatorio, con al menos seis casos ocultos.

---

## 5. Verificadores

Cada uno tiene un caso negativo en `fixtures/route/<nombre>/` y un test que demuestra que falla (`AGENTS.md` §5). Los
existentes `REF-*` se aplican también a la ruta donde se indica.

| ID | Regla | Caso negativo |
|---|---|---|
| `RUTA-FORMAT` | La fuente sigue §2 y §3: cabeceras completas, recuadros cerrados, `respuesta` justo después de `intento`, fases ordenadas | `respuesta` sin `intento` |
| `RUTA-ANATOMY` | Orden y presencia de bloques según §2.7 y tipo de lección | Lección sin `problema` |
| `RUTA-TERM-OWNER` | Cada término de `terminos.json` tiene exactamente una lección dueña; cada `introduce` existe en `terminos.json`; cada término introducido tiene exactamente un `[[def:…]]` en su dueña | Término introducido por dos lecciones |
| `RUTA-TERM-ORDER` | Ninguna lección usa un término cuya dueña viene después: ni marcado (`[[…]]`, `usa`, `recuerda`), ni, si el término es `estricto`, por sus formas en la prosa, títulos, problemas, pistas o enunciados | La lección 0.1 dice «variable» |
| `RUTA-RECALL-SOURCE` | Cada término introducido aparece en exactamente un ítem etiquetado del resumen de su dueña; cada `recuerda` apunta a un término de `usa` | Término sin ítem de resumen |
| `RUTA-PREREQ` | `necesita` contiene solo lecciones anteriores e incluye a las dueñas de todos los términos de `usa` (directa o transitivamente) | `usa: [arreglo]` sin necesitar 1.5 |
| `RUTA-SPEC-LINK` | Todo `especificacion:` y `figura-especificacion` apunta a una sección, ancla y figura existentes en el libro de la Especificación | Sección inexistente |
| `RUTA-LINK-VALID` | Todo `ruta:` apunta a una lección existente | Lección inexistente |
| `RUTA-NO-SPEC-DUP` | Una lección no contiene `forma`, `railes`, `ri`, `traza`, ni recuadros `partes`, `limite` o `errores`; `por-dentro` solo contiene párrafos y `especificacion` | Lección con una cerca `forma` |
| `RUTA-EXAMPLE-VERIFIED` | `REF-EXAMPLE-VERIFIED` aplicado a cada programa de lección y de ejercicio | Salida prometida falsa |
| `RUTA-EXERCISE-VERIFIED` | Las comprobaciones por tipo de §3.3 | Un `romperlo` cuya entrada no rompe |
| `RUTA-EXERCISE-MIX` | Cada lección no proyecto tiene al menos 5 ejercicios, de al menos 3 tipos y 2 niveles, con al menos 3 obligatorios; cada ejercicio listado en `practica` existe y cada archivo de `ejercicios/` está listado | Lección con 4 ejercicios |
| `RUTA-STATEMENT-NO-RECIPE` | Un `problema` o `enunciado` no contiene código en línea que tokenice como palabra reservada del vocabulario ni formas de términos con `receta: true` | Enunciado con «usa un acumulador» |
| `RUTA-HINTS` | `resolver`, `modificar`, `encontrar-error`, `romperlo` y `disenar-pruebas` tienen cuatro pistas y una `variante` | Tres pistas |
| `RUTA-SCAFFOLD` | El andamiaje de fases corresponde a la parte (03 §3) | Lección de la Parte II con fases 1 y 2 separadas |
| `RUTA-PARITY` | `es` y `en` tienen los mismos archivos, cabeceras, bloques y ejercicios | Ejercicio solo en español |
| `REF-FIGURE-CONTRACT`, `REF-FIGURE-NARROW` | Se aplican a `figures/ruta-*.svg` | Figura de 400 de ancho |
| `REF-NO-INTERNAL-IDS`, `REF-INLINE-CODE` | Se aplican al texto publicado de la ruta | Párrafo con `LANG.CONTROL.WHILE` |
| `RUTA-BUNDLE-STALE` | El paquete versionado en `assets/route/` es idéntico al producido | Archivo editado a mano |

`reference coverage` agrega un informe de la ruta: términos por lección, lecciones por sección de la Especificación,
ejercicios por tipo y nivel, y secciones de la Especificación que ninguna lección enlaza. El informe no falla; sirve
para la revisión de RA-7.
