# 04 — Términos, máquina nocional y figuras

## 1. Catálogo de términos

Fuente de `route/<idioma>/terminos.json` y de los campos `introduce` de cada lección. **E** = `estricto` (se detecta
en la prosa sin marcado). **R** = `receta` (prohibido en enunciados). La columna «Formas» lista las formas de
superficie en español; la edición inglesa define las suyas.

### Unidad 0

| Id | Etiqueta | Formas | E | R | Dueña |
|---|---|---|---|---|---|
| `problema` | problema | problema, problemas | — | — | 0.1 |
| `ejemplo-a-mano` | ejemplo a mano | ejemplo a mano, ejemplos a mano | sí | — | 0.1 |
| `programa` | programa | programa, programas | — | — | 0.1 |
| `instruccion` | instrucción | instrucción, instrucciones | — | — | 0.1 |
| `ejecutar` | ejecutar | ejecutar, ejecuta, ejecución | — | — | 0.1 |
| `salida` | salida | salida | — | — | 0.1 |
| `funcion-ya-hecha` | función ya hecha | función ya hecha, funciones ya hechas | sí | — | 0.1 |
| `ciclo-pseudolearn` | el ciclo PseudoLearn | ciclo PseudoLearn | sí | — | 0.1 |
| `variable` | variable | variable, variables | sí | — | 0.2 |
| `valor` | valor | valor, valores | — | — | 0.2 |
| `memoria` | memoria | memoria | — | — | 0.2 |
| `tipo-de-dato` | tipo de dato | tipo de dato, tipos de dato | sí | — | 0.2 |
| `declarar` | declarar | declarar, declara, declaración | sí | — | 0.2 |
| `asignar` | asignar | asignar, asigna, asignación | sí | — | 0.2 |
| `division-entera` | división entera y resto | división entera, resto | sí | sí | 0.2 |
| `entrada` | entrada | entrada, entradas | — | — | 0.3 |
| `leer-dato` | leer un dato | leer un dato | — | — | 0.3 |
| `ficha-del-problema` | ficha del problema | ficha del problema | sí | — | 0.3 |
| `error-de-compilacion` | error al compilar | error al compilar, errores al compilar | sí | — | 0.4 |
| `error-de-ejecucion` | error al ejecutar | error al ejecutar, errores al ejecutar | sí | — | 0.4 |
| `error-de-logica` | error de lógica | error de lógica, errores de lógica | sí | — | 0.4 |
| `diagnostico` | diagnóstico | diagnóstico, diagnósticos | sí | — | 0.4 |
| `caso-de-prueba` | caso de prueba | caso de prueba, casos de prueba | sí | — | 0.4 |
| `caso-borde` | caso borde | caso borde, casos borde | sí | — | 0.4 |

### Parte I

| Id | Etiqueta | Formas | E | R | Dueña |
|---|---|---|---|---|---|
| `paradigma` | paradigma | paradigma, paradigmas | sí | — | 1.1 |
| `programacion-imperativa` | programación imperativa | programación imperativa | sí | — | 1.1 |
| `condicion` | condición | condición, condiciones | — | — | 1.1 |
| `valor-logico` | valor lógico | valor lógico, valores lógicos | sí | — | 1.1 |
| `comparacion` | comparación | comparación, comparaciones | — | — | 1.1 |
| `decision` | decisión | decisión, decisiones | — | sí | 1.1 |
| `instruccion-actual` | instrucción actual | instrucción actual | sí | — | 1.1 |
| `particion-de-casos` | partición de casos | partición de casos | sí | — | 1.1 |
| `condicion-compuesta` | condición compuesta | condición compuesta, condiciones compuestas | sí | sí | 1.2 |
| `tabla-de-decision` | tabla de decisión | tabla de decisión, tablas de decisión | sí | — | 1.2 |
| `seleccion-multiple` | selección múltiple | selección múltiple | sí | sí | 1.2 |
| `anidar` | anidar | anidar, anidado, anidada, anidados | sí | sí | 1.2 |
| `bucle` | bucle | bucle, bucles | sí | sí | 1.3 |
| `vuelta` | vuelta | vuelta, vueltas | — | — | 1.3 |
| `rol-de-variable` | rol de una variable | rol, roles | sí | — | 1.3 |
| `contador` | contador | contador, contadores | sí | sí | 1.3 |
| `acumulador` | acumulador | acumulador, acumuladores | sí | sí | 1.3 |
| `tabla-por-vuelta` | tabla por vuelta | tabla por vuelta | sí | — | 1.3 |
| `invariante` | invariante | invariante, invariantes | sí | — | 1.3 |
| `bucle-infinito` | bucle infinito | bucle infinito | sí | — | 1.3 |
| `centinela` | centinela | centinela, centinelas | sí | sí | 1.3 |
| `bucle-contado` | bucle contado | bucle contado | sí | sí | 1.4 |
| `bucle-posterior` | bucle que pregunta al final | bucle que pregunta al final | sí | sí | 1.4 |
| `bandera` | bandera | bandera, banderas | sí | sí | 1.4 |
| `mejor-hasta-ahora` | mejor hasta ahora | mejor hasta ahora | sí | sí | 1.4 |
| `salida-anticipada` | salida anticipada | salida anticipada | sí | sí | 1.4 |
| `arreglo` | arreglo | arreglo, arreglos | sí | sí | 1.5 |
| `indice` | índice | índice, índices | sí | — | 1.5 |
| `recorredor` | recorredor | recorredor | sí | sí | 1.5 |
| `fuera-de-rango` | fuera de rango | fuera de rango | sí | — | 1.5 |
| `esquema` | esquema | esquema, esquemas | sí | sí | 1.6 |
| `seguidor` | seguidor | seguidor, seguidores | sí | sí | 1.6 |
| `matriz` | matriz | matriz, matrices | sí | sí | 1.7 |
| `bucle-anidado` | bucle anidado | bucle anidado, bucles anidados | sí | sí | 1.7 |
| `concatenar` | concatenar | concatenar, concatenación | sí | — | 1.7 |
| `estrategia` | estrategia | estrategia, estrategias | — | — | 1.8 |
| `fuerza-bruta` | fuerza bruta | fuerza bruta | sí | sí | 1.8 |
| `busqueda-binaria` | búsqueda binaria | búsqueda binaria | sí | sí | 1.8 |
| `costo` | costo de un algoritmo | costo | — | — | 1.8 |
| `ordenamiento-por-seleccion` | ordenamiento por selección | ordenamiento por selección | sí | sí | 1.8 |

### Parte II

| Id | Etiqueta | Formas | E | R | Dueña |
|---|---|---|---|---|---|
| `programacion-procedimental` | programación procedimental | programación procedimental | sí | — | 2.1 |
| `descomposicion` | descomposición | descomposición | sí | — | 2.1 |
| `arbol-de-descomposicion` | árbol de descomposición | árbol de descomposición | sí | — | 2.1 |
| `subprograma` | subprograma | subprograma, subprogramas | sí | sí | 2.1 |
| `llamada` | llamada | llamada, llamadas, llamar | sí | — | 2.1 |
| `parametro` | parámetro | parámetro, parámetros | sí | sí | 2.1 |
| `valor-de-retorno` | valor de retorno | valor de retorno | sí | — | 2.1 |
| `ambito` | ámbito | ámbito, ámbitos | sí | — | 2.2 |
| `paso-por-valor` | paso por valor | por valor | sí | — | 2.2 |
| `paso-por-referencia` | paso por referencia | por referencia | sí | sí | 2.2 |
| `pila-de-llamadas` | pila de llamadas | pila de llamadas | sí | — | 2.2 |
| `marco` | marco | marco, marcos | sí | — | 2.2 |
| `efecto` | efecto | efecto, efectos | — | — | 2.3 |
| `funcion-pura` | función pura | función pura, funciones puras | sí | sí | 2.3 |
| `recursion` | recursión | recursión, recursivo, recursiva | sí | sí | 2.4 |
| `caso-base` | caso base | caso base | sí | sí | 2.4 |
| `caso-recursivo` | caso recursivo | caso recursivo | sí | sí | 2.4 |
| `registro` | registro | registro, registros | sí | sí | 2.5 |
| `campo` | campo | campo, campos | — | — | 2.5 |
| `enumerado` | enumerado | enumerado, enumerados | sí | sí | 2.5 |
| `vector` | vector | vector, vectores | sí | sí | 2.5 |
| `diccionario` | diccionario | diccionario, diccionarios | sí | sí | 2.5 |
| `clave` | clave | clave, claves | — | — | 2.5 |
| `valor-opcional` | valor que puede faltar | valor que puede faltar | sí | — | 2.6 |
| `resultado-con-error` | resultado con error | resultado con error | sí | — | 2.6 |
| `propagar` | propagar un error | propagar | sí | sí | 2.6 |
| `validar` | validar | validar, validación | — | — | 2.6 |
| `modulo` | módulo | módulo, módulos | sí | sí | 2.7 |
| `importar` | importar | importar, importación | sí | — | 2.7 |
| `visibilidad` | visibilidad | visibilidad, público, privado | sí | — | 2.7 |

### Parte III

| Id | Etiqueta | Formas | E | R | Dueña |
|---|---|---|---|---|---|
| `programacion-orientada-a-objetos` | programación orientada a objetos | orientada a objetos | sí | — | 3.1 |
| `objeto` | objeto | objeto, objetos | sí | sí | 3.1 |
| `clase` | clase | clase, clases | sí | sí | 3.1 |
| `atributo` | atributo | atributo, atributos | sí | sí | 3.1 |
| `metodo` | método | método, métodos | sí | sí | 3.1 |
| `constructor` | constructor | constructor, constructores | sí | sí | 3.1 |
| `instancia` | instancia | instancia, instancias | sí | — | 3.1 |
| `encapsulamiento` | encapsulamiento | encapsulamiento, encapsular | sí | sí | 3.2 |
| `invariante-de-clase` | invariante de clase | invariante de clase | sí | — | 3.2 |
| `identidad` | identidad | identidad | — | — | 3.3 |
| `alias` | alias | alias | sí | — | 3.3 |
| `referencia-a-objeto` | referencia a un objeto | referencia a un objeto, referencias a objetos | sí | — | 3.3 |
| `interfaz` | interfaz | interfaz, interfaces | sí | sí | 3.4 |
| `polimorfismo` | polimorfismo | polimorfismo | sí | sí | 3.4 |
| `despacho-dinamico` | despacho dinámico | despacho dinámico | sí | — | 3.4 |
| `herencia` | herencia | herencia, heredar, hereda | sí | sí | 3.5 |
| `composicion` | composición | composición, componer | sí | sí | 3.5 |
| `sobrescribir` | sobrescribir | sobrescribir, sobrescritura | sí | — | 3.5 |
| `responsabilidad` | responsabilidad | responsabilidad, responsabilidades | — | — | 3.6 |
| `tarjeta-de-responsabilidad` | tarjeta de responsabilidad | tarjeta de responsabilidad, tarjetas de responsabilidad | sí | — | 3.6 |
| `colaborador` | colaborador | colaborador, colaboradores | — | — | 3.6 |

### Parte IV

| Id | Etiqueta | Formas | E | R | Dueña |
|---|---|---|---|---|---|
| `programacion-funcional` | programación funcional | programación funcional | sí | — | 4.1 |
| `inmutabilidad` | inmutabilidad | inmutabilidad, inmutable | sí | sí | 4.1 |
| `transparencia-referencial` | transparencia referencial | transparencia referencial | sí | — | 4.1 |
| `nucleo-puro` | núcleo puro y borde con efectos | núcleo puro | sí | sí | 4.1 |
| `funcion-como-valor` | función como valor | función como valor, funciones como valores | sí | sí | 4.2 |
| `orden-superior` | función de orden superior | orden superior | sí | sí | 4.2 |
| `mapear` | mapear | mapear, mapeo | sí | sí | 4.2 |
| `filtrar` | filtrar | filtrar | — | — | 4.2 |
| `reducir` | reducir | reducir | — | — | 4.2 |
| `clausura` | clausura | clausura, clausuras | sí | sí | 4.3 |
| `fabrica-de-funciones` | fábrica de funciones | fábrica de funciones | sí | sí | 4.3 |
| `variante` | variante | variante, variantes | — | sí | 4.4 |
| `coincidencia-de-patrones` | coincidencia de patrones | coincidencia de patrones | sí | sí | 4.4 |
| `generico` | genérico | genérico, genéricos | sí | sí | 4.4 |
| `estado-imposible` | estado imposible | estado imposible, estados imposibles | sí | — | 4.4 |

### Partes V y VI

| Id | Etiqueta | Formas | E | R | Dueña |
|---|---|---|---|---|---|
| `programacion-concurrente` | programación concurrente | programación concurrente | sí | — | 5.1 |
| `concurrencia` | concurrencia | concurrencia | sí | — | 5.1 |
| `tarea` | tarea | tarea, tareas | — | — | 5.1 |
| `agenda` | agenda | agenda | — | — | 5.1 |
| `canal` | canal | canal, canales | sí | sí | 5.2 |
| `aislamiento` | aislamiento | aislamiento | sí | — | 5.2 |
| `productor-consumidor` | productor y consumidor | productor, consumidor | sí | sí | 5.2 |
| `cancelacion` | cancelación | cancelación, cancelar | sí | — | 5.3 |
| `archivo` | archivo | archivo, archivos | — | — | 6.1 |
| `capacidad` | capacidad | capacidad, capacidades | sí | — | 6.1 |
| `limpieza-diferida` | limpieza diferida | limpieza diferida | sí | sí | 6.1 |
| `json` | JSON | JSON | sí | — | 6.2 |
| `serializar` | serializar | serializar, serialización | sí | sí | 6.2 |
| `peticion` | petición | petición, peticiones | sí | — | 6.3 |
| `codigo-de-estado` | código de estado | código de estado, códigos de estado | sí | — | 6.3 |

Las lecciones 4.5 y los proyectos no introducen términos.

**Formas comunes con choque de sentido.** `tarea` (tarea escolar), `clase` (clase de la escuela), `marco`, `campo`,
`valor` y `entrada` (entrada al cine) aparecen en enunciados antes de su dueña con sentido cotidiano. Las que son
estrictas (`clase`, `marco`) solo pueden aparecer antes de su dueña en `::: problema` y `::: enunciado` con el sentido
cotidiano si la lección declara `menciones_cotidianas: [clase]` en su cabecera. `RUTA-TERM-ORDER` respeta esa lista y
la revisión manual confirma el sentido.

---

## 2. Máquina nocional

| Pieza | Dueña | Qué se agrega a la imagen | Figura |
|---|---|---|---|
| 1. Instrucciones en orden | 0.1 | Se ejecuta una instrucción por vez, de arriba abajo, y cada `Escribir` agrega una línea a la salida | `ruta-instrucciones-en-orden` |
| 2. Cajas con nombre | 0.2 | La memoria son cajas; cada una tiene nombre, tipo y un valor. Asignar reemplaza el valor anterior, que se pierde. Una caja no se recalcula sola | `figura-especificacion declaraciones.definir cajas-variables` y `ruta-caja-no-se-recalcula` |
| 3. La instrucción actual | 1.1 | Hay una instrucción actual (el dedo). Una decisión hace saltar el dedo por encima de lo que no se ejecuta | `ruta-dedo-decision` |
| 4. Una fila por vuelta | 1.3 | En un bucle, la misma instrucción se ejecuta muchas veces con valores distintos; se sigue con una fila por vuelta | `ruta-tabla-por-vuelta` |
| 5. La pila de llamadas | 2.2 | Cada llamada abre su propio marco de cajas encima del anterior y lo cierra al volver | `figura-especificacion subprogramas.llamada llamada-marcos` |
| 6. Objetos y flechas | 3.3 | Una variable puede guardar una flecha hacia un objeto; dos flechas pueden llegar al mismo objeto | `figura-especificacion objetos.copia alias-copia` y `ruta-flechas-pedido` |
| 7. La agenda | 5.1 | Varias tareas avanzan por turnos; una espera y otra sigue | `figura-especificacion motor.agenda agenda-cola` y `ruta-cocina-turnos` |

Cada pieza **amplía** el dibujo anterior. Desde la pieza 2, las figuras de memoria usan siempre la misma caja (nombre
arriba, valor en el centro, tipo abajo y en gris).

---

## 3. Figuras nuevas

Todas en `packages/pseudolearn_reference/figures/`, con el contrato de la Especificación. «Pasos» indica una figura por
pasos con ese número de pasos; «—» es estática. El texto exacto de cada paso lo redacta el agente siguiendo la columna
«Contenido».

| Id | Lección | Pasos | Contenido y propósito |
|---|---|---|---|
| `ruta-ciclo` | 0.1 (ancla, se reutiliza) | — | Cinco rectángulos en círculo (Entender, Planear, Escribir, Probar, Mejorar) con flechas llenas; flecha punteada de Probar a Planear rotulada «¿falló?»; punteada de Mejorar a Entender «siguiente problema». Muestra que el ciclo vuelve atrás y no se empieza de cero |
| `ruta-instrucciones-en-orden` | 0.1 | 3 | Un programa de tres `Escribir` a la izquierda, la salida a la derecha. Cada paso resalta una línea y agrega su línea de salida. Pieza 1 |
| `ruta-caja-no-se-recalcula` | 0.2 | 3 | Cajas `invitados` (23), `porciones` (69). Paso 2: `invitados` cambia a 30 y `porciones` sigue en 69, marcada en rojo «no se recalculó». Paso 3: se vuelve a ejecutar el cálculo y `porciones` pasa a 90. Desmonta la idea de hoja de cálculo |
| `ruta-ficha` | 0.3 (ancla) | — | La ficha del problema como tarjeta de cuatro zonas (entra, sale, relación, ejemplos a mano) con el problema de la propina. Es el dibujo de referencia de la herramienta |
| `ruta-tres-errores` | 0.4 | 3 | Un viaje en bus: paso 1 el bus no arranca (error al compilar), paso 2 se rompe en el camino (error al ejecutar), paso 3 llega a otra ciudad (error de lógica). Debajo de cada uno, quién lo detecta: el motor antes de empezar, el motor durante el viaje, solo tú con tus casos de prueba |
| `ruta-recta-casos` | 0.4 (ancla de casos) | — | Recta numérica de la cantidad de amigos: zona «raro» (0 y negativos), borde (1), zona normal (2 en adelante). Cada zona con un punto elegido como caso de prueba |
| `ruta-dedo-decision` | 1.1 | 5 | Programa del cine con una mano que señala la instrucción actual; en la decisión la mano salta la rama que no se ejecuta, que queda atenuada. Pieza 3 |
| `ruta-particion-edad` | 1.1 (ancla de partición) | — | Recta de edades 0 a 100 partida en 12: regiones «paga 5» y «paga 8», con 11 y 12 marcados como borde |
| `ruta-tabla-decision-bisiesto` | 1.2 | — | Tabla de decisión: filas «divisible por 4», «por 100», «por 400»; columnas con los cuatro años de ejemplo (2023, 2024, 1900, 2000) y la fila de resultado |
| `ruta-orden-preguntas` | 1.2 | 2 | Dos embudos de preguntas para el bisiesto: paso 1 en orden incorrecto, 1900 sale por «sí»; paso 2 en orden correcto, sale por «no» |
| `ruta-tabla-por-vuelta` | 1.3 (ancla) | 4 | La alcancía: a la izquierda las tres cajas; a la derecha una tabla que gana una fila por paso (antes, vuelta 1, vuelta 2, salida). Pieza 4 |
| `ruta-rol-contador` | 1.3 | — | Icono 340×80: tres escalones crecientes y el rótulo «contador: avanza lo mismo cada vuelta» |
| `ruta-rol-acumulador` | 1.3 | — | Icono 340×80: alcancía que recibe una moneda y el rótulo «acumulador: va juntando» |
| `ruta-rol-bandera` | 1.4 | — | Icono 340×80: banderín que se levanta una vez y no baja |
| `ruta-rol-mejor-hasta-ahora` | 1.4 | — | Icono 340×80: podio con un solo puesto y una flecha que reemplaza al ocupante |
| `ruta-elegir-bucle` | 1.4 | — | Árbol de dos preguntas: «¿sabes cuántas vueltas?» → bucle contado; si no, «¿la primera vuelta va siempre?» → bucle que pregunta al final; si no → `Mientras` |
| `ruta-rol-recorredor` | 1.5 | — | Icono 340×80: un índice que avanza casilla por casilla |
| `ruta-dos-pasadas` | 1.5 | 2 | El arreglo de temperaturas; paso 1: flecha que recorre todo y alimenta el promedio; paso 2: segunda pasada que marca los días por encima |
| `ruta-esquemas` | 1.6 (ancla) | — | El mismo arreglo dibujado seis veces, una por esquema: recorrer, contar, acumular, buscar (se detiene), filtrar (copia a otro arreglo), transformar (otro arreglo del mismo largo) |
| `ruta-rol-seguidor` | 1.6 | — | Icono 340×80: dos huellas, la de atrás sigue a la de adelante |
| `ruta-racha` | 1.6 | 6 | Arreglo de 14 temperaturas; un contador de racha que sube con cada día de más de 30, vuelve a 0 al cortarse y registra la ola más larga |
| `ruta-matriz-coordenadas` | 1.7 | — | Tablero 3×3 con `[fila, columna]` en cada casilla y las dos diagonales: `fila = columna` y `fila + columna = 2` |
| `ruta-busqueda-binaria` | 1.8 | 4 | Arreglo ordenado de 15 números; cada paso tacha la mitad que no puede contener el buscado |
| `ruta-pasos-crecen` | 1.8 | — | Barras horizontales: pasos de búsqueda lineal frente a binaria para 10, 100 y 1000 datos (10/4, 100/7, 1000/10) |
| `ruta-seleccion` | 1.8 | 5 | Ordenamiento por selección de 5 números: en cada paso se elige el menor de la parte desordenada y se lo lleva al frente |
| `ruta-arbol-boletin` | 2.1 (ancla de descomposición) | 3 | Árbol: «Boletín» → «Leer notas», «Calcular promedio», «Decidir estado», «Buscar el mejor». Cada paso baja un nivel |
| `ruta-maquina-pura` | 2.3 | — | Dos máquinas: la pura con una sola entrada y una sola salida; la impura con puertas laterales «lee», «escribe», «cambia afuera» |
| `ruta-hanoi` | 2.4 | 7 | Los siete movimientos de tres discos entre A, B y C |
| `ruta-munecas` | 2.4 | 4 | Muñecas que se abren hasta la más chica (caso base) y se vuelven a cerrar con el resultado |
| `ruta-forma-de-datos` | 2.5 | — | La agenda dibujada tres veces: arreglos paralelos, vector de registros y diccionario por nombre |
| `ruta-filtro-validacion` | 2.6 | — | Tubería: texto → ¿es número? → ¿está en rango? → edad válida; cada filtro con su salida lateral de error con motivo |
| `ruta-kiosco-modulos` | 2.7 | — | Cajas de módulos (`inventario`, `ventas`, `tickets`, `principal`) con flechas de importación sin ciclos |
| `ruta-molde` | 3.1 | 2 | Paso 1: un molde (clase) con forma de estrella; paso 2: tres galletas (objetos) con distinta decoración (estado). Pie: dónde falla la analogía (el molde también define qué puede hacer cada galleta) |
| `ruta-caja-fuerte` | 3.2 | — | Un objeto como caja fuerte: atributos adentro, métodos como ventanillas que controlan qué entra |
| `ruta-flechas-pedido` | 3.3 | 3 | Variables `pedido` y `copia` con flechas al mismo objeto; paso 2: se modifica por `copia` y se ve por `pedido`; paso 3: una copia real crea un segundo objeto. Pieza 6 |
| `ruta-enchufe` | 3.4 | — | La caja como un enchufe; efectivo, tarjeta y vale como aparatos con el mismo enchufe. Pie: dónde falla la analogía |
| `ruta-explosion-clases` | 3.5 | 2 | Paso 1: árbol de herencia que explota en combinaciones; paso 2: un producto que **tiene** vencimiento y **tiene** oferta |
| `ruta-tarjetas` | 3.6 (ancla) | — | Tres tarjetas de responsabilidad (`Producto`, `Inventario`, `Caja`) con responsabilidades y colaboradores unidos por flechas |
| `ruta-nucleo-borde` | 4.1 (ancla) | — | Círculo exterior «borde con efectos» con `Leer` y `Escribir`; círculo interior «núcleo puro» con las funciones del kiosco; flechas de entrada y salida |
| `ruta-sustitucion` | 4.1 | 6 | Seis renglones que reducen `ConDescuento(Linea(3, 3) + Linea(5, 2))` hasta 18, uno por paso |
| `ruta-cinta` | 4.2 | 3 | Una cinta transportadora de precios: paso 1 mapear (cada caja pasa por una máquina), paso 2 filtrar (una compuerta), paso 3 reducir (un embudo que deja un solo valor) |
| `ruta-mochila` | 4.3 | 2 | Una función con una mochila: paso 1 la fábrica guarda el porcentaje en la mochila; paso 2 la función usa lo de la mochila al llamarla |
| `ruta-estados-pedido` | 4.4 | — | Diagrama de estados: Pendiente → EnCamino(repartidor) → Entregado(hora), y Cancelado(motivo) desde Pendiente y EnCamino |
| `ruta-tres-kioscos` | 4.5 | 3 | El mismo ticket en tres paradigmas, uno por paso: órdenes que cambian cajas, objetos que colaboran, funciones que transforman |
| `ruta-cocina-turnos` | 5.1 | 6 | Línea de tiempo vertical con tres columnas de cocineros; cada paso muestra quién avanza y quién espera. Pieza 7 |
| `ruta-mostrador` | 5.2 | 4 | Cocina, tubo (canal) con capacidad y mostrador; los pedidos viajan por el tubo |
| `ruta-carrera` | 5.3 | 3 | Dos carriles de proveedores; gana el primero que llega y el otro se cancela |
| `ruta-memoria-y-disco` | 6.1 | 2 | Paso 1: el inventario en cajas de memoria; paso 2: se apaga el programa, las cajas desaparecen y el archivo queda |
| `ruta-json-viaje` | 6.2 | — | Un registro del inventario, su texto JSON y el mismo registro reconstruido del otro lado |

Las figuras de iconos de roles (`ruta-rol-*`) miden 340×80 para cumplir el contrato y se publican como figuras normales
dentro del bloque `roles`.

---

## 4. Figuras de la Especificación que la ruta incrusta

| Lección | Sección | Figura |
|---|---|---|
| 0.2 | `declaraciones.definir` | `cajas-variables` |
| 0.2 | `declaraciones.asignacion` | `intercambio` |
| 0.2 | `expresiones.division` | `reparto` |
| 0.3 | `biblioteca.consola` | `leer-escribir` |
| 0.4 | `diagnosticos.anatomia` | `anatomia-diagnostico` |
| 1.1 | `control.si` | `si-ordinograma` |
| 1.2 | `expresiones.logicos` | `cortocircuito` |
| 1.2 | `control.segun` | `segun-ramas` |
| 1.3 | `control.mientras` | `mientras-ciclo` |
| 1.4 | `control.para` | `para-contador` |
| 1.4 | `control.repetir` | `repetir-ciclo` |
| 1.4 | `control.salir` | `salir-corte` |
| 1.5 | `tipos.arreglos` | `arreglo-casillas` |
| 1.5 | `control.para-cada` | `para-cada-recorrido` |
| 2.1 | `subprogramas.declaracion` | `subprograma-caja` |
| 2.2 | `subprogramas.parametros` | `paso-valor` |
| 2.2 | `subprogramas.referencia` | `referencia-salida` |
| 2.2 | `subprogramas.llamada` | `llamada-marcos` |
| 2.3 | `subprogramas.pureza` | `pureza-grafo` |
| 2.4 | `subprogramas.recursion` | `recursion-pila` |
| 2.5 | `tipos.registros` | `registro-copia` |
| 2.5 | `tipos.diccionarios` | `diccionario` |
| 2.6 | `tipos.opcional-resultado` | `opcional-resultado` |
| 2.7 | `programas.modulos` | `paquete-modulos` |
| 3.1 | `objetos.clase` | `clase-objetos` |
| 3.1 | `objetos.constructor` | `nuevo-pasos` |
| 3.3 | `objetos.copia` | `alias-copia` |
| 3.4 | `objetos.interfaces` | `interfaz-promesa` |
| 3.5 | `objetos.herencia` | `herencia-despacho` |
| 4.3 | `tipos.funciones` | `clausura` |
| 4.4 | `tipos.variantes` | `variante-formas` |
| 5.1 | `motor.agenda` | `agenda-cola` |
| 5.1 | `tareas.ambitos` | `ambito-tareas` |
| 5.2 | `tareas.canales` | `canal-cola` |
| 6.1 | `biblioteca.archivos` | `archivo-capas` |
| 6.1 | `control.diferir` | `diferir-pila` |
| 6.2 | `biblioteca.json` | `json-arbol` |
| 6.3 | `biblioteca.http` | `http-ida-vuelta` |

Una lección puede incrustar más figuras de la Especificación si las encuentra útiles; nunca redibuja una.
