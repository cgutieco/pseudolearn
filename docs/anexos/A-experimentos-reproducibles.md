# Anexo A · Experimentos reproducibles sobre el sistema actual

> **Estado:** investigación, no normativo. Registra las mediciones y sondas que sustentan el
> [diagnóstico](../02-diagnostico-del-sistema-actual.md). No forma parte de ningún paquete ni de su
> verificación; el código del arnés vivió fuera del repositorio y aquí se transcribe para que
> cualquiera pueda repetirlo.

## A.1 Entorno de medición

| Elemento               | Valor                                                                     |
|------------------------|---------------------------------------------------------------------------|
| Fecha                  | 2026-10-13                                                                |
| Máquina                | Apple M2, 16 GiB de RAM                                                   |
| Sistema operativo      | macOS 27.0.1 (26A434)                                                     |
| Dart SDK               | 3.13.4 (stable, 2026-09-15), `macos_arm64`                                |
| Flutter                | 3.47.5 (revisión 6a19cca564)                                              |
| Node.js (para `dart2js`) | v22.23.3                                                                |
| Commit del repositorio | `b44b2dd` (rama `feature/agregar-ruta-de-especificacion`, árbol limpio)   |

**Límites de validez.** Una sola máquina, sin aislamiento de núcleos, sin control de frecuencia, dos
ejecuciones por configuración (una de calentamiento descartada y una medida). Sirven para estimar
órdenes de magnitud y para comparar configuraciones del mismo motor entre sí, **no** como benchmark
publicable. El protocolo que sí lo sería está en
[16 · Experimentos y benchmarks](../16-experimentos-y-benchmarks.md).

## A.2 Verificación de los paquetes

| Comando (desde el directorio del paquete)                                  | Resultado                         |
|----------------------------------------------------------------------------|-----------------------------------|
| `packages/pseudolearn_core`: `dart test`                                   | **772 tests, todos en verde**     |
| `packages/pseudolearn_core`: `dart analyze --fatal-infos --fatal-warnings` | Sin incidencias                   |
| `packages/pseudolearn_core`: `dart run tool/check_limits.dart`             | Todos los límites en verde        |
| `apps/pseudolearn_app`: `flutter test test/engine test/application/execution*` | **458 tests, todos en verde** |

No se ejecutó la suite completa de la app (336 archivos de test) ni los verificadores de `brand`,
`backend` y `fe-pseudolearn`, porque ningún hallazgo de esta investigación depende de ellos.

## A.3 Arnés de rendimiento del intérprete

El arnés analiza un programa con la API pública del núcleo y avanza el intérprete con `step()` hasta
`StepFinished`, contando micro-pasos. Mide dos configuraciones: sin observador y con un observador que
recibe instantáneas (`EnvironmentSnapshot`), que es como lo usa la app.

```dart
RunStats run(AnalyzedProgram program, {required bool observe}) {
  final observer = observe ? CountingObserver() : null;
  final start = Interpreter.start(program: program, observer: observer);
  final interp = (start as ExecutionReady).interpreter;
  final sw = Stopwatch()..start();
  var steps = 0;
  StepOutcome outcome;
  while (true) {
    outcome = interp.step();
    steps++;
    if (outcome is StepFinished || outcome is StepHalted) break;
    if (outcome is StepAwaitingInput) interp.provideInput('5');
  }
  sw.stop();
  return RunStats(steps, sw.elapsed, outcome);
}
```

Programas medidos (perfil «Español clásico», variante flexible):

```
Proceso Suma
  Definir i, total Como Entero
  total <- 0
  Para i <- 1 Hasta N Hacer
    total <- total + i
  FinPara
  Escribir total
FinProceso
```

```
SubProceso Fib(n Como Entero) Como Entero
  Si n < 2 Entonces
    Retornar n
  SiNo
    Retornar Fib(n - 1) + Fib(n - 2)
  FinSi
FinSubProceso

Proceso Fibo
  Escribir Fib(N)
FinProceso
```

```
Proceso Burbuja
  Dimension a[N] Como Entero
  Definir i, j, t Como Entero
  Para i <- 0 Hasta N - 1 Hacer
    a[i] <- N - i
  FinPara
  Para i <- 0 Hasta N - 2 Hacer
    Para j <- 0 Hasta N - 2 - i Hacer
      Si a[j] > a[j + 1] Entonces
        t <- a[j]
        a[j] <- a[j + 1]
        a[j + 1] <- t
      FinSi
    FinPara
  FinPara
  Escribir a[0], " ", a[N - 1]
FinProceso
```

```
Clase Contador
  Privado Definir valor Como Entero
  Metodo Constructor()
    Este.valor <- 0
  FinMetodo
  Metodo Sumar(d Como Entero)
    Este.valor <- Este.valor + d
  FinMetodo
  Metodo Valor() Como Entero
    Retornar Este.valor
  FinMetodo
FinClase

Proceso Objetos
  Definir c Como Contador
  Definir i Como Entero
  c <- Nuevo Contador()
  Para i <- 1 Hasta N Hacer
    c.Sumar(i)
  FinPara
  Escribir c.Valor()
FinProceso
```

### A.3.1 Resultados

Tiempos de la ejecución medida (segunda ejecución). «ns/paso» divide el tiempo total por los
micro-pasos del intérprete. «Pasos/iteración» divide los micro-pasos por las iteraciones del bucle
interior (o por las comparaciones, en burbuja).

**Dart VM (JIT, `dart run`)**

| Programa         | Micro-pasos | Sin observador     | Con observador     | Pasos/iteración |
|------------------|------------:|--------------------|--------------------|----------------:|
| Suma, N=10⁶      |  10 000 020 | 733 ms (73 ns/p)   | 971 ms (97 ns/p)   |            10,0 |
| Fib(22)          |     945 667 | 71 ms (76 ns/p)    | 264 ms (280 ns/p)  |               — |
| Burbuja, N=300   |   2 026 078 | 153 ms (76 ns/p)   | 190 ms (94 ns/p)   |            45,2 |
| Objetos, N=10⁵   |   2 000 039 | 161 ms (81 ns/p)   | 220 ms (110 ns/p)  |            20,0 |

**Ejecutable nativo AOT (`dart compile exe`)**

| Programa         | Micro-pasos | Sin observador     | Con observador     |
|------------------|------------:|--------------------|--------------------|
| Suma, N=10⁶      |  10 000 020 | 744 ms (74 ns/p)   | 986 ms (99 ns/p)   |
| Fib(22)          |     945 667 | 70 ms (74 ns/p)    | 324 ms (343 ns/p)  |
| Burbuja, N=300   |   2 026 078 | 161 ms (80 ns/p)   | 200 ms (99 ns/p)   |
| Objetos, N=10⁵   |   2 000 039 | 172 ms (86 ns/p)   | 244 ms (122 ns/p)  |

**JavaScript (`dart compile js -O2`, ejecutado en Node.js 22)**

| Programa         | Sin observador      | Con observador      |
|------------------|---------------------|---------------------|
| Suma, N=10⁶      | 3739 ms (374 ns/p)  | 4167 ms (417 ns/p)  |
| Fib(22)          | 337 ms (356 ns/p)   | 590 ms (624 ns/p)   |
| Burbuja, N=300   | 749 ms (370 ns/p)   | 819 ms (404 ns/p)   |
| Objetos, N=10⁵   | 810 ms (405 ns/p)   | 923 ms (461 ns/p)   |

Las salidas de los cuatro programas fueron idénticas en JIT, AOT y JavaScript (500000500000, 17711,
«1 300», 5000050000).

**Línea base: el mismo cálculo escrito en Dart, compilado AOT**, con la suma comprobada contra
desbordamiento para igualar la semántica de `entero`:

| Cálculo                     | Dart AOT |
|-----------------------------|---------:|
| Suma comprobada, N=10⁶      | ≈1,5 ms  |
| Fib(22) recursivo           | ≈0,095 ms|
| Burbuja, N=300              | ≈0,085 ms|

**Cocientes resultantes (intérprete AOT sin observador ÷ Dart AOT):** suma ≈ 500×, Fib ≈ 740×,
burbuja ≈ 1900×. Son cocientes de micro-benchmarks y no predicen el de programas reales; indican el
orden de magnitud de la distancia entre el motor actual y código nativo.

**Incidente instructivo del propio arnés.** La primera versión usaba `1 << 40` como tope de pasos.
Compilada a JavaScript, esa expresión vale 0 (los desplazamientos de enteros en `dart2js` operan sobre
32 bits) y el arnés se detenía tras un paso. Es exactamente la clase de divergencia entre objetivos
que motivó `PseudoInteger` en el núcleo, y muestra por qué la paridad entre objetivos debe
comprobarse ejecutando, no solo compilando.

## A.4 Sondas de comportamiento

Cada sonda ejecuta el pipeline público del núcleo sobre un texto mínimo.

| Sonda | Entrada                                                                      | Resultado observado                                                                                       |
|-------|------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| A     | `Definir x, y Como Entero` (español, flexible)                              | `reservedLexemeUsedAsName` sobre `y`, y una cascada de cuatro diagnósticos más en las líneas que usan `y` |
| A2    | `define step, total as integer` (inglés, flexible)                          | `reservedLexemeUsedAsName` sobre `step`                                                                   |
| B     | `Dimension a[3] Como Entero` · `Definir k Como Entero` · asignaciones        | La última instantánea contiene `[k]`: **el arreglo no aparece**                                           |
| C1    | `Proceso P` · `Si x > 1 Entonces` · `Escribir x` (sin cierres)              | Árbol devuelto; diagnósticos `unclosedIfStatement`, `unclosedAlgorithm`                                   |
| C2    | `Proceso P` · `Escribir 1 +` · `FinProceso`                                 | Árbol devuelto; **dos** `expectedExpression` idénticos, mismo tramo 2:15–3:1                              |
| C3    | Texto vacío                                                                  | `program == null`, diagnóstico `expectedAlgorithmStart`                                                   |
| D     | Programa con `Leer n`, ejecutado con `ProgramRunner().runToCompletion` sin proveedor de entrada | **`StateError` escapa** de la API pública                                  |
| E     | Programas de 104 a 20 004 líneas de asignaciones                             | Ver tabla A.4.1                                                                                           |
| F     | `Dimension a[100000000000] Como Entero`                                     | **`OutOfMemoryError` escapa** («Exhausted heap space, trying to allocate 800000000032 bytes»)             |
| G     | Plantillas de autocompletado de `Segun` y `switch` dentro de un algoritmo    | `expectedDoKeyword` en ambos perfiles: **la plantilla genera código inválido**                            |
| H     | `año` escrito en NFC y en NFD (`n` + U+0303) en el mismo programa            | La forma NFD produce `unrecognizedCharacter` y tres diagnósticos sintácticos en cascada                   |
| H2    | `Definir año Como Entero;` con perfil estricto                              | `unrecognizedCharacter`: el perfil estricto no admite `ñ` en identificadores (decisión documentada)       |
| I     | Dos objetos que se referencian mutuamente (`a.Enlazar(c)`, `c.Enlazar(a)`)   | Programa válido; se ejecuta y recorre el ciclo: **los ciclos de referencias son expresables hoy**         |
| J     | Bucle contado: cero iteraciones, valor final, límites congelados, paso cero, paso negativo, estricto sin paso | Coinciden con §8.5 de la especificación (`fin 10`; `123 / 4`; `123`; `zeroStepInCountedLoop`; `10 6 2 /-2`; `missingStepClause`) |
| K     | `Para i <- 1 Hasta 3 Hacer` · `i <- i + 1` · `FinPara`                       | **Ningún diagnóstico**, aunque §8.5 exige una advertencia en las dos políticas                           |

### A.4.1 Latencia del análisis completo (sonda E, JIT, segunda pasada)

| Líneas | Bytes   | Léxico   | Sintaxis | Nombres | Tipos   | Total     |
|-------:|--------:|---------:|---------:|--------:|--------:|----------:|
|    104 |   4 260 |  3,5 ms* |   0,7 ms | 0,2 ms  | 0,5 ms  |  5,0 ms*  |
|  1 004 |  42 960 |   8,4 ms |   1,7 ms | 1,0 ms  | 1,6 ms  |  12,7 ms  |
|  5 004 | 218 960 |  36,2 ms |   3,4 ms | 3,3 ms  | 6,5 ms  |  49,5 ms  |
| 20 004 | 888 960 | 169,4 ms |  23,4 ms | 7,4 ms  | 16,5 ms | 216,7 ms  |

\* Incluye calentamiento residual del JIT. El léxico domina (66–78 % del total) y crece algo más que
linealmente. El análisis no es incremental: cada pulsación del editor relanza las cuatro etapas.

## A.5 Cómo repetirlo

1. Crear un paquete Dart fuera del repositorio con `pseudolearn_core` como dependencia por ruta.
2. Copiar el arnés de A.3 y los programas; usar `const ClassicSpanishProfile.flexible()`.
3. Ejecutar con `dart run`, con `dart compile exe` y con `dart compile js -O2` + `node`.
4. Para cada sonda de A.4, analizar con `Lexer`, `Parser`, `NameResolver` y `TypeChecker`, e
   imprimir `diagnostic.code`, `severity` y `span`.

No se versiona el arnés en el repositorio porque no pertenece a ningún paquete aprobado
(`SCOPE-YAGNI`); el [experimento E-01](../16-experimentos-y-benchmarks.md#e-01) propone dónde y cómo
institucionalizarlo.
