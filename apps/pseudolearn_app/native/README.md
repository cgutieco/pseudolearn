# pseudolearn_bridge

## 1. Qué es y qué no es

`pseudolearn_bridge` conecta Dart con la API pública de `pseudolearn_engine`. Traduce llamadas del
transporte, conserva sesiones en el hilo invocador y devuelve respuestas JSON propias. No contiene
semántica del lenguaje, estado de interfaz ni una segunda implementación del motor.

## 2. Guía operativa y ciclo de vida

Requisitos: Rust `1.99.0`, Flutter y Dart fijados por `apps/pseudolearn_app`, Cargo, `cargo-deny`
`0.20.2`, `cargo-expand` `1.0.127` y `flutter_rust_bridge_codegen` `2.13.0`.

Instalación de herramientas:

```bash
cargo install cargo-deny --version 0.20.2 --locked
cargo install cargo-expand --version 1.0.127 --locked
cargo install flutter_rust_bridge_codegen --version 2.13.0 --locked
```

Desde `apps/pseudolearn_app`:

```bash
bash tool/bridge.sh generate
bash tool/bridge.sh check
bash tool/bridge.sh clean-checkout
```

`clean-checkout` exige `flutter_rust_bridge_codegen 2.13.0` y `cargo-expand 1.0.127` instalados.

Desde este directorio:

```bash
cargo fmt --all --check
cargo clippy --all-targets
cargo test
cargo deny check
cargo run --manifest-path ../../../packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all .
```

`Cargo.lock` fija el grafo consumido por la app. La compilación Native Assets usa los destinos del
`rust-toolchain.toml`; los comandos de generación y comprobación no necesitan un checkout previo del
repositorio para hallar archivos auxiliares. El toolchain y Cargo se requieren al compilar; el framework
macOS, el archive iOS y el bundle Windows contienen la biblioteca para su carga en tiempo de ejecución.

## 3. Arquitectura y modelo del sistema

El crate tiene una sola capa, `pseudolearn_bridge`. Puede depender de `pseudolearn_api`,
`flutter_rust_bridge` y `serde_json`. `ApiSession` permanece en un registro `thread_local`; Dart
transporta identificadores `u64` y sobres JSON por valor. No se conservan punteros ni vistas de
memoria fuera de una llamada. La API del puente no importa Flutter ni tipos de dominio de la app.

`src/api.rs` valida el sobre y administra sesiones. `src/frb_generated.rs` y
`lib/engine/bridge/` son salidas del generador y no se editan a mano. `tests/api_session.rs`,
`tests/api_execution.rs` y `tests/api_event_codec.rs` verifican la frontera mediante llamadas reales
al crate.

## 4. Decisiones de diseño y fundamentos técnicos

`ApiSession` contiene estado `!Sync`, mientras los puertos de la app son síncronos. La sesión vive en
un registro local al hilo invocador y se identifica con un `u64`; no se expone como objeto opaco ni se
crea un worker. Cada llamada lleva un JSON completo que Rust decodifica a valores propios. Las
respuestas de error conservan familia y detalle; los fallos internos de la API quedan contenidos en
su límite `catch_unwind`.

`flutter_rust_bridge` y `flutter_rust_bridge_hooks` se fijan en `2.13.0`. Native Assets compila y
empaqueta la biblioteca con el SDK de Rust fijado. El módulo `native` compila la API sin activar la
feature `native` de `pseudolearn_api`, por lo que el puente no incorpora Cranelift.

El build de Release macOS conserva los slices arm64 y x86_64 en `pseudolearn_bridge.framework`. iOS
compila para dispositivo y simulador. Windows instala el DLL junto al ejecutable a través de
`windows/CMakeLists.txt`; los paquetes de distribución contienen ese directorio completo. La firma
restringida de macOS se aplica después del build, cuando el workflow ya instaló el perfil de tienda.

El árbol de `flutter_rust_bridge` trae `syn 2.0.119` para sus macros y `syn 3.0.9` por
`delegate-attr`; `deny.toml` mantiene prohibidas las versiones duplicadas y omite solo `syn@3.0.9`,
que es la dependencia transitiva exacta del transporte.

El código generado necesita `unsafe` para decodificar el transporte. Esa excepción se limita a
`src/frb_generated.rs`; el verificador omite únicamente esa salida versionada y revisa el código
escrito a mano. Los avisos Clippy `unwrap_used`, `unreachable` y `as_conversions` quedan al nivel
warning porque el codec generado los usa; los demás lints declarados se deniegan en el manifiesto.
`rust-checks all` omite únicamente el archivo generado y mantiene sus reglas sobre el código propio.
La compilación conserva `unsafe_code` permitido solo para que el archivo generado pueda compilar;
ninguna función escrita a mano usa `unsafe`.

## 5. Reglas de legibilidad, estilo y estructura de código

Todo el código escrito a mano usa nombres completos en inglés y no contiene comentarios, supresiones
de lint, pánicos, `unwrap` ni conversiones con pérdida. El crate no crea capas internas: la regla de
dependencias del único crate se declara en `architecture.yaml`. Las excepciones del generador no se
propagan a `src/api.rs` ni a `tests/`.

## 6. Decisiones de producto que condicionan el código

Rust es el único motor de la composición que consume el puente. Si una sesión, recurso o llamada deja
de ser válida, el transporte devuelve un fallo tipado; no cae de vuelta al intérprete Dart. La
cancelación se dirige a la sesión propietaria y repetirla conserva su carácter idempotente.

## 7. Verificación, testing y aseguramiento de calidad

`cargo test` cubre negociación, cierre, JSON inválido, versiones desconocidas, fallos internos,
avance, consultas y liberación. `cargo clippy`, rustfmt, `cargo-deny` y `rust-checks all` validan el
crate y sus dependencias. Desde la raíz de la app, `bash tool/test_bridge.sh` compila el `cdylib` y
prueba las llamadas Dart por FFI. `bash tool/bridge.sh check` regenera desde la configuración
versionada y falla si los archivos generados cambian; debe terminar sin diferencias desde un checkout
limpio; `bash tool/bridge.sh clean-checkout` lo comprueba en un árbol de trabajo nuevo. Los tests de integración también cubren `program_view`, `query_node` y `query_page` a través del puente.

## 8. Fuentes consultadas y genealogía conceptual

- [flutter_rust_bridge 2.13.0](https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.13.0):
  generación de bindings Rust–Dart y llamadas síncronas.
- `cargo tree -i syn@3.0.9`: procedencia del segundo major de `syn` por `delegate-attr`.
- `cargo-expand` `1.0.127`: expansión de los atributos usados por el generador.
- [Native Assets de flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge/blob/master/website/docs/manual/integrate/03-native-assets.md):
  empaquetado de la biblioteca a través de hooks.
- [Llamadas síncronas de flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/guides/concurrency/sync-dart):
  uso acotado desde puertos síncronos.
