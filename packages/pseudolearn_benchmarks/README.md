# pseudolearn_benchmarks

## 1. Qué es y qué no es

Arnés E-01 de la API pública del núcleo Dart congelado como `reference`. Mide ejecución y coste de
observación sin modificar semántica. No es una especificación ni un umbral obligatorio de velocidad.
Carga suma, Fibonacci, burbuja, objetos del anexo, Sieve y Permute de Are We Fast Yet.
Se excluyen Bounce/List/Mandelbrot/NBody/Queens/Storage/Towers y CD/DeltaBlue/Havlak/Json/Richards:
la portación y validación de sus estructuras y bibliotecas no están disponibles en esta suite.
La suite usa tamaños reducidos declarados para permitir repeticiones, no reproduce los tiempos del anexo.

## 2. Guía operativa y ciclo de vida

Flutter 3.47.5 aporta Dart 3.13.4; Node se fija en `node-version` para JS y Wasm.
Preparación: `dart pub get`. Verificación: `dart test`, `dart analyze --fatal-infos --fatal-warnings`
y `dart run tool/check.dart`. Ejecución: `dart run tool/collect.dart --output results/local`.
Compila ejecutable nativo, JavaScript optimizado y Wasm en `build/`; ejecuta Node con soporte Wasm GC.
Resultados crudos y resumen en la ruta indicada. Recalcular estadísticas sin repetir mediciones:
`dart run tool/summarize.dart results/local`. CI conserva artefactos por sistema operativo;
`results/` contiene solamente evidencias seleccionadas y no es salida del build del motor.
No requiere secretos ni despliegue. macOS, Linux y Windows son plataformas del recolector.

## 3. Arquitectura y modelo del sistema

| Capa | Responsabilidad | Puede importar | Prohibido |
|---|---|---|---|
| model | Contratos de cargas y resultados | Dart SDK | suite, execution |
| suite | Programas con resultados esperados | model | execution |
| execution | Análisis y ejecución mediante API pública | model, pseudolearn_core | suite, imports internos del núcleo |
| bin | Ejecutar suite y emitir JSON | model, suite, execution | internals del núcleo |
| tool | Compilar, recolectar y verificar | API del paquete, SDK, analyzer, yaml | modificar el núcleo |

Las reglas están en `architecture.yaml`; tests reflejan `lib/src` y `tool`.
Cada proceso analiza las cargas antes de medir; cada repetición crea un intérprete nuevo.
La observación recibe instantáneas y cuenta eventos sin conservarlos. Se valida terminación y salida
en ambas configuraciones antes de aceptar la muestra. Un fallo retorna un resultado, no escapa.
El worker es secuencial, con semilla fija, sin I/O dentro del intervalo medido.

## 4. Decisiones de diseño y fundamentos técnicos

- **Problema:** la captura puede consagrar un error del intérprete. **Elección:** resultados esperados
  calculados por la definición de cada carga y validados antes de guardar tiempos.
  **Descartado:** usar la primera ejecución como resultado normativo.
- **Problema:** JIT y calentamiento sesgan una ejecución. **Elección:** diez procesos por objetivo,
  treinta iteraciones por carga y modo. Conservar todas; detectar candidatos de puntos de cambio con segmentos de al menos cinco muestras,
  diferencia relativa superior al 5 % y diferencia superior a 3,3 errores estándar. No se declara
  estado estable demostrado; se conservan candidatos y datos completos para el protocolo de R3.
  **Descartado:** borrar calentamientos o muestras desfavorables.
- **Problema:** memoria y CPU no tienen API web portátil. **Elección:** muestreo del proceso anfitrión
  con `ps` en Unix y `Get-Process` en Windows. RSS máxima muestreada es cota inferior del pico;
  CPU es la última lectura acumulada, incluyendo arranque. La memoria no se atribuye a cada carga.
  **Descartado:** reportar una estimación como pico exacto o mezclar CPU con tiempo de pared.
- **Problema:** repeticiones del mismo proceso no son independientes. **Elección:** bootstrap de medias
  por proceso, semilla reproducible e intervalo 95 %; cocientes observado/no observado emparejados
  por proceso y media geométrica por familia. **Descartado:** tratar 300 iteraciones como 300 procesos.
- **Problema:** runners compartidos no fijan frecuencia ni carga externa. **Elección:** publicar
  hardware, versiones y limitaciones. **Descartado:** comparar máquinas diferentes como mismo hardware.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés, sin comentarios, imports relativos internos y API pública exportada por un único punto.
Límites en `architecture.yaml`; herramientas y tests exentos de tamaño, no de comentarios.
El verificador usa AST de Dart y sus tokens para evitar falsos comentarios dentro de pseudocódigo.

## 6. Decisiones de producto que condicionan el código

El núcleo se congela como `reference`; E-01 mide defectos existentes sin repararlos en Dart.
`PERF.BASELINE.REFERENCE` y el protocolo normativo pertenecen a R3. E-01 publica evidencia inicial
con sus amenazas a la validez; no afirma rendimiento del futuro motor Rust.

## 7. Verificación, testing y aseguramiento de calidad

Tests de cargas, análisis inválido, programa vacío, entrada requerida, límite de pasos y salida
incorrecta. El recolector rechaza falta de muestras, objetivos fallidos y métricas ausentes.
`tool/check.dart` verifica comentarios, capas y límites; cada regla tiene caso negativo.
El workflow manual autorizado ejecuta tests y mediciones en macOS arm64, Linux x64 y Windows x64,
sin umbral de tiempo. `collect_metrics=false` permite verificar las mismas fuentes sin repetir una
medición ya conservada; la verificación habitual se ejecuta en local.
Pendiente operativo de R0: GitHub Actions bloquea nuevas ejecuciones por facturación/límite de gasto;
falta confirmar CI completa y las mediciones remotas. El protocolo normativo se publica en R3.

## 8. Fuentes consultadas y genealogía conceptual

El anexo aporta las cuatro cargas básicas y la API de micro-pasos; no se adoptan sus tiempos como
línea base estadística. Are We Fast Yet aporta Sieve y Permute: se portan sus algoritmos y sus
resultados de control (669 y 8660). Se descartan las cargas sin portación validada en esta suite.
La metodología conserva repeticiones independientes y resultados desfavorables del protocolo E-01.

### Aviso de licencia de las cargas derivadas de Are We Fast Yet

Copyright (c) 2015-2016 Stefan Marr <git@stefan-marr.de>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

La procedencia se captura antes de compilar y medir; dirty se refiere solo a fuentes y configuración
del arnés, no a sus salidas. El resumen puede recalcularse sobre los mismos datos crudos sin cambiar
las mediciones, conservando su entorno original.
