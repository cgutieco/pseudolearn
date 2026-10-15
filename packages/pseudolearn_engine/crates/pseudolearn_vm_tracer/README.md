# pseudolearn_vm_tracer

## 1. Qué es y qué no es

Worker interno para medir la VM sin observador. Recibe una carga del arnés, compila su texto a RI
verificada y bytecode antes del intervalo, y ejecuta directamente `pseudolearn_vm`. No llama a
`API.EXECUTE`, no contiene un protocolo público y no reemplaza el arnés de referencia.

## 2. Guía operativa y ciclo de vida

El arnés de `pseudolearn_benchmarks` compila este binario en modo release y lo invoca como proceso
independiente para cada carga. Cada worker valida una ejecución previa y recoge treinta iteraciones
con estado nuevo. La versión exacta de Rust se fija en `rust-toolchain.toml`. Verificación: `cargo xtask
verify` del motor y `rust-checks layers`.

## 3. Arquitectura y modelo del sistema

Capa `tooling` del motor. Importa API solo para bajar el texto fuente a RI, bytecode para compilar y VM
para ejecutar. No usa el trabajador de medición de API ni importa la implementación Dart `reference`.
El arnés conserva en un solo archivo las cargas que ejecutan ambos motores.

El worker compila antes de leer el reloj, valida la terminación de cada resultado después del intervalo
y emite muestras estructuradas a stdout. No realiza E/S dentro del intervalo medido.
Los perfiles dinámicos se guardan por carga. `r5-vm-superinstructions.json` selecciona comparación-
salto a partir de Mandelbrot y Fibonacci; el bucle entero queda reservado para validar esa selección.

## 4. Decisiones de diseño y fundamentos técnicos

El worker mide una carga por proceso. Así, diez procesos independientes producen medias emparejables
con los diez procesos de `reference`, mientras cada iteración construye una máquina nueva. Una guarda
del propio programa detecta resultados incorrectos al fallar la terminación. Se descarta ejecutar la
API pública, porque mediría análisis, adaptación o protocolo junto con la VM.

La compilación de la carga y una ejecución de validación ocurren antes de iniciar las muestras. El
worker solo conserva tiempos positivos y resultados completados; los resultados fallidos hacen fallar
el proceso recolector.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés, sin comentarios, `doc`, `allow`, `expect`, pánicos, `unsafe` ni conversiones con pérdida.
Los fallos operativos se devuelven como errores y se convierten en un código de salida en el borde de
la herramienta.

## 6. Decisiones de producto que condicionan el código

La comparación temprana de R5 usa cargas numéricas y recursivas sin entrada externa ni efectos de
anfitrión. La referencia y el worker reciben el mismo texto, y una guarda deriva la validez del
resultado esperado. La VM sigue sin exponerse como API de usuario.

## 7. Verificación, testing y aseguramiento de calidad

Tests de selección de carga, bytecode inválido, resultado incorrecto y ejecución completada. El
recolector verifica diez procesos, treinta iteraciones, estado nuevo, resultados válidos y ausencia de
muestras faltantes. El resumen conserva intervalos por proceso y candidatos de cambio; no descarta
muestras.

## 8. Fuentes consultadas y genealogía conceptual

El protocolo de medición del arnés fija procesos independientes, iteraciones, validación, procedencia y
retención de resultados. El worker usa el protocolo sin importar su lógica estadística.
