# pseudolearn

## 1. Qué es y qué no es

Monorepo privado del ecosistema PseudoLearn. Aloja el núcleo del lenguaje en Rust, sus especificaciones
ejecutables, la aplicación Flutter, la CLI, el sitio web, el backend y las herramientas de marca y medición.
El corpus es la fuente de verdad del comportamiento observable. Cada README de miembro define su
arquitectura, operación y decisiones; `AGENTS.md` establece las reglas transversales.

`packages/` contiene componentes reutilizables que no se despliegan; `apps/` contiene productos que se
entregan a una persona. La clasificación depende de su responsabilidad y no del lenguaje.

El sujeto histórico `reference` está retirado. Su manifiesto y sus resultados pertenecen al sistema de
especificaciones; el repositorio no instala ni ejecuta una segunda implementación del núcleo en Dart.
Las mediciones históricas conservan sus fuentes, hashes y condiciones; no certifican fuentes actuales.

| Miembro | Responsabilidad | Cadena |
|---|---|---|
| `packages/pseudolearn_engine` | Núcleo Rust, VM, backend nativo y servicio de lenguaje | Cargo y rustup |
| `packages/pseudolearn_spec` | Corpus y herramienta SEE | Cargo y rustup |
| `packages/pseudolearn_rust_checks` | Reglas mecánicas Rust y casos negativos | Cargo y rustup |
| `packages/pseudolearn_benchmarks` | Recolectores, estadísticas y evidencia de rendimiento | Dart; experimento Rust anidado |
| `packages/pseudolearn_brand` | Generación paramétrica de identidad visual | Python y fonttools |
| `apps/pseudolearn_app` | Cliente Flutter con puente Rust generado | Flutter, Dart y Cargo |
| `apps/pseudolearn_cli` | Órdenes de usuario y adaptadores de conformidad | Cargo y rustup |
| `apps/pseudolearn_backend` | Backend Supabase | Deno y CLI de Supabase |
| `apps/fe-pseudolearn` | Sitio web Astro | Node y pnpm |

Los presupuestos AOT incumplidos y las validaciones de plataforma sin evidencia permanecen declarados
en sus miembros. La validación posterior de plataformas se limita inicialmente a macOS e iOS.

## 2. Guía operativa y ciclo de vida

Cada miembro utiliza exclusivamente su cadena. Las versiones exactas y comandos completos viven en su
README y manifiestos. Todos los miembros Rust fijan el mismo toolchain exacto; no hay workspace Cargo raíz.

- Rust: desde cada miembro ejecutable, `cargo xtask verify`; la frontera nativa Flutter documenta sus
  comandos de formato, Clippy, tests y reglas por separado.
- Flutter: desde la app, `flutter pub get`, compilar la biblioteca local con
  `cargo build --release --locked --lib --manifest-path native/Cargo.toml` y ejecutar `flutter test`.
- Métricas: desde el arnés, `dart pub get`, `dart test`, `dart analyze --fatal-infos --fatal-warnings`
  y `dart run tool/check.dart`.
- Marca: desde su paquete, `python3 -m pseudolearn_brand check`, `python3 tool/check_limits.py` y
  `python3 -m unittest discover -s test -t .`.
- Backend: desde su app, `deno task verify`.
- Web: desde su app, `pnpm install --frozen-lockfile` y `pnpm check:all`.

Los secretos de despliegue se configuran en los canales de publicación; no son requisitos de tests
unitarios. Ninguna comprobación local autoriza por sí misma un despliegue productivo.

## 3. Arquitectura y modelo del sistema

El monorepo no impone una arquitectura común a sus miembros. El motor usa crates por capa; Flutter usa
puertos de dominio y adaptadores; la web aplica Feature-Sliced Design; el backend separa dominio,
aplicación e infraestructura. Cada archivo de reglas declara sus imports, límites y excepciones.

La dependencia funcional principal es corpus exportado → núcleo Rust → API pública → CLI, puente Flutter
y Wasm. La app transforma modelos de transporte en modelos propios; dominio y aplicación desconocen
el transporte. Las herramientas de marca producen artefactos para destinos declarados, sin importar
código de sus consumidores.

La raíz contiene configuración y documentación, no lógica de producto ni un gestor global de procesos.
Las reglas y habilidades transversales viven en `AGENTS.md` y `.agents/skills` como autoridad única.

## 4. Decisiones de diseño y fundamentos técnicos

**Miembros definidos por papel.** El problema de agrupar por lenguaje es que una biblioteca Python o
Rust terminaría fuera del mapa de componentes reutilizables. `packages/` expresa reutilización sin
despliegue y `apps/` expresa entrega. Se descarta crear una carpeta raíz por excepción o reescribir
herramientas de geometría para uniformar lenguajes.

**Verificación nativa por miembro.** Las cadenas tienen gestores y verificadores distintos. Se usan
sus comandos documentados sin un orquestador externo. Se descartan un workspace Cargo raíz y un
`pubspec.yaml` raíz porque impondrían acoplamiento entre miembros con ciclos de distribución distintos.

**API única del lenguaje.** Flutter, CLI y Wasm consumen el mismo núcleo Rust y los datos generados del
corpus. Se descartan analizadores o tablas normativas duplicados en consumidores. Probar varias
fronteras del mismo núcleo aporta cobertura de integración, no un oráculo independiente.

**Artefactos generados.** Solo se versionan salidas consumidas por otro build, como enlaces del puente
y artefactos de marca declarados. El generador y su comprobación son los dueños; editar una copia
manualmente destruiría la correspondencia entre fuente y producto.

**Dependencias y locks.** Las aplicaciones conservan sus locks. Las bibliotecas Dart no los versionan.
Cada workspace Rust conserva su grafo y verifica licencias, fuentes y dependencias con cargo-deny.

## 5. Reglas de legibilidad, estilo y estructura de código

La raíz no define límites de código adicionales. `AGENTS.md` y los archivos de reglas de los miembros
exigen código en inglés, documentación en español, ausencia de comentarios en código, nombres semánticos,
responsabilidades únicas y dirección de dependencias comprobada. Las decisiones viven en los README.

## 6. Decisiones de producto que condicionan el código

El comportamiento didáctico pertenece al corpus. Los perfiles de sintaxis y el idioma de interfaz son
ejes independientes. Las superficies de la app se sincronizan mediante identidades del programa,
no mediante números de línea usados como sustituto de identidad.

La documentación técnica contiene contratos operativos y motivos de diseño, sin insignias ni prosa
promocional. La historia del software pertenece a Git y a sus evidencias históricas, no a instrucciones
que describan como vigentes componentes retirados.

## 7. Verificación, testing y aseguramiento de calidad

La verificación habitual es local. `verify-monorepo.yml` se ejecuta únicamente mediante despacho manual;
los pushes no lo disparan. Los workflows productivos conservan sus disparadores y canales propios.
Los resultados de un sistema operativo no certifican otro.

SEE verifica corpus, anclajes, exportaciones, conformidad, propiedades y referencias documentales.
Su puerta local también rechaza dependencias operativas del núcleo retirado en la app y CI, con casos
negativos. La evidencia histórica de `reference` se conserva sin lanzador y aparece como no aplicable
en la matriz vigente. Las afirmaciones de estabilidad requieren sujetos activos y evidencia revisada.

Las suites reflejan sus capas y cubren caminos felices, fallos y límites. Cada verificador mecánico
incluye una violación deliberada que debe rechazar. Un resultado de rendimiento desfavorable no se
convierte en exención ni se sustituye por otro estimador.

## 8. Fuentes consultadas y genealogía conceptual

La separación entre componentes reutilizables y aplicaciones adopta la convención habitual de
monorepos Dart/Flutter y la aplica también a Rust y Python. No adopta un orquestador Dart para miembros
que no comparten su gestor de paquetes. Las arquitecturas y referencias externas específicas se
registran en los README de sus respectivos miembros.
