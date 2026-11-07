# 11 — Parte I: Imperativo y estructurado

**Lema:** Darle órdenes a una máquina con memoria.

**Propósito de la parte:** que la persona resuelva problemas con decisiones, repeticiones y colecciones, eligiendo la
estructura adecuada y razonando con particiones, roles de variables, esquemas y tablas por vuelta. Ocho lecciones y un
proyecto, unas cuatro horas.

Fases 1 y 2 separadas y completas (03 §3). Programas con `Algoritmo`. Salidas a verificar con el motor.

---

## 1.1 Decidir — `imperativo.decidir`

| Campo | Valor |
|---|---|
| Tipo | `apertura` · 25 min · semilla a árbol |
| Necesita | `inicio.errores` |
| Introduce | `paradigma`, `programacion-imperativa`, `condicion`, `valor-logico`, `comparacion`, `decision`, `instruccion-actual`, `particion-de-casos` |
| Pieza | 3 |

**Propósito.** La persona hace que un programa elija entre dos caminos y parte el espacio de entradas en regiones con sus
bordes, para no olvidar ningún caso.

**Frase.** Un programa decide haciendo una pregunta que solo se responde con verdadero o falso, y sigue un camino según la
respuesta.

**Problema.** En el cine de la escuela, los menores de **12 años** pagan **5 pesos** y los demás pagan **8**. **¿Cuánto
paga cada persona, según su edad?**

**Inténtalo.** Decir cuánto pagan personas de 10, 11, 12 y 30 años. Respuesta: 5, 5, 8 y 8. El 12 es el que más se equivoca:
«menores de 12» no lo incluye.

**Un paradigma nuevo (breve).** Lo que la persona hizo desde la Unidad 0 tiene nombre. `paradigma`:

- Pregunta: ¿y si un programa fuera una lista de órdenes que van cambiando lo que hay en la memoria?
- Metáfora: una receta de cocina, con pasos en orden que transforman los ingredientes. Deja de valer en que una receta no
  pregunta nada: un programa sí puede hacerlo.
- Historia: en 1945, John von Neumann describió una computadora que guarda el programa en su memoria, junto con los datos.
  En 1957, el equipo de John Backus publicó FORTRAN, uno de los primeros lenguajes que permitían escribir esas órdenes
  con fórmulas.
- Costo: para saber qué vale una caja hay que seguir el orden de las órdenes.

Definición de paradigma y de programación imperativa.

**1. Entender.** Entra la edad; sale el precio. Figura `ruta-particion-edad` (ancla): dos regiones y el borde entre 11 y 12.
Definición de partición de casos: cada región, un ejemplo a mano; cada borde, dos.

**2. Planear.** Preguntar la edad; si es menor que 12, el precio es 5; si no, 8.

**Herramienta nueva.** Condición, valor lógico (`Verdadero`, `Falso`) y comparación. `Si`/`Sino` con la figura de la
Especificación `control.si#si-ordinograma`. La instrucción actual: figura `ruta-dedo-decision` (pieza 3).

| Id | Programa | Salida |
|---|---|---|
| `alcanza` | `Definir dinero Como Entero <- 10;` · `Si dinero >= 12 Entonces Escribir "Alcanza"; Sino Escribir "No alcanza"; FinSi` | `No alcanza` |

Enlaces: `control.si`, `expresiones.comparacion`, `tipos.primitivos`.

**3. Escribir.** `cine`: lee la edad y escribe `Paga 5` o `Paga 8`.

**4. Probar.** Tabla con 10, 11, 12 y 30. La figura de partición marca qué casos cubren qué región.

**5. Mejorar.** La calculadora de propinas de 0.4 deja de caerse con 0 amigos (`propina-segura`: con 100 y 0 muestra `No
hay quien pague`). Comparación: antes el error era una caída; ahora es una respuesta.

**Resumen.**

- `{paradigma,programacion-imperativa}` Un paradigma es una forma de organizar un programa; en la programación imperativa,
  el programa es una lista de órdenes que cambian la memoria.
- `{condicion,valor-logico,comparacion}` Una condición es una pregunta cuya respuesta es un valor lógico: `Verdadero` o
  `Falso`. Las comparaciones son condiciones.
- `{decision,instruccion-actual}` En una decisión se ejecuta solo uno de los caminos; la instrucción actual salta el otro.
- `{particion-de-casos}` Una partición de casos divide las entradas en regiones; se prueba un caso por región y los dos
  lados de cada borde.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `par-impar-predecir` | predecir | semilla | sí | `x <- 7`; si `x mod 2 = 0` escribe `par`, si no `impar` | `impar` |
| `par-impar` | resolver | semilla | sí | Lee un número entero y muestra si es `par` o `impar` | Visibles: 4 → par; 7 → impar. Ocultos: 0 → par; 1 → impar; -3 → impar |
| `cine-romper` | romperlo | brote | sí | El cine de otra escuela escribió `Si edad > 12 Entonces Escribir "Paga 8"; Sino Escribir "Paga 5"; FinSi`. Encuentra una edad que cobre mal | Visibles: 10, 30. Rompe: 12 |
| `zonas-cine` | clasificar | semilla | — | Ubicar 3, 11, 12 y 65 años en «paga 5» o «paga 8», y marcar cuáles son borde | 3 y 11 pagan 5; 12 y 65 pagan 8; borde: 11 y 12 |
| `cine-pruebas` | disenar-pruebas | brote | — | Entre 2 y 4 casos para el cine | Mutantes: `edad <= 12`, `edad < 11`, `edad < 13`, precios intercambiados. Solución: 11 → 5; 12 → 8 |
| `estacionamiento` | resolver | árbol | — | El estacionamiento cobra 3 pesos la primera hora y 2 por cada hora o fracción adicional; menos de una hora se cobra como una. Lee los minutos y muestra el precio | Visibles: 45 → 3; 150 → 7. Ocultos: 60 → 3; 61 → 5; 0 → 3; 600 → 21 |

**Para docentes.** «Se ejecutan las dos ramas» (figura del dedo); «menor que 12 incluye al 12»; un número usado como
condición (diagnóstico `nonBooleanCondition`: enlazar la sección, no explicarlo).

**Siguiente.** «Los jueves todos pagan 4. ¿Cómo se combinan dos preguntas, y en qué orden se hacen?»

---

## 1.2 Muchos caminos — `imperativo.caminos`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `imperativo.decidir` |
| Introduce | `condicion-compuesta`, `tabla-de-decision`, `seleccion-multiple`, `anidar` |

**Propósito.** La persona combina condiciones, ordena preguntas con una tabla de decisión y elige entre decisiones
anidadas y selección múltiple.

**Frase.** Cuando hay muchos casos, una tabla de decisión ordena las preguntas antes de escribir la primera.

**Problema.** Un año es bisiesto si se puede dividir exacto entre 4, salvo que también se pueda entre 100; pero los que se
pueden dividir entre 400 sí son bisiestos. **¿Cómo sabe un programa si un año es bisiesto?**

**Inténtalo.** Decidir para 2024, 2023, 1900 y 2000. Respuesta: sí, no, no, sí.

**1. Entender.** Ficha: entra el año; sale «es bisiesto» o «no es bisiesto»; ejemplos: los cuatro años. Los cuatro son una
partición; 1900 y 2000 son los bordes de las excepciones.

**2. Planear.** Figura `ruta-tabla-decision-bisiesto`: tres condiciones por columna de ejemplo. Definición de tabla de
decisión. Figura `ruta-orden-preguntas`: preguntar primero «¿divisible por 4?» hace que 1900 salga mal si no se sigue
preguntando; se empieza por la condición más específica (400).

**Herramienta nueva.** Condición compuesta con `Y`, `O`, `NO` (figura de la Especificación
`expresiones.logicos#cortocircuito`). Anidar: un `Si` dentro del `Sino` de otro. Selección múltiple con `Segun` para
opciones de un valor (figura `control.segun#segun-ramas`):

| Id | Programa | Entrada | Salida |
|---|---|---|---|
| `menu` | `Segun codigo Hacer` con 1 Jugo 3, 2 Sándwich 5, 3 Alfajor 2, 4 Agua 1, 5 Fruta 2 y `De Otro Modo` `No existe` | `2` | `Sándwich 5` |

Enlaces: `expresiones.logicos`, `expresiones.precedencia`, `control.segun`, `control.si`.

**3. Escribir.** `bisiesto-anidado` (tres `Si` anidados en el orden 400, 100, 4) y `bisiesto-compuesto` (una condición
`(a mod 4 = 0 Y a mod 100 <> 0) O a mod 400 = 0`). Las dos escriben `Es bisiesto` o `No es bisiesto`.

**4. Probar.** Los cuatro años en las dos versiones. Mostrar que la versión compuesta necesita paréntesis (enlace a
`expresiones.precedencia`, sin explicar la regla).

**5. Mejorar.** El cine con jueves: lee el día (1 a 7, el 4 es jueves) y la edad. Comparar dos órdenes de pregunta en una
tabla de decisión. Gana el orden «jueves primero».

**Resumen.**

- `{condicion-compuesta}` `Y`, `O` y `NO` combinan condiciones en una sola.
- `{tabla-de-decision}` Una tabla de decisión pone cada condición en una fila y cada caso en una columna, antes de escribir.
- `{anidar}` Anidar es poner una decisión dentro de otra; el orden de las preguntas importa.
- `{seleccion-multiple}` La selección múltiple elige entre muchos valores posibles de un mismo dato.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `compuesta` | predecir | semilla | — | `Si 5 > 3 Y 2 > 4 Entonces Escribir "A"; Sino Escribir "B"; FinSi` y luego lo mismo con `O` | `B` ⏎ `A` |
| `menu-kiosco` | resolver | semilla | sí | Lee un código de producto del kiosco y muestra su nombre y precio; si no existe, `No existe` | Visibles: 1 → `Jugo 3`; 9 → `No existe`. Ocultos: 2 → `Sándwich 5`; 5 → `Fruta 2`; 0 → `No existe` |
| `bisiesto-romper` | romperlo | brote | sí | Un programa decide con `a mod 4 = 0` solamente | Visibles: 2024, 2023. Rompe: 1900, 2100 |
| `triangulo` | resolver | brote | sí | Lee tres lados y muestra `equilátero`, `isósceles`, `escaleno` o `no es triángulo` (cada lado tiene que ser menor que la suma de los otros dos) | Visibles: 3,3,3 → equilátero; 3,4,5 → escaleno. Ocultos: 2,2,3 → isósceles; 1,2,3 → no es triángulo; 5,1,1 → no es triángulo; 2,3,2 → isósceles |
| `bisiesto-ordenar` | ordenar | brote | — | Las líneas de `bisiesto-anidado` mezcladas | Casos: 2024, 2023, 1900, 2000 |
| `descuentos` | clasificar | árbol | — | Regla: estudiante con compra de 10 o más → 10 %; cumpleañero → 15 %; si aplican las dos, gana la mayor. Ubicar cinco clientes en 0, 10 o 15 | (estudiante, 12, no) → 10; (no, 12, sí) → 15; (estudiante, 8, no) → 0; (estudiante, 20, sí) → 15; (no, 5, no) → 0 |

**Para docentes.** «`O` significa uno u otro, pero no los dos»; olvidar paréntesis; poner la condición general antes de la
específica.

**Siguiente.** «Lucía ahorra para una pelota y no sabe cuántos días va a tardar. ¿Cómo se repite algo sin saber cuántas
veces?»

---

## 1.3 Repetir mientras haga falta — `imperativo.mientras`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `imperativo.caminos` |
| Introduce | `bucle`, `vuelta`, `rol-de-variable`, `contador`, `acumulador`, `tabla-por-vuelta`, `invariante`, `bucle-infinito`, `centinela` |
| Pieza | 4 |
| Muestra | `docs/ruta-aprendizaje-ejemplos/1-3-repetir-mientras-haga-falta.html` (contenido casi completo; cambiar `Proceso` por `Algoritmo` y la figura de la Especificación por `figura-especificacion control.mientras mientras-ciclo`) |

**Propósito.** La persona repite un bloque mientras haga falta, reconoce contadores y acumuladores, sigue un bucle con
una tabla por vuelta, encuentra su invariante y lee datos hasta un centinela.

**Frase.** Cuando no sabes cuántas veces hay que hacer algo, pero sí sabes cuándo parar, repites mientras no se cumpla esa
condición.

**Problema.** Lucía quiere comprar una pelota que cuesta **50 monedas**. El primer día guarda **2 monedas**, y cada día
guarda **una moneda más** que el anterior. **¿Qué día puede comprar la pelota, y cuántas monedas tendrá ese día?**

**Inténtalo.** Tabla a mano. Respuesta: 2, 5, 9, 14, 20, 27, 35, 44, 54: **día 9 con 54**.

**1. Entender.** Ficha con ejemplos: 50 → día 9, 54; 54 → día 9, 54 (borde: alcanza justo); 2 → día 1, 2 (borde: alcanza el
primer día).

**2. Planear.** Los tres pasos de cada fila y la pregunta «¿todavía no alcanza?». Definición de rol; bloque `roles` con
`ruta-rol-contador` (`dia`, `guardaHoy`) y `ruta-rol-acumulador` (`ahorro`).

**Herramienta nueva.** Bucle, vuelta y `Mientras` con la figura de la Especificación `control.mientras#mientras-ciclo`.
Tabla por vuelta: figura `ruta-tabla-por-vuelta` (ancla, pieza 4). Programa mínimo:

| Id | Programa | Salida |
|---|---|---|
| `cuenta-regresiva` | `n <- 3`; mientras `n > 0`, escribe `n` y resta 1; al final `¡Ya!` | `3` ⏎ `2` ⏎ `1` ⏎ `¡Ya!` |

Enlace: `control.mientras`.

**3. Escribir.** `alcancia` (precio fijo 50) → `Lucía compra la pelota el día 9 con 54 monedas`.

**4. Probar.** Tabla por vuelta completa (8 vueltas). Invariante: «`ahorro` es todo lo guardado desde el día 1 hasta
`dia`». `alcancia-leida`: precio leído; tabla de casos 50 → `Día 9 con 54 monedas`, 54 → igual, 2 → `Día 1 con 2 monedas`,
1000 → `Día 44 con 1034 monedas`. Bucle infinito: `alcancia-infinita` (olvida sumar), ejecutada con un presupuesto de
10 000 sentencias (bloque de programa con ese límite si el compilador lo admite; si no, se muestra el diagnóstico real de
la app y se reporta). Pregunta de control: ¿qué cambia en cada vuelta que acerca la condición a falso? Enlace:
`motor.limites`.

**5. Mejorar.** Centinela: `alcancia-dictada`, entradas 2, 3, 4, -1 → `Juntó 9 monedas`; con -1 directo → `Juntó 0 monedas`.
Los dos `Leer` y por qué hacen falta.

**Resumen.**

- `{bucle,vuelta}` Un bucle repite un grupo de instrucciones; cada repetición es una vuelta. `Mientras` pregunta antes de
  cada vuelta y puede dar cero vueltas.
- `{rol-de-variable,contador,acumulador}` El rol de una variable es para qué sirve; un contador avanza lo mismo en cada
  vuelta y un acumulador va juntando.
- `{tabla-por-vuelta,invariante}` La tabla por vuelta sigue un bucle a mano; un invariante es lo que se cumple al terminar
  cada vuelta.
- `{bucle-infinito}` Si nada acerca la condición a falso, el bucle es infinito.
- `{centinela}` Un centinela es un valor especial que avisa que se terminaron los datos.

**Ejercicios.** Los de la muestra, con `Algoritmo`.

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `misterio` | predecir | semilla | sí | `n` y `total` en 0; mientras `total < 10`, `n` suma 1 y `total` suma `n`; escribe `n, " ", total` | `4 10` |
| `misterio-tabla` | rastrear | brote | sí | Tabla por vuelta del programa anterior, columnas `n` y `total` | Filas: antes 0,0; 1,1; 2,3; 3,6; 4,10. Ocultas todas salvo «antes» y `n` de la vuelta 1 |
| `alcancia-tomas` | romperlo | brote | sí | La versión de Tomás con `ahorro <= precio` | Visible: 50. Rompe: 54 (dice día 10 con 65), 2 (dice día 2 con 5) |
| `frijol` | resolver | brote | sí | Un frijol mágico mide lo que se lee al plantarlo. El primer día crece 1 cm y cada día crece el doble que el anterior. ¿Cuántos días tarda en llegar a la ventana, a 100 cm? | Visibles: 3 → 7; 100 → 0. Ocultos: 99 → 1; 0 → 7; 50 → 6 |
| `promedio-profesora` | resolver | árbol | — | La profesora dicta notas y termina con -1. Muestra el promedio, o `No hay notas` | Visibles: 14, 17, 11, -1 → `14.0`; -1 → `No hay notas`. Ocultos: 10, -1 → `10.0`; 0, 0, -1 → `0.0`; 7, 8, -1 → `7.5` |
| `alcancia-pruebas` | disenar-pruebas | árbol | — | Cuatro precios con su respuesta, de modo que cualquier versión equivocada falle alguno | Mutantes: `<=`, `ahorro` desde 0, sumar antes de aumentar `guardaHoy`, `dia` desde 0. Solución: 50, 54, 2, 1000 |

Verificar el oculto de `frijol` con 50: 50 → 51, 53, 57, 65, 81, 113: 6 días.

**Para docentes.** Los de la muestra.

**Siguiente.** «¿Y si sabes desde el principio cuántas vueltas hacen falta? ¿Cómo sabes si un número es primo?»

---

## 1.4 Repetir un número conocido de veces — `imperativo.contado`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `imperativo.mientras` |
| Introduce | `bucle-contado`, `bucle-posterior`, `bandera`, `mejor-hasta-ahora`, `salida-anticipada` |

**Propósito.** La persona elige entre los tres bucles con un criterio, usa banderas y el mejor hasta ahora, y corta un
bucle cuando ya sabe la respuesta.

**Frase.** Elegir el bucle es responder dos preguntas: ¿sé cuántas vueltas habrá? ¿la primera vuelta va siempre?

**Problema.** El club de matemática quiere un programa que diga si un número es **primo**: un número mayor que 1 que solo se
puede dividir exacto entre 1 y entre sí mismo. **¿Cómo lo averigua el programa?**

**Inténtalo.** Decidir para 7, 9, 2 y 1. Respuesta: sí, no (9 = 3 × 3), sí, no (1 no es primo por definición).

**1. Entender.** Ficha con los cuatro ejemplos; 2 y 1 son bordes.

**2. Planear.** Probar cada posible divisor de 2 a n − 1. Hay que recordar si alguno dividió exacto: bloque `roles` con
`ruta-rol-bandera`. Se sabe de antemano cuántos divisores probar.

**Herramienta nueva.** Bucle contado `Para` (figura `control.para#para-contador`), bucle que pregunta al final `Repetir`
(figura `control.repetir#repetir-ciclo`), salida anticipada `Salir` (figura `control.salir#salir-corte`) y figura
`ruta-elegir-bucle`. Mejor hasta ahora con `ruta-rol-mejor-hasta-ahora`. Programas mínimos:

| Id | Programa | Entrada | Salida |
|---|---|---|---|
| `tabla-del-7` | `Para i <- 1 Hasta 3` escribe `7 * i` | — | `7` ⏎ `14` ⏎ `21` |
| `uno-a-diez` | `Repetir` lee `n` `Hasta Que n >= 1 Y n <= 10`; escribe `Aceptado: ` y `n` | `0` ⏎ `15` ⏎ `7` | `Aceptado: 7` |
| `maxima` | Lee 5 temperaturas con `Para` y guarda la mayor, empezando por la primera leída | `20` ⏎ `23` ⏎ `19` ⏎ `25` ⏎ `22` | `Máxima: 25` |

Enlaces: `control.para`, `control.repetir`, `control.salir`.

**3. Escribir.** `primo`: bandera `esPrimo` que empieza en `n >= 2`; `Para d <- 2 Hasta n - 1`; si `n mod d = 0`, la bandera
baja y se sale. Escribe `Es primo` o `No es primo`. El agente comprueba qué hace `Para` cuando el final es menor que el
inicio (n = 2) en la Especificación; si no da cero vueltas, el plan se ajusta y se reporta.

**4. Probar.** Tabla con 7, 9, 2 y 1. Contar cuántas divisiones hace con 97 (95) para preparar la lección 1.8.

**5. Mejorar.** Con `Salir`, 9 se resuelve en 2 vueltas en vez de 7. Comparar con y sin `Salir`.

**Resumen.**

- `{bucle-contado}` Un bucle contado se usa cuando se sabe cuántas vueltas habrá.
- `{bucle-posterior}` Un bucle que pregunta al final da siempre al menos una vuelta.
- `{bandera}` Una bandera es un valor lógico que cambia una sola vez para recordar que algo pasó.
- `{mejor-hasta-ahora}` El mejor hasta ahora guarda el valor más alto (o más bajo) visto; empieza con el primer dato.
- `{salida-anticipada}` Una salida anticipada corta el bucle cuando ya se conoce la respuesta.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `suma-cinco` | predecir | semilla | sí | `Para i <- 1 Hasta 5` acumula `i`; escribe el total | `15` |
| `hay-par` | rastrear | brote | — | `hayPar` en `Falso`; `Para i <- 1 Hasta 4`, `x <- i * 3`, si `x` es par `hayPar <- Verdadero`. Columnas `i`, `x`, `hayPar` | 1,3,Falso; 2,6,Verdadero; 3,9,Verdadero; 4,12,Verdadero (formato de los lógicos según el motor) |
| `primo-romper` | romperlo | brote | sí | Un programa empieza con `esPrimo <- Verdadero` | Visibles: 7, 9. Rompe: 1 |
| `nota-mas-alta` | resolver | brote | sí | Lee 5 notas (de 0 a 10) y muestra la más alta | Visibles: 4,9,7,9,2 → 9; 1,1,1,1,1 → 1. Ocultos: 0,0,0,0,10 → 10; 10,0,0,0,0 → 10; 5,6,7,8,9 → 9 |
| `que-bucle` | clasificar | semilla | — | Ubicar en contado, pregunta al final o `Mientras`: cantar el feliz cumpleaños 4 veces; pedir la contraseña hasta que sea correcta; sumar monedas de una bolsa que puede estar vacía; mostrar del 1 al 100; pedir notas hasta -1 | Contado: 1 y 4. Al final: 2. `Mientras`: 3 y 5 |
| `uno-a-diez-resolver` | resolver | brote | — | Pide un número hasta que esté entre 1 y 10 y muestra `Aceptado: n` | Visibles: 0, 15, 7 → `Aceptado: 7`; 3 → `Aceptado: 3`. Ocultos: 10 → `Aceptado: 10`; 11, 1 → `Aceptado: 1`; -5, 0, 11, 5 → `Aceptado: 5` |
| `suma-digitos` | resolver | árbol | — | Lee un número entero no negativo y muestra la suma de sus cifras | Visibles: 1234 → 10; 9 → 9. Ocultos: 0 → 0; 1000 → 1; 9999 → 36 |

**Para docentes.** El máximo que empieza en 0 (falla con datos negativos: mostrarlo); la bandera que vuelve a cambiar en
cada vuelta (`esPrimo <- n mod d <> 0` dentro del bucle); usar `Para` cuando no se sabe cuántas vueltas habrá.

**Siguiente.** «Para saber qué días hizo más calor que el promedio, primero hay que conocer el promedio... y para entonces
los datos ya pasaron. ¿Dónde se guardan muchos datos?»

---

## 1.5 Muchos datos con un solo nombre — `imperativo.arreglos`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `imperativo.contado` |
| Introduce | `arreglo`, `indice`, `recorredor`, `fuera-de-rango` |

**Propósito.** La persona guarda una colección en un arreglo, la recorre con un índice y la vuelve a recorrer cuando un
dato depende de todos los demás.

**Frase.** Un arreglo guarda muchos datos del mismo tipo bajo un solo nombre, y cada uno se encuentra por su posición.

**Problema.** El kiosco anota la temperatura máxima de cada día de la semana, de lunes a domingo. Quiere saber **qué días
fueron más calurosos que el promedio de la semana**. **¿Cómo lo calcula un programa?**

**Inténtalo.** Con 20, 23, 19, 25, 22, 18 y 26. Respuesta: la suma es 153 y el promedio 21,86; superan el promedio martes,
jueves, viernes y domingo.

**1. Entender.** Ficha: entran siete temperaturas; salen nombres de días. Borde: todos iguales (ningún día supera).

**2. Planear.** Primero hay que conocer el promedio, y para eso hay que leer todo; después comparar cada día. Figura
`ruta-dos-pasadas`. Con variables sueltas harían falta siete nombres.

**Herramienta nueva.** Arreglo, índice desde 0 (figura `tipos.arreglos#arreglo-casillas`), recorrido con `Para` de 0 a 6 y
con `Para Cada` (figura `control.para-cada#para-cada-recorrido`). `roles` con `ruta-rol-recorredor`. Fuera de rango:
mencionarlo y enlazar, sin explicar el diagnóstico.

| Id | Programa | Salida |
|---|---|---|
| `tres-notas` | Arreglo de 3 notas con 7, 9, 4; escribe la de la posición 1 | `9` |

Enlaces: `tipos.arreglos`, `control.para-cada`.

**3. Escribir.** `dias-calurosos`: arreglo de nombres de días, arreglo de temperaturas, primera pasada para el promedio,
segunda para escribir los días; si ninguno supera, `Ningún día`.

**4. Probar.** El ejemplo de la ficha → `martes` ⏎ `jueves` ⏎ `viernes` ⏎ `domingo`. Todos en 20 → `Ningún día`.

**5. Mejorar.** Comparar con la versión de siete variables sueltas: cuántas líneas cambian si la semana tuviera 30 días.

**Resumen.**

- `{arreglo,indice}` Un arreglo guarda datos del mismo tipo; el índice es la posición y empieza en 0.
- `{recorredor}` Un recorredor es el índice que avanza casilla por casilla.
- `{fuera-de-rango}` Usar un índice que no existe es un error fuera de rango y detiene el programa.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `posiciones` | predecir | semilla | sí | Arreglo 4, 8, 15, 16, 23; escribe la suma de las posiciones 1 y 3 | `24` |
| `semana-error` | encontrar-error | brote | sí | El programa suma las 7 temperaturas con `Para i <- 0 Hasta 7` y se detiene | Visibles: 1..7 → 28; 20×7 → 140. Ocultos: 0×7 → 0; 30,31,32,33,34,35,36 → 231; -1×7 → -7 |
| `al-reves` | resolver | semilla | sí | Lee 5 números y los muestra en orden inverso, uno por línea | Visibles: 1..5 → 5..1; 7,7,7,7,7 → igual. Ocultos: 0,1,0,1,0 → 0,1,0,1,0; 9,8,7,6,5 → 5..9; -1,2,-3,4,-5 → -5,4,-3,2,-1 |
| `aprobados` | resolver | brote | — | Lee 6 notas (de 0 a 10) y muestra cuántas son 6 o más | Visibles: 6,5,7,10,2,6 → 4. Ocultos: 5×6 → 0; 6×6 → 6; 0,0,0,0,0,10 → 1; 10×6 → 6 |
| `calurosos-ordenar` | ordenar | brote | — | Las líneas de `dias-calurosos`, sin la parte de `Ningún día` | Casos de la lección |
| `rotar` | resolver | árbol | — | Lee 5 números y los muestra rotados un lugar a la derecha (el último pasa a ser el primero) | Visibles: 1..5 → 5,1,2,3,4. Ocultos: 9,0,0,0,0 → 0,9,0,0,0; 1,1,1,1,2 → 2,1,1,1,1; 3,4,5,6,7 → 7,3,4,5,6 |

**Para docentes.** Índices desde 1; confundir la posición con el valor; una sola pasada para el promedio.

**Siguiente.** «Muchos problemas con colecciones se parecen: contar, buscar, juntar. ¿Hay formas que se repiten?»

---

## 1.6 Buscar, contar y filtrar — `imperativo.esquemas`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `imperativo.arreglos` |
| Introduce | `esquema`, `seguidor` |

**Propósito.** La persona reconoce seis esquemas sobre colecciones (recorrer, contar, acumular, buscar, filtrar y
transformar), los combina y usa un seguidor para comparar cada dato con el anterior. Es la base para reconocer patrones
de diseño en el futuro.

**Frase.** Casi todo problema con una colección es una combinación de unos pocos esquemas que ya conoces.

**Problema.** El kiosco registró la máxima de 14 días seguidos. Una **ola de calor** son **3 o más días seguidos por encima de
30 grados**. **¿Cuántas olas hubo, y cuántos días duró la más larga?**

**Inténtalo.** Con 28, 31, 32, 33, 29, 31, 30, 31, 32, 31, 35, 27, 31, 32. Respuesta: rachas de 3, 1, 4 y 2 días; olas: 2;
la más larga: 4. El 30 no cuenta: tiene que ser **más** de 30.

**1. Entender.** Ficha. Bordes: una ola que termina el último día; exactamente 3 días; 30 grados justos.

**2. Planear.** Figura `ruta-esquemas` (ancla) y definición de esquema. Este problema combina contar (días de la racha),
mejor hasta ahora (la más larga) y contar (olas). `roles` con `ruta-rol-seguidor` para la racha. Figura `ruta-racha`.

**Herramienta nueva.** No hay construcción nueva. Programa mínimo del seguidor:

| Id | Programa | Salida |
|---|---|---|
| `subidas` | Arreglo 20, 22, 21, 25; cuenta cuántas veces un día fue más caluroso que el anterior | `2` |

**3. Escribir.** `olas`: lee 14 temperaturas, recorre con la racha y cierra la última racha **después** del bucle. Salida
`Olas: 2` ⏎ `La más larga: 4`.

**4. Probar.** Caso de la ficha; caso con ola final (los tres últimos días por encima de 30); caso sin olas; caso con
exactamente 3 días.

**5. Mejorar.** Cambiar la definición de ola a «4 o más días»: cuántas líneas cambian si el 3 tiene nombre.

**Resumen.**

- `{esquema}` Recorrer, contar, acumular, buscar, filtrar y transformar son esquemas que se combinan para resolver problemas
  con colecciones.
- `{seguidor}` Un seguidor recuerda el dato anterior o una racha para compararla con el actual.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `que-esquema` | clasificar | semilla | sí | ¿Cuánto se vendió en total?; ¿cuántos días llovió?; ¿hubo algún día de más de 35?; la lista de aprobados; todos los precios con aumento; mostrar cada nota | Acumular; contar; buscar; filtrar; transformar; recorrer |
| `primer-siete` | predecir | semilla | — | Busca la primera posición del 7 en 3, 7, 9, 7 | `1` |
| `olas-romper` | romperlo | brote | sí | Un programa de olas que solo cuenta una racha cuando se corta | Visible: el caso de la ficha. Rompe: 28, 29, 28, 29, 28, 29, 28, 29, 28, 29, 28, 31, 32, 33 (el bueno dice 1 ola de 3; el defectuoso, 0) |
| `primer-desaprobado` | resolver | brote | sí | Lee 6 notas y muestra la posición de la primera menor que 6, o -1 si no hay | Visibles: 7,8,3,9,2,6 → 2; 6,7,8,9,10,6 → -1. Ocultos: 5,9,9,9,9,9 → 0; 6,6,6,6,6,5 → 5; 0×6 → 0 |
| `sin-lluvia` | resolver | árbol | — | Lee 10 días (1 si llovió, 0 si no) y muestra la racha más larga sin lluvia | Visibles: 0,0,1,0,0,0,1,1,0,0 → 3; 1×10 → 0. Ocultos: 0×10 → 10; 1,0,0,0,0,1,0,1,0,0 → 4; 0,1,0,1,0,1,0,1,0,0 → 2 |
| `buscar-pruebas` | disenar-pruebas | árbol | — | Casos para «posición de la primera aparición de un número en 5 leídos, o -1» | Mutantes: devuelve la última aparición; recorre desde la posición 1; devuelve 0 si no está. Solución: con repetidos, con el buscado en la posición 0, y ausente |

**Para docentes.** Olvidar la última racha; reiniciar la racha en el lugar equivocado; querer un esquema nuevo para cada
problema.

**Siguiente.** «Un tablero de tres en raya no es una fila de datos: tiene filas y columnas. ¿Cómo se guarda y se recorre?»

---

## 1.7 Tableros y cuadrículas — `imperativo.cuadriculas`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `imperativo.esquemas` |
| Introduce | `matriz`, `bucle-anidado`, `concatenar` |

**Propósito.** La persona representa una cuadrícula como matriz, la recorre por filas, columnas y diagonales con bucles
anidados y arma texto concatenando.

**Frase.** Una matriz es un arreglo con filas y columnas, y cada casilla se encuentra con dos números.

**Problema.** En el recreo juegan al tres en raya. Al terminar, el tablero se anota fila por fila: 0 para vacío, 1 para X y 2
para O. **¿Quién ganó?**

**Inténtalo.** Tablero 1, 2, 1 / 2, 1, 2 / 2, 1, 1. Respuesta: gana X por la diagonal principal.

**1. Entender.** Ficha. Formas de ganar: 3 filas, 3 columnas, 2 diagonales. Borde: nadie gana; tablero vacío.

**2. Planear.** Figura `ruta-matriz-coordenadas`. Revisar filas, columnas y diagonales con el mismo esquema (buscar).

**Herramienta nueva.** Matriz con la figura de la Especificación `tipos.arreglos#arreglo-casillas` (dos dimensiones),
bucle anidado y concatenación (enlace `expresiones.concatenacion`).

| Id | Programa | Salida |
|---|---|---|
| `dibujar-tablero` | Recorre una matriz 3×3 y escribe cada fila como texto con `X`, `O` y `.`, armado con concatenación | `X O X` ⏎ `O X O` ⏎ `O X X` para el tablero del Inténtalo |

**3. Escribir.** `tres-en-raya`: lee 9 números y escribe `Gana X`, `Gana O` o `Nadie`.

**4. Probar.** Una victoria por fila, una por columna, una por cada diagonal y un empate.

**5. Mejorar.** Para un tablero de 4×4: qué cambia si el 3 tiene nombre.

**Resumen.**

- `{matriz}` Una matriz guarda datos en filas y columnas; cada casilla tiene dos índices.
- `{bucle-anidado}` Un bucle anidado recorre todas las columnas de cada fila.
- `{concatenar}` Concatenar es unir textos para formar uno nuevo.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `filas-texto` | predecir | semilla | sí | `Para f <- 1 Hasta 2`, `Para c <- 1 Hasta 3`, arma una línea con `f * c` separados por espacios | `1 2 3` ⏎ `2 4 6` |
| `suma-filas` | resolver | semilla | sí | Lee 9 números de una cuadrícula 3×3 y muestra la suma de cada fila | Visibles: 1..9 → 6, 15, 24; 0×9 → 0, 0, 0. Ocultos: 1×9 → 3, 3, 3; 9,0,0,0,9,0,0,0,9 → 9, 9, 9; -1,1,0,2,2,2,5,0,0 → 0, 6, 5 |
| `raya-romper` | romperlo | brote | sí | Un programa que no revisa la diagonal de derecha a izquierda | Visible: tablero del Inténtalo. Rompe: 2, 0, 1, 0, 1, 0, 1, 0, 2 (gana X) |
| `negativo` | resolver | brote | — | Una imagen de 4×4 en blanco (0) y negro (1). Lee los 16 valores y muestra la imagen invertida, una fila por línea, sin espacios | Visibles: 0110/1001/1001/0110 → 1001/0110/0110/1001; todo 0 → todo 1. Ocultos: todo 1; diagonal; una sola casilla |
| `cuadrado-magico` | resolver | árbol | — | Lee 9 números. Es mágico si todas las filas, columnas y las dos diagonales suman lo mismo. Muestra `Es mágico` o `No es mágico` | Visibles: 2,7,6,9,5,1,4,3,8 → Es mágico; 1..9 → No es mágico. Ocultos: 8,1,6,3,5,7,4,9,2 → Es mágico; 5×9 → Es mágico; 2,7,6,9,5,1,4,8,3 → No es mágico |
| `casillas` | explicar | semilla | — | ¿Qué posición es el centro del tablero? `[1, 1]`, `[2, 2]`, `[1, 2]` | `[1, 1]`: los índices empiezan en 0 |

**Para docentes.** Confundir fila con columna; índices desde 1; revisar solo filas.

**Siguiente.** «Pienso un número entre 1 y 100. ¿Cuántas preguntas necesitas para adivinarlo? ¿Hay una forma mejor que
probar uno por uno?»

---

## 1.8 Más de una manera — `imperativo.estrategias`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `imperativo.cuadriculas` |
| Introduce | `estrategia`, `fuerza-bruta`, `busqueda-binaria`, `costo`, `ordenamiento-por-seleccion` |

**Propósito.** La persona compara estrategias por su costo contando pasos, usa la búsqueda binaria y ordena con selección.

**Frase.** Dos programas correctos pueden tardar muy distinto; contar sus pasos dice cuál conviene.

**Problema.** Juegan a adivinar: alguien piensa un número del 1 al 100; tú dices un número y te responden «mayor», «menor»
o «acertaste». **¿Qué estrategia adivina en la menor cantidad de intentos, aun en el peor caso?**

**Inténtalo.** Jugar en parejas con papel. Respuesta: empezar por 50 y quedarse siempre con la mitad: nunca más de 7
intentos. Probar uno por uno puede necesitar 100.

**1. Entender.** Ficha: entra el número secreto (para simular el juego); sale la cantidad de intentos. Bordes: 1 y 100.

**2. Planear.** Definición de estrategia y de fuerza bruta. Figura `ruta-busqueda-binaria`.

**Herramienta nueva.** No hay construcción nueva. Costo: contar pasos con un contador; figura `ruta-pasos-crecen`. La
búsqueda binaria exige datos ordenados: ordenamiento por selección con la figura `ruta-seleccion`.

**3. Escribir.**

| Id | Programa | Entrada | Salida |
|---|---|---|---|
| `adivinar` | Simula la estrategia de mitades con `bajo`, `alto` y `medio <- (bajo + alto) div 2` | `37` | `Intentos: 3` (50, 25, 37) |
| `buscar-ordenado` | Búsqueda binaria en un arreglo ordenado de 15 números, con contador de pasos | el agente elige los datos | posición y pasos |
| `seleccion` | Ordena 5 números leídos | `5` ⏎ `3` ⏎ `8` ⏎ `1` ⏎ `9` | `1` ⏎ `3` ⏎ `5` ⏎ `8` ⏎ `9` |

**4. Probar.** `adivinar` con 1, 100 y 50. Invariante de la búsqueda binaria: «si el número está, está entre `bajo` y
`alto`».

**5. Mejorar.** Volver al primo de 1.4: probar divisores solo mientras `d * d <= n`. Con 97, de 95 divisiones a 8.

**Resumen.**

- `{estrategia,fuerza-bruta}` Una estrategia es una forma de resolver un problema; la fuerza bruta prueba todas las
  posibilidades.
- `{busqueda-binaria}` La búsqueda binaria descarta la mitad en cada paso, pero necesita datos ordenados.
- `{costo}` El costo de un algoritmo se estima contando sus pasos en el peor caso.
- `{ordenamiento-por-seleccion}` El ordenamiento por selección lleva al frente, una y otra vez, el menor de los que faltan.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `intentos-100` | predecir | semilla | sí | `adivinar` con el secreto 100 | `Intentos: 7` (50, 75, 88, 94, 97, 99, 100) |
| `guia-telefonica` | comparar | semilla | — | Buscar un nombre en una lista ordenada de 1000: ¿uno por uno o por mitades? ¿cuántos pasos como máximo en cada caso? | Por mitades: 10 frente a 1000 |
| `binaria` | resolver | brote | sí | Lee 10 números ordenados de menor a mayor y un número buscado; muestra su posición o -1 | Visibles: 1..10 y 7 → 6; 2,4,…,20 y 5 → -1. Ocultos: buscado en la posición 0, en la 9, menor que todos, mayor que todos |
| `binaria-romper` | romperlo | brote | sí | Una búsqueda binaria que hace `bajo <- medio` en vez de `medio + 1` | Visible: un buscado que está en el centro. Rompe: un buscado ausente mayor que todos (el defectuoso no termina; se detiene por límite) |
| `ordenar-seis` | resolver | árbol | — | Lee 6 números y los muestra de menor a mayor | Visibles: 5,3,8,1,9,2 → 1,2,3,5,8,9; 1..6 → igual. Ocultos: 6..1; 4,4,1,4,1,1; -2,0,-5,3,3,-1 |
| `seleccion-tabla` | rastrear | árbol | — | Ordenamiento por selección de 4, 3, 2, 1; una fila por vuelta del bucle exterior, columnas `v[0]` a `v[3]` | 1,3,2,4; 1,2,3,4; 1,2,3,4 |

`rastrear` con columnas de arreglo requiere que la instrumentación admita designadores (`v[0]`). Si el compilador solo
admite variables, el agente usa variables auxiliares en el programa del ejercicio y lo reporta.

**Para docentes.** «El más rápido es el que tiene menos líneas»; búsqueda binaria sobre datos sin ordenar; el `medio` que no
avanza.

**Siguiente.** «Llegó el momento de juntar todo lo aprendido en la caja del kiosco.»

---

## P·I Proyecto: la caja del kiosco — `imperativo.proyecto`

| Campo | Valor |
|---|---|
| Tipo | `proyecto` · 60 min · árbol |
| Necesita | `imperativo.estrategias` |
| Introduce | — |

**Propósito.** Integrar decisiones, bucles, arreglos, roles y esquemas en un programa real, recorriendo el ciclo completo
sin guía paso a paso.

**Frase.** Un proyecto es un problema grande que se resuelve con las herramientas que ya tienes.

**Problema.** Durante el recreo, la caja del kiosco anota cada venta como **código de producto** y **cantidad**. Al cerrar,
escribe el código **0**. Hay que mostrar el ticket del día: una línea por venta con producto, cantidad e importe; el
total; el total con descuento; y el producto que más unidades vendió. Un código que no existe se informa y se ignora.
**¿Cómo es el programa de la caja?**

Productos, precios y descuento: tabla de 03 §5.1.

**Inténtalo.** Ventas 1 × 3, 2 × 2, 3 × 1, 1 × 1, fin. Respuesta: importes 9, 10, 2, 3; total 24; con descuento 22; más
vendido: Jugo (4 unidades).

**Fases.** Las cinco separadas. La ficha y el plan son ejercicios.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `caja-ficha` | clasificar | árbol | sí | Ubicar cada dato del enunciado: código, cantidad, precios, el 0, el descuento, la hora del recreo, el ticket, el más vendido | Entra: código, cantidad, 0 (centinela). Dato fijo: precios, descuento. Sale: ticket, total, más vendido. No importa: hora |
| `caja-plan` | ordenar | árbol | sí | Ordenar los pasos del plan en lenguaje natural: preparar nombres y precios; leer el primer código; mientras no sea 0: validar, leer cantidad, escribir la línea, acumular total y unidades, leer el siguiente; calcular el descuento; buscar el más vendido; escribir el cierre | Orden exacto |
| `caja` | resolver | árbol | sí | El programa completo, con el formato de salida exacto que define el enunciado | Visibles: el del Inténtalo; un día sin ventas (0 directo: total 0, más vendido `Ninguno`). Ocultos: un código inválido en medio; empate en el más vendido (gana el de menor código, regla del enunciado); una sola venta; los cinco productos; cantidades grandes |

**Para docentes.** Planear antes de abrir el editor; probar el día sin ventas; el desempate.
