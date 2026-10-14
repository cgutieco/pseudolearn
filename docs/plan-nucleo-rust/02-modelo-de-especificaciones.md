# 02 · Modelo de especificaciones y granularidad

> **Estado:** propuesta. Extiende el diseño de [11](../11-especificaciones-ejecutables-diseno.md)
> (formato `see/1`, estados, versionado, dependencias) con lo que la reescritura necesita: niveles de
> agregación, criterio de corte, frontera con el `README.md`, sujetos nuevos y manifiestos de
> característica. Lo que no se menciona aquí se toma de 11 sin cambios.

---

## 1. Cuatro niveles, un grafo

El modelo se parece al Atomic Design, con una diferencia de fondo: en Atomic Design un organismo
**contiene** moléculas. Aquí una especificación **depende de** otras. La estructura es un **grafo
acíclico de dependencias** agrupado por prefijos de identificador, no un árbol de contención.

```
Nivel        Ejemplo                               Qué es                                   ¿Se versiona?
──────────── ───────────────────────────────────── ──────────────────────────────────────── ─────────────
Dominio      LANG                                  Gran familia de contratos                No
Área         LANG.TYPES                            Agrupación temática («feature» simple)   No (índice generado)
Especificación LANG.TYPES.INTEGER                  Unidad de contrato con versión y estado  Sí
Elemento     LANG.TYPES.INTEGER#R2  ·  #C4  ·  #E1  Regla, caso, error, definición,          No (hereda la versión
                                                   propiedad: el átomo                      de su especificación)
```

- **El átomo normativo es la regla** (`R*`): una sola afirmación con fuerza (DEBE, NO DEBE…).
- **El átomo ejecutable es el caso** (`C*`) o la propiedad (`Q*`): una entrada y un observable esperado.
- **La unidad que se versiona y cambia de estado es la especificación.** Es lo que un sujeto declara
  cumplir (`LANG.TYPES.INTEGER@1.0.0`) y lo que el informe de impacto propaga.
- **El área no es un documento.** Es el segundo segmento del identificador. `see` genera su índice: lista
  de especificaciones, estado agregado y cobertura.
- **Las «features» complejas cruzan áreas** (closures toca `LANG.SCOPE`, `LANG.FUNCTION`, `MEM`,
  `ENG.TRACE`) y se describen con un **manifiesto de característica** (§5), no con una especificación.

### 1.1 Cada tipo de dato es una especificación

Sí. Cada tipo primitivo tiene su propia razón de cambio:

- el rango y el desbordamiento del `entero`;
- la precisión y los no finitos del `real`;
- los puntos de código del `carácter`;
- la normalización y la longitud de la `cadena`;
- la lógica del `lógico`.

Lo que **relaciona** tipos no va dentro de ninguno:

- conversiones y asignabilidad → `LANG.TYPES.RELATIONS`;
- tipo de cada operador → `LANG.OPS.*`.

Si «entero se amplía a real» viviera en `INTEGER`, `REAL` tendría que citarla y `INTEGER` citaría a
`REAL`: un ciclo, que el validador rechaza.

```
                 LANG.TYPES.RELATIONS
                 ▲    ▲    ▲    ▲    ▲
                 │    │    │    │    │   usa
LANG.TYPES. INTEGER REAL BOOLEAN CHARACTER TEXT
                 ▲    ▲                    ▲
                 │    │ usa                │ usa
            LANG.OPS.ARITHMETIC        LANG.OPS.CONCATENATION
                 ▲
                 │ usa
            LANG.CONTROL.FOR
```

---

## 2. Criterio de corte

Una especificación agrupa las reglas que **cambian juntas**, igual que un archivo de código agrupa lo
que tiene una sola razón de cambio. Para no decidirlo por intuición:

| Se parte en dos si…                                                    | Se fusionan si…                                                        |
|------------------------------------------------------------------------|------------------------------------------------------------------------|
| Dos grupos de reglas cambian por motivos distintos                     | Una regla no se puede verificar sin la otra                            |
| Los grupos tienen **sujetos** distintos (`engine` frente a `aot`)       | Siempre cambian de versión a la vez                                     |
| Supera ~15 reglas, o sus casos dejan de leerse de corrido              | Una de las dos quedaría con una regla y un caso                        |
| Una parte va a ser `estable` mucho antes que la otra                   | Separarlas obliga a una dependencia mutua (ciclo)                       |
| Una parte es una **restricción** de un nivel pedagógico o de un perfil  | —                                                                      |

Reglas de forma (las comprueba `see`):

- Toda regla `R*` declara su verificación: casos, propiedades, comprobación estructural o
  `revision_humana` con justificación. **Ninguna regla huérfana.**
- Cada caso tiene una regla principal. Puede tocar otras, pero falla «por» una.
- Todo error `E*` tiene al menos un caso que lo produce y uno límite que no lo produce.
- Toda especificación del dominio `LANG` tiene casos en los dos perfiles (`es`, `en`) o una exclusión
  justificada por caso.

---

## 3. Qué se especifica y qué no

Respuesta corta: **se especifica todo lo que es observable por alguien distinto de quien lo
implementa**. «Alguien» es una persona que escribe programas, otro sujeto o un consumidor de la API.

| Se especifica (corpus)                                                                   | No se especifica (va al `README.md` del crate)                     |
|------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| Qué programas son válidos y qué significan (`LANG`)                                     | Cómo está organizado el parser                                      |
| Qué diagnóstico produce cada situación, con su código y su tramo (`DIAG`)               | Qué estructura de datos usa la tabla de símbolos                    |
| La RI: instrucciones, tipos, buena formación, formato textual (`IR`)                     | Cómo se asignan los registros de la VM                              |
| Qué eventos y qué estado observa quien mira la ejecución (`ENG`)                         | Cuántas instrucciones de bytecode genera un `Para`                  |
| El contrato entre el código generado y el runtime (`RT.ABI`)                            | La disposición interna del montón                                   |
| Que la memoria no es observable y que los registros se copian (`MEM`)                    | El algoritmo del recolector                                         |
| Cada función de la biblioteca estándar (`LIB`)                                          | Cómo se implementa `raíz cuadrada`                                  |
| La API pública del núcleo: operaciones, errores, versión, formato de intercambio (`API`) | El nombre de los módulos internos                                   |
| Órdenes de la CLI, capacidades del servidor de lenguaje, formateador (`TOOL`)            | El framework de línea de órdenes usado                              |
| Umbrales y suites de rendimiento (`PERF`)                                                | Optimizaciones concretas                                            |

**Esta frontera es lo que impide que la implementación Dart se cuele en Rust.** Ejemplos:

- «`entero` tiene 64 bits con signo y desbordar es un error de ejecución con código `integerOverflow`»
  → especificación `LANG.TYPES.INTEGER`.
- «Se representa como `i64` sin caja en los registros de la VM y se suma con `checked_add`» →
  `README.md` de `pseudolearn_vm`.
- «El núcleo Dart usa `BigInt`» → no aparece en ningún sitio del núcleo nuevo.
- «El tope de 10 000 micro-pasos» → no se porta. Se sustituye por `ENG.LIMITS`, en unidades
  observables (sentencias, tiempo, memoria), según D-17.

### 3.1 Contratos entre crates del mismo sujeto

Un contrato entre dos crates Rust del mismo sujeto (por ejemplo, entre `pseudolearn_syntax` y
`pseudolearn_semantic`) **no se especifica**: lo garantizan los tipos de Rust y lo explica el
`README.md`.

Hay dos excepciones, porque ahí el compilador de Rust no puede comprobar el contrato:

1. **La RI** (`IR.*`): la producen el front-end y la consumen la VM y el backend. Además tiene formato
   textual para pruebas.
2. **La ABI del runtime** (`RT.ABI`): la consume código máquina generado por Cranelift, que `rustc` no
   compila.

---

## 4. Sujetos

| Sujeto        | Implementación                                       | Qué puede declarar cumplir                                   | Desde |
|---------------|------------------------------------------------------|--------------------------------------------------------------|-------|
| `reference`   | `packages/pseudolearn_core` (Dart), congelado         | `LANG`, `DIAG`, una parte de `ENG`                           | R1    |
| `engine`      | `pseudolearn_engine` ejecutando en la VM              | `LANG`, `DIAG`, `IR`, `ENG`, `MEM`, `LIB`, `API`              | R4    |
| `aot`         | `pseudolearn_engine` compilando con Cranelift         | `LANG` (salvo lo marcado `exento` de observación), `RT`, `MEM`, `LIB` | R6 |
| `service`     | Servicio de lenguaje (`pseudolearn_service`)          | `TOOL.SERVICE.*`, `TOOL.FORMAT.*`                            | R7    |
| `cli`         | Binario `pseudo`                                      | `TOOL.CLI.*`                                                  | R4    |
| `app`         | `apps/pseudolearn_app` sobre el puente                | `APP.*`                                                       | R8    |
| `see`         | La propia herramienta                                 | `SEE.*`                                                       | R1    |

Una regla `LANG` pasa a `estable` cuando está verde en `engine` y además:

- está verde en `reference`, o
- tiene en `reference` una divergencia registrada como `exento`, con justificación (por ejemplo, un
  hallazgo H-xx que el núcleo Dart nunca va a corregir).

Desde R6, el segundo sujeto para las reglas de ejecución es `aot`.

---

## 5. Manifiestos de característica

Una característica que cruza áreas tiene un **manifiesto**: un archivo pequeño que no contiene reglas,
solo enlaces. Sirve para planificar, para preguntar «¿está terminada esta feature?» y para generar su
página de documentación.

```yaml
caracteristica: closures
titulo: Funciones como valores y closures
estado_agregado: generado
edicion: B
especificaciones:
  - LANG.SCOPE.BLOCK
  - LANG.FUNCTION.VALUE
  - LANG.FUNCTION.CAPTURE
  - MEM.IDENTITY.CAPTURED-CELL
  - ENG.TRACE.SNAPSHOT
  - IR.MODEL.CLOSURE
  - DIAG.SEMANTIC.CAPTURE-ERRORS
criterio_de_terminado:
  - todas las especificaciones en estable
  - casos verdes en engine y aot
  - visualización de entornos capturados en APP.EXEC.SNAPSHOT-VIEW
```

- El manifiesto **no tiene versión propia**: su estado es la agregación del estado de sus
  especificaciones y lo calcula `see`.
- Una especificación puede pertenecer a varios manifiestos.
- Las áreas simples (`LANG.TYPES`) no necesitan manifiesto: su índice generado basta.

Ubicación: `packages/pseudolearn_spec/specifications/features/<caracteristica>.yaml`.

---

## 6. Plantillas por dominio

Todas las especificaciones usan el formato `see/1` ([11](../11-especificaciones-ejecutables-diseno.md)
§3–4). Cada dominio usa un subconjunto distinto de bloques:

| Dominio | Bloques habituales                                 | Forma de un caso                                                                         |
|---------|----------------------------------------------------|------------------------------------------------------------------------------------------|
| `LANG`  | definiciones, reglas, errores, casos, propiedades  | Programa + perfil + rigor → diagnósticos, salida, terminación                            |
| `DIAG`  | definiciones, reglas, ficha por código             | Programa → diagnóstico con código, clase, severidad, tramo y tramos relacionados         |
| `IR`    | definiciones, invariantes, reglas, casos           | Programa → RI en formato textual que valida; RI inválida → error del verificador         |
| `ENG`   | definiciones, reglas, invariantes, casos           | Programa + entradas → secuencia de eventos y estado observable en puntos dados           |
| `RT`    | precondiciones, resultados, errores, casos         | Programa compilado → salida y terminación; símbolo del runtime → comportamiento          |
| `MEM`   | invariantes, propiedades                           | Programa con y sin recolección forzada → misma salida (propiedad)                        |
| `LIB`   | por función: firma bilingüe, precondiciones, resultados, errores, casos | Llamada → valor o diagnóstico                                     |
| `API`   | precondiciones, resultados, errores, casos         | Secuencia de llamadas al adaptador → respuestas                                          |
| `TOOL`  | reglas, casos                                      | Estado de archivos + orden o consulta → salida, código de salida, respuesta LSP           |
| `PERF`  | carga, plataforma, método estadístico, umbral      | Suite → medición con intervalo; veredicto contra umbral                                  |
| `SEE`   | reglas, casos                                      | Corpus de prueba → veredicto de `see`                                                    |

### 6.1 Ejemplo: esqueleto de `LANG.TYPES.INTEGER`

````markdown
---
id: LANG.TYPES.INTEGER
titulo: Tipo entero
titulo_en: Integer type
dominio: lenguaje
estado: borrador
version: 0.1.0
edicion: { introducida_en: "2026" }
duenos: [responsable-lenguaje]
sujetos: [reference, engine, aot]
depende_de:
  - { id: LANG.LEXICAL.NUMBER-LITERAL, version: "^1", tipo: usa }
  - { id: DIAG.MODEL, version: "^1", tipo: usa }
resumen: >
  Valores, rango, literal por defecto y comportamiento ante desbordamiento del tipo entero.
---

# Tipo entero

```definicion
id: D1
termino: rango del entero
texto: El intervalo cerrado [-9223372036854775808, 9223372036854775807].
```

```regla
id: R1
fuerza: DEBE
clase: semantica
texto: Todo valor de tipo entero pertenece al rango del entero (D1), en todos los objetivos.
verificacion: [C1, C2, Q1]
```

```regla
id: R2
fuerza: DEBE
clase: ejecucion
texto: >
  Una operación cuyo resultado matemático cae fuera del rango produce el error E1
  y no produce ningún valor; nunca da la vuelta al otro extremo.
verificacion: [C3, C4, Q2]
```

```error
- { id: E1, situacion: resultado fuera del rango, clase: ejecucion, codigo: integerOverflow, severidad: A }
```

```caso
id: C3
etiquetas: [limite]
perfiles: [es, en]
programa: |
  Proceso P
    Definir mayor Como Entero
    mayor <- 9223372036854775807
    Escribir mayor + 1
  FinProceso
espera:
  fallo: { codigo: integerOverflow }
  salida: ""
origen: escrito
```

```propiedad
id: Q2
generador: { izquierdo: entero, derecho: entero }
propiedad: >
  Si la suma matemática cabe en D1, el programa escribe esa suma;
  si no cabe, termina con integerOverflow.
oraculo: aritmetica de precision arbitraria del ejecutor
```

## No objetivos

- Enteros sin signo o de otros anchos.
- Representación interna: no es observable.
````

---

## 7. Arranque del propio sistema

Las especificaciones `SEE.*`, que describen el formato y la herramienta, se escriben antes de que la
herramienta exista. Para romper la circularidad:

1. `SEE.FORMAT`, `SEE.IDENTITY` y `SEE.LIFECYCLE` se escriben en `borrador` y se revisan a mano.
2. La primera versión de `see` implementa justo esas tres.
3. `see` se valida a sí mismo: su corpus de prueba incluye las especificaciones `SEE.*`, más una carpeta
   `specifications/see/fixtures/invalid/` con un caso negativo por regla.
4. A partir de ahí, toda especificación nueva entra por `see validate`.
