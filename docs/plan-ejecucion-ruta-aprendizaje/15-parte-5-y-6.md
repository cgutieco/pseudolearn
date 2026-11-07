# 15 — Partes V y VI: Concurrente y el mundo exterior

## Parte V — Concurrente

**Lema:** Varias cosas a la vez.

**Propósito de la parte:** que la persona organice un programa en tareas que avanzan por turnos, coordine tareas con
canales en vez de cajas compartidas y reaccione a lo primero que llega, cancelando lo que ya no hace falta. Tres
lecciones, unas dos horas.

Fases 1 y 2 condensadas (`fase=1-2`) con las preguntas de 03 §3: ¿qué entra y qué sale?, ¿a qué se parece?, **¿qué
puede pasar a la vez y qué tiene que esperar?**

**Regla de toda la parte.** El motor es determinista: la agenda reparte los turnos siempre igual y cada salida se
verifica como cualquier otra. Aun así, **ninguna lección ni ningún ejercicio promete un orden que dependa de cómo la
agenda reparte los turnos**. Lo único que se promete es lo que garantizan `Aguardar`, el cierre de un ámbito `Tareas` y
el orden de los mensajes dentro de un mismo canal. Las salidas de los programas de la lección se publican tal como las da
el motor, y la prosa dice qué parte de ese orden está garantizada y cuál no. Los ejercicios `predecir` y `rastrear` solo
preguntan por valores que no dependen de los turnos (una suma, una cantidad, el último mensaje de un canal).

**Limitación conocida del motor.** Leer después de `FinTareas` una variable declarada fuera del ámbito y modificada
dentro de un `Mientras` que recibe de un canal termina con `internalFault`. Los programas de la parte declaran y
escriben esos contadores **dentro** del ámbito `Tareas`. Es un pendiente del motor, no una regla del lenguaje.

---

## 5.1 Varias cosas a la vez — `concurrente.tareas`

| Campo | Valor |
|---|---|
| Tipo | `apertura` · 35 min · semilla a árbol |
| Necesita | `funcional.proyecto` |
| Introduce | `programacion-concurrente`, `concurrencia`, `tarea`, `agenda` |
| Pieza | 7 |
| Menciones cotidianas | — (`tarea` no es estricto; en el problema solo se habla de cocineros y platos) |

**Propósito.** La persona reconoce cuándo un problema tiene partes que pueden avanzar a la vez, las escribe como tareas
dentro de un ámbito, espera sus resultados y entiende con la agenda que «a la vez» significa «por turnos».

**Por qué así.** La concurrencia se presenta con su forma más segura: tareas hijas que el ámbito espera siempre. No hay
cajas compartidas entre tareas; eso queda para el problema de la lección siguiente.

**Frase.** Un programa concurrente reparte el trabajo en tareas que avanzan por turnos, y espera a todas antes de seguir.

**Problema.** La cocina del kiosco tiene **tres cocineros**: uno prepara **3 jugos** de 3 pesos, otro **2 sándwiches** de
5 pesos y otro **4 frutas** de 2 pesos. La bandeja sale al mostrador **solo cuando los tres terminaron**, y en el ticket va
el valor total de la bandeja. Hasta ahora, cada programa hacía una cosa después de otra. **¿Cómo se escribe una cocina
donde los tres trabajan a la vez y la bandeja espera a todos?**

**Inténtalo.** Calcular el valor de la bandeja y decir qué tiene que pasar antes de entregarla. Respuesta: 9 + 10 + 8 =
**27 pesos**; la bandeja espera a que terminen los tres, sin importar quién termina primero.

**Un paradigma nuevo.** `paradigma`:

- Pregunta: ¿y si un programa fuera un equipo de trabajadores que avanzan por turnos y se esperan cuando hace falta?
- Metáfora: una cocina con varios cocineros y una sola hornalla que se turnan. Deja de valer en que un cocinero puede
  decidir solo cuándo cede la hornalla; una tarea cede su turno solo cuando espera algo.
- Historia: en 1965, Edsger Dijkstra publicó cómo coordinar procesos que comparten recursos. En 1978, Tony Hoare
  describió los procesos que se comunican enviándose mensajes, la idea que usan los canales.
- Costo: hay que pensar qué puede pasar a la vez y qué tiene que esperar; los errores aparecen solo con ciertos turnos.

Definición de programación concurrente y de concurrencia. Comparación breve con los paradigmas anteriores (tabla de la
fase 5).

**1-2. Entender y planear.** Lista:

- ¿Qué entra y qué sale? Entran tres pedidos con precio y cantidad; sale el valor de la bandeja.
- ¿A qué se parece? Al boletín de la Parte II: tres cálculos iguales con datos distintos.
- ¿Qué puede pasar a la vez y qué tiene que esperar? Los tres platos son independientes; la bandeja espera a los tres.

**Herramienta nueva.** Definición de tarea. `Tareas`, `Lanzar` y `Aguardar` con la figura de la Especificación
`tareas.ambitos#ambito-tareas`. Definición de agenda con la figura `motor.agenda#agenda-cola` y la figura propia
`ruta-cocina-turnos` (pieza 7): las tareas no corren «al mismo tiempo» en una sola computadora; avanzan por turnos y
una tarea que espera cede el suyo.

| Id | Programa | Salida |
|---|---|---|
| `dos-saludos` | Dos `Lanzar Saludar(...)` dentro de `Tareas`, luego `Escribir "todas terminaron"` | Los dos saludos en el orden que da el motor y `todas terminaron` al final. La prosa dice que solo la última línea está garantizada |

Enlaces: `tareas.suspendible`, `tareas.ambitos`, `motor.agenda`.

**3. Escribir.** `cocina`: `SubProceso Suspendible Cocinar(plato, precio, porciones) Como Entero` escribe `Empieza
<plato>` y devuelve `precio * porciones`; el algoritmo lanza tres tareas `Tarea<Entero>` y escribe `Bandeja: 27 pesos`;
después de `FinTareas`, `Bandeja entregada`. Salida verificada: `Empieza jugos` ⏎ `Empieza sándwiches` ⏎ `Empieza
frutas` ⏎ `Bandeja: 27 pesos` ⏎ `Bandeja entregada`.

**4. Probar.** Qué está garantizado: `Bandeja` va después de los tres `Empieza` porque espera los tres resultados, y
`Bandeja entregada` va al final porque `FinTareas` espera a todas. Qué no está garantizado: el orden entre los tres
`Empieza`. Caso borde: un cocinero con 0 porciones → la bandeja suma 0 por él y igual espera a los tres.

**5. Mejorar.** Tabla que compara imperativo, procedimental, objetos, funcional y concurrente en dos filas: «qué organiza
el programa» y «qué cuesta». Problema abierto: si la cocina tiene que avisarle al mostrador plato por plato, esperar el
final de todo no alcanza.

**Resumen.**

- `{programacion-concurrente,concurrencia}` La programación concurrente organiza un programa en partes que pueden avanzar
  a la vez; la concurrencia es esa posibilidad de avanzar por turnos.
- `{tarea}` Una tarea es un trabajo que se lanza para que avance por su cuenta; su ámbito la espera antes de seguir.
- `{agenda}` La agenda reparte los turnos entre las tareas; una tarea que espera cede su turno a otra.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `suma-tareas` | predecir | semilla | sí | Dos tareas que devuelven `Cuadrado(3)` y `Cuadrado(4)`; se escribe `Aguardar a + Aguardar b` | `25` |
| `que-espera` | clasificar | semilla | sí | Ubicar en «puede ir a la vez» o «tiene que esperar»: lavar la fruta y exprimir jugos; cobrar y entregar el ticket; tostar el pan y cortar la fruta; sumar la bandeja y entregarla | A la vez: 1 y 3. Esperar: 2 y 4 |
| `bandeja` | resolver | brote | sí | Lee las porciones de jugos, sándwiches y frutas; cada plato se calcula en una tarea; muestra `Bandeja: <total> pesos` | Visibles: 3, 2, 4 → `Bandeja: 27 pesos`; 1, 1, 1 → `Bandeja: 10 pesos`. Ocultos: 0, 0, 0 → `Bandeja: 0 pesos`; 0, 2, 0 → `Bandeja: 10 pesos`; 10, 10, 10 → `Bandeja: 100 pesos` |
| `final-garantizado` | explicar | semilla | — | Un programa lanza dos saludos y escribe `listo` después de `FinTareas`. ¿Qué se puede asegurar? Opciones: que `listo` sale último; que Ana saluda antes que Leo; que los saludos salen alternados | La primera |
| `turnos-ordenar` | ordenar | brote | — | Las líneas de `cocina` mezcladas | Casos: sin entradas → la salida de la lección |
| `doble-romper` | romperlo | árbol | — | Un programa calcula en dos tareas el doble y el triple de un número leído y escribe la suma, pero escribe la suma **antes** de aguardar la segunda tarea, usando un valor provisorio 0 | Referencia aguarda las dos. Visible: 0 → 0. Rompe: cualquier número distinto de 0 |

**Para docentes.** «Las tareas corren al mismo tiempo» (figura de turnos); «el orden de la salida siempre será este» (lo
garantizado frente a lo observado); `Lanzar` fuera de `Tareas` (enlazar la sección, no explicar el diagnóstico).

**Bajo el capó.** Una frase y enlace a `motor.agenda`.

**Siguiente.** «La cocina termina los platos de a uno. ¿Cómo le avisa al mostrador cada plato apenas sale, sin que los
dos toquen la misma caja?»

---

## 5.2 Pasarse mensajes — `concurrente.canales`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `concurrente.tareas` |
| Introduce | `canal`, `aislamiento`, `productor-consumidor` |

**Propósito.** La persona coordina dos tareas pasándose mensajes por un canal con capacidad, reconoce el esquema
productor y consumidor y entiende por qué cada tarea guarda sus propios datos.

**Frase.** Dos tareas se coordinan mejor pasándose mensajes que compartiendo cajas.

**Problema.** La cocina prepara los pedidos **1, 2 y 3** y los deja en un **mostrador donde caben 2 platos**. El mostrador
entrega cada pedido apenas llega y, cuando la cocina cierra, dice cuántos entregó. Si el mostrador está lleno, la cocina
espera. **¿Cómo se comunican la cocina y el mostrador sin pisarse?**

**Inténtalo.** ¿Cuántos pedidos entrega y en qué orden? Respuesta: **3**, en el orden en que la cocina los dejó: 1, 2 y 3.

**1-2. Entender y planear.** Lista con las tres preguntas; la tercera: la cocina y el mostrador trabajan a la vez, el
mostrador espera cuando no hay platos y la cocina espera cuando no hay lugar.

**Herramienta nueva.** Definición de canal (figura de la Especificación `tareas.canales#canal-cola` y figura propia
`ruta-mostrador`), de productor y consumidor, y de aislamiento: cada tarea trabaja con sus datos y solo comparte lo que
envía.

| Id | Programa | Salida |
|---|---|---|
| `tuberia-mini` | Un productor envía 10, 20 y 30 por un canal de capacidad 2 y lo cierra; el consumidor escribe cada valor | `recibido 10` ⏎ `recibido 20` ⏎ `recibido 30` |

Enlaces: `tareas.canales`.

**3. Escribir.** `mostrador`: la cocina envía 1, 2 y 3 y cierra; el mostrador, dentro de `Tareas`, recibe hasta que el
canal se cierra, cuenta y escribe. Salida verificada: `Entrego el pedido 1` ⏎ `Entrego el pedido 2` ⏎ `Entrego el pedido
3` ⏎ `Entregados: 3`.

**4. Probar.** Garantizado: el orden 1, 2, 3, porque un canal entrega en el orden en que se envía, y `Entregados` al
final del recibir. Caso borde: la cocina cierra sin enviar nada → `Entregados: 0`. Caso raro: nadie cierra el canal → el
mostrador espera para siempre y el motor lo detecta (programa `bloqueo`, con la terminación real que da el motor).

**5. Mejorar.** Comparar con una versión donde las dos tareas escribieran la misma caja: la lección explica por qué el
lenguaje empuja a los canales (aislamiento). Problema abierto: si hay dos proveedores, ¿a quién se le hace caso?

**Resumen.**

- `{canal}` Un canal es una fila de mensajes entre tareas, con capacidad; entrega en el orden en que se envió.
- `{productor-consumidor}` En el esquema productor y consumidor, una tarea produce mensajes y otra los consume.
- `{aislamiento}` Con aislamiento, cada tarea guarda sus datos y solo comparte lo que envía por un canal.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `canal-suma` | predecir | semilla | sí | Un productor envía 4, 5 y 6 y cierra; el consumidor suma y escribe el total | `15` |
| `canal-tabla` | rastrear | brote | — | El consumidor de `canal-suma` con columnas `valor` y `total`, una fila por mensaje | 4,4; 5,9; 6,15 |
| `pedidos-contar` | resolver | brote | sí | Lee cuántos pedidos prepara la cocina; la cocina los envía numerados por un canal de capacidad 2; el mostrador muestra `Entregados: n` | Visibles: 3 → `Entregados: 3`; 1 → `Entregados: 1`. Ocultos: 0 → `Entregados: 0`; 2 → `Entregados: 2`; 7 → `Entregados: 7` |
| `quien-es-quien` | clasificar | semilla | sí | Ubicar en productor o consumidor: la cocina que deja platos; el mostrador que los entrega; un sensor que manda temperaturas; la pantalla que las muestra | Productor: 1 y 3. Consumidor: 2 y 4 |
| `sin-cerrar` | encontrar-error | brote | — | El productor envía los pedidos y nunca cierra el canal; el programa no termina bien | Referencia con `Cerrar`. Visibles: 3 → `Entregados: 3`; 1 → `Entregados: 1`. Ocultos: 0, 2, 5 |
| `promedio-sensor` | resolver | árbol | — | Lee 5 temperaturas; un productor las envía y el consumidor muestra el promedio | Visibles: 20,22,24,26,28 → `24.0`; 10×5 → `10.0`. Ocultos: 0×5 → `0.0`; -5,5,-5,5,0 → `0.0`; 1,2,3,4,5 → `3.0` |

**Para docentes.** «Dos tareas pueden escribir la misma caja sin problema»; olvidar cerrar el canal; esperar que un
canal lleno descarte mensajes.

**Siguiente.** «Dos proveedores pueden traer el pan. ¿Cómo se atiende al que llega primero y se cancela lo que ya no hace
falta?»

---

## 5.3 Lo primero que llegue — `concurrente.elegir`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `concurrente.canales` |
| Introduce | `cancelacion` |

**Propósito.** La persona espera en varios canales a la vez y atiende el primero listo con `Elegir`, y entiende que un
error en una tarea cancela a sus hermanas.

**Frase.** Cuando varias respuestas pueden llegar, se atiende la primera y se cancela lo que ya no hace falta.

**Problema.** El kiosco pide fruta a **tres proveedores** a la vez: Norte, Sur y Este. Si **alguno no tiene stock**, el
pedido completo se suspende y no tiene sentido seguir esperando a los demás. **¿Cómo se escribe el pedido para que el
primer problema detenga todo, y cómo se sabe cuántas consultas se cortaron?**

**Inténtalo.** Norte no tiene stock; Sur tiene 5 y Este 3. Respuesta: el pedido se suspende por Norte y se cortan las
otras **dos** consultas.

**1-2. Entender y planear.** Lista con las tres preguntas; la tercera: las tres consultas van a la vez; la primera falla
corta a las otras.

**Herramienta nueva.** `Elegir` con la figura propia `ruta-carrera`: espera en varios canales y atiende el primero que
está listo. Definición de cancelación con el nombre de fallo del ámbito (`Tareas fallo`, `f.Primero`, `f.Canceladas`).

| Id | Programa | Salida |
|---|---|---|
| `primera-oferta` | Dos proveedores envían su oferta por canales distintos; `Elegir` atiende la primera | La salida que da el motor. La prosa dice que **cuál** llega primero lo decide la agenda y no se puede asumir |

Enlaces: `tareas.canales`, `tareas.ambitos`.

**3. Escribir.** `proveedores`: `SubProceso Suspendible Consultar(nombre, stock) Como Resultado<Entero, Cadena>` devuelve
`Error(nombre + " no tiene stock")` si el stock es 0; el ámbito `Tareas fallo` lanza tres consultas y después escribe
`Falló: …` y `Canceladas: …`, o `Todos confirmaron`. Salida verificada con Norte 0, Sur 5, Este 3: `Falló: Norte no tiene
stock` ⏎ `Canceladas: 2`.

**4. Probar.** Caso normal: los tres con stock → `Todos confirmaron`. Caso borde: el último en fallar es el único sin
stock. Caso raro: los tres sin stock → el primer error manda y los demás quedan como asociados o cancelados. La prosa no
promete cuál es «el primero» cuando dos fallan; los casos verificados de los ejercicios tienen como mucho un error.

**5. Mejorar.** Comparar `Elegir` con esperar las respuestas una tras otra: con una sola respuesta que importa, esperar
todas desperdicia la espera.

**Resumen.**

- `{cancelacion}` Cancelar es cortar una tarea que ya no hace falta; en un ámbito, el primer error cancela a las hermanas.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `canceladas` | predecir | semilla | sí | El programa de la lección con stock 3, 0, 2 | `Falló: Sur no tiene stock` ⏎ `Canceladas: 2` |
| `todos-bien` | predecir | semilla | — | El mismo con 1, 1, 1, sin las líneas que escriben confirmaciones | `Todos confirmaron` |
| `pedido-resolver` | resolver | brote | sí | Lee el stock de tres proveedores; si alguno tiene 0, muestra `Pedido suspendido`; si no, `Pedido confirmado: <suma>` | Visibles: 5, 3, 2 → `Pedido confirmado: 10`; 0, 3, 2 → `Pedido suspendido`. Ocultos: 1, 1, 1 → `Pedido confirmado: 3`; 4, 4, 0 → `Pedido suspendido`; 9, 0, 9 → `Pedido suspendido` |
| `elegir-o-esperar` | comparar | brote | sí | Solo importa la primera oferta de pan. Ana espera las dos ofertas una tras otra; Beto usa `Elegir`. ¿Quién atiende antes? | Beto: atiende la primera lista sin esperar la otra |
| `cancelar-clasificar` | clasificar | semilla | — | Ubicar en «conviene cancelar» o «hay que esperar»: buscar un libro en tres bibliotecas y ya apareció; sumar las ventas de tres cajas; pedir un taxi a dos empresas y ya llegó uno; cocinar los tres platos de una bandeja | Cancelar: 1 y 3. Esperar: 2 y 4 |
| `pedido-pruebas` | disenar-pruebas | árbol | — | Entre 2 y 4 casos para `pedido-resolver` | Mutantes: solo revisa el primer proveedor; usa `< 0` en vez de `= 0`; confirma con la suma de los dos primeros. Solución: 5,3,2; 0,3,2; 4,4,0 |

**Para docentes.** «`Elegir` atiende siempre al mismo» (lo decide la agenda: no se asume); «cancelar borra lo que la tarea
ya hizo» (lo ya escrito queda); confundir cancelar con fallar.

**Siguiente.** «Al cerrar el kiosco, todo lo que el programa sabía se pierde. ¿Cómo se guarda para mañana?»

---

## Parte VI — El mundo exterior

**Lema:** Hablar con lo que está afuera del programa.

**Propósito de la parte:** que la persona guarde y lea archivos pidiendo permiso, deje la limpieza escrita junto a lo
que la necesita, intercambie datos en JSON y consulte un servicio por HTTP, separando siempre lo que se calcula de lo
que toca el mundo. Tres lecciones y el proyecto final, unas tres horas.

Fases 1 y 2 condensadas con las preguntas de 03 §3: ¿qué entra y qué sale?, ¿a qué se parece?, **¿qué puede fallar
afuera del programa?**

**Regla de los ejercicios.** El comprobador de la app no tiene anfitrión de archivos ni de red. Por eso, en esta parte,
los ejercicios comprobados (`resolver`, `modificar`, `encontrar-error`, `romperlo`, `disenar-pruebas`, `predecir`,
`rastrear`, `ordenar` con programa) **solo prueban funciones puras**: reciben texto o números por `Leer` y devuelven
valores, sin pedir capacidades. Los programas completos de la lección se ejecutan en el compilador con el anfitrión de
memoria (bloque `anfitrion`) y en la app se ofrecen para abrir en el editor, sin comprobación.

---

## 6.1 Guardar para mañana — `exterior.archivos`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `concurrente.elegir` |
| Introduce | `archivo`, `capacidad`, `limpieza-diferida` |

**Propósito.** La persona guarda y lee el inventario en un archivo de texto, pide la capacidad para hacerlo, trata el
error de un archivo que falta y escribe la limpieza junto a lo que la necesita.

**Frase.** Lo que está en la memoria se pierde al cerrar; lo que se guarda en un archivo queda para mañana.

**Problema.** El kiosco cierra cada día con el stock de sus cinco productos (jugo 10, sándwich 5, alfajor 8, agua 12,
fruta 6). Al día siguiente el programa empieza otra vez desde cero y **el stock se perdió**. **¿Cómo se guarda el stock
para la próxima vez, y qué pasa si el archivo todavía no existe?**

**Inténtalo.** ¿Qué tendría que decir el programa el primer día, cuando nunca se guardó nada? Respuesta: que no hay
inventario guardado, y empezar con el stock inicial.

**1-2. Entender y planear.** Lista con las tres preguntas; la tercera: el archivo puede no existir, la carpeta puede no
dar permiso.

**Herramienta nueva.** Definición de archivo con la figura propia `ruta-memoria-y-disco` y la figura de la
Especificación `biblioteca.archivos#archivo-capas`. Definición de capacidad: el programa pide permiso para tocar una
carpeta y puede recibir un error. Limpieza diferida con `Diferir` y la figura `control.diferir#diferir-pila`.

| Id | Programa | Salida |
|---|---|---|
| `puerta-luz` | Dos `Diferir` que cierran la puerta y apagan la luz | `abro la puerta` ⏎ `enciendo la luz` ⏎ `leo un rato` ⏎ `apago la luz` ⏎ `cierro la puerta` |

Enlaces: `biblioteca.archivos`, `control.diferir`, `tareas.efectos`.

**3. Escribir.** `inventario-archivo`, con anfitrión de memoria vacío: una función pura `LineaStock(nombre, stock)` arma
`jugo;10`; un subprograma guarda las cinco líneas en `stock.txt` y otro lo lee. Salida verificada con la ejecución real
del anfitrión de memoria. `inventario-sin-archivo`: leer sin haber guardado escribe `No hay inventario guardado`.

**4. Probar.** Tabla: primer día (sin archivo), día con archivo, archivo con una línea vacía. La parte pura (`LineaStock`
y su inversa `StockDeLinea`) se prueba con casos como cualquier función; la parte con efectos, con el anfitrión de
memoria.

**5. Mejorar.** Separar núcleo puro (armar y leer líneas) y borde con efectos (abrir y escribir), como en la Parte IV.

**Resumen.**

- `{archivo}` Un archivo guarda texto fuera de la memoria; sigue ahí cuando el programa termina.
- `{capacidad}` Una capacidad es el permiso que el programa pide para tocar algo de afuera; pedirla puede fallar.
- `{limpieza-diferida}` Una limpieza diferida se escribe junto a lo que la necesita y se ejecuta al salir, en orden
  inverso.

**Ejercicios.** Todos los comprobados prueban funciones puras.

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `orden-diferir` | predecir | semilla | sí | Tres `Diferir` que escriben `1`, `2` y `3`, y un `Escribir "fin"` | `fin` ⏎ `3` ⏎ `2` ⏎ `1` |
| `linea-stock` | resolver | semilla | sí | Lee un nombre y un stock y muestra la línea del archivo: `nombre;stock` | Visibles: jugo, 10 → `jugo;10`; agua, 0 → `agua;0`. Ocultos: fruta, 6 → `fruta;6`; alfajor, 125 → `alfajor;125`; té, 1 → `té;1` |
| `stock-de-linea` | resolver | brote | sí | Lee una línea `nombre;stock` y muestra `nombre tiene stock`; si no hay `;`, `Línea inválida` | Visibles: `jugo;10` → `jugo tiene 10`; `agua` → `Línea inválida`. Ocultos: `fruta;0` → `fruta tiene 0`; `;5` → ` tiene 5`; `x;y;3` → la salida que da la referencia, decidida en la ficha del ejercicio |
| `que-puede-fallar` | clasificar | semilla | — | Ubicar en «puede fallar afuera» o «es cálculo»: abrir `stock.txt`; sumar el stock; pedir permiso a la carpeta; armar la línea `jugo;10` | Afuera: 1 y 3. Cálculo: 2 y 4 |
| `limpieza-lugar` | explicar | brote | — | ¿Por qué se escribe `Diferir` justo después de abrir? Opciones: para que la limpieza no se olvide aunque el subprograma salga antes; porque se ejecuta enseguida; porque así es más rápido | La primera |
| `linea-pruebas` | disenar-pruebas | árbol | — | Entre 2 y 4 casos para `stock-de-linea` | Mutantes: no revisa el `;`; corta en el último `;`; muestra el nombre sin el stock. Solución: `jugo;10`; `agua`; `x;y;3` |

**Para docentes.** «El archivo se guarda solo»; «si el archivo no existe, el programa se cae» (es un `Error` que se
trata); `Diferir` que se ejecuta en el lugar donde se escribe.

**Siguiente.** «Otra aplicación quiere leer el inventario. ¿En qué forma se escribe para que cualquier programa lo
entienda?»

---

## 6.2 Datos que se entienden entre programas — `exterior.json`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `exterior.archivos` |
| Introduce | `json`, `serializar` |

**Propósito.** La persona convierte el inventario en texto JSON con una función pura, lo vuelve a leer con
`AnalizarJson` y trata un texto mal formado como un error con lugar.

**Frase.** JSON es una forma de escribir datos como texto que cualquier programa sabe leer.

**Problema.** La escuela tiene una página que muestra el inventario del kiosco, pero no sabe leer `jugo;10`: espera
**JSON**. Hay que **exportar** los cinco productos con su stock. **¿Cómo se escribe el inventario para que otro programa lo
entienda, y cómo se comprueba que quedó bien?**

**Inténtalo.** Escribir a mano el JSON de dos productos. Respuesta: `{"jugo": 10, "sandwich": 5}`.

**1-2. Entender y planear.** Lista con las tres preguntas; la tercera: el texto que llega de afuera puede estar roto.

**Herramienta nueva.** Definición de JSON con la figura de la Especificación `biblioteca.json#json-arbol` y la figura
propia `ruta-json-viaje`. Serializar: convertir un dato en texto para que viaje. `AnalizarJson` y `TextoJson`.

| Id | Programa | Salida |
|---|---|---|
| `ficha-json` | Analiza `{"nombre": "Ana", "edad": 15}` y escribe la edad | `edad: 15` |

Enlaces: `biblioteca.json`, `expresiones.concatenacion`.

**3. Escribir.** `exportar`: función pura `InventarioJson` que concatena las cinco entradas; el algoritmo la escribe y la
vuelve a analizar con `AnalizarJson` para comprobar que es válida. Salida verificada:
`{"jugo": 10, "sandwich": 5, "alfajor": 8, "agua": 12, "fruta": 6}` y `Válido: 5 productos`.

**4. Probar.** Caso normal; caso borde: inventario de un producto (sin comas); caso raro: un texto con coma final →
`SintaxisInvalida` con línea y columna reales.

**5. Mejorar.** Comparar `jugo;10` con JSON: qué gana y qué cuesta cada formato.

**Resumen.**

- `{json}` JSON escribe datos como texto con objetos, listas, números y textos; lo leen casi todos los programas.
- `{serializar}` Serializar es convertir un dato en texto para guardarlo o enviarlo, y poder reconstruirlo.

**Ejercicios.** Todos los comprobados prueban funciones puras.

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `json-campo` | predecir | semilla | sí | Analiza `{"jugo": 10, "agua": 12}` y escribe la cantidad de claves | `2` |
| `par-json` | resolver | semilla | sí | Lee un nombre y un stock y muestra `{"nombre": stock}` | Visibles: jugo, 10 → `{"jugo": 10}`; agua, 0 → `{"agua": 0}`. Ocultos: fruta, 6; alfajor, 125; sandwich, 1 |
| `valido-o-no` | resolver | brote | sí | Lee un texto y muestra `Válido` si es JSON, o el código de error y su columna | Visibles: `{"a": 1}` → `Válido`; `{"a": 1,}` → la salida real del motor. Ocultos: `[]` → `Válido`; `{` → la salida real; `{"a" 1}` → la salida real |
| `formato` | comparar | semilla | — | Para la página de la escuela, ¿`jugo;10` o `{"jugo": 10}`? | JSON: la página ya sabe leerlo y no hay que inventar reglas para el `;` |
| `json-clasificar` | clasificar | semilla | — | Ubicar en «JSON válido» o «no válido»: `{"a": 1}`; `{a: 1}`; `[1, 2]`; `{"a": 1,}` | Válido: 1 y 3. No: 2 y 4 |
| `dos-pares` | resolver | árbol | — | Lee dos nombres con su stock y muestra el objeto JSON con los dos | Visibles: jugo 10, agua 12 → `{"jugo": 10, "agua": 12}`; a 0, b 0 → `{"a": 0, "b": 0}`. Ocultos: tres casos más |

**Para docentes.** Comillas simples en JSON; la coma final; creer que JSON es un tipo de archivo y no una forma de
escribir texto.

**Siguiente.** «El precio de la fruta importada depende del tipo de cambio del día, y ese dato está en internet. ¿Cómo se
le pregunta?»

---

## 6.3 Hablar con internet — `exterior.http`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `exterior.json` |
| Introduce | `peticion`, `codigo-de-estado` |

**Propósito.** La persona pide un dato a un servicio por HTTP con la capacidad de red, revisa el código de estado y
convierte la respuesta en un valor con una función pura.

**Frase.** Un programa le pregunta algo a otro por internet enviando una petición, y la respuesta trae un código que dice
cómo le fue.

**Problema.** La fruta importada cuesta **2 dólares**, y el kiosco cobra en pesos según el **tipo de cambio del día**, que
publica un servicio en internet. A veces el servicio responde y a veces no. **¿Cuánto cobra hoy el kiosco por la fruta
importada, y qué hace si el servicio no responde?**

**Inténtalo.** Si el servicio dice que un dólar vale 20 pesos, ¿cuánto cuesta la fruta? Respuesta: **40 pesos**. Si no
responde, el kiosco no puede inventar un precio: avisa.

**1-2. Entender y planear.** Lista con las tres preguntas; la tercera: la red puede no estar, el servicio puede
responder un error, la respuesta puede venir mal escrita.

**Herramienta nueva.** Definición de petición y de código de estado con la figura de la Especificación
`biblioteca.http#http-ida-vuelta`. La capacidad de red se pide igual que la de archivos.

| Id | Programa | Salida |
|---|---|---|
| `clima` | Pide `https://clima.test/hoy` con el anfitrión de memoria | `Estado: 200` ⏎ `Soleado, 25` |

Enlaces: `biblioteca.http`, `biblioteca.json`.

**3. Escribir.** `cambio`: con anfitrión de memoria que responde `{"dolar": 20}` con estado 200, una función pura
`PrecioEnPesos(dolares, cambio)` y el borde que pide la red. Salida verificada: `Fruta importada: 40 pesos`.
`cambio-caido`: anfitrión que responde 503 → `Servicio no disponible (503)`.

**4. Probar.** Casos: 200 con dato; 503; 200 con JSON roto. La función pura se prueba sola.

**5. Mejorar.** Núcleo puro y borde: solo el borde cambia si mañana el dato viene de un archivo.

**Resumen.**

- `{peticion}` Una petición le pide algo a otro programa por internet; la respuesta llega con un cuerpo de texto.
- `{codigo-de-estado}` El código de estado dice cómo le fue a la petición: 200 es bien; 400 y 500 son problemas.

**Ejercicios.** Todos los comprobados prueban funciones puras.

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `estado-clasificar` | clasificar | semilla | sí | Ubicar 200, 404, 503 y 201 en «salió bien» o «hubo un problema» | Bien: 200 y 201. Problema: 404 y 503 |
| `precio-pesos` | resolver | semilla | sí | Lee el precio en dólares y el tipo de cambio y muestra el precio en pesos | Visibles: 2, 20 → 40; 0, 20 → 0. Ocultos: 3, 21 → 63; 1, 1 → 1; 10, 0 → 0 |
| `que-hacer` | resolver | brote | sí | Lee un código de estado y un número; si el código es 200 muestra `Precio: <2 × número>`; si no, `Servicio no disponible (<código>)` | Visibles: 200, 20 → `Precio: 40`; 503, 20 → `Servicio no disponible (503)`. Ocultos: 404, 1; 200, 0; 201, 5 → `Servicio no disponible (201)` |
| `predecir-estado` | predecir | semilla | — | Una función pura que devuelve `"bien"` si el código está entre 200 y 299 y `"problema"` si no; se llama con 204 y con 301 | `bien` ⏎ `problema` |
| `que-romper` | romperlo | brote | — | Un programa decide «bien» solo con `codigo = 200` | Referencia con el rango 200 a 299. Visibles: 200, 503. Rompe: 201, 204 |
| `borde-o-nucleo` | clasificar | árbol | — | Ubicar en núcleo puro o borde: pedir la red; calcular el precio; leer el JSON de la respuesta; escribir el precio | Núcleo: 2 y 3. Borde: 1 y 4 |

**Para docentes.** «Si hay internet, siempre responde 200»; mezclar el cálculo con la petición; creer que la app puede
probar la red sin un anfitrión simulado.

**Siguiente.** «Ya tienes todas las piezas. ¿Cómo queda el kiosco completo?»

---

## P·F Proyecto final: el kiosco completo — `exterior.proyecto`

| Campo | Valor |
|---|---|
| Tipo | `proyecto` · 90 min · árbol |
| Necesita | `exterior.http` |
| Introduce | — |

**Propósito.** Integrar las seis partes: el kiosco guarda su inventario en un archivo JSON, lo carga al abrir, vende con
validación y descuento, y lo vuelve a guardar al cerrar.

**Frase.** Un programa completo es un núcleo que calcula y un borde que habla con el mundo.

**Problema.** Al abrir, el kiosco lee `inventario.json`; si no existe, empieza con el stock inicial (jugo 10, sándwich 5,
alfajor 8, agua 12, fruta 6). Vende durante el recreo con las reglas de la Parte II (validar código y stock) y el
descuento de 03 §5.1. Al cerrar, guarda el inventario nuevo en `inventario.json` y muestra el ticket. **¿Cómo es el
kiosco completo?**

**Inténtalo.** Primer día sin archivo, ventas 1 × 3, 2 × 2, fin. Respuesta: total 19, con descuento 18; el archivo nuevo
dice jugo 7 y sándwich 3.

**Fases.** Las cinco separadas. La ficha y el plan son ejercicios. El programa completo, con archivo, se ofrece en la
lección para abrir en el editor y se verifica en el compilador con el anfitrión de memoria; el ejercicio comprobado es su
núcleo puro.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `final-ficha` | clasificar | árbol | sí | Ubicar cada dato del enunciado: archivo de inventario, stock inicial, código, cantidad, el 0, precios, descuento, ticket, inventario nuevo, hora del recreo | Entra: archivo, código, cantidad, 0. Dato fijo: stock inicial, precios, descuento. Sale: ticket, inventario nuevo. No importa: hora |
| `final-plan` | ordenar | árbol | sí | Pasos del plan en lenguaje natural: cargar el inventario o usar el inicial; leer ventas hasta 0 validando; calcular total y descuento; armar el JSON nuevo; guardar con limpieza diferida; mostrar el ticket | Orden exacto |
| `final-nucleo` | resolver | árbol | sí | El núcleo puro del kiosco: lee las ventas hasta 0, valida código y stock con el stock inicial, y muestra el ticket con total y descuento, seguido del inventario final en JSON | Visibles: el del Inténtalo; un día sin ventas. Ocultos: venta inválida en medio; venta que deja un stock en 0; venta que pide más de lo que hay; los cinco productos; cantidades grandes rechazadas; día con solo rechazos |

**Para docentes.** Planear antes de abrir el editor; separar núcleo y borde; probar el día sin archivo.
