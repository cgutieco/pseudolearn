# pseudolearn_app

Fuente de verdad técnica de este paquete. Aquí vive el *por qué* de cada decisión, para que el código no necesite
comentarios que lo expliquen. Un cambio de arquitectura o de decisión de diseño se documenta aquí en el mismo cambio que
lo introduce.

Las reglas transversales del monorepo están en el `AGENTS.md` de la raíz. Las reglas que los verificadores ejecutan
están en `architecture.yaml`, junto a este archivo. La arquitectura del motor del lenguaje está en
`packages/pseudolearn_engine/README.md` y no se repite aquí: este documento describe **dónde y cómo la app se acopla a ese
motor y cómo se construye su experiencia interactiva**.

**Motor:** La composición normal inicializa el puente generado y ensambla `RustEngineServices`.
Análisis, ejecución, editor, ejercicios, diagramas y exportadores consumen la API pública Rust.
Dominio y aplicación conservan sus puertos sin importar el transporte. Las validaciones de
plataforma y las mediciones físicas están pendientes; su alcance inicial es macOS e iOS.

---

## 1. Qué es y qué no es

### 1.1 Propósito y problema que resuelve

`pseudolearn_app` es la aplicación cliente interactiva en Flutter del monorepo PseudoLearn. Proporciona un entorno
integrado de aprendizaje que incluye edición asistida de pseudocódigo, ejecución didáctica paso a paso, visualización
multidiagrama sincrónica (ordinograma, estructograma de Nassi-Shneiderman y diagrama de clases UML), tabla interactiva
de prueba de escritorio con inspección de aliasing de objetos, traducción de código a lenguajes industriales (Python y
Rust), base de conocimiento pedagógica versionada con comprobación observable de ejercicios y almacenamiento local
estructurado.

Consume `pseudolearn_engine` mediante el puente generado de `native/`. **No aporta ninguna lógica
de lenguaje.** En esta aplicación no reside ningún lexer, parser, chequeador de tipos, evaluador, tabla de precedencias,
lista de palabras reservadas ni expresiones regulares que reconozcan sintaxis. Todo el análisis y la ejecución proceden
del núcleo; la aplicación traduce, orquesta y renderiza los resultados.

### 1.2 Responsabilidades primarias

1. **Interfaz y experiencia de usuario:** Construcción de widgets y lienzos interactivos con fidelidad geométrica
   constante entre plataformas.
2. **Orquestación de estado de presentación:** Cubits puros en Dart con estados inmutables y derivación previa de
   colecciones.
3. **Traducción y proyección anticorrupción (`engine/`):** Adaptación unidireccional de los tipos y eventos del núcleo (
   `Span`, `Diagnostic`, `NodeId`, `ExecutionEvent`) a tipos propios del dominio de la aplicación (`SourceRange`,
   `AppDiagnostic`, `ProgramNodeId`, `ExecutionStep`, `DiagramScene`).
4. **Almacenamiento local offline-first (`data/`):** Persistencia en archivos de texto plano `.pseudo` como fuente de
   verdad y base de datos SQLite local como índice y caché de metadatos reconstruible.
5. **Carga y verificación de la base de conocimiento:** Procesamiento de recursos Markdown estructurados con marcadores
   dinámicos del motor y ejecución local de comprobaciones conductuales y estructurales de ejercicios.
6. **Composición estática (`composition/`):** Ensamblado determinista de adaptadores e inyección sin ramas condicionales
   en tiempo de ejecución.

### 1.3 Fuera de alcance a propósito

#### De producto


- **Edición gráfica bidireccional de diagramas:** Los diagramas se generan exclusivamente como proyección de solo
  lectura a partir del código fuente. No se soporta manipulación de nodos por arrastre para mutar el AST ni diagramado
  inverso a código.
- **Calificación sumativa y porcentajes:** La resolución de ejercicios evalúa cumplimiento funcional y estructural sin
  emitir notas numéricas, porcentajes de logro ni almacenamiento de intentos.
- **Edición colaborativa en tiempo real e inteligencia artificial integrada:** Sin soporte para cursores compartidos,
  sincronización remota continua de buffers ni sugerencias de código generadas por LLMs.
- **Compilación y ejecución nativa del código traducido:** La pestaña de código equivalente genera y resalta
  proyecciones en Python y Rust; no invoca compiladores, intérpretes externos ni entornos de ejecución de terceros.
- **Personalización arbitraria de temas:** No se admiten esquemas de color definidos por el usuario, temas de alto
  contraste no calibrados ni fuentes tipográficas arbitrarias del sistema. Existen exclusivamente los temas claro y
  oscuro basados en la escala semántica de tokens.

#### De implementación técnica

- **Aislamiento en hilos secundarios (`Isolate`) y concurrencia real:** El motor de lenguaje es síncrono y determinista;
  la interfaz ejecuta en micro-lotes cooperativos sobre el hilo principal sin bloquear el bucle de eventos.
- **Widgets adaptativos al sistema operativo:** Terminantemente prohibido el uso de constructores adaptativos (
  `Switch.adaptive`, `Slider.adaptive`, `CircularProgressIndicator.adaptive`, etc.) para garantizar paridad visual
  absoluta.
- **Expresiones regulares para reconocimiento léxico:** Prohibido el uso de `RegExp` en `engine`, `application` y
  `presentation` para tareas de coloreado sintáctico o análisis.
- **Localizadores de servicios globales o inyección por reflexión:** Prohibido `get_it`, `Provider` directo,
  `flutter_hooks` o `riverpod`.
- **Caché inter-sesión de análisis sintáctico:** La identidad de nodos (`NodeId`) solo es estable dentro de un ciclo de
  análisis en memoria. Al reiniciar la app se reanaliza el documento.
- **Ejecución reversible (hacia atrás):** El intérprete avanza en una sola dirección; no se implementa rebobinado de
  pasos ni mutaciones inversas.

### 1.4 Casos de uso principales

1. **Edición asistida y validación en tiempo real:** Redacción de programas con retroalimentación inmediata de
   diagnósticos, rangos relacionados y completado de esqueletos derivado del perfil léxico activo.
2. **Depuración y ejecución guiada:** Avance paso a paso en cuatro ritmos con sincronización del foco en código,
   ordinograma, estructograma, diagrama de clases y tabla de prueba de escritorio.
3. **Inspección de estructuras de datos y memoria:** Visualización gráfica de variables primitivas, matrices y aliasing
   de referencias a objetos (`NombreClase#id`, receptor `Este`).
4. **Estudio autónomo en la ruta de aprendizaje:** Lectura de la ruta publicada —partes, lecciones y ejercicios de
   nueve tipos— con enlaces a la especificación ilustrada y comprobación de cada respuesta por el motor.
5. **Comprobación pedagógica de soluciones:** Validación de programas contra casos de prueba visibles y ocultos mediante
   normalización numérica y aserciones sobre el AST sin juicio punitivo.
6. **Biblioteca personal:** Gestión de documentos locales con política canónica de nombres, duplicación y exportación de
   código equivalente.

### 1.5 Pendientes técnicos declarados

| Pendiente                                                      | De quién depende                                                                                                                             | Estado actual                                                                                          |
|:---------------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------|
| Tramos de comentario para el resaltado del editor              | La API Rust de análisis expone tokens léxicos con tramos y el adaptador los proyecta a categorías del editor                              | Resuelto                                                                                              |
| Adaptador remoto de Supabase                                   | Definición de credenciales de red y esquema de sincronización remota                                                                         | Resuelto (sincronización bidireccional y outbox en SQLite, ver decisiones de diseño de sincronización) |
| Vocabulario localizado de receptor de objeto en tabla de traza | RustWatchRows proyecta receptor con thisObject del vocabulario público del perfil | Resuelto; `rust_receiver_localization_test` comprueba `this` y `Este` por el puente real, con programas de clase en cada perfil |
| Purga local sin lápidas en «Cerrar sesión y borrar datos de este dispositivo» | `AccountCubit.signOut(deleteLocalData: true)` borra por `SyncingDocumentRepository`, que encola una lápida por documento; reutilizar `LocalAccountDataPurger` | Abierto |
| Inicio de sesión en la nube desde el `.zip` portable de Windows | Registro de `pseudolearn://` en `HKCU` desde la propia app, o aviso en la página de descargas de que el portable solo sirve sin cuenta | Abierto |
| Distribución en Microsoft Store y firma de binarios | Configuración de empaquetado MSIX (`CESARGUTIERREZ.PseudoLearn`, Store ID `9MXZB1XDWP9J`) y workflow `.github/workflows/push-production-windows-store.yml`; Microsoft Store firma el paquete oficial en certificación | Resuelto (pendiente revisión en Partner Center) |
| Firma Authenticode en instalador directo Inno Setup | Decidir proveedor (Artifact Signing de Azure, certificado OV) si se mantiene la distribución directa fuera de la Store | Abierto |
| Petición de reseña en Microsoft Store                           | Publicación de Windows como MSIX en Microsoft Store y un adaptador de `StoreReviewPrompt` que abra la reseña de la Store; `in_app_review` solo ofrece el diálogo nativo en iOS y macOS (ver §4.46) | Abierto |
| Andamiaje de la plataforma web                                 | Creación de `web/` y de un adaptador de `TextEntryModality` para navegador; hasta entonces la barra de teclas no se verifica ahí (ver §4.33) | Abierto                                                                                                |
| Campaña E-NR2 | Medición con muestras independientes en dispositivo, escritorio y navegador, con procedencia y resumen recalculable | Pendiente; falta el ejecutor de medición y la prueba física, que la persona repetirá después |
| Tamaños de artefactos R8 | Biblioteca ios-arm64 Release y módulo Wasm con Brotli Q11/lgwin22 | Medición registrada tras PG-5: 4,294,592 bytes (4.10 MiB) y 772,804 bytes (754.7 KiB), dentro de sus presupuestos de 8 MiB y 900 KiB. El puente declara `[profile.release]` con `opt-level = "z"`, `lto = "fat"` y `codegen-units = 1`: con el perfil por omisión medía 6,929,984 bytes y con `opt-level = "s"` 5,589,776 bytes, ambos sobre el tope |
| Adaptador SEE del sujeto `app` | Lanzador, escenarios APP y propiedades API sobre el transporte FRB generado | Implementado; 252 observaciones y tres propiedades API por el puente real pasan sin divergencias |
| Resaltado y unidades de foco en la ruta Rust                    | `RustProgramAnalyzer` proyecta los tokens de `analyze`; `RustFocusTracker` deriva `unitId` de la vista pública del programa                | Resuelto                                                                                              |
| Pruebas de widgets con el puente real                           | Los widgets se prueban con fakes; solo `ExecutionCubit` se ejercita contra la biblioteca nativa en `tool/native_bridge_adapters_test.dart` | Abierto |
| Ficha de ayuda de `Importar` y `Exportar` | Catálogo `TOOL.SERVICE.CATALOG` y resolución contextual del servicio; el pegado aislado conserva su diagnóstico, mientras la consulta sobre la directiva y su alias devuelve la ficha propia | Resuelto en PG-A.08; no enlaza paquetes ni habilita E/S |
| Ampliar el código equivalente | El núcleo traduce el lenguaje completo salvo los pendientes declarados en el README de `pseudolearn_transpiler` (capacidades del anfitrión) | Abierto en el núcleo |
| Valor de un parámetro `Canal` en la vista Variables | La página de valores de `debug_state` aplana el canal como registro con la hoja interna `identity` y la muestra como `stream.identity = Nulo`; la API debería publicar el canal como un valor propio (número de canal). La app no oculta la hoja por nombre, porque ocultaría también un campo de usuario llamado igual | Abierto; reportado desde el rediseño de la pestaña `Tareas` |
| Capturas de producto y material de tiendas con la ruta de aprendizaje | Regenerar §2.8 y §2.9 sobre la ruta publicada; las imágenes versionadas muestran todavía la base de conocimiento anterior | Abierto |
| Ancla dentro de una sección al seguir un enlace de especificación desde la ruta | `ReferenceSectionPage` abre la sección por identidad y no desplaza a un ancla interior; el enlace conserva el ancla en el paquete | Abierto |
| Límite de ejecución de los ejercicios | La app corta a 10 000 pasos (`ProgramRunner.defaultStepLimit`) y el compilador de la ruta a 100 000 sentencias; `route_exercise_gate_test` garantiza que cada solución de referencia cabe en el límite de la app | Vigilado por test |
| Compras reales del agente | Adaptadores `PurchaseStore` de StoreKit (iOS y macOS de la App Store, obligatorio dentro de iOS), Microsoft Store y Stripe para la descarga directa, y sus verificadores en el backend | Abierto; solo existe la compra simulada (§4.63) |
| Clave del proveedor del agente | El propietario pone `OPENAI_API_KEY` en el servidor y compila con `AGENT_BACKEND=proxy` y `AGENT_PROXY_URL` | Abierto; sin clave el agente responde «no disponible» sin cobrar |
| Markdown enriquecido en el chat del agente | Lector propio sobre el paquete `markdown` y vistas propias (§4.66) | Resuelto |
| Enlaces externos en las respuestas del agente | Un caso de uso de aplicación sobre `ExternalUrlLauncher` que la presentación pueda invocar; hoy el enlace se muestra subrayado y se puede seleccionar y copiar, pero no se abre | Abierto |
| Diagramas Mermaid distintos de `flowchart` en el chat | Un modelo y una vista por tipo (secuencia, estados, clases); hoy se muestran como código con un aviso (§4.66) | Abierto |
| Medición del agente | Ejecutar el benchmark de `packages/pseudolearn_benchmarks` contra el gateway real con la clave del propietario | Abierto; requiere autorización de la persona |
| Cancelación de tareas hermanas en ejecución paso a paso | El motor reanuda la hermana cancelada solo para completar su cancelación, y en ese evento ya no es consultable; `RustExecutionEventConsumer` lo acepta sin detener el paso (ver §4.10) | Resuelto en la app; el motor cumple el corpus. `rust_task_termination_test` lo ejercita paso a paso con el puente real |

---

## 2. Guía operativa y ciclo de vida

### 2.1 Requisitos previos y plataformas objetivo

- **SDKs:** Flutter SDK `3.47.5` exacto (fijado en `environment.flutter` de `pubspec.yaml`, ver §4.47), Dart SDK `^3.9.0` y Rust `1.99.0` mediante `native/rust-toolchain.toml` para compilar la biblioteca. Rust y Cargo solo se necesitan durante builds; el paquete instalado contiene el código nativo.
- **Plataformas objetivo primarias:** macOS 13+ (Apple Silicon y x86_64), iOS 16+ (iPhone y iPad), Windows 10/11 (x64).
- **Plataformas secundarias:** Linux (GTK), Web (WASM). Son objetivo declarado, **no andamiaje
  existente**: el proyecto contiene las carpetas `ios/`, `macos/` y `windows/`. Toda afirmación sobre el comportamiento en
  navegador —el redimensionado del *viewport* al subir el teclado, en particular— es hipótesis sin verificar hasta que
  la carpeta `web/` exista.
- **Variables de entorno:** La autenticación remota (Apple, Google, magic link) y la sincronización
  contra Supabase requieren `SUPABASE_URL`, `SUPABASE_ANON_KEY` y `GOOGLE_IOS_CLIENT_ID` como
  `--dart-define`. Sin ellas, el cliente de Supabase se construye contra un host placeholder que no
  resuelve en DNS, y todo intento de inicio de sesión falla con `NoConnection` sin importar el
  proveedor. El repositorio no versiona estos valores; se cargan desde `dart_define.local.json`
  (ignorado por git) con `--dart-define-from-file`.
- **Configuración del proyecto Supabase:** El enlace mágico solo vuelve a la aplicación si
  `pseudolearn://auth-callback` está declarado en la lista de *Redirect URLs* del proyecto (*Authentication → URL
  Configuration*). Supabase rechaza cualquier `redirect_to` que no esté en esa
  lista y redirige al *Site URL* en su lugar: el correo se envía, el enlace abre el navegador y la
  aplicación no recibe nada. El esquema `pseudolearn` está registrado en `CFBundleURLTypes` de
  `macos/Runner/Info.plist` y de `ios/Runner/Info.plist`; ambos extremos tienen que coincidir.

### 2.2 Preparación e instalación

```bash
# Resolución de dependencias del monorepo
flutter pub get

# Preparación de exportación SEE, localizaciones, puente y activos de plataforma
bash tool/prepare_generated.sh

# Repetición aislada desde un checkout limpio
bash tool/bridge.sh clean-checkout

# Verificación de fuentes tipográficas empaquetadas
dart run tool/check_design_system.dart
```

### 2.3 Ejecución en desarrollo

```bash
# Ejecución en escritorio macOS, con credenciales de Supabase y Google
flutter run -d macos --dart-define-from-file=dart_define.local.json

# Ejecución en simulador iOS
flutter run -d "iPhone 15" --dart-define-from-file=dart_define.local.json

# Ejecución con herramientas de depuración de Flutter
flutter run -d macos --observe --dart-define-from-file=dart_define.local.json
```

### 2.4 Compilación y build

En un checkout limpio, instala las dependencias y genera las entradas ignoradas antes de ejecutar la app
o compilarla: `flutter pub get` y `bash tool/prepare_generated.sh`. El script genera la exportación del
corpus, las localizaciones, los enlaces FRB y los activos de plataforma.

```bash
# Artefacto de producción para macOS (.app sin firmar, empaquetable en DMG)
flutter build macos --release
# Ruta de salida: build/macos/Build/Products/Release/PseudoLearn.app

# Artefacto de producción para iOS (paquete .ipa sin firma para staging)
flutter build ipa --no-codesign
# Ruta de salida: build/ios/archive/Runner.xcarchive

# Artefacto de producción para Windows (ejecutable pseudolearn.exe y bundle)
flutter build windows --release
# Ruta de salida: build/windows/x64/runner/Release/
```

El target `Runner` de Release en `macos/Runner.xcodeproj` usa `CODE_SIGN_STYLE = Manual` y
`CODE_SIGNING_ALLOWED = NO`: el build produce un bundle sin firma porque sus entitlements restringidos
requieren el perfil de Mac App Store que el workflow instala después de compilar. El workflow
`.github/workflows/push-production-macos.yml` (§2.6) incorpora el perfil, firma el framework Rust y los
frameworks anidados, y firma el `.app`. `flutter build macos --release` no necesita una cuenta Apple ni
un perfil en el equipo de desarrollo.

### 2.5 Pruebas y verificación inmediata

La verificación de integridad se ejecuta sin dependencias externas:

```bash
# 1. Análisis estático estricto
flutter analyze --fatal-infos --fatal-warnings

# 2. Verificación del transporte Dart–FFI con la biblioteca nativa real
bash tool/test_bridge.sh

# 3. Verificación de límites métricos (architecture.yaml)
dart run tool/check_limits.dart

# 5. Verificación de integridad del sistema de diseño
dart run tool/check_design_system.dart

# 5b. Cobertura de las formas públicas de la vista por ordinograma, estructograma y estructura
dart run tool/check_syntax_coverage.dart

# 5c. Manual de usuario: cada funcionalidad anclada tiene entrada en es y en, y viceversa
dart run tool/check_manual.dart

# 6. Biblioteca nativa de las pruebas y suite completa (unitarios, arquitectura, widgets y ruta contra el motor real)
cargo build --release --locked --lib --manifest-path native/Cargo.toml
flutter test

# 7. Humo funcional en el primer simulador iPhone disponible
SIMULATOR_ID=$(xcrun simctl list devices available --json | python3 -c 'import json, sys; devices = json.load(sys.stdin)["devices"].values(); print(next((device["udid"] for runtime in devices for device in runtime if device["name"].startswith("iPhone")), ""))')
flutter test --no-pub --device-id "$SIMULATOR_ID" integration_test/native_engine_smoke_test.dart

# 8. Humo Profile en un iPhone físico conectado por USB o Wi-Fi
DEVICE_ID="<UDID del iPhone físico>"
flutter drive --profile --no-pub --device-id "$DEVICE_ID" \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/native_engine_smoke_test.dart

# 9. Humo de los bindings sobre el asset generado para macOS Release
FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR="$PWD/build/native_assets/macos" \
  flutter test --no-pub tool/native_bridge_test.dart tool/native_bridge_adapters_test.dart

# 10. Conformidad de la composición de app desde el miembro de especificaciones
cd ../../packages/pseudolearn_spec
cargo run -p see_cli --bin see -- conform --subject app
flutter test --no-pub --device-id "$SIMULATOR_ID" integration_test/real_api_acceptance_test.dart \
  --dart-define=PSEUDOLEARN_ACCEPTANCE=true
```

El humo de plataforma inicia el puente real y recorre análisis, completado, entrada y consulta de arreglos.
`flutter drive` no admite Release para integración nativa; Profile sirve para el humo funcional, no reemplaza
las mediciones Release de E-NR2. `flutter build ios --release --no-codesign` compila el artefacto de tamaño sin
instalarlo en un dispositivo.
Los builds de Windows ejecutan la integración en la app y las pruebas FFI contra
`build/native_assets/windows`; también verifican que el DLL aparezca en el bundle, el MSIX, el instalador
y el ZIP portable.

La verificación remota de builds se inicia manualmente desde `.github/workflows/verify-native-builds.yml`.
Construye el archive iOS sin firma, la app macOS universal y los paquetes Windows, ejecuta los humos nativos
y no publica artefactos en tiendas, R2 ni CDN. Requiere acceso a GitHub Actions; el build local no requiere
ese servicio.

`tool/see_app_adapter.dart` implementa el proceso SEE y abre `openNativeTransport()`, por lo que los
escenarios de app llaman el puente FRB generado para consultar el motor. `see conform --subject app`
escribe observaciones y matriz bajo `packages/pseudolearn_spec/results/`, un directorio local ignorado.
`see conform --subject app --operation properties` ejecuta las propiedades API por el mismo transporte
y guarda su evidencia en ese directorio. Las llamadas API pueden enviarse en secuencia y reutilizar un
recurso devuelto por una llamada anterior mediante `resource_from`; así se contrastan por el puente
real los contratos que necesitan negociar versiones, conservar identidad o consultar una sesión.
El manifiesto conserva sus reglas como pendientes hasta que
todas las divergencias se resuelvan y la campaña de medición de B8 esté completa.

### 2.6 Despliegue y distribución

La validación de build está separada de los flujos productivos. `.github/workflows/verify-native-builds.yml`
solo admite `workflow_dispatch`, no usa secretos de publicación y no sube artefactos. Los workflows
`push-production-*` también son manuales, pero sí contienen las acciones explícitas de firma, carga o
distribución de su canal. Los workflows de iOS, macOS, Windows Store y Windows R2 usan
`.github/actions/setup-rust-bridge/action.yml`, que instala el toolchain declarado por
`native/rust-toolchain.toml`, los objetivos requeridos y las versiones fijadas de `cargo-expand` y
`flutter_rust_bridge_codegen`. Luego genera la exportación SEE, las localizaciones, los enlaces FRB y los
activos Apple en rutas ignoradas. Su caché solo conserva descargas de Cargo. La clave incluye sistema
operativo, objetivos, toolchain, locks, archivo FRB y hook Native Assets; nunca se restauran dependencias
de una clave anterior ni se reutilizan binarios compilados.

- **Distribución en macOS:** Automatizada por `.github/workflows/push-production-macos.yml`, en la raíz del
  monorepo. Un disparo manual (`workflow_dispatch`) hace que un runner
  `macos-15` compile el `.app` universal en modo release, compruebe las arquitecturas arm64/x86_64 del
  ejecutable y de `pseudolearn_bridge.framework`, y ejecute el humo Rust contra el asset generado. Después le
  embebe el perfil de aprovisionamiento de *Mac App
  Store*, firme sus frameworks anidados y el bundle con un certificado *Apple Distribution*, lo empaquete
  con `productbuild` en un `.pkg` firmado con un certificado *Mac Installer Distribution*, y lo valide y
  suba a App Store Connect con `xcrun altool` autenticado por API Key. El canal de macOS es el mismo que
  el de iOS: no hay descarga directa, ni imagen de disco, ni notarización, ni alojamiento propio del
  artefacto, ni nada en GitHub Releases.
    - **Credenciales de firma (Secrets del repositorio de GitHub, nunca en el código ni en el
      workflow):** `APPLE_DISTRIBUTION_CERTIFICATE_P12_BASE64`, `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD`,
      `APPLE_INSTALLER_CERTIFICATE_P12_BASE64`, `APPLE_INSTALLER_CERTIFICATE_PASSWORD`,
      `APPLE_PROVISIONING_PROFILE_BASE64` (el `.provisionprofile` de tipo *Mac App Store* emitido para
      `com.pseudolearn.app`, codificado en base64). El perfil caduca y hay que renovarlo; el workflow falla
      de forma explícita si su `application-identifier` no coincide con el de la app o si no autoriza
      `com.apple.developer.applesignin` y `keychain-access-groups`.
    - **Los nombres de las dos identidades de firma no son parámetros.** El workflow los resuelve del
      llavero temporal, admitiendo `Apple Distribution` o `3rd Party Mac Developer Application` para el
      bundle y `3rd Party Mac Developer Installer` para el instalador, y falla con un mensaje explícito si
      el certificado importado es de otro tipo. Un nombre de identidad copiado a mano es la fuente de error
      más frecuente de este pipeline y no aporta información que el certificado no lleve ya dentro.
    - **Credenciales de publicación (Secrets):** `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
      `APP_STORE_CONNECT_KEY_P8_BASE64`. La clave privada se materializa en el runner como
      `~/.appstoreconnect/private_keys/AuthKey_<id>.p8`, única ruta donde `altool` la busca, y se borra al
      terminar el job junto con el llavero temporal. La API Key necesita rol de *App Manager* o superior:
      un rol de solo lectura firma la petición pero no admite la subida.
    - **Variables de auth de la app en CI (Secrets, categoría distinta de las dos anteriores):**
      `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_IOS_CLIENT_ID` — las mismas tres claves que en
      desarrollo local se cargan desde `dart_define.local.json` (§2.1). El workflow las escribe a un
      `dart_define.ci.json` efímero, en el propio runner, justo antes de `flutter build macos`, y ese
      archivo nunca se commitea ni queda en el log del job.
    - Ningún secret vive en el repositorio, en `dart_define.local.json` ni en el propio archivo del
      workflow: los tres grupos se configuran en GitHub → *Settings → Secrets and variables → Actions*
      del repositorio.
    - **El `.app` lleva el perfil de aprovisionamiento embebido en `Contents/embedded.provisionprofile`, y
      el workflow lo copia ahí antes de firmar el bundle.** Un *entitlement* restringido no lo autoriza el
      certificado: lo autoriza un perfil embebido que lo declare para `com.pseudolearn.app`. Sin él, AMFI
      mata el proceso al arrancar con `Error -413 "No matching profile found"` y macOS muestra «La
      aplicación no se puede abrir», aunque la firma sea válida — el binario no llega a ejecutarse.
      `Release.entitlements` declara dos entitlements restringidos, `com.apple.developer.applesignin` y
      `keychain-access-groups`, que el perfil de Mac App Store autoriza; y `com.apple.security.app-sandbox`,
      obligatorio en ese canal y ya vigente en `DebugProfile.entitlements`, de modo que el
      almacenamiento de la app corre bajo sandbox también en desarrollo.
    - **`Release.entitlements` declara `com.apple.application-identifier` explícitamente.** Xcode inyecta esa
      clave por su cuenta cuando firma con un perfil embebido; `codesign` invocado desde la línea de órdenes
      no lo hace, y firma solo lo que el archivo de entitlements diga. Un bundle cuyo perfil declara un
      identificador de aplicación y cuya firma no lo lleva se sube y se valida sin queja, pero TestFlight lo
      rechaza con `ITMS-90886` y la compilación queda como no disponible para pruebas. El valor debe coincidir
      con el `com.apple.application-identifier` del perfil, y coincide porque ambos se derivan del mismo
      prefijo de equipo.
    - **`$(AppIdentifierPrefix)` se resuelve en el runner, no se escribe a mano en el archivo.** Esa
      variable la expande Xcode; `codesign` invocado desde la línea de órdenes no la expande y firmaría el
      literal, produciendo un grupo de llavero inválido. El workflow lee el prefijo de equipo del propio
      perfil (`security cms -D` sobre el `.provisionprofile`, clave `ApplicationIdentifierPrefix`), genera
      una copia resuelta de `Release.entitlements` en el directorio temporal del runner y firma con esa
      copia. El archivo del repositorio conserva la variable para que las compilaciones locales con Xcode
      sigan funcionando, y el prefijo de equipo nunca se duplica como constante en el repositorio.
    - **`Runner/Info.plist` declara `LSApplicationCategoryType` como `public.app-category.education`.** La
      plantilla de macOS de Flutter no trae esa clave porque la distribución directa no la exige; la App
      Store sí, y sin ella `altool --validate-app` rechaza el paquete con un 409 antes de subirlo. El valor
      es la categoría con la que la app se lista en la tienda y debe coincidir con la categoría elegida en
      la ficha de App Store Connect.
    - **`Runner/Info.plist` declara `ITSAppUsesNonExemptEncryption` como falso.** La app solo emplea el
      cifrado estándar del sistema operativo: TLS hacia Supabase y hacia Google, y el llavero de macOS. No
      incorpora algoritmos criptográficos propios, de modo que queda exenta de la normativa de exportación.
      Sin esa declaración en el bundle, App Store Connect retiene cada compilación pidiendo la respuesta a
      mano y TestFlight no la ofrece a ningún tester.
    - **`Runner/Info.plist` declara `CFBundleLocalizations` con `es` y `en`.** Flutter resuelve el idioma en
      tiempo de ejecución, así que sin esa lista el bundle no anuncia ningún idioma y la ficha de la tienda
      aparece como si la app fuese solo inglesa. El español va primero porque es la lengua plantilla de la
      localización (`app_es.arb` en `l10n.yaml`) y el público objetivo del producto.
    - **El número de compilación lo fija el workflow, no `pubspec.yaml`.** App Store Connect rechaza una
      subida cuyo `CFBundleVersion` repita el de otra anterior de la misma versión de mercado.
      `flutter build macos` recibe `--build-number` con el número de ejecución del job, monotónico por
      repositorio, y ese valor llega a `CFBundleVersion` a través de `$(FLUTTER_BUILD_NUMBER)`.
      `pubspec.yaml` sigue siendo la fuente única de la versión de mercado, que viaja por
      `$(FLUTTER_BUILD_NAME)` a `CFBundleShortVersionString`.
- **Distribución en iOS:** Automatizada por `.github/workflows/push-production-ios.yml`, solo por despacho manual
  (`workflow_dispatch`), con los mismos secretos que el canal de macOS (sin el instalador ni el perfil de Mac App
  Store). El script `.github/scripts/app_store_connect.rb` habla con la API de App Store Connect: calcula el siguiente
  número de compilación de iOS para la versión de `pubspec.yaml` (el mayor ya subido más uno, porque
  `GITHUB_RUN_NUMBER` de un workflow nuevo colisionaría con compilaciones existentes), crea en cada ejecución un perfil
  `IOS_APP_STORE` con todos los certificados de distribución y lo borra al terminar (los perfiles guardados caducan o
  quedan `INVALID` cuando cambian las capacidades del App ID, por eso no se guarda uno en un secreto). La firma pasa a
  manual solo en el runner, añadiendo ajustes a `ios/Flutter/Release.xcconfig` antes de `flutter build ipa`; el
  proyecto versionado conserva la firma automática. Antes de subir, extrae el `.ipa`, comprueba arm64 y la firma del
  framework Rust y valida la firma profunda de la app. Tras `altool --upload-app` espera a que la compilación quede
  `VALID`, declara el cifrado como exento si falta, crea (o reutiliza) la versión editable de la App Store con
  `releaseType` manual, rellena *Novedades* desde `CHANGELOG.json`, y asocia la compilación. **No envía a revisión**:
  ese paso lo da la persona en App Store Connect. Si la versión de `pubspec.yaml` ya está publicada, el workflow se
  detiene: hay que subir la versión.
- **Distribución en Windows (Microsoft Store):** Automatizada por `.github/workflows/push-production-windows-store.yml`.
  Un despacho manual (`workflow_dispatch`) en runner `windows-latest` compila la versión release con
  `--dart-define-from-file=dart_define.ci.json`, verifica la presencia de los redistribuibles de Visual C++
  (`msvcp140.dll`, `vcruntime140.dll`, `vcruntime140_1.dll`) y del DLL Rust en el bundle y el MSIX. Ejecuta el
  smoke del puente y la integración en la app antes de empaquetar el bundle con `dart run msix:pack` en
  `PseudoLearn-Store.msix`, configurado con la identidad de Partner Center (`CESARGUTIERREZ.PseudoLearn`,
  `CN=EDFD3B2E-83F3-4BC3-9577-7798545994BB`, Store ID `9MXZB1XDWP9J`). El paquete declara la capacidad `runFullTrust`,
  el protocolo `pseudolearn://` para captura de callbacks de autenticación y la asociación de archivos `.pseudo`.
  Microsoft Store firma el paquete oficialmente tras la certificación en Partner Center.
- **Distribución en Windows (Cloudflare R2):**
  - **Instalador ejecutable (`PseudoLearn-Setup.exe`) y `.zip` portable:** Compilados automáticamente en el workflow
    `.github/workflows/push-production-windows-r2.yml` en runners `windows-latest` solo por despacho manual (`workflow_dispatch`), con la versión como input opcional; si se omite, la lee de `pubspec.yaml`.
  - **Empaquetado con Inno Setup (`packaging/windows/inno_setup.iss`):** Genera un instalador por usuario
    (`{localappdata}\Programs\PseudoLearn`) sin requerir elevación de privilegios UAC. Registra el protocolo
    `pseudolearn://` en `HKCU\Software\Classes\pseudolearn` con comando `"{app}\pseudolearn.exe" "%1"` para captura en
    caliente de callbacks OAuth/Magic Link, y asocia la extensión `.pseudo`.
  - **Runtime de Visual C++ local a la aplicación:** `windows/CMakeLists.txt` incluye
    `InstallRequiredSystemLibraries` y copia `msvcp140.dll`, `vcruntime140.dll` y `vcruntime140_1.dll` junto a
    `pseudolearn.exe`, así que el instalador y el `.zip` arrancan en un Windows sin el redistribuible instalado. El
    workflow falla antes de empaquetar si falta alguna; después instala en modo silencioso y comprueba el DLL Rust en
    el instalador y el ZIP portable. Se descartó instalar `vc_redist.x64.exe` desde Inno Setup:
    exige elevación UAC y el instalador es por usuario.
  - **Versión del ejecutable:** el workflow pasa la versión del tag como `--build-name`, de modo que el recurso de
    versión de `pseudolearn.exe` coincide con la del instalador.
  - **Versión portable:** no registra `pseudolearn://`, así que en ella el inicio de sesión con Apple, Google o enlace
    mágico no vuelve a la aplicación (pendiente declarado en §1.5).
  - **Sin firma Authenticode:** ni `pseudolearn.exe` ni el instalador están firmados; SmartScreen muestra «Editor
    desconocido» (pendiente declarado en §1.5).
  - **Almacenamiento y CDN:** Los binarios se suben a un bucket de Cloudflare R2 mediante la API compatible con S3.
    Se mantienen punteros estables (`windows/PseudoLearn-Setup.exe` y `windows/PseudoLearn-Windows-Portable.zip`) y
    rutas inmutables versionadas (`windows/vX.Y.Z/...`).
  - **Secretos de GitHub Actions necesarios:**
    - `R2_ACCOUNT_ID`: Account ID de Cloudflare.
    - `R2_ACCESS_KEY_ID`: Clave de acceso del token R2 con permisos de lectura y escritura sobre el bucket.
    - `R2_SECRET_ACCESS_KEY`: Secreto de acceso de R2.
    - `R2_BUCKET_NAME`: Nombre del bucket de almacenamiento (ej. `pseudolearn-releases`).
    - `SUPABASE_URL` y `SUPABASE_ANON_KEY`: Credenciales inyectadas en tiempo de compilación.
- **Checklist de liberación:**
    - [ ] `flutter test` y todos los scripts de `tool/` al 100 % en verde.
    - [ ] Versión de mercado actualizada en `pubspec.yaml`; el número de compilación lo pone el workflow.
    - [ ] El tag empujado (`vX.Y.Z`) coincide con `version:` en `pubspec.yaml`.
    - [ ] Entrada nueva al principio de `CHANGELOG.json`, en la raíz del monorepo, con la misma versión, la fecha
      de publicación, el núcleo anclado y cada cambio en español e inglés (`README.md` de la raíz, §4.4). La
      web la publica sola al llegar a `master`.
    - [ ] Documentación técnica (`README.md`) y contratos de `architecture.yaml` actualizados.
    - [ ] El perfil de `APPLE_PROVISIONING_PROFILE_BASE64` sigue vigente y autoriza los entitlements
      restringidos de `Release.entitlements`.
    - [ ] La compilación aparece en App Store Connect, arranca en un Mac distinto del de compilación y
      completa el inicio de sesión por los tres proveedores con el almacenamiento dentro del sandbox.
    - [ ] La Edge Function `delete-account` y sus secretos de Apple están desplegados en producción antes
      de publicar una versión que la invoque (`apps/pseudolearn_backend/README.md` §2.6), y «Eliminar
      cuenta» con una cuenta de prueba de Apple la retira de `auth.users` y de los ajustes de Apple ID del
      dispositivo.

### 2.7 Regeneración de los activos de marca

La pantalla de lanzamiento de iOS se rasteriza desde la geometría que la app pinta en su primer fotograma. Los íconos de
iOS, macOS y Windows usan esa geometría sobre el fondo degradado del vector maestro. `tool/prepare_generated.sh` los
regenera antes de compilar y escribe los `Contents.json` de los catálogos:

```bash
bash tool/prepare_generated.sh
```

`flutter test tool/generate_app_icons.dart` genera los tamaños iOS y macOS, el PNG de empaquetado MSIX y el ICO de
Windows. Xcode valida y compila los catálogos durante el build.

### 2.8 Regeneración de las capturas de producto de la web

La landing (`apps/fe-pseudolearn`) no dibuja una reconstrucción del editor: muestra la app real. Las ocho imágenes las
rasteriza esta herramienta montando la composición completa —`CubitScope`, enrutador y armazón—, cargando el programa
correspondiente (`assets/demo/guided_demo_es.pseudo` con `SyntaxProfileId.classicSpanish` y
`UiLanguageId.spanish`
para español, o `assets/demo/guided_demo_en.pseudo` con `SyntaxProfileId.english` y `UiLanguageId.english`
para inglés), ejecutándolo hasta el final, abriendo el panel acompañante y encuadrando el ordinograma. Se ejecuta cuando
cambie algo que la imagen enseñe, no en cada compilación:

```bash
bash tool/prepare_generated.sh
cargo build --release --locked --lib --manifest-path native/Cargo.toml
FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR="$PWD/native/target/release" flutter test tool/generate_product_shot.dart
```

| Archivo                       | Lienzo    | Clase de dispositivo | Idioma  | Tema   |
|-------------------------------|-----------|----------------------|---------|--------|
| `es/editor-mobile-light.png`  | 390 × 844 | `compact`            | español | claro  |
| `es/editor-mobile-dark.png`   | 390 × 844 | `compact`            | español | oscuro |
| `es/editor-desktop-light.png` | 1280× 800 | `expanded`           | español | claro  |
| `es/editor-desktop-dark.png`  | 1280× 800 | `expanded`           | español | oscuro |
| `en/editor-mobile-light.png`  | 390 × 844 | `compact`            | inglés  | claro  |
| `en/editor-mobile-dark.png`   | 390 × 844 | `compact`            | inglés  | oscuro |
| `en/editor-desktop-light.png` | 1280× 800 | `expanded`           | inglés  | claro  |
| `en/editor-desktop-dark.png`  | 1280× 800 | `expanded`           | inglés  | oscuro |

El lienzo se dispone en unidades lógicas y se rasteriza al doble: la clase de dispositivo la decide el ancho lógico, así
que subir la densidad de la imagen no puede cambiar la maquetación que se está retratando.

Dos comprobaciones acompañan a la escritura de los archivos, y ninguna es decorativa. La primera mide el avance de
`iiii` contra el de `MMMM`: el motor de pruebas rasteriza con un tipo de relleno de avance constante, así que si las
familias empaquetadas no se cargaron los dos avances coinciden y la captura saldría llena de bloques en vez de texto. La
segunda exige que la ejecución haya dejado líneas de salida, porque una captura de un editor en reposo se parece
demasiado a una correcta como para detectarla mirando.

### 2.9 Regeneración del material promocional para tiendas

Las capturas de pantalla y el gráfico destacado de Google Play no son maquetas estáticas dibujadas a mano ni capturas
manuales en emuladores: se componen mecánicamente montando la aplicación viva (`CubitScope`, rutas y armazón completo)
dentro de un marco de presentación (`PromoFrame`) con fondo de gradiente del sistema de diseño, sombras de elevación y
titulares tipográficos localizados. Se ejecutan cuando cambie la interfaz, la marca o los textos promocionales:

```bash
# Compone y rasteriza las 40 capturas de pantalla y los 2 gráficos destacados en build/store/
flutter test tool/generate_store_material.dart
```

#### Destinos, resoluciones y factores de escala

| Destino de tienda               | Carpeta bajo `build/store/`    | Resolución en píxeles | Escala | Lienzo lógico app | Proporción |
|:--------------------------------|:-------------------------------|:----------------------|:-------|:------------------|:-----------|
| Mac App Store                   | `mac-app-store/`               | 2880 × 1800           | 2.0x   | 1440 × 900        | 16:10      |
| iOS App Store (iPhone 6.9")     | `ios-app-store-iphone-6-9/`    | 1320 × 2868           | 3.0x   | 393 × 852         | 9.2:20     |
| iOS App Store (iPad 13")        | `ios-app-store-ipad-13/`       | 2064 × 2752           | 2.0x   | 1024 × 1366       | 3:4        |
| Google Play (Teléfono)          | `google-play-phone/`           | 1080 × 1920           | 2.0x   | 393 × 852         | 9:16       |
| Google Play (Gráfico destacado) | `google-play-feature-graphic/` | 1024 × 500            | 2.0x   | 512 × 250         | 2.048:1    |

Cada destino de captura genera las 5 escenas de la historia en español (`es/`) y en inglés (`en/`), sumando 40 capturas
de pantalla, a las que se añaden los 2 gráficos destacados de Google Play (`es.png` y `en.png`), totalizando 42 activos.

#### Escenas interactivas y aserciones de estado

Cada captura ejecuta un guion determinista sobre la interfaz viva y comprueba que el estado sea el esperado:

1. `01-synced-views` (*Tu algoritmo, en código y en diagrama*): Carga el programa guiado, avanza 11 pasos en depuración,
   abre la pestaña de ordinograma y despliega el panel acompañante. Verifica que el estado de ejecución esté en pausa a
   mitad del programa (`statementNumber > 1`).
2. `02-step-by-step` (*Avanza instrucción por instrucción*): Carga el programa guiado, avanza 11 pasos y expande el
   panel de salida interactivo. Verifica que la ejecución permanezca pausada mid-step.
3. `03-trace-table` (*Mira cada variable cambiar en la tabla*): Carga la demostración de aliasing de objetos, abre la
   pestaña de traza, abre el panel acompañante y avanza 4 pasos. Verifica que la tabla de traza muestre aliasing activo
   con distintivos de identidad de objeto (`NombreClase#id`).
4. `04-equivalent-code` (*El mismo algoritmo en Python y Rust*): Carga el programa de funciones, abre la pestaña de
   código equivalente y despliega el panel acompañante. Verifica que la exportación haya emitido código no vacío.
5. `05-knowledge-base` (*Módulos y ejercicios para practicar*): Navega a la ruta de conocimiento (`/conocimiento`) y
   espera a que el índice de la ruta, la especificación y el banco de ejercicios completen su carga
   (`status == success`). Las imágenes versionadas son anteriores a la ruta de aprendizaje y están pendientes de
   regenerar (§1.5).

#### Validaciones mecánicas obligatorias del flujo

Cuatro comprobaciones automáticas blindan la generación antes y durante la rasterización:

1. **Rasterización de familias empaquetadas:** Comprueba la diferencia de avance métrico entre `iiii` y `MMMM` en la
   tipografía de interfaz. Si las fuentes empaquetadas (IBM Plex Sans) no se cargaron, el ancho coincide y la prueba
   falla.
2. **Auditoría de vocabulario y directrices de tiendas:** Audita cada titular contra las políticas de App Store y Google
   Play (`marketing_lexicon.dart`), rechazando referencias a precios o gratuidad, términos beta, superlativos ("el
   mejor"),
   reclamos de premios, llamadas a la acción agresivas ("descarga ahora"), mención a plataformas rivales ("Android" en
   material de Apple, o "iOS" en Google Play) y longitudes mayores a 7 palabras o 48 caracteres.
3. **Ajuste geométrico de titulares:** Verifica mediante `TextPainter` que el titular no supere el número máximo de
   líneas
   permitido (2 en vertical, 1 en horizontal) sobre el ancho asignado por `PromoLayout`.
4. **Codificación PNG opaca sin canal alfa:** Ambas tiendas rechazan tajantemente imágenes con canal alfa. El flujo
   utiliza
   un codificador propio (`opaque_png.dart`) que inspecciona cada píxel (arrojando `TransparentPixelFound` si algún alfa
   difiere de 255) y escribe un archivo PNG Truecolour (color type 2) con filtro Paeth y compresión Deflate. La cabecera
   del archivo resultante es leída y verificada tras la escritura (`PngHeader.colourType == 2`).

---

## 3. Arquitectura y modelo del sistema

### 3.1 Paradigma arquitectónico

`pseudolearn_app` implementa una **Arquitectura Hexagonal (Puertos y Adaptadores)** estricta. El dominio interno (
`model` y `ports`) está completamente aislado de la infraestructura externa, del framework Flutter y del motor del
lenguaje. Las dependencias apuntan exclusivamente hacia el centro. La presentación desconoce la
infraestructura y el motor; la lógica de aplicación desconoce los widgets y el contexto de interfaz (`BuildContext`).

### 3.2 Diagrama de capas y dirección de dependencias

```
┌────────────────────────────────────────────────────────────────────────┐
│ 5. composition    Raíz de inyección estática (main.dart, factories)    │
├────────────────────────────────────────────────────────────────────────┤
│ 4. presentation   Widgets, pintores, tema, navegación (go_router)      │
├────────────────────────────────────────────────────────────────────────┤
│ 3. application    Cubits de estado de vista y casos de uso (Dart puro)  │
├───────────────────────────┬────────────────────────────────────────────┤
│ 2. engine                 │ 2. data                                    │
│ Adaptador API Rust│ Archivos .pseudo, SQLite, activos bundled  │
├───────────────────────────┴────────────────────────────────────────────┤
│ 1. ports          Interfaces requeridas hacia el exterior              │
├────────────────────────────────────────────────────────────────────────┤
│ 0. model          Estructuras de datos inmutables (el centro)          │
└────────────────────────────────────────────────────────────────────────┘
```

La capa `host` comparte el anillo 2 con engine y data; solo importa model y ports y posee el contexto físico por documento.

### 3.3 Catálogo de carpetas, responsabilidades e invariantes

| Capa / Directorio        | Responsabilidad única                                                                                                                                                                                                                                                                                              | Puede importar (`may_import`)                                             | Prohibido importar (`forbidden_imports`)                                                                                                       |
|:-------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------|
| `domain/model/`          | Entidades y valores de datos inmutables de la aplicación                                                                                                                                                                                                                                                           | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, el transporte del motor, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/model/account/`  | Entidades inmutables de cuenta, sesión, perfiles y resultados tipados de autenticación y de eliminación de cuenta (`AccountSession`, `AccountProfile`, `AuthMethod`, `AuthOutcome`, `AccountDeletionOutcome`)                                                                                                     | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, el transporte del motor, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/model/sync/`     | Modelos inmutables de reconciliación, instantáneas, resultados y función pura de resolución trilateral (`DocumentSnapshot`, `ReconciliationOutcome`, `reconcileDocument`, `SyncStatus`, `OutboxEntry`)                                                                                                             | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, el transporte del motor, `bloc`, `dart:io`, `dart:ui`, `sqflite`                                                 |
| `domain/model/progress/` | Modelos inmutables de avance curricular y marcas temporales de primer logro (`ProgressEntry`)                                                                                                                                                                                                                      | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, el transporte del motor, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/model/editor/`   | Cursor propio (`CaretRange`), tecla del editor (`EditorKey`) y resultado de una edición (`SourceEdit`). No usa `TextSelection`: es de Flutter y el modelo no lo importa                                                                                                                                            | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, el transporte del motor, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/ports/`          | Contratos abstractos e interfaces requeridas                                                                                                                                                                                                                                                                       | `model`                                                                   | `engine`, `data`, `application`, `presentation`, `flutter/`, el transporte del motor, `bloc`, `dart:io`, `dart:ui`                                  |
| `engine/`                | Adaptación y traducción entre el transporte del motor y `domain`                                                                                                                                                                                                                                                        | `model`, `ports`, el transporte del motor                                      | `data`, `application`, `presentation`, `flutter/`, `dart:io`, `dart:ui`, `RegExp`                                                              |
| `engine/editing/`        | Cálculo puro de la edición en el cursor (`LexiconSourceEditor`) y derivación de las teclas desde el léxico del perfil (`ProfileKeySource`)                                                                                                                                                                         | `model`, `ports`, el transporte del motor                                      | `data`, `application`, `presentation`, `flutter/`, `dart:io`, `dart:ui`, `RegExp`                                                              |
| `host/`                  | Contexto físico de ejecución por documento: carpeta de trabajo real (`LocalExecutionEnvironment` implementa `ExecutionEnvironment`); admite `dart:io`, prohíbe interfaz Flutter y `engine/`                                                                                                                                                                                                                                                                                                                                                          |
| `data/`                  | Persistencia en disco, SQLite y lectura de activos                                                                                                                                                                                                                                                                 | `model`, `ports`, `dart:io`, `sqflite`, `package:markdown`                | `engine`, `application`, `presentation`, el transporte del motor, `flutter/material.dart`, `flutter/widgets.dart`, `bloc`                           |
| `data/auth/`             | Adaptadores de autenticación nativa de plataforma, cliente Dart puro `supabase`, almacenamiento seguro de token y forma del enlace de retorno (`SupabaseAuthGateway`, `SupabaseAccountDeletionGateway`, `SupabaseSessionPersistence`, `NativeCredentialSource`, `SessionStorage`, `authCallbackUrl`)                                             | `domain/model`, `domain/ports`, `package:supabase`, almacenamiento seguro | `engine`, `application`, `presentation`, el transporte del motor, `flutter/material.dart`, `flutter/widgets.dart`, `flutter/cupertino.dart`, `bloc` |
| `data/platform/`         | Adaptadores de servicios del sistema operativo: reloj, generación de identificadores, sondeo de conectividad, recepción de enlaces entrantes, modalidad de entrada de texto, apertura de enlaces, versión instalada, petición de reseña en la tienda y soporte de autenticación nativa (`SystemClock`, `RandomIdentifierGenerator`, `ConnectivityMonitorAdapter`, `AppLinksIncomingLinkSource`, `PlatformTextEntryModality`, `PlatformExternalUrlLauncher`, `PlatformNativeAuthSupport`, `PlatformAppVersionSource`, `PlatformStoreReviewPrompt`) | `domain/model`, `domain/ports`, `dart:io`, `package:app_links`, `package:url_launcher`, `package:package_info_plus`, `package:in_app_review` | `engine`, `application`, `presentation`, el transporte del motor, `flutter/material.dart`, `flutter/widgets.dart`, `flutter/cupertino.dart`, `bloc` |
| `data/sync/`             | Persistencia de outbox en SQLite, almacenes remotos en Supabase y orquestación de drenado con orden pull-antes-que-push, y purga local de los datos de una cuenta eliminada (`SqliteSyncQueue`, `SupabaseDocumentStore`, `SyncDrainer`, `LocalAccountDataPurgerAdapter`)                                                       | `domain/model`, `domain/ports`, `sqflite`, `package:supabase`             | `engine`, `application`, `presentation`, el transporte del motor, `flutter/material.dart`, `flutter/widgets.dart`, `flutter/cupertino.dart`, `bloc` |
| `application/`           | Casos de uso, orquestación y cubits de estado inmutable                                                                                                                                                                                                                                                            | `model`, `ports`, `package:bloc`, `package:equatable`                     | `engine`, `data`, `presentation`, `flutter/`, el transporte del motor, `go_router`, `sqflite`, `dart:io`, `dart:ui`, `BuildContext`, `RegExp`       |
| `application/agent/`     | Bucle del agente, registro y política de confirmación, ensamblado del prompt, instantáneas de pantalla, verificación de bloques, resaltado léxico (`highlight/`), disposición de diagramas de flujo (`flowchart/`) y una herramienta por caso de uso (`tools/`) | `model`, `ports`, `package:bloc` | Lo mismo que `application/`; ninguna herramienta habla con un repositorio sin pasar por su caso de uso cuando existe |
| `application/credits/`   | Estado de créditos, compras y consentimiento del agente (`CreditsCubit`, `PurchaseCubit`, `AgentConsentCubit`) | `model`, `ports`, `package:bloc` | Lo mismo que `application/` |
| `data/agent/`, `data/credits/` | Proxy HTTP del modelo y de créditos, códec de la Responses API, lector de Markdown de las respuestas (`markdown/`) y de diagramas Mermaid (`mermaid/`), índice de conocimiento, consentimiento en disco y compra simulada | `model`, `ports`, `dart:io` | Lo mismo que `data/` |
| `presentation/agent/`    | Glifo, botón flotante, panel de chat, vistas de la respuesta enriquecida (`reply/`), confirmaciones, oferta, consentimiento, ajustes de Nodo y publicadores de contexto de pantalla | `model`, `application`, `flutter/` | Lo mismo que `presentation/` |
| `application/<área>/use_cases/` | Casos de uso: clases puras con un único método público `call` (y, como mucho, una variante con nombre) que ejecutan un comando o una consulta de negocio contra los puertos y devuelven un valor tipado en lugar de lanzar (`CreateDocument`, `RenameDocument`, `DeleteDocument`, `SaveDocumentSource`, `SetExecutionArguments`, `ListDocuments`, `LoadDocument`, `CheckProgram`, `RunProgram`, `TranslateProgram`, `FormatProgram`) | `model`, `ports` | Lo mismo que `application/`; además, un caso de uso no conoce ningún Cubit ni estado de vista |
| `presentation/`          | Widgets, CustomPainters, renderizado de lienzo y temas                                                                                                                                                                                                                                                             | `model`, `application`, `flutter/`, `go_router`, `flutter_bloc`           | `ports`, `engine`, `data`, el transporte del motor, `sqflite`, `dart:io`, constructores adaptativos OS, métodos de colección derivados              |
| `composition/`           | Ensamblado estático e inyección de dependencias en arranque                                                                                                                                                                                                                                                        | `model`, `ports`, `engine`, `data`, `application`, `presentation`         | Contener lógica o ramificaciones condicionales (`if`, `switch`, ternarios)                                                                     |

### 3.4 Flujo de datos y ciclo de vida

```
[Entrada de Usuario / Teclado]
         │
         ▼
[Presentation: CodeField] ──(Invoca comando)──► [Application: EditorCubit]
                                                       │
                                            (Petición a través de puerto)
                                                       ▼
                                            [Domain: ProgramAnalyzer]
                                                       │
                                             (Implementado en engine)
                                                       ▼
                                            [Engine: RustProgramAnalyzer]
                                                       │
                                      (Invoca Lexer/Parser/Resolver/Types)
                                                       ▼
                                            [Package: pseudolearn_engine]
                                                       │
                                         (Retorna AST y Diagnósticos)
                                                       ▼
                                            [Engine: RustProgramAnalyzer]
                                                       │
                                     (Proyecta a tipos inmutables de app)
                                                       ▼
                                            [Domain: AnalysisReport]
                                                       │
                                           (Emite nuevo estado inmutable)
                                                       ▼
                                            [Application: EditorState]
                                                       │
                                            (BlocBuilder repinta UI)
                                                       ▼
                                            [Presentation: Widgets/Canvases]
```

### 3.5 Concurrencia, asincronía y modelo de threading

- **Hilo principal determinista:** Todo el cómputo de análisis y trazado gráfico se ejecuta de forma sincrónica sobre el
  hilo de la interfaz gráfica.
- **Prohibición de `Isolate`:** El modelo evita la serialización entre hilos para garantizar latencias mínimas de
  refresco por paso de ejecución.
- **División en micro-lotes cooperativos:** `StepBatchRunner` divide la ejecución en bloques de micro-pasos acotados
  cediendo periódicamente el control al bucle de eventos mediante `Future.delayed(Duration.zero)`. Esto permite que la
  interfaz procese eventos de usuario, atienda el botón de detención y actualice los pintores sin congelamientos.
- **Prohibición de `await` en capa de presentación:** Los widgets delegan toda operación asíncrona a los cubits; las
  respuestas a diálogos se entregan como comandos unidireccionales mediante callbacks síncronos.
- **Frontera Rust síncrona:** El contrato del transporte generado reserva al hilo de la interfaz las operaciones breves de
  negociación, consulta y avance por micro-lote. Cada lote devuelve antes de que `StepBatchRunner` ceda al bucle de
  eventos; el puente no crea workers ni convierte los puertos síncronos en `Future`.

---

## 4. Decisiones de diseño y fundamentos técnicos

### 4.1 Manejo de estado: `bloc` en su forma de cubit

- **El caso de uso es la unidad de negocio; el Cubit orquesta la vista.** Un comando o una consulta de negocio
  (crear, renombrar, borrar o guardar un documento, fijar sus argumentos, comprobar, ejecutar, traducir o formatear un
  programa) vive en `application/<área>/use_cases/` como una clase pura con un método público `call`. Valida, toma el
  reloj y el generador de identificadores de sus puertos y devuelve un resultado tipado
  (`DocumentCommandResult`, `ProgramRunReport`, `ProgramTextResult`); nunca deja escapar una excepción. El Cubit
  traduce ese resultado a estado de vista y no repite reglas. Un caso de uso existe porque tiene **dos clientes**: la
  pantalla y el agente de IA (§4.63), que opera la app con los mismos comandos que la persona. Solo se extraen los que
  pide una pantalla o una herramienta; el resto de la lógica sigue en su Cubit.
  - *Alternativa descartada — que el agente llame a los Cubits:* un Cubit solo existe con su pantalla montada y su
    estado mezcla vista con negocio; el agente quedaría atado a qué pantalla está abierta.
  - *Alternativa descartada — que el agente llame a los repositorios:* duplicaría la validación del título, el
    incremento de revisión y el reloj, y dos clientes acabarían aplicando reglas distintas.
  - Los Cubits construyen sus casos de uso a partir de los puertos que ya recibían, para no cambiar su contrato de
    construcción ni el de sus tests.
- **Aviso de cambios (`DocumentRepository.changes`).** El repositorio emite `DocumentChange` (guardado con su
  revisión, borrado o reindexado) por un flujo de difusión. El adaptador de archivos emite tras escribir; el decorador
  de sincronización reenvía el flujo interno, de modo que también se oyen los cambios que aplica el drenaje remoto.
  `LibraryCubit` recarga la lista en silencio cuando ya estaba cargada, y `EditorCubit` recarga el documento abierto
  solo si la revisión anunciada es mayor que la suya y no tiene cambios sin guardar: lo que escribe el agente o la
  sincronización se ve sin recargar y nunca pisa una edición local. La suscripción vive en el mixin
  `DocumentChangeFollower`, que la cancela al cerrar el Cubit.
- **Formato y traducción sin operación nueva en el motor.** `RustProgramTranslator` usa la operación `translate` de la
  API y `RustProgramFormatter` abre un recurso LSP efímero y pide `textDocument/formatting`; ninguno añade
  operaciones al puente. `EngineProgramBatchRunner` reutiliza `ProgramRunner` con argumentos y un límite de pasos
  acotado a `[1, 100 000]`; la profundidad de recursión y las celdas las limita el propio motor.

- **Problema:** En aplicaciones reactivas complejas, la lógica de negocio suele filtrarse al árbol de widgets a través
  de
  llamadas de estado mutable, hooks o proveedores con dependencias cruzadas dentro del método `build`.
- **Elección:** Se adopta `package:bloc` exclusivamente en su modalidad `Cubit`. La unidad de lógica es una clase pura
  en
  Dart dentro de `application/`. El widget recibe un objeto de estado inmutable (`final`) precalculado y solo puede
  emitir
  comandos invocando métodos del cubit (`context.read<Cubit>().accion()`). Se prohíben transformadores de colección (
  `where`, `sort`, `fold`) en la vista; derivar datos es responsabilidad del cubit.
- **Alternativas descartadas y por qué:**
    - *Riverpod:* Descartado porque el objeto `ref` accesible dentro de `build` invita a combinar proveedores y alojar
      lógica de derivación en la interfaz.
    - *`flutter_hooks`:* Descartado porque propicia la mezcla de ciclo de vida de UI con orquestación de datos.
    - *Bloc con eventos:* Descartado porque añade una ceremonia redundante; la traza de eventos de ejecución del
      programa
      ya la produce el núcleo.
    - *`ChangeNotifier`:* Descartado porque el estado mutable notificado dificulta el rastreo determinista y los tests
      unitarios.

### 4.2 La presentación no conoce el núcleo ni la infraestructura

- **Problema:** Permitir que los tipos del compilador (`Span`, `NodeId`, `Diagnostic`, `AstNode`) alcancen los widgets
  crea acoplamiento directo entre el pipeline del motor y la interfaz gráfica.
- **Elección:** `presentation/` tiene vetado importar el transporte del motor y `domain/ports/`. El modelo de la aplicación
  declara sus propios tipos de datos inmutables (`AppDiagnostic`, `SourceRange`, `ProgramNodeId`, `ExecutionStep`,
  `WatchRow`, `DiagramScene`). La capa `engine/` proyecta limpiamente los tipos del núcleo hacia estos modelos sin
  alterar severidades ni mensajes.
- **Alternativas descartadas y por qué:**
    - *Consumo directo de tipos del núcleo en widgets:* Descartado porque un cambio en las estructuras internas del
      compilador forzaría refactorizaciones en cascada en la interfaz.
    - *Paquete intermedio `pseudolearn_ui_model`:* Descartado por añadir sobrecarga de mantenimiento de paquetes en un
      monorepo donde la aplicación es el único consumidor de estos tipos.

### 4.3 Acoplamiento al motor: adaptación de una API pública

- **Problema:** Orquestar análisis y ejecución desde cada pantalla duplicaría reglas del lenguaje.
- **Elección:** `engine/rust/` transforma respuestas de la API en los modelos de los puertos. El puente
  generado es la única frontera nativa. Los validadores de contenido usan las mismas operaciones para
  comprobar diagnósticos, formas bilingües, programas ejecutables y soluciones de ejercicios.
- **Alternativas descartadas:** Un parser local, vocabularios copiados o un intérprete alternativo
  romperían la autoridad del corpus y permitirían comportamientos distintos entre consumidores.

### 4.4 Consistencia visual: clases de dispositivo y lienzo fluido con anchos máximos por contenido

- **Problema:** En Flutter, dos dispositivos con la misma resolución lógica pueden verse dispares si se usan widgets
  adaptativos del sistema operativo o si el lienzo distorsiona los anchos útiles en pantallas panorámicas.
- **Elección:** Se establecen tres clases de dispositivo basadas estrictamente en el ancho lógico de la ventana:
    - `compact`: `< 600 dp` (factor de escala de densidad `1.00`).
    - `medium`: `600 .. 959 dp` (factor de escala de densidad `1.00`).
    - `expanded`: `>= 960 dp` (factor de escala de densidad `1.05`).

  `DesignCanvas` envuelve la aplicación, ocupa toda la ventana y expone sus dimensiones a través de `MediaQuery`. Para
  evitar extensiones excesivas de líneas en pantallas anchas, `AppContentColumn` impone anchos máximos de contenido:
    - `reading`: `680 dp` (compact/medium) / `720 dp` (expanded) — para textos continuos de aprendizaje.
    - `form`: `480 dp` (compact) / `520 dp` (medium) / `560 dp` (expanded) — para formularios sencillos.
    - `wide`: `1080 dp` (compact/medium) / `1440 dp` (expanded) — para listados, ajustes y rejillas.
    - `full`: sin límite — para el editor de código, diagramas y tabla de traza.

  En `compact`, la aparición del teclado virtual (`isKeyboardVisible`) oculta el pie de ejecución y ajusta el visor de
  ejercicios para garantizar visibilidad al editor. La misma señal, con el signo invertido, **hace aparecer** la barra
  de teclas del editor (`EditorKeyBar`) y **colapsa el panel de diagnósticos a su línea de recuento** mientras se
  escribe; el detalle de la decisión está en §4.33. Como el pie desaparece con él, esa misma franja de diagnósticos
  contraída hospeda mientras tanto las dos salidas del modo escritura —ejecutar y ocultar teclado—, según §4.34.
- **Alternativas descartadas y por qué:**
    - *Lienzo de ancho fijo con bandas laterales:* Descartado porque dejaba hasta el 80 % de la superficie sin pintar en
      monitores de 1920 dp.
    - *`flutter_screenutil`:* Descartado por dispersar sufijos escalados (`.w`, `.h`) por todo el código en lugar de
      centralizar la escala por densidad.

> El sistema de tokens de aspecto —color, tipografía, espaciado, radios, elevación, iconografía, movimiento,
> apilamiento y las medidas propias del editor, el ordinograma y la tabla de traza— no vive en este README: está en
> [`docs/fundamentos-visuales.md`](docs/fundamentos-visuales.md), con cada tabla de valores mapeada a su archivo bajo
> `lib/presentation/theme/`.

### 4.5 Navegación adaptativa con punto único de ramificación (`go_router`)

- **Problema:** Adaptar la navegación para móvil (barra inferior) y escritorio (riel lateral) suele fragmentar la
  estructura de rutas.
- **Elección:** Se utiliza `go_router` con `StatefulShellRoute` y un único punto de ramificación en `AdaptiveShell`.
  Consume la lista unificada `destinations.dart`. Conserva el estado de cada pestaña (posición de cursor, scroll del
  editor) al alternar entre destinos. El raíl se compone de dos piezas: la firma de marca (`_RailBrand`), que no es
  interactiva, y los destinos (`_RailDestinations`). Tocar el destino en el que ya se está (`goToShellBranch`) devuelve
  esa rama a su ubicación inicial en vez de no hacer nada: es la convención que la persona espera de una barra de
  navegación, y la única forma de salir de una subpantalla sin retroceder paso a paso.
- **Alternativas descartadas y por qué:**
    - *`Navigator` imperativo manual con `IndexedStack`:* Descartado por requerir código repetitivo y carecer de
      historial de rutas declarativo.
    - *`auto_route`:* Descartado por requerir generadores de código innecesarios para seis rutas cerradas.

### 4.6 Inyección de dependencias: composición estática sin ramas (`AppDependencies`)

- **Problema:** El uso de localizadores globales o contenedores dinámicos permite solicitar dependencias desde cualquier
  punto de la interfaz y oculta el acoplamiento.
- **Elección:** `AppDependencies` declara todas las dependencias en campos `final`. En producción,
  `buildLocalDependencies` recibe un `RustTransport` y ensambla `RustEngineServices`, que implementa
  `EngineServices`. La inicialización nativa ocurre antes de abrir los servicios de la aplicación; los
  fallos se reportan por la frontera de arranque y la sesión se cierra al separar la aplicación. Un fallo de liberación también se reporta y no impide comunicar el fallo original de arranque. No se permite ningún condicional (`if`, `switch`, ternario) en `composition/`. Los tests
  inyectan fakes directamente en el constructor de `AppDependencies`. Los ajustes dinámicos (perfil de sintaxis, idioma
  de interfaz) se pasan como parámetros en los métodos de los puertos.
- **Alternativas descartadas y por qué:**
    - *`get_it`:* Descartado por permitir acceso global desde métodos `build`.
    - *`injectable` / `build_runner`:* Descartado por introducir generación de código para una raíz que se resuelve
      limpiamente a mano.

### 4.7 Organización por capa técnica y por funcionalidad

- **Problema:** Organizar primero por funcionalidad (`features/`) diluye la frontera de verificación de capas
  arquitectónicas y complica el enforcement mecánico de imports.
- **Elección:** La raíz de `lib/` se organiza primero por capa técnica (`domain/`, `engine/`, `data/`, `application/`,
  `presentation/`, `composition/`) y en el segundo nivel por área funcional (`editor/`, `diagram/`, `route/`,
  `library/`, `settings/`). Esto permite validar reglas de dependencia mediante prefijos de ruta simples en los tests de
  arquitectura.
- **Alternativas descartadas y por qué:**
    - *Package-by-feature en primer nivel:* Descartado porque exige reglas complejas de visibilidad entre
      funcionalidades
      y debilita la verificación hexagonal.

### 4.8 Ejecución paso a paso: bombeo cooperativo de eventos (`StepBatchRunner`)

- **Problema:** Avanzar por una traza larga sin ceder el hilo impediría que la interfaz repinte, atienda comandos o
  responda a la acción de detener.
- **Elección:** `ProgramExecution.step()` entrega como máximo el siguiente evento observable y `StepBatchRunner` cede
  al bucle de eventos cada 25 avances. El tamaño del lote solo define cuándo se cede el hilo; no cambia la traza. Los
  comandos de avance se serializan, y `stop` interrumpe el comando activo entre lotes y descarta comandos encolados antes
  de esa detención. La operación no altera la agenda ni activa una tarea seleccionada.

  `StepSettlement` mantiene separados estos comandos y ritmos:
    - `nextEvent`: consume exactamente el evento global siguiente, aunque no cambie el foco.
    - `nextStatement`: avanza hasta el próximo cambio de foco ejecutable.
    - `overBlock`: avanza hasta quedar fuera del bloque inicial y en un nodo distinto.
    - `outOfBlock`: avanza hasta salir del bloque que contiene el foco.
    - `toEnd`: bombea hasta terminar, fallar, esperar una entrada o efecto, o encontrar un límite.
    - `advanceTask(taskId)`: aplica cada evento global, incluidos los de otras tareas, hasta que el contexto activo
      observado después del evento corresponda a `taskId`. Así, seleccionar una tarea lista o suspendida no la reanuda;
      la agenda existente puede ejecutar otras tareas antes de que llegue su siguiente evento.

  Una tarea desconocida o ya terminada no avanza ni produce un paso ficticio. Si la tarea elegida no vuelve a ejecutarse
  antes de la terminación, fallo, espera global de entrada/efecto o límite, se entrega el último estado confirmado. Los
  eventos intermedios se aplican a foco, variables, salida e historial en el orden global, también cuando el lote del
  motor termina esperando una respuesta.

  El tope de 10 000 avances es una protección local de la interfaz para un comando que no alcanza su condición; se
  presenta como tope local y no como límite del lenguaje. Un límite informado por el motor mantiene su estado separado.
  Ninguno de los dos crea eventos ni cambia los límites configurados para el programa.

  Las solicitudes de entrada detienen el bombeo; al recibir el dato, se conserva la condición del comando que esperaba.

  **La agenda no depende de la presentación.** La agenda de tareas es del motor: orden FIFO y cesión por masa
  normativa. La app no la decide. Hay tres relojes que no se mezclan: el bombeo cooperativo (cuándo cede el hilo de la
  interfaz), la animación (cómo se suaviza visualmente una transición ya confirmada) y el tiempo lógico del programa
  (el que el escenario declara). Ni la animación ni el repintado, la selección, el redimensionado o la velocidad piden
  `advance` ni responden efectos: solo los comandos de `ExecutionCubit` llegan a `ProgramExecution.step()`. Leer
  `outputLines`, `projection` o `recordedTape` no llama al motor. Cada llamada síncrona tiene una cota explícita:

  | Frontera | Cota | Dueño |
  |:--|:--|:--|
  | Eventos por `advance` | 25 (`RustProgramExecution.batchSize`) | `rust_program_execution.dart` |
  | Respuestas de efecto por comando | 16 (`RustEffectGate.maxResolutionsPerDrain`) | `rust_effect_gate.dart` |
  | Llamadas al transporte por `step()` | `2 × 16 + 1` = 33 (`advance` y `effect_result`) | consecuencia de las dos anteriores |
  | Avances por comando de interfaz | 25 entre cesiones; tope local 10 000 | `step_batch_runner.dart` |

  Con el bombeo automático, el gate responde las esperas con el anfitrión real hasta 16 veces por llamada; si el
  motor sigue esperando, devuelve un lote en estado `running` y la espera pendiente queda en el motor, que la repite
  idéntica en el siguiente `advance` sin eventos nuevos. Así una ejecución con muchas esperas ya no resuelve todas en una
  sola llamada síncrona. El 16 es un valor de seguridad de la interfaz, no un límite del lenguaje ni un cuanto
  normativo; se verifica con `rust_effect_gate_test.dart` (doble de transporte que cuenta llamadas por comando) y con la
  prueba del puente real «many effects are pumped in bounded commands», que además comprueba las 80 respuestas de una
  traza de 40 lecturas de reloj. La demora de detención es, como mucho, el tiempo de una cesión: `stop` se atiende al
  llegar a la siguiente cesión y los comandos encolados antes de ella se descartan; no se afirma garantía temporal
  desde un test funcional. Medir el máximo de lote observado es contar, por comando, las operaciones `advance` y
  `effect_result` del transporte, tal como hacen esos tests.
- **Alternativas descartadas y por qué:**
    - *Uso de `Isolate`:* Descartado por la sobrecarga de serializar estados de AST y la latencia en repintar el
      resaltado de línea.

### 4.9 Almacenamiento local: archivos `.pseudo` como verdad, SQLite como índice de metadatos

- **Problema:** Si el contenido del programa se almacena en base de datos y archivos a la vez, se producen
  desincronizaciones silenciosas.
- **Elección:** El archivo `.pseudo` en texto plano es la única fuente de verdad. La base de datos SQLite actúa
  exclusivamente como índice y caché de metadatos (título, fechas, revisión, `exerciseId` vinculado). Si la base de
  datos
  se corrompe o borra, `index_rebuild.dart` regenera el índice completo leyendo los archivos de disco.
- **Alternativas descartadas y por qué:**
    - *Guardar el código en SQLite:* Descartado para garantizar que los archivos sean directamente editables y legibles
      fuera de la aplicación.
    - *Almacenes NoSQL (Hive / Isar):* Descartados por competir con los archivos por ser la fuente de verdad.

### 4.10 Foco de ejecución y contextos independientes por tarea

- **Problema:** La traza conserva un orden global, pero cada tarea tiene su propia llamada, foco y variables. Un único
  foco o una pila compartida mezcla dos hijas que ejecutan el mismo subprograma.
- **Elección:** `ExecutionStep` conserva el índice global del evento seleccionado, su tarea activa y una instantánea
  inmutable de `ExecutionTaskContext` por identidad de tarea. Cada contexto tiene estado de tarea, revisión de foco,
  pila de bloques y marcos, variables y el último evento cuyo estado se consultó. El tracker mantiene un contador global
  de foco para los ritmos existentes y uno por tarea para inspección.

  La identidad de una tarea pertenece a una ejecución; la raíz es cero y las hijas nacen con `task_spawned`. El paso por
  tarea compara el índice global consumido con la identidad del contexto activo resultante del evento. Por eso una hija
  creada o lista todavía no recibe un paso propio: el primer límite de su selección es `task_resumed`, cuando pasa a
  ejecutar. Los eventos de otras tareas entre el comando y ese límite también se proyectan; no quedan saltos en salida o
  ventana de eventos. El campo
  `task` de `task_spawned` identifica la hija, no cambia el foco activo. `task_ready` tampoco selecciona una tarea;
  solo `task_resumed` cambia el contexto activo. Los eventos ordinarios pertenecen a la última tarea reanudada y, antes
  de la primera, a la raíz. Cada pila se crea vacía para su tarea y los límites de llamada solo modifican esa pila.
  Al terminar globalmente, la raíz conserva pila/foco/variables: queda `completed` con `success` si termina bien,
  `failed` con el motivo si hay una trampa, `cancelledByHost` ante un corte explícito del anfitrión, o `limitReached`
  si se agota el límite del motor. Una espera global no finaliza la raíz.

  | Evento | Contexto que actualiza | Efecto en el foco y la pila |
  |---|---|---|
  | `statement_entered`, `statement_exited`, `decision`, `call`, `return`, salida y entrada | La última tarea reanudada; la raíz antes de la primera | Solo cambia el contexto dueño; los eventos de control refrescan variables en el índice global consumido |
  | `task_spawned` | `data.task` nace en `created` sin marco; el padre conserva el índice del evento | No cambia la tarea activa ni hereda foco o pila |
  | `task_ready` | `data.task` pasa a `ready` | No cambia la tarea activa |
  | `task_resumed` | `data.task` pasa a `running` | Selecciona ese contexto y refresca sus variables; un cambio de tarea aumenta la revisión global de foco. Si la tarea tenía la cancelación pedida y ya no es consultable, conserva su último entorno |
  | `task_suspended` | `data.task` pasa a `suspended` | Conserva foco, pila y variables para consultar ese evento global |
  | `task_completed` | `data.task` conserva estado `completed` y resultado | Conserva su última pila, foco y variables |
  | `task_cancel_requested` | `data.task` conserva `cancellationRequested`; `data.origin` señala quién pidió cancelarla | No selecciona la tarea cancelada |
  | `scope_joined` y `channel_*` | La tarea indicada por `scope_joined`; la activa para los eventos de canal | Actualiza el último evento sin cambiar foco o pila |
  | `effect_delivered` | La tarea receptora de `data.task` | Actualiza su último evento sin reanudarla |

  `RustEvent` conserva `revision_id`, identidad opcional de proyecto/fuente y `node_id`. Un evento cuya revisión no
  coincide con la vista activa se rechaza como secuencia inválida. La selección de una tarea consulta `query_frame` y
  `query_page` en el índice global elegido mediante `task_id`; no reanuda la tarea ni altera la agenda. Las consultas
  al pasado siguen ligadas al mismo evento después de avanzar. Un lector que inicie una ventana en un índice distinto
  de cero debe reconstruir la atribución y los contextos desde la historia retenida anterior; no puede asumir la raíz.
  La ejecución actual comienza en el evento cero.

  Los errores de consulta de estado se representan como fallos del paso, no como una tabla vacía, con una única
  excepción. Cuando falla una tarea de un ámbito `Tareas`, el motor reanuda cada hermana con cancelación pedida para que
  termine su cancelación: emite `task_resumed` y, si la hermana no tiene limpieza pendiente, `task_completed` con
  `cancelled` en la misma instrucción. El estado de un evento es el del instante posterior a su instrucción, y
  `query_frame` con `task_id` solo responde para tareas activas o suspendidas, así que en ese `task_resumed` la hermana
  ya no es consultable y el motor responde con un error de uso. Es conducta normativa del motor, no un defecto. Por eso
  `RustWatchRows` distingue `RustEnvironmentUnavailable` (uso en el primer marco) de un fallo de consulta, y
  `RustExecutionEventConsumer` lo acepta sin detener el paso solo cuando `RustFocusTracker.isResumingCancelledTask`
  indica que el evento recién aplicado reanudó una tarea con cancelación pedida. Esa tarea conserva su último entorno.
  Cualquier otra tarea no consultable sigue deteniendo el paso con `task_state_unavailable`. La ejecución completa no
  consulta estado y no pasaba por este camino; antes de esta excepción el modo paso a paso se detenía
  (`programHalted`) cuando la tarea que fallaba no era la última en terminar.

  La identidad de nodo solo enlaza con la vista de su revisión; nombres, líneas y profundidad no identifican una tarea
  ni un marco.

  Las superficies de trabajo (editor, diagramas, tabla de traza y código equivalente) sincronizan el nodo de foco sin
  recalcular análisis independientes. Conservan el mismo modelo `ExecutionFocus`:
    - En el **editor**, resalta la línea física en el canalón y el tramo de texto correspondiente.
    - En el **ordinograma**, resalta el símbolo activo y la arista correspondiente a la rama evaluada (
      `ExecutionBranch`).
    - En el **estructograma**, resalta la celda activa.
    - En el **diagrama de clases**, resalta la fila del método o constructor en ejecución.
    - En la **tabla de traza**, abre una fila en el paso actual mostrando las variables modificadas y el receptor
      `Este`.
    - En **código equivalente**, resalta las líneas generadas asociadas al nodo de origen.

  `API.PROGRAM.VIEW` y los eventos comparten revisión e identidad estructural. El adaptador normaliza
  nodos semánticos hacia su sentencia visible; las decisiones resaltan solo la cabecera y la entrada
  de un contenedor no crea una parada adicional. Las páginas de estado consultan el evento global consumido y la tarea
  elegida.
- **Alternativas descartadas y por qué:**
    - *Sincronización mediante eventos en `presentation/` (BlocListener cruzados):* Descartado porque introduce
      orquestación en la interfaz y produce desincronizaciones de estado.

### 4.11 Código equivalente (Python y Rust)

- **Problema:** Enseñar programación estructurada, orientada a objetos y concurrente requiere contrastar el
  pseudocódigo con implementaciones en lenguajes industriales sin depender de herramientas externas, y el código
  mostrado tiene que ser realmente equivalente.
- **Elección:** La traducción pertenece al núcleo. `RustProgramExporter` (`engine/rust/export/`) lee primero la vista
  del programa; si el análisis tiene errores, incluidas las dependencias sin enlazar, responde error de análisis sin
  invocar otra operación (`API.PROGRAM.VIEW#R16`). Si no, crea un documento, llama a la operación `equivalent_code`
  del puente con el destino y libera el documento. El núcleo traduce el programa analizado completo desde su
  representación tipada y responde `ready` (código y nodo de origen de cada línea), `unavailable` (construcciones
  pendientes con su nodo) o `analysis_error`. La app antepone la línea de cabecera (`targetCodeHeader`), convierte los
  nodos en `ProgramNodeId` y toma de la vista el rango de cada construcción pendiente. Las decisiones de traducción, las correspondencias de cada
  construcción y sus pendientes viven en el README de `pseudolearn_transpiler`.
- **Código equivalente honesto (`API.PROGRAM.VIEW#R17`/`R18`):** el destino Python exige 3.11 y el destino Rust la
  edición 2024; ambos usan solo su biblioteca estándar. Si alguna construcción queda pendiente, no se entrega un
  programa parcial: la pestaña muestra el mensaje localizado con las construcciones y la línea de la primera. Cada
  revisión nueva reemplaza el resultado y limpia código y líneas de foco anteriores.
- **Evidencia:** El barrido diferencial del núcleo (`pseudolearn_api/tests/equivalent_code_sweep.rs`) ejecuta cada
  caso `execute` del corpus en el motor, compila o interpreta la traducción y compara la salida byte a byte. En los
  casos de `lang.*` que terminan con normalidad, Python reproduce 748 de 812 y Rust 730 de 812; el resto son
  capacidades, que dependen del anfitrión, o diferencias registradas en el README del traductor. `test/engine/rust/export/rust_program_exporter_test.dart` comprueba el
  contrato por el puente real.
- **Alternativas descartadas y por qué:** Emisores en Dart sobre la vista del programa. Reconstruían en la app los
  tipos que el motor ya resuelve, y cada construcción nueva exigía duplicar semántica. Por eso casi ningún programa
  con tareas, variantes o clases tenía equivalente. Se retiraron junto con su prueba diferencial en Dart.

- **Diagramas con errores semánticos:** La vista estructural permite representar clases o controles
  cuando hay errores semánticos, incluidos ciclos de herencia, siempre que la sintaxis sea válida.
  Los exportadores y la ejecución siguen exigiendo análisis válido. Se evita ocultar justamente la
  estructura que la persona necesita inspeccionar para corregir el error.

### 4.12 Fundamentos visuales y sistema de diseño

Toda la apariencia visual se rige estrictamente por los tokens declarados en `presentation/theme/tokens/`:

1. **Color y Paleta Primitiva (Espacio OKLCH):**
    - Escala neutral: 15 pasos calibrados por luminosidad y croma reducido para superficies y textos; el modo oscuro
      necesita resolución fina cerca del extremo inferior y por eso tiene más pasos que las demás.
    - Escala de marca (`brand`): 11 pasos en teal, tono 200°. El tono está elegido por descarte geométrico —es el centro
      del mayor hueco angular que dejan los cuatro tonos ya comprometidos con error, advertencia, acierto e
      información—,
      y su croma máxima es 0.085, alrededor de la mitad que una escala de señal: es color de tinta, no de aviso. De ella
      salen el foco, el enlace, la acción primaria, el indicador de navegación y las dos tintas de marca (`brandInk`,
      `brandPlate`).
    - Semánticos funcionales: Éxito (esmeralda), Advertencia (ámbar), Error (rosa/rojo), Información (celeste).
    - Resaltado sintáctico: Colores específicos de contraste verificado para palabras clave, tipos, identificadores,
      literales numéricos, literales de texto, operadores y comentarios.
    - Marcas de terceros: Las primitivas de Sign in with Apple son las únicas fuera de las escalas propias. Existen
      porque
      las directrices de Apple fijan sus valores; ninguna otra superficie las consume.
    - Accesibilidad: Todo par texto/superficie satisface un ratio de contraste mínimo de `4.5:1` (WCAG AA) y `3.0:1`
      para
      componentes gráficos grandes.
2. **Tipografía:**
    - Rol de interfaz (`ui`): `IBMPlexSans` (empaquetada en `assets/fonts/`), con reserva en la pila del sistema.
    - Rol de código (`code`): `IBMPlexMono` (empaquetada en `assets/fonts/`), con espaciado monoespaciado estricto para
      canalón, editor y rótulos de diagramas.
    - Escala tipográfica unificada: `display`, `headline`, `titleLarge`, `titleMedium`, `titleSmall`, `bodyLarge`,
      `bodyDefault`, `bodySmall`, `caption`, `codeDefault`, `codeSmall`, `codeCaption`.
3. **Espaciado y Radios:**
    - Cuadrícula base de 4px: `xxs` (2px), `xs` (4px), `sm` (8px), `md` (12px), `lg` (16px), `xl` (24px), `xxl` (32px),
      `xxxl` (48px).
    - Radios de borde: `none` (0), `xs` (2px), `sm` (4px), `md` (8px), `lg` (12px), `xl` (16px), `full` (9999px). La
      escala es cerrada: la única medida de la app fuera de ella es la esquina de la placa de marca (22.37 % del lado),
      que reproduce la del ícono del sistema operativo y está declarada como excepción.
4. **Elevación y Movimiento:**
    - Sombras tenues en modo claro y bordes sutiles en modo oscuro para jerarquía de profundidad.
    - Duraciones estándar: Rápida (100 ms), Normal (200 ms), Lenta (350 ms). Respeto automático a la directiva de
      reducción de movimiento del sistema operativo.
    - Duración de gráficos (`MotionSpeed.chart`, 900 ms): solo para la entrada de los gráficos del panel de progreso,
      donde el crecimiento del dato es el contenido y no una transición; con movimiento reducido vale cero.
5. **Capas de Apilamiento (Z-Index):**
    - `canvas` (0), `content` (1), `sticky/header` (10), `overlay/dropdown` (20), `modal/dialog` (30), `tooltip/toast`
      (40).

### 4.13 Especificación de pantallas y navegación

- **Biblioteca (`LibraryPage`):** Dos pestañas, «Algoritmos» y «Ejercicios», bajo un título sin acciones. Algoritmos:
  gestión de documentos personales, filtrado por búsqueda de texto, creación con nombres sugeridos mediante diálogo
  modal y eliminación/renombrado seguro. Ejercicios: los ejercicios propios (§4.64). La pestaña activa es estado de
  la página, no de un cubit, porque no sobrevive a la navegación ni la necesita nadie más.
- **Documento (`DocumentPage`) · Armazón de cuatro pestañas:**
    - Cabecera con título, perfil de sintaxis y estado de sincronización.
    - Franja plegable de ejercicio (`ExerciseStrip`) si el documento procede de la base de conocimiento. Su cabecera
      es una sola línea (título, nivel y píldora de casos `n/m` o «Superado»); el cuerpo (tipo, enunciado, casos
      visibles y, si falló, el detalle del fallo) arranca plegado cuando el ejercicio ya está superado (§4.61).
    - Cuatro pestañas conmutables: Editor (`EditorPage`), Diagramas (`FlowchartTabView`), Tabla de prueba de
      escritorio (`TraceTablePage`) y
      Código equivalente (`ExportPage`).
    - Pie de ejecución interactivo con control de avance didáctico en cuatro ritmos, salida del programa con píldora
      de resultado y un único acceso `⋯` a las opciones de ejecución (argumentos, repetir la última ejecución y
      carpeta de archivos). El pie no narra estado ni cuenta sentencias (§4.61).
    - Disposición acompañante (`CompanionLayout`): muestra el editor junto al diagrama o tabla en modo vertical (
      `below`, 3:2) en `compact`/`medium`, y horizontal (`beside`, 1:1) en `expanded`.
- **Introducción interactiva (`OnboardingPage`):** Flujo de cuatro pasos (Bienvenida, Laboratorio en vivo de solo
  lectura con motor de
  diagramas y traza real, Métricas vivas de la Base de conocimiento y Cierre con doble salida a biblioteca o ruta de
  aprendizaje). El paso de bienvenida abre con el símbolo de la marca sobre el título que dice el nombre (§4.35).
- **Base de conocimiento (`KnowledgePage`) y Detalle (`RouteLessonPage`, `RouteExercisePage`, `ReferenceSectionPage`):**
  Tres secciones fijas (Ruta de aprendizaje, Especificación publicada, Banco de ejercicios). Lección en
  `/conocimiento/ruta/:leccion`, ejercicio en `/conocimiento/ruta/:leccion/:ejercicio` y lector de la especificación ilustrada en `/conocimiento/especificacion/:id`, con índice lateral en
  pantallas anchas y hoja inferior en las demás (§4.62).
- **Ajustes (`SettingsOverviewPage`):** Armazón con medida `wide` y distribución en dos columnas en clase `expanded`.
  Subpantallas de
  Idioma, Tema, Diagramas y Contacto integradas con botón de retroceso accesible en la cabecera. El pie
  (`VersionFooter`)
  cierra con el lockup horizontal sobre la línea de versión, que ya no repite el nombre del producto porque lo dice el
  lockup. La hoja de Contacto lo lleva como membrete del documento.
- **Panel de progreso (`DashboardPage` / `DashboardView`):** Cuarto destino de navegación (`/progreso`). Armazón
  `AppPage` con medida `wide` y distribución adaptable (dos columnas en clase `expanded`, columna única en `compact`/
  `medium`). Operativo al 100 % con datos locales sin requerir sesión iniciada. La cabecera es la del armazón común; el
  cuerpo presenta nueve tarjetas gráficas alimentadas exclusivamente por proyecciones desacopladas de
  `application/dashboard/`. Columna principal: resumen (`OverviewCard`: tres anillos concéntricos de lecciones
  completadas, ejercicios resueltos y conceptos usados, porcentaje de ruta completada en el centro y tres indicadores
  —algoritmos, semanas activas de la ventana y ejercicios resueltos con ayuda—), siguiente paso (`NextStepCard`, con la
  tira segmentada de ejercicios obligatorios resueltos de la lección sugerida y la regla que la completa), recorrido de
  la ruta (`RouteMapCard`: un punto por lección unido por un trazo, coloreado por estado —completada, en curso, sin
  empezar—, la lección sugerida rodeada y cada punto abre su lección) y ejercicios (`ExercisesCard`: tres medidores
  circulares por nivel y un radar por tipo de ejercicio). Columna secundaria: actividad semanal (barras apiladas de
  lecciones abiertas, ejercicios resueltos y algoritmos creados en una ventana fija de 8 semanas), biblioteca (anillo
  repartido por perfil de sintaxis), conceptos ejercitados y cobertura de la especificación (nubes de fichas marcadas) y
  salud de sincronización. Los gráficos se pintan con `CustomPainter` propios en `presentation/dashboard/charts/`.
- **Cuenta (`AccountPage` / `AccountView`):** Subpantalla de Ajustes (`/ajustes/cuenta`) con armazón estándar y botón de
  retroceso en cabecera. Sin sesión iniciada, presenta explicación contextual de sincronización y botones de acceso
  (`SignInOptions`) priorizando Apple con la variante de marca `brandApple` (directriz 4.8 de App Store), Google y
  enlace por correo sin contraseña. Con sesión iniciada, muestra el avatar del usuario (`AccountAvatar`: fotografía
  remota del proveedor cuando la sesión la aporta, monograma de iniciales deterministas sobre fondo de acento cuando el
  nombre o la dirección empiezan por letra, y glifo neutro cuando ninguno lo hace), identidad con aclaración explícita
  cuando la dirección es un reenvío privado de Apple, estado reactivo de sincronización, acción manual "Sincronizar
  ahora", listado de dispositivos vinculados con etiqueta de sistema editable y las tres acciones de sesión
  (`SessionActions`) segregadas por jerarquía visual («Cerrar sesión», «Cerrar sesión y borrar datos de este
  dispositivo» tras confirmación modal, y «Eliminar cuenta» con diálogo destructivo de confirmación). «Eliminar
  cuenta» invoca `AccountDeletionGateway.deleteAccount()`, que llama a la Edge Function `delete-account` del backend;
  mientras dura, la tarjeta muestra «Eliminando cuenta...» con las tres acciones deshabilitadas
  (`AccountDeletingAccount`). Si el servidor no confirma, la sesión sigue visible con un aviso según el código de
  fallo y la acción reintentable (`AccountDeletionFailed`); los datos del dispositivo solo se purgan tras la
  confirmación (decisión 4.42).
- **Diálogos modales:** Creación de documento con selección de perfil (`NewDocumentDialog`), Confirmaciones
  destructivas (`ConfirmationDialog`), Entrada interactiva de datos durante la ejecución (`DataInputDialog`), y acceso
  por enlace mágico (`SignInOptions`). Todo diálogo modal se acota geométricamente mediante
  `DialogMetricsTokens.minWidth`
  (280 dp) y `DialogMetricsTokens.maxWidth` (480 dp, correspondiente a la cota base de formulario `formMax`) para evitar
  que los formularios se estiren excesivamente en pantallas de escritorio y medianas.

### 4.14 Catálogo de componentes y reglas de interfaz

0. **Componentes de marca (`presentation/brand/`):** Fuera del catálogo de interfaz a propósito, porque la marca no es
   un
   elemento de interfaz y no se combina con los demás (§4.35).
    - `BrandSymbol`: la figura sola, en una sola tinta, decorativa ante el lector de pantalla. Se dimensiona por su caja
      de tinta cuadrada, no por una rejilla de íconos.
    - `BrandWordmark`: el logotipo compuesto con las dos caras empaquetadas. Se mide por su caja de tinta y coloca su
      línea base midiendo la del texto real en cada pintado, no con métricas verticales copiadas.
    - `BrandLockup`: las dos únicas composiciones autorizadas (`horizontal` y `vertical`), con la placa de degradado, la
      esquina continua del ícono y el espacio libre obligatorio incorporado como relleno propio, para que ningún punto
      de
      uso pueda olvidarlo.

1. **Formas base reutilizables:**
    - `AppCard` / `AppCardSurface`: Contenedores con radio `radiusMd`, elevación sutil y borde semántico.
    - `AppTextField` / `AppSearchField`: Entradas de texto homologadas con soporte de teclado, validaciones de error y
      borrado rápido. Ofrecen dos variantes de tamaño: estándar (48 dp) y compacta (36 dp, empleada en controles de
      cabecera como `InlineTitleField`). Ambas variantes comparten un relleno horizontal de 12 dp
      (`FieldMetricsTokens.paddingHorizontal`) que supera holgadamente el radio de 8 dp del borde, garantizando que el
      cursor (`caret`) y el texto inicien en la zona plana interior sin colisionar con la curvatura del contorno. La
      variante compacta emplea un relleno vertical de 6 dp para aislar el cursor de los bordes superior e inferior.
    - `AppListItem`: Filas de una sola línea con icono opcional, etiqueta flexible y valor acotado en cola.
    - `AppDialog` / `AppConfirmationDialog`: Modales accesibles con foco atrapado y botones de acción, restringidos a
      la cota de ancho máximo de diálogo (`DialogMetricsTokens.maxWidth`).
    - `AppButton`: Tres variantes estrictas según prioridad: `primary` (fondo acento), `secondary` (borde sutil) y
      `ghost` (sin fondo). Variante `AppIconButton` para barras de herramientas.
    - `AppText`: Tipografía vinculada a la escala semántica de tokens.
2. **Componentes especializados:**
    - `CodeField`: Editor monoespaciado con resaltado sintáctico, canalón de líneas estático sin saltos de línea
      suaves (*soft-wrap*), desplazamiento vertical del documento completo y desplazamiento horizontal independiente.
      El campo de texto no captura el gesto vertical, que controla el contenedor del editor. Aísla completamente su
      `InputDecoration` con
      `InputBorder.none` en todos los estados para evitar que el tema global de formularios de Material le inyecte
      contornos de recuadro; el foco se expresa exclusivamente mediante el fondo de la línea activa y el cursor del
      editor. **Recibe** su `HighlightController` desde fuera; no lo crea, porque el cursor tiene que ser alcanzable por
      quien inserta texto en él.
    - `CodePreview`: Envoltorio de solo lectura de `CodeField` para las superficies que muestran código sin editarlo
      (código equivalente, bloques de la base de conocimiento, actividades de predicción y demo guiada). Es dueño de su
      propio controlador porque ahí nadie necesita el cursor.
    - `EditorSurface`: Dueño del `HighlightController` y del `FocusNode` del editor. Compone campo, panel de
      diagnósticos y barra de teclas, lee el cursor en el momento de la pulsación y aplica la edición pendiente cuando
      cambia su revisión.
    - `EditorKeyBar`: Barra de teclas anclada al pie del editor. Fila fija de siete teclas derivadas del léxico del
      perfil, sin desplazamiento horizontal, con etiquetas accesibles en `l10n/`; una tecla de despliegue en el extremo
      izquierdo abre la segunda fila con las plantillas de estructura (`EditorTemplateRow`), que sí se desplaza.
    - `EditorKeyCap`: Cara de una tecla de la barra, con el lexema visible y la etiqueta accesible que dice qué inserta.
    - `EditorDiagnosticsStrip`: Franja de diagnósticos del editor. Mientras el pie de ejecución está oculto por el
      teclado, llena el hueco `trailing` del panel con `KeyboardExitActions` y absorbe el toque fuera del campo para
      soltar el foco (§4.34).
    - `KeyboardExitActions`: Las dos salidas del modo escritura, ejecutar hasta el final y ocultar teclado.
    - `EditorKeyShortcuts`: `Tab`, `Mayús`+`Tab` y `Esc` sobre el editor en escritorio, contra el mismo puerto que usan
      las teclas dibujadas.
    - `AppSectionTabs`: Pestañas de sección a todo el ancho con indicador inferior y recuento opcional. Las usan la
      Base de conocimiento y la Biblioteca, para que cambiar de sección se vea igual en ambas.
    - `StatusBanner`: Avisos descartables de sincronización (`SyncBanner`). Sin margen lateral propio: ocupa el ancho
      de la columna de contenido que lo aloja, como cualquier otro bloque del cuerpo. El editor ya no lo usa: el resultado de
      una ejecución lo dice `RunResultPill` (§4.61).
    - `RunResultPill` y `RunOutcomeNote`: Píldora de resultado en la cabecera de la salida y línea final explicativa
      en el cuerpo de la salida; ambos leen el único mapeo `runOutcomeOf` de estado de ejecución a presentación.
    - `RunOptionsButton` y `ExecutionOptionsSheet`: Botón `⋯` del pie, con marca cuando hay argumentos definidos, y
      hoja inferior con argumentos, repetición de la última cinta y carpeta de archivos del documento.
    - `KeywordHelpChip` y `SyntaxHelpSheet`: Chip `?` sobre la palabra clave en la que reposa el cursor y hoja
      inferior con la ficha de ayuda (§4.53).
    - `DiagramNotationSwitch`: Conmutador adaptativo al ancho del panel (`>= 760 dp` botonera segmentada; `< 760 dp`
      menú
      desplegable).
    - `TraceTable`: Tabla interactiva con celda resaltada, diferencias respecto al paso anterior e insignias de
      identidad
      numérica de objetos.
    - `ProgramOutputPanel`: Consolidación de fragmentos de salida en líneas de texto estructuradas.

### 4.15 Motor de ordinogramas: composición recursiva serie-paralelo, carril de retorno y cámara interactiva

- **Problema:** Dibujar ordinogramas anidados mediante posicionamiento plano produce superposición de aristas en bucles
  complejos y mediciones inconsistentes entre sistemas operativos.
- **Elección:** El trazado (`engine/diagram/`) se implementa como composición recursiva serie-paralelo. Cada bloque
  sintáctico genera un `LayoutBlock` con dimensiones exteriores, eje vertical central (`spineX`) y marcas de
  conectividad (`hasExit`, `entryId`, `exitId`).
    - **Carril reservado de retorno:** Los bloques de bucle (`Mientras`, `Repetir`, `Para`) calculan una anchura que
      reserva un carril lateral exclusivo para la arista de retorno, evitando cualquier colisión con el cuerpo interno.
    - **Bucle `Para` como nodo único:** El bucle contado se modela como un hexágono de preparación indivisible con
      variable, rango y paso, garantizando correspondencia 1:1 con la línea del editor.
    - **Cálculo de texto determinista sin tipografía:** La anchura de los rótulos se calcula como cota superior
      analítica
      clasificando caracteres (estrechos, anchos, regulares), garantizando que el diseño sea determinista e idéntico en
      cualquier máquina sin invocar `TextPainter`.
    - **Soporte multiarea POO:** `DiagramProgram` contiene múltiples `DiagramUnit` (algoritmo principal, subprogramas,
      constructores y métodos), permitiendo alternar de escena mediante un selector.
    - **Cámara interactiva asistida (`DiagramCameraAnimator`):** Calcula la traslación y zoom suave hacia el rectángulo
      del nodo activo (`FocusFrameProjection`). Si el usuario interactúa manualmente con el lienzo, la asistencia cede
      el
      mando temporalmente.
- **Alternativas descartadas y por qué:**
    - *Medición dinámica con fuentes del sistema:* Descartada porque variaciones mínimas de renderizado en diferentes
      plataformas desalinearían las aristas de los diagramas.

### 4.16 Motor de estructogramas (Nassi-Shneiderman): composición de celdas en dos pasadas y pintado sin suavizado

- **Problema:** Los estructogramas no utilizan ejes verticales ni aristas de conexión; modelan la computación encajando
  celdas rectangulares contiguas.
- **Elección:** `engine/structogram/` define su propio árbol de celdas (`StructogramBlock`). Se calcula en dos pasadas
  deterministas:
    1. *Ascendente (Bottom-Up):* Determina la anchura mínima acumulada y la altura natural de cada celda con el texto
       pre-partido.
    2. *Descendente (Top-Down):* Distribuye la anchura total disponible entre las columnas de condicionales y fija las
       coordenadas absolutas.

  Para evitar que las líneas divisorias compartidas entre celdas contiguas sufran doble oscurecimiento por mezcla alfa,
  el renderizado se realiza con trazado nítido sin suavizado en los bordes. Se respeta la regla de anchura mínima
  estricta: los condicionales anidados expanden el lienzo horizontalmente sin recortar texto.
- **Alternativas descartadas y por qué:**
    - *Reutilizar `LayoutBlock` de ordinogramas:* Descartado porque los campos de aristas, espaciados y ejes carecen de
      sentido en una notación puramente jerárquica de celdas compartidas.

### 4.17 Diagrama de clases UML: modelo multinodo, rejilla de columnas, ruteo ortogonal y evasión

- **Problema:** En programas orientados a objetos, representar relaciones de herencia y asociación sin solapamientos
  entre
  cajas ni cruces caóticos requiere reglas geométricas rigurosas.
- **Elección:** Se implementa un trazador UML ligero acotado al lenguaje:
    - **Caja multimnodo:** La caja de la clase se descompone en un nodo contenedor para la estructura y nodos
      individuales
      para cada atributo y método. Esto permite que el foco de ejecución resalte exactamente la fila del método en
      curso.
    - **Rejilla de columnas con centrado entero:** Las clases se agrupan en niveles según su profundidad en el árbol de
      herencia. Las cajas se posicionan sobre una rejilla horizontal uniforme, dejando corredores verticales continuos
      entre columnas.
    - **`boxGap` con suelo dinámico:** La distancia horizontal entre cajas parte de un mínimo base (`64.0 dp`) y se
      amplía
      automáticamente según la anchura máxima de las etiquetas de asociación.
    - **Ruteo ortogonal con evasión de obstáculos:** Las relaciones de generalización (herencia) se trazan primero
      uniendo troncos comunes hacia la superclase. Las asociaciones se rutean secuencialmente buscando corredores libres
      directos, bandas intermedias o contornos exteriores mediante puntos de anclaje ordenados (`RelationAnchors`),
      evitando colisiones y solapamientos.
    - **Protección contra herencia cíclica:** Se emplea un conjunto de nodos visitados; ante ciclos de herencia en
      programas inválidos, el algoritmo interrumpe el ciclo y dispone las clases en el mismo nivel sin caer en recursión
      infinita.
- **Alternativas descartadas y por qué:**
    - *Ruteo mediante fuerzas elásticas o grafos genéricos:* Descartado por ser no determinista y generar líneas
      diagonales contrarias al estándar ortogonal de UML.
- **Accesibilidad y foco:** `ClassDiagramAccessibility` deriva los elementos semánticos de la escena, incluidos
  nombre, firma, relación, invalidez y diagnósticos. El lienzo permite recorrerlos con Tab y activarlos con Enter,
  espacio, toque o acción Semantics; el foco de teclado se dibuja con un borde primario de 2 dp. Los nombres completos
  siguen disponibles aunque una caja recorte visualmente la firma, y cada selección conserva el rango fuente del
  mismo nodo accesible.
- **Observación de escenas inválidas:** el sujeto SEE deriva `invalid_accessible_relations` de los elementos accesibles
  de la escena nativa; expone relación, diagnóstico, presencia del rango fuente y tamaño del hit target. Los casos
  `API.PROGRAM.VIEW` C21, C42, C44, C45 y C47 contrastan esas observaciones, incluido el destino de 24 × 24 dp. La app no
  duplica la geometría ni prepara respuestas de conformidad por adelantado.
- **Evidencia:** `class_diagram_semantics_layer_test.dart` comprueba navegación y activación en un lienzo compacto con
  escala de texto 2; `class_diagram_layout_test.dart` y `class_shapes_test.dart` cubren ruteo y límites; los tests
  `rust_class_diagram_integration_test.dart` atraviesan FRB nativo, selección por Semantics, ayuda de clase y liberación
  balanceada de recursos. `see_app_class_diagram_test.dart` valida la observación viva de escenas válidas e inválidas.

### 4.18 Ruta de aprendizaje: lector de un segundo paquete generado

- **Problema:** la base de conocimiento anterior —quince módulos en Markdown y JSON bajo `assets/knowledge/`, con
  marcadores que la app resolvía y un verificador propio (`tool/check_content.dart`)— repetía en la app un trabajo de
  compilación que ya hace `packages/pseudolearn_reference` para la especificación. Sus programas no se ejecutaban al
  publicar, sus ejercicios solo admitían escribir código y no había forma de comprobar que las respuestas coincidieran
  con el motor.
- **Elección:** la ruta es el segundo libro de `packages/pseudolearn_reference`. El compilador la ejecuta y verifica
  (`RUTA-*`) y escribe en `assets/route/<idioma>/<perfil>/` un paquete ya resuelto: `toc.json` (partes, lecciones y
  ejercicios con tipo, nivel y obligatoriedad), `lessons/<id>.json`, `exercises/<id>.json`, `terms.json`,
  `spec-links.json` y `manifest.json`. La app solo lo lee:
    - `domain/model/route/` modela índice, lección con bloques compartidos y propios de la ruta, ejercicio con su
      evaluación tipada (predecir, rastrear, ordenar, casos, romperlo, diseñar pruebas, clasificar, elegir),
      respuesta y veredicto. El puerto `RouteRepository` lo abstrae y `data/route/BundledRouteRepository` lo lee de
      `rootBundle`, con `ContentLoadFailure.malformedRoute` ante un JSON inválido.
    - `engine/route_exercise/` tiene un evaluador por forma de respuesta, todos detrás del puerto
      `RouteAnswerEvaluator`; `composition/route_evaluators.dart` arma el mapa tipo → evaluador. Los que ejecutan
      programas del estudiante (`romperlo`, `disenar-pruebas`, `ordenar`) usan `ProgramRunner`, el mismo ejecutor de
      `BehaviourChecker`. Los ejercicios que escriben código (`encontrar-error`, `modificar`, `resolver`) se abren en el
      editor y los comprueba la sesión de ejercicio de §4.19.
    - `application/route/` tiene un cubit por pantalla (índice, lección, ejercicio, banco) y `RouteProgress` con las
      identidades de §4.25. El banco es una proyección del índice filtrada por parte, tipo y nivel, no un catálogo
      aparte. Una lección abierta queda «En curso» y solo se completa al resolver todos sus ejercicios obligatorios
      (o al abrirla si no tiene ninguno); los opcionales no cuentan. Como esa regla no se ve desde fuera,
      `RouteProgress.requiredExercisesOf` da el recuento de obligatorios resueltos y `RouteIndexState` lo lleva por
      lección: la tarjeta del índice añade «Obligatorios resueltos: N de M» mientras la lección no está completada. Un
      recuento suelto («2 de 3») no decía qué contaba ni para qué servía, así que la regla se enuncia también en dos
      lugares: `RouteCompletionRule` encabeza el índice y `PracticeRequiredHint` encabeza la lista de práctica de una
      lección que tiene obligatorios (`LessonScope.hasRequiredExercises`). El borde resaltado de una tarjeta marca la
      lección sugerida —la primera sin completar cuyas lecciones previas lo están—, no la lección abierta más reciente.
    - El índice y el banco se proyectan de nuevo cuando cambia el progreso, sin esperar a reabrir la app: la pestaña de
      la ruta queda viva debajo de la lección y del ejercicio, y al volver mostraba la proyección de cuando se cargó.
      `PublishingProgressStore` (`application/route/`) decora `LocalProgressStore` como `ReviewPromptingProgressStore`:
      persiste la marca en el almacén interno y después publica en `ProgressUpdates`, un flujo de difusión sin carga.
      Un fallo al persistir no publica. `RouteIndexCubit` y `RouteBankCubit` reciben ese flujo como `progressChanges`
      (vacío por omisión) y lo atienden con `refresh`, que reproyecta la última edición sin emitir el estado de carga
      —sin parpadeo del esqueleto— y conserva el filtro del banco; antes de la primera carga no hace nada y al cerrar
      el cubit se cancela la suscripción. La composición coloca el decorador por fuera del de reseña, así que ninguna
      sesión de ejercicio sabe que el índice escucha. El progreso que llega por sincronización entra por SQL y no
      publica: se ve al recargar la pestaña, igual que antes.
    - `presentation/route/` es el lector: bloques de lección, avisos de la ruta, tira del ciclo, panel de respuesta por
      tipo y enlaces. Un enlace `ruta:<lección>` abre otra lección; un enlace de especificación abre su sección en el
      lector de §4.62. Al pedir la respuesta de un ejercicio, `ExerciseReveal` muestra su explicación y su variante, y
      nada más: la app no distingue roles, así que no hay sección «Para docentes» ni `ReferenceCalloutKind.teachers`.
      Un paquete antiguo que todavía publique ese tipo de recuadro se lee como una nota, igual que cualquier tipo
      desconocido.
    - El camino de vuelta, de la Especificación a la ruta, sale de `spec-links.json`: `RouteSpecLinksCubit` cruza ese
      mapa con el índice una vez por edición y deja, por sección, las lecciones que la enlazan en el orden del archivo,
      descartando identidades que el índice no publica. `presentation/reference/reference_route_links.dart` las pinta
      como «Aprender en la ruta» al pie de la sección (el lector recibe el pie como un `Widget` opcional, sin conocer la
      ruta). Sin proveedor del cubit, o si el paquete de la ruta falta, el pie no se dibuja: la Especificación se lee
      igual.
- **Inventario de la retirada:** se borraron `assets/knowledge/`, `lib/data/knowledge/`, `lib/engine/knowledge/`,
  `lib/application/knowledge/`, la vista de módulo y sus ilustraciones, el puerto `KnowledgeRepository`, la cadena de
  `SyntaxReferenceSource` (sin consumidor tras la retirada), `tool/check_content.dart` y sus tests, y las claves de
  localización que solo usaban. Los seis programas que otras pantallas cargan (demo guiada, alias y función, en los
  dos idiomas) pasaron a `assets/demo/` detrás del puerto `DemoProgramSource`; la página de contacto dejó de leer el
  manifiesto y muestra textos localizados.
- **Alternativas descartadas y por qué:**
    - *Adaptar el manifiesto v2 a la nueva ruta:* conservaba la resolución de marcadores en la app y un segundo
      verificador de contenido; el paquete generado llega ya ejecutado y comprobado.
    - *Mantener los módulos anteriores junto a la ruta:* dos temarios con identidades de progreso distintas y sin
      correspondencia; la ruta los sustituye por completo.
- **Consecuencia:** el paquete se versiona porque lo consume un build ajeno a su generador; `RUTA-BUNDLE-STALE` falla
  si el paquete versionado no coincide con lo que el compilador produce.

### 4.19 Comprobación pedagógica de ejercicios: conducta observable, normalización y aserciones estructurales

- **Problema:** Comprobar si un ejercicio es correcto no debe depender de una coincidencia textual del código fuente ni
  de comparaciones frágiles de cadenas.
- **Elección:** El puerto `ExerciseChecker` y su implementación `RustExerciseChecker` evalúan los programas en base a
  conducta observable:
    - **Casos de prueba visibles y ocultos:** El programa se ejecuta con entradas simuladas capturando la salida
      emitida.
    - **Normalización de salidas:** Colapso de espacios en blanco internos, recorte de extremos, eliminación de saltos
      de
      línea finales superfluos y comparación numérica con tolerancia de `1e-9` para valores de punto flotante.
    - **Aserciones estructurales del AST (Catálogo cerrado):** Cuando el enunciado exige restricciones de diseño, se
      comprueban hasta cinco condiciones sobre la vista pública del programa:
        1. Contiene construcción sintáctica (`ContainsConstructAssertion`).
        2. No contiene construcción sintáctica (`NotContainsConstructAssertion`).
        3. Declara subprograma con nombre y aridad (`SubprogramSignatureAssertion`).
        4. Declara miembro de clase con visibilidad (`ClassMemberAssertion`).
        5. No supera N repeticiones de una construcción (`MaxOccurrencesAssertion`).
    - **Contenido ya verificado:** los casos, las aserciones, la solución de referencia y las respuestas de cada
      ejercicio llegan en el paquete de la ruta, que el compilador de `packages/pseudolearn_reference` ya ejecutó con
      el motor. `test/engine/rust/route_exercise_gate_test.dart` repite la comprobación desde la app: cada solución de
      referencia pasa este comprobador por el puente real y cada clave de respuesta la aceptan los evaluadores.
    - **Filosofía no punitiva:** No se muestran calificaciones ni porcentajes. Si fallan casos ocultos, se aísla y
      revela **exclusivamente el primer caso oculto fallido** con sus entradas y salidas esperadas.
    - **Código base inicial (`starterCode`) para ejercicios interactivos:** Los ejercicios que escriben código y traen
      un programa de partida (completar, modificar, rompe) lo proyectan como `starterCode` en
      `domain/model/route/route_exercise_projection.dart`. Al abrirlo en el editor, `ExerciseCreationLauncher` crea el
      documento pre-poblando el editor con ese código base.
      Asimismo, `DocumentPage` asegura retrocompatibilidad: si se abre un documento vinculado a un ejercicio cuyo
      contenido esté vacío pero tenga `starterCode`, este se inyecta y persiste de forma automática en el editor.
- **Alternativas descartadas y por qué:**
    - *Iniciar el editor siempre en blanco y exigir transcribir el código base:* Descartada porque contradice la
      casuística de ejercicios diseñados explícitamente para completar o modificar código existente, generando
      fricción y errores tipográficos ajenos al objetivo pedagógico.
    - *Calificación con nota numérica y persistencia de intentos fallidos:* Descartada por contravenir el alcance
      educativo personal del sistema.

### 4.20 Política de nombres de documento y regla de familias en biblioteca

- **Problema:** La duplicación de nombres de archivo confunde la gestión documental en la biblioteca.
- **Elección:** `DocumentTitlePolicy` implementa una función pura en `domain/model/`:
    1. *Normalización:* Recorte de espacios en extremos y colapso de secuencias de espacios en blanco a un único
       espacio.
    2. *Comparación canónica:* Insensible a mayúsculas/minúsculas pero **estrictamente sensible a tildes y diacríticos
       ** (`Calculo` y `Cálculo` se consideran distintos).
    3. *Regla de familias:* Para un título base $B$, su familia comprende $B$ y $B\ \langle n\rangle$. La sugerencia
       automática adopta $B$ si no existe colisión, o $B\ \langle\max + 1\rangle$ en caso contrario.
- **Alternativas descartadas y por qué:**
    - *Generación de identificadores numéricos visibles para el usuario:* Descartada porque degrada la legibilidad de la
      biblioteca personal.

### 4.21 Ajustes unificados sobre el armazón general y panel acompañante adaptable

- **Problema:** Si la pantalla de ajustes se maqueta con reglas distintas al resto de destinos, se producen
  desalineaciones visuales en monitores de escritorio.
- **Elección:**
    - `SettingsOverviewView` adopta `AppPage` y la medida de ancho `wide`, distribuyendo sus secciones en dos columnas
      en pantallas `expanded`.
    - Las subpantallas de Idioma, Tema, Diagramas y Contacto utilizan el mismo armazón con navegación de retroceso en la
      cabecera.
    - El ajuste de **zoom asistido en diagramas** (`assistedDiagramZoom`) viaja en `AppPreferences`; su valor rige tanto
      en el documento activo como en el laboratorio de la introducción.
    - El **panel acompañante** (`CompanionLayout`) adapta su orientación: en `expanded` sitúa el editor y el acompañante
      en paralelo horizontal (proporción 1:1 con franja de comandos); en `compact` y `medium` los organiza
      verticalmente (proporción 3:2 sin franja de comandos para preservar espacio de código).

### 4.22 Autoridad de orden en sincronización: contador monotónico por cuenta bajo bloqueo de fila

- **Problema:** Si el orden de sincronización dependiera de las marcas de tiempo (`updatedAt`) del dispositivo, los
  desfases entre relojes provocarían que un cambio más reciente pareciera más antiguo, y ediciones concurrentes dentro
  del mismo segundo empatarían sin que el sistema detectara el conflicto, provocando pérdida destructiva e inadvertida
  de trabajo.
- **Elección:** El servidor Postgres asigna `server_revision`, un entero monotónico por cuenta, dentro de la función RPC
  atómica `push_documents` bajo bloqueo exclusivo de fila en la tabla `account_revision` del usuario. El cliente nunca
  asigna ni altera `server_revision`. La marca temporal `updated_at` generada por el dispositivo se conserva con
  carácter
  estrictamente informativo para la interfaz gráfica, sin intervenir en el algoritmo de ordenación ni en la resolución
  de conflictos.
- **Alternativas descartadas y por qué:**
    - *Ordenación por timestamp local del cliente (`updatedAt`):* Descartada por ser vulnerable al desvío de relojes
      físicos y generar empates no detectables con sobrescritura ciega (Last-Write-Wins).
    - *Secuencia global `bigserial` de base de datos:* Descartada porque transacciones confirmadas fuera de orden pueden
      hacer que una transacción con revisión menor confirme después de que un cliente haya avanzado su cursor,
      provocando que el cliente omita permanentemente la descarga de dicho documento.
    - *CRDTs o vectores de versiones distribuidos:* Descartados por requerir una complejidad algorítmica y de
      almacenamiento
      desproporcionada para el modelo de documentos de la aplicación, donde se sincronizan instantáneas completas y no
      edición colaborativa concurrente carácter a carácter.

### 4.23 Ubicación de la autenticación: puerto en dominio, credencial nativa y canje en infraestructura pura

- **Problema:** Proporcionar autenticación remota federada (Apple, Google, correo mediante enlace mágico) sin acoplar
  las capas internas (`domain`, `application`, `presentation`) a SDKs de terceros ni violar la prohibición de
  dependencias de Flutter UI en la capa de datos.
- **Elección:**
    - El contrato abstracto `AuthGateway` reside en `domain/ports/` y expone cinco métodos públicos:
      `restoreSession()`, `signIn(method)`, `completeSignInFromLink(link)`, `signOut()` y `sessionChanges()`. Los
      métodos
      retornan la clase sellada `AuthOutcome` (`Authenticated`, `Cancelled`, `NoConnection`, `Rejected`,
      `MagicLinkSent`),
      evitando propagar excepciones de red.
    - `NativeCredentialSource` en `data/auth/` gestiona las llamadas a los plugins de plataforma (`sign_in_with_apple`,
      `google_sign_in`) sin requerir `BuildContext`.
    - Cada autorización de Apple se vincula a un `SignInNonce` (`data/auth/`) generado con `Random.secure()`: el resumen
      SHA-256 viaja a Apple, que lo incrusta como reclamación `nonce` del token de identidad, y el valor crudo viaja a
      Supabase, que solo acepta el token si ambos concuerdan. El campo `rawNonce` de `NativeAppleCredential` es
      obligatorio
      y no admite nulo, de modo que resulta imposible construir una credencial de Apple sin vínculo antirreplay.
    - El nombre completo solo viaja en la respuesta de la primera autorización de un Apple ID: el token de identidad de
      Apple
      no contiene reclamación de nombre y las autorizaciones siguientes lo omiten. `SupabaseAuthGateway` lo escribe en
      `user_metadata.full_name` inmediatamente después del canje, únicamente si esa clave está vacía, para que quede
      disponible en todos los dispositivos de la cuenta. Un fallo al escribirlo no invalida la sesión ya autenticada.
    - Las credenciales nativas solo transportan lo que el canje consume: identidad, nonce, y el nombre y la dirección
      que
      únicamente Apple entrega fuera del token. El proveedor de Google no duplica nombre, dirección ni fotografía porque
      su token de identidad ya los traslada a `user_metadata`.
    - `SupabaseAuthGateway` canjea las credenciales nativas ante el backend empleando el paquete de Dart puro `supabase`
      (en lugar de `supabase_flutter`).
    - El paquete `supabase` de Dart puro mantiene la sesión solo en memoria. `SupabaseSessionPersistence`
      (`data/auth/`) la hace sobrevivir al cierre de la app: escucha `onAuthStateChange` y, ante `initialSession`,
      `signedIn`, `tokenRefreshed` y `userUpdated`, escribe `Session.toJson()` bajo la clave `supabase.auth.session` en
      `SecureSessionStorage` (Llavero en iOS y macOS, mediante `FlutterSecureStorage`); ante `signedOut` la borra, lo que
      cubre el cierre de sesión y la sesión local cerrada tras eliminar la cuenta. `SupabaseAuthGateway.restoreSession()`
      usa la sesión en memoria o, si no la hay, `recover()`, que llama a `GoTrueClient.recoverSession` (renueva el token
      si expiró). Refresh token revocado o inválido (`AuthException`) y datos corruptos (`FormatException`) borran lo
      guardado y devuelven sin sesión; un fallo de red (`AuthRetryableFetchException`) devuelve sin sesión y **conserva**
      lo guardado para el siguiente arranque con conexión. Un fallo del Llavero al leer o escribir no invalida la sesión
      en memoria: la app sigue autenticada hasta cerrarse. `sessionChanges()` descarta los errores que `GoTrueClient`
      emite en el flujo de estado, que no son sesiones. `pkceAsyncStorage` sigue guardando únicamente el verificador
      PKCE del enlace mágico.
    - En iOS el Llavero sobrevive a la desinstalación: una reinstalación puede recuperar la sesión anterior; si la
      cuenta ya no existe, el refresh token falla y la sesión guardada se borra.
    - `AccountCubit` gestiona el estado inmutable `AccountState` y tipifica cualquier fallo en `AccountError`.
- **Alternativas descartadas y por qué:**
    - *Guardar solo el refresh token y llamar a `setSession`:* pierde el usuario y la expiración del access token,
      obliga a una llamada de red en cada arranque y no funciona sin conexión mientras el access token sigue vigente.
    - *`supabase_flutter`:* Descartado por incorporar widgets, escuchas implícitas del ciclo de vida de Flutter y
      acoplamiento a `BuildContext` en la infraestructura de datos.
    - *Adaptador de autenticación implementado en `composition/`:* Descartado porque la capa de composición tiene
      terminantemente prohibido contener lógica de negocio o ramificaciones condicionales.
    - *Firebase Auth:* Descartado para consolidar la infraestructura en Supabase y aplicar políticas de seguridad a
      nivel
      de fila (RLS) en Postgres.
    - *Autenticación por contraseña clásica:* Descartada para evitar el almacenamiento, validación y flujos de
      recuperación
      de contraseñas, prefiriendo enlaces mágicos por correo junto a proveedores federados nativos.
    - *Canje de Apple sin nonce:* Descartado porque un token de identidad interceptado sería reutilizable contra el
      backend
      sin vínculo alguno con el intento de acceso que lo originó.
    - *Persistir el nombre de Apple solo en el dispositivo que lo recibe:* Descartado porque la primera autorización
      ocurre en
      un único dispositivo y el nombre quedaría inaccesible en el resto de la cuenta para siempre.
    - *Sobrescribir `full_name` en cada acceso con Apple:* Descartado porque revocar y repetir la autorización
      devolvería el
      nombre del sistema y pisaría cualquier corrección posterior del usuario.
    - *Conservar el código de autorización de Apple del inicio de sesión para revocar al eliminar la cuenta:*
      Descartado porque el código caduca a los cinco minutos y es de un solo uso. `NativeAppleCredential` transporta
      `authorizationCode` porque la eliminación de cuenta pide una autorización nueva y lo consume en ese momento
      (decisión 4.42); el canje de inicio de sesión no lo usa y nada lo persiste.

### 4.24 Reconciliación pura de documentos y política de preservación no destructiva

- **Problema:** Resolver discrepancias entre el estado local y remoto sin acoplar la lógica de reconciliación a red ni a
  base de datos, garantizando matemáticamente que ninguna edición válida del usuario se elimine silenciosamente.
- **Elección:**
    - La resolución de conflictos se implementa como la función pura `reconcileDocument` en `domain/model/sync/` (capa
      0).
      Recibe `local`, `remote` (ambos `DocumentSnapshot?`) y `lastSyncedRevision`, y retorna la unión sellada
      `ReconciliationOutcome` (`PushLocal`, `AdoptRemote`, `KeepBoth`, `NoChange`).
    - Ante modificaciones concurrentes (local y remoto modificados, o borrado local con edición remota, o edición local
      con lápida remota), la regla invariable es la no destrucción: el estado remoto se adopta en el identificador
      principal
      y la versión local se preserva automáticamente como copia de conflicto con título asignado mediante
      `suggestNextDocumentTitle` bajo el sufijo `(conflicto)`.
    - Detección de falso conflicto: si los contenidos son idénticos bit a bit pese a divergir en sus números de
      revisión,
      la función resuelve `NoChange` evitando la generación de copias redundantes.
- **Alternativas descartadas y por qué:**
    - *Servicio de reconciliación impuro con acceso a SQLite y HTTP:* Descartado porque impide la verificación
      exhaustiva
      de la matriz trilateral de estados mediante pruebas unitarias puras y sin dobles de prueba pesados.
    - *Last-Write-Wins (LWW) destructivo:* Descartado porque descarta silenciosamente ediciones de usuario en escenarios
      de desconexión prolongada.
    - *Interfaz gráfica de fusión trilateral (3-way merge):* Descartada por incorporar una sobrecarga de fricción
      cognitiva
      desmedida para la naturaleza educativa de los algoritmos personales.

### 4.25 Reconciliación de progreso por unión monotónica y partición de preferencias

- **Problema:** Sincronizar el avance curricular (lecciones visitadas y ejercicios resueltos) y las preferencias del
  usuario
  entre dispositivos sin generar conflictos textuales y sin acoplar configuraciones ergonómicas del dispositivo a la
  cuenta personal.
- **Elección:**
    - Las identidades de progreso de la ruta son `ruta.leccion:<id>` y `ruta.ejercicio:<id>`
      (`domain/model/route/route_kinds.dart`); el prefijo las separa de las identidades de la ruta anterior, que
      quedan en el almacén sin consumidor y no se migran porque no existe correspondencia entre módulos y lecciones.
    - Las banderas `visited` y `completed` transitan exclusivamente de 0 a 1 (conjunto de crecimiento monótono). La
      sincronización se modela como una unión de semilattice idempotente (`mergeProgress` en cliente y `push_progress`
      en
      Supabase con `visited or excluded.visited`), preservando las fechas mínimas de logro (`first_completed_at`).
      Reenviar un lote es seguro e idempotente.
    - Segregación de puertos de progreso: `SqliteLocalProgressStore` estampa la bandera `dirty = 1` al persistir
      avances.
      El puerto segregado `ProgressSyncStore` (`SqliteProgressSyncStore`) expone la lectura y limpieza de entradas
      sucias,
      evitando exceder el límite de 5 métodos públicos en `LocalProgressStore`.
    - Partición de preferencias por ciclo de vida: `AppPreferences` se particiona estrictamente en `AccountPreferences`
      (idioma, tema visual, zoom asistido en diagramas), que viajan entre dispositivos, y `DevicePreferences` (cuerpo de
      fuente del editor, números de línea, guías de indentación, `hasSeenOnboarding`), que pertenecen exclusivamente al
      entorno físico de ejecución.
    - Desacoplamiento del drenador: `SyncDrainer` orquesta en alto nivel delegando en `DocumentSyncDrainer` y
      `ProgressSyncDrainer`, preservando la regla de única responsabilidad y límites métricos.
- **Alternativas descartadas y por qué:**
    - *Reconciliación trilateral de progreso idéntica a documentos:* Descartada porque el progreso educativo nunca
      presenta
      conflictos de contenido divergente.
    - *Sincronización del tamaño de fuente del editor:* Descartada porque teléfonos móviles y pantallas de escritorio
      poseen
      densidades de píxeles y distancias de lectura dispares que exigen cuerpos tipográficos específicos por
      dispositivo.
    - *Reinicio de progreso local sin soporte de backend:* Se asume contractualmente que un reinicio completo de avance
      requerirá una operación destructiva de cuenta en el servidor para evitar que la unión monotónica vuelva a
      descargar el
      progreso previo desde la nube.

### 4.26 Disparo de sincronización y outbox persistente desacoplado del camino crítico

- **Problema:** Garantizar que la persistencia y edición local de algoritmos opere a velocidad de disco sin depender de
  la
  conectividad ni congelar el hilo de la interfaz gráfica por latencias de red.
- **Elección:**
    - Toda mutación local (`saveDocument`, `deleteDocument`, progreso) escribe atómicamente en el almacenamiento local y
      encola una tarea en la tabla SQLite `sync_outbox`.
    - El componente `SyncDrainer` en `data/sync/` procesa la cola de fondo priorizando siempre la descarga (*pull*)
      antes
      que la subida (*push*), asegurando que cualquier conflicto se evalúe contra el estado remoto más reciente.
    - Disparadores de vaciado: recuperación de conectividad (`ConnectivityMonitorAdapter`), reanudación de la aplicación
      en
      primer plano, temporizador con *debounce* de 3 segundos tras la última edición y acción manual "Sincronizar
      ahora".
    - Los reintentos implementan retroceso exponencial con tope de reintentos; entradas fallidas persistentes se marcan
      sin
      bloquear el procesamiento de las demás operaciones.
- **Alternativas descartadas y por qué:**
    - *Sincronización sincrónica durante el guardado:* Descartada por violar el principio offline-first y bloquear la
      interfaz
      ante desconexión o latencia del servidor.
    - *Bandeja de salida exclusivamente en memoria:* Descartada porque cualquier terminación súbita de la aplicación
      provocaría
      la pérdida irrecuperable de las operaciones pendientes de sincronización.

### 4.27 Ensamblado incondicional en composición: decorador siempre cableado

- **Problema:** La capa de composición (`composition/`) prohíbe terminantemente estructuras de control condicional
  (`if`,
  `switch`, ternarios), impidiendo bifurcar el ensamblado de dependencias según exista o no una sesión de usuario
  activa.
- **Elección:**
    - En `AppDependencies`, `SyncingDocumentRepository` decora siempre e incondicionalmente a `FileDocumentRepository` y
      encola toda operación en `sync_outbox`.
    - El caso de usuario sin sesión iniciada se resuelve dentro del adaptador: `SyncDrainer` consulta el estado de
      `AuthGateway` y permanece inactivo mientras no exista una sesión válida.
    - Los algoritmos creados o modificados por el usuario antes de iniciar sesión quedan encolados en el outbox local y
      se
      sincronizan automáticamente en cuanto se autentica por primera vez.
- **Alternativas descartadas y por qué:**
    - *Bifurcación condicional en AppDependencies (`if (hasSession) ...`):* Descartada por violación directa de la regla
      arquitectónica `composition_rules.forbid_conditionals`.
    - *Mantenimiento de dos repositorios separados (local y remoto):* Descartado por duplicar lógica de
      lectura/escritura de
      archivos `.pseudo` y romper la uniformidad de acceso a datos.

### 4.28 Cierre de sesión con preservación local por defecto y borrado selectivo

- **Problema:** Evitar la destrucción involuntaria del trabajo de un estudiante al desconectar su cuenta y proporcionar
  un
  mecanismo higiénico de borrado para entornos educativos compartidos.
- **Elección:**
    - Se exponen dos acciones diferenciadas por jerarquía visual en la interfaz de cuenta:
        - **Cerrar sesión:** descarta el token de refresco y suspende el drenador de sincronización. Los documentos,
          progreso y preferencias locales se conservan intactos y editables en el dispositivo.
        - **Cerrar sesión y borrar datos de este dispositivo:** purga completamente los archivos locales `.pseudo` y el
          índice SQLite tras confirmación explícita del usuario mediante `AppConfirmationDialog`.
    - Al volver a iniciar sesión con la misma cuenta, las mutaciones locales sin sincronizar suben por `PushLocal` sin
      sobrescritura destructiva.
    - Si inicia sesión una cuenta distinta de la que reclamó previamente los datos locales, la aplicación detecta la
      divergencia mediante `sync_state` y solicita decisión explícita al usuario entre fusionar los datos locales con la
      nueva cuenta o aislarlos empezando con una biblioteca vacía.
- **Alternativas descartadas y por qué:**
    - *Borrado local automático e incondicional al cerrar sesión:* Descartado por destruir catastróficamente algoritmos
      creados sin conexión por estudiantes.
    - *Acción única de cierre con configuración ambigua:* Descartada para evitar errores operativos en dispositivos
      compartidos de laboratorios o aulas.

### 4.29 Panel de progreso local-first y métricas basadas en cobertura

- **Problema:** Consolidar en una pantalla única el avance pedagógico del estudiante —biblioteca, temario, ejercicios,
  construcciones sintácticas ejercitadas y estado de sincronización— sin exigir conectividad ni sesión remota, sin
  emitir
  juicios sumativos o notas numéricas y sin que ningún widget compute agregaciones de colecciones.
- **Elección:**
    - **Cuarto destino `/progreso`:** Opera al 100 % fuera de línea utilizando los orígenes locales persistidos en
      SQLite y
      en el AST de los archivos `.pseudo`. La sesión remota solo enriquece las métricas con el progreso alcanzado en
      otros
      dispositivos.
    - **Agregación estricta en `application/dashboard/`:** `DashboardLoader` reúne los datos locales y
      `DashboardProjection`
      los transforma mediante funciones puras desacopladas (`projectLibraryMetrics`, `projectPartCoverage`,
      `projectNextLesson`, `projectExerciseCoverage` —por parte, nivel y tipo—, `projectConceptUsage`, `projectSpecificationCoverage`,
      `projectActivityWeeks`, `projectSyncHealth`), respetando el límite de 5 métodos públicos por clase.
    - **Cimas y recuentos calculados en el estado:** Estructuras como `ActivityTimeline`, `ConceptCoverage` y
      `SpecificationCoverage` transportan valores agregados definitivos hacia los widgets, dando estricto cumplimiento a
      la
      prohibición de `where`, `fold` y `sort` en la capa de presentación.
    - **Conceptos ejercitados derivados del AST:** El adaptador `RustProgramConstructReader` analiza el código de los
      documentos locales mediante `API.PROGRAM.VIEW` (la misma vista de las aserciones estructurales), deduciendo qué
      estructuras de control y programación orientada a objetos ha escrito realmente el estudiante sin almacenar
      telemetría
      adicional.
    - **Cobertura de especificación acotada a lo observable:** Cruza construcciones ejercitadas contra las secciones
      normativas correspondientes publicadas en los manifiestos, omitiendo del denominador aquellas secciones
      conceptuales
      no asociadas a nodos sintácticos verificables.
    - **Línea de actividad semanal fija de 8 semanas:** Muestra barras apiladas descriptivas sin penalizar períodos de
      inactividad ni introducir rachas gamificadas punitivas. El indicador «semanas activas» cuenta semanas con algún
      evento dentro de la ventana; no es una racha consecutiva y no se reinicia por una semana vacía.
    - **Estado por lección proyectado, no recalculado en la vista:** `projectPartCoverage` entrega por tramo una
      `LessonMark` por lección (`LessonStage.pending`, `inProgress` o `completed`, más la marca de lección sugerida),
      derivada de la misma `RouteProgress` que usa el índice de la ruta. Así el panel y el índice no pueden discrepar:
      una lección abierta es «En curso» y solo pasa a completada cuando todos sus ejercicios obligatorios están resueltos,
      o al abrirla si no tiene ninguno. `NextLesson` transporta el recuento de obligatorios resueltos de la lección
      sugerida para que el estudiante vea qué le falta, y `DashboardState.hasNothingRecorded` considera tocada una
      lección solo abierta.
    - **Gráficos propios sin dependencia de terceros:** Anillos concéntricos, anillo repartido, radar y barras apiladas son
      `CustomPainter` pequeños (`ConcentricRingsPainter`, `DonutPainter`, `RadarPainter`, `StackedBarsPainter`) sobre la
      paleta semántica del tema (`ChartPalette`): primario para lecciones, éxito para ejercicios y lecciones completadas,
      información para conceptos y aviso para creaciones, de modo que el modo oscuro hereda el contraste del tema. La
      animación de entrada (`ChartReveal`) usa `MotionSpeed.chart` (900 ms con `easeEnter`) y se anula con movimiento
      reducido, que pinta directamente el estado final. Las etiquetas del radar son widgets alineados en el borde del
      lienzo, no texto pintado, para conservar tipografía, escala de sistema y accesibilidad.
- **Alternativas descartadas y por qué:**
    - *Panel alojado dentro de la pantalla de Cuenta:* Descartada porque exigiría iniciar sesión para consultar el
      propio
      progreso, violando el principio local-first.
    - *Cálculo de cobertura leyendo los archivos Markdown en tiempo real:* Descartada por el impacto prohibitivo en el
      tiempo
      de renderizado de la interfaz al analizar toda la ruta en cada apertura.
    - *Almacenamiento de número de intentos, tasas de acierto o tiempos por módulo:* Descartado por contravenir las
      directrices
      de privacidad y la filosofía pedagógica formativa no punitiva.
    - *Barras de progreso apiladas por tramo, nivel y tipo:* Descartada en la revisión del panel porque producía una
      lista larga de medidores idénticos sin jerarquía, mezclaba visitadas con completadas en el rótulo y no explicaba
      qué faltaba para completar una lección.
    - *Biblioteca de gráficos de terceros:* Descartada porque cuatro formas simples no justifican una dependencia, y una
      biblioteca impone su propia paleta, tipografía y animaciones por encima del sistema de diseño.
    - *Rachas de días consecutivos:* Descartadas por punitivas; se sustituyen por semanas activas dentro de la ventana.

### 4.30 Captura inmediata de historia: marcas de tiempo de progreso desde el origen

- **Problema:** Reconstruir cronológicamente la línea de actividad histórica semanal exige conocer el momento exacto en
  que un
  módulo fue visitado o un ejercicio fue resuelto por primera vez. Si estas marcas no se capturan en el momento del
  evento, la
  información temporal se pierde de forma permanente e irrecuperable.
- **Elección:**
    - La tabla `content_progress` incorpora las columnas `first_visited_at` y `first_completed_at` gestionadas mediante
      semántica `write-once` en `SqliteLocalProgressStore` (solo se asignan en la primera transición de 0 a 1 y nunca se
      sobrescriben).
    - Constituye una excepción justificada a la directiva de no anticipar código no solicitado, sustentada en la
      imposibilidad
      técnica de reconstruir retroactivamente la cronología de eventos si las columnas se introdujeran en fases
      posteriores.
    - El acceso a estos datos históricos para el panel se desacopla a través del puerto `ProgressHistory`
      (`SqliteProgressHistory`), manteniendo segregadas la consulta analítica y la mutación operativa de progreso.
- **Alternativas descartadas y por qué:**
    - *Diferir la creación de columnas hasta la construcción del widget de cronograma:* Descartada porque todo el avance
      previo
      del estudiante habría carecido de fecha de inicio, imposibilitando la reconstrucción histórica de la actividad.
    - *Registro de marcas temporales por cada intento individual:* Descartado para cumplir rigurosamente con la
      prohibición de
      almacenar intentos o historiales de fallo.

### 4.31 Identidad visual de la cuenta derivada en dominio y estable entre plataformas

- **Problema:** Representar una cuenta cuando el proveedor no entrega fotografía ni nombre. Una dirección de reenvío
  privado de
  Apple es un identificador opaco (`7k5fdm5f2j@privaterelay.appleid.com`): su primer carácter no es una inicial, y
  mostrarlo como
  tal produce un monograma sin significado. La derivación tampoco puede vivir en el árbol de widgets, donde filtrar y
  plegar
  colecciones está prohibido.
- **Elección:**
    - `AccountAvatarIdentity.fromSession` en `domain/model/account/` (capa 0) deriva las dos únicas magnitudes que el
      avatar
      necesita: `initials` (nulo cuando no hay letra que lo sustente) y `colorSeed`.
    - Las iniciales toman la primera letra de la primera y de la última palabra del nombre; sin nombre, la primera letra
      de la
      dirección; y quedan nulas cuando el candidato no empieza por letra, en cuyo caso `AccountAvatar` pinta un glifo
      neutro en
      lugar de un carácter arbitrario.
    - La condición de letra se resuelve por plegado de mayúsculas y minúsculas, más un umbral ASCII que admite las
      escrituras sin
      caja (han, kana, hangul) y descarta cifras y símbolos, sin tablas Unicode ni expresiones regulares.
    - `colorSeed` es un plegado polinómico determinista sobre las unidades de código del identificador de usuario. La
      presentación
      lo reduce con módulo sobre su paleta de acento, de forma que el dominio nunca conoce colores.
    - `isApplePrivateRelayEmail` en `domain/model/account/` etiqueta la dirección de reenvío en la tarjeta de sesión, de
      modo que
      una dirección opaca se lee como una decisión de privacidad del usuario y no como un dato corrupto.
- **Alternativas descartadas y por qué:**
    - *`String.hashCode` como semilla de color:* Descartado porque el hash de cadena de Dart no está garantizado entre
      plataformas
      ni versiones de la máquina virtual, de modo que la misma cuenta podría teñirse distinto en macOS y en iOS.
    - *Derivar iniciales dentro del widget del avatar:* Descartado porque la derivación de datos pertenece al dominio,
      es donde se
      puede probar sin montar un árbol de widgets, y la capa de presentación tiene prohibido plegar colecciones.
    - *Recortar la parte local de la dirección de reenvío para fabricar una inicial:* Descartado porque el fragmento es
      un
      identificador asignado por Apple, no un nombre, y cualquier letra extraída de él engaña sobre la identidad de la
      cuenta.
    - *Ocultar por completo la dirección de reenvío:* Descartado porque es la dirección real a la que llega el correo de
      la cuenta
      y el usuario necesita reconocerla.

### 4.32 Retorno del enlace mágico: puerto de enlaces entrantes y canje del código en el adaptador

- **Problema:** El enlace mágico completa su verificación en el navegador y devuelve el control al sistema operativo
  mediante
  el esquema `pseudolearn://auth-callback`. Sin nadie que reciba esa URL, el usuario ve una pestaña en blanco, vuelve a
  la
  aplicación y la encuentra exactamente como la dejó: el correo se envió, el enlace se consumió y la sesión nunca
  existió.
- **Elección:**
    - La recepción de enlaces es un servicio del sistema operativo, así que entra por un puerto: `IncomingLinkSource` en
      `domain/ports/` expone un único `Stream<Uri> incomingLinks()`. `AppLinksIncomingLinkSource` en `data/platform/` lo
      implementa sobre `package:app_links`, que resuelve el arranque en frío y la reanudación en caliente con la misma
      corriente: el complemento retiene el primer enlace recibido y lo entrega al primer suscriptor.
    - `AccountCubit` se suscribe a esa corriente dentro de `init()` y su proveedor se monta con `lazy: false`, de modo
      que la
      suscripción existe desde el arranque y no desde la primera vez que alguien abre la pantalla de Cuenta.
    - `AuthGateway` gana un quinto método, `completeSignInFromLink(Uri)`, que retorna `AuthOutcome?`. El nulo significa
      «este enlace no es el retorno de autenticación de esta aplicación», y deja la sesión intacta: la aplicación
      registra el
      esquema `pseudolearn` para más usos que el acceso, y un enlace ajeno no puede degradar el estado de la cuenta.
    - Reconocer el enlace es responsabilidad del adaptador, no del caso de uso: `isAuthCallbackLink` y `authCallbackUrl`
      viven juntos en `data/auth/auth_callback_link.dart`, de modo que la dirección que se pide a Supabase en
      `emailRedirectTo`
      y la que se acepta al volver son literalmente la misma constante y no pueden divergir.
    - El canje lo hace `getSessionFromUrl` del cliente `supabase`, que bajo flujo PKCE cambia el parámetro `code` por
      una
      sesión usando el verificador que `signInWithOtp` guardó en el almacenamiento seguro. Esto ata el acceso al
      dispositivo
      que pidió el enlace: abrirlo en otro equipo no puede completar la sesión, y el mensaje de la aplicación lo
      advierte.
    - Los fallos del retorno viajan por el mismo camino tipado que el resto del acceso —`Rejected` para un enlace
      caducado o
      ya consumido, `NoConnection` para una red ausente—, así que la pantalla de Cuenta los presenta sin conocer el
      transporte.
- **Alternativas descartadas y por qué:**
    - *Leer también `getInitialLink()` además de la corriente:* Descartado porque el código PKCE es de un solo uso: el
      segundo
      canje del mismo enlace falla, y ese fallo pisaría con un error la sesión que el primero acababa de abrir.
    - *`supabase_flutter`, que trae su propio observador de enlaces:* Descartado por la misma razón que en el acceso
      federado:
      arrastra widgets y escuchas implícitas del ciclo de vida de Flutter a la capa de datos.
    - *Recibir el enlace en código nativo y pasarlo por un canal propio:* Descartado por reimplementar en Swift, dos
      veces, lo
      que un complemento ya resuelve para las cinco plataformas, y por dejar la lógica de acceso repartida entre dos
      lenguajes.
    - *Filtrar el enlace en `AccountCubit`:* Descartado porque obligaría a la capa de aplicación a conocer la forma de
      la URL de
      retorno, que es un detalle del adaptador de autenticación.
    - *Retornar `Cancelled` ante un enlace ajeno en vez de nulo:* Descartado porque `Cancelled` significa que la persona
      abandonó el acceso, y emitirlo por un enlace no relacionado borraría el aviso de «enlace enviado» que sigue siendo
      cierto.

### 4.33 Escritura en el cursor y barra de teclas: modalidad de entrada, no plataforma

- **Problema:** Escribir pseudocódigo en un teléfono era más difícil de lo que el motor merece. No hay `TAB` ni `<-` en
  el teclado del sistema, y la franja de comandos que existía concatenaba la plantilla **al final del archivo**
  (`'${sourceCode}\n${item.template}'`), no donde estaba el cursor: no era una ayuda de edición, era un añadidor de
  bloques al pie. Además el cursor no era alcanzable desde fuera del campo, porque `CodeField` creaba su propio
  `HighlightController` en `initState`. En escritorio el problema era distinto pero real: `TAB` lo consume el recorrido
  de foco de Flutter y nunca indenta.
- **Elección:** Tres decisiones encadenadas.
    1. **El cursor es un dato del dominio y la edición una operación pura.** `CaretRange` (propio, porque
       `TextSelection` es de Flutter y `domain/model` no lo importa), `EditorKey` y `SourceEdit` viven en
       `domain/model/editor/`; el cálculo entra por el puerto `SourceEditor` y lo implementa `LexiconSourceEditor` en
       `engine/editing/`. La regla `application.may_import` convierte en obligatorio lo que de todos modos hace el
       cálculo probable sin motor real: `EditorCubit` no puede llamar a `engine/`, así que recibe el puerto inyectado.
       La sangría se hereda de la línea del cursor, la unidad de sangría es la que el documento ya usa (tabulador si
       aparece alguno, dos espacios si no) y una plantilla insertada bajo una línea que abre bloque baja un nivel más;
       *qué lexema abre bloque lo dice el perfil*, no un literal incrustado.
    2. **La barra va en el flujo, no flotando.** `EditorKeyBar` es la última fila de la columna del editor. Como el
       `Scaffold` ya encoge su cuerpo cuando sube el teclado, la barra queda pegada encima de él sin calcular una sola
       coordenada, y desaparece con él. Es una fila fija de siete teclas sin desplazamiento horizontal —una tecla que
       se mueve deja de ser una tecla— más una tecla de despliegue que abre la segunda fila con las plantillas de
       estructura, que sí se desplaza porque se busca con la vista y no con el dedo entrenado.
    3. **La pregunta no es «¿es un móvil?» sino «¿el texto entra por un teclado en pantalla?».** Un iPad en horizontal
       es `expanded` por ancho y sí necesita las teclas; un portátil con la ventana estrecha es `compact` y no las
       necesita. La respuesta se compone de dos señales, ninguna de ellas un identificador de plataforma en
       presentación: la **capacidad** la publica el puerto `TextEntryModality` —su adaptador
       `PlatformTextEntryModality` es el único archivo de `lib/` autorizado a preguntar por el sistema operativo, y así
       está declarado en `platform_query_allowed_paths` de `architecture.yaml`— y llega a la presentación como el
       booleano `EditorState.showsKeyBar`; la **presencia** la publica `DesignCanvasData.isKeyboardVisible`, que ya
       existía. En `composition/` no aparece ningún condicional y en `presentation/` ningún identificador de
       plataforma.
- **Cómo vuelve el cursor al campo:** `EditorState.pendingEdit` lleva texto, posición y una revisión monotónica.
  `EditorSurface` —dueño del `HighlightController` y del `FocusNode`— aplica la edición **solo cuando la revisión
  cambia**, de modo que reemitir el estado por cualquier otro motivo no reposiciona el cursor bajo el dedo de quien
  está escribiendo. La edición se escribe sobre el controlador y no reconstruyendo el campo: solo así el historial de
  deshacer del propio campo la registra, y hay un test que pulsa una tecla y deshace.
- **Un solo método público nuevo:** `EditorCubit` ya exponía `loadDocument`, `updateSourceCode`, `saveDocument` y
  `selectDiagnostic`, cuatro de los cinco que permite `public_methods_per_class`. En lugar de gastar el hueco restante
  en `updateSelection` y quedarse sin sitio para la pulsación, la selección viaja como argumento de
  `applyKey(key, caret)`. El cursor deja de ser estado replicado en el cubit y se lee en el momento de la pulsación,
  que es la única vez que importa. El límite obligó a un diseño mejor.
- **El acompañante de escritorio:** `EditorKeyShortcuts` cablea `Tab` a indentar, `Mayús`+`Tab` a desindentar y `Esc` a
  devolver el tabulador al recorrido de foco. Es código compartido, no una segunda implementación: el móvil pulsa una
  tecla dibujada y el escritorio una física, y ambas entran por el mismo puerto `SourceEditor`.
- **Alternativas descartadas y por qué:**
    - *Extensión de teclado del sistema operativo (Custom Keyboard de iOS, `InputMethodService` de Android):*
      Descartada por máximo coste sobre la plataforma menos prioritaria: dos bases de código nativas fuera de Flutter,
      revisión de tienda como componente sensible a privacidad, instalación y activación manual por cada estudiante, y
      cobertura nula en navegador y escritorio.
    - *Teclado propio dentro de la app (`TextInputControl`):* Descartada por regresión, no por coste. Se perderían
      dictado, escritura por deslizamiento, autocorrección, portapapeles del sistema y el *layout* que la persona ya
      tiene configurado; habría que reimplementar la `ñ`, las tildes por pulsación larga y la diéresis —se degradaría
      el 95 % de las pulsaciones para arreglar el 5 %—; y el teclado del sistema es la vía accesible (VoiceOver,
      TalkBack, Control por Interruptores, braille externo). Contradice además §6.3.
    - *Barra flotante sobre el teclado (`Overlay` + `viewInsets`):* Descartada **con reserva**. Entrega lo mismo que la
      barra en el flujo asumiendo un riesgo que esta no necesita asumir: en navegador móvil el inset del teclado no es
      fiable —Safari en iOS encoge el *visual viewport* pero no el de *layout*— y obliga a gestionar a mano el ciclo de
      vida del `OverlayEntry` por ruta, por pestaña y por pérdida de foco. Queda documentada como plan de contingencia:
      si en alguna plataforma el redimensionado no llegara, esa plataforma —y solo esa— usaría capa flotante, sin tocar
      dominio ni aplicación.
    - *No hacer nada y conservar la franja de comandos:* Descartada porque la franja escribía al final del archivo. No
      era una versión reducida de la solución, sino un comportamiento distinto que había que corregir de todos modos.
    - *Ajuste de tres estados (automático · siempre · nunca) en `DevicePreferences`:* **No implementado a propósito**
      (`SCOPE-YAGNI`). Estaba previsto solo como mitigación de una detección poco fiable; con las dos plataformas hoy
      presentes en el proyecto —iOS y macOS— la detección resulta fiable, así que el ajuste no se escribe. Si aparece
      una plataforma donde falle, la partición correcta ya está decidida: va en `DevicePreferences`, no en
      `AccountPreferences`, porque la misma cuenta quiere una respuesta en su teléfono y otra en su portátil.
    - *Crear `web/` para verificar el comportamiento del inset en navegador:* Fuera de alcance. La carpeta no existe en
      el proyecto y no se andamia aquí. El puerto `TextEntryModality` y la condición de aparición de la barra se
      diseñaron para que un adaptador web futuro entre sin tocar `application/` ni `presentation/`; verificarlo queda
      para cuando exista la plataforma.

### 4.34 Salir del teclado en `compact`: la franja de diagnósticos como puente entre escribir y ejecutar

- **Problema:** En `compact`, la aparición del teclado oculta el pie de ejecución completo (§3.4). Escribir el programa
  y querer ejecutarlo dejaba a la persona sin botón de ejecutar y sin forma evidente de bajar el teclado: el campo de
  código es multilínea, así que la tecla de retorno del teclado del sistema escribe un salto de línea en vez de cerrar
  —lo correcto mientras se escribe—, y el único camino que quedaba era cambiar de pestaña y volver, que devuelve el
  foco por efecto colateral del desmontaje. No es un problema de teclado: es que la acción primaria desaparecía justo
  cuando se acababa de terminar de escribirla.
- **Elección:** Dos salidas explícitas y una implícita, alojadas **en la franja de diagnósticos**, no en la barra de
  teclas.
    1. **`Ejecutar` baja el teclado y arranca, en un solo toque.** `EditorSurface._run` suelta el foco antes de avisar
       hacia arriba: al bajar el teclado reaparece el pie de ejecución y con él la salida del programa, que es lo que se
       quiere ver. Ejecuta **hasta el final**; el paso a paso se queda en el pie, porque estudiar un programa se hace
       con
       el teclado bajado y con la tabla de traza a la vista.
    2. **`Ocultar teclado` (`Icons.keyboard_hide`) suelta el foco sin ejecutar,** para leer el programa, mirar los
       diagnósticos o cambiar de pestaña.
    3. **Un toque en el resto de la franja hace lo mismo.** Es la vía implícita: mientras el teclado está levantado, la
       franja no ofrece su desplegable —queda contraída a la línea de recuento—, así que es superficie muerta. Los
       botones ganan la arena de gestos por ser descendientes, de modo que el toque de más afuera no les roba la
       pulsación.
- **Por qué en la franja de diagnósticos y no en la barra de teclas:** No cabe. En 390 dp la fila fija de siete teclas
  más la tecla de plantillas deja unos 49 dp de paso por tecla; añadir ejecutar y ocultar en el mismo eje lo baja a unos
  39 dp y encoge la cara de cada tecla de 41 a 30 dp, con `TAB` y `>=` al borde del recorte. La franja de diagnósticos,
  en cambio, ya existe, ya ocupa el ancho completo, ya aparece exactamente cuando el teclado está levantado y tiene
  vacío todo su lado derecho. El emparejamiento además es honesto de leer: *«2 problemas»* junto a un botón de
  ejecutar apagado; sin problemas, la franja calla su recuento y deja solo las dos salidas. Con el teclado bajado y
  sin problemas la franja no se monta (§4.61).
- **Cómo se compone sin mezclar responsabilidades:** `DiagnosticsPanel` no sabe qué es ejecutar; recibe un hueco
  `trailing` en su cabecera. `EditorDiagnosticsStrip` es quien decide llenarlo con `KeyboardExitActions` y quien
  envuelve
  la franja en el gesto de soltar el foco, y solo cuando el pie está oculto. `EditorSurface`, dueño del `FocusNode`,
  resuelve `canRun` con `report.isExecutable && executionState.canStart` —el mismo criterio que el pie— y no necesita
  ningún canal nuevo para bajar el teclado.
- **La petición de ejecutar no duplica la del pie.** `onRun` es un `VoidCallback` que baja desde `DocumentColumn`, donde
  ya vive `onPace`, atado a `onPace(editorState, StepPace.toEnd)`. El editor pide ejecutar; quién sabe con qué perfil e
  idioma sigue siendo `DocumentPage`, en un solo sitio.
- **La tecla de plantillas se muda al extremo izquierdo de la barra.** Su galón de desplegar y el glifo de ocultar
  teclado son dos cosas distintas y estaban quedando en el mismo borde. El reparto pasa a ser legible sin leer los
  iconos: izquierda, ayudas de escritura; derecha, salidas del modo escritura.
- **Alternativas descartadas y por qué:**
    - *Solo el botón de ocultar teclado:* Descartada. Deja dos gestos —cerrar y luego buscar el botón de ejecutar— para
      una única intención, y no toca la causa: que la acción primaria desaparezca.
    - *Devolver el `ExecutionStepper` completo mientras el teclado está levantado:* Descartada por alto. Apila 36 dp de
      diagnósticos, 64 dp de pie y 44 dp de teclas sobre un teclado de unos 336 dp; en un teléfono de 844 dp de alto el
      editor baja de unas doce líneas visibles a unas ocho.
    - *Cerrar el teclado al desplazar el campo de código (`ScrollViewKeyboardDismissBehavior.onDrag`):* Descartada
      aunque sea el idiom estándar en formularios. En un editor se desplaza para mirar una línea de más arriba
      **mientras
      se está componiendo**, y cerrar el teclado ahí castiga el uso normal.
    - *Un velo de toque sobre toda la pantalla:* Descartada. El editor ocupa casi todo el alto y un toque sobre el
      código debe colocar el cursor, no bajar el teclado. La franja contraída es la única superficie que no tiene ya un
      significado propio.
    - *Modelar ejecutar y ocultar como `EditorKey`:* Descartada. Ninguna de las dos inserta texto; meterlas en
      `EditorKeyKind` obligaría a `LexiconSourceEditor` a ramificar sobre casos que no son ediciones.
- **Objetivos táctiles y simetría vertical:** La franja de diagnósticos mide 36 dp en reposo, pero cuando aloja
  acciones de salida (`KeyboardExitActions`) escala su cabecera a 40 dp. Esto sitúa a los botones de 32 dp
  (`AppIconButton`)
  con un padding vertical simétrico de 4 dp arriba y 4 dp abajo, duplicando la holgura contra el borde superior con el
  editor y preservando al mismo tiempo el presupuesto de altura en pantallas compactas mínimas (360×640 px con teclado y
  ejercicio abiertos) sin provocar desbordamientos (`RenderFlex overflow`).
- **Disociación entre modo edición y foco de ejecución:** El foco didáctico (`ExecutionFocus`) solo se proyecta sobre el
  editor cuando una ejecución está en marcha (`isInFlight`). Cuando la persona edita código o pulsa teclas de edición,
  cualquier ejecución anterior se cancela de inmediato (`ExecutionCubit.stop()`) limpiando el foco remanente. En modo
  edición, el canalón (`LineNumbersGutter`) resalta exclusivamente la línea donde se sitúa el cursor del usuario, sin
  colorear fondos sobre el texto editable ni fragmentar palabras con rangos obsoletos.
- **Objetivos táctiles de la barra, corregidos en el mismo cambio:** La fila de teclas medía 44 dp y la de plantillas
  40,
  con áreas activas de 40 y 32 dp respectivamente, por debajo del mínimo táctil de 48. Ambas alturas pasan a leerse de
  `SpacingTokens.targetTouchMin`, que es el token que fija esa regla, en vez de repetir el número. La cara visible de la
  tecla y la del chip **no cambian**: siguen midiendo 32 dp, centradas dentro del área activa. Es la distinción que los
  fundamentos visuales ya hacían —el área activa no es el tamaño visible— y basta un `Center` dentro de cada pulsador
  para obtenerla; estirar las celdas de la fila habría agrandado también la cara. Hay test de tamaño para las tres
  superficies pulsables: tecla, tecla de plantillas y chip de plantilla.

### 4.35 Presencia de marca en la interfaz: firma en cuatro superficies, y ninguna más

- **Problema:** dentro de la aplicación no había marca. La identidad se sostenía sobre el ícono del sistema operativo
  —que se ve antes de entrar, nunca dentro— y sobre tres cadenas de texto que mencionaban el nombre. Quien usa la app a
  diario veía el símbolo una vez al tocar el ícono y no volvía a verlo, así que la asociación entre el objeto, la figura
  y
  el nombre no llegaba a formarse. El tono de marca, en cambio, ya era sistémico: la acción primaria, el enlace, el foco
  y
  el indicador de navegación salen de la escala `brand`. Lo que faltaba era la figura y el nombre, no el color.
- **Elección:** cuatro superficies, elegidas por identidad ganada frente a interfaz robada, y una prohibición explícita
  para todo lo demás.

| superficie                                                | qué aparece             | por qué esa y no otra                                                                                                                                |
|-----------------------------------------------------------|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| Pantalla de lanzamiento de iOS                            | símbolo, claro y oscuro | Es el primer fotograma de cada sesión y no cuesta ni un píxel de interfaz. Antes mostraba el logotipo de Flutter sobre blanco fijo                   |
| Paso de bienvenida de la introducción (`WelcomeStepView`) | símbolo                 | Sustituye a un `Icons.terminal_outlined` genérico, justo encima del único título que ya dice el nombre: figura y nombre llegan juntos y una sola vez |
| Cabecera del raíl de navegación (`_RailBrand`)            | símbolo                 | Única superficie permanente donde cabe sin quitar espacio: el raíl tiene ancho fijo y su parte alta no la ocupaba ningún destino                     |
| Pie de Ajustes (`VersionFooter`) y hoja de Contacto       | lockup horizontal       | Pie y membrete de documento son dos de los tres usos que la marca autoriza para el lockup horizontal                                                 |

- **Consecuencia:** en `compact` no hay firma permanente, y es deliberado: la barra inferior tiene cuatro destinos y no
  sobra espacio, y añadir una barra superior solo para el logotipo sería precisamente la intrusión que este diseño
  evita.
  En teléfono la marca se apoya en el lanzamiento, la introducción y los ajustes. En `medium` y `expanded` la firma del
  raíl acompaña toda la sesión.
- **La marca no es un ícono de interfaz, y de ahí salen las prohibiciones.** El set de trazo de la app tiene rejilla,
  grosor y ángulos propios; la marca no pertenece a él. Por eso el símbolo **no** se usa como ícono de destino de
  navegación, ni como ilustración de estado vacío —repetirlo lo quema, y en un estado vacío lo ata a un contexto
  negativo—, ni como ícono de un botón. Tampoco aparece como marca de agua sobre el ordinograma o la tabla de traza,
  donde el color y la geometría significan foco de ejecución, ni como indicador de carga animado, porque el símbolo no
  se rota ni se deforma.
- **El degradado de la placa es la única excepción a la interfaz neutra**, y está acotada al lockup. La placa reproduce
  el
  ícono que la persona ya reconoce de su pantalla de inicio, con su degradado, su esquina continua del 22.37 % y su
  aspecto claro y oscuro; fuera de ella, ninguna superficie de la app lleva relleno de marca.
- **Descartado:** el logotipo en la cabecera de cada pantalla, que rompe el ritmo vertical que `AppPage` existe para
  mantener; y una pantalla de presentación propia antes de la biblioteca, que añade latencia a un arranque que hoy es
  directo.

### 4.36 La política de autoguardado vive en el modelo, no entre los tokens

- **Problema:** el rebote del autoguardado del editor era un `Duration(milliseconds: 1500)` suelto dentro de
  `EditorCubit`, y el verificador de pureza de tokens lo marcaba —con razón: un tiempo sin nombre es un número mágico—.
  Pero el destino que la regla proponía, `presentation/theme/tokens/`, es inalcanzable desde `application`, que solo
  puede importar modelo y puertos. La regla y las capas se contradecían, y el resultado era un verificador en rojo que
  nadie podía poner en verde sin romper una de las dos.
- **Elección:** el valor pasa a `AutosavePolicy.debounce`, en `domain/model/editor/`. Un rebote de guardado no anima
  nada y no se percibe como movimiento: no es un tiempo de interfaz, es una política del producto, y el modelo es lo
  que la aplicación y la presentación comparten. En paralelo, el verificador deja de traer su lista de excepciones
  escrita dentro y la lee de `architecture.yaml`, como ya hacían sus hermanos.
- **Consecuencia:** el tiempo tiene nombre, tiene un archivo dueño y tiene escrito su porqué —por debajo, escribir una
  frase provoca varios guardados; por encima, un cierre repentino se lleva más texto del que la persona daría por
  perdido—. Y la próxima política de tiempo de la capa de aplicación tiene un sitio evidente donde ir.
- **Descartado:** inyectar el tiempo desde `composition`, que solo traslada el literal a otra capa que tampoco es su
  dueña; y ampliar la regla para admitir toda la capa de aplicación, que la vaciaría de sentido.

### 4.37 La marca dentro de la app es geometría redibujada, no un activo cargado

- **Problema:** `pubspec.yaml` no puede declarar activos fuera del directorio del paquete, así que los vectores que
  emite `packages/pseudolearn_brand` son inalcanzables desde aquí. Cargarlos exigía una copia a mano de un artefacto
  generado. `flutter_svg` sí está en el paquete desde §4.62, pero solo para las figuras que genera la especificación
  ilustrada; la marca sigue sin pasar por él.
- **Elección:** `presentation/brand/` redibuja el símbolo con las mismas primitivas que el generador de vectores —seis
  rectángulos de esquinas redondeadas de radio igual a la mitad del grosor, un círculo y un triángulo de esquinas a
  radio
  3, unidos por la regla de relleno `non-zero`— y compone el logotipo con IBM Plex Mono Medium e IBM Plex Sans Bold, que
  son las dos caras de las que se contornea el vector maestro y que el paquete ya empaqueta y verifica.
- **Consecuencia:** cero dependencias nuevas y cero activos copiados, y la pantalla de lanzamiento se rasteriza desde
  esta
  misma geometría (§2.7), así que el primer fotograma de la app y la imagen que lo precede no pueden diferir. El precio
  es
  que las medidas del símbolo existen en dos idiomas, Python y Dart. Se vigila con dos pruebas: la del lockup compara
  sus
  medidas contra los `viewBox` que el generador escribe, y una prueba de renderizado reduce el símbolo a 16, 24, 32 y 48 px.
- **La costura del logotipo se aplica como avance negativo tras la última letra de la mitad monoespaciada**, que es
  donde
  el generador la aplica al unir las dos mitades. El tracking solo afecta a la mitad de prosa: cerrar la monoespaciada
  destruiría la rejilla de paso constante, que es la señal que la hace leer como código.
- **El logotipo se pinta por su caja de tinta, no por su caja tipográfica:** la esquina superior izquierda del widget es
  la primera tinta de la «P». La línea base se mide en cada pintado en vez de fijarse como constante, porque las
  métricas verticales las pone la fuente y no el código que la coloca.
- **La placa se ata al centro de las versalitas y no al centro de la caja de tinta.** El logotipo tiene tinta por debajo
  de la línea base y por encima de la altura de versalita; centrar la placa por la caja la dejaría visiblemente
  descolgada respecto de la palabra.
- **Descartado:** `flutter_svg` con los vectores copiados a los activos; y emitir Dart desde el generador de Python, que
  quitaría la duplicación a cambio de meter generación de código en un repositorio que no tiene ninguna.

---

### 4.38 La familia tipográfica se declara donde el estilo no se funde con el heredado

- **Problema:** `ThemeData.fontFamily` solo alcanza a los estilos que se fusionan con el heredado. Un `Text` fusiona el
  estilo que recibe sobre el del `DefaultTextStyle`, así que un `TextStyle(color: …, fontSize: 13)` dentro de un widget
  hereda la familia sin decir nada. Otros dos consumidores no la heredan: el tema de componente —
  `NavigationRailThemeData`,
  `NavigationBarThemeData`, `DropdownButton.style`, `TooltipThemeData`— sustituye el estilo por defecto en vez de
  fundirse
  con él, y el `TextPainter` de un `CustomPainter` no tiene ningún estilo del que heredar. En ambos casos el motor caía
  a
  la familia del sistema: las etiquetas de navegación y todo el texto de los tres diagramas se pintaban en SF Pro, no en
  IBM Plex, contra la regla de que ningún valor vive fuera de las escalas.
- **Por qué no se había visto:** el fallo no produce error ni texto ilegible en un dispositivo, solo otra tipografía; y
  en
  el motor de pruebas, que rasteriza con un tipo de relleno, produce bloques. Lo destapó la herramienta de §2.8 al
  fotografiar la pantalla del documento.
- **Elección:** la extensión `presentation/theme/font_role_style.dart` aplica la familia y su cadena de reemplazo a
  partir
  del papel —`ui` o `code`— sobre un `TextStyle` ya construido. Los dos consumidores que no heredan la piden
  explícitamente; el resto sigue heredándola y no cambia.
- **Consecuencia:** el texto de los ordinogramas, los estructogramas y los diagramas de clases pasa a pintarse con la
  familia empaquetada, igual que el resto de la interfaz; las pruebas de renderizado comprueban su composición. A cambio, un
  `TextStyle` suelto en un widget sigue siendo correcto sin ceremonia: la extensión solo aparece donde hace falta, que
  es
  justo donde el compilador nunca iba a avisar.
- **Descartado:** repetir `fontFamily:` y `fontFamilyFallback:` en cada sitio, que duplica la decisión tantas veces como
  estilos haya; y registrar la familia bajo el nombre que el motor usa por defecto, que arreglaría la captura sin
  arreglar
  la app.

---

### 4.39 Cargar un ejercicio ya cargado es destructivo, así que la sesión no lo recarga

- **Problema:** `document_page.dart` escucha los cambios del estado del editor y, si el documento tiene ejercicio
  asociado, pide `loadExercise`. El oyente se dispara cuando cambia el código fuente **o** el documento, y guardar el
  documento cambia el documento. Al tocar «Ejecutar» sobre un ejercicio con cambios sin guardar, la secuencia real era
  `checking → success → loading → loading → ready → ready`: la comprobación acertaba y las dos recargas que provocaban
  los guardados la borraban. Para quien usa la app, el «resuelto» aparecía y desaparecía.
- **Elección:** `ExerciseSessionCubit` ignora una carga del mismo ejercicio en el mismo idioma cuando ya lo tiene. La
  identidad de la petición se guarda en dos campos privados del cubit, no en el estado, porque ninguna vista la muestra;
  y se escribe solo cuando la carga acierta, para que un fallo no bloquee el reintento.
- **Por qué ahí y no en el oyente:** el enunciado, los casos y las aserciones de un ejercicio no dependen del código que
  la persona esté escribiendo, así que recargarlos por un cambio de fuente no es solo trabajo de más. Poner la guarda en
  el cubit protege a cualquier llamante, no solo al que hoy provoca el fallo.
- **Consecuencia:** un cambio de idioma sigue recargando, porque la ruta del ejercicio depende del idioma y la guarda
  compara los dos valores. Tres tests cubren los tres caminos: que la comprobación sobreviva a la recarga, que el cambio
  de idioma sí recargue, y que un fallo de carga no impida reintentar el mismo identificador.
- **Descartado:** comparar en `document_page.dart` contra `state.exercise?.id` antes de llamar, que deja la invariante
  en
  el llamante y obliga a repetirla en el siguiente; y reordenar el guardado y la comprobación dentro de `_onPace`, que
  no
  arregla nada porque el oyente se dispara igual, solo que más tarde.

### 4.40 Canal de distribución de macOS: Mac App Store, porque el flujo nativo de Apple no es firmable fuera de ella

- **Problema:** `SignInWithApple.getAppleIDCredential` exige el entitlement `com.apple.developer.applesignin`. Ese
  entitlement es *restringido*: AMFI solo lo admite si un perfil de aprovisionamiento embebido en el bundle lo declara
  para el identificador de la app. Los perfiles que Apple emite para el canal *Developer ID* no lo declaran, esté o no
  activada la capacidad *Sign In with Apple* en el App ID, porque esa capacidad pertenece a los canales de App Store y
  de
  desarrollo. Un bundle firmado con el entitlement recibe `SIGKILL` en el arranque y macOS muestra «La aplicación no se
  puede abrir», con firma válida, notarización grapada y `spctl` aceptando la app.
- **Elección:** la app de macOS se publica en la Mac App Store, el mismo canal que la de iOS. Ese canal autoriza el
  entitlement y, por la directriz 4.8 de App Review, lo exige: toda app que ofrezca inicio de sesión social de terceros
  —aquí, Google— debe ofrecer también Sign in with Apple. `Release.entitlements` lo declara junto a
  `com.apple.security.app-sandbox`, que ese canal impone y que el almacenamiento de la app ya cumple por confinarse a
  `getApplicationDocumentsDirectory()`. En iOS, `ios/Runner/Runner.entitlements` declara el mismo
  `com.apple.developer.applesignin` y las tres configuraciones del target `Runner` (Debug, Profile, Release) lo
  referencian con `CODE_SIGN_ENTITLEMENTS`; sin ese archivo, la firma automática no incluye el entitlement y
  `getAppleIDCredential` falla con `AuthorizationErrorCode.unknown` en todo build de iOS. El flujo nativo de
  `ASAuthorization` queda idéntico en las dos plataformas y `AuthMethod.apple` no necesita variante por sistema
  operativo.
- **Alternativas descartadas y por qué:**
    - *Regenerar el perfil Developer ID con la capacidad activada en el App ID:* Apple emite el perfil sin el
      entitlement. No es un defecto de configuración y ninguna regeneración lo corrige.
    - *Retirar el proveedor de Apple de la interfaz de macOS y conservar la distribución directa:* recorta una vía de
      acceso en el primer contacto del usuario con la app, y en el canal de App Store constituiría un motivo de rechazo.
    - *Conservar el entitlement bajo Developer ID y absorber el fallo en tiempo de ejecución:* el binario no arranca en
      ninguna máquina, de modo que rompe la app entera y no solo un proveedor.
    - *Canje web de Apple contra Supabase:* evita el entitlement abriendo el punto de autorización de Apple en el
      navegador contra un *Services ID*, con retorno por el enlace profundo `pseudolearn://` (§4.32). Añade un *Services
      ID*, su dominio y su URL de retorno a la superficie de configuración, y deja dos flujos de Apple
      distintos según la plataforma, para sortear una limitación que el canal de App Store no tiene.
    - *Mantener los dos canales, `.dmg` y App Store:* duplica certificados, perfiles, pipelines y ficha de producto, y
      obliga a sostener dos juegos de entitlements divergentes de forma permanente.

### 4.41 Composición automatizada del material de tiendas: aplicación viva en marco con codificación PNG opaca

- **Problema:** Las tiendas de aplicaciones (App Store de Apple y Google Play Store) imponen especificaciones estrictas
  e
  inflexibles para los activos promocionales: rechazan imágenes con canal alfa o píxeles translúcidos (incluso si el
  lienzo parece visualmente opaco, si el encabezado PNG declara color type 6 / RGBA la subida es rechazada), imponen
  resoluciones exactas por clase de dispositivo (iPhone 6.9", iPad 13", Mac 16:10, Play Store 16:9 y Feature Graphic
  1024×500), penalizan titulares con vocabulario promocional prohibido (precios, plataformas rivales, superlativos o
  llamadas a la acción), y descalifican capturas vacías que no demuestren el producto en uso real. La preparación manual
  en herramientas de diseño externo genera divergencia visual constante frente a los tokens de color y fuentes de la
  aplicación, requiere un mantenimiento costoso por idioma y expone el proceso a canales alfa residuales generados por
  herramientas gráficas.
- **Elección:** El material de tiendas se compone y rasteriza mediante pruebas de widget en
  `tool/generate_store_material.dart`. La herramienta monta el armazón vivo de la aplicación (`AppStage` con
  `CubitScope` y dependencias inyectadas), ejecuta secuencias interactivas sobre widgets reales (abrir documentos,
  avanzar
  pasos de depuración, expandir salidas y abrir paneles acompañantes) y aloja la vista dentro de un marco (`PromoFrame`)
  con gradiente semántico, sombra de elevación de nivel 3 y titular localizado (`es`/`en`). Los píxeles crudos de la
  superficie se procesan mediante un codificador PNG propio (`opaque_png.dart`) que valida la opacidad absoluta (alfa
  estricto de 255 en cada píxel) y emite un flujo Truecolour puro (color type 2) con filtro Paeth y compresión Deflate.
  Tres verificadores mecánicos custodian el proceso: inspección de avance tipográfico para descartar la fuente de
  relleno de pruebas, auditoría léxica del titular contra directrices de tienda (`marketing_lexicon.dart`) y
  comprobación
  geométrica de desbordamiento en el marco.
- **Alternativas descartadas y por qué:**
    - *Composición manual en herramientas de diseño vectorial (Figma / Illustrator):* desacopla el material del código,
      obliga a reconstruir manualmente pantallas ante cualquier cambio en tokens o diagramas, y no previene errores
      humanos en dimensiones o inclusión involuntaria de canales alfa.
    - *Captura manual de pantalla sobre simuladores:* inconsistente entre resoluciones de ventana, incapaz de fijar un
      estado determinista idéntico en cada versión, carente de marcos y titulares integrados, y dependiente del estado
      del
      sistema operativo del host.
    - *Uso de frameworks de automatización pesados (`fastlane snapshot`, `integration_test` en emuladores):* requiere
      levantar emuladores completos y lentos, añade dependencias complejas de integración continua y no ofrece control a
      nivel de bytes sobre el encabezado y tipo de color del archivo PNG resultante.
    - *Exportación estándar mediante `toByteData(format: ImageByteFormat.png)` de `dart:ui`:* la implementación nativa
      de la plataforma emite invariablemente PNGs con canal alfa (RGBA, tipo de color 6), lo que provoca el rechazo
      automático de los activos en los validadores de carga de App Store Connect y Google Play Console.

### 4.42 Eliminación de cuenta confirmada por servidor, con reautenticación de Apple y purga local sin lápidas

- **Problema:** La directriz 5.1.1(v) de App Store exige eliminar la cuenta, no solo sus datos, y revocar el token de
  Sign in with Apple. Revocar exige la clave `.p8` de desarrollador, que no puede viajar en el cliente, y un código de
  autorización fresco. Además, borrar documentos por `SyncingDocumentRepository` encola una lápida por documento en el
  outbox, que ningún servidor puede ya aceptar y que contaminaría la biblioteca de la siguiente cuenta.
- **Elección:**
    - `AccountDeletionGateway` (`domain/ports/`) expone un único método, `deleteAccount()`, que devuelve la clase
      sellada `AccountDeletionOutcome`: `AccountDeleted`, `AccountDeletionCancelled`, `AccountDeletionNoConnection`,
      `AccountDeletionRejected(code)`. Nunca lanza. Es un puerto propio porque `AuthGateway` ya tiene cinco métodos
      públicos y porque eliminar la cuenta no es responsabilidad de `RemoteDocumentStore`.
    - `SupabaseAccountDeletionGateway` (`data/auth/`) detecta una identidad `apple` en `User.identities` o en
      `app_metadata.providers`. Si la hay, pide a `NativeCredentialSource` una autorización nueva (`null` →
      `AccountDeletionCancelled`, sin llamar al servidor) y envía solo `apple_authorization_code`. Si la plataforma no
      tiene Apple nativo (`NativeCredentialSource.isAppleSupported` falso, hoy Windows), devuelve
      `Rejected('apple_reauthentication_unavailable')` sin abrir la hoja ni llamar al servidor: el código que el flujo
      web emitiría pertenece al Services ID, y la Edge Function solo canjea códigos del Bundle ID. Invoca
      `functions.invoke('delete-account')`. `FunctionsFetchException` y `SocketException` → `NoConnection`;
      `FunctionException` → `Rejected` con el `code` del cuerpo o `http_<estado>`; cualquier otra excepción →
      `Rejected('unexpected_failure')`; sin usuario → `Rejected('no_session')`.
    - `AccountCubit.deleteAccount()` actúa solo desde `AccountAuthenticated` o `AccountDeletionFailed`; emite
      `AccountDeletingAccount` e ignora invocaciones y eventos de sesión mientras dura. Con `AccountDeleted` cierra la
      sesión local y llama a `LocalAccountDataPurger.purgeAccountData()`; si la purga lanza, emite
      `AccountError('local_cleanup_failed')`. Con `Cancelled` vuelve a `AccountAuthenticated`. Con `NoConnection` y
      `Rejected` emite `AccountDeletionFailed(session, code)` sin tocar sesión ni datos.
    - `LocalAccountDataPurgerAdapter` (`data/sync/`) vacía en una transacción SQLite `sync_outbox`, `sync_state`,
      `content_progress` y `documents_index`, y después borra los archivos `.pseudo` y `.pseudo.tmp` del directorio de
      documentos. Conserva las preferencias. No pasa por `SyncingDocumentRepository`, así que no encola lápidas.
    - La presentación mapea los códigos del backend: `no_connection`, los cuatro `apple_*` y el resto a un aviso
      genérico; `apple_reauthentication_unavailable` a un aviso que pide eliminar la cuenta desde un iPhone, iPad o Mac; `local_cleanup_failed` a un aviso de datos remanentes en el dispositivo.
    - Las ramas del armazón (`StatefulShellRoute.indexedStack`) conservan sus páginas vivas y cada cubit de datos
      locales carga una sola vez al montar su página. `LocalAccountDataRefresher` (`presentation/settings/account/`),
      montado en `CubitScope` por encima del router, escucha `AccountCubit` y, cuando
      `isLocalAccountDataPurge(previous, current)` (`application/account/`) detecta la transición
      `AccountDeletingAccount → AccountUnauthenticated`, recarga `LibraryCubit`, `DashboardCubit`,
      `LearningRouteCubit` y `ExerciseBankCubit` y notifica a `SyncCubit`. Sin esa recarga, «Mis algoritmos» sigue
      mostrando documentos ya borrados del disco hasta reiniciar la app.
- **Alternativas descartadas y por qué:**
    - *RPC SQL `delete_account` invocada con la clave publicable:* no elimina el usuario de `auth.users` ni revoca
      Apple, y su fallo no se distinguía de un éxito.
    - *Borrar los datos locales aunque el servidor falle:* deja una cuenta viva en el servidor y un dispositivo vacío,
      y la persona cree haber eliminado una cuenta que sigue existiendo.
    - *Revocar Apple desde el cliente:* exige embeber la clave `.p8` en el binario.
    - *Enviar el `identityToken` y el nonce para que el servidor los verifique:* el `id_token` que Apple devuelve al
      canjear el código ya prueba la identidad (`apps/pseudolearn_backend/README.md`, decisión sobre la identidad de
      Apple).
    - *Recargar cada página desde un `BlocListener` propio:* repite la misma condición en tres páginas y obliga a
      cada test de página a proveer `AccountCubit`.
    - *Añadir `deleteAccount` a `AuthGateway`:* supera el límite de métodos públicos y obliga a todo consumidor de
      autenticación a conocer la eliminación.

### 4.43 Inicialización de SQLite FFI en escritorio y restricciones de ventana en Windows

- **Problema:** En Windows (y Linux), el paquete `sqflite` carece de implementación por canales de plataforma nativos y
  requiere activar el backend FFI (`sqflite_common_ffi`) antes de cualquier invocación a `openDatabase()`. Además, la
  arquitectura impone una prohibición estricta de consultas a `Platform` en `lib/` fuera de los archivos declarados en
  `platform_query_allowed_paths`. Asimismo, en Windows el usuario puede redimensionar la ventana arbitrariamente, lo que
  rompería las aserciones visuales del lienzo si el tamaño cae por debajo de la clase de dispositivo mínima (320 × 568 dp).
- **Elección:**
    - La inicialización de la factoría SQLite se encapsula en `initializePlatformDatabaseFactory()` dentro de
      `data/platform/platform_database_factory.dart`. Es el único archivo autorizado junto con
      `platform_text_entry_modality.dart` y `platform_native_auth_support.dart` para consultar `Platform.is*`.
    - Se invoca de forma determinista en `main.dart` inmediatamente después de `WidgetsFlutterBinding.ensureInitialized()`.
      Soporta el parámetro opcional `forceFfi` para permitir pruebas unitarias aisladas sin alterar el entorno del host.
    - Las restricciones de tamaño mínimo de ventana se aplican a nivel nativo en C++ en `windows/runner/win32_window.cpp`
      mediante la intercepción del mensaje `WM_GETMINMAXINFO`, escalando los límites de 320 × 568 dp según el DPI del monitor.
- **Alternativas descartadas y por qué:**
    - *Consultar `Platform.isWindows` directamente en `main.dart`:* Rompe el invariante de arquitectura de que las
      preguntas por el sistema operativo pertenecen con exclusividad a adaptadores de `data/platform/`.
    - *Inicializar FFI incondicionalmente en todas las plataformas:* En macOS e iOS `sqflite` cuenta con implementaciones
      nativas en Objective-C/Swift optimizadas que se integran con los ciclos de vida del sistema sin sobrecarga FFI.
    - *Usar un plugin de Flutter de terceros para restringir la ventana:* Introduce dependencias innecesarias cuando la
      API nativa de Win32 (`WM_GETMINMAXINFO`) en el runner existente lo resuelve de forma limpia y directa.

### 4.44 Autenticación unificada en Windows mediante Web OAuth y desacoplamiento de enlaces externos

- **Problema:** En Windows, los plugins oficiales de autenticación nativa (`sign_in_with_apple` y `google_sign_in`)
  carecen de implementación nativa o lanzan excepciones de plataforma no soportada. La aplicación debe mantener paridad
  absoluta de métodos de inicio de sesión (Apple, Google, Magic Link) sin introducir ramificaciones de plataforma
  prohibidas en la capa de datos o presentación.
- **Elección:**
    - Se define el puerto `ExternalUrlLauncher` en `domain/ports/external_url_launcher.dart` y su adaptador
      `PlatformExternalUrlLauncher` en `data/platform/platform_external_url_launcher.dart` utilizando `package:url_launcher`
      en modo aplicación externa (`LaunchMode.externalApplication`).
    - La consulta de disponibilidad de SDKs nativos se abstrae en `NativeAuthSupport` (`data/auth/`) y se implementa
      exclusivamente en `PlatformNativeAuthSupport` (`data/platform/platform_native_auth_support.dart`), declarada en
      `platform_query_allowed_paths`.
    - En `SupabaseAuthGateway`, cuando el soporte nativo no está disponible (Windows), las solicitudes de Apple o Google
      derivan a la URL de autorización Web OAuth de Supabase (`_client.auth.getOAuthSignInUrl`) con redirección a
      `pseudolearn://auth-callback` y abren el navegador predeterminado del sistema.
    - La respuesta de autorización es interceptada por el manejador del protocolo de Windows en `windows/runner/main.cpp`
      vía `SendAppLinkToInstance`, recibida por `AppLinksIncomingLinkSource` y finalizada en
      `SupabaseAuthGateway.completeSignInFromLink` mediante `_client.auth.getSessionFromUrl`.
- **Alternativas descartadas y por qué:**
    - *Ocultar los botones de Apple y Google en Windows:* Rompe el principio de paridad funcional entre plataformas y
      degrada la experiencia de usuario.
    - *Embeber un WebView en la ventana de Flutter:* Genera riesgos de seguridad y es rechazado activamente por Google
      OAuth ("disallowed_useragent"). Abrir el navegador del sistema es el estándar recomendado (RFC 8252).
    - *Consultar `Platform.isWindows` en `SupabaseAuthGateway`:* Viola las reglas de arquitectura y la frontera de capas
      definida en `architecture.yaml`.

### 4.45 La versión que muestra Ajustes se lee de la compilación instalada, no de un literal

- **Problema:** el pie de Ajustes mostraba `v1.0.0` escrito a mano en la presentación. Al subir la versión de mercado en
  `pubspec.yaml` el binario instalado seguía anunciando la anterior, porque nada obligaba a mantener los dos valores
  iguales.
- **Elección:**
    - `pubspec.yaml` sigue siendo la fuente única de la versión de mercado (§2.6). La aplicación la lee en ejecución con
      `package:package_info_plus`, que expone la versión con la que se compiló el binario en iOS, macOS y Windows.
    - El puerto `AppVersionSource` (`domain/ports/app_version_source.dart`) y su adaptador `PlatformAppVersionSource`
      (`data/platform/platform_app_version_source.dart`) encapsulan la lectura; `AppVersionCubit` la publica y
      `SettingsOverviewPage` se la entrega como texto a `SettingsOverviewView`, que sigue siendo una vista sin cubits.
    - Antes de que la lectura termine el estado es una cadena vacía y el pie muestra solo el logotipo con su versión
      vacía; la lectura es local y casi instantánea, por lo que no se añade un estado de carga.
- **Alternativas descartadas y por qué:**
    - *Inyectar la versión con `--dart-define` desde cada workflow:* duplica la fuente de verdad en tres workflows y
      un build local olvidaría el valor.
    - *Añadir la versión a `SettingsCubit`:* la versión no es una preferencia; mezcla dos razones de cambio y obligaría
      a tocar todos los tests que construyen ese cubit.
    - *Seguir con el literal y actualizarlo a mano en cada release:* es el defecto que motiva esta decisión.

### 4.46 Petición de reseña nativa en hitos de ejercicios resueltos, solo donde hay tienda

- **Problema:** la posición en App Store depende de las valoraciones, y la app no pedía ninguna. Pedirla en un momento
  arbitrario (al abrir, tras un tiempo de uso) llega cuando la persona no ha obtenido nada todavía, y Apple solo permite
  mostrar el diálogo nativo tres veces cada 365 días por usuario: cada petición gastada sin satisfacción es irrecuperable.
- **Elección:**
    - **Momento:** la petición sale al resolver por primera vez un ejercicio cuando el total de ejercicios resueltos
      alcanza un hito. Los hitos son un dato, `ReviewPromptPolicy.standard` (`domain/model/review/`): 1, 10 y 30. Tres
      hitos, a juego con el tope anual de Apple. Volver a resolver un ejercicio ya resuelto no cuenta.
    - **Disparo sin tocar la sesión de ejercicio:** `ReviewPromptingProgressStore` (`application/review/`) decora
      `LocalProgressStore` igual que `SyncingDocumentRepository` decora el repositorio de documentos (§4.27): primero
      persiste la marca en el almacén interno y después consulta la política. `ExerciseSessionCubit` no gana una segunda
      razón de cambio y no sabe que existe la reseña. Solo ese cubit llama a `markExerciseCompleted`; el progreso que
      llega por sincronización entra por SQL en `data/sync/` y no dispara la petición.
    - **Plataforma:** el puerto `StoreReviewPrompt` (`domain/ports/`) lo implementa `PlatformStoreReviewPrompt`
      (`data/platform/`) con `package:in_app_review`, que llama a `SKStoreReviewController` en iOS y macOS. En Windows el
      paquete no registra plugin nativo: `isAvailable()` responde `false` y el adaptador no hace nada. Por eso el adaptador
      no pregunta por el sistema operativo y no figura en `platform_query_allowed_paths`, y la composición lo cablea sin
      condicional en todas las plataformas.
    - **Contrato del puerto:** `request()` nunca lanza. El adaptador absorbe `MissingPluginException` y
      `PlatformException`, porque una reseña fallida no puede convertir en error un ejercicio resuelto.
    - **Privacidad (§6.6):** el recuento es local, sale del mismo `content_progress` que el panel de progreso, y la app no
      envía nada a ningún servidor. El diálogo y su resultado pertenecen al sistema operativo; la app no sabe si la persona
      valoró ni con cuántas estrellas.
    - **Comportamiento esperado al verificar:** en compilaciones de desarrollo el diálogo aparece siempre, en TestFlight
      no aparece nunca, y en la versión publicada lo decide Apple. Que no salga en TestFlight no es un fallo.
    - **Límite conocido:** un hito se compara por igualdad. Si una sincronización hace saltar el total por encima de un
      hito (de 9 a 12, por ejemplo), ese hito se pierde. Se acepta: cuesta una petición de tres, y comparar por cruce
      exigiría persistir qué hitos se usaron.
- **Alternativas descartadas y por qué:**
    - *Llamar a la reseña desde `ExerciseSessionCubit`:* añade al cubit una dependencia y una razón de cambio ajenas a
      comprobar ejercicios.
    - *Un botón «Valorar la app»:* Apple prohíbe invocar la petición nativa desde un botón; un enlace a la ficha no
      cuenta con el tope ni con el diálogo dentro de la app.
    - *Pedirla al terminar el Tramo A:* ata la política a la organización del temario, que puede cambiar; contar ejercicios
      resueltos no depende de ella.
    - *Preguntar antes con un diálogo propio («¿Te gusta PseudoLearn?»):* filtra a quien está contento hacia la tienda y
      a quien no hacia otro sitio, práctica que las directrices de Apple desaconsejan, y añade texto que traducir.

### 4.47 Versión exacta de Flutter fijada en `pubspec.yaml` y leída por los workflows

- **Problema:** la generación de localizaciones, enlaces nativos y capturas depende del SDK y del motor de rasterización.
- **Elección:** `environment.flutter` declara `3.47.5` como fuente única. `flutter pub get` rechaza otra versión y los
  workflows la leen con `flutter-version-file` de `subosito/flutter-action`. Un cambio de SDK regenera los artefactos
  locales y ejecuta las verificaciones de renderizado y layout.
- **Alternativas descartadas:** repetir el número en cada workflow o añadir otro gestor de versiones, porque ambos
  duplican la fuente declarada en `pubspec.yaml`.

### 4.48 Verificación visual sin capturas de referencia

- **Problema:** los PNG versionados fijaban la salida de rasterización del sistema anfitrión y acumulaban 178 imágenes.
- **Elección:** las pruebas de widgets verifican presencia, layout y ausencia de excepciones de renderizado. No guardan
  comparaciones de píxeles; una regresión visual pequeña requiere revisar la pantalla renderizada.
- **Límite:** este control detecta fallos de composición y desbordamientos, no diferencias sutiles de color o tipografía.

### 4.49 Frontera síncrona Rust–Dart con handles y Native Assets

- **Problema:** Los puertos de análisis y ejecución son síncronos, `ApiSession` contiene estado `!Sync` y el código
  generado de FFI tiene convenciones que no coinciden con las del código escrito a mano.
- **Elección:** `flutter_rust_bridge`, su generador y `flutter_rust_bridge_hooks` se fijan juntos en `2.13.0`.
  El backend elegido es Native Assets; la integración conserva desactivada la feature `native` de `pseudolearn_api`.
  El transporte HTTP con Hyper y Rustls reside en `pseudolearn_host`, compartido con la CLI; el puente
  incorpora transporte y raíces TLS de plataforma, conservando excluidos AOT, Cranelift y `test-host`. `rust-checks isolation` verifica los destinos nativos y `cargo tree --locked -e normal` permite revisar el grafo
  fijado del puente desde `native/`.
  Las operaciones de frontera se declaran `#[frb(sync)]`; la configuración deja `default_dart_async: false`.
  La sesión vive en un registro local al hilo invocador y Dart transporta un handle `u64`; `ApiSession` no se expone
  como objeto opaco ni cruza hilos. El handle llega a Dart como `BigInt`, por lo que conserva todo el rango `u64`.
- **Vida de los buffers:** El codec SSE crea un mensaje serializado por llamada y transfiere la propiedad de su
  bloque entre Dart y Rust. Rust decodifica valores dueños como `String` y estructuras; al finalizar se descartan el
  decoder y su bloque. No se retienen punteros ni vistas prestadas entre llamadas. Los consumidores intercambian
  parámetros y resultados por valor, no un estado de memoria compartido.
- **Código generado:** Solo `native/src/frb_generated.rs` y el subárbol `lib/engine/bridge/` pueden contener los
  comentarios, atributos, bloques `unsafe` y `unwrap` que FRB emite. Son salidas ignoradas del generador y su
  versión fijada; `bash tool/bridge.sh check` compara dos generaciones locales consecutivas. `analysis_options.yaml`
  excluye el subárbol Dart generado
  del análisis estático. Todo wrapper escrito a mano permanece sujeto a los límites y verificadores ordinarios. Las
  exenciones se limitan a esas rutas exactas.
- **Responsabilidad del crate:** `native/` es un miembro Cargo separado, con lock, auditoría de dependencias y
  reglas Rust propias. `native/src/api.rs` expone creación, llamada y cierre de sesión; las operaciones y
  capacidades siguen siendo las de `pseudolearn_api`. El registro libera los recursos descendientes cuando se
  cierra una sesión. `hook/build.dart` compila la biblioteca por Native Assets sin incorporar el feature `native`.
- **Identidad estructural y páginas:** La API anuncia `program_view` y `state_pages`. Cada evento lleva
  `source.node_id` resuelto por coincidencia exacta del tramo (línea y columna de inicio y fin) contra la vista del
  documento, nunca por línea; dos sentencias en una misma línea tienen identidades distintas. Las consultas
  paginadas usan cursores opacos ligados a sesión, revisión, ejecución, consulta, evento y tamaño de página.
- **Adaptadores (`lib/engine/rust/`):** `RustTransport` es la única frontera que ve JSON; `JsonRustTransport` la
  implementa sobre cualquier función de envío y `native_rust_transport.dart` es el único archivo que importa los
  enlaces generados. `RustProgramAnalyzer` implementa `ProgramAnalyzer` y `RustProgramExecution` implementa
  `ProgramExecution`: cada `step()` consume un evento de un lote de 25 y proyecta el índice global, la tarea activa y
  contextos de foco, pila y variables segregados por `task_id`. Las consultas de marcos y colecciones pasan el mismo
  `task_id` junto con el evento consumido; una consulta inválida produce un fallo del paso. El texto y el carácter se
  muestran entre comillas según la etiqueta de tipo de la API; los arreglos muestran forma y dimensiones. `RustBatch`
  y `RustTerminationKind` reconocen `awaitingEffect` junto con `PendingEffectRequest`, permitiendo que la interfaz o el
  entorno orquestador suministren el resultado del efecto mediante `provideEffectResult` y reanuden la máquina.
  `analyze` devuelve los tokens léxicos y sus tramos, y el adaptador proyecta categorías de resaltado desde ellos
  incluso cuando hay errores sintácticos. La categoría de cada palabra reservada sale de
  `keyword_highlight_categories.dart`, un mapa por identidad del vocabulario; antes `RustSyntaxHighlighter` repartía las
  identidades en `switch` escritos a mano y 30 de las 103 de D1 (`Funcion`, `Tareas`, `Opcional`, `Algo`, `Importar`…)
  quedaban sin color. El mapa repite las categorías de `packages/pseudolearn_reference/categories.json`, que el libro
  usa para pintar sus programas; `test/engine/rust/keyword_highlight_categories_test.dart` exige que cubra exactamente
  las identidades de D1 de la exportación del corpus con la misma categoría que el libro, así que una identidad nueva o
  una categoría distinta rompe el test en lugar de quedar sin color. Se descartó leer el JSON en tiempo de ejecución:
  el resaltador es síncrono y la categoría no existe todavía en el corpus. El idioma de los mensajes de diagnóstico se negocia con un `locale`
  independiente del perfil, y `AppDiagnostic` conserva los argumentos del motor. Los cuatro ritmos no tienen código
  propio: `StepSettlement` decide solo con `focusRevision`,
  `blockPosition` y `nodeId`, que el adaptador reproduce según las reglas de foco de los puertos de la aplicación
  (un contenedor no mueve el foco; una llamada o retorno conserva el nodo anterior). El foco resuelve `unitId`
  recorriendo el subárbol de la unidad ejecutable o del miembro de clase desde la misma vista pública, con los
  identificadores que usan los diagramas. El estado se consulta por
  evento y solo de los marcos activos; arreglos y objetos se describen por consulta paginada (`[n]`, `Clase#id`) sin
  materializar el montón. `RustCompletionSource`, las fuentes de plantillas y vocabulario y los lectores de
  construcciones y aserciones estructurales usan las operaciones públicas del servicio. Los tres adaptadores de
  diagramas construyen sus modelos desde `program_view`, que aporta roles de hijos, unidades, miembros, tipos,
  dimensiones e identidades compatibles con los eventos. `RustProgramExporter` produce el código equivalente y
  `RustSyntaxReferenceSource` resuelve marcadores y tablas con `reference_vocabulary`, `editor_vocabulary` y
  `diagnostic_template`; la app solo conserva el orden de presentación. `buildRustEngineServices` ensambla todos los
  puertos mediante la API pública y `rust_composition_isolation_test.dart` recorre las importaciones alcanzables
  desde él para comprobarlo.
- **Lenguaje único:** el lenguaje es uno solo. Ni el documento, ni la configuración de ejecución, ni las solicitudes al
  puente llevan un parámetro que cambie las reglas: análisis, completado, ayuda y severidades de los marcadores coinciden.
- **Diferencias conocidas entre composiciones** (la suite de equivalencia exige que sean exactamente estas):
  Rust informa `unusedParameter` como advertencia (el corpus declara códigos propios para parámetros no usados) y no
  duplica diagnósticos que carecen de una causa independiente; los diagramas Rust rotulan con el texto fuente del usuario en
  lugar de un texto normalizado, por lo que la suite compara unidades y formas de nodo, no rótulos; las listas de
  funciones y palabras de la referencia salen en orden alfabético de identidad y los tipos con su ortografía de
  palabra clave (`Entero`); las plantillas del editor son las verificadas por el servicio de lenguaje.
- **Biblioteca nativa de las pruebas:** `test/` carga `native/target/release/` y no la recompila. Antes de
  `flutter test` ejecute `cargo build --release --locked --lib --manifest-path native/Cargo.toml` (lo hace
  `tool/test_bridge.sh`); `native_library_freshness_test.dart` falla si la biblioteca es anterior a cualquier fuente Rust.
- **Verificación del puente:** `bash tool/bridge.sh clean-checkout` crea un árbol de trabajo limpio, instala
  dependencias, regenera los enlaces y exige que no difieran del estado que se verifica. Requiere
  `flutter_rust_bridge_codegen 2.13.0` y `cargo-expand 1.0.127` instalados. El archivo Dart generado se versiona tal
  como lo emite el generador, sin pasadas posteriores de `dart fix`.
- **Alternativas descartadas:** Exponer `ApiSession` como objeto opaco exige `Sync`; no satisface el tipo de máquina
  actual. Las llamadas asíncronas o un worker cambian el contrato de los puertos. Cargokit se descarta porque FRB
  ofrece el backend Native Assets en la versión fijada y la app ya mantiene su versión exacta de Flutter.
- **Fuentes:** [FRB 2.13.0](https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v2.13.0),
  [llamadas síncronas](https://cjycode.com/flutter_rust_bridge/guides/concurrency/sync-dart),
  [modelo de concurrencia](https://cjycode.com/flutter_rust_bridge/guides/concurrency/overview),
  [Native Assets](https://github.com/fzyzcjy/flutter_rust_bridge/blob/master/website/docs/manual/integrate/03-native-assets.md).

### 4.50 Carga y distribución del puente nativo por plataforma

- **Problema:** la biblioteca Rust debe estar disponible al arrancar la app, conservar las arquitecturas declaradas y
  viajar en cada artefacto sin requerir un checkout ni una instalación de Rust en el dispositivo.
- **Elección:** `hook/build.dart` compila con el toolchain exacto y registra la biblioteca como Native Asset. Flutter
  produce una app macOS universal y un `pseudolearn_bridge.framework` con slices arm64/x86_64; iOS compila la
  biblioteca para dispositivo y simulador; Windows copia `pseudolearn_bridge.dll` al bundle mediante CMake. Los
  workflows prueban el asset generado y verifican su presencia en el MSIX, el instalador y el ZIP portable. La
  ejecución de la app usa el cargador de FRB, no `native/target`.
- **Firma de macOS:** Release desactiva la firma de Xcode. El workflow agrega el perfil restringido de Mac App Store y
  firma el framework Rust y el bundle después del build. La compilación local entrega un `.app` sin firma.
- **Android:** queda fuera del alcance de la app; ningún contrato de rendimiento ni de tamaño lo mide ni lo
  menciona. Los builds de R8 no compilan ni distribuyen la app Flutter para Android.
- **Alternativas descartadas:** cargar binarios desde el checkout o compilar Rust en el dispositivo exigiría
  herramientas de desarrollo al usuario; incorporar Android en estos builds ampliaría el alcance de distribución.
- **Fuentes:** [Native Assets de flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/manual/integrate/native-assets),
  [hooks de Dart](https://dart.dev/tools/hooks).

### 4.51 El sujeto SEE de app atraviesa el transporte generado

- **Problema:** las reglas de integración de la app necesitan observar el comportamiento que llega a la interfaz, y
  una respuesta prefabricada no prueba ni el transporte ni la proyección que consume la app.
- **Elección:** `tool/see_app_adapter.dart` negocia una sesión SEE por JSONL, inicializa FRB y abre
  `openNativeTransport()`. Sus escenarios llaman las API de análisis, ejecución, estado y completado usadas por los
  adaptadores de `lib/engine/rust/`; las respuestas se forman a partir de valores recibidos en esa sesión.
  Las peticiones API aceptan una llamada o una secuencia; `resource_from` resuelve los recursos desde las respuestas
  anteriores para que los casos de negociación y ciclo de vida recorran el puente real.
  Un paso `input` con solo `text` toma `resource_id`, `task_id` y `request_id` de la última `pending_input` recibida, igual que el adaptador del motor; sin solicitud pendiente la API lo rechaza.
  Una ejecución devuelve sus eventos solo si la petición pide `observe: events`; si no, la respuesta lleva la lista vacía, como exige el protocolo para un sujeto que anuncia `observe`. Antes los devolvía siempre y el primer caso `execute` del sujeto (`LANG.PROGRAM.STRUCTURE` C6) cortaba la sesión con `SEE-PROTOCOL`.
  `conformance.yaml` mantiene los vínculos pendientes hasta que una verificación ejecutada respalde cada vínculo.
- **Comparación de datos:** `candidates_include` comprueba pertenencia sin imponer el orden de presentación y
  `next_cursor: "opaque"` acepta cualquier cursor no vacío. Se descarta fijar un orden o una codificación que el
  contrato no declara.
- **Verificación actual:** `see conform --subject app` ejecuta 252 observaciones sin divergencias, incluidas las
  llamadas de documento único con Unicode y los formatos de intercambio por el puente real. `see conform --subject app
  --operation properties` comprueba tres propiedades API mediante el transporte real, con 1117 muestras por propiedad y
  semilla 42. Esa evidencia no sustituye las
  mediciones Release de E-NR2.
- **Alternativas descartadas:** duplicar el motor Rust dentro del ejecutor, responder con valores constantes o
  simular las llamadas de transporte ocultaría fallos de recursos, conversión de posiciones y proyección.

### 4.52 Captura reproducible de tamaños nativos y Wasm

- **Elección:** después de `flutter build ios --release --no-codesign` y `bash tool/wasm.sh build`,
  `dart run tool/capture_bridge_artifacts.dart` en `packages/pseudolearn_benchmarks` registra hashes,
  arquitectura, símbolos dSYM separados, toolchain y bytes Brotli en su directorio local `results/` o en la ruta
  indicada con `--output`.
- **Medición observada:** tras añadir `Vector`, `Diccionario`, interfaces y limpieza, el framework ios-arm64
  ocupa 4,566,624 bytes (4.36 MiB) y el Wasm comprimido 819,420 bytes (800.21 KiB). Ambos quedan dentro de los
  presupuestos vigentes de 8 MiB y 900 KiB (antes 3 MiB y 600 KiB, con 2,985,792 y 530,599 bytes); el margen
  de aquella captura correspondía al tope anterior de 5 MiB. Es evidencia histórica; una dependencia nueva exige
  repetir la captura. `PERF.ARTIFACT.SIZE` mide bytes del binario Release y no exige dispositivo físico.
- **Límite:** el build iOS Release se generó sin firma y se midió antes de empaquetar Flutter. El iPhone 17
  con iOS 27.0.1 ejecutó la prueba en Profile, donde el runner no encontró el Dart VM Service por Wi-Fi y
  quedó visible la pantalla inicial; no se atribuyen tiempos de ejecución a esa captura. `flutter drive --release`
  no admite esta integración nativa.

### 4.53 Validación manual separada de la distribución

- **Problema:** una comprobación multiplataforma debe poder compilar y ejercitar los puentes sin tener acceso a
  credenciales ni producir una carga accidental a una tienda o un canal de distribución.
- **Elección:** `.github/workflows/verify-native-builds.yml` solo inicia mediante `workflow_dispatch`, compila
  paquetes sin firma para iOS, macOS y Windows, verifica enlaces y recursos Rust empaquetados, y ejecuta humos
  en iOS Simulator, macOS y Windows. No requiere secretos ni publica artefactos. Los flujos productivos siguen
  siendo manuales y se mantienen en workflows separados.
- **Reproducibilidad:** `.github/actions/setup-rust-bridge/action.yml` lee la versión y los destinos de
  `native/rust-toolchain.toml`, instala `cargo-expand` y `flutter_rust_bridge_codegen` en sus versiones
  fijadas, y ejecuta `bash tool/prepare_generated.sh`. La caché solo contiene descargas de Cargo; su clave depende
  del sistema operativo, objetivos, toolchain, `Cargo.toml`, `Cargo.lock`, `pubspec.lock`, configuración FRB
  y hook Native Assets. No se restauran claves parciales ni se cachean bibliotecas compiladas.
- **Alternativas descartadas:** reutilizar un workflow de publicación expondría la comprobación a sus secretos y
  efectos externos; disparar builds en cada push o PR contradiría el ciclo manual de CI; reutilizar salidas
  binarias de una clave incompleta podría ocultar cambios de toolchain o transporte.

---

El adaptador SEE de app ejecuta también el alfabeto completo de eventos mediante los recursos del transporte nativo. Reúne los lotes, obtiene la vista de la misma revisión y libera el documento y sus ejecuciones dependientes al finalizar; no mantiene otra implementación del lenguaje.

La prueba de frescura de la biblioteca nativa recorre el cierre de dependencias de producción declarado por `cargo metadata --locked --offline`. Excluye herramientas no enlazadas y módulos de tests, y exige que las fuentes embebidas precedan a la biblioteca release. La generación de enlaces se verifica antes del build y de la suite, porque el generador escribe sus archivos. Un caso negativo detecta la inclusión incorrecta de dependencias de desarrollo o de herramientas.

La proyección conserva las comillas del texto fuente en los diagramas y los lexemas canónicos del perfil en la referencia de tipos. Las expectativas de presentación comprueban estos datos Rust sin reconstruir tablas del motor retirado.

El trabajador `dart run tool/bridge_benchmark_worker.dart` consume escenarios de medición por stdin,
con preparación, solicitudes cronometradas, verificación posterior y expectativas independientes.
Usa el transporte generado real y puede medir `ExecutionCubit` hasta preparar el modelo visible.
Cada iteración cierra el cubit y la sesión. El renderizado requiere la captura de plataforma posterior;
el trabajador no publica fotogramas inventados ni certifica dispositivos a partir de llamadas locales.

### 4.53 Consulta de ayuda del editor: puerto propio, sesión efímera y estado separado del búfer

Problema: el editor debe explicar el elemento bajo el cursor sin reconocer el lenguaje ni conservar descripciones propias, y sin que un resultado tardío se muestre sobre un texto que ya cambió. Elección: `SyntaxHelpSource` es un puerto pequeño de dominio (texto, perfil, idioma de interfaz, cursor UTF-16 y revisión) y `RustSyntaxHelpSource` lo adapta a `help_query`: abre una sesión de edición, consulta y la libera siempre, sin conservar un segundo búfer ni mantener sesión entre consultas. La consulta es una acción explícita, así que el coste de abrir la sesión se paga una vez por pulsación del usuario, no por tecla. `SyntaxHelpCubit` guarda solo el último resultado y la revisión del documento; su estado no pertenece a `EditorCubit`, que no gana responsabilidades ni métodos.

La posición se convierte a línea y columna en unidades UTF-16 (`Utf16LineIndex`) y se rechaza sin consultar si cae dentro de un par sustituto. El servicio devuelve los rangos en columnas de escalares Unicode, no en UTF-16, aunque la consulta use UTF-16; el adaptador los convierte a desplazamientos UTF-16 del documento. Esa asimetría la detectó el caso de conformidad con un emoji antes del token, no una revisión del código, y por eso hay una prueba propia.

Vigencia: cada consulta pertenece a la revisión del documento con que se pidió (la revisión de completado del editor, monótona). Cuando el documento cambia, la ayuda visible se descarta; una consulta de una revisión anterior a la vigente se ignora. El resultado distingue ayuda de ficha, símbolo del usuario, posición sin ayuda, posición no válida y fallo del servicio; un fallo nunca se presenta como ausencia de ayuda.

Presentación: la ficha se abre en una hoja inferior modal (`SyntaxHelpSheet`) que solo muestra texto, con encabezados semánticos y desplazamiento propio; al cerrarse, la ayuda se descarta (`dismiss`). Ya no hay fila «Explicar» bajo el editor (§4.61). Hay tres entradas: el chip `?` (`KeywordHelpChip`), F1 y la opción «Explicar» del menú contextual del campo (pulsación mantenida). El chip aparece sobre una palabra clave o un nombre de tipo cuando el cursor reposa en ella **sin haber escrito**: `EditorSurface` solo informa movimientos de cursor que no acompañan a una edición, `SyntaxHelpCubit.caretMoved` busca entre los `highlightSpans` del informe vigente el rango explicable que contiene el cursor (bordes incluidos) y lo guarda como `restingKeyword`; cualquier edición (`documentChanged`) o la apertura de la ayuda lo retiran. Así tocar para editar nunca se convierte en abrir ayuda: el toque coloca el cursor como siempre y el chip es una oferta que se ignora escribiendo. No hay temporizador de reposo; la regla es determinista. El chip se coloca centrado sobre el token con la geometría del `RenderEditable` (`keyword_help_geometry.dart`), cae debajo si no cabe encima, se acota a los bordes y se declara región de toque del campo (`TextFieldTapRegion`) para no robarle el foco; no se ofrece durante una ejecución. La consulta explícita funciona con la asistencia automática desactivada, no modifica el documento y no cambia selección ni foco, porque no emite ninguna edición pendiente. Las etiquetas de interfaz (acción, encabezados de sección, mensajes de ausencia) viven en los recursos localizados; título, resumen, descripción y secciones son los de la ficha devuelta. El idioma de interfaz se resuelve en presentación y es independiente del perfil del documento.

Verificación: los casos `APP.EDITOR.COMPLETION` R8–R13 los ejecuta el sujeto `app` por el transporte generado; las pruebas de widgets no sustituyen el puente, y `tool/native_bridge_adapters_test.dart` ejercita la consulta contra la biblioteca nativa real. La cobertura en dispositivo físico no se ha medido.

Render: la hoja dibuja siempre texto, sin Markdown, enlaces, imágenes ni reconocedores de gestos; un texto con etiquetas, enlaces o esquemas se ve literal, y el único elemento pulsable de la hoja es su botón de cierre. El servicio rechaza ese contenido en el origen y lo escapa en sus propias proyecciones; el panel no depende de ello. La ficha se ordena para quien empieza: categoría, título y «qué es»; «Cómo se escribe» con la plantilla (`HelpFormView`), que pinta palabras y signos con los colores de sintaxis, los huecos como pastillas `«etiqueta»` (`HelpSlotChip`) y la repetición como `...`, con dos espacios por nivel; «Cada parte» en el orden de la plantilla; «Devuelve», «Reglas», «Errores comunes» con su programa si lo tiene, y «Ejemplo» con el programa, su resultado y la nota. Los programas se muestran en un bloque de solo lectura con desplazamiento horizontal (`HelpCodeView`), sin numeración de líneas ni campo de texto, para no anidar otro desplazamiento vertical dentro de la hoja. El resaltado de esos programas lo calcula la capa de aplicación (`HelpProgramHighlighter`) con el mismo `ProgramAnalyzer` del editor y el perfil del documento, igual que los bloques de código de la base de conocimiento; el mapeo de categoría a color es una única función (`syntaxCategoryColor`) compartida con el editor. La descripción del token solo se muestra cuando no hay ficha, porque con ficha ya aparece en «Cada parte». La plantilla llega del servicio como segmentos ya clasificados en palabra, signo, hueco o repetición; el adaptador solo los proyecta, sin reconocer el lenguaje. Lo comprueba `test/presentation/editor/help/syntax_help_body_test.dart`: orden de secciones, plantilla con pastillas y sangría, ficha hostil mostrada literal y sin elementos pulsables, secciones vacías ocultas y aviso de ejemplo con error.

Frontera entre currículo, interfaz y catálogo: la base de conocimiento conserva su narrativa pedagógica; la interfaz, sus etiquetas y mensajes localizados; la semántica normativa del lenguaje (qué hace una palabra, sus partes, restricciones y ejemplos) solo llega de la ficha que devuelve la consulta. Ningún archivo de `lib/` ni recurso localizado puede repetir prosa de una ficha: lo comprueba una prueba del motor que recorre esta aplicación, con una violación deliberada que demuestra que falla. Una modificación de una ficha llega a la API, al servidor LSP y a esta consulta por generación, sin cambios de código.

### 4.54 Anfitrión real en modo de archivo único

La app ejecuta capacidades contra el anfitrión Rust compartido con la CLI. `ExecutionEnvironment`
expone una carpeta por documento; `LocalExecutionEnvironment` la deriva de la carpeta de documentos
como execution/<identidad codificada>. La capa host solo importa modelo y puertos; admite dart:io y
prohíbe interfaz Flutter, engine y application. La composición inyecta el puerto en RustEffectGate.
No hay implementación Dart de HTTP, reloj, temporizador ni archivos del lenguaje.

RustEffectGate abre un HostWorker por recurso, envía solicitudes con effect_seq y sondea respuestas.
Una operación lenta mantiene visible la espera; no consume el presupuesto de pasos ni bloquea la UI.
HostWorker conserva archivos y atiende HTTP y temporizadores en hilos independientes. Cancelar,
liberar, detener o reiniciar cierra el anfitrión; reproducción no lo abre ni envía effect_result.
La entrada de Leer conserva su identidad propia (recurso, tarea, solicitud).

El documento persiste los argumentos; la hoja «Opciones de ejecución», abierta desde el botón `⋯` del pie,
permite editarlos y repetir la última cinta. La misma hoja explica que los archivos del programa viven en la carpeta
del algoritmo y, tras la primera ejecución, muestra su ruta seleccionable; la ruta ya no ocupa una franja del
editor porque es estable por documento y no cambia entre ejecuciones. Los argumentos admiten comillas, vacíos, espacios y Unicode. La semilla viva usa entropía del SO y queda grabada; reproducción conserva la
semilla de la cinta. Los errores de reproducción se muestran y no inician una ejecución viva alternativa.

La nueva capa se verifica con una importación prohibida deliberada. La puerta de contenido rechaza
identificadores y claves del anfitrión retirado, con fixture negativo. Las pruebas Dart–FFI ejercitan
HTTP loopback, archivos reales y reproducción con cero llamadas nuevas al anfitrión.

### Configuración del transporte por plataforma

iOS declara NSLocalNetworkUsageDescription en español e inglés y NSAllowsArbitraryLoads, autorizado
explícitamente para ejecutar programas educativos con HTTP arbitrario. HTTPS mantiene validación TLS
en Rust contra las raíces de plataforma; ATS no se usa para desactivar esa validación. macOS conserva
los entitlements de red cliente y acceso a datos del contenedor. Windows declara internetClient y
privateNetworkClientServer. El build y la ejecución de Windows quedan no verificados en macOS.

Lista de comprobación por plataforma antes de publicar:

| Plataforma | Clave o declaración | Dónde | Qué habilita |
|---|---|---|---|
| iOS | `NSLocalNetworkUsageDescription` en `es` e `en` | `ios/Runner/Info.plist` y `*.lproj/InfoPlist.strings` | Peticiones a servicios de la red local; el sistema muestra el texto localizado al pedir permiso |
| iOS | `NSAllowsArbitraryLoads` | `ios/Runner/Info.plist` | HTTP sin cifrar a loopback y direcciones privadas, que el lenguaje permite por diseño |
| macOS | `network.client` | `macos/Runner/*.entitlements` | Salida de red del anfitrión |
| macOS | `network.server` solo en Debug y Profile | `macos/Runner/DebugProfile.entitlements` | Servicio de depuración de Flutter; Release no lo declara |
| Windows | `internetClient,privateNetworkClientServer` | `msix_config.capabilities` de `pubspec.yaml` | Internet y red privada desde el paquete MSIX |

Justificación para la revisión de tienda: PseudoLearn es un entorno de ejecución de programas escritos por la
persona usuaria, y esos programas pueden pedir cualquier URL `http` o `https`, incluidas las de su red local o
su propia máquina. Por eso no existe una lista de dominios que declarar en ATS; la validación TLS de HTTPS no
depende de ATS porque la hace Rust contra las raíces de la plataforma. Los archivos que tocan los programas
quedan en la carpeta del documento dentro del contenedor de la app. La prueba
`test/tool/platform_host_configuration_test.dart` falla si desaparece alguna de estas claves.

Mediciones de PG-B.22 y PG-B.23 sobre `96188d7b` con el árbol modificado: la biblioteca del puente con
`pseudolearn_host` en ios-arm64 Release, con símbolos de depuración y locales retirados, mide 5.913.976 bytes
(5,64 MiB) y cabe en el tope de 8 MiB de `PERF.ARTIFACT.SIZE#R1`. `flutter build ios --simulator --debug` y
`flutter build macos --release` terminan correctamente. El build de Windows no se ejecutó (no hay
cadena de herramientas en este equipo): queda no verificado. `flutter build macos --debug` exige un perfil de
desarrollo de Apple que este equipo no tiene; no es un fallo del proyecto.

### 4.55 Import y export pegados: dependencia visible, nunca resuelta

Problema: la app abre un solo archivo y no tiene proyecto, pero una persona puede pegar `Importar geo.Punto Como P;`.
Decisión: el análisis conserva su diagnóstico (`moduleSyntaxOutsideProject`, el mismo de `LANG.MODULE.MODEL#R3`), la vista
conserva las demás unidades y la dependencia se muestra sin enlazar; nada intenta resolverla.

- `RustProgramViewSource.loadStructure` acepta ese único diagnóstico sintáctico (`load`, que usan el exportador y la
  ejecución, sigue rechazando cualquier error). La vista decodifica `dependencies` en `ProgramDependency` (modelo
  inmutable: tipo, ruta, alias, estado, código de diagnóstico y `SourceRange`) y valida cada fila con fallos tipados.
- `DiagramProgram.dependencies` lo llena el constructor del ordinograma; `DiagramState.dependencies` lo expone para las
  tres notaciones y `DiagramDependencyOverlay` dibuja una tarjeta con una fila por dependencia («Importa geo.Punto como
  P», «Sin enlazar…»). Cada fila es un botón de Semantics y navega al rango exacto con el mismo `revealSource` que las
  demás superficies, sin tocar el texto. Los textos están en ambos idiomas de la interfaz.
- Ejecución y exportación quedan bloqueadas porque el análisis sigue reportando un error. No hay gestor de
  dependencias, selector de proyecto, descarga ni archivo auxiliar, y un import soportado visualmente no se anuncia como
  proyecto resuelto.
- Una ruta vacía, incompleta, con `..` o absoluta es un error sintáctico adicional: no hay estructura ni filas.
- `RustSyntaxHelpSource` aprovecha el diagnóstico del análisis aislado para resolver `Importar` y `Exportar`, y reconoce
  `Como` como alias solo dentro de esa misma directiva. Cada papel obtiene su ficha propia del catálogo
  (`help.module-import` o `help.module-export`), con idioma elegido por la interfaz sin cambiar el perfil español del
  documento. La consulta no crea una dependencia enlazada ni habilita una operación de anfitrión.
- Evidencia: `rust_program_dependencies_test.dart` (puente real; un transporte que registra operaciones afirma que
  solo se analizó, se leyó la vista y se liberó, sin `start`, `execute` ni operaciones de anfitrión, también cuando el
  texto nombra un paquete que existe en disco), `rust_program_view_dependencies_wire_test.dart` (filas ausentes y mal
  formadas), `diagram_dependency_strip_test.dart` (es/en, toque, Semantics), `rust_class_diagram_integration_test.dart`
  (consulta de las tres fichas por FRB nativo con balance de recursos) y los casos C48–C52 por el puente real.

### 4.56 Evidencia estática de E-PG-12

El protocolo humano necesita escenas repetibles con contenido válido en los perfiles español e inglés, y una variante
con una realización inválida. `test/fixtures/static_view_scenes/` contiene el archivo autocontenido que reúne interfaz,
dos implementaciones, `Resultado`, captura por valor e iteración. `static_view_protocol_test.dart` lo valida por FRB
real, comprueba identidades y relaciones del diagrama, y contrasta la realización inválida sin producir una escena
válida.

`static_view_measurement_test.dart` mide, para 1, 10 y 100 realizaciones, la lectura de vista, la construcción
completa del diagrama, el layout de un modelo sintético y el registro de comandos del pintor. Cada muestra usa un
análisis nuevo. `view_operations` y `scene_operations` registran las llamadas al puente; `rss_bytes` es una lectura de
RSS del proceso. Los comandos de pintado terminan en `PictureRecorder`: no miden rasterización GPU, interacción ni
latencia de dispositivo. `scene_build_ns` incluye análisis, transporte, decodificación, proyección y layout; las APIs
actuales no permiten separar esas etapas internas. Son medidas descriptivas del host de test y no fijan presupuesto.

El test de medición queda omitido cuando no se define `STATIC_VIEW_OUTPUT`. Ejecutar diez procesos independientes conserva
30 iteraciones por tamaño en cada archivo JSONL. El resumen valida el tamaño de la campaña y calcula percentiles,
intervalos bootstrap del 95 % sobre medias por proceso y candidatos de punto de cambio sin descartar muestras:

```sh
STATIC_VIEW_OUTPUT=/tmp/static-view-process-01.jsonl flutter test --no-pub test/engine/rust/static_view_measurement_test.dart
dart run tool/static_view_summary.dart --output /tmp/static-view-summary.json /tmp/static-view-process-*.jsonl
```

Cambiar el sufijo por un archivo distinto para cada proceso. El protocolo de participantes conserva consentimiento y
respuestas bajo responsabilidad de quien conduzca el estudio; no simula participantes ni recoge datos personales.

### 4.57 Reproducción de una ejecución: cinta transportada, proyección canónica y rechazos tipados

Problema: reproducir una ejecución con efectos no puede volver a consultar el anfitrión real, porque la segunda
ejecución podría diferir de la primera sin que nadie lo note. Decisión: la app transporta la cinta de efectos que el
motor ya graba, se la devuelve en modo `replay_from_tape` y compara la ejecución reproducida con la grabada mediante
una proyección canónica. La app no valida la cinta: el motor es el único dueño de identidad, secuencia y hashes.

- **Entrada completa de una reproducción.** Fuentes, perfil, semilla y límites son la identidad que el
  motor ata a la cinta; no se aporta un anfitrión al reproducir. Los datos del anfitrión (archivos,
  respuestas HTTP, reloj) no se vuelven a entregar: viven en la cinta. El orden de entrega queda registrado en la cinta
  y la reproducción lo sigue. La revisión y la selección de tarea, evento o página no forman parte de lo que se
  reproduce: son disposición, no ejecución.
- **Transporte.** `RustBatch.effectTape` conserva el documento de cinta de la respuesta de `advance`. `EffectTape`
  (modelo) lo guarda como texto JSON inmutable; `ProgramExecution.startExecution(replayTape: ...)` lo envía junto con el
  modo. `ExecutionReproduction` (puerto de solo lectura) expone `recordedTape`, `replayRejection` y `projection`. La cinta
  solo existe cuando hay anfitrión declarado y se conserva hasta el siguiente inicio, también después de `stop`; la app
  nunca la escribe en disco ni la registra en el log. El motor redacta los argumentos secretos antes de serializarla.
- **Enteros sin pérdida.** La cinta cruza una frontera JSON que Dart decodifica con enteros de 64 bits con signo. Una
  identidad con `u64::MAX` como «sin límite» se reenviaba como número decimal distinto y el motor la rechazaba como
  `replay_corrupted_tape`. La identidad ya no incluye `statements` ni `micro_steps` cuando no están configurados y
  ningún entero de la cinta excede `i64::MAX`.
- **Rechazos tipados.** `ReplayRejection` distingue `missingTape` y `unsupportedSchema` (fallos de inicio de uso y de
  versión), los cinco códigos `replay_*` del motor (`identityMismatch`, `divergence`, `truncatedTape`, `corruptedTape`,
  `nonReproducible`) y `engineRefused` para cualquier otro fallo que el motor emita durante una reproducción. Un
  rechazo al iniciar devuelve un paso sin iniciar y libera el análisis; un rechazo durante el avance termina la ejecución
  con `failed` y el código como motivo. Un fallo del transporte fuera de una reproducción no se oculta como rechazo: se
  propaga como antes. Una cinta sellada como no reproducible (truncada por presupuesto, redactada o incierta) se rechaza
  con `nonReproducible`; no se espera una reproducción exitosa de ella ni se vuelve a ejecutar contra el anfitrión para
  sustituirla.
- **Proyección canónica.** `ExecutionProjection` compara, en orden, la firma de cada evento consumido (clase, tarea
  dueña según la atribución del motor, nodo sin la etiqueta de revisión, línea, profundidad y datos), las líneas de
  salida con su clase, la terminación y el motivo de fallo. Dos ejecuciones son equivalentes solo si todo coincide;
  `firstDivergence` informa el índice del primer evento distinto, o la longitud común si difieren cola o terminación.
  Quedan fuera, a propósito, las marcas de tiempo, los píxeles, la etiqueta de revisión (contador de la sesión de
  análisis: `rev1` y `rev4` pueden nombrar la misma fuente) y los identificadores de recurso. Pilas, variables y
  solicitudes se derivan de esos eventos y de consultas por evento; sus pruebas viven en el rastreador de foco y en las
  consultas paginadas. El estado de canales no tiene dato público, así que no forma parte de la proyección.
- **Qué cambia solo la disposición.** Tamaño de lote, pausas de la interfaz, ritmo, selección, paginación,
  redimensionado e idioma de la interfaz no cambian la proyección: la prueba repite la reproducción con lotes de 1, 2, 3, 5
  y 25 eventos y pausando entre pasos. Constituye divergencia cualquier diferencia de la lista anterior.
- **Invalidación.** El inicio de la reproducción usa el mismo `RustExecutionResource` que una ejecución viva: abre un
  recurso con su revisión, de modo que cursores y cachés ligados a recurso y revisión no sobreviven a `stop` ni a un nuevo
  inicio. `begin` limpia cinta, firmas y rechazo. Reconstruir una ventana no recorre la cinta: la atribución de eventos
  ordinarios sale de `task_id` en `history_events`, por lo que la reproducción no se usa para obtener contexto previo.
- **Retención y fallos.** La app guarda solo la cinta de la ejecución en curso, acotada por `max_tape_bytes` del motor
  (16 MiB por omisión). Al agotarse el presupuesto el motor sella la cinta y el programa continúa; reproducirla se
  rechaza. Las muestras para pruebas se generan en el momento y no se almacenan; los dobles de las pruebas llevan
  documentos de cinta mínimos escritos a mano y no artefactos generados.
- **Verificación.** `rust_program_execution_replay_test.dart` (doble de transporte: modo y cinta enviados, equivalencia
  con distintas particiones, divergencia detectada, rechazos de inicio y de avance, cero `effect_result` ni `input`) y,
  contra el motor real, «reproduction through the real engine» en `tool/native_bridge_adapters_test.dart` (equivalencia
  con espía de transporte, cinta de otro programa, cinta truncada y cinta adulterada).

**Control «Repetir última ejecución».** `ExecutionReplaySection`, dentro de `ExecutionOptionsSheet`, solo se monta
mientras `ExecutionState.recordedTape` no sea nulo y habilita el botón cuando no hay una ejecución en curso; bajo él,
una frase explica qué hace o, si la última repetición fue rechazada, el motivo. Al pulsarlo lee la fuente y el documento vigentes del `EditorCubit` en ese instante,
no los capturados en la última construcción del widget, porque una edición posterior a esa construcción reproduciría
con la fuente anterior y ocultaría el rechazo. El cubit conserva la cinta durante la reproducción (`_startNew` la
mantiene), de modo que una reproducción rechazada o aceptada permite otra. El rechazo se muestra localizado y con
su causa, porque una frase única («la cinta no se puede reproducir») no le decía a la persona qué hacer.
`replayRejectionText` agrupa los ocho `ReplayRejection` en tres motivos accionables: código cambiado
(`identityMismatch`, `executionReplayRejectedChanged`), ejecución no reproducible (`nonReproducible` y `missingTape`,
`executionReplayRejectedUnfinished`) y grabación inválida (el resto, `executionReplayRejectedInvalid`); los tres
terminan pidiendo pulsar «Ejecutar». El agrupamiento sigue lo que la persona puede hacer, no el código del motor, y el
`switch` exhaustivo obliga a clasificar cualquier rechazo nuevo. El mismo texto aparece en la hoja y en la salida:
`runOutcomeOf` trata `haltedWithError` con `replayRejection` presente como aviso «No se pudo repetir» y no como error
del programa, porque la repetición rechazada termina en `haltedWithError` sin mensaje ni línea, y el respaldo genérico
«Error en tiempo de ejecución» hacía creer que el programa había fallado. La ayuda del botón declara qué datos repite
(lo leído con `Leer`, archivos y argumentos), que sirve para volver a ver un error y que exige que el código no haya
cambiado. Una trampa del programa deja la cinta reproducible en el motor, de modo que repetirla vuelve a mostrar el
mismo mensaje y la misma línea; solo un corte (detener, límite) o una cinta truncada, redactada o incierta la vuelven
no reproducible, y eso es lo que nombra `executionReplayRejectedUnfinished`. Los argumentos actuales del documento no
participan en la identidad, de modo que la repetición usa los grabados aunque el campo haya cambiado. `APP.EXEC.CONFIGURATION#R2` cubre cinta válida y fuente cambiada por el puente real; la
prueba de widgets verifica el botón deshabilitado durante una ejecución y la sección ausente sin cinta. El estado de canales y cola no es consultable por API,
por lo que no se compara.

### 4.58 Resultados de tareas y terminaciones: error recuperable, trampa y corte del anfitrión

`task_completed.outcome = error` representa un valor `Resultado::Error` que la tarea devuelve al ámbito. La tarea está
completada y el error puede recuperarse; no se presenta como una trampa del programa. `task_completed.outcome = cancelled`
representa la cancelación cooperativa de una tarea hermana, después de las hijas y limpiezas que exige el lenguaje.
Una terminación global `failed` es una trampa: se marca como fallida la tarea que emitió el evento `failure` y las demás
tareas que seguían activas quedan como interrumpidas por esa terminación. `cancelled` del recurso es un corte del
anfitrión: no ejecuta limpiezas; las tareas que seguían activas quedan interrumpidas por el corte. `limit_reached` mantiene
su identidad y no se mezcla con un fallo ni con una cancelación.

La tabla de tareas combina los eventos retenidos con los contextos finales identificados por `task_id`. Esos contextos
actualizan el estado de cada tarea sin fabricar eventos `task_completed` o `scope_joined`. Los resultados conocidos se
localizan en español e inglés; un resultado desconocido se muestra como informado por el motor, nunca como éxito. La
cancelación del anfitrión tiene una banda de advertencia propia y conserva el paso observado que la precede. La tabla no
atribuye la trampa a una hija por su número de línea: usa el evento `failure` con la atribución de tarea de la cinta.

Los eventos de canales exponen identidad y operación, pero no el contenido de la cola. La pestaña de estado conserva el
aviso de que ese contenido no está disponible; no representa una cola vacía, llena o parcialmente consumida a partir de
los eventos. Las pruebas del API `task_failure_tests`, `task_event_tests`, `task_channel_tests` y
`task_deadlock_tests` cubren errores recuperables, cancelación cooperativa, trampas, limpiezas, canales y ubicaciones
relacionadas del bloqueo. `rust_task_termination_test.dart` atraviesa el puente nativo para comprobar esos resultados en
los contextos de tarea; `task_structure_projection_test.dart` y `task_state_cards_view_test.dart` verifican la proyección y
sus rótulos accesibles.

| Conducta | Cinta y eventos | Recursos y limpiezas | Presentación y ayuda |
|---|---|---|---|
| Una tarea devuelve `Resultado::Error` | `task_completed` conserva `outcome = error`; el programa puede seguir con terminación exitosa | La tarea queda completada y el ámbito recibe el resultado recuperable | La tabla muestra el estado completado y el resultado de error. No hace falta una ficha porque no aparece sintaxis nueva |
| Una trampa termina la ejecución | `failure` atribuye la causa a la tarea activa y la terminación global queda `failed` | Se detienen las tareas sin iniciar limpiezas pendientes; los efectos ya confirmados no se revierten | La banda de error y la tabla distinguen la tarea que falló de las interrumpidas. La ubicación sale de la atribución del evento |
| El error de una hija cancela hermanas | Se conserva el primer error por orden de terminación, `task_cancel_requested` y `task_completed = cancelled` | Las hijas se cancelan por identidad, ejecutan limpiezas LIFO y los efectos en espera quedan abandonados; una respuesta tardía se descarta y un efecto externo incierto conserva esa incertidumbre | La tabla separa la hija fallida, las hermanas canceladas y los errores ya ocurridos. Una unión con error no se dibuja como exitosa |
| El anfitrión corta una espera | La API confirma terminación `cancelled`; la app no crea eventos de tarea ni una unión | El corte es inmediato, no ejecuta limpiezas de usuario y descarta la respuesta tardía; la cinta queda incompleta | Una banda localizada indica el corte y la tabla conserva los contextos observados antes de detener el recurso |
| No queda trabajo listo | El motor informa `failed/taskDeadlock` con sitios de suspensión; una respuesta externa pendiente mantiene `awaiting_effect` | La espera externa capaz de reanudar no se clasifica como bloqueo definitivo | Se muestran sitios por tarea y se distingue bloqueo de espera externa. No se inventa el estado final de recursos para eventos previos |
| Un canal está lleno, vacío o cerrado | La cinta conserva identidad y orden de eventos, no los valores de la cola | Un envío espera capacidad; al cerrar, el receptor consume primero lo encolado y después recibe `Nada` | La app no representa tamaño, contenido ni llenado de una cola que la API no expone. La ayuda gramatical no sustituye esa observación |

### 4.59 Integración con el puente real: qué certifica cada nivel

La integración con tareas atraviesa el transporte nativo sin dobles: `rust_task_bridge_integration_test.dart` abre la
biblioteca nativa, ejecuta un archivo suelto con dos tareas (una espera un efecto de temporizador y la otra avanza), consulta
la tarea suspendida, responde la solicitud de entrada de la raíz, corta la ejecución y comprueba que los recursos del motor
se liberan. Corre en ambos perfiles de sintaxis (español clásico e inglés) con la lengua de interfaz correspondiente.

Las operaciones que usa la app contra `ApiSession` son `start`, `advance`, `input`, `effect_result`, `cancel` y `release`
para la ejecución, y `history_events`, `debug_configure`, `debug_state` y `query_page` para la observación. `input`
exige `(resource_id, task_id, request_id)`; `effect_result` exige la secuencia del efecto. Cada observación tiene un nivel
que la certifica y los demás no la sustituyen:

| Observación | La certifica | No la certifica |
|---|---|---|
| Estado de la tarea (`waiting`, `completed`, …) y marcos en un evento | API Rust (`state_pages`, `execution_queries`) y el adaptador `RustProgramExecutionObserver` | El cubit ni el widget: solo muestran lo que el adaptador devolvió |
| Dueño de cada evento ordinario y contexto por tarea | Adaptación Dart (`RustFocusTracker` y contextos), comparada con la traza del motor | Un doble de transporte: solo prueba el algoritmo del tracker |
| Rechazo de entrada obsoleta, cruzada o de otro recurso | Adaptación Dart (`RustProgramExecution.provideInput`), antes de llamar al motor | La API, que además valida la identidad por su cuenta |
| Consultar no mueve la agenda | Conteo de llamadas `advance` del transporte real antes y después de consultar | Un test que solo reenvía `session.call` |
| Liberación de recursos al terminar o cortar | Conteo de `release` frente a `create_analysis` y `start` en el transporte real | El cubit, que solo delega `stop()` |
| Qué ve la persona (tabla, foco, banda) | Widget y cubit sobre el estado ya adaptado | El puente |

Un evento de espera de efecto no suspende por sí mismo a la tarea que lo pidió en el momento de la consulta: la tarea
queda en el estado que el motor informa para ese evento, y la tarea de la raíz espera en la unión. Las pruebas leen el
estado de la tarea en el evento `task_suspended` correspondiente y no en la punta de la ejecución. El vocabulario de estado
de la consulta es el del motor (`waiting`, no `suspended`).

No hubo cambio de firma Rust: el sobre de `native/src/api.rs` es un único punto `call(operation, arguments)` hacia
`ApiSession`, y las operaciones anteriores ya existían. Por eso no se regenera el puente; `bash tool/bridge.sh check` solo
comprueba que las salidas versionadas siguen vigentes. Una discrepancia que requiera observación Dart y esté cubierta por el
corpus de la app se añade como escenario del sujeto de app; este punto no encontró una carencia que lo exigiera.

#### Tareas con efectos reales en loopback

`rust_real_task_host_test.dart` ejecuta escenas de tareas contra un servidor HTTP de loopback y el temporizador real del
anfitrión, en ambos perfiles, y vuelve a reproducir la cinta que el propio anfitrión grabó con un contador de llamadas
`host_*` que debe quedar igual. `live_timer` deja avanzar a la hermana mientras la espera del temporizador sigue viva;
`live_fetch` hace lo mismo con una petición HTTP real; `live_http` y `live_order` combinan dos efectos vivos. `rust_real_host_integration_test.dart` prueba el corte durante una
petición: la detención cierra el anfitrión sin esperar a la respuesta y cada `host_open` tiene su `host_close`. El paso de
la ejecución solo entrega la solicitud al anfitrión cuando se resuelve la espera (`settleEffect`); un bucle que solo llama a
`step()` nunca llega a abrir el socket.

Dos resultados de efecto entregados en una misma tanda (HTTP más temporizador, o dos HTTP que terminan fuera de orden) ya
no rompen la consulta de historia. Antes, la reconstrucción de un evento repetía la cinta resolviendo cada espera en el
orden de petición, mientras el recurso vivo entregaba en el orden de llegada y agrupaba las entregas entre dos `advance`;
la consulta respondía «evento inalcanzable» y la app detenía la ejecución con `task_state_unavailable`. Ahora el recurso
de la API registra sus operaciones (`advance`, `effect_result`, `input`) y, cuando hubo entregas reales, reconstruye un
evento repitiendo ese registro en un gemelo que usa el mismo código del modo en vivo. En mitad de una instrucción que
emite varios eventos la consulta devuelve el estado anterior a esa instrucción, de modo que una tarea que termina en ella
sigue siendo inspeccionable en los eventos previos a su `task_completed`. Las escenas `live_http` y `live_order`
(`rust_real_task_host_test.dart`) lo ejercen con servidores de loopback de duración distinta.

Límite conocido: reproducir la cinta de una de esas ejecuciones reproduce la salida, la terminación, el fallo y las
entregas, pero no los pares `task_resumed`/`task_suspended` especulativos que el planificador vivo emite al reanudar una
tarea cuyo resultado aún no había llegado. Por eso para `live_http` y `live_order` la comparación de reproducción es de
resultado y no de traza evento a evento.

Los casos de completado `APP.EDITOR.COMPLETION#R5/R6/R10` usan programas con `Definir x Como Entero <- 0;`: se
reescribieron así cuando la declaración sin valor era un error, y conservan el valor inicial aunque ya no sea
obligatorio para no mover sus posiciones. Las propiedades de conformidad que
parten de casos con bloque `anfitrion` solo las ejecuta el sujeto que distribuye el doble de prueba (`engine`): el puente
de la app no lo trae y devolvía `peticion_invalida`. La vista de instantánea buscaba la referencia del arreglo solo en marcos
con variables visibles y un programa que solo declara el arreglo no emite ningún evento posterior; el escenario `snapshot`
usa la primera referencia del montón, como las pruebas de páginas del motor.

El humo local usa el host de desarrollo (macOS). No certifica iOS ni Windows: el humo de iOS requiere simulador y el de
Windows un anfitrión Windows.

```sh
cargo build --release --locked --lib --manifest-path native/Cargo.toml
bash tool/test_bridge.sh
flutter test --no-pub test/engine/rust/rust_task_bridge_integration_test.dart
```

### 4.60 E-PG-12 dinámico: protocolo automatizado, arnés de medición y evidencia humana

La parte dinámica de E-PG-12 se separa de la estática (§4.56). `test/fixtures/task_scenes/` contiene seis escenas
bilingües, validadas por el análisis real: `identities` (un mismo subprograma en dos tareas, una espera y la otra avanza),
`failure` (un error recuperable cancela a la hermana), `channel` (un canal de capacidad 1 llena y el emisor espera),
`select` (dos ramas listas eligen la primera textual), `cancellation` (corte del anfitrión con limpiezas sin ejecutar) y la
variante de revisión nueva, que se genera cambiando un argumento de `identities`.

`task_scenes_protocol_test.dart` ejecuta cada escena por el puente real en ambos perfiles y comprueba contra un
esperado derivado de la regla (estado de cada tarea, salida, causa de la espera y revisión del recurso). Es evidencia
automatizada de identidad, estado y navegación, no de comprensión: la parte humana sigue su propio protocolo.

`task_projection_measurement_test.dart` mide dos intervalos por separado y no los suma. El intervalo puro proyecta una
ventana ya leída a escena de flujo y de estructura, sin FFI ni E/S. El intervalo integrado lee la ventana al motor,
decodifica y proyecta el flujo. Ambos usan entradas preparadas fuera del intervalo y se validan después contra el recuento
de marcadores y carriles. Las cargas son 0, 1, 10 y 100 tareas con una ventana de 100 eventos, más 100 tareas con la
ventana máxima de 4096 eventos, que es la única donde las cien tareas son visibles. Cada iteración parte de una ejecución
nueva. No se mide rasterización, presentación de frame ni dispositivo.

El manifiesto declara además `scenes`: cada escena con su identidad, el hash de sus fuentes y `host: real`. El resumen rechaza una lista vacía, una escena sin identidad o hash, y cualquier escena cuyo anfitrión no sea el real o cuyas claves o valores mencionen simulación; así una campaña no puede mezclar escenarios simulados. El arnés queda omitido sin `TASK_PROJECTION_OUTPUT`. La campaña son diez procesos independientes con 30 iteraciones por carga.
`tool/task_projection_summary.dart` exige un manifiesto de procedencia (revisión, hashes de entrada, versiones, modo de
build, sistema y hardware) y rechaza una muestra incompleta, menos procesos, un resultado divergente dentro de una carga, una
configuración de reloj distinta o un tiempo no medido. Calcula p50 y p95 por rango más cercano e intervalos bootstrap del 95 %
sobre medias por proceso. El umbral de 50 ms para el p95 de la ventana de 100 eventos es un candidato, no un presupuesto
aprobado: el resumen lo copia del manifiesto y no lo evalúa como aprobación.

```sh
TASK_PROJECTION_OUTPUT=build/task-projection/raw/process-01.jsonl flutter test --no-pub test/engine/rust/task_projection_measurement_test.dart
dart run tool/task_projection_summary.dart --manifest MANIFEST.json --output build/task-projection/resumen.json build/task-projection/raw/process-*.jsonl
```

Cambiar el sufijo para cada proceso. La memoria es RSS del proceso Flutter completo, muestreada tras cada carga: es una cota
inferior del pico y no se atribuye a una etapa. La evidencia humana (tareas de espera, unión, canal, cancelación frente a
error y preguntas sobre simultaneidad) la conducen personas con consentimiento gestionado fuera del repositorio; este
proyecto no simula participantes ni resultados. Mientras no existan, ese resultado se registra como diferido.

### 4.61 Editor en modo flujo: código, salida y una sola barra de control

- **Problema:** La pantalla de documento apilaba hasta nueve franjas entre la cabecera y la navegación: tira de
  ejercicio con su botón «Comprobar» y su recuadro de resultado, pestañas, banner «Ejecución finalizada con éxito»,
  editor, fila «Explicar», panel «Sin problemas», campo «Argumentos» con «Reproducir», ruta de la carpeta de trabajo,
  salida y un pie que narraba «Ejecución terminada · Sentencia 6». En un teléfono grabado en vertical el código quedaba
  en tres líneas visibles. La pantalla existe para escribir, ejecutar y depurar; todo lo que no sirve a eso en ese
  instante compite con el código.
- **Elección:** Cada pieza aparece solo cuando tiene algo que decir, y lo dice en el lugar donde ya se mira.
    1. **Sin banner de resultado.** El resultado de una ejecución terminada se dice en una píldora en la cabecera de la
       salida (`RunResultPill`): «Terminado», «Error · línea N» —que al tocarla selecciona la sentencia del fallo con
       `EditorCubit.revealSource`—, «Límite alcanzado», «Tope de interfaz» o «Cancelada». El mensaje largo (el error
       del motor o la explicación del límite) se añade como última línea de la salida (`RunOutcomeNote`), como lo
       haría una terminal. El mapeo de estado a presentación vive en un solo sitio, `runOutcomeOf`; antes estaba
       repetido en el banner y en el texto del pie. El tono se inyecta como selector de `SeverityColors`, no con otro
       `switch` sobre `AppSeverity`.
    2. **Pie sin narración.** El texto de estado y el contador de sentencias desaparecen: el estado ya lo dicen los
       controles (inactivos, depuración o detener) y la línea resaltada en el editor, y el contador contaba cambios de
       foco de la interfaz, no algo que la persona necesite. A la derecha del pie queda solo `⋯`.
    3. **Opciones de ejecución en hoja.** Argumentos y repetición de la última cinta son útiles pero raros: solo
       importan a programas que leen argumentos o usan el anfitrión. Pasan a `ExecutionOptionsSheet`, con frases que
       explican qué hace cada uno y la nota de la carpeta de archivos. El botón `⋯` lleva un punto de marca cuando hay
       argumentos, para que una configuración activa no quede invisible. El campo usa `AppTextField`, y la hoja se
       separa del teclado con `DesignCanvasData.keyboardInset`, porque `MediaQuery` solo se lee en el armazón.
    4. **Diagnósticos solo cuando hay problemas.** Con cero diagnósticos y el teclado bajado la franja no se monta; con
       el teclado levantado en `compact` sigue alojando las salidas de §4.34, sin rótulo «Sin problemas».
    5. **Ayuda sin fila propia.** «Explicar» deja de ocupar una fila: el chip `?` aparece sobre la palabra clave en la
       que reposa el cursor y la ficha se abre en hoja inferior (§4.53).
    6. **Ejercicio en una línea.** «Ejecutar» ya comprueba el ejercicio en el mismo gesto, así que el botón
       «Comprobar» era un segundo camino a lo mismo y se retira. La cabecera muestra la proporción `n/m` con tono de
       éxito o aviso (y la frase completa como etiqueta accesible); el recuadro de resultado solo se muestra plegado
       dentro del cuerpo cuando la comprobación falló, porque entonces aporta el caso oculto. La franja arranca plegada
       si el ejercicio está superado y se pliega sola al superarlo, salvo que la persona la haya abierto o cerrado a
       mano (`DocumentPage._exerciseStripExpansion` es `null` hasta que la toca).
    7. **La tira nunca deja alto sin asignar.** Entre la cabecera y el pie, `StripWorkspaceSplit` coloca la tira con
       un alto máximo de la mitad del espacio que comparte con el área de trabajo, y el área de trabajo (pestañas y
       superficie activa) se lleva todo lo demás con `Expanded`. El cuerpo desplegado se desplaza dentro de ese
       máximo. Antes la tira era un `Flexible` hermano del `Expanded` del área de trabajo: el `Flex` daba a cada uno la
       mitad del espacio libre y la tira, de ajuste suelto, solo usaba su alto propio. Su sobrante quedaba sin asignar
       al final de la columna, en un hueco muerto debajo de la cinta de depuración, sobre todo con la tira plegada o
       en tableta. Acotar con la mitad de toda la columna tampoco servía: con el teclado abierto en 360×640 dejaba sin
       sitio a la cabecera y a las pestañas. `document_column_test` comprueba en 375×812, 360×640, 768×1024 y
       1024×1366, con la tira desplegada, plegada y tras ejecutar, que el pie llega al borde inferior de la columna y
       que el área de trabajo termina donde empieza el pie.
- **Qué se retiró del modelo:** `ExecutionViewAction.dismissStatusBanner`, `ExecutionState.isStatusBannerDismissed`,
  `ExecutionState.isNearStepLimit` y `StepBatchRunner.warningUiAdvanceThreshold`, que solo existían para el banner y
  para colorear el contador. `ExecutionState.statementNumber` se conserva porque lo consumen los guiones de escena
  de `tool/product/`.
- **Alternativas descartadas y por qué:**
    - *Toast o `SnackBar` al terminar:* Descartada. Es otra superficie temporal que tapa el pie justo cuando se quiere
      leer la salida, y en un vídeo es ruido que entra y sale.
    - *Ayuda al tocar directamente la palabra:* Descartada. El toque es de quien edita; convertirlo en ayuda obligaría
      a distinguir intención por tiempo de pulsación y castigaría a quien solo quería colocar el cursor.
    - *Mover la ruta de trabajo a Ajustes:* Descartada. La carpeta es por documento, no global; en Ajustes solo podría
      describirse en abstracto. La hoja de opciones la explica junto a lo que la usa.
    - *Eliminar argumentos y repetición:* Descartada. Funcionan y tienen casos de conformidad
      (`APP.EXEC.CONFIGURATION`); el problema era su peso visual, no su existencia.

### 4.62 Especificación ilustrada: lector de un paquete generado

- **Problema:** la especificación publicada se proyectaba desde Markdown con marcadores resueltos en la app. Sus
  ejemplos no se ejecutaban, las figuras no existían y nada impedía que el texto y el motor divergieran.
- **Elección:** `packages/pseudolearn_reference` compila el libro y escribe en `assets/reference/<idioma>/<perfil>/`
  un paquete JSON ya resuelto: índice, búsqueda, enlaces y una sección por archivo con bloques tipados, programas
  ejecutados con su salida, diagnósticos, anatomías y figuras SVG con capas por paso. La app solo lo lee:
    - `domain/model/reference/` modela edición, sección, bloques, programas, figuras, índice y enlaces; el puerto
      `ReferenceRepository` lo abstrae y `data/reference/BundledReferenceRepository` lo lee de `rootBundle`, con un
      fallo `ContentLoadFailure.malformedReference` ante un JSON inválido.
    - `application/reference/` tiene `ReferenceIndexCubit` (índice, búsqueda y enlaces, cargados una vez por edición) y
      `ReferenceSectionCubit` (secciones en caché por identidad).
    - `presentation/reference/` es el lector: cabecera, bloques, programas con «Probar en el editor», anatomías
      (cada pieza de código con su etiqueta debajo, en una fila que salta de línea en pantallas estrechas), figuras con
      controles de paso y paneles, y botones que llevan desde fichas de sintaxis y diagnósticos a su sección
      (`ReferenceLinkButton`).
    - La edición la decide el idioma de la interfaz y el perfil de vocabulario activo (`ReferenceEditionResolver`).
- **Figuras:** el compilador pinta con colores centinela por papel (`#FF0001`…`#FF000D`) y
  `presentation/reference/figure_color_mapper.dart` los sustituye por tokens del tema antes de pasar el SVG a
  `flutter_svg`, así que una figura respeta el tema claro y el oscuro sin conocerlos.
- **Alternativas descartadas y por qué:**
    - *Pintar las figuras con `CustomPainter` desde un modelo propio:* exigía un segundo renderizador que reprodujera
      el kit de figuras del compilador y su contrato; `flutter_svg` dibuja exactamente el subconjunto que el contrato
      permite (sin marcadores, CSS ni `dominant-baseline`).
    - *Mantener `test/tool/spec_coverage_test.dart`:* comprobaba la proyección de `language-spec.md`, que ya no existe;
      la cobertura y la paridad las comprueba ahora el verificador `REF-COVERAGE` del miembro que genera el paquete.
- **Consecuencia:** el paquete se versiona porque lo consume un build ajeno a su generador; `REF-BUNDLE-STALE` falla
  si el paquete versionado no coincide con lo que el compilador produce.

---

### 4.63 Agente de IA integrado (Nodo)

- **Problema:** la persona necesita ayuda contextual —explicar un diagnóstico, escribir un programa correcto, resolver
  dudas de la app— sin salir de la pantalla, sin poner nunca una clave de un proveedor y sin que la ayuda enseñe código
  inválido ni regale la solución de un ejercicio.
- **Elección:**
  - **Paridad.** Nodo no tiene ninguna capacidad que la interfaz no ofrezca. Cada herramienta de escritura llama al
    mismo caso de uso que la acción manual (§4.1): crear, renombrar, editar, reemplazar o borrar documentos, fijar
    argumentos, crear o borrar ejercicios propios (§4.64), cambiar tema o idioma (`SetThemeMode`,
    `SetInterfaceLanguage`, que publican en `PreferenceUpdates` para que `SettingsCubit` refleje el cambio) y
    traducir un documento a otro perfil. Lo que escribe el agente aparece en la interfaz por `changes`.
  - **Herramientas como datos.** Un archivo por grupo en `application/agent/tools/`; cada herramienta declara nombre,
    esquema JSON, riesgo (`read`, `write`, `destructive`), si pide confirmación y la clave l10n de su paso visible.
    `composition/agent_tool_catalog.dart` compone el `ToolRegistry`; añadir una herramienta no toca el bucle.
    Catálogo: `get_screen_context`, `search_knowledge`, `list_documents`, `get_document`, `check_program`,
    `run_program`, `translate_program`, `format_program`, `get_route_progress`, `get_lesson`, `get_exercise`,
    `explain_diagnostic`, `create_document`, `rename_document`, `edit_document`, `replace_document_content`,
    `delete_document`, `set_execution_arguments`, `create_user_exercise`, `update_user_exercise`,
    `delete_user_exercise`, `give_hint`, `reveal_solution`, `navigate`, `set_theme`, `set_interface_language` y
    `set_profile`. El plan pedía también herramientas de ajustes de perfil por defecto; como el perfil por defecto se
    deriva del idioma, `set_profile` cambia el perfil de un documento.
  - **Confirmación.** `ConfirmationPolicy` exige confirmación para todo lo `destructive` y para lo que la herramienta
    marque (reemplazar todo el contenido, cambiar el perfil, crear o actualizar un ejercicio, revelar la solución). El
    bucle se suspende (`AgentAwaitsConfirmation`), la barra de confirmación muestra la acción y sus argumentos, y un
    rechazo devuelve al modelo `declined_by_person`; si el modelo vuelve a pedir la misma herramienta en ese turno se
    rechaza sin preguntar.
  - **Bucle en el cliente** (`AgentLoop`): el motor y los documentos están en el dispositivo, el servidor solo media
    el modelo y cobra (backend §4.10). Máximo de 14 llamadas al modelo por turno (`AgentExhausted`). Herramienta
    desconocida, argumentos que no son JSON y herramientas que lanzan se devuelven al modelo como salidas de error;
    un fallo de créditos o de red termina el turno (`AgentFailed`) con su `CreditFailure`.
  - **Proveedor.** `AgentModelGateway` con `ProxyAgentModelGateway` (Responses API por la función `agent-responses`,
    con el JWT de Supabase de `SupabaseAccessTokenSource`, `X-Request-Id` por llamada y `X-PseudoLearn-Turn-Id` por
    petición) y `FakeAgentModelGateway` (respuestas guionizadas para tests; sin guion responde `model_unconfigured`).
    Se elige con `--dart-define=AGENT_BACKEND=fake|proxy` y `AGENT_PROXY_URL` por búsqueda en un mapa, sin
    condicionales en composición; por defecto `fake`, así una build sin configurar dice «Nodo todavía no está
    disponible» y no llama a nadie. El cliente no elige modelo: lo fija el servidor.
  - **Prompt** (`PromptAssembler`): el prompt del sistema vive en `assets/agent/<idioma>/system-prompt.md`; le siguen
    la ficha del lenguaje y el índice del manual (bloque estable, primero, para aprovechar el caché de prefijos del
    proveedor) y al final el contexto dinámico: idioma, perfil por defecto, fecha, plataforma y la instantánea de
    pantalla. Nunca se envían el correo ni los tokens.
  - **Contexto de pantalla.** `ScreenContextBoard` (aplicación) implementa `ScreenContextSource`; los publicadores de
    `presentation/agent/context/` envuelven las páginas en el enrutador y publican una instantánea mínima construida
    en `application/agent/context/screen_snapshots.dart`: editor (id, título, perfil, cambios sin guardar,
    diagnósticos, argumentos, última ejecución con salida truncada y error, y si hay ejercicio: referencia, intentos
    fallidos, último veredicto y pistas disponibles, nunca casos ocultos), lección, especificación y pantallas
    estáticas. El texto completo solo sale con `get_screen_context` y se recorta a 20 000 caracteres.
  - **Código verificado.** `MarkdownReplyReader` (datos, §4.66) lee la respuesta completa y devuelve sus bloques y,
    aparte, sus bloques de código en orden; `CodeBlockChecker` analiza los de PseudoLearn con `ProgramAnalyzer` en el
    perfil del documento. La interfaz marca «Verificado» o «Con errores» y solo el verificado ofrece «Insertar en el
    editor».
  - **Modo tutor.** `ExerciseSessionCubit` implementa `ActiveExerciseSource` y cuenta intentos fallidos.
    `give_hint` devuelve la pista del nivel pedido; `reveal_solution` exige `explicit_request` y tres intentos
    fallidos, y pide confirmación. Ambas marcan el progreso como asistido (`SqliteAssistedProgressStore`, columna
    `assisted` del esquema 4) y la marca viaja en `ProgressEntry` y en la sincronización con fusión por O lógico. El
    panel de progreso muestra cuántos ejercicios resueltos fueron asistidos.
  - **Créditos y compras.** `CreditsCubit` lee el saldo por `CreditsGateway` y lo actualiza con las cabeceras de cada
    respuesta y con un agotamiento detectado a mitad de turno. `PurchaseCubit` compra con `PurchaseStore` y canjea con
    `CreditsGateway.redeem`; el único adaptador es `SimulatedPurchaseStore` (`purchase_store_simulation.dart`), y el
    servidor solo lo acepta con `AGENT_PURCHASES=simulated`. `agentAccessOf` decide la vista del panel: sin cuenta →
    oferta con «Inicia sesión»; sin plan ni recarga → oferta con prueba de 7 días y plan mensual; sin consentimiento →
    consentimiento; si no, conversación. Con el saldo agotado, el compositor se sustituye por el panel de recarga.
  - **Consentimiento.** Antes del primer mensaje: nombra a OpenAI, qué se envía, la retención y la edad mínima (13
    años). Se guarda en `agent_consent.json` del directorio de documentos (`FileAgentConsentStore`) y se retira en
    Ajustes → Nodo (`/ajustes/nodo`, que también muestra saldo, renovación, gasto de la última petición y recarga).
  - **Interfaz.** `AgentLauncher` vive en el armazón (`presentation/shell/adaptive_shell.dart`), no aparece en el
    onboarding (fuera del armazón), se oculta con el teclado y sube por encima del pie de ejecución en el editor
    escuchando al `routerDelegate`. El glifo propio (`AgentGlyphPainter`, excepción acotada en
    `docs/fundamentos-visuales.md` §6.2) tiene estados reposo, pensando, respuesta nueva y sin créditos. El chat se
    abre en hoja inferior en `compact` y en panel lateral en el resto, con burbujas, bloques verificados, pasos
    desplegables, barra de confirmación, compositor y enlaces a secciones de la especificación citadas como
    `specification:<id>`. La respuesta se dibuja como Markdown enriquecido (§4.66). `AgentChatPanel` envuelve su
    contenido en un `SafeArea` sin borde superior: `showModalBottomSheet` con `useSafeArea` solo protege el borde
    superior, y sin él el compositor quedaba sobre el indicador de inicio del iPhone. El fondo del panel sigue
    llegando al borde; solo el contenido se aparta. Con el teclado abierto el relleno inferior del sistema es cero,
    así que no se suma al desplazamiento del teclado.
  - **Textos.** Todo texto visible pasa por l10n; los nombres de paso son claves l10n declaradas por cada herramienta.
- **Decisiones que cambian el plan original y por qué:** los avisos de cambio son el getter `changes` y no un método
  (límite de métodos públicos); los ejercicios se sincronizan con bandera `dirty` en lugar de un decorador del outbox
  (§4.64); el glifo se verifica con el comparador `paints` de `flutter_test` en lugar de capturas de referencia, que
  el proyecto no usa (§4.48).
- **Alternativas descartadas:** bucle en el servidor (el motor no está ahí); embeddings (§4.65); la persona
  introduce su clave (se filtra y no permite cobrar).

### 4.64 Ejercicios del usuario: misma forma que un ejercicio `resolver`, publicados solo si su solución pasa

- **Problema:** la persona quiere practicar con enunciados propios (o que redacte el agente, §4.63) sin perder lo que
  hace pedagógica a la ruta: casos visibles y ocultos, aserciones estructurales, pistas graduadas y una solución que
  demuestre que el ejercicio tiene respuesta.
- **Elección:**
  - `UserExercise` guarda un `UserExerciseDraft` con título, narrativa en texto (opcional), enunciado, restricciones,
    pistas, casos visibles y ocultos, aserciones, solución de referencia obligatoria, código inicial y perfil.
  - `ExerciseContent` es la interfaz común que consumen la sesión de ejercicio y el evaluador. La implementan
    `Exercise` —la proyección de un ejercicio de la ruta que ya consumía el editor, ahora con `hints` y `origin`— y
    `UserExercise`. `RouteExercise` no la implementa directamente porque su texto son tramos enriquecidos; su
    proyección sí, y es la que usa la pantalla. `exerciseOfUser` proyecta un ejercicio del usuario a `Exercise`
    (narrativa antes del enunciado) para que la franja de ejercicio y `ExerciseSessionCubit` no distingan orígenes.
  - **Publicar es validar.** `ValidateUserExercise` exige título, enunciado, al menos un caso visible y solución;
    analiza la solución y la ejecuta con `ExerciseChecker` contra todos los casos y aserciones. Devuelve
    `ExercisePublication` con el problema, el caso que falla (y si es oculto) o las aserciones no cumplidas.
    `CreateUserExercise` y `UpdateUserExercise` no guardan nada que no valide. La narrativa vacía se admite: el
    enunciado basta para resolver.
  - **Referencias prefijadas.** El `exerciseId` de un intento es `route:<id>` o `user:<id>` (`ExerciseReference`). Un
    id sin prefijo se lee como `route:`: así los documentos existentes migran al leerse, sin reescribir archivos ni
    filas remotas. Los intentos nuevos de la ruta se escriben ya con prefijo. El progreso de un ejercicio del usuario
    usa `usuario.ejercicio:<id>` para no mezclarse con el de la ruta.
  - **Persistencia.** `SqfliteUserExerciseRepository` guarda una fila por ejercicio en `user_exercises` (esquema 4)
    con la carga en JSON (`user_exercise_codec.dart`, que reutiliza el lector de aserciones de la ruta), borrado
    lógico y bandera `dirty`. Emite `UserExerciseChange` por `changes`.
  - **Sincronización.** Se descartó un decorador sobre el outbox compartido porque `DocumentSyncDrainer` drena todas
    las entradas pendientes como documentos. Se sigue el patrón del progreso (§4.25): la bandera `dirty` marca lo que
    falta subir y `UserExerciseSyncDrainer`, invocado por `SyncDrainer` tras documentos y progreso, sube por la RPC
    `push_user_exercises` y baja por `server_revision` con su propio cursor en `sync_state`. En conflicto gana la
    edición con `updated_at` más reciente; un ejercicio lo edita una sola persona, así que no hace falta conservar
    ambas versiones. La subida envía `payload` como texto JSON y la RPC lo convierte a `jsonb`; la bajada, en cambio,
    lo recibe ya como objeto, porque PostgREST serializa las columnas `jsonb` como JSON y no como cadena.
    `userExercisePayloadText` acepta ambas formas y devuelve el texto que espera el decodificador. Antes la bajada
    leía la columna como cadena: el primer ejercicio subido hacía fallar cada `pullSince` y la Biblioteca mostraba
    «Error de sincronización» de forma permanente.
  - **Interfaz.** La Biblioteca separa algoritmos y ejercicios en dos pestañas (`LibrarySectionSelector`, sobre
    `AppSectionTabs`), cada una con su recuento, y la cabecera solo lleva el título, como las demás pantallas. Cada
    pestaña tiene su propia barra (`LibraryToolbar`): en «Algoritmos», el buscador y «Nuevo algoritmo»; en
    «Ejercicios», una línea que explica qué es un ejercicio y «Nuevo ejercicio». En `compact` el botón de crear es
    un «+» primario junto al buscador y en el resto lleva texto (`LibraryCreateAction`). Se descartó el botón único
    de la cabecera porque, con dos cosas que crear, un «+» sin contexto no dice qué crea, y se descartó apilar ambas
    listas en una sola columna porque la sección de ejercicios quedaba fija y la rejilla de algoritmos se desplazaba
    por debajo de ella. Ambas listas reservan al final el hueco del lanzador de Nodo para que la última tarjeta no
    quede tapada. Cada ejercicio tiene una tarjeta (`UserExerciseTile`) con la misma forma que la de un algoritmo: título, dos líneas del enunciado, el número de
    casos de prueba y de pistas, una única acción visible «Resolver» y el botón de opciones (⋮) que abre la hoja
    «Editar» / «Eliminar» (`user_exercise_menu.dart`). Tocar la tarjeta también resuelve. Antes las cuatro acciones
    eran botones de texto en un `Wrap` que se partía en varias filas en móvil y competía con el título; la acción
    frecuente queda a la vista y las de mantenimiento, una de ellas destructiva, se apartan como en las tarjetas de
    algoritmo. «Resolver» reutiliza el intento existente o crea un documento con `user:<id>` y abre la pantalla de
    documento de siempre.
  - **Editor.** `/biblioteca/ejercicio/:id` (con `nuevo` para crear) agrupa los diez campos en tres tarjetas
    numeradas —«El problema», «Cómo se comprueba», «Solución»— precedidas de una explicación de qué ocurre al
    publicar. Cada campo lleva junto a la etiqueta una insignia «Obligatorio» u «Opcional» (las mismas cuatro que
    exige `ValidateUserExercise`), un ejemplo como *placeholder* y una ayuda permanente debajo. Se eligió texto de
    ayuda visible en lugar de *tooltips* porque en táctil un *tooltip* exige pulsación larga y nadie lo descubre; la
    insignia es texto y no un asterisco para que no dependa de una leyenda, y el lector de pantalla recibe
    «Título, obligatorio» como etiqueta del campo. Los campos se describen como datos (`UserExerciseFieldSpec`), así
    que añadir uno no toca el widget que los dibuja. Los casos se escriben uno por línea (`2; 3 => 5`) y las
    aserciones con la forma `contiene: bucle-contado`; el formato vive en `exercise_text_format.dart` del modelo y un
    error de forma se informa antes de validar.
- **Fuera de alcance:** compartir ejercicios, imágenes en la narrativa y argumentos de programa por caso.

### 4.65 Conocimiento del agente: ficha generada, manual verificado y búsqueda local

- **Problema:** un modelo conoce PSeInt y no PseudoLearn, y tampoco sabe para qué sirve cada parte de la app. Sin
  contexto inventa sintaxis (base uno, sin `;`, parámetros sin tipo) y funciones de la interfaz.
- **Elección:**
  - **Ficha del lenguaje.** `assets/agent/<idioma>/language-sheet.md` la genera `see agent-sheet` desde el corpus
    (vocabulario, biblioteca, gramática, diferencias con PSeInt citando reglas y ejemplos canónicos del corpus). No se
    edita a mano (`GEN-NO-HAND-COPY`); la verificación del miembro de especificaciones falla si está desfasada.
  - **Manual de usuario.** `assets/manual/<idioma>/manual.json` tiene una entrada por funcionalidad visible con `id`
    estable, ruta, título, explicación y palabras clave. Cada entrada se ancla a un widget con
    `ValueKey('feature:<id>')` (la mayoría en `app_router.dart`, sobre la página). `tool/check_manual.dart` exige
    correspondencia en ambos sentidos y en ambos idiomas (`MANUAL-ORPHAN`, `MANUAL-UNDOCUMENTED`), ids únicos, ancla
    coherente y campos no vacíos; sus casos negativos viven en `test/tool/check_manual_test.dart`. El README técnico no
    es conocimiento del agente: habla de capas, no de qué hace un botón.
  - **Búsqueda local.** `AssetKnowledgeIndex` (`data/agent/`) implementa `KnowledgeIndex` sobre el manual, el índice
    de búsqueda del libro de referencia empaquetado y las secciones de la ficha. Tokeniza sin acentos ni palabras
    vacías, pondera por IDF, satura la frecuencia y da triple peso al título. Si el idioma pedido no da resultados
    repite la búsqueda en el otro. Cada resultado cita `fuente:id` para que la respuesta pueda enlazarlo. Se
    descartaron los embeddings: añaden un servicio y un coste para un corpus de unos cientos de documentos.
  - Los casos del corpus llegan a la búsqueda a través de los ejemplos de la ficha; el índice no carga la exportación
    completa (`export.json`, varios MB), que no se empaqueta.

### 4.66 Respuestas del agente en Markdown enriquecido: lector propio, modelo de bloques y vistas propias

- **Problema:** el modelo responde en Markdown de GitHub —tablas, listas, citas, código en otros lenguajes y diagramas
  Mermaid— y el chat lo mostraba como texto plano, con los marcadores a la vista. Una tabla comparativa o un
  diagrama del motor eran ilegibles en un teléfono.
- **Elección:**
  - **Lector en datos.** `MarkdownReplyReader` (`data/agent/markdown/`) implementa el puerto `ReplyMarkdownReader`
    sobre el paquete `markdown`, que ya era dependencia y es un analizador puro sin widgets. Usa el conjunto de GitHub
    (tablas, tareas, tachado, autoenlaces), los avisos `> [!NOTE]`… y los emojis por nombre. Convierte el árbol a un
    modelo propio del dominio (`ReplyBlock`: título, párrafo, lista con estado de tarea, cita o aviso, tabla con
    alineación, línea, código y diagrama; `ReplyRun`: texto con marcas y destino de enlace). La presentación nunca
    ve el árbol del paquete. El HTML en línea se reduce: `<br>` es un salto de línea y un conjunto cerrado de
    etiquetas de presentación (`kbd`, `sub`, `span`…) se quita conservando su texto. Solo se quitan etiquetas con
    atributos `nombre="valor"`, para que una comparación como `a<b y c>d` no desaparezca.
  - **El código no se separa con una expresión regular.** El lector anterior cortaba la respuesta por vallas de tres
    acentos, de modo que un bloque dentro de un elemento de lista rompía la lista. Ahora el mismo árbol produce los
    bloques y la lista ordenada de código; cada `ReplyCode` guarda su índice en esa lista y `CodeBlockChecker`
    verifica la lista. `AgentMessage` conserva el texto, los bloques y el código verificado.
  - **Resaltado.** El pseudocódigo se colorea con los `HighlightSpan` que el motor ya devuelve en el análisis que
    verifica el bloque, sin una segunda llamada. Los demás lenguajes se colorean con `highlightLexically`
    (`application/agent/highlight/`), un escáner a mano —la capa de aplicación no usa `RegExp`— que distingue
    comentarios de línea y de bloque, cadenas (con escapes, triples y plantillas), números, palabras clave, tipos,
    constantes, llamadas y nombres de etiqueta. Cada lenguaje es un dato (`CodeLanguage`) y los alias se resuelven en
    `code_language_catalog.dart`: añadir un lenguaje no toca el escáner. Un lenguaje desconocido solo colorea
    palabras y números. Ambos producen `HighlightSpan`, así que la vista reutiliza `highlightedCodeSpans` y la
    paleta del editor.
  - **Diagramas Mermaid propios.** No se incrusta un navegador con `mermaid.js`: no hay vista web en Windows sin otra
    dependencia, exigiría red o un activo de varios MB y no seguiría el tema. `parseMermaidFlowchart`
    (`data/agent/mermaid/`) lee `flowchart` y `graph` con sus cinco direcciones, las formas de nodo, etiquetas entre
    comillas o con `<br>`, cadenas `A --> B --> C`, grupos `A & B`, flechas sólidas, punteadas, gruesas, invisibles y
    bidireccionales con etiqueta en las dos sintaxis, y omite `subgraph`, `style`, `classDef`, `click` y comentarios
    `%%`. Una sentencia que no entiende se salta sin perder las demás. Otro tipo de diagrama devuelve `null` y la
    vista muestra su código con un aviso.
  - **Disposición por capas.** `layoutFlowchart` (`application/agent/flowchart/`) es puro y se prueba sin widgets:
    rompe ciclos invirtiendo las aristas de retroceso de un recorrido en profundidad, asigna rangos por camino más
    largo y acerca cada fuente a su primer sucesor, inserta nodos ficticios en las aristas largas, ordena cada rango
    por baricentro en cuatro barridos y coloca cada nodo bajo la media de sus predecesores sin solaparse. Trabaja en
    ejes abstractos (principal y transversal) y una sola transformación da `TD`, `BT`, `LR` y `RL`. La presentación
    mide las etiquetas con `TextPainter`, suma al hueco entre rangos la etiqueta de arista más gruesa y pinta con
    `ReplyFlowchartPainter`; las formas compartidas con el ordinograma salen de `FlowchartShapes`.
  - **Vistas.** `presentation/agent/reply/` tiene una vista por tipo de bloque. Tablas, código y diagramas se
    desplazan en horizontal en lugar de desbordar el teléfono. Toda la respuesta vive en un `SelectionArea` para
    poder seleccionar a través de bloques. Los títulos bajan dos niveles para no competir con la cabecera del panel.
    El diagrama ofrece «Ver código» y copiar su fuente.
  - **Prompt.** El prompt del sistema enumera lo que la app dibuja (y que no hay LaTeX ni imágenes) para que el
    modelo no gaste la respuesta en formatos que se verían crudos.
- **Alternativas descartadas:** `flutter_markdown` (descontinuado y sin tablas con desplazamiento ni bloques
  verificados), una vista web para Mermaid (arriba) y resaltado por expresiones regulares en la presentación (la capa
  no puede usar `RegExp`).
- **Pruebas:** `test/data/agent/markdown/`, `test/data/agent/mermaid/`, `test/application/agent/flowchart/`,
  `test/application/agent/highlight/` y `test/presentation/agent/reply/reply_rendering_test.dart`, que recorre el
  chat real con una respuesta que mezcla todos los bloques en escritorio y en teléfono.

## 5. Reglas de legibilidad, estilo y estructura de código

### 5.1 Filosofía de código auto-explicativo

- **Una sola responsabilidad por archivo:** Cada archivo debe poder describirse con una frase simple sin conjunciones
  copulativas ("y").
- **Idioma del código:** Todos los identificadores, métodos, variables, tests y mensajes de commit se redactan en inglés
  técnico. La documentación, manuales y especificaciones se escriben en español.

### 5.2 Límites métricos obligatorios (`architecture.yaml`)

El script `tool/check_limits.dart` valida de forma mecánica los siguientes topes:

| Métrica                     | Límite              | Ámbito de aplicación                                           |
|:----------------------------|:--------------------|:---------------------------------------------------------------|
| Líneas por archivo          | Máximo 250 líneas   | Todos los archivos bajo `lib/` (salvo generados)               |
| Líneas por función / método | Máximo 40 líneas    | Todas las funciones y métodos en `lib/`                        |
| Líneas por método `build`   | Máximo 30 líneas    | Métodos `build` de clases de widgets                           |
| Parámetros posicionales     | Máximo 3 parámetros | Todas las funciones y constructores                            |
| Profundidad de anidación    | Máximo 3 niveles    | Estructuras de control (`if`, `for`, `while`, `switch`, `try`) |
| Métodos públicos por clase  | Máximo 5 métodos    | Clases de dominio, cubits y servicios                          |

*Exenciones:* Se excluyen de límites métricos `test/`, `tool/` y `lib/presentation/l10n/generated/`. La anidación de
literales declarativos de widgets no cuenta como anidación de control.

*Dueños de valor declarados:* `color_literal_owner_paths` y `duration_literal_owner_paths` nombran los archivos
autorizados a escribir un `Color(...)` o un `Duration(...)` literal. La regla no persigue el literal en sí, sino el
valor suelto: uno con nombre y con un archivo dueño no lo está. Las dos listas viven en `architecture.yaml` y no dentro
del verificador, porque una excepción que solo consta en el código de un test es una excepción que nadie encuentra.

### 5.3 Política estricta de comentarios (`QUALITY-NO-COMMENTS`)

- **Prohibición absoluta en código Dart (`code_rules.forbid_comments: true`):**
    - Todo comentario de cualquier tipo (`//`, `/* */`, `///`) está estrictamente prohibido en los archivos `.dart`.
    - Los nombres de variables, funciones, widgets y clases junto con tipos explícitos expresan el *qué*.
    - Las razones y decisiones arquitectónicas residen en este `README.md`, nunca en comentarios dentro del código.
    - Se excluye de esta regla únicamente el código generado automáticamente por Flutter
      (`lib/presentation/l10n/generated/`, declarado en `comment_exempt`).
    - Esta regla es enforceada de forma mecánica por `tool/check_limits.dart` y validada por
      `test/tool/check_limits_test.dart`.

### 5.4 Convenciones técnicas y anti-patrones prohibidos

1. **Restricciones de Widgets:**
    - Una clase de widget solo expone públicamente `build` y, si corresponde, `createState`.
    - Ningún método helper privado puede devolver un `Widget`. Cualquier fragmento de árbol con nombre debe extraerse a
      una clase de widget independiente.
2. **Pureza de Presentación:**
    - Prohibido el uso de métodos de derivación y agregación de colecciones (`where`, `firstWhere`, `reduce`, `fold`,
      `sort`, `any`, `every`) dentro del árbol de widgets. La transformación a widgets mediante `map(...).toList()` sí
      está permitida.
    - Prohibido el uso de `await` dentro de métodos de widgets.
    - Prohibida la consulta de `MediaQuery.size` o plataforma fuera de `presentation/shell/`.
3. **Pureza de Composición:**
    - Prohibida toda ramificación condicional (`if`, `switch`, ternarios) en `composition/`. La elección de adaptadores
      se realiza seleccionando el punto de entrada o la fábrica correspondiente.

### 5.5 Gestión tipada de errores

- Ninguna excepción no controlada puede cruzar fronteras de capas o puertos públicos.
- Todo fallo esperable (falla de análisis, fallo de lectura de archivos, error de carga de contenido) se modela y
  retorna como un tipo de datos explícito mediante uniones o clases selladas (`ContentLoadResult`,
  `ExerciseCheckResult`, `AccountDeletionOutcome`, etc.).

---

## 6. Decisiones de producto que condicionan el código

### 6.1 Flutter dibuja cada píxel (prohibición de widgets adaptativos)

La aplicación garantiza paridad visual estricta entre sistemas operativos. No se aceptan desviaciones de aspecto
introducidas por controles nativos del sistema. Toda la interfaz se dibuja con los mismos tokens semánticos propios.

### 6.2 Local primero sin excepciones en el camino crítico

Ninguna pantalla ni flujo esencial de la aplicación requiere conectividad de red para operar. La aplicación arranca
instantáneamente con la base de conocimiento empaquetada y almacena los algoritmos localmente en el dispositivo.

### 6.3 Fidelidad sobre facilidad

El editor de código implementa un `CodeField` real compatible con selección precisa e IME, evitando atajos simplistas de
bloques visuales cerrados. La inserción de código añade plantillas completas con balance sintáctico estricto, y siempre
en la posición del cursor.

La barra de teclas del editor **añade** teclas; no sustituye el teclado del sistema, que es precisamente lo que esta
decisión protege: dictado, escritura por deslizamiento, autocorrección, portapapeles, tildes y `ñ`, y las vías de
accesibilidad (VoiceOver, TalkBack, Control por Interruptores, braille externo) siguen siendo las del sistema.

### 6.4 El error enseña: diagnósticos con rangos relacionados

Los errores léxicos, sintácticos y semánticos generados por el núcleo se proyectan preservando sus rangos de código
exactos y las ubicaciones secundarias vinculadas, orientando pedagógicamente al estudiante en la resolución del
problema.

### 6.5 El aliasing de objetos se enseña

La tabla de prueba de escritorio hace explícita la identidad de los objetos en memoria (`NombreClase#id`) y su mutación
a través de referencias compartidas, evitando abstracciones que oculten el modelo de punteros y referencias de la
computación.

### 6.6 Privacidad del borrador y sincronización opt-in

Los algoritmos del usuario residen localmente en el directorio gestionado de la aplicación como fuente de verdad
operativa primaria. El respaldo y la sincronización remota son estrictamente opcionales (opt-in): se activan única y
exclusivamente cuando el usuario decide de forma voluntaria iniciar sesión en su cuenta personal. Bajo sesión activa,
los
documentos se transmiten cifrados y quedan aislados en el espacio privado del usuario mediante políticas estrictas de
seguridad a nivel de fila (RLS) en el backend. Se prohíbe de manera absoluta e incondicional la emisión de telemetrías
de
comportamiento, métricas analíticas de uso, seguimiento de tiempos o envíos no autorizados de código a servidores
externos.

### 6.7 Determinismo en trazados, diagramas y ejecución

Un programa dado produce siempre la misma escena gráfica en los diagramas y la misma traza de ejecución, con
independencia de la resolución del monitor, la plataforma de hardware o la tipografía instalada en el sistema.

### 6.8 Comprobación pedagógica no punitiva

La resolución de ejercicios tiene carácter formativo. Se informa qué casos de prueba cumplen y se orienta sobre el
primer caso anómalo sin asociar notas numéricas, calificaciones ni penalizaciones.

### 6.9 Salida de sesión con preservación o borrado local selectivo

La aplicación ofrece dos acciones visualmente diferenciadas al cerrar sesión:

- **Cerrar sesión:** desconecta la cuenta remota pero preserva los documentos locales intactos en el dispositivo,
  garantizando que el usuario nunca pierda su trabajo fuera de línea accidentalmente.
- **Cerrar sesión y borrar datos de este dispositivo:** elimina los documentos locales del repositorio local tras
  solicitar confirmación explícita mediante un diálogo destructivo.
- En la interfaz de autenticación, la opción "Continuar con Apple" se ubica en primer lugar y se pinta con la variante
  `brandApple`, satisfaciendo la directriz 4.8 de App Store. Es la única variante de botón que no toma color de la
  paleta
  semántica: las directrices de Sign in with Apple fijan sus colores, así que invierte con el tema —tinta sobre lienzo
  en
  claro, lienzo sobre tinta en oscuro— con primitivas de marca propias, ajenas a la escala neutra de la aplicación.
- La dirección de reenvío privado de Apple se muestra íntegra y acompañada de la aclaración "Correo privado de Apple".
  El
  producto no oculta ni maquilla la dirección: es a donde llega el correo de la cuenta.

### 6.10 Arquitectura de sincronización offline-first y resolución no destructiva

- **Outbox persistente:** Toda mutación de documento encola una entrada en la tabla SQLite `sync_outbox`. El usuario
  siempre interactúa a velocidad de disco local, independientemente de la latencia o disponibilidad del backend.
- **Pull antes que push:** Cada ciclo de vaciado de cola drena primero los cambios remotos pendientes antes de empujar
  los locales. Esto garantiza que cualquier edición concurrente se evalúe contra la versión común más reciente.
- **Conflictos conservados (`KeepBoth`):** Los conflictos nunca descartan silenciosamente el trabajo del usuario. Se
  adopta la versión remota
  en el ID principal y se genera una copia local con el contenido en conflicto titulada `... (conflicto)`.
- **Composición incondicional:** `SyncingDocumentRepository` decora siempre a `FileDocumentRepository` en la raíz de
  composición, eliminando ramas condicionales de runtime entre modos online y offline.

### 6.11 Unión monotónica de progreso y partición de preferencias

- **Convergencia sin intervención:** El progreso de aprendizaje es un conjunto de crecimiento monótono. Al no existir
  eliminaciones ni regresiones de avance en el uso ordinario, cualquier sincronización converge calculando la unión
  lógica
  de las banderas de visita y completado, y el mínimo temporal de las fechas de primer logro. Reenviar un lote es seguro
  e idempotente.
- **Partición de preferencias por ciclo de vida:** Los datos de personalización de la experiencia pertenecen a la
  identidad
  del usuario (`AccountPreferences`), mientras que los parámetros de renderizado visual y fuentes pertenecen al entorno
  físico de ejecución (`DevicePreferences`). Solo los primeros se sincronizan.

### 6.12 El panel de progreso mide cobertura, nunca rendimiento

El panel resume el trabajo hecho sin emitir juicio: cuenta lecciones visitadas, ejercicios resueltos, algoritmos
escritos y construcciones ejercitadas, siempre como «hechos de un total» y nunca como porcentaje de logro, nota ni
racha. Una semana sin actividad se dibuja como una barra a cero, no como una marca de fallo, y no existe comparación
con nadie. Quedan fuera por decisión de producto, no por alcance: intentos por ejercicio y tasa de acierto —el
sistema no almacena intentos—, tiempo dedicado por lección —sería telemetría de comportamiento— y cualquier
comparación entre estudiantes.

### 6.13 La cuenta solo se da por eliminada cuando el servidor lo confirma

«Eliminar cuenta» es irreversible y completo: borra el usuario del servidor, todos sus datos sincronizados, revoca Sign
in with Apple y purga documentos y progreso del dispositivo. Mientras el servidor no responda con éxito, la aplicación no
toca nada local y lo dice: la cuenta y los documentos siguen intactos y la acción se puede repetir. Las cuentas de Apple
confirman la identidad con la hoja nativa de Apple en el momento de eliminar, y el diálogo de confirmación lo anticipa.
Donde esa hoja no existe (Windows), la aplicación no lo intenta: dice que la cuenta se elimina desde un dispositivo de
Apple y no toca nada.

---

## 7. Verificación, testing y aseguramiento de calidad

### 7.1 Matriz de verificadores mecánicos

| Verificador                    | Comando / Script                                                         | Qué valida                                                                                                                                       | Regla en                        |
|:-------------------------------|:-------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------|
| Linter estricto                | `flutter analyze --fatal-infos --fatal-warnings`                         | Errores de tipo, null safety, dead code, imports no usados                                                                                       | `analysis_options.yaml`         |
| Límites métricos y comentarios | `dart run tool/check_limits.dart`                                        | Líneas de archivo, funciones, build, anidación, métodos, parámetros, y ausencia total de comentarios en código                                   | `architecture.yaml`             |
| Ruta de aprendizaje            | `cargo xtask verify` en `packages/pseudolearn_reference`                 | Anatomía de lecciones, términos, mezcla de ejercicios, soluciones y respuestas ejecutadas, paridad y paquete al día (verificadores `RUTA-*`)     | `packages/pseudolearn_reference/README.md` |
| Sistema de diseño              | `dart run tool/check_design_system.dart`                                 | Familias tipográficas en disco, ausencia de medidas crudas en padding/espacios y unicidad de `DesignCanvas`                                      | `architecture.yaml`             |
| Especificación ilustrada       | `cargo xtask verify` en `packages/pseudolearn_reference`                 | Ejemplos ejecutados, anclajes, cobertura, paridad, contrato de figuras y paquete al día (verificadores `REF-*` de ese miembro)                    | `packages/pseudolearn_reference/README.md` |
| Capas y dependencias           | `flutter test test/architecture/layering_test.dart`                      | Matriz de `may_import`, `forbidden_imports`, ausencia de imports package propios y rechazo del puente generado desde el dominio                   | `architecture.yaml`             |
| Generación Rust–Dart           | `bash tool/bridge.sh check`                                               | Regeneración y comparación limpia de los enlaces Rust y Dart versionados                                                                          | `.flutter_rust_bridge.yaml`     |
| Transporte Dart–FFI real       | `bash tool/test_bridge.sh`                                                | Construye la biblioteca nativa y verifica por FFI sesión, capacidades, errores y cierre                                                           | `native/README.md`              |
| Pureza de presentación         | `flutter test test/architecture/presentation_purity_test.dart`           | Prohibición de constructores adaptativos, métodos de derivación de colecciones, `await` y `MediaQuery` fuera de shell                            | `architecture.yaml`             |
| Pureza de composición          | `flutter test test/architecture/composition_purity_test.dart`            | Ausencia total de condicionales en `composition/`                                                                                                | `architecture.yaml`             |
| Inmutabilidad de estados       | `flutter test test/architecture/state_immutability_test.dart`            | Campos estrictamente `final` en archivos `*_state.dart`                                                                                          | `architecture.yaml`             |
| Cadenas visibles               | `flutter test test/architecture/no_user_facing_strings_test.dart`        | Ausencia de literales de texto en español fuera de capas de localización y vocabulario autorizado                                                | `architecture.yaml`             |
| Consultas de plataforma        | `flutter test test/presentation/platform_target_verification_test.dart`  | Constructores adaptativos prohibidos en todo `lib/`, y `Platform.isX` / `defaultTargetPlatform` / `TargetPlatform.` solo en las rutas declaradas | `architecture.yaml`             |
| Familias empaquetadas          | `flutter test test/presentation/theme/bundled_fonts_test.dart`           | Que la suite rasterice con IBM Plex y no con el tipo de relleno del motor, con un caso negativo sobre una familia inexistente                    | `test/flutter_test_config.dart` |
| Fidelidad de la marca          | `flutter test test/presentation/brand/ test/presentation/rendering/brand/` | Que las medidas del lockup sigan coincidiendo con el generador de vectores, y que el símbolo aguante la reducción a 16, 24, 32 y 48 px          | `brand/README.md`               |
| Material para tiendas          | `flutter test tool/generate_store_material.dart`                         | Composición sobre app viva, ausencia de canal alfa (Truecolour tipo 2), auditoría de directrices de tienda y tipografía empaquetada              | `tool/product/`                 |

### 7.2 Estrategia y pirámide de pruebas

- **Estructura espejo:** La carpeta `test/` reproduce con exactitud la jerarquía de carpetas de `lib/`.
- **Doble camino:** Toda unidad se prueba en su camino exitoso, en sus caminos de fallo controlados
  y ante casos límite (árboles vacíos, identificadores de un carácter, recursión profunda, programas sin salida).
- **Pruebas de verificadores (Casos negativos):** En `test/architecture/fixtures/` se mantienen violaciones deliberadas
  para constatar que cada verificador falla efectivamente ante infracciones.
- **Renderizado de widgets:** las pruebas recorren tamaños representativos y comprueban composición, presencia de
  elementos y ausencia de excepciones. No comparan capturas ni bloquean cambios de rasterización entre anfitriones.

### 7.3 Señales de alerta al revisar (Code Review Checklist)

El revisor o agente de IA debe rechazar inmediatamente un cambio si detecta:

- [ ] Importaciones hacia capas superiores o no declaradas en `architecture.yaml`.
- [ ] Presencia de métodos helper privados que retornen `Widget`.
- [ ] Uso de combinadores de colección (`where`, `sort`, `reduce`, `fold`) en widgets.
- [ ] Invocaciones a `await` dentro del árbol de presentación.
- [ ] Expresiones regulares (`RegExp`) fuera de las capas autorizadas.
- [ ] Constructores adaptativos del sistema operativo (`*.adaptive`).
- [ ] Condicionales dentro de `composition/`.
- [ ] Archivos o métodos que superen los límites de líneas de `architecture.yaml`.
- [ ] Comentarios que parafraseen el código o citen documentación externa.
- [ ] Modificación de arquitectura o decisiones sin actualización de este `README.md`.

---

### 4.50 Asistencia de edición: el núcleo decide el texto, la app solo lo aplica y lo dibuja

- **Problema:** el completado existía pero no se veía: la única superficie era una segunda fila plegada de la barra de
  teclas, que además exigía teclado en pantalla, de modo que en escritorio nunca aparecía. Y la lógica del lenguaje que
  rodea al completado —sangría de una plantilla, apertura de línea, cierre de bloques— vivía duplicada en Dart.
- **Elección:** la app mantiene tres responsabilidades y ninguna de lenguaje. (1) Capturar teclas y mapearlas a
  peticiones: `Ctrl+Espacio` invoca la lista, las flechas la recorren, `Enter` o `Tab` aceptan, `Esc` la cierra, y
  `Tab`, `Mayús+Tab` y `Esc` recorren y terminan las paradas de una plantilla. (2) Aplicar al búfer, sin interpretarla,
  la edición que devuelve el puerto `EditAssistSource`, convirtiendo UTF-8 a UTF-16 en `RustEditAssistSource`, que
  sincroniza la sesión del núcleo enviándole la diferencia mínima entre el texto anterior y el actual
  (`SingleTextEdit`) sin partir pares sustitutos. (3) Dibujar: `EditorAssistLayer` mide el cursor sobre
  `EditableTextState` para anclar la lista emergente y deriva la línea base del texto para el fantasma, y la barra móvil muestra la fila de
  candidatos mientras la asistencia está activa y los controles de paradas mientras hay una plantilla en curso.
- **Ajuste desactivado por omisión.** `DevicePreferences.editorAssistance` apaga solo lo no solicitado: lista y texto
  fantasma al escribir y la asistencia al teclear. La invocación explícita, la fila de plantillas y el recorrido de
  paradas de una plantilla ya aceptada siguen disponibles. El ajuste viaja como parámetro de `updateSourceCode`
  (`assisted`), no como estado del cubit, que ya está en su tope de métodos públicos.
- **Una sola vía de edición.** Aceptar un candidato, insertar una plantilla y moverse entre paradas son claves del
  editor (`EditorKey.completion`, `EditorKey.template` con su `construction`, `EditorKey.stop`) que `RustSourceEditor`
  traduce a operaciones del núcleo; no hay un método nuevo en `EditorCubit`. Se elimina de Dart la re-sangría de
  plantillas y el salto de línea previo, que ahora decide el núcleo con la sangría de la línea destino. La tecla de
  sangría y la de des-sangría siguen en Dart: no dependen de la gramática.
- **Detalle localizado.** El núcleo emite claves con argumentos (`close_block`, `structure`, …) y la app las localiza
  al idioma de interfaz con `localizedCompletionDetail`; el idioma de interfaz no cambia los lexemas ni el orden.
- **El texto de la lista sale del estado, no del árbol de widgets.** `EditorState` deriva `popupCandidates`,
  `completionPrefixLength`, `inlineCandidate` y `ghostText`; la presentación solo los dibuja, como exige su regla de no
  derivar datos.
- **Alternativas descartadas:** un cubit nuevo para la asistencia, porque duplicaría el texto que ya posee
  `EditorCubit`; calcular la sangría en Dart con el vocabulario de aperturas, que es la duplicación que se elimina;
  una lista flotante en móvil, porque taparía el código y la barra sobre el teclado ya cumple ese papel; anclar la lista
  en un `Overlay` global, porque exigiría conservar coordenadas de desplazamiento ajenas al campo.
- **Línea base del fantasma.** El origen vertical sale de la línea base de la línea del documento, medida con un `TextPainter` del mismo `TextSpan`, `StrutStyle` y escalado que el campo, menos la línea base del propio sufijo. No se parte de la caja de selección del campo porque esa caja viene redondeada a píxel y dejaba el fantasma hasta un píxel lógico por encima del texto escrito.
- **Altura del cursor.** `CodeTextInput` fija `cursorHeight` en el tamaño de fuente por `editorCaretHeightFactor`; con la altura de línea completa la barra sobresalía bajo la línea base y se leía como un hueco entre la última letra escrita y el texto fantasma, que se ancla exactamente al borde del cursor.
- **Intención y vigencia del texto fantasma.** El núcleo deja en silencio las líneas vacías y entrega la continuación
  de asignación solo para un destino simple confirmado. La app muestra únicamente el sufijo pendiente de la primera
  línea del texto insertable, normalizando para la vista los espacios ya escritos; no reconoce operadores ni variables.
  Lista y fantasma requieren foco, selección colapsada, ausencia de composición activa, texto sincronizado y candidatos
  con revisión y extremo de reemplazo iguales a los del estado y cursor actuales. Los cambios de foco, selección y
  composición actualizan la visibilidad inmediatamente. `Tab` acepta el fantasma; `Enter` sigue siendo salto de línea y
  `Esc` lo descarta. Aceptar un nombre y aceptar después su continuación son acciones separadas.
- **Una superficie disponible.** `EditorState.usesSuggestionBar` concentra la decisión a partir de la capacidad de
  entrada, presencia de teclado, disponibilidad de teclas y estado de ejecución. `EditorSurface` proyecta ese mismo
  resultado a la banda y a la capa anclada: mientras la banda está disponible no hay fantasma ni lista flotante; sin
  ella se conservan las superficies ancladas y los atajos. No hay nuevas consultas de plataforma ni preferencias.
  La presencia sigue siendo la señal del lienzo basada en `viewInsets`; no se afirma que detecte un teclado físico
  conectado ni todos los teclados flotantes. Verificar esos modos en dispositivo sigue pendiente.
- **Vista previa táctil.** `CompletionItem.insertionPreview` deriva la primera línea del texto insertable recibido,
  sin espacios finales; la banda dibuja ese dato y conserva la etiqueta y edición originales al aceptar. Así `area`
  puede mostrar `area <-` sin reconocer operadores en presentación. Las plantillas siguen insertándose completas.
- **Geometría del fantasma.** `editor_assist_geometry` distingue el rectángulo del cursor de la línea base del texto.
  Mide el grafema anterior al cursor con la fuente, escala, strut, dirección y comportamiento de altura del campo y
  transforma su caja real en una línea base para el fantasma. Los pintores temporales se liberan tras medir; no se
  alteran el búfer ni los índices, ni se usan compensaciones por plataforma. El cursor se conserva como ancla de la
  lista. Las notificaciones de desplazamiento actualizan ambas posiciones. Las pruebas comparan cajas tipográficas
  en iOS, macOS y Windows a escalas 1.0 y 1.6, además del desplazamiento y la transición entre superficies.
- **Pendientes declarados:** los controles de paradas no tienen atajo propio fuera de `Tab`; la validación física de
  teclados externos y flotantes sigue pendiente. La banda táctil es la vía de aceptación cuando está disponible.

## 8. Fuentes consultadas y genealogía conceptual

| Fuente consultada                                                 | Qué se tomó                                                                                                                                                                   | Qué se rechazó deliberadamente y por qué                                                                                                      |
|:------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------|
| Material Design 3 (Google)                                        | Corte base de 600 dp entre clases de ventana compacta y mediana.                                                                                                              | Escala de cinco clases y comportamientos adaptativos automáticos de widgets que rompen la consistencia multiplataforma.                       |
| Guía de diseño adaptativo de Flutter                              | Estructura de armazón con navegación compartida entre barra inferior y riel lateral.                                                                                          | Variaciones automáticas de densidad, física de scroll y estilos dependientes del sistema operativo.                                           |
| Arquitectura Hexagonal (A. Cockburn)                              | Puertos independientes de la tecnología y adaptadores periféricos intercambiables.                                                                                            | Terminología empresarial compleja (DTOs, repositorios genéricos pesados) innecesaria en un cliente de aplicación interactivo.                 |
| BLoC Pattern (`package:bloc`)                                     | Modelo de estados inmutables precalculados y comandos unidireccionales mediante `Cubit`.                                                                                      | Patrón completo de eventos por introducir burocracia redundante frente a la traza ya provista por el núcleo.                                  |
| ISO 5807:1985 (Símbolos para diagramas de procesamiento de datos) | Convenciones geométricas: terminal ovalado, proceso rectangular, decisión en rombo, E/S en romboide y proceso predefinido en rectángulo con barras.                           | Símbolos de almacenamiento físico (cintas magnéticas, discos, tarjetas perforadas) por carecer de sentido en pseudocódigo abstracto.          |
| PSeInt (Pablo Novara)                                             | Representación del bucle `Para` como nodo único de preparación e inspiración en estructogramas integrados.                                                                    | Estética visual no estructurada, diagramado como imágenes fijas no interactivas y falta de determinismo algorítmico documentado.              |
| Nassi, I. y Shneiderman, B. (1973)                                | Principio fundamental del estructograma: modelado jerárquico de control estructurado sin aristas explícitas de salto.                                                         | Repertorio original sin normalizar previo a la adopción de selección múltiple estandarizada.                                                  |
| DIN 66261:1985-11                                                 | Catálogo de celdas para estructogramas: proceso, selección con cabecera de cuñas, bucles con franja indentada y subprogramas con doble barra.                                 | Proporciones fijas inflexibles y ausencia de representaciones explícitas para salida anticipada (`Retornar`).                                 |
| Ruteo ortogonal y diagramas de clases UML (OMG UML 2.5)           | Caja de tres compartimentos, visibilidad `+`/`-`, jerarquía de generalización y relación de asociación.                                                                       | Diagramado libre manual, multiplicidades complejas innecesarias en el nivel de abstracción del lenguaje y conectores diagonales.              |
| Sign in with Apple (Human Interface Guidelines y App Store 4.8)   | Prioridad del acceso con Apple, colores y contraste del botón de marca, y flujo de nonce con resumen SHA-256 contra reutilización de token.                                   | Botón nativo del complemento, por imponer métricas, radios y tipografía propias que rompen el sistema de diseño de la aplicación.             |
| App Store Review Guidelines 5.1.1(v)                              | Eliminación de cuenta iniciable desde la app, completa e inmediata, con revocación de Sign in with Apple.                                                                     | Enlazar a un formulario web o a soporte para eliminar la cuenta, por exigir salir de la aplicación.                                          |
| Directrices de activos gráficos de App Store y Google Play        | Requisitos dimensionales (iPhone 6.9", iPad 13", Mac 16:10, Feature Graphic 1024×500), exigencia estricta de opacidad (sin canal alfa) y políticas de contenido en titulares. | Composición manual en herramientas externas y captura manual sobre simuladores por inducir desalineación visual y canales alfa involuntarios. |
| Apple: valoraciones y reseñas (HIG) y `RequestReviewAction`      | Petición nativa tras un logro y no al abrir la app; tope de tres peticiones cada 365 días como criterio para elegir tres hitos.                                               | Invocar la petición desde un botón y filtrar antes con un diálogo propio de satisfacción, por ir contra las directrices de Apple.            |

El inventario oficial de [xcode-27](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md)
se usa para seleccionar macOS y arquitectura del entorno de prueba, no para definir el producto.

### Observación de colecciones

El adaptador Rust de la tabla de variables consume las entradas vector y diccionario de query_object y muestra su longitud con delimitadores distintos, conservando la insignia de identidad compartida. No interpreta bancos, versiones ni índices del runtime. Los mapas de transporte siguen siendo la frontera; no cambia el puente generado ni se añade lógica del lenguaje en Dart. Las pruebas del consumidor quedan pendientes de autorización junto a las del motor.

### Registros por hojas y vínculos de bloque en la traza y el estado (PG-L)

`RustWatchRows` muestra una fila por cada entrada de `variables` de `API.STATE.QUERY` sin reinterpretarla: una variable, un campo de clase o un arreglo de tipo registro llega del motor como una entrada por hoja (`q.x`, `p.x`, `a.x`) y la tabla la presenta así, con `-` para una hoja sin valor. Un vínculo declarado dentro de un bloque deja de aparecer en el estado de un evento posterior al cierre de su ámbito porque la consulta del motor filtra por el intervalo léxico; la app no conserva filas de eventos anteriores. Cubre `rust_watch_rows_test.dart`; el filtrado lo prueba el motor en `pseudolearn_api/tests/scope_release.rs`.

### Proyección de capacidades en la vista del programa (`PG-3.09`)

`RustViewSemantics` lee de cada nodo de la vista pública los atributos `builtin_type` (`bytes`, `io_error`), `capability_type` (`console`, `arguments`, `directory`, `file`, `clock`, `timer`) y `effect_operation` (identidad de `LIB.MODEL`) que proyecta `pseudolearn_api`; un nodo sin ellos no expone ninguno. La app solo los transporta: no interpreta la autoridad de una capacidad, que sigue siendo del anfitrión real (`HostWorker`). Cubre `test/engine/rust/rust_view_semantics_test.dart`.

### Datos estáticos tipados de la vista pública

`RustProgramView.decode` conserva `revision_id` y crea el mapa de `node_id` público a ordinal local. Valida campos requeridos, tramos Unicode y vínculos de la vista antes de construir modelos inmutables de realizaciones, restricciones, variantes, capturas, iteraciones y ámbitos; un campo ausente o mal formado y una referencia inexistente o ajena devuelven `RustProgramViewReadFailure`. Los atributos desconocidos se ignoran para aceptar extensiones aditivas. `RustProgramViewSource` envía el texto original con perfil y rigor explícitos; los modelos solo describen datos estáticos y no calculan disposición ni dibujan diagramas.

| Dato consumido | Campo de `API.PROGRAM.VIEW#R5` | Prueba de consumidor |
|---|---|---|
| Realización nominal | `realizations`, origen, validez y diagnósticos por `node_id` | `rust_program_view_test.dart`; `program_view_nominal.rs` |
| Restricción genérica | `constraints` y destino de contrato por identidad | `rust_program_view_test.dart`; `program_view_nominal.rs` |
| Variante y carga | `variant` y roles de hijos, sin carga sintética para `none` | `rust_program_view_test.dart`; `program_view_nominal.rs` |
| Captura | `captures` con vínculo y modo `value` | `rust_program_view_test.dart`; `program_view_nominal.rs` |
| Iteración y ámbito | `iteration` con colección, vínculos, cuerpo y dueño | `rust_program_view_test.dart`; `program_view_nominal.rs` |
| Revisión, referencias y rangos | `revision_id`, IDs del mismo origen, hijos y tramos Unicode | `rust_program_view_test.dart`; `source_identity_tests.rs` |
| Salidas y limpiezas | `control_exit`, `normal_cleanups` y `cleanup_scope_node_id` de `API.PROGRAM.VIEW#R10` | `rust_program_view_exits_test.dart`; `program_view_exits.rs` |

### Contratos, realizaciones y restricciones en el diagrama de clases (`PG-A.03`)

La regla de representación vive en `API.PROGRAM.VIEW#R6`–`R9` y `R12`, observada por el sujeto `app` con el escenario `class_diagram` (`tool/see_app_class_diagram.dart`), que resume la escena real que construye `RustClassDiagramBuilder` sin respuestas precalculadas. El motor no tiene caso propio para estas reglas: su vínculo está exento porque la representación es del consumidor.

- **Caja de contrato.** Una interfaz es un `ClassBox` de tipo `interfaceContract`: cabecera con el estereotipo «interface» sobre el nombre, una fila por firma y ningún atributo. Permanece visible sin implementaciones. La lectura sale de los nodos `interface_unit`/`interface_signature` de la vista pública, no de `units`, que no los lista.
- **Realización.** Se proyecta una `ClassRelation` de tipo `realization` por cada realización explícita de `staticData.realizations`, por identidad de nodo. Se dibuja discontinua con triángulo hueco hacia el contrato; la herencia sigue continua. La realización heredada válida no se redibuja: la herencia la transporta y duplicarla sobrecargaría el lienzo sin añadir información. Una realización heredada inválida por `incompatibleMethodOverride` sí se dibuja desde la subclase hacia el contrato; su origen es el nodo del método que sobrescribe.
- **Estado inválido.** La relación conserva los códigos de diagnóstico y el nodo de origen (`originNodeId`), se pinta con el color de error, con guiones más cortos y con una etiqueta que empieza por `!`: nunca se distingue solo por el color. Una operación implementada con otra firma en la clase que declara el contrato es `interfaceMethodSignatureMismatch`; una sobrescritura incompatible heredada usa `incompatibleMethodOverride`. Un contrato desconocido no crea relación ni caja; aparece como fila de incidencia (`ClassRowRole.contractIssue`) en la clase, anclada al nodo de la referencia escrita.
- **Restricción genérica.** Un subprograma con restricción se muestra como caja «subprogram» con su firma y una relación `usage` (discontinua, punta abierta) hacia el contrato, etiquetada con el nombre del parámetro. No se crean valores de interfaz ni despacho. En una clase o interfaz genérica la restricción se escribe en la cabecera (`Caja<T: Imprimible>`) y no crea relación de uso: la caja ya nombra el contrato y una arista por parámetro duplicaría la realización.
- **Clases, interfaces y variantes genéricas (`R12`).** `RustTypeParameterText` compone la lista `<T, U: I>` desde los nodos `type_parameters`/`type_parameter` de la vista y `ClassBox.typeParameters` la añade al nombre en la cabecera (`ClassBox.title`); el nombre sin parámetros sigue siendo la identidad con la que se enrutan las relaciones. La herencia de `Base<T>` y la realización de `Medible<T>` se rotulan con el texto del nodo `type_arguments` que sigue al identificador de la base o del contrato. Las realizaciones de una plantilla de clase llegan de la vista por identidad de nodo, como las de una clase concreta. Un campo de tipo registro es una fila `nombre: Registro` y no crea asociación, que solo une clases. Una variante declarada (`variant_unit`) es una caja «variant» (`ClassBoxKind.variant`) con una fila por alternativa, `nombre` o `nombre(campo: tipo, …)`, sin marca de visibilidad, después de registros y enumerados en orden de fuente.
- **Registros, enumerados y parámetros de tipo (`R12`).** `RustValueTypeProjection` lee los nodos públicos `record_unit` y `enum_unit` (tampoco figuran en `units`): un registro es una caja «record» con una fila `nombre: tipo` por vínculo de cada campo declarado; un enumerado, una caja «enumeration» con una fila por miembro, sin marca de visibilidad (`ClassRowRole.enumMember`). `RustGenericSubprogramBoxes` da caja «subprogram» a todo subprograma con `type_parameters`, tenga o no restricción (`ClassBoxKind.genericSubprogram`). Ninguna de estas cajas crea relaciones ni pasos en ordinograma o estructograma. Cada fila conserva el nodo del miembro o del vínculo, de modo que navegarla lleva a su texto exacto.
- **Colocación.** `ClassBox.contractNames` hace que `InheritanceLevels` coloque el contrato por encima de sus realizaciones, con protección contra ciclos. Las relaciones se enrutan por `nodeId` y recurren al nombre solo si falta. El orden de cajas es clases, interfaces, registros y enumerados en orden de fuente y subprogramas genéricos.
- **Semántica accesible y navegación.** `RustClassDiagramBuilder` adjunta a la escena el rango de fuente de cada nodo y de cada origen de relación (`DiagramScene.sourceRanges`). `ClassDiagramAccessibility` (capa de aplicación) deriva un `DiagramAccessibleElement` por caja, fila y relación, con nombre, extremos, diagnósticos, límites y rango; la relación usa su origen y, si no lo tiene, la caja de la que parte, y su zona de toque es un cuadrado de `ClassDiagramMetrics.relationHitSize` en el centro de su tramo medio. `ClassDiagramSemanticsLayer` conserva el texto completo aunque el lienzo recorte una fila, expone cada destino como botón accesible y permite recorrerlos en orden de lectura con `Tab`; `Enter`, `Espacio` y la acción semántica activan la selección. El destino enfocado muestra un borde de 2 px con el color primario. La relación se anuncia con su tipo localizado y, si es inválida, con «inválida: códigos» («invalid: codes»), de modo que la invalidez es texto accesible y no color. Activar el elemento llama a `EditorCubit.revealSource`, que reutiliza `pendingEdit` con el mismo texto y una selección igual al rango: la superficie del editor selecciona el código sin editarlo ni marcar el documento como modificado.
- **Sobrescritura incompatible heredada.** La vista conserva `incompatibleMethodOverride` cuando el análisis lo relaciona con la firma de una interfaz y marca inválida la realización heredada. El diagrama dibuja esa relación con el estilo de invalidez de `R8`; las realizaciones heredadas válidas siguen sin redibujarse. `method_signature_span`, derivado de la estructura sintáctica por la API, hace que tocar la relación seleccione exactamente el encabezado del método que sobrescribe. `ClassDiagramSemanticsLayer` anuncia la invalidez y el código del diagnóstico.
- **Fuera de alcance de este punto.** La etiqueta pintada de una relación inválida muestra el código de diagnóstico sin localizar; el mensaje localizado se obtiene del diagnóstico enlazado por origen.

Pruebas: `rust_type_contract_diagram_test.dart` (motor real, es/en, incluidas las escenas de método heredado y firma incompatible), `rust_value_type_diagram_test.dart` (registros, enumerados, variantes, genéricos y nodos navegables), `rust_type_parameter_text_test.dart` (cabeceras genéricas con restricción, campo registro sin asociación y rótulos `<T>` de herencia y realización), `class_shapes_test.dart` (dirección del triángulo, punta abierta, guiones y color por estado), `class_diagram_layout_test.dart` (relaciones múltiples y etiquetas largas dentro del lienzo), `class_diagram_accessibility_test.dart` (límites de toque y rangos), `class_diagram_semantics_layer_test.dart` (árbol `Semantics`, rango exacto, teclado, vista compacta y escala de texto 2), `rust_class_diagram_integration_test.dart` (FRB nativo recién compilado, proyección → escena → selección → ayuda y balance de recursos) y `editor_source_reveal_test.dart` (selección sin edición).

### Matriz de cobertura sintáctica y respuesta no soportada (`PG-A.04`)

`lib/domain/model/diagram/coverage/` contiene la matriz como datos: cada fila declara construcción, papel público (`statement`, `declaration`, `expression`, `symbol`, `type`), formas públicas, anclaje de regla con versión, seis celdas (ordinograma, estructograma, estructura, foco, estado, ayuda) y la prueba que la respalda. Una celda es `exact`, `declaredExtension` o `notApplicable`, y las dos últimas exigen motivo; una ayuda exacta se declara con `CoverageCell.help` y nombra una ficha del catálogo de ayuda. Es distinta de `AstConstruct`, que es la taxonomía curricular del panel de progreso y no prueba exhaustividad; incluye `interface_unit` porque el ejercicio bilingüe `CON-C4-E7` requiere medir esa construcción junto con las clases. Las filas están repartidas por familia en tres archivos (sentencias, declaraciones y expresiones) para respetar el límite de tamaño.

El contrato del verificador es `API.PROGRAM.VIEW#R13`, con un caso por código observado por el escenario `syntax_coverage` (`tool/see_app_syntax_coverage.dart`), que aplica una mutación concreta a la matriz real (quitar, duplicar, cambiar papel, añadir forma, quitar motivo, ocultar control, ayuda inexistente) y devuelve los códigos que produce. `dart run tool/check_syntax_coverage.dart` contrasta la matriz con el inventario público del motor, que lee de los archivos `program_view_kind.rs` y `program_view_tasks.rs` (nombre de sintaxis y papel de cada forma), y con las fichas `helpCatalog` de `specifications/cases/catalogs.json`. Falla con `COV-MISSING-ROW`, `COV-STALE-ROW`, `COV-DUPLICATE`, `COV-ROLE`, `COV-NO-REASON`, `COV-HIDDEN-CONTROL` (una construcción ejecutable marcada «no aplicable» en una vista), `COV-HELP` (ayuda exacta sin ficha existente), `COV-RULE` (anclaje inexistente en el corpus) y `COV-EVIDENCE` (prueba inexistente). Cada código tiene un caso negativo en `test/tool/check_syntax_coverage_test.dart`, y otro test contrasta la matriz real con el inventario y el catálogo reales. Conjunto esperado frente a cubierto: 78 formas públicas, 78 cubiertas.

- **Clasificación exhaustiva.** `rustStatementTreatment` decide para cada sentencia un tratamiento explícito: control, ruptura, registro diferido, retorno, llamada, E/S, paso de proceso o `unsupported`. Los constructores de ordinograma y estructograma no tienen una rama `_` que produzca un proceso. `for_each_loop` se dibuja como bucle de preámbulo (cabecera con la primera línea del propio nodo, de modo que cambia con el perfil sin literales sueltos) y una colección vacía conserva el bucle.
- **Salidas y limpiezas (`R10`, `R11`).** La app no decide a qué bucle sale un `Salir` ni qué limpiezas corren: lee `control_exit`, `normal_cleanups` y `cleanup_scope_node_id` de la vista (`ProgramViewControlExit`, `ProgramViewCleanupScope`), validados en la frontera por `rust_program_view_wire_exits.dart` y consultados mediante `RustControlExits`. En el ordinograma, `Salir` es un paso con arista `breakExit` hacia un conector rotulado `exitConnector` («Fin del bucle (línea N)»), y el bucle destino repite ese conector tras su salida normal: es la notación de conectores emparejados y evita trazar una arista que cruzaría columnas vecinas. `Retornar` sigue siendo terminal. `Propagar` añade a su sentencia una arista lateral `propagationExit` hacia un terminal «Propaga el fallo», sin cortar el flujo normal (`SideBlock`). `Diferir` es un paso de preparación con su cuerpo al costado, unido por una arista discontinua `cleanupRegistration` que el flujo no atraviesa. Cada salida anticipada anota «limpiezas: líneas …» en el orden de `control_exit`, y un paso de subproceso «Limpiezas al terminar: líneas …» cierra el ámbito cuyo final es alcanzable, en el orden de `normal_cleanups`; las líneas son las de las sentencias `Diferir`, así que el dibujo nunca evalúa una limpieza. En el estructograma, `Salir` y `Retornar` son celdas de salida con la misma anotación, `Diferir` es un bloque con cabecera que contiene su cuerpo, la sentencia que propaga se anota con «si falla, propaga» y las limpiezas de fin normal son una celda de llamada. El texto sale de `ExitVocabulary` dentro de `diagram_vocabulary.dart`, en ambos idiomas de interfaz. Una selección cuyas ramas no continúan ya no declara salida, de modo que el fin de ámbito tras dos `Retornar` no se dibuja como alcanzable.
- **Respuesta no soportada (`R14`).** `Propagar` dentro de la cabecera de un control (condición, selector, colección o encabezado de bucle) se reporta como no soportado: dibujar su salida obligaría a partir la decisión. El constructor captura `UnsupportedSyntaxView` en su propio borde y devuelve `DiagramProgram.unsupported(kinds)`; el panel muestra qué formas faltan en vez de un diagrama parcial (`diagramUnsupportedSyntax`, es/en). El escenario `control_flow` (`tool/see_app_control_flow.dart`) observa ese resultado y la escena real.
- **Variantes declaradas y genéricos (PG-L).** La fila `value.variant` cubre `variant_unit`, `variant_alternative` y `alternative_field` (no aplicables en ordinograma y estructograma porque una declaración no se ejecuta; estructura exacta; ficha `help.pgl04.variant`), y `generic.parameters` apunta a `help.pgl04.type_parameter`. Un `Segun` sobre una variante declarada no necesita forma propia: los patrones cualificados (`Forma.Circulo(r)`) son las etiquetas del caso y se dibujan completas en las dos notaciones; ninguna forma nueva cae en «no soportado».
- **Pendientes declarados.** Los patrones conservan la etiqueta completa de cada caso y los literales de función tienen una unidad seleccionable con su cuerpo. Cada fila asigna una ficha existente mediante `CoverageCell.help`; la puerta rechaza cualquier extensión pendiente con COV-EXTENSION. El inventario se lee del código fuente del motor porque la API no publica aún un catálogo de formas; cuando exista, el verificador debe leerlo de ahí.

Pruebas: `rust_control_exit_diagram_test.dart` (motor real, es/en: conectores emparejados, bucle interior, ruptura huérfana, cuerpos laterales sin solapamiento, retornos con limpiezas, fin inalcanzable, propagación y estructograma), `rust_syntax_coverage_behavior_test.dart` y `check_syntax_coverage_test.dart`.

### Proyecciones de tareas y estado paginado

La observación de ejecución es un puerto (`ProgramExecutionObserver`) separado del control
(`ProgramExecution`). La composición comparte el mismo `RustExecutionResource` entre el adaptador de
control y el adaptador de observación, así seleccionar y consultar nunca crea una segunda ejecución
ni bombea la agenda. `history_events` entrega ventanas con `task_id` de la cinta completa también
para sentencias y salida ordinarias. `debug_state(event, task_id)` consulta el contexto de una tarea
en un evento retenido mediante una máquina temporal: no mueve el cursor, la punta viva ni la agenda.
El contrato también conserva el rechazo de identidades fuera del horizonte. Los cursores de
`query_page` siguen siendo opacos y ligados por la API a la sesión, revisión, evento, tarea, consulta,
destino y tamaño de página.

La política de lectura es explícita: cada ventana de API admite como máximo 4096 eventos; la caché
de la app retiene como máximo esos mismos 4096 y elimina entradas anteriores al horizonte; la
navegación visual solicita rangos de hasta 96 eventos; las consultas de marcos usan ventanas de 32 y
las de valores páginas de 64. La vista de eventos puede cambiar tarea y marco sin confundir el
desplazamiento de página con el identificador real del marco. Un cursor de valores se solicita solo
cuando se pide la página siguiente; no se lee la colección completa para recortarla después. Las
consultas nunca actualizan el estado de control.

La pestaña `Tareas` es una herramienta de aula: se diseña primero para el teléfono, donde el panel
acompañante deja unos 230 px útiles bajo el editor, y escritorio usa el mismo diseño con más filas
visibles. Todas sus piezas comparten el evento seleccionado, el rango y la tarea.

- **Cabecera fija de una línea:** segmentado «Cronología · Estado · Variables» y un botón de ayuda
  que abre una hoja inferior con la explicación de cada vista. Las leyendas fijas se eliminaron
  porque ocupaban la altura que el teléfono necesita para los datos.
- **Barra de narración:** «Evento N de M» (N es el seleccionado y M el vivo), ‹ y › para moverse
  entre eventos sin tocar la ejecución, «En vivo» para volver al último y una frase en lenguaje
  natural del evento elegido («T1 · Produce espera lugar en el canal 1»). La frase sale de un único
  mapeo, tipo de evento → recurso localizado (`task_event_sentence.dart`), así que las tres vistas
  hablan igual. Moverse con ‹ y › o tocar una fila resalta la sentencia en el editor mediante
  `revealSource`, como el ordinograma. Cuando el panel mide menos de 360 pt (el modo
  «Acompañar» del teléfono le deja unos 190), la barra pasa a una sola fila («11/18 · frase») y la
  cronología oculta la leyenda de nombres. Así la fila seleccionada sigue visible y no hay
  desbordamiento; `task_projections_tab_view_test.dart` lo comprueba a 375×230.
- **Cronología:** línea de tiempo vertical, con una fila de alto fijo por evento y una columna
  estrecha por tarea. El eje es vertical porque el desplazamiento natural del teléfono es vertical;
  el lienzo horizontal anterior obligaba a desplazarse de costado en cada paso. Cuando cambia el
  evento seleccionado, la lista se desplaza con animación hasta dejar su fila centrada (sin
  animación si el sistema pide reducir el movimiento). La creación se dibuja como una línea continua
  hacia la columna hija. La espera es punteada y llega solo a su objetivo real: la tarea esperada
  (`task`) o las hijas de ese ámbito (`join`, resueltas con `scope` de `task_spawned`). Las esperas de
  canal, `select` o efecto se rotulan sin cruzar columnas, porque su objetivo no es una tarea. Las
  filas de sentencia se atenúan y las de tarea o canal se destacan. El orden es el índice lógico, no
  tiempo físico. «Ver eventos anteriores» amplía el rango hacia atrás.
- **Estado:** una tarjeta por tarea, con sangría según quién la lanzó. Proyecta el estado **en el
  evento seleccionado**: los eventos posteriores no se aplican y los contextos vivos del motor solo
  corrigen estados cuando el seleccionado es el vivo. Antes se mezclaba la caché completa con los
  contextos vivos, y retroceder mostraba el presente. Cada tarjeta explica su estado en una línea
  («Esperando su turno», «Esperando a sus tareas: faltan 1 de 2») y ofrece acciones explícitas: «Ver
  variables» e «Ir a su creación». Si el horizonte perdió la creación, la vista avisa que el árbol es
  parcial.
- **Variables:** chips de tarea («Tarea del evento» o una concreta), migas de pan de la pila de
  llamadas y una tabla nombre/valor, todo en un único desplazamiento. Elegir una tarea la **fija**:
  al avanzar se sigue inspeccionando esa tarea y no la del evento, siempre que ya exista en el
  evento elegido. Si todavía no existe, se usa la del evento. «Tarea del evento» quita la fijación.
  Los eventos de canal advierten que la cola no está expuesta.

**Identidad y color.** Una tarea se nombra `T<n>` más el subproceso que ejecuta, tomado del primer
evento `call` atribuido a ella (`T1 · Produce`); la raíz se llama «principal». No se añadió una paleta
categórica por tarea al sistema de diseño: el color expresa **estado**, con los semánticos
existentes (información = ejecutando, advertencia = esperando, éxito = terminada, error = fallo), y
siempre va acompañado de ícono y texto.

**Capas.** `TaskEventClassifier` (motor) es el único lugar que conoce las cadenas del cable
(`task_suspended`, `channel_send`, `present`…) y las traduce a `TaskEventKind` y `TaskWaitCause`
(modelo). `TaskFlowProjection` produce filas y columnas sin geometría, y la presentación calcula los
píxeles a partir del ancho disponible. `TaskStructureProjection` recibe el evento seleccionado y el
vivo. La regla de fijación de tarea vive en aplicación (`execution_history_task_pin.dart`).

| Dato de ejecución | Cronología | Estado | Variables | Tabla de trazas | Ayuda | Evidencia y contrato |
|---|---|---|---|---|---|---|
| `task_spawned` | Fila del emisor con línea continua a la hija | Crea la tarjeta hija bajo su progenitor | Tarea emisora | No aplica: las filas se abren por cambio de `focusRevision`, no por todo evento de agenda | No aplica: es estado de ejecución de sintaxis existente, no una forma gramatical nueva | Proyecciones; `history_events.rs`; `API.EXECUTE` R8/C13 |
| `task_ready`, `task_resumed`, `task_suspended`, `task_completed`, `task_cancel_requested` | Fila en la columna de la tarea afectada (`data.task`); la espera enlaza su objetivo real | Estado, explicación y resultado en el evento elegido | Tarea atribuida | No aplica: no cada transición cambia la fila de sentencia enfocada | No aplica por el mismo motivo curricular | Proyecciones; cubit; `API.EXECUTE` R7/R8 |
| `scope_joined` | Fila «continúa: sus tareas terminaron» | Unión adscrita a la tarea emisora | Resultado | No aplica: una unión no agrega una fila sintáctica | No aplica: no agrega una construcción al lenguaje | Proyección de estructura; `API.EXECUTE` R8 |
| `channel_created`, `channel_sent`, `channel_received`, `channel_closed` | Fila con número de canal; recibir sin valor se narra como canal cerrado | Sin tarjeta artificial | Aviso de cola no disponible | No aplica: los eventos de canal no son filas de sentencia | No aplica: el aviso documenta el límite del dato expuesto | Decodificador de eventos; `API.EXECUTE` R8 |
| Evento ordinario (`statement_entered`, `call`, `output`, entre otros) | Fila atenuada asignada por `task_id`; `call` da nombre a la tarea | Línea actual de la tarea | Valores del marco | Se conserva la fila por foco de sentencia, sin duplicarla por selección histórica | No aplica: la ayuda existente sigue resolviendo la fuente de sintaxis | `history_events.rs`, `debug_control.rs`; `API.EXECUTE` R7/R8 |

Pruebas de la app: `test/engine/execution/task_flow_projection_test.dart` cubre columnas, enlaces de
creación, espera por tarea, espera por unión limitada a su ámbito, esperas de canal sin enlace, nombres
por `call`, recorte de rango y entrada vacía. `task_structure_projection_test.dart` cubre el estado en
un evento pasado frente al vivo, el progreso de la unión, el objetivo de espera, el árbol anidado, el
horizonte y las terminaciones. `test/application/execution/execution_history_cubit_test.dart` cubre la
selección independiente del evento vivo, la tarea fijada, la paginación, los errores y los límites
4096/4097. `test/presentation/execution/task_projections_tab_view_test.dart` comprueba, en 375×520,
que la cronología sigue el último evento, que retroceder narra la espera en la unión y la refleja en
Estado, y que Variables muestra chips y valores. `task_state_cards_view_test.dart` comprueba los
resultados de error recuperable y de cancelación. Las pruebas API `history_events.rs` y
`debug_control.rs` comprueban la atribución histórica y que consultar un evento anterior no mueve la
ejecución. Los casos de conformance C13/C14 verifican el contrato de atribución e inspección en
`API.EXECUTE`.

Medición intermedia local del 2026-11-03, fuentes modificadas sobre 04b4153868cc3ab63f90c2b0e1445e4adb8832bf:
ios-arm64 Release 5.989.360 bytes, SHA-256
cd90dbf8d48abf3d7673bfa65b49c55188c1b4435c55eae31ce597c42c6a51e4,
con símbolos separados y UUID coincidente. El Wasm Brotli Q11/lgwin22 mide 842.655 bytes,
SHA-256 633df31c149568458b1266a94a6a9ee9606463eab360d6513db5b501cdecbf31.
Ambos caben en los presupuestos vigentes de 8 MiB y 900 KiB. Se modificaron después la entrega
de efectos concurrentes y la reutilización de entropía; falta recapturar los artefactos finales.
El campo de argumentos usa
un ancho semántico propio de componente para conservar espacio legible sin literales de diseño.

La fila de receptor se obtiene de `receptor` del marco público; su nombre procede de `thisObject`
del vocabulario del perfil, sin lexemas propios en Dart. Los marcos sin receptor conservan sus variables.

Los argumentos son una preferencia local por documento. Se guardan en su cabecera y
se conservan al adoptar contenido remoto del mismo documento; no se amplía el protocolo del backend.
La fila de configuración de ejecución solo aloja el campo de argumentos y el botón de reproducción; una clave retirada en un front matter antiguo se ignora porque el lector toma solo las claves conocidas.

## Ampliación numérica y de colecciones

La proyección transporta collection_operation desde el motor. Las llamadas nuevas conservan el nodo de llamada para diagramas y traza; la mezcla no introduce sentencias visibles. La exportación señala collection:<identidad> sin equivalente mientras no pueda conservar alias, atomicidad y fallos. Las seis trascendentes nuevas quedan sin equivalente en Rust/Python porque la libm del destino no garantiza el redondeo requerido.

### Salida de error en la consola

`RustBatch` lee `error_ranges` (tramos `[inicio, fin)` en bytes UTF-8 de la salida combinada) y `exit_code` de cada
respuesta del motor. `RustExecutionEventEffects` lleva el desplazamiento acumulado de los eventos `output` y marca como
`OutputLineKind.programError` los que caen dentro de un tramo; `output_panel.dart` los pinta con el color de severidad
`error`. Cada `EscribirError` produce un evento completo dentro de un tramo, así que un evento nunca queda a medias. Límites: el código de salida se
lee pero la app no lo muestra, el estilo propio no existe en la extensión web ni en la frontera Wasm, y no hay
proyección específica de las operaciones nuevas más allá de la que ya da el catálogo exportado.

### Aceptación de la biblioteca de propósito general

`integration_test/general_purpose_acceptance_test.dart` ejecuta con el motor nativo real el programa de operaciones puras
(texto, números, formato, colecciones y calendario) y exige las once líneas derivadas de las reglas. Se ejecuta con
`flutter test integration_test/general_purpose_acceptance_test.dart -d macos` y, en simulador,
`flutter test --no-pub --device-id <UDID> integration_test/general_purpose_acceptance_test.dart`. Pasó en macOS (debug) y
en el simulador iPhone 18 Pro (iOS 27.0). No cubre archivos, entorno ni consola con efectos físicos, y Windows no se
ejecutó.

## Exportación de la biblioteca clásica

El emisor Python traduce `Azar(n)` a `random.randrange(n)`, `Aleatorio(a, b)` a `random.randint(a, b)`, `AzarReal()` a
`random.random()` y `Concatenar(a, b)` a `(a + b)`, e importa `random` cuando aparece cualquiera de las tres funciones de
azar. El emisor Rust no tiene generador sin dependencias: conserva un valor fijo del tipo correcto (el inicio del
intervalo en `Aleatorio`) como antes hacía con `azar()`. La vista del programa ya no trae el atributo `mutable`.
