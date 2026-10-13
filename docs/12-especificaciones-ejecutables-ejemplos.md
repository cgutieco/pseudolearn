# 12 · Especificaciones ejecutables: ejemplos

> **Estado:** **todos los ejemplos son PROPUESTAS** para evaluar el diseño de
> [11](11-especificaciones-ejecutables-diseno.md). Ninguno es normativo. Los que dicen «migración» toman
> reglas vigentes de `language-spec.md` y las reescriben en el formato propuesto; sus casos se
> comprobaron contra el núcleo actual con las sondas J y K del [anexo A](anexos/A-experimentos-reproducibles.md).
> Los identificadores usan mnemónicos en inglés a modo de ilustración ([D-20](17-riesgos-preguntas-y-decisiones.md#d-20)).

Cubre V-47: closure, clase, interfaz, memoria, motor y comportamientos de la app, conectados entre sí.

---

## 1. Migración de una regla vigente: `LANG.CONTROL.FOR`

Muestra que el formato puede absorber `language-spec.md` sin perder nada y que, al hacerlo, una regla
no implementada (H-37) aparece sola.

````markdown
---
id: LANG.CONTROL.FOR
titulo: Bucle contado
titulo_en: Counted loop
dominio: lenguaje
estado: estable
version: 1.0.0
edicion: { introducida_en: "2026" }
sujetos: [nucleo]
depende_de:
  - { id: LANG.TYPES.INTEGER, version: "^1", tipo: usa }
  - { id: LANG.DECL.DESIGNATOR, version: "^1", tipo: usa }
  - { id: DIAG.SEVERITY.POLICY, version: "^1", tipo: usa }
---

# Bucle contado

Forma: `<para> <identificador> <asignación> <expresión> <hasta> <expresión>
[<con paso> <expresión>] <hacer> <cuerpo> <fin de para>`.

```regla
id: R1
fuerza: DEBE
clase: semantica
texto: >
  El valor inicial, el valor final y el paso se evalúan exactamente una vez,
  en ese orden, antes de la primera prueba. Omitido el paso, vale uno.
verificacion: [C3, Q1]
```

```regla
id: R2
fuerza: DEBE
clase: ejecucion
texto: Un paso que vale cero produce el diagnóstico de ejecución E1 y el cuerpo no se ejecuta.
verificacion: [C4]
```

```regla
id: R3
fuerza: DEBE
clase: semantica
texto: >
  La prueba precede al cuerpo. Con paso positivo se itera mientras la variable
  sea menor o igual que el final; con paso negativo, mientras sea mayor o igual.
  La dirección la decide solo el signo del paso.
verificacion: [C1, C5, Q1]
```

```regla
id: R4
fuerza: DEBE
clase: semantica
texto: Al salir, la variable de control conserva el primer valor que no superó la prueba.
verificacion: [C1, C2, C5]
```

```regla
id: R5
fuerza: DEBE
clase: semantica
texto: >
  Modificar en el cuerpo la variable de control produce la advertencia E3
  en las dos políticas de rigor.
verificacion: [C6]
```

```error
- { id: E1, situacion: paso cero, clase: ejecucion, codigo: zeroStepInCountedLoop, severidad: A }
- { id: E2, situacion: falta la cláusula de paso con «Paso explícito», clase: sintactica, codigo: missingStepClause, severidad: A }
- { id: E3, situacion: se modifica la variable de control en el cuerpo, clase: semantica, codigo: controlVariableModified, severidad: C }
```

```caso
id: C1
etiquetas: [limite]
perfiles: [es, en]
rigor: flexible
programa: |
  Proceso P
    Definir i Como Entero
    Para i <- 10 Hasta 0 Hacer
      Escribir i
    FinPara
    Escribir "fin ", i
  FinProceso
espera:
  salida: "fin 10\n"
origen: escrito
```

```caso
id: C2
perfiles: [es, en]
programa: |
  Proceso P
    Definir i Como Entero
    Para i <- 1 Hasta 3 Hacer
      Escribir i Sin Saltar
    FinPara
    Escribir " / ", i
  FinProceso
espera:
  salida: "123 / 4\n"
origen: escrito
```

```caso
id: C3
perfiles: [es, en]
programa: |
  Proceso P
    Definir i, n Como Entero
    n <- 3
    Para i <- 1 Hasta n Hacer
      n <- 10
      Escribir i Sin Saltar
    FinPara
    Escribir ""
  FinProceso
espera:
  salida: "123\n"
origen: escrito
```

```caso
id: C4
etiquetas: [limite]
perfiles: [es, en]
programa: |
  Proceso P
    Definir i, p Como Entero
    p <- 0
    Para i <- 1 Hasta 3 Con Paso p Hacer
      Escribir i
    FinPara
  FinProceso
espera:
  fallo: { codigo: zeroStepInCountedLoop }
  salida: ""
origen: escrito
```

```caso
id: C5
perfiles: [es, en]
programa: |
  Proceso P
    Definir i Como Entero
    Para i <- 10 Hasta 0 Con Paso -4 Hacer
      Escribir i, " " Sin Saltar
    FinPara
    Escribir "/", i
  FinProceso
espera:
  salida: "10 6 2 /-2\n"
origen: escrito
```

```caso
id: C6
perfiles: [es, en]
rigor: [estricto, flexible]
programa: |
  Proceso P
    Definir i Como Entero
    Para i <- 1 Hasta 3 Hacer
      i <- i + 1
    FinPara
  FinProceso
espera:
  diagnosticos:
    - { codigo: controlVariableModified, severidad: advertencia }
origen: escrito
```

```propiedad
id: Q1
generador: { inicial: entero[-50, 50], final: entero[-50, 50], paso: entero[-7, 7] \ {0} }
propiedad: >
  El número de iteraciones es max(0, floor((final - inicial) / paso) + 1)
  y la variable termina en inicial + iteraciones * paso.
oraculo: aritmetica de precision arbitraria, independiente del sujeto
```
````

**Resultado esperado al ejecutar contra el núcleo actual:** C1 a C5 cumplen (comprobado, sonda J). **C6
incumple**: el núcleo no tiene el código `controlVariableModified` ni emite la advertencia (H-37, sonda
K). El archivo de conformidad del núcleo tendría que declarar `LANG.CONTROL.FOR@1.0.0#R5` como
`pendiente`. Hoy esa regla vive en dos tablas de prosa y nadie sabía que no está implementada.

---

## 2. Reglas transversales que hoy se incumplen: `LANG.SYNTAX.RECOVERY`

````markdown
---
id: LANG.SYNTAX.RECOVERY
titulo: Recuperación ante errores de sintaxis
dominio: lenguaje
estado: estable
version: 1.0.0
sujetos: [nucleo, servicio-lenguaje]
---

```regla
id: R3
fuerza: DEBE
clase: sintactica
texto: Como máximo un diagnóstico sintáctico por sentencia.
verificacion: [C1]
```

```regla
id: R7
fuerza: DEBE
clase: sintactica
texto: El análisis sintáctico siempre devuelve un árbol, también para el texto vacío.
verificacion: [C2]
```

```caso
id: C1
perfiles: [es, en]
programa: |
  Proceso P
    Escribir 1 +
  FinProceso
espera:
  diagnosticos:
    - { codigo: expectedExpression, tramo: "2:15-3:1" }
  diagnosticos_exactos: true
origen: escrito
```

```caso
id: C2
etiquetas: [limite]
perfiles: [es, en]
programa: ""
espera:
  arbol: presente
  diagnosticos: [{ codigo: expectedAlgorithmStart }]
origen: escrito
```
````

**Resultado esperado hoy:** C1 incumple (dos diagnósticos idénticos, H-06) y C2 incumple (árbol nulo,
H-05).

---

## 3. Una característica propuesta: closures

Muestra dependencias entre especificaciones propuestas, casos en modo «esperado fallo» y reglas que
tocan memoria y motor.

````markdown
---
id: LANG.SCOPE.BLOCK
titulo: Ámbitos de bloque
dominio: lenguaje
estado: propuesta
version: 0.1.0
edicion: { introducida_en: "2028" }
sujetos: [nucleo, vm, aot]
reemplaza_reglas: [LANG.DECL.PROGRAM#R4]
---

```regla
id: R1
fuerza: DEBE
clase: semantica
texto: >
  Una variable declarada dentro de un bloque es visible desde su declaración
  hasta el cierre de ese bloque, y es una variable nueva en cada ejecución del bloque.
verificacion: [C1]
```

```caso
id: C1
perfiles: [es, en]
programa: |
  Proceso P
    Si Verdadero Entonces
      Definir x Como Entero
      x <- 1
    FinSi
    Escribir x
  FinProceso
espera:
  diagnosticos: [{ codigo: undeclaredVariable, tramo: "6:14-6:15" }]
origen: escrito
modo: esperado-fallo
```
````

````markdown
---
id: LANG.CLOSURE.CAPTURE
titulo: Captura de variables en funciones locales
dominio: lenguaje
estado: propuesta
version: 0.1.0
edicion: { introducida_en: "2028" }
sujetos: [nucleo, vm, aot]
depende_de:
  - { id: LANG.SCOPE.BLOCK, version: "^0.1", tipo: requiere }
  - { id: LANG.TYPES.FUNCTION, version: "^0.1", tipo: usa }
  - { id: MEM.MANAGED.UNOBSERVABLE, version: "^0.1", tipo: usa }
  - { id: ENG.TRACE.EVENTS, version: "^1", tipo: usa }
---

```regla
id: R1
fuerza: DEBE
clase: semantica
texto: >
  Una función local captura las variables libres que usa, no sus valores:
  una asignación posterior a la captura es visible desde la función, y viceversa.
verificacion: [C1]
```

```regla
id: R2
fuerza: DEBE
clase: semantica
texto: >
  La variable de un «Para Cada» es nueva en cada iteración; cada función creada
  en una iteración ve el valor de esa iteración.
verificacion: [C2]
```

```regla
id: R3
fuerza: DEBE
clase: semantica
texto: >
  Capturar la variable de control de un bucle contado en una función que escapa
  del bucle produce la advertencia E1.
verificacion: [C3]
```

```regla
id: R4
fuerza: NO DEBE
clase: semantica
texto: >
  Una función que escapa del subprograma no puede capturar un parámetro
  «Por Referencia»; hacerlo es el error E2.
verificacion: [C4]
```

```regla
id: R5
fuerza: NO DEBE
clase: semantica
texto: Las funciones no son comparables con «=» ni «<>»; hacerlo es el error E3.
verificacion: [C5]
```

```regla
id: R6
fuerza: DEBE
clase: observacion
texto: >
  El estado observable muestra cada función como un objeto con identidad y su
  entorno capturado como aristas hacia las celdas capturadas.
verificacion: [C6]
```

```error
- { id: E1, situacion: captura de variable de control de bucle contado en función que escapa, clase: semantica, codigo: loopControlVariableCaptured, severidad: C }
- { id: E2, situacion: función que escapa captura parámetro por referencia, clase: semantica, codigo: escapingClosureCapturesReference, severidad: A }
- { id: E3, situacion: comparación entre funciones, clase: semantica, codigo: functionsNotComparable, severidad: A }
```

```caso
id: C1
perfiles: [es, en]
programa: |
  SubProceso Contador() Como Funcion() Como Entero
    Definir n Como Entero
    n <- 0
    Funcion Siguiente() Como Entero
      n <- n + 1
      Retornar n
    FinFuncion
    Retornar Siguiente
  FinSubProceso

  Proceso P
    Definir f Como Funcion() Como Entero
    f <- Contador()
    Escribir f(), f(), f()
  FinProceso
espera:
  salida: "123\n"
origen: escrito
modo: esperado-fallo
```

```caso
id: C2
perfiles: [es, en]
programa: |
  Proceso P
    Definir fs Como Lista De Funcion() Como Entero
    fs <- NuevaLista()
    Para Cada k En [1, 2, 3] Hacer
      Funcion Valor() Como Entero
        Retornar k
      FinFuncion
      fs.Agregar(Valor)
    FinPara
    Para Cada g En fs Hacer
      Escribir g() Sin Saltar
    FinPara
    Escribir ""
  FinProceso
espera:
  salida: "123\n"
origen: escrito
modo: esperado-fallo
```

```caso
id: C6
perfiles: [es]
programa: "(el de C1)"
espera:
  estado_en: { evento: entrada-a-sentencia, linea: 5, ocurrencia: 2 }
  estado:
    objetos:
      - { tipo: funcion, nombre: Siguiente, captura: [n] }
    celdas:
      - { nombre: n, marco: Contador, valor: 1, viva_tras_retorno: true }
origen: escrito
modo: esperado-fallo
```

## No objetivos

- Funciones genéricas locales.
- Captura por valor explícita (listas de captura).
````

(Casos C3 a C5 omitidos por brevedad; seguirían la misma forma.)

**Lo que el ejemplo demuestra:** las dependencias declaran que no puede haber closures sin ámbitos de
bloque (`requiere`) y que su semántica de memoria se apoya en otra especificación (`usa`); los casos
existen antes que la implementación, en modo «esperado fallo», sin que nada los confunda con un
contrato aprobado; y R6 conecta la característica con la observación pedagógica.

---

## 4. Una clase y una interfaz: `LANG.CLASS.INTERFACE`

````markdown
---
id: LANG.CLASS.INTERFACE
titulo: Interfaces
dominio: lenguaje
estado: propuesta
version: 0.1.0
sujetos: [nucleo, vm, aot, servicio-lenguaje]
depende_de:
  - { id: LANG.CLASS.DECL, version: "^1", tipo: usa }
  - { id: LANG.CLASS.DISPATCH, version: "^1", tipo: usa }
---

```regla
id: R1
fuerza: DEBE
clase: semantica
texto: >
  Una clase que declara «Implementa I» define todos los métodos de I con la misma
  firma (mismo número y tipos de parámetros, mismas marcas de paso, mismo tipo de retorno).
verificacion: [C1, C2]
```

```regla
id: R2
fuerza: DEBE
clase: semantica
texto: Una variable de tipo interfaz puede referenciar instancias de cualquier clase que la implemente.
verificacion: [C1]
```

```regla
id: R3
fuerza: NO DEBE
clase: semantica
texto: Una interfaz no se instancia con «Nuevo».
verificacion: [C3]
```

```regla
id: R4
fuerza: DEBE
clase: semantica
texto: La llamada a un método a través de una interfaz se despacha según la clase real del objeto.
verificacion: [C1]
```

```caso
id: C1
perfiles: [es, en]
programa: |
  Interfaz Figura
    Metodo Area() Como Real
  FinInterfaz

  Clase Cuadrado Implementa Figura
    Privado Definir lado Como Real
    Metodo Constructor(l Como Real)
      Este.lado <- l
    FinMetodo
    Metodo Area() Como Real
      Retornar Este.lado * Este.lado
    FinMetodo
  FinClase

  Proceso P
    Definir f Como Figura
    f <- Nuevo Cuadrado(2.0)
    Escribir f.Area()
  FinProceso
espera:
  salida: "4.0\n"
origen: escrito
modo: esperado-fallo
```

```caso
id: C2
perfiles: [es, en]
programa: |
  Interfaz Figura
    Metodo Area() Como Real
  FinInterfaz
  Clase Punto Implementa Figura
  FinClase
  Proceso P
  FinProceso
espera:
  diagnosticos:
    - { codigo: interfaceMethodNotImplemented, argumentos: { metodo: Area, interfaz: Figura } }
origen: escrito
modo: esperado-fallo
```
````

Los casos de servicio de lenguaje (por ejemplo, que tras `Clase X Implementa` el autocompletado ofrezca
interfaces y no clases) irían en una especificación `TOOL.*` que depende de esta.

---

## 5. Memoria: `MEM.MANAGED.UNOBSERVABLE` y `MEM.VALUE.COPY`

````markdown
---
id: MEM.MANAGED.UNOBSERVABLE
titulo: La recuperación de memoria no es observable
dominio: memoria
estado: propuesta
version: 0.1.0
sujetos: [nucleo, vm, aot]
---

```regla
id: R1
fuerza: NO DEBE
clase: semantica
texto: >
  Ningún resultado observable de un programa (salida, diagnósticos, traza de
  eventos) depende de cuándo ni de si se recupera la memoria de objetos inalcanzables.
verificacion: [Q1]
```

```regla
id: R2
fuerza: DEBE
clase: recurso
texto: >
  Agotar la memoria disponible produce un fallo de recurso con diagnóstico,
  nunca una terminación sin diagnóstico.
verificacion: [C1]
```

```propiedad
id: Q1
generador: corpus de conformidad del lenguaje + programas generados con objetos y ciclos
propiedad: >
  Ejecutar cada programa con la recolección forzada tras cada asignación de
  memoria y con la recolección desactivada produce la misma salida y la misma traza.
oraculo: comparación entre dos ejecuciones del mismo sujeto en modos extremos
```

```caso
id: C1
etiquetas: [limite]
perfiles: [es]
programa: |
  Proceso P
    Dimension a[100000000000] Como Entero
    a[0] <- 1
  FinProceso
espera:
  fallo: { clase: recurso, codigo: resourceExhausted }
origen: escrito
```
````

**Resultado esperado hoy:** C1 incumple: el núcleo deja escapar `OutOfMemoryError` (H-09). Q1 es un
ejemplo de propiedad que **ejercita al recolector sin observarlo**: si alguna vez se añadieran
finalizadores o referencias débiles observables, Q1 fallaría y obligaría a decidir.

````markdown
---
id: MEM.VALUE.COPY
titulo: Los registros se copian al asignar
dominio: memoria
estado: propuesta
version: 0.1.0
depende_de:
  - { id: LANG.RECORD.DECL, version: "^0.1", tipo: usa }
---

```regla
id: R1
fuerza: DEBE
clase: semantica
texto: >
  Asignar un registro, pasarlo por valor o devolverlo produce una copia
  independiente; modificar la copia no modifica el original.
verificacion: [C1]
```

```caso
id: C1
perfiles: [es, en]
programa: |
  Registro Punto
    Definir x, y Como Real
  FinRegistro
  Proceso P
    Definir a, b Como Punto
    a.x <- 1.0
    a.y <- 2.0
    b <- a
    b.x <- 9.0
    Escribir a.x, " ", b.x
  FinProceso
espera:
  salida: "1.0 9.0\n"
origen: escrito
modo: esperado-fallo
```
````

(Nótese que C1 usa `y` como nombre: el caso también depende de la resolución de
[D-13](17-riesgos-preguntas-y-decisiones.md#d-13). El validador lo haría explícito, porque el programa
no analizaría con el léxico vigente.)

---

## 6. Motor: `ENG.TRACE.EVENTS` y `ENG.TRACE.SNAPSHOT`

````markdown
---
id: ENG.TRACE.SNAPSHOT
titulo: Estado observable
dominio: motor
estado: propuesta
version: 0.1.0
sujetos: [nucleo, vm, reproductor]
depende_de:
  - { id: ENG.TRACE.EVENTS, version: "^1", tipo: usa }
---

```regla
id: R1
fuerza: DEBE
clase: observacion
texto: El estado observable incluye todos los arreglos visibles en cada marco, con dimensiones y celdas.
verificacion: [C1]
```

```regla
id: R2
fuerza: DEBE
clase: observacion
texto: >
  Una instantánea es inmutable: el estado que describe no cambia cuando
  el programa sigue ejecutándose, incluidos los campos de los objetos.
verificacion: [C2]
```

```caso
id: C1
perfiles: [es, en]
programa: |
  Proceso P
    Dimension a[3] Como Entero
    Definir k Como Entero
    a[0] <- 7
    k <- 1
  FinProceso
espera:
  estado_en: { evento: salida-de-sentencia, linea: 5 }
  estado:
    celdas:
      - { nombre: a, dimensiones: [3], valores: [7, sin-valor, sin-valor] }
      - { nombre: k, valor: 1 }
origen: escrito
```

```caso
id: C2
perfiles: [es]
programa: |
  Clase Caja
    Definir v Como Entero
  FinClase
  Proceso P
    Definir c Como Caja
    c <- Nuevo Caja()
    c.v <- 1
    c.v <- 2
  FinProceso
espera:
  estado_en: { evento: salida-de-sentencia, linea: 7, conservar: true }
  estado_conservado_tras_fin:
    objetos: [{ tipo: Caja, campos: { v: 1 } }]
origen: escrito
```
````

**Resultado esperado hoy:** C1 incumple (los arreglos no aparecen, H-10) y C2 incumple (la instantánea
conservada muestra `v: 2` porque referencia el objeto vivo).

---

## 7. Comportamientos de la app

### 7.1 `APP.EDITOR.COMPLETION`

````markdown
---
id: APP.EDITOR.COMPLETION
titulo: Autocompletado en el editor
dominio: app
estado: propuesta
version: 0.1.0
sujetos: [servicio-lenguaje, app]
depende_de:
  - { id: LANG.GRAMMAR, version: "^1", tipo: usa }
  - { id: TOOL.SERVICE.BLOCK-STACK, version: "^0.1", tipo: requiere }
---

```regla
id: R1
fuerza: DEBE
clase: herramienta
texto: Toda plantilla ofrecida, insertada en su posición, produce un programa sin errores sintácticos nuevos.
verificacion: [Q1]
```

```regla
id: R2
fuerza: DEBE
clase: herramienta
texto: Dentro de un bloque sin cerrar, el primer candidato es la palabra de cierre de ese bloque.
verificacion: [C1]
```

```regla
id: R3
fuerza: DEBE
clase: herramienta
texto: Todo texto de una sugerencia, incluidos los marcadores, está en el idioma del perfil del archivo.
verificacion: [C2]
```

```regla
id: R4
fuerza: PUEDE
clase: herramienta
texto: >
  Si se escribe una palabra clave del otro perfil, puede ofrecerse su equivalente
  en el perfil del archivo, indicando el idioma de origen.
verificacion: [C3]
```

```caso
id: C1
perfiles: [es]
texto_con_cursor: |
  Proceso P
    Mientras x < 10 Hacer
      x <- x + 1
    ‸
espera:
  candidatos_primero: FinMientras
origen: escrito
```

```caso
id: C2
perfiles: [en]
texto_con_cursor: |
  algorithm P
    ‸
  endAlgorithm
espera:
  ningun_candidato_contiene: [condicion, mensaje, variable, nombre]
origen: escrito
```

```caso
id: C3
perfiles: [es]
texto_con_cursor: |
  Proceso P
    while‸
  FinProceso
espera:
  contiene: { etiqueta: Mientras, detalle_incluye: while }
origen: escrito
```

```propiedad
id: Q1
generador: cada plantilla ofrecida × cada posición de inicio de sentencia del corpus de conocimiento, en ambos perfiles
propiedad: insertar la plantilla no añade diagnósticos sintácticos
oraculo: parser de referencia
```
````

**Resultado esperado hoy:** Q1 incumple con la plantilla de selección múltiple (H-18); C2 incumple
(marcadores en español en el perfil inglés); C1 y C3 incumplen porque no existe contexto. La
especificación vigente de la app no tiene dónde decir nada de esto: el test actual solo comprueba que
existan etiquetas.

### 7.2 `APP.EXEC.PACE`

````markdown
---
id: APP.EXEC.PACE
titulo: Ritmos de ejecución paso a paso
dominio: app
estado: propuesta
version: 0.1.0
sujetos: [app]
depende_de:
  - { id: ENG.TRACE.EVENTS, version: "^1", tipo: usa }
---

```regla
id: R1
fuerza: DEBE
clase: app
texto: >
  «Siguiente sentencia» avanza hasta el siguiente evento de entrada a sentencia,
  de decisión, de petición de entrada o de terminación.
verificacion: [C1]
```

```regla
id: R2
fuerza: DEBE
clase: app
texto: >
  Los límites de seguridad se expresan en sentencias ejecutadas y en tiempo,
  nunca en unidades internas del motor, y son distintos en modo observado y no observado.
verificacion: [C2]
```

```caso
id: C2
perfiles: [es]
programa: |
  SubProceso Fib(n Como Entero) Como Entero
    Si n < 2 Entonces
      Retornar n
    SiNo
      Retornar Fib(n - 1) + Fib(n - 2)
    FinSi
  FinSubProceso
  Proceso P
    Escribir Fib(20)
  FinProceso
accion: ejecutar-hasta-el-final
espera:
  salida: "6765\n"
  terminacion: normal
origen: escrito
```
````

**Resultado esperado hoy:** C2 incumple: la app se detiene por el tope de 10 000 micro-pasos (H-14).

---

## 8. Rendimiento: `PERF.SUITE.AWFY-CORE`

````markdown
---
id: PERF.SUITE.AWFY-CORE
titulo: Rendimiento de programas en la suite de referencia
dominio: rendimiento
estado: borrador
version: 0.1.0
sujetos: [aot]
---

```regla
id: R1
fuerza: DEBERÍA
clase: rendimiento
texto: >
  En cada plataforma de referencia, la media geométrica del tiempo en estado estable
  de la suite, en la comparación de misma semántica, no supera 1,5 veces la de Go.
verificacion: [B1]
```

```benchmark
id: B1
suite: awfy-core (Bounce, List, Mandelbrot, NBody, Permute, Queens, Sieve, Storage, Towers, Richards)
plataformas: [macos-arm64-m2, linux-x86_64-ref, windows-x86_64-ref]
metodo:
  procesos: 10
  iteraciones_por_proceso: 50
  estado_estable: deteccion de puntos de cambio
  intervalo_confianza: 95 %
referencias: [go-misma-semantica, rust-misma-semantica, go-idiomatico, rust-idiomatico]
umbral: { media_geometrica_maxima: 1.5, referencia: go-misma-semantica, maximo_por_prueba: 3.0 }
publicar: todos los resultados, incluidos los desfavorables
```
````

Una especificación de rendimiento en `borrador` no gobierna nada: documenta la intención hasta que
[D-07](17-riesgos-preguntas-y-decisiones.md#d-07) fije los umbrales.

---

## 9. Un cambio clasificado y su impacto

**Escenario hipotético:** se decide ([D-17](17-riesgos-preguntas-y-decisiones.md#d-17)) que el límite
de profundidad de llamada deja de ser 1 000 por regla del lenguaje y pasa a ser un límite de recurso
declarado por el entorno.

**Clasificación preliminar** que el sistema propondría al comparar `LANG.SUBPROGRAM.RECURSION@1.0.0`
con la nueva versión:

```
Regla R2 «El límite de profundidad es del lenguaje y vale mil»     → retirada
Regla R5 (nueva) «Agotar la pila es un fallo de recurso…»          → ampliación (revisar)
Caso C3 (profundidad 999 no es error) sin cambios                   → —
Caso C4 (profundidad 1000 falla) valor esperado cambiado            → cambio de significado candidato
Clase propuesta: MAYOR (retirada + cambio de significado)
Lenguaje: requiere edición nueva
```

Una persona confirma «MAYOR, edición 2028» y el registro queda en la especificación.

**Informe de impacto** (forma propuesta):

```
Cambio: LANG.SUBPROGRAM.RECURSION 1.0.0 → 2.0.0 (MAYOR, edición 2028)

Especificaciones dependientes fuera de rango (revisión requerida):
  ENG.TRACE.EVENTS@1.2.0           usa ^1 → revisar evento de fallo de recurso
  APP.EXEC.PACE@0.1.0              usa ^1 → revisar límites de la app

Vínculos desactualizados:
  nucleo   LANG.SUBPROGRAM.RECURSION@1.0.0#R2   test/evaluation/interpreter/recursion_test.dart
  app      LANG.SUBPROGRAM.RECURSION@1.0.0      ejecutor

Artefactos a regenerar:
  base de conocimiento: esp-i-subprogramas (es, en)

Documentación que cita el identificador:
  packages/pseudolearn_core/README.md §4.x
```

---

## 10. Archivo de conformidad y matriz

Archivo de conformidad del núcleo tras migrar los ejemplos de §1, §2 y §6:

```yaml
sujeto: nucleo
paquete: packages/pseudolearn_core
vinculos:
  - { regla: LANG.CONTROL.FOR@1.0.0, verificacion: ejecutor, estado: cumple, excepto: [R5] }
  - { regla: LANG.CONTROL.FOR@1.0.0#R5, verificacion: ejecutor, estado: pendiente, resuelve_en: F2 }
  - { regla: LANG.SYNTAX.RECOVERY@1.0.0#R3, verificacion: ejecutor, estado: pendiente, resuelve_en: F2 }
  - { regla: LANG.SYNTAX.RECOVERY@1.0.0#R7, verificacion: ejecutor, estado: pendiente, resuelve_en: F2 }
  - { regla: ENG.TRACE.SNAPSHOT@0.1.0, verificacion: ejecutor, estado: exento, motivo: "propuesta" }
```

Matriz de cobertura resultante (extracto):

| Regla                          | nucleo     | vm    | app       |
|--------------------------------|------------|-------|-----------|
| `LANG.CONTROL.FOR#R1`          | cumple     | —     | —         |
| `LANG.CONTROL.FOR#R5`          | pendiente  | —     | —         |
| `LANG.SYNTAX.RECOVERY#R3`      | pendiente  | —     | —         |
| `LANG.SYNTAX.RECOVERY#R7`      | pendiente  | —     | —         |
| `APP.EDITOR.COMPLETION#R1`     | —          | —     | sin vínculo (propuesta) |

Los tres incumplimientos pendientes de esta tabla son hallazgos que esta investigación encontró a mano
(H-05, H-06, H-37); con el sistema funcionando, los habría encontrado la CI el día en que se escribió
cada regla.
