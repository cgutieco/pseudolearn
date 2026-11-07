# 03 — Pedagogía y estilo

Este archivo es normativo para todo el contenido de la ruta. Lo que aquí se pide y no tiene verificador mecánico se
revisa a mano con la lista de §11 antes de cerrar cada lección.

---

## 1. Principios

1. **Se parte de cero.** La persona no sabe qué es un programa, una variable ni una computadora por dentro. Ningún
   término se usa antes de su lección dueña (`RUTA-TERM-ORDER`).
2. **Problema primero.** Cada lección empieza con un problema que la persona todavía no sabe resolver bien. La
   construcción nueva llega como la herramienta que lo resuelve. El título nombra la habilidad, no la palabra
   reservada.
3. **Resultados rápidos.** En la lección 0.1 hay un programa ejecutándose antes del minuto 5. En cada lección hay un
   programa ejecutable antes de la mitad.
4. **Una sola explicación por cosa.** La Especificación explica cómo se escribe y qué hace exactamente el lenguaje.
   La ruta explica cuándo usarlo y cómo pensar el problema. Lo que ya se explicó en una lección anterior aparece como
   tarjeta «Recuerda», generada, no reescrita.
5. **La máquina nocional se arma en piezas.** Cada pieza la presenta la primera lección que la necesita
   (`04-terminos-maquina-figuras.md` §2). Nunca se menciona una pieza antes.
6. **Se enseña a razonar, no solo a escribir.** Cada lección deja una herramienta de pensamiento (ficha, tabla,
   partición, roles, árbol, invariante, tarjetas) y la usa.
7. **Un público, varias capas.** El cuerpo se entiende desde los 10 años. Lo que profundiza va en «Profundizar»; lo
   que baja al motor va en «Bajo el capó»; lo que sirve para enseñar va en «Para docentes». El cuerpo nunca depende de
   las capas plegables.

---

## 2. Qué contiene cada fase del ciclo

| Fase | Obligatorio | Prohibido |
|---|---|---|
| **1. Entender** | Lo que se sabe y lo que se pide, en palabras. Desde la 0.3, la `ficha` con al menos dos ejemplos a mano, y uno de ellos es un caso borde (desde la 0.4) | Código |
| **2. Planear** | Los pasos en lenguaje natural, numerados, en el mismo orden que tendrá el programa. Cuando corresponde, la herramienta de la lección (roles, árbol, tabla de decisión, partición) | Código |
| **La herramienta nueva** | Para qué sirve, un programa mínimo **distinto** de la solución, enlace a la Especificación | Reglas, límites, catálogos de errores, raíles y formas: todo eso es de la Especificación |
| **3. Escribir** | La solución ejecutada. Un párrafo que señala qué línea corresponde a qué paso del plan | Explicar sintaxis ya explicada |
| **4. Probar** | Comparación con los ejemplos a mano en una tabla; al menos un caso borde; la herramienta de verificación de la lección (traza, tabla por vuelta, sustitución) | Decir «funciona» sin mostrar la comparación |
| **5. Mejorar** | «En una frase» y, al menos, una de estas: un cambio de requisito resuelto, una comparación con otra solución o el problema que queda abierto para la lección siguiente | — |

---

## 3. Andamiaje por parte

| Parte | Fases 1 y 2 | Preguntas de «Entender y planear» |
|---|---|---|
| Unidad 0 y Parte I | Separadas y completas | — |
| Parte II | `fase=1-2` | ¿Qué entra y qué sale? ¿A qué problema que ya resolví se parece? **¿En qué partes se divide?** |
| Parte III | `fase=1-2` | Las dos primeras y **¿quién tiene la información para hacer esto?** |
| Parte IV | `fase=1-2` | Las dos primeras y **¿qué parte es cálculo y qué parte toca el mundo?** |
| Parte V | `fase=1-2` | Las dos primeras y **¿qué puede pasar a la vez y qué tiene que esperar?** |
| Parte VI | `fase=1-2` | Las dos primeras y **¿qué puede fallar afuera del programa?** |
| Proyectos | Separadas y completas, con ficha y plan como ejercicios | — |

Cada lección condensada responde sus preguntas en una lista breve, como en la muestra 4.1.

---

## 4. Redacción

- Tuteo y español neutro: «puedes», «escribe», «computadora». Sin voseo, sin regionalismos y sin modismos.
- Frases de menos de 25 palabras. Una idea por párrafo. Párrafos de cuatro líneas como máximo en teléfono.
- Prohibido: «simplemente», «obviamente», «es fácil», «como todos saben», «trivial».
- Toda palabra del lenguaje dentro de la prosa va como código en línea (`REF-INLINE-CODE`).
- Las negritas marcan el dato o la idea que la persona tiene que retener. Como máximo dos por párrafo.
- Cada analogía dice dónde deja de valer, en la misma analogía.
- Los números de la prosa salen de una ejecución o de una cuenta mostrada (`RA-NUMBERS-ORACLE`).
- Nombres de personas variados y sin estereotipos de género en los roles. Ninguna marca comercial.
- Moneda: **pesos**, siempre enteros salvo que la lección trate de reales.
- Sin violencia, sin apuestas con dinero y sin temas que excluyan a alguien por su situación económica o familiar.
- La edición inglesa es una redacción natural en inglés con la misma estructura, no una traducción palabra a palabra.
  Los nombres propios se mantienen.

---

## 5. Problemas

Un buen problema de la ruta:

1. Es **concreto**: personas, cosas y números reales, no «dado un número n».
2. Se resuelve **a mano** en menos de cinco minutos con los datos del enunciado.
3. Tiene **al menos un caso borde natural** que una solución apurada rompe.
4. **No regala la solución**: no nombra la construcción, el rol ni el esquema (`RA-NO-RECIPE`).
5. Termina en **una pregunta**, en negrita, en un párrafo propio.

### 5.1 El kiosco de la escuela

El problema hilo usa siempre los mismos datos, para que la persona los reconozca entre partes:

| Código | Producto | Precio (pesos) |
|---|---|---|
| 1 | Jugo | 3 |
| 2 | Sándwich | 5 |
| 3 | Alfajor | 2 |
| 4 | Agua | 1 |
| 5 | Fruta | 2 |

- **Descuento:** por cada 10 pesos de compra se descuenta 1 peso (`monto - monto div 10`).
- **Pedido de prueba canónico:** 3 jugos y 2 sándwiches = 19 pesos, con descuento 18.
- El kiosco lo atiende la clase. No tiene dueño con nombre.

---

## 6. Ejercicios

### 6.1 Reglas

- Un ejercicio plantea un problema; nunca enumera pasos.
- Los tres niveles: **semilla** (el concepto de la lección en su forma más directa, con números pequeños), **brote** (el
  concepto combinado con algo anterior o con un caso borde que hay que descubrir), **árbol** (problema nuevo de
  varios pasos, sin parecido superficial con la lección).
- Cada lección tiene entre 5 y 7 ejercicios, de al menos 3 tipos y 2 niveles, con 3 obligatorios. Los obligatorios
  cubren el objetivo central de la lección y al menos uno ejecuta código de la persona (`resolver`, `modificar` o
  `encontrar-error`), salvo en 2.7 y 3.6.
- Los casos visibles incluyen al menos uno normal. Los ocultos incluyen todos los casos borde que la ficha de la
  lección menciona.
- Las salidas esperadas son cortas y sin adornos que la persona tenga que adivinar. Si el formato importa, el
  enunciado muestra un ejemplo exacto de salida.
- En los ejercicios, los programas no escriben mensajes antes de `Leer` salvo que el enunciado lo pida. En las
  lecciones sí pueden hacerlo, porque enseñan a escribir programas amables.

### 6.2 Escalera de pistas

| Pista | Contenido | Ejemplo (alcancía de Tomás) |
|---|---|---|
| 1 | Una **pregunta** sobre el problema, no sobre el código | «¿Cuál de los ejemplos a mano es un caso borde?» |
| 2 | Un **problema parecido** ya resuelto en la ruta, enlazado | «Compara con la línea 7 de tu versión» |
| 3 | El **esqueleto**: qué partes tiene la solución, sin el código completo | «Prueba con un precio que se pueda juntar exacto» |
| 4 | La **solución**, y la `variante` obligatoria para cerrar | «Con 54 Tomás dice día 10. Variante: corrige la línea 7» |

### 6.3 Mutantes

Los mutantes de `disenar-pruebas` imitan errores reales de principiantes. Catálogo del que se eligen al menos tres:

| Mutante | Ejemplo |
|---|---|
| Borde de comparación | `<` por `<=`, `>` por `>=` |
| Uno de más o de menos | `Hasta n` por `Hasta n - 1`; índice desde 1 |
| Inicialización | Acumulador desde 1, máximo desde 0 con datos negativos |
| Orden de actualización | Sumar antes de incrementar |
| Caso olvidado | Sin la rama de «no hay datos» |
| Operación vecina | `div` por `/`, `techo` por `redon` |

Ningún mutante puede ser equivalente a la referencia: el compilador lo comprueba (02 §3.3).

### 6.4 Para docentes en cada ejercicio

Solución comentada en dos o tres frases, el error más frecuente y cómo detectarlo, y los casos ocultos con el motivo de
cada uno.

---

## 7. Aperturas de paradigma

Las lecciones `apertura` son 1.1, 2.1, 3.1, 4.1 y 5.1: la primera de cada parte de paradigma. En 1.1 y 2.1 el bloque
`::: paradigma` es breve, porque la persona todavía conoce un solo paradigma. Llevan:

| Campo | Regla |
|---|---|
| `pregunta` | La pregunta que el paradigma se hace, en una oración |
| `metafora` | Una imagen cotidiana y dónde deja de valer |
| `historia` | Solo hechos establecidos, con año y nombre (los de cada ficha de lección). Nada de «el lenguaje más usado» ni rankings |
| `costo` | Qué cuesta usarlo, con honestidad |

Y cierran la fase 5 con una tabla que compara el paradigma nuevo con el anterior, como la muestra 4.1.

---

## 8. Figuras

- Contrato de `packages/pseudolearn_reference/README.md` §3.4: 340 de ancho, letra de 12 o más, colores por rol, textos
  desde `strings`, sin marcadores.
- **Una figura ancla por herramienta**, idéntica en todas las lecciones que la usan: la ficha, la tabla por vuelta, el
  árbol de descomposición. Se reutiliza por id; no se redibuja con otros colores.
- Todo lo que transcurre (ejecución, búsqueda, recursión) es una figura por pasos, con un texto por paso.
- Antes de dibujar una figura nueva, se busca en la Especificación (`04-terminos-maquina-figuras.md` §4). Si existe, se
  incrusta con `figura-especificacion`.
- El pie dice qué mirar, no qué hay: «La pregunta va antes del cuerpo», no «Diagrama de un bucle».
- Colores por fase del ciclo: Entender `acento-estructurado`, Planear `hueco`, Escribir `acento-procedimental`,
  Probar `acento-objetos`, Mejorar `exito`. El agente confirma con la persona si estos roles no alcanzan, antes de
  proponer un rol nuevo, que afectaría a la paleta de la app.

---

## 9. Para docentes

Cada lección tiene un recuadro `docentes` con tres o cuatro confusiones frecuentes. Cada una lleva: la frase que dice
quien tiene la confusión, por qué es falsa y una actividad de clase de un minuto que la desmonta.

---

## 10. Siguiente

El bloque `siguiente` nombra el problema que la lección deja abierto, nunca el tema. Bien: «¿Y si sabes desde el
principio cuántas vueltas hacen falta?». Mal: «En la próxima lección veremos el bucle `Para`».

---

## 11. Lista de cierre de cada lección

- [ ] El problema se resuelve a mano y la respuesta de «Inténtalo» coincide con el motor.
- [ ] Ningún término aparece antes de su dueña (verificador en verde) y cada definición es clara para alguien de 10 años.
- [ ] La herramienta nueva tiene un ejemplo distinto de la solución y enlaza a la Especificación.
- [ ] No se repite nada que la Especificación ya explique.
- [ ] Las cinco fases (o su forma condensada) están completas según §2 y §3.
- [ ] Hay al menos un caso borde en la ficha, en Probar y en los casos ocultos.
- [ ] Los ejercicios cumplen §6 y sus enunciados no regalan la solución.
- [ ] Las figuras cumplen §8 y se leen en un teléfono de 375 puntos.
- [ ] La edición inglesa está completa y con paridad.
- [ ] «Siguiente» deja un problema abierto.
