# Informe PG-S.07 (código de salida y salida de error) y PG-S.08 (formato de números)

Estado: ambos puntos implementados. La persona aprobó ampliar el contrato de salida (`PS-K-01`) con un campo aditivo.
No se hizo commit ni push y la fase no se declara cerrada: no se ejecutó `cargo xtask verify` completo, ni las
propiedades, ni las pruebas de Flutter, ni las nativas con la feature `native`.

## Decisiones tomadas

| Tema | Decisión |
|---|---|
| Alcance de `PG-S.07` (`PS-V-09`, `PS-K-01`) | Más de seis consumidores de la salida. Tras la aprobación de la persona se amplió el contrato de forma **aditiva**: `output` sigue siendo la salida combinada en orden (los consumidores que no conocen el campo muestran todo) y la respuesta añade `error_ranges`, los tramos `[inicio, fin)` de bytes que pertenecen al flujo de error. |
| `EstablecerCodigoSalida` (DS-21) | Operación D2 de `Consola`; el motor guarda el código (imagen y delta, para retroceder en el tiempo) y la API lo entrega como campo aditivo `exit_code`. Rango 0–255, si no `ErrorES.PeticionInvalida`. El último gana; un final distinto de `completed` da 1. |
| `EscribirError` (DS-22) | La VM repite el texto en `output` y guarda el tramo en `error_ranges` (imagen y delta, así que retroceder lo restaura). La CLI reparte los tramos entre `stdout` y `stderr` en el orden del programa; DAP los informa como `stdout`/`stderr`. La extensión web confirma la operación y muestra la salida combinada. El anfitrión físico solo confirma el conteo de bytes. |
| Conformidad de códigos de proceso | `TOOL.CLI.CONVENTIONS#D1` declara 7 y 9 como códigos establecidos por el programa, porque el validador exige declarar cada código que un caso espera. |
| Nombres (CANDIDATOS confirmados) | `Decimales`/`decimals`, `RellenarIzquierda`/`padLeft`, `RellenarDerecha`/`padRight`, `EscribirError`/`writeError`, `EstablecerCodigoSalida`/`setExitCode`. |
| Tope de `cantidad` (DS-23) | 100. Trampas nuevas: `decimalPlacesOutOfRange`, `invalidPaddingText`, `paddingWidthOutOfRange`. |
| Relleno enorme | Un ancho mayor que 16 777 216 produce `cellLimitExceeded` antes de construir la cadena. |
| Real no finito en `Decimales` | Se escribe con su forma de salida habitual (`NaN`, `inf`). |
| Entero en `Decimales` (`PS-V-03`) | Refutada: había que ensanchar el argumento de operaciones D2 (`Widen`) en `semantic`. |
| Redondeo | Naturales de precisión arbitraria; empate alejado de cero decidido con un solo bit. `format_value` no se reutiliza. |

## Resultado de las verificaciones

- `see validate` (197 especificaciones), `see lock --check`, `see export --check`: en verde.
- `see conform --subject engine --only` `LIB.CORE.CONVERSION`, `LIB.CORE.TEXT`, `LIB.IO`: 0 divergencias.
- `see conform --subject cli --only TOOL.CLI.RUN`: 26 observaciones, 0 divergencias, con el binario real
  (códigos 7, 9, 1 y 0, y `stderr` separado).
- `cargo test` de `library`, `runtime`, `vm`, `semantic`, `abi`, `service`, `lowering`, `timeline`, `host`, `api`
  (pruebas relevantes) y de la CLI: en verde. Clippy estricto en los mismos miembros y `rust-checks all` en el motor y
  la CLI: en verde. `tsc`, comentarios, tamaño y arquitectura de la extensión, y 8 pruebas de Vitest: en verde.

## Pendientes declarados

1. Sin estilo propio para el error en la extensión web ni en la vista de consola de la app, y sin interpretar `error_ranges` en el protocolo de editor ni en la frontera Wasm (reciben la salida combinada completa). No se ejecutaron pruebas de Flutter.
2. La ejecución nativa (`--native`) y el AOT no implementan las dos operaciones: vínculos `pendiente` (`PG-N.08`). La
   reescritura de `RT.PROCESS` sigue en `PG-N.01`.
3. Una reproducción desde cinta devuelve el código y el conteo de `EscribirError`; el texto sale por `error_ranges` de la nueva ejecución.
4. Sin generador propio para la propiedad `AReal(Decimales(x, 17)) ≈ x`; la cubren los casos fijos.
5. Sin exportador a Rust/Python de operaciones D2: `format!("{:.2}")`/`f"{x:.2f}"` quedan «sin equivalente».
6. Los límites de celdas de `LIB.CORE.CONVERSION#C14`–`C15` y `LIB.CORE.TEXT#C41`–`C42` son medidas del contador del
   motor (los literales de un carácter cuentan como `Caracter`), no una fórmula de la regla.
7. La conformidad completa de `engine` muestra 25 reglas «sin evidencia» (`API.*`, `ENG.*`, `IR.LOWERING`, …) que no
   tocan estos puntos: su evidencia de propiedades está obsoleta y debe regenerarse. Se apartó
   `results/properties-cli.json` como `properties-cli.stale-pg-s-07-08.json` para poder ejecutar `conform --subject cli`.

## Cambios ajenos al alcance

- `pseudolearn_service/src/contextual_tokens.rs`: el `HEAD` no compilaba (guard `if` en mitad de un patrón alternativo
  en `owns`); se separó en `owns_type_identity`. Sin ello no se podía construir el adaptador de conformidad.
- Espacio en disco: se borraron `target/debug/incremental` del motor, `~/Library/Developer/Xcode/DerivedData` y los
  símbolos de dispositivo `iOS DeviceSupport` del iPhone18,3 27.0.1 (cachés regenerables, ~15 GiB).
