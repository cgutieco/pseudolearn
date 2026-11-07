# 14 — Parte IV: Funcional

**Lema:** Calcular sin cambiar nada.

**Propósito de la parte:** que la persona construya programas alrededor de funciones puras, use funciones como valores,
modele el dominio para que los estados imposibles no se puedan escribir y compare los tres paradigmas con criterio. Cinco
lecciones y un proyecto, unas tres horas y media.

Fases 1 y 2 condensadas con la pregunta propia: ¿qué parte es cálculo y qué parte toca el mundo?

---

## 4.1 Calcular sin cambiar nada — `funcional.sin-cambiar`

| Campo | Valor |
|---|---|
| Tipo | `apertura` · 30 min · semilla a árbol |
| Necesita | `objetos.proyecto` |
| Introduce | `programacion-funcional`, `inmutabilidad`, `transparencia-referencial`, `nucleo-puro` |
| Muestra | `docs/ruta-aprendizaje-ejemplos/4-1-calcular-sin-cambiar-nada.html` (contenido casi completo; la tarjeta de `paradigma` apunta a 1.1, no a 3.1) |

**Propósito.** La persona organiza un programa como núcleo puro y borde con efectos, calcula por sustitución y compara con
honestidad este paradigma con los anteriores.

**Frase.** La programación funcional arma los programas con cálculos que no modifican nada: reciben valores y devuelven
valores nuevos.

**Problema.** Un cliente compra 3 jugos y 2 sándwiches. La caja le cobra **18** pesos, pero el ticket dice **17**. Nadie tocó
el ticket. **¿Qué pasó, y cómo se escribe la caja para que no pueda volver a pasar?** (Programa `caja-referencia` de la
muestra: `AplicarDescuento` por referencia llamado dos veces.)

**Inténtalo.** Encontrar el error y decir qué vale `total` en la línea 12, notando que hay que leer todo lo anterior.

**Un paradigma nuevo.** El de la muestra: pregunta «¿y si nada cambiara?»; metáfora de la hoja de cálculo; historia: cálculo
lambda de Alonzo Church (1936) y Lisp de John McCarthy (1958); costo: el mundo sí cambia y eso se pone en un borde delgado.
Recuerdos: `paso-por-referencia`, `paradigma`, `funcion-pura`.

**Entender y planear.** Las tres preguntas. Figura `ruta-nucleo-borde` (ancla).

**3. Escribir.** `caja-funcional` de la muestra → `Cobrado: 18` ⏎ `Ticket: 18` ⏎ `Doble descuento: 17`. Enlace:
`subprogramas.pureza`.

**4. Probar.** Figura `ruta-sustitucion`. Programa `casos-descuento` → `18 9 9 0`.

**5. Mejorar.** Tabla comparativa de la muestra, con la fila honesta sobre lo que cambia con el tiempo.

**Resumen.**

- `{programacion-funcional}` La programación funcional arma programas con funciones puras que reciben valores y devuelven
  valores nuevos.
- `{inmutabilidad}` Inmutabilidad: en vez de modificar un valor, se calcula uno nuevo.
- `{transparencia-referencial}` Transparencia referencial: una llamada se puede reemplazar por su resultado sin cambiar el
  programa.
- `{nucleo-puro}` Núcleo puro y borde con efectos: el cálculo va al centro y leer o mostrar queda en un borde delgado.

**Ejercicios.** Los de la muestra y uno más.

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `nucleo-o-borde` | clasificar | semilla | sí | Calcular el IVA de un precio; preguntar al cajero cuántos productos lleva; decidir si un producto está vencido dada su fecha y la de hoy; mostrar el ticket; averiguar la fecha de hoy | Núcleo: 1 y 3. Borde: 2, 4 y 5 |
| `sustituye` | predecir | brote | sí | `Linea(4, 2) + ConDescuento(Linea(10, 3))` | `35` |
| `ticket-puro` | resolver | brote | sí | Lee dos ventas (código y cantidad) y muestra el total con descuento, con funciones puras para el importe y el descuento | Aserción: declara `ConDescuento` como `Funcion`. Visibles: 1, 3, 2, 2 → 18; 4, 1, 4, 1 → 2. Ocultos: 2, 10, 2, 10 → 90; 3, 5, 5, 0 → 9; 1, 0, 1, 0 → 0 |
| `caja-iva` | modificar | árbol | — | La caja con IVA del 18 % que nadie toca, reescrita como núcleo puro y borde | Casos: 100 → 107; 0 → 0; 9 → 9 |
| `cual-probar` | comparar | brote | — | Para probar el descuento con 50 montos, ¿`AplicarDescuento` o `ConDescuento`? | `ConDescuento`; justificación por opción |

En `ticket-puro`, «3, 5, 5, 0» son 5 alfajores (10 pesos) y 0 frutas: total 10, con descuento 9.

**Para docentes.** Los de la muestra.

**Siguiente.** «Tres bucles del kiosco recorren la misma lista y solo cambian en una operación. ¿Se puede escribir el bucle
una vez y pasarle la operación?»

---

## 4.2 Funciones que reciben funciones — `funcional.orden-superior`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 40 min · semilla a árbol |
| Necesita | `funcional.sin-cambiar` |
| Introduce | `funcion-como-valor`, `orden-superior`, `mapear`, `filtrar`, `reducir` |

**Propósito.** La persona pasa funciones como datos y construye por su cuenta mapear, filtrar y reducir sobre vectores.

**Frase.** Si lo único que cambia entre dos bucles es una operación, la operación puede ser un dato.

**Problema.** El kiosco tiene sus precios en un vector: 3, 5, 2, 1, 2. Hay tres programas: uno **suma 1 peso** a cada precio,
otro los **duplica** y otro les **resta 1**. Los tres tienen el mismo bucle y cambian en una sola línea. **¿Cómo se escribe
el bucle una sola vez?**

**Inténtalo.** Marcar en los tres programas la única línea distinta.

**Entender y planear.** Las tres preguntas. Lo que cambia es «qué hacer con cada precio»: eso pasa a ser un parámetro.

**Herramienta nueva.** Función como valor (enlace `tipos.funciones`): una `Funcion` se pasa por su nombre. El agente verifica
en la Especificación si existen literales de función y si una `Funcion` puede recibir otra `Funcion`; la lección se ajusta a
lo que el lenguaje permite. Figura `ruta-cinta`.

| Id | Programa | Salida |
|---|---|---|
| `aplicar-dos-veces` | `Funcion AplicarDosVeces(f, x)` retorna `f(f(x))`; con `MasUno` y 5 | `7` |

Enlaces: `tipos.funciones`, `tipos.vectores`, `subprogramas.pureza`.

**3. Escribir.** `mapear-filtrar-reducir`: la persona construye `Mapear(v, f)`, `Filtrar(v, condicion)` y `Reducir(v, f,
inicial)`. Con los precios: `Mapear(precios, MasUno)` → 4, 6, 3, 2, 3; `Filtrar(precios, Barato)` (2 o menos) → 2, 1, 2;
`Reducir(precios, Sumar, 0)` → 13.

**4. Probar.** Vector vacío en las tres (borde): vacío, vacío, el valor inicial.

**5. Mejorar.** Los tres programas originales quedan en tres líneas. Componer: el total de los precios baratos con aumento.

**Resumen.**

- `{funcion-como-valor,orden-superior}` Una función puede pasarse como dato; una función que recibe o devuelve funciones es de
  orden superior.
- `{mapear,filtrar,reducir}` Mapear aplica una función a cada elemento; filtrar se queda con los que cumplen una condición;
  reducir combina todos en un solo valor.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `mapear-predecir` | predecir | semilla | sí | `Mapear(1, 2, 3, Doble)` mostrado elemento por elemento | `2` ⏎ `4` ⏎ `6` |
| `cual-de-las-tres` | clasificar | semilla | sí | Precios con IVA; solo los aprobados; el total de ventas; los nombres en mayúscula; la nota más alta; los productos sin stock | Mapear: 1 y 4. Filtrar: 2 y 6. Reducir: 3 y 5 |
| `pares` | resolver | brote | sí | Lee números hasta 0 y muestra solo los pares, usando una función que filtra | Aserción: declara `Filtrar` con dos parámetros. Ocultos: ninguno par; 0 directo; negativos pares |
| `maximo-reducir` | resolver | árbol | — | Con `Reducir` y una función `Mayor`, muestra el mayor de los números leídos hasta 0 | Ocultos: un solo número; todos negativos (el inicial no puede ser 0) |
| `tres-en-uno` | modificar | brote | — | Los tres programas de precios, reescritos con un solo `Mapear` | Aserción: declara `Mapear`. Casos de los tres programas |
| `por-que-pasar` | explicar | semilla | — | ¿Qué se gana al pasar la operación como dato? | El recorrido se escribe una vez |

**Para docentes.** Llamar a la función en lugar de pasarla (`Mapear(v, MasUno(1))`); reducir con un valor inicial
equivocado; querer mapear cuando se necesita filtrar.

**Siguiente.** «Cada semana hay una campaña con otro porcentaje de descuento, que se lee al empezar. ¿Se puede fabricar una
función a partir de un dato?»

---

## 4.3 Funciones que recuerdan — `funcional.clausuras`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `funcional.orden-superior` |
| Introduce | `clausura`, `fabrica-de-funciones` |

**Propósito.** La persona crea funciones que recuerdan valores del momento en que se crearon y escribe fábricas de
funciones.

**Frase.** Una clausura es una función que se lleva consigo los valores que necesita.

**Problema.** Cada semana, el kiosco lanza una campaña de descuento cuyo **porcentaje se lee al empezar** (10, 20, 25…). El
`Mapear` de la lección anterior necesita una función de un solo parámetro, el precio. **¿Cómo se crea esa función si el
porcentaje no se conoce al escribir el programa?**

**Inténtalo.** Escribir en palabras qué función haría falta para 10 % y cuál para 20 %, y qué tienen en común.

**Entender y planear.** Las tres preguntas. Una función que **fabrica** funciones de descuento.

**Herramienta nueva.** Clausura y fábrica de funciones con las figuras `ruta-mochila` y `tipos.funciones#clausura`. La regla
sobre qué se puede capturar la explica la Especificación y se enlaza. Enlace: `tipos.funciones`.

| Id | Programa | Salida |
|---|---|---|
| `sumador` | `CrearSumador(3)` devuelve una función; aplicada a 4 | `7` |

**3. Escribir.** `campanas`: lee el porcentaje, crea el descuento con `CrearDescuento(porcentaje)` y lo mapea sobre precios.
Con 10 y precios 50, 30, 20 → 45, 27, 18.

**4. Probar.** Porcentaje 0 (precios iguales) y 100 (todo en 0).

**5. Mejorar.** Dos campañas a la vez: dos funciones de la misma fábrica, cada una con su mochila.

**Resumen.**

- `{clausura}` Una clausura es una función que recuerda valores del momento en que se creó.
- `{fabrica-de-funciones}` Una fábrica de funciones recibe datos y devuelve una función preparada con ellos.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `sumador-predecir` | predecir | semilla | sí | `s <- CrearSumador(10)`; escribe `s(1)` y `s(s(1))` | `11` ⏎ `21` |
| `captura-cambiante` | encontrar-error | brote | sí | Una fábrica que captura una variable que después se reasigna y no compila | Referencia que captura un valor que no cambia. Casos |
| `multiplicador` | resolver | brote | sí | Lee un factor y luego números hasta 0; muestra cada número multiplicado, con `CrearMultiplicador` | Aserción: declara `CrearMultiplicador`. Ocultos: factor 0; factor -1 |
| `componer` | resolver | árbol | — | `Componer(f, g)` devuelve una función que aplica `g` y después `f` | Casos con `MasUno` y `Doble` en los dos órdenes |
| `mochila` | explicar | semilla | — | ¿Qué hay en la mochila de `CrearDescuento(20)`? | El 20 |

**Para docentes.** Creer que la clausura ve cambios posteriores (en PseudoLearn no puede haberlos: el motor lo impide); confundir
la fábrica con la función fabricada.

**Siguiente.** «Un pedido marcado como entregado no tiene hora de entrega. ¿Se puede hacer que ese error ni siquiera se pueda
escribir?»

---

## 4.4 Datos que no pueden estar mal — `funcional.tipos-dominio`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 40 min · semilla a árbol |
| Necesita | `funcional.clausuras` |
| Introduce | `variante`, `coincidencia-de-patrones`, `generico`, `estado-imposible` |

**Propósito.** La persona modela datos con variantes para que los estados imposibles no se puedan escribir, los recorre con
coincidencia de patrones y reconoce tipos genéricos.

**Frase.** El mejor error es el que no se puede escribir.

**Problema.** El kiosco empezó a hacer envíos. Un pedido es un registro con `estado` (texto), `repartidor`, `hora` y `motivo`.
Aparecieron pedidos «entregados» **sin hora**, «cancelados» **con repartidor** y uno con estado «entrgado». **¿Cómo se
representa un pedido para que esos errores sean imposibles?**

**Inténtalo.** Escribir los estados posibles y qué dato necesita cada uno.

**Entender y planear.** Las tres preguntas. Figura `ruta-estados-pedido`: Pendiente; EnCamino(repartidor);
Entregado(hora); Cancelado(motivo).

**Herramienta nueva.** Variante (figura `tipos.variantes#variante-formas`), coincidencia de patrones con `Segun`, genéricos
(con `Resultado` como ejemplo conocido) y valores inmutables. Enlaces: `tipos.variantes`, `control.segun`, `tipos.genericos`,
`tipos.inmutable`.

| Id | Programa | Salida |
|---|---|---|
| `describir` | `Funcion Describir(p)` con un `Segun` por cada forma; con `EnCamino("Sol")` | `En camino con Sol` |

**3. Escribir.** `pedidos-variante`: `Avanzar(pedido)` devuelve `Resultado<Pedido, Cadena>`: de pendiente a en camino, de en
camino a entregado; avanzar uno entregado o cancelado es un error con motivo.

**4. Probar.** Cada transición válida y cada inválida.

**5. Mejorar.** Agregar el estado `Devuelto(motivo)`: el motor señala cada `Segun` que no lo contempla (el agente verifica si
es un error o una advertencia y lo describe sin repetir la regla).

**Resumen.**

- `{variante}` Una variante es un tipo con varias formas, y cada forma lleva solo los datos que le corresponden.
- `{coincidencia-de-patrones}` La coincidencia de patrones elige qué hacer según la forma de un valor y lee sus datos.
- `{generico}` Un tipo genérico funciona con cualquier tipo de dato, como `Resultado`.
- `{estado-imposible}` Un buen modelo hace que los estados imposibles no se puedan escribir.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `posible-o-no` | clasificar | semilla | sí | Con el modelo de registros: entregado con hora; entregado sin hora; cancelado con motivo; cancelado con repartidor; pendiente sin nada | Posibles con sentido: 1, 3 y 5. Imposibles: 2 y 4 |
| `segun-pedido` | predecir | semilla | sí | `Describir` aplicado a tres pedidos | Las tres líneas |
| `describir-resolver` | resolver | brote | sí | Lee un código de estado (1 a 4) y su dato, arma el pedido y muestra su descripción | Aserción: contiene una variante. Ocultos: los cuatro estados |
| `avanzar` | resolver | árbol | — | `Avanzar` con sus errores | Ocultos: avanzar uno cancelado; dos avances seguidos |
| `registro-a-variante` | modificar | brote | — | El modelo de registros reescrito con una variante, sin cambiar lo que muestra | Casos de la versión inicial |
| `por-que-variante` | explicar | semilla | — | ¿Qué gana el kiosco con la variante? | El pedido sin hora ya no se puede escribir |

**Para docentes.** Una variante con un campo «tipo» adentro; `Segun` con un caso «otro» que esconde formas nuevas; confundir
variante con enumerado (el enumerado no lleva datos).

**Siguiente.** «Ya conoces tres formas de pensar un programa. ¿Cuál conviene para cada problema?»

---

## 4.5 Cara a cara — `funcional.cara-a-cara`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla y brote |
| Necesita | `funcional.tipos-dominio` |
| Introduce | — |

**Propósito.** La persona compara los tres paradigmas sobre el mismo problema y elige uno con criterios, sabiendo que en la
práctica se combinan.

**Frase.** Ningún paradigma gana siempre: cada uno hace fácil un tipo de cambio.

**Problema.** El kiosco va a recibir tres pedidos de cambio: agregar un **impuesto nuevo**, agregar un **medio de pago** y
agregar un **reporte de ventas por día**. Tienes la caja escrita de tres formas: con órdenes que cambian cajas, con objetos y
con funciones. **¿Cuál conviene para cada cambio?**

**Inténtalo.** Elegir a ojo antes de mirar el código.

**Entender y planear.** Las tres preguntas. Figura `ruta-tres-kioscos`.

**3. Escribir.** Programas `kiosco-imperativo`, `kiosco-objetos`, `kiosco-funcional` con el pedido de prueba canónico:
los tres muestran lo mismo.

**4. Probar.** Aplicar cada cambio en cada versión y contar líneas tocadas (tabla).

**5. Mejorar.** Mezcla: núcleo funcional para los cálculos, objetos para lo que tiene estado (inventario), y un borde
imperativo corto.

**Resumen.** Sin términos nuevos. Ítems sin etiqueta:

- Los objetos facilitan agregar tipos nuevos de cosas que comparten un contrato.
- Las funciones facilitan agregar operaciones nuevas sobre los mismos datos.
- Lo imperativo es directo para programas cortos que hacen una cosa.

`RUTA-RECALL-SOURCE` admite ítems sin etiqueta cuando la lección no introduce términos.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `que-paradigma` | clasificar | semilla | sí | Un saldo que sube y baja todo el día; transformar una lista de ventas en un reporte; un programa de 10 líneas que convierte una temperatura; un juego con personajes; estadísticas de notas | Objetos: 1 y 4. Funcional: 2 y 5. Imperativo: 3 |
| `mismo-ticket` | predecir | semilla | — | Las tres versiones con el pedido 3 jugos y 2 sándwiches | La misma salida en las tres |
| `impuesto` | comparar | brote | sí | ¿En qué versión agregar un impuesto toca menos líneas? | La funcional; justificación por opción |
| `medio-nuevo` | comparar | brote | — | ¿Y un medio de pago nuevo? | La de objetos |
| `mezcla` | explicar | brote | sí | ¿Por qué un programa real suele mezclar paradigmas? | Cada parte tiene un tipo de cambio distinto |

**Para docentes.** «Funcional es lo moderno»; elegir por gusto y no por el tipo de cambio esperado.

**Siguiente.** «El kiosco funcional.»

---

## P·IV Proyecto: el kiosco funcional — `funcional.proyecto`

| Campo | Valor |
|---|---|
| Tipo | `proyecto` · 60 min · árbol |
| Necesita | `funcional.cara-a-cara` |

**Problema.** Al final del día, la caja tiene la lista de ventas (código y cantidad). Hay que mostrar un **reporte**: el
total, el total con descuento, cuántas ventas superaron los 5 pesos y el producto estrella (más unidades). Todo el cálculo
va en un núcleo puro; leer y mostrar, en el borde. **¿Cómo es el reporte?**

**Inténtalo.** Ventas de P·I (1 × 3, 2 × 2, 3 × 1, 1 × 1). Respuesta: total 24; con descuento 22; ventas de más de 5 pesos: 2
(9 y 10); estrella: Jugo.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `reporte-nucleo` | clasificar | árbol | sí | Ubicar cada tarea en el núcleo o en el borde | Según el enunciado |
| `reporte-plan` | ordenar | árbol | sí | Pasos del plan (cerca `pasos`) | Orden exacto |
| `reporte` | resolver | árbol | sí | El programa completo | Aserciones: declara `Mapear`, `Filtrar` y `Reducir` como funciones; no hay `Escribir` dentro de funciones (lo garantiza la pureza). Ocultos: día sin ventas; todas las ventas de menos de 5; empate de estrella |
