# 13 — Parte III: Orientación a objetos

**Lema:** Cosas que saben y hacen.

**Propósito de la parte:** que la persona agrupe estado y conducta en objetos, proteja lo que siempre tiene que ser cierto,
entienda la identidad, programe contra contratos, elija entre heredar y componer, y reparta responsabilidades. Es la
preparación directa para el release de patrones de diseño. Seis lecciones y un proyecto, unas cuatro horas.

Fases 1 y 2 condensadas con la pregunta propia de la parte: ¿quién tiene la información para hacer esto?

---

## 3.1 Cosas que saben y hacen — `objetos.cosas`

| Campo | Valor |
|---|---|
| Tipo | `apertura` · 40 min · semilla a árbol |
| Necesita | `procedimental.proyecto` |
| Introduce | `programacion-orientada-a-objetos`, `objeto`, `clase`, `atributo`, `metodo`, `constructor`, `instancia` |

**Propósito.** La persona agrupa los datos y las operaciones de una misma cosa en una clase, crea varios objetos
independientes y les pide que hagan cosas.

**Frase.** Un objeto guarda su propio estado y sabe hacer las operaciones que le corresponden.

**Problema.** El kiosco tiene **dos máquinas expendedoras**. Cada una tiene su **stock** de latas, el **dinero** recaudado y el
**precio** (3 pesos). El programa actual usa `stock1`, `dinero1`, `stock2`, `dinero2` y repite el código de vender para cada
máquina. Ayer, una venta en la máquina 1 descontó una lata de la máquina 2. **¿Cómo se escribe para que cada máquina cuide
sus propios datos?**

**Inténtalo.** Encontrar en el programa dado la línea que descuenta de la máquina equivocada.

**Un paradigma nuevo.** Bloque completo:

- Pregunta: ¿y si los datos vinieran con sus propias operaciones y supieran cuidarse solos?
- Metáfora: una máquina expendedora real. Por dentro tiene latas y monedas; por fuera, botones. Nadie mete la mano para
  sacar una lata. Deja de valer en que un objeto de programa puede crearse cuantas veces haga falta.
- Historia: en 1967, Ole-Johan Dahl y Kristen Nygaard presentaron Simula, el primer lenguaje con clases y objetos. En la
  década de 1970, el equipo de Alan Kay en Xerox PARC creó Smalltalk, donde todo es un objeto que recibe mensajes.
- Costo: hay que decidir qué cosas existen y qué sabe hacer cada una; un mal reparto complica más de lo que ayuda.

**Entender y planear.** Las tres preguntas. Una máquina sabe su stock, su dinero y su precio; sabe vender y cargar latas.

**Herramienta nueva.** Clase, objeto, atributo, método, constructor e instancia, con las figuras `ruta-molde`,
`objetos.clase#clase-objetos` y `objetos.constructor#nuevo-pasos`.

| Id | Programa | Salida |
|---|---|---|
| `contador` | `Clase Contador` con atributo `valor`, método `Incrementar` y método `Valor`; un objeto incrementado dos veces | `2` |

Enlaces: `objetos.clase`, `objetos.metodos`, `objetos.constructor`.

**3. Escribir.** `maquinas`: `Clase Maquina` con `stock`, `recaudado` y `precio`; `Vender()` devuelve si pudo; dos instancias.
Vender dos latas en la 1 y una en la 2 → `Máquina 1: 8 latas, 6 pesos` ⏎ `Máquina 2: 9 latas, 3 pesos` (stock inicial 10).

**4. Probar.** Vender en una máquina sin stock (devuelve `Falso`, no cambia nada).

**5. Mejorar.** Una tercera máquina es una línea. Tabla que compara variables sueltas con objetos.

**Resumen.**

- `{programacion-orientada-a-objetos}` La programación orientada a objetos arma un programa con objetos que guardan su estado
  y colaboran.
- `{clase,objeto,instancia}` Una clase describe un tipo de objeto; cada objeto creado con ella es una instancia.
- `{atributo,metodo}` Los atributos son lo que el objeto sabe; los métodos, lo que sabe hacer.
- `{constructor}` El constructor prepara un objeto nuevo con sus valores iniciales.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `mascota` | clasificar | semilla | sí | Una mascota virtual: nombre, energía, comer, jugar, hambre, dormir. ¿Qué es atributo y qué es método? | Atributos: nombre, energía, hambre. Métodos: comer, jugar, dormir |
| `dos-contadores` | predecir | semilla | sí | Dos objetos `Contador`; uno se incrementa 3 veces y el otro una; escribe los dos | `3 1` |
| `alcancia-objeto` | resolver | semilla | sí | Una clase `Alcancia` con `Depositar` y `Total`. El algoritmo lee depósitos hasta 0 y muestra el total | Aserción: miembro `Depositar` público. Visibles: 2, 3, 4, 0 → 9; 0 → 0. Ocultos: 50, 0; 1×10 y 0; 7, 0 |
| `maquina-resolver` | resolver | brote | — | La clase `Maquina`: lee ventas de la máquina 1 o 2 hasta 0 y muestra el estado de las dos | Ocultos: máquina sin stock; ventas solo en una |
| `clase-u-objeto` | explicar | semilla | — | «Molde» y «galleta»: ¿cuál es la clase? | El molde; la galleta es el objeto. Explicación de dónde falla la analogía |
| `cronometro-objeto` | resolver | árbol | — | Una clase `Cronometro` con `Avanzar(segundos)` y `Mostrar()` en formato `1 h 2 min 5 s` | Reutiliza la lógica de 0.2. Ocultos: 0, 59, 3600, 86399 |

**Para docentes.** «La clase y el objeto son lo mismo»; un método que no usa el estado del objeto; atributos que deberían ser
variables locales.

**Siguiente.** «Alguien dejó la tarjeta del comedor con saldo negativo. ¿Cómo se impide desde el objeto?»

---

## 3.2 Proteger lo que debe ser cierto — `objetos.invariantes`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `objetos.cosas` |
| Introduce | `encapsulamiento`, `invariante-de-clase` |

**Propósito.** La persona identifica lo que siempre tiene que ser cierto de un objeto y lo protege ocultando sus atributos y
validando en sus métodos.

**Frase.** Un objeto bien hecho no deja que nadie lo ponga en un estado imposible.

**Problema.** La tarjeta del comedor tiene un **saldo** público. Un programa cobró 50 pesos a una tarjeta con 30 y dejó el
saldo en **-20**. Otro cargó -100. **¿Cómo se escribe la tarjeta para que eso no pueda pasar, la use quien la use?**

**Inténtalo.** Escribir en una frase qué tiene que ser cierto siempre de una tarjeta. Respuesta: el saldo nunca es negativo.

**Entender y planear.** Las tres preguntas. La tarjeta tiene la información para decidir si alcanza.

**Herramienta nueva.** Encapsulamiento con la figura `ruta-caja-fuerte`; invariante de clase (tarjeta de recuerdo de
`invariante` y de `visibilidad`). Enlaces: `objetos.clase`, `objetos.metodos`.

**3. Escribir.** `tarjeta`: `saldo` privado; `Cobrar(monto)` devuelve `Falso` sin cambiar nada si no alcanza;
`Cargar(monto)` rechaza montos no positivos; `Saldo()`.

**4. Probar.** Cobrar exactamente el saldo (borde: queda 0); cobrar uno más; cargar 0 y -5.

**5. Mejorar.** Comparar con la versión de atributo público: la regla vive en un solo lugar.

**Resumen.**

- `{encapsulamiento}` Encapsular es ocultar los atributos y dejar que solo los métodos los cambien.
- `{invariante-de-clase}` Un invariante de clase es lo que tiene que ser cierto de todo objeto antes y después de cada método.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `tarjeta-negativa` | encontrar-error | brote | sí | `Cobrar` resta sin comprobar | Visibles y ocultos con cobros mayores que el saldo |
| `no-alcanza` | predecir | semilla | — | Tarjeta con 10; `Cobrar(15)` y luego `Saldo()` | `Falso` ⏎ `10` (formato de los lógicos según el motor) |
| `atributo-privado` | modificar | brote | sí | Convierte `saldo` en privado y agrega los métodos necesarios sin cambiar lo que muestra el programa | Aserción: miembro `saldo` privado. Casos de la versión inicial |
| `tarjeta-pruebas` | disenar-pruebas | brote | sí | Casos para `Cobrar` y `Cargar` | Mutantes: `>` en lugar de `>=` al comparar saldo y monto; permite negativo; `Cargar` acepta negativos. Solución: cobrar justo el saldo; cobrar más; cargar -5 |
| `termostato` | resolver | árbol | — | Una clase `Termostato` entre 16 y 30 grados; `Subir()` y `Bajar()` nunca pasan los límites | Ocultos: subir desde 30; bajar desde 16; muchos pasos |
| `invariantes-ascensor` | clasificar | semilla | — | De un ascensor: el piso está entre 0 y 10; hay como máximo 8 personas; es de color gris; la puerta no se abre en movimiento | Invariantes: 1, 2 y 4. No: 3 |

**Para docentes.** «Privado es para esconder errores»; validar afuera en vez de en el método; un `Asignar` público para cada
atributo, que rompe la protección.

**Siguiente.** «Copié un pedido para armar otro parecido, le agregué un alfajor a la copia... y el original también lo
tiene. ¿Qué pasó?»

---

## 3.3 Dos nombres, un objeto — `objetos.identidad`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla a árbol |
| Necesita | `objetos.invariantes` |
| Introduce | `identidad`, `alias`, `referencia-a-objeto` |
| Pieza | 6 |

**Propósito.** La persona distingue tener dos nombres para un objeto de tener dos objetos, y sabe cuándo hace falta una copia.

**Frase.** Asignar un objeto a otra variable no lo copia: le da otro nombre al mismo objeto.

**Problema.** En el kiosco, un pedido es un objeto con su lista de productos. Para armar un pedido parecido, alguien escribió
`copia <- pedido` y le agregó un alfajor a `copia`. El ticket del pedido original **también** muestra el alfajor. **¿Por qué
pasó, y cómo se hace una copia de verdad?**

**Inténtalo.** Predecir qué muestran los dos pedidos.

**Entender y planear.** Las tres preguntas. Comparar con la lección 2.5: un registro sí se copia al asignarlo (tarjeta de
recuerdo de `registro`).

**Herramienta nueva.** Identidad, alias y referencia a un objeto (pieza 6) con las figuras `objetos.copia#alias-copia` y
`ruta-flechas-pedido`. La forma de copiar un objeto sale de `objetos.copia`. Enlace: `objetos.copia`.

**3. Escribir.** `pedidos`: la versión con alias y la versión con copia real.

**4. Probar.** Modificar por cada nombre y mirar los dos.

**5. Mejorar.** Cuándo conviene compartir (todos ven el mismo inventario) y cuándo copiar (cada pedido es suyo).

**Resumen.**

- `{identidad}` La identidad es lo que hace que un objeto sea ese objeto y no otro igual.
- `{alias,referencia-a-objeto}` Una variable de objeto guarda una referencia al objeto; dos variables con la misma referencia
  son alias.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `alias-predecir` | predecir | semilla | sí | `a <- Nuevo Contador()`, `b <- a`, `b.Incrementar()`, escribe `a.Valor()` | `1` |
| `mismo-o-distinto` | clasificar | semilla | — | Cuatro pares de variables en un programa dado: ¿mismo objeto o distintos? | Según el programa |
| `pedido-copia` | encontrar-error | brote | sí | El programa de los pedidos con alias; corrígelo para que el original no cambie | Casos con la salida de los dos tickets |
| `dos-tarjetas` | resolver | brote | sí | Lee un saldo inicial y crea dos tarjetas con ese saldo; cobra 5 a la primera y muestra los dos saldos | Visibles: 20 → `15 20`. Ocultos: 5 → `0 5`; 3 → `3 3` (no alcanza) |
| `registro-u-objeto` | comparar | brote | — | Para un pedido que varias pantallas tienen que ver actualizado, ¿registro u objeto? | Objeto; justificación por opción |

**Para docentes.** «Asignar copia»; comparar objetos con `=` esperando comparar contenido (enlazar `objetos.copia`); creer que
el alias es un error siempre.

**Siguiente.** «La caja cobra en efectivo, con tarjeta y con vale, y cada medio nuevo obliga a tocar la caja. ¿Se puede
agregar un medio sin tocarla?»

---

## 3.4 Contratos — `objetos.contratos`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `objetos.identidad` |
| Introduce | `interfaz`, `polimorfismo`, `despacho-dinamico` |

**Propósito.** La persona define un contrato con una interfaz, escribe varias clases que lo cumplen y un código que funciona
con cualquiera de ellas.

**Frase.** Si el código depende de lo que un objeto promete y no de qué objeto es, se le pueden agregar casos sin tocarlo.

**Problema.** La caja cobra en **efectivo** (sin recargo), con **tarjeta** (5 % de recargo, en pesos enteros) y con **vale**
(paga hasta lo que tiene el vale). Hoy la caja tiene un `Segun` por medio de pago, y la semana que viene se agrega la
**transferencia**. **¿Cómo se escribe la caja para que un medio nuevo no obligue a cambiarla?**

**Inténtalo.** Cobrar 20 pesos con cada medio (vale de 15). Respuesta: 20; 21 (20 + 20 × 5 div 100); 15 con el vale y 5 que
faltan.

**Entender y planear.** Las tres preguntas. Lo que cambia es cómo se cobra; lo que no cambia es que la caja pide cobrar.

**Herramienta nueva.** Interfaz, polimorfismo y despacho dinámico con las figuras `ruta-enchufe`,
`objetos.interfaces#interfaz-promesa` y `objetos.herencia#herencia-despacho`. Enlaces: `objetos.interfaces`, `objetos.herencia`.

**3. Escribir.** `medios-de-pago`: interfaz `MedioDePago` con `Cobrar(monto)`; tres clases; una caja que recibe cualquier
medio.

**4. Probar.** La caja con cada medio y con 0 pesos.

**5. Mejorar.** Agregar `Transferencia` sin tocar la caja. Contar las líneas que cambiaron en cada diseño.

**Resumen.**

- `{interfaz}` Una interfaz es un contrato: los métodos que una clase promete tener.
- `{polimorfismo,despacho-dinamico}` Polimorfismo es usar objetos de clases distintas a través del mismo contrato; el despacho
  dinámico elige en ejecución el método de la clase real.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `cumple-contrato` | clasificar | semilla | — | Cuatro clases dadas: ¿cumplen el contrato `MedioDePago`? | Según el código del enunciado |
| `que-metodo` | predecir | semilla | sí | Un vector de medios de pago recorrido cobrando 10 a cada uno | Las tres líneas con los importes |
| `transferencia` | modificar | brote | sí | Agrega el medio `Transferencia` (sin recargo, con 1 peso de costo fijo) sin cambiar la caja | Restricción: la clase `Caja` no cambia (aserción: la caja no contiene `Segun`). Casos con los cuatro medios |
| `figuras-area` | resolver | árbol | sí | Una interfaz `Figura` con `Area()` para rectángulo, cuadrado y triángulo rectángulo; el algoritmo lee el tipo y las medidas y muestra el área | Ocultos: medidas 0; triángulo con área no entera |
| `por-que-contrato` | explicar | brote | — | ¿Qué gana la caja al depender de `MedioDePago`? | Se agregan medios sin tocarla |

**Para docentes.** Una interfaz con métodos que nadie usa; el `Segun` que vuelve a aparecer en otro lado; confundir interfaz
con herencia.

**Siguiente.** «Algunos productos vencen, otros están en oferta y otros las dos cosas. ¿Una clase hija para cada
combinación?»

---

## 3.5 Heredar o componer — `objetos.componer`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 35 min · semilla a árbol |
| Necesita | `objetos.contratos` |
| Introduce | `herencia`, `composicion`, `sobrescribir` |

**Propósito.** La persona usa herencia para la relación «es un» y composición para «tiene un», y reconoce la explosión de
combinaciones como señal de que conviene componer.

**Frase.** Heredar dice qué es algo; componer dice qué tiene. Cuando los rasgos se combinan, componer escala mejor.

**Problema.** En el kiosco hay productos que **vencen** (tienen fecha) y productos **en oferta** (tienen porcentaje). Alguien
creó `ProductoVencible` y `ProductoEnOferta` como hijos de `Producto`. Ahora llega un yogur que vence **y** está en oferta.
**¿Hace falta una tercera clase hija? ¿Y si mañana aparece un tercer rasgo?**

**Inténtalo.** Contar cuántas clases harían falta con 3 rasgos combinables. Respuesta: 8 combinaciones.

**Entender y planear.** Las tres preguntas. Figura `ruta-explosion-clases`.

**Herramienta nueva.** Herencia, `Super` y sobrescritura (figura `objetos.herencia#herencia-despacho`); composición. Lo que
el lenguaje no tiene (clases abstractas, visibilidad protegida) se enlaza. Enlaces: `objetos.herencia`, `objetos.ausentes`.

**3. Escribir.** `productos-componer`: `Producto` tiene un `Vencimiento` opcional y una `Oferta` opcional; `PrecioFinal()`
usa lo que tenga.

**4. Probar.** Los cuatro tipos de producto.

**5. Mejorar.** Un tercer rasgo (envase retornable) agrega una clase, no cuatro.

**Resumen.**

- `{herencia,sobrescribir}` Heredar crea una clase que es un caso particular de otra y puede sobrescribir sus métodos.
- `{composicion}` Componer es armar un objeto con otros objetos que tiene adentro.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `es-o-tiene` | clasificar | semilla | sí | Un cajero y una persona; un producto y su fecha de vencimiento; un círculo y una figura; un pedido y sus productos | Es: 1 y 3. Tiene: 2 y 4 |
| `super-predecir` | predecir | semilla | — | `Cajero` sobrescribe `Saludar` y llama a `Super` | Las dos líneas |
| `yogur` | modificar | brote | sí | El diseño con herencia y tres clases hijas: reescríbelo con composición sin cambiar los precios | Aserción: no hay clase que herede de `Producto`. Casos con los cuatro tipos |
| `empleados` | resolver | brote | sí | Clase `Empleado` y clase `Cajero` que hereda y sobrescribe `Presentarse` | Casos |
| `cuando-heredar` | explicar | brote | — | ¿Cuándo es buena idea heredar? | Cuando la hija es un caso particular y no se combinan rasgos |

**Para docentes.** Heredar para reutilizar código; jerarquías profundas; creer que componer es «menos orientado a objetos».

**Siguiente.** «La clase `Kiosco` hace todo y tiene 600 líneas. ¿Cómo se decide a quién le toca cada cosa?»

---

## 3.6 ¿A quién le toca? — `objetos.responsabilidades`

| Campo | Valor |
|---|---|
| Tipo | `leccion` · 30 min · semilla y brote |
| Necesita | `objetos.componer` |
| Introduce | `responsabilidad`, `tarjeta-de-responsabilidad`, `colaborador` |

**Propósito.** La persona reparte responsabilidades entre clases con tarjetas, preguntando quién tiene la información, y
reconoce una clase que hace demasiado. Prepara el release de patrones de diseño.

**Frase.** Cada tarea le toca a la clase que tiene la información para hacerla.

**Problema.** La clase `Kiosco` lee las ventas, calcula importes, descuenta stock, aplica el descuento y escribe el ticket.
Cada cambio, por chico que sea, toca esa clase. **¿Cómo se reparte el trabajo?**

**Inténtalo.** Listar las tareas de `Kiosco` y escribir al lado qué dato necesita cada una.

**Entender y planear.** Las tres preguntas. Figura `ruta-tarjetas` (ancla): `Producto`, `Inventario`, `Caja` y `Ticket`.

**Herramienta nueva.** No hay construcción nueva. Tarjetas de responsabilidad (clase, responsabilidades, colaboradores).

**3. Escribir.** `kiosco-repartido`: el mismo comportamiento con cuatro clases.

**4. Probar.** Las mismas salidas que la clase única.

**5. Mejorar.** Cambiar el formato del ticket toca solo `Ticket`.

**Resumen.**

- `{responsabilidad,colaborador}` Una responsabilidad es algo que una clase sabe o hace; sus colaboradores son las clases a las
  que les pide ayuda.
- `{tarjeta-de-responsabilidad}` Una tarjeta de responsabilidad anota una clase, lo que le toca y con quién colabora.

**Ejercicios.** Solo uno ejecuta código, y no es obligatorio (excepción de 03 §6.1).

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `a-quien-le-toca` | clasificar | semilla | sí | Ocho tareas del kiosco en `Producto`, `Inventario`, `Caja` o `Ticket` | Según el reparto de la lección |
| `dos-disenos` | comparar | brote | sí | Dos repartos de la misma funcionalidad: ¿cuál cambia menos si se agrega un impuesto? | El que pone el cálculo en `Producto` |
| `colaboracion` | ordenar | brote | sí | Los pasos de una venta como mensajes entre objetos (cerca `pasos`) | Orden exacto |
| `mover-metodo` | modificar | brote | — | Mueve el cálculo del importe de `Caja` a `Producto` | Aserción: `Producto` tiene `Importe`. Casos de la versión inicial |
| `clase-dios` | explicar | semilla | — | ¿Qué problema tiene una clase que hace todo? | Todo cambio la toca y nadie la entiende entera |

**Para docentes.** Clases con nombre de verbo («Calculador»); repartir por tamaño y no por información; tarjetas con diez
responsabilidades.

**Siguiente.** «El kiosco, ahora con objetos.»

---

## P·III Proyecto: el kiosco con objetos — `objetos.proyecto`

| Campo | Valor |
|---|---|
| Tipo | `proyecto` · 75 min · árbol |
| Necesita | `objetos.responsabilidades` |

**Problema.** La caja con stock de P·II, ahora con objetos. Al cerrar, el cliente elige pagar en **efectivo** o con
**tarjeta** (5 % de recargo en pesos enteros). El inventario **nunca** queda negativo. **¿Cómo se reparte en objetos?**

**Inténtalo.** Las ventas de P·II pagadas con tarjeta. Respuesta: total con descuento 31; con tarjeta 31 + 31 × 5 div 100 =
32.

**Ejercicios.**

| Id | Tipo | Nivel | Obl. | Problema | Respuesta y verificación |
|---|---|---|---|---|---|
| `objetos-tarjetas` | clasificar | árbol | sí | Ubicar diez responsabilidades en `Producto`, `Inventario`, `MedioDePago`, `Caja` y `Ticket` | Según el enunciado |
| `objetos-plan` | ordenar | árbol | sí | Pasos del plan (cerca `pasos`) | Orden exacto |
| `kiosco-objetos` | resolver | árbol | sí | El programa completo | Aserciones: interfaz `MedioDePago` con dos clases; `Inventario` con stock privado. Ocultos: los de P·II, cada uno con efectivo y con tarjeta |
