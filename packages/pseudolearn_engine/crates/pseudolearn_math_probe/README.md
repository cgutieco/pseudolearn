# pseudolearn_math_probe

## 1. Qué es y qué no es

Herramienta interna que evalúa `pseudolearn_library` sobre los argumentos que genera SEE para el
contraste matemático de `LIB.CORE.MATH`. Lee `<función>.arguments` (bits hexadecimales de binario64 por
línea; dos por línea en la potencia) y escribe `<función>.results` con los bits del resultado o
`nonFiniteRealResult`. No decide valores esperados, no importa el oráculo ni la VM y no se distribuye.

## 2. Guía operativa y ciclo de vida

Flujo completo, desde las carpetas de cada miembro y con un directorio de trabajo fuera del repositorio:

```bash
cargo run --release -p see_cli --bin see -- math-arguments --output <directorio>
```

```bash
cargo run --release -p pseudolearn_math_probe --bin math-probe -- <directorio>
```

```bash
cargo run --release -p see_cli --bin see -- math-check --input <directorio>
```

El primero corre en `packages/pseudolearn_spec`, el segundo en `packages/pseudolearn_engine` y el
tercero de nuevo en `packages/pseudolearn_spec`, que escribe el informe en su directorio local ignorado. Los archivos
de argumentos y resultados son datos crudos regenerables por semilla y no se versionan.

## 3. Arquitectura y modelo del sistema

Capa `tooling` del motor. Importa solo `pseudolearn_library`. Una función se identifica por el nombre
del archivo (`exp`, `ln`, `sin`, `cos`, `atan`, `pow`).

## 4. Decisiones de diseño y fundamentos técnicos

- **Problema:** el motor y SEE son miembros Cargo distintos y el oráculo debe ser independiente del
  sujeto (`SPEC-INDEPENDENT-ORACLE`). **Elección:** intercambio por archivos de texto con bits exactos;
  SEE genera y juzga, el motor solo evalúa. **Descartado:** enlazar el oráculo en el motor o la biblioteca
  en SEE, que acoplaría los dos miembros y permitiría correlacionar sus errores.
- Un `PrecisionExhausted` de la biblioteca no se traduce a resultado: hace fallar la herramienta, porque
  es un defecto interno y no un valor observable.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, `doc`, `allow`, `expect`, pánicos ni `unsafe`; errores como `Result`.

## 6. Decisiones de producto que condicionan el código

`LIB.CORE.MATH#R1`, `LANG.OPS.POWER` y `LANG.TYPES.REAL`: resultado binario64 más cercano y
`nonFiniteRealResult` para dominio inválido o resultado no finito.

## 7. Verificación, testing y aseguramiento de calidad

`tests/lib_tests.rs` cubre evaluación unaria y binaria, trampas, líneas mal formadas y un directorio
completo.

## 8. Fuentes consultadas y genealogía conceptual

El esquema de contraste masivo sigue a las campañas de validación de CORE-MATH (comparación bit a bit
contra una referencia de precisión múltiple); aquí la referencia es el oráculo racional propio de SEE.
