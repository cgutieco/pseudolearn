# Informe PG-S.05 (fecha y hora) y PG-S.06 (variables de entorno)

Estado: implementadas con el alcance de abajo. No se hizo commit ni push, y la fase no se declara cerrada: no se
ejecutó `cargo xtask verify` completo ni las pruebas nativas con la feature `native`.

## Decisiones tomadas

| Tema | Decisión |
|---|---|
| Representación (DS-16) | `FechaHora` opaco: instante `i64` en nanosegundos + desplazamiento `i32` en segundos, guardado como `Bytes` con prefijo `PLDT` (como las respuestas HTTP). Sin `i128`. |
| Nombres (CANDIDATOS) | `FechaHora`/`DateTime`, `FechaHoraUtc`, `FechaHoraDe` (8 enteros → `Opcional`), `AnalizarFechaHora`, accesores `Anio, Mes, Dia, Hora, Minuto, Segundo, Nanosegundo, DiaDeLaSemana, DesplazamientoUtc, Instante`, `FormatoIso`, `FormatoIsoPreciso`, `Reloj.AhoraLocal`; `Entorno`/`Environment`, `SolicitarEntorno`, `Obtener`. |
| Formato | `FormatoIso` sin fracción; `FormatoIsoPreciso` siempre nueve dígitos (es la que cumple la ida y vuelta). Día de la semana ISO 1–7. |
| Análisis | Solo `AAAA-MM-DD` y `AAAA-MM-DDThh:mm:ss[.f{1,9}][Z|±hh:mm]`; sin zona = UTC; `T`/`Z` solo en mayúscula; desplazamiento −12:00…+14:00 en minutos enteros; segundo 60 rechazado. |
| Zona del sistema (DS-17/18) | `jiff` 0.2.37 sin características por defecto (`PS-E01`: 2 cajas nativas, `cargo deny` en verde). Desplazamiento truncado a minutos. Web: `getTimezoneOffset`. |
| Familia de `Entorno` (S.06.01) | Se reutiliza la familia `io` en D2; la cinta usa `capability_kind` `environment` (derivado del receptor/solicitud). Sin familia D2 nueva. |
| Sensibilidad (DS-20) | Por nombre (sufijos `token`, `key`, `secret`, `password`, sin distinguir mayúsculas ASCII). La referencia usa el nombre como clave HMAC y mensaje vacío, así que no depende del valor; no hay entropía en el runtime. |
| Navegador | `request_environment` concede; `environment_get` → `permiso_denegado` (error de plataforma). |
| Mayúsculas en nombres | El corpus declara «el anfitrión decide»; el doble de memoria distingue mayúsculas. |
| Motor | `Resultado<Opcional<T>,ErrorES>` exigió reducir en `effect_values.rs` el tipo del efecto al del valor interno; `result_cell_count` distingue opcional falible (3 celdas). |
| Evidencia | `results/` está ignorado por git; se eliminó la evidencia de propiedades obsoleta y debe regenerarse. |

## Pendientes declarados

1. Propiedad de ida y vuelta ISO sobre instantes sembrados: sin generador; la cubre el caso `LIB.TIME#C15`.
2. Sujeto nativo/AOT: `pendiente` `PG-N.08` (R12–R14 de `LIB.IO`, R3–R8 de `LIB.TIME`).
3. El valor de una variable sensible vive en las variables del programa, visibles en el estado de la API; solo la cinta lo redacta.
4. Windows/iPhone físico: solo compilación; sin zona del sistema legible, UTC.
5. Sin caso de «reproducción rechazada con almacén de resolución» ni de capacidad cerrada (`Entorno` no tiene `Cerrar`).
6. `cargo xtask verify` completo, propiedades y conformidad completa de `engine` por regenerar.
