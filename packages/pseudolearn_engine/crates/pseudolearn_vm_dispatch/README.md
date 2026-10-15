# pseudolearn_vm_dispatch

## 1. Qué es y qué no es

Generador de la forma de despacho de `pseudolearn_vm`. Lee la exportación de `IR.INSTRUCTIONS` y la tabla
de formas `crates/pseudolearn_vm/data/dispatch_forms.json`, y produce el código Rust que el `build.rs` de la
VM escribe en `OUT_DIR`: la clasificación de cada opcode, el `enum` de operaciones de despacho, las
funciones que eligen una forma para una instrucción y el `match` del paso de ejecución.
No ejecuta programas, no se enlaza en la VM en tiempo de ejecución y no decide semántica: la semántica de
cada operación vive en los evaluadores y manejadores escritos a mano de `pseudolearn_vm`.

## 2. Guía operativa y ciclo de vida

Es una dependencia de compilación (`build-dependencies`) de `pseudolearn_vm`; no tiene binario. Usa la
versión exacta de `rust-toolchain.toml` del miembro. Comprobación: `cargo xtask verify` del motor, que
incluye sus tests y `rust-checks all`. Cambiar la tabla de formas o la exportación recompila la VM.

## 3. Arquitectura y modelo del sistema

Capa `tooling` del motor; no importa crates del motor y solo depende de `serde_json`.

| Módulo | Responsabilidad |
|---|---|
| `lib.rs` | Orquesta la generación y ofrece acceso tipado al JSON |
| `catalog.rs` | Nombres de `IR.INSTRUCTIONS`, familia de despacho de cada opcode y cobertura escalar |
| `forms.rs` | Expansión de cada fila de la tabla en formas registro/inmediato y fusionadas |
| `render.rs` | Texto Rust del `enum`, de la selección y del paso de despacho |

Una fila de operación declara forma, opcode de la RI, aridad, predicado opcional, evaluador y si admite
fusión con `branch`. La aridad se expande con las formas de operando declaradas en `shapes`
(registro o inmediato por operando). Las filas especiales declaran campos y el manejador de la máquina.

Invariante: toda instrucción de las familias `int.`, `real.`, `math.`, `bool.` y `char.` del catálogo
tiene al menos una forma; si falta, la generación falla y la VM no compila.

## 4. Decisiones de diseño y fundamentos técnicos

- **Problema:** el despacho de la VM debe cubrir el catálogo exportado sin copiarlo a mano
  (`GEN-NO-HAND-COPY`) y añadir una operación no debe modificar el bucle. **Elección:** tabla de datos más
  generador; una operación nueva es una fila nueva. **Descartado:** escribir a mano el `match` de cientos
  de brazos, que mezclaría decodificación y semántica y repetiría cada forma de operando.
- **Problema:** el generador superaba el límite de tamaño de un `build.rs`. **Elección:** crate de
  herramienta propio, partido por responsabilidad y sujeto a `rust-checks`. **Descartado:** módulos con
  `#[path]` fuera de `src`, que el verificador no inspecciona.
- **Problema:** el `match` generado es un artefacto de cientos de brazos que el lint de longitud de
  función rechazaría sin aportar legibilidad. **Elección:** el texto generado se emite compacto, una
  función por línea; se lee la tabla y el generador, nunca `OUT_DIR`. **Descartado:** atributos `allow`,
  prohibidos en el repositorio, y repartir el despacho en dos niveles, que añadiría un salto indirecto por
  operación.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, `doc`, `allow`, `expect`, pánicos ni `unsafe`. Errores como `Result` con
mensaje; nunca una salida parcial. Límites en `architecture.yaml` del miembro.

## 6. Decisiones de producto que condicionan el código

Ninguna observable. El generador conserva la identidad de cada opcode de la RI y no inventa
instrucciones: una forma solo existe para un opcode del catálogo exportado.

## 7. Verificación, testing y aseguramiento de calidad

`tests/lib_tests.rs` genera con la exportación y la tabla reales y comprueba formas, fusión y
clasificación; los caminos infelices cubren cobertura escalar incompleta, aridad no soportada, campos
ausentes y archivos inexistentes.

## 8. Fuentes consultadas y genealogía conceptual

Ertl y Gregg (superinstrucciones y especialización de operandos) y las formas registro-constante de Lua
inspiran la expansión por forma de operando. Se toma la especialización estática; se rechaza la
generación de código máquina en tiempo de ejecución.
