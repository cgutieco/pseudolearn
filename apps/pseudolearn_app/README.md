# pseudolearn_app

Fuente de verdad técnica de este paquete. Aquí vive el *por qué* de cada decisión, para que el código no necesite
comentarios que lo expliquen. Un cambio de arquitectura o de decisión de diseño se documenta aquí en el mismo cambio que
lo introduce.

Las reglas transversales del monorepo están en el `AGENTS.md` de la raíz. Las reglas que los verificadores ejecutan
están en `architecture.yaml`, junto a este archivo. La arquitectura del motor del lenguaje está en
`packages/pseudolearn_core/README.md` y no se repite aquí: este documento describe **dónde y cómo la app se acopla a ese
motor y cómo se construye su experiencia interactiva**.

**Estado:** Arquitectura hexagonal implementada; superficies de biblioteca, documento (con cuatro pestañas sincronizadas
por `NodeId`), introducción con laboratorio en vivo, base de conocimiento y ajustes operativas; tres notaciones de
diagrama (ordinograma, estructograma y diagrama de clases) trazadas determinísticamente; verificación mecánica y suite
de pruebas al 100 % en verde.

---

## 1. Qué es y qué no es

### 1.1 Propósito y problema que resuelve

`pseudolearn_app` es la aplicación cliente interactiva en Flutter del monorepo PseudoLearn. Proporciona un entorno
integrado de aprendizaje que incluye edición asistida de pseudocódigo, ejecución didáctica paso a paso, visualización
multidiagrama sincrónica (ordinograma, estructograma de Nassi-Shneiderman y diagrama de clases UML), tabla interactiva
de prueba de escritorio con inspección de aliasing de objetos, traducción de código a lenguajes industriales (Python y
Rust), base de conocimiento pedagógica versionada con comprobación observable de ejercicios y almacenamiento local
estructurado.

Consume `pseudolearn_core` como paquete de Dart puro por ruta relativa dentro del monorepo. **No aporta ninguna lógica
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

- **Capa institucional y gestión docente:** No existen entidades de instituciones, aulas, códigos de acceso, roles
  administrativos, inscripciones, tareas asignadas, fechas límite, calificaciones, rúbricas ni seguimiento agregado de
  grupos. La aplicación modela estrictamente un espacio personal e individual.
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
4. **Estudio autónomo en la base de conocimiento:** Navegación por tres tramos curriculares estructurados en 15 módulos
   con especificaciones proyectadas, actividades de predicción y ejercicios verificables.
5. **Comprobación pedagógica de soluciones:** Validación de programas contra casos de prueba visibles y ocultos mediante
   normalización numérica y aserciones sobre el AST sin juicio punitivo.
6. **Biblioteca personal:** Gestión de documentos locales con política canónica de nombres, duplicación y exportación de
   código equivalente.

### 1.5 Pendientes técnicos declarados

| Pendiente                                                      | De quién depende                                                                                                                             | Estado actual                                                                                          |
|:---------------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------|
| Tramos de comentario para el resaltado del editor              | Del núcleo `pseudolearn_core` (exposición de tokens de comentario en el lexer)                                                               | Abierto                                                                                                |
| Adaptador remoto de Supabase                                   | Definición de credenciales de red y esquema de sincronización remota                                                                         | Resuelto (sincronización bidireccional y outbox en SQLite, ver decisiones de diseño de sincronización) |
| Vocabulario localizado de receptor de objeto en tabla de traza | Parametrización en `watch_row_projection.dart` para perfiles no hispanos                                                                     | Abierto                                                                                                |
| Selector del eje de rigor del perfil (estricto/flexible)       | `ProfileCatalog.toLanguageProfile` instancia siempre la variante `.flexible()` del núcleo; falta control de UI y persistencia por documento  | Abierto                                                                                                |
| Andamiaje de la plataforma web                                 | Creación de `web/` y de un adaptador de `TextEntryModality` para navegador; hasta entonces la barra de teclas no se verifica ahí (ver §4.33) | Abierto                                                                                                |

---

## 2. Guía operativa y ciclo de vida

### 2.1 Requisitos previos y plataformas objetivo

- **SDKs:** Flutter SDK `>= 3.24.0`, Dart SDK `>= 3.5.0`.
- **Plataformas objetivo primarias:** macOS 13+ (Apple Silicon y x86_64), iOS 16+ (iPhone y iPad).
- **Plataformas secundarias:** Linux (GTK), Windows 10/11, Web (WASM). Son objetivo declarado, **no andamiaje
  existente**: el proyecto solo contiene las carpetas `ios/` y `macos/`. Toda afirmación sobre el comportamiento en
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

# Verificación de fuentes tipográficas empaquetadas
dart run tool/check_design_system.dart
```

### 2.3 Ejecución en desarrollo

```bash
# Ejecución en escritorio macOS, con credenciales de Supabase y Google
flutter run -d macos --dart-define-from-file=dart_define.local.json

# Ejecución en simulador iOS
flutter run -d "iPhone 15" --dart-define-from-file=dart_define.local.json

# Ejecución con inspección y observador de Dart
flutter run -d macos --observe --dart-define-from-file=dart_define.local.json
```

### 2.4 Compilación y build

```bash
# Artefacto de producción para macOS (.app empaquetable en DMG)
flutter build macos --release
# Ruta de salida: build/macos/Build/Products/Release/pseudolearn_app.app

# Artefacto de producción para iOS (paquete .ipa sin firma para staging)
flutter build ipa --no-codesign
# Ruta de salida: build/ios/archive/Runner.xcarchive
```

### 2.5 Pruebas y verificación inmediata

La verificación de integridad se ejecuta sin dependencias externas:

```bash
# 1. Análisis estático estricto
flutter analyze --fatal-infos --fatal-warnings

# 2. Verificación de límites métricos (architecture.yaml)
dart run tool/check_limits.dart

# 3. Verificación de invariantes de la base de conocimiento
dart run tool/check_content.dart

# 4. Verificación de integridad del sistema de diseño
dart run tool/check_design_system.dart

# 5. Suite completa de tests unitarios, de arquitectura y widgets
flutter test
```

### 2.6 Despliegue y distribución

- **Distribución en macOS:** Binario firmado y notarizado vía script de release o DMG directo.
- **Distribución en iOS:** Archivo `.ipa` subido a TestFlight mediante `xcrun altool` o Fastlane.
- **Checklist de liberación:**
    - [ ] `flutter test` y todos los scripts de `tool/` al 100 % en verde.
    - [ ] Versión y build sincronizados en `pubspec.yaml`.
    - [ ] Documentación técnica (`README.md`) y contratos de `architecture.yaml` actualizados.

### 2.7 Regeneración de los activos de marca

La pantalla de lanzamiento de iOS no es un activo dibujado a mano: se rasteriza desde la misma geometría que la app
pinta
en su primer fotograma, y con ella se escriben los dos `Contents.json` del catálogo. Se ejecuta cuando cambia la marca,
no
en cada compilación:

```bash
# Escribe LaunchImage.imageset (claro y oscuro, 1x/2x/3x) y LaunchBackground.colorset
flutter test tool/generate_launch_images.dart
```

El ícono de aplicación **no** sale de aquí: lo genera Xcode desde `app-icon.svg`, que produce el motor de marca en
`packages/pseudolearn_brand/out/`, y el procedimiento de cada plataforma está en el `README.md` de ese paquete.

### 2.8 Regeneración de las capturas de producto de la web

La landing (`apps/fe-pseudolearn`) no dibuja una reconstrucción del editor: muestra la app real. Las ocho imágenes las
rasteriza esta herramienta montando la composición completa —`CubitScope`, enrutador y armazón—, cargando el programa
correspondiente (`assets/knowledge/examples/guided_demo_es.pseudo` con `SyntaxProfileId.classicSpanish` y
`UiLanguageId.spanish`
para español, o `assets/knowledge/examples/guided_demo_en.pseudo` con `SyntaxProfileId.english` y `UiLanguageId.english`
para inglés), ejecutándolo hasta el final, abriendo el panel acompañante y encuadrando el ordinograma. Se ejecuta cuando
cambie algo que la imagen enseñe, no en cada compilación:

```bash
# Escribe las ocho capturas en apps/fe-pseudolearn/src/assets/product/{es,en}/
flutter test tool/generate_product_shot.dart
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
│ Adaptador pseudolearn_core│ Archivos .pseudo, SQLite, activos bundled  │
├───────────────────────────┴────────────────────────────────────────────┤
│ 1. ports          Interfaces requeridas hacia el exterior              │
├────────────────────────────────────────────────────────────────────────┤
│ 0. model          Estructuras de datos inmutables (el centro)          │
└────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Catálogo de carpetas, responsabilidades e invariantes

| Capa / Directorio        | Responsabilidad única                                                                                                                                                                                                                                                                                              | Puede importar (`may_import`)                                             | Prohibido importar (`forbidden_imports`)                                                                                                       |
|:-------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------|
| `domain/model/`          | Entidades y valores de datos inmutables de la aplicación                                                                                                                                                                                                                                                           | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, `pseudolearn_core`, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/model/account/`  | Entidades inmutables de cuenta, sesión, perfiles y resultado tipado de autenticación (`AccountSession`, `AccountProfile`, `AuthMethod`, `AuthOutcome`)                                                                                                                                                             | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, `pseudolearn_core`, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/model/sync/`     | Modelos inmutables de reconciliación, instantáneas, resultados y función pura de resolución trilateral (`DocumentSnapshot`, `ReconciliationOutcome`, `reconcileDocument`, `SyncStatus`, `OutboxEntry`)                                                                                                             | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, `pseudolearn_core`, `bloc`, `dart:io`, `dart:ui`, `sqflite`                                                 |
| `domain/model/progress/` | Modelos inmutables de avance curricular y marcas temporales de primer logro (`ProgressEntry`)                                                                                                                                                                                                                      | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, `pseudolearn_core`, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/model/editor/`   | Cursor propio (`CaretRange`), tecla del editor (`EditorKey`) y resultado de una edición (`SourceEdit`). No usa `TextSelection`: es de Flutter y el modelo no lo importa                                                                                                                                            | *Ninguna* (datos puros)                                                   | Todas las demás capas, `flutter/`, `pseudolearn_core`, `bloc`, `dart:io`, `dart:ui`                                                            |
| `domain/ports/`          | Contratos abstractos e interfaces requeridas                                                                                                                                                                                                                                                                       | `model`                                                                   | `engine`, `data`, `application`, `presentation`, `flutter/`, `pseudolearn_core`, `bloc`, `dart:io`, `dart:ui`                                  |
| `engine/`                | Adaptación y traducción entre `pseudolearn_core` y `domain`                                                                                                                                                                                                                                                        | `model`, `ports`, `pseudolearn_core`                                      | `data`, `application`, `presentation`, `flutter/`, `dart:io`, `dart:ui`, `RegExp`                                                              |
| `engine/editing/`        | Cálculo puro de la edición en el cursor (`LexiconSourceEditor`) y derivación de las teclas desde el léxico del perfil (`ProfileKeySource`)                                                                                                                                                                         | `model`, `ports`, `pseudolearn_core`                                      | `data`, `application`, `presentation`, `flutter/`, `dart:io`, `dart:ui`, `RegExp`                                                              |
| `data/`                  | Persistencia en disco, SQLite y lectura de activos                                                                                                                                                                                                                                                                 | `model`, `ports`, `dart:io`, `sqflite`, `package:markdown`                | `engine`, `application`, `presentation`, `pseudolearn_core`, `flutter/material.dart`, `flutter/widgets.dart`, `bloc`                           |
| `data/auth/`             | Adaptadores de autenticación nativa de plataforma, cliente Dart puro `supabase`, almacenamiento seguro de token y forma del enlace de retorno (`SupabaseAuthGateway`, `NativeCredentialSource`, `SessionStorage`, `authCallbackUrl`)                                                                               | `domain/model`, `domain/ports`, `package:supabase`, almacenamiento seguro | `engine`, `application`, `presentation`, `pseudolearn_core`, `flutter/material.dart`, `flutter/widgets.dart`, `flutter/cupertino.dart`, `bloc` |
| `data/platform/`         | Adaptadores de servicios del sistema operativo: reloj, generación de identificadores, sondeo de conectividad, recepción de enlaces entrantes y modalidad de entrada de texto (`SystemClock`, `RandomIdentifierGenerator`, `ConnectivityMonitorAdapter`, `AppLinksIncomingLinkSource`, `PlatformTextEntryModality`) | `domain/model`, `domain/ports`, `dart:io`, `package:app_links`            | `engine`, `application`, `presentation`, `pseudolearn_core`, `flutter/material.dart`, `flutter/widgets.dart`, `flutter/cupertino.dart`, `bloc` |
| `data/sync/`             | Persistencia de outbox en SQLite, almacenes remotos en Supabase y orquestación de drenado con orden pull-antes-que-push (`SqliteSyncQueue`, `SupabaseDocumentStore`, `SyncDrainer`)                                                                                                                                | `domain/model`, `domain/ports`, `sqflite`, `package:supabase`             | `engine`, `application`, `presentation`, `pseudolearn_core`, `flutter/material.dart`, `flutter/widgets.dart`, `flutter/cupertino.dart`, `bloc` |
| `application/`           | Casos de uso, orquestación y cubits de estado inmutable                                                                                                                                                                                                                                                            | `model`, `ports`, `package:bloc`, `package:equatable`                     | `engine`, `data`, `presentation`, `flutter/`, `pseudolearn_core`, `go_router`, `sqflite`, `dart:io`, `dart:ui`, `BuildContext`, `RegExp`       |
| `presentation/`          | Widgets, CustomPainters, renderizado de lienzo y temas                                                                                                                                                                                                                                                             | `model`, `application`, `flutter/`, `go_router`, `flutter_bloc`           | `ports`, `engine`, `data`, `pseudolearn_core`, `sqflite`, `dart:io`, constructores adaptativos OS, métodos de colección derivados              |
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
                                            [Engine: CoreProgramAnalyzer]
                                                       │
                                      (Invoca Lexer/Parser/Resolver/Types)
                                                       ▼
                                            [Package: pseudolearn_core]
                                                       │
                                         (Retorna AST y Diagnósticos)
                                                       ▼
                                            [Engine: CoreProgramAnalyzer]
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

---

## 4. Decisiones de diseño y fundamentos técnicos

### 4.1 Manejo de estado: `bloc` en su forma de cubit

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
- **Elección:** `presentation/` tiene vetado importar `pseudolearn_core` y `domain/ports/`. El modelo de la aplicación
  declara sus propios tipos de datos inmutables (`AppDiagnostic`, `SourceRange`, `ProgramNodeId`, `ExecutionStep`,
  `WatchRow`, `DiagramScene`). La capa `engine/` proyecta limpiamente los tipos del núcleo hacia estos modelos sin
  alterar severidades ni mensajes.
- **Alternativas descartadas y por qué:**
    - *Consumo directo de tipos del núcleo en widgets:* Descartado porque un cambio en las estructuras internas del
      compilador forzaría refactorizaciones en cascada en la interfaz.
    - *Paquete intermedio `pseudolearn_ui_model`:* Descartado por añadir sobrecarga de mantenimiento de paquetes en un
      monorepo donde la aplicación es el único consumidor de estos tipos.

### 4.3 Acoplamiento al motor (`engine`): etapa única de traducción y orquestación

- **Problema:** El núcleo expone etapas discretas (Lexer, Parser, NameResolver, TypeChecker, Interpreter). Si varias
  pantallas orquestan el pipeline por su cuenta, surgen inconsistencias en el orden de análisis.
- **Elección:** La carpeta `engine/` centraliza de forma exclusiva el acoplamiento a `pseudolearn_core`.
  `CoreProgramAnalyzer` compone las etapas sintácticas y semánticas en orden riguroso. `AnalysisCache` garantiza que las
  cuatro superficies consuman el resultado del mismo árbol AST.
- **Alternativas descartadas y por qué:**
    - *Orquestación distribuida en cubits:* Descartado porque violaría la regla de que `application/` no conoce
      `pseudolearn_core`.
    - *Adaptador de flujo asíncrono del núcleo:* Descartado para mantener síncrona y determinista la ejecución de pasos
      simples.

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
  `buildLocalDependencies` instancia los adaptadores concretos. No se permite ningún condicional (`if`, `switch`,
  ternario) en `composition/`. Los tests inyectan fakes directamente en el constructor de `AppDependencies`. Los ajustes
  dinámicos (perfil de sintaxis, idioma de interfaz) se pasan como parámetros en los métodos de los puertos.
- **Alternativas descartadas y por qué:**
    - *`get_it`:* Descartado por permitir acceso global desde métodos `build`.
    - *`injectable` / `build_runner`:* Descartado por introducir generación de código para una raíz que se resuelve
      limpiamente a mano.

### 4.7 Organización por capa técnica y por funcionalidad

- **Problema:** Organizar primero por funcionalidad (`features/`) diluye la frontera de verificación de capas
  arquitectónicas y complica el enforcement mecánico de imports.
- **Elección:** La raíz de `lib/` se organiza primero por capa técnica (`domain/`, `engine/`, `data/`, `application/`,
  `presentation/`, `composition/`) y en el segundo nivel por área funcional (`editor/`, `diagram/`, `knowledge/`,
  `library/`, `settings/`). Esto permite validar reglas de dependencia mediante prefijos de ruta simples en los tests de
  arquitectura.
- **Alternativas descartadas y por qué:**
    - *Package-by-feature en primer nivel:* Descartado porque exige reglas complejas de visibilidad entre
      funcionalidades
      y debilita la verificación hexagonal.

### 4.8 Ejecución paso a paso didáctica: micro-lotes en el hilo de interfaz (`StepBatchRunner`)

- **Problema:** El evaluador del núcleo avanza a nivel de micro-pasos de máquina (evaluar expresión, resolver operando).
  Ejecutar un bucle largo de corrido bloquearía la interfaz o saturaría el renderizado.
- **Elección:** `StepBatchRunner` ejecuta lotes acotados de micro-pasos en el hilo principal cediendo periódicamente el
  control. La máquina se gobierna por cuatro ritmos unificados bajo `StepSettlement`:
    - `nextStatement`: para al cambiar de sentencia observable (paso didáctico).
    - `overBlock`: para cuando la profundidad de bloque es menor o igual a la inicial y no es el nodo saltado.
    - `outOfBlock`: para cuando la profundidad desciende de la inicial.
    - `toEnd`: ejecuta continuo hasta terminar, fallar o alcanzar el tope de seguridad (10 000 micro-pasos).

  Las solicitudes de entrada del usuario detienen el lote y emiten un estado de espera; al recibir el dato, la ejecución
  continúa con la misma condición de parada.
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

### 4.10 Foco de ejecución unificado: un identificador de nodo en cuatro superficies

- **Problema:** Las cuatro superficies de trabajo (editor, diagramas, tabla de traza y código equivalente) necesitan
  sincronizarse con la instrucción en curso sin recalcular cuatro análisis independientes.
- **Elección:** `ExecutionState` mantiene una única instancia de `ExecutionFocus` construida sobre `ProgramNodeId`:
    - En el **editor**, resalta la línea física en el canalón y el tramo de texto correspondiente.
    - En el **ordinograma**, resalta el símbolo activo y la arista correspondiente a la rama evaluada (
      `ExecutionBranch`).
    - En el **estructograma**, resalta la celda activa.
    - En el **diagrama de clases**, resalta la fila del método o constructor en ejecución.
    - En la **tabla de traza**, abre una fila en el paso actual mostrando las variables modificadas y el receptor
      `Este`.
    - En **código equivalente**, resalta las líneas generadas asociadas al nodo de origen.

  `AnalysisCache` almacena el último análisis en memoria para que todas las vistas compartan los mismos identificadores
  de nodo durante la sesión.
- **Alternativas descartadas y por qué:**
    - *Sincronización mediante eventos en `presentation/` (BlocListener cruzados):* Descartado porque introduce
      orquestación en la interfaz y produce desincronizaciones de estado.

### 4.11 Emisión de código equivalente (Python y Rust) para subprogramas, POO y funciones predefinidas

- **Problema:** Enseñar programación estructurada y orientada a objetos requiere contrastar el pseudocódigo con
  implementaciones en lenguajes industriales sin depender de herramientas externas.
- **Elección:** En `engine/export/`, `PythonCodeEmitter` y `RustCodeEmitter` traducen el AST del programa. Cada emisor
  se
  descompone en emisores especializados de sentencias y expresiones:
    - **Python:** Clases con `def __init__(self, ...)`, métodos con parámetro `self`, invocaciones a superclase con
      `super()`, y mapeo de funciones predefinidas (`math.sqrt`, `len`, `str`, `random.random`) con imports
      condicionales.
    - **Rust:** Estructuras `struct` con `#[derive(Default, Clone)]`, composición de base para herencia, bloques `impl`
      con métodos `&mut self`, constructor estático `pub fn new() -> Self`, y tipado estricto con funciones
      idiomáticas (
      `parse::<i64>()`, `.sqrt()`, `format!`).
- **La primera línea del código generado es la firma de la marca** (`targetCodeHeader`), en el comentario de línea que
  cada destino usa. Es la única parte de la marca que sale de la aplicación: el código equivalente se pega en un
  trabajo, en un chat o en un repositorio, y va firmado. La firma tiene un solo dueño y no una copia por emisor, porque
  dos destinos que la escriben cada uno por su cuenta acaban firmando distinto.
- **Alternativas descartadas y por qué:**
    - *Emisión monolítica en un único archivo:* Descartada para cumplir el límite de 250 líneas por archivo enforceado
      por
      `architecture.yaml`.

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
5. **Capas de Apilamiento (Z-Index):**
    - `canvas` (0), `content` (1), `sticky/header` (10), `overlay/dropdown` (20), `modal/dialog` (30), `tooltip/toast`
      (40).

### 4.13 Especificación de pantallas y navegación

- **Biblioteca (`LibraryPage`):** Gestión de documentos personales, filtrado por búsqueda de texto, creación con nombres
  sugeridos mediante diálogo modal y eliminación/renombrado seguro.
- **Documento (`DocumentPage`) · Armazón de cuatro pestañas:**
    - Cabecera con título, perfil de sintaxis y estado de sincronización.
    - Franja plegable de ejercicio (`ExerciseStrip`) si el documento procede de la base de conocimiento.
    - Cuatro pestañas conmutables: Editor (`EditorPage`), Diagramas (`FlowchartTabView`), Tabla de prueba de
      escritorio (`TraceTablePage`) y
      Código equivalente (`ExportPage`).
    - Pie de ejecución interactivo con control de avance didáctico en cuatro ritmos.
    - Disposición acompañante (`CompanionLayout`): muestra el editor junto al diagrama o tabla en modo vertical (
      `below`, 3:2) en `compact`/`medium`, y horizontal (`beside`, 1:1) en `expanded`.
- **Introducción interactiva (`OnboardingPage`):** Flujo de cuatro pasos (Bienvenida, Laboratorio en vivo de solo
  lectura con motor de
  diagramas y traza real, Métricas vivas de la Base de conocimiento y Cierre con doble salida a biblioteca o ruta de
  aprendizaje). El paso de bienvenida abre con el símbolo de la marca sobre el título que dice el nombre (§4.35).
- **Base de conocimiento (`KnowledgePage`) y Detalle (`ModuleDetailView`, `SpecificationDetailView`):** Tres secciones
  fijas (Ruta de aprendizaje, Especificación
  publicada, Banco de ejercicios). Vista de módulo estructurada en sus siete partes canónicas y vista de especificación
  con
  banner de retorno contextual.
- **Ajustes (`SettingsOverviewPage`):** Armazón con medida `wide` y distribución en dos columnas en clase `expanded`.
  Subpantallas de
  Idioma, Tema, Diagramas y Contacto integradas con botón de retroceso accesible en la cabecera. El pie
  (`VersionFooter`)
  cierra con el lockup horizontal sobre la línea de versión, que ya no repite el nombre del producto porque lo dice el
  lockup. La hoja de Contacto lo lleva como membrete del documento.
- **Panel de progreso (`DashboardPage` / `DashboardView`):** Cuarto destino de navegación (`/progreso`). Armazón
  `AppPage` con medida `wide` y distribución adaptable (dos columnas en clase `expanded`, columna única en `compact`/
  `medium`). Operativo al 100 % con datos locales sin requerir sesión iniciada. Presenta nueve tarjetas alimentadas
  exclusivamente por proyecciones desacopladas de `application/dashboard/` —biblioteca, ruta de aprendizaje, siguiente
  paso, ejercicios, conceptos ejercitados (derivados sobre el AST mediante `ProgramConstructReader`), cobertura de la
  especificación, línea de actividad semanal (ventana fija de 8 semanas), algoritmos creados en el tiempo y salud de
  sincronización—.
- **Cuenta (`AccountPage` / `AccountView`):** Subpantalla de Ajustes (`/ajustes/cuenta`) con armazón estándar y botón de
  retroceso en cabecera. Sin sesión iniciada, presenta explicación contextual de sincronización y botones de acceso
  (`SignInOptions`) priorizando Apple con la variante de marca `brandApple` (directriz 4.8 de App Store), Google y
  enlace por correo sin contraseña. Con sesión iniciada, muestra el avatar del usuario (`AccountAvatar`: fotografía
  remota del proveedor cuando la sesión la aporta, monograma de iniciales deterministas sobre fondo de acento cuando el
  nombre o la dirección empiezan por letra, y glifo neutro cuando ninguno lo hace), identidad con aclaración explícita
  cuando la dirección es un reenvío privado de Apple, estado reactivo de sincronización, acción manual "Sincronizar
  ahora", listado de dispositivos vinculados con etiqueta de sistema editable y las tres acciones de sesión
  (`SessionActions`) segregadas por jerarquía visual («Cerrar sesión», «Cerrar sesión y borrar datos de este
  dispositivo» tras confirmación modal, y «Eliminar cuenta» con diálogo destructivo de confirmación que invoca la purga
  integral en servidor mediante `RemoteDocumentStore.deleteAccount()` y la eliminación de documentos locales en
  cumplimiento de la directriz 5.1.1 (v) de App Store; la revocación de tokens de Apple Sign-In ante el endpoint REST
  oficial se delega al backend/Edge Functions para resguardar la clave privada de desarrollador fuera del cliente).
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
      suaves (*soft-wrap*), y desplazamiento horizontal independiente. Aísla completamente su `InputDecoration` con
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
    - `StatusBanner`: Avisos de estado de ejecución (éxito, aviso, límite de pasos) descartables mediante acción
      explícita.
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

### 4.18 Base de conocimiento: contenido versionado, manifiesto v2, módulos canónicos y especificaciones proyectadas

- **Problema:** Mantener documentación educativa, especificaciones de sintaxis y ejercicios redactados como código Dart
  dificulta su traducción, versionado y paridad entre idiomas.
- **Elección:** El material pedagógico reside como activos Markdown y JSON estructurados bajo `assets/knowledge/` con un
  `manifest_<lang>.json` versionado (v2):
    - **Tres tramos curriculares y quince módulos canónicos:** Tramo A (Fundamentos: A1–A5), Tramo B (Imperativo: B1–B5)
      y
      Tramo C (Orientación a Objetos: C1–C5).
    - **Estructura obligatoria de siete partes fijas:** Cada módulo declara secuencialmente: 1. `question`, 2.
      `machineModel`, 3. `development`, 4. `prediction`, 5. `commonErrors`, 6. `specificationAnchors`, 7. `exercises`.
    - **Especificaciones proyectadas mediante marcadores:** Los documentos normativos de especificación de sintaxis
      imperativa (`esp-i-*`) y de orientación a objetos (`esp-o-*`) contienen texto estático enlazado a marcadores del
      motor:
        - Marcadores de motor: `{{lexema:<token>}}`, `{{tabla:<id>}}`, `{{firma:<builtin>}}`, `{{diagnostico:<code>}}`.
          Se resuelven en `engine/knowledge/` contra el léxico del perfil activo.
        - Marcadores de contenido: `{{ejemplo:<id>}}`, `{{figura:<id>}}`, `{{diagrama:<id>#<notacion>}}`. Se resuelven
          en
          `data/` contra el manifiesto del idioma activo.
    - **Actividad «Predice y ejecuta»:** Extrae la casuística de la lista de la parte de predicción (
      `<ejemplo>#<paso>#<variable>`) y compara la predicción del estudiante contra el valor observable en la máquina.
    - **Ilustraciones catalogadas:** `illustrationCatalog` mapea identificadores estables a constructores de widgets
      programáticos (`MemoryBoxesIllustration`), garantizando soporte vectorial sin imágenes rasterizadas.
- **Alternativas descartadas y por qué:**
    - *Redacción de especificaciones con valores de sintaxis cableados:* Descartada porque generaría divergencias cuando
      el
      perfil de sintaxis cambia o se actualiza el núcleo.
    - *Imágenes generadas por IA o diagramas estáticos incrustados:* Descartadas por inconsistencia estilística y falta
      de
      adaptabilidad a temas claro y oscuro.

### 4.19 Comprobación pedagógica de ejercicios: conducta observable, normalización y aserciones estructurales

- **Problema:** Comprobar si un ejercicio es correcto no debe depender de una coincidencia textual del código fuente ni
  de comparaciones frágiles de cadenas.
- **Elección:** El puerto `ExerciseChecker` y su implementación en `engine/exercise/` evalúan los programas en base a
  conducta observable:
    - **Casos de prueba visibles y ocultos:** El programa se ejecuta con entradas simuladas capturando la salida
      emitida.
    - **Normalización de salidas:** Colapso de espacios en blanco internos, recorte de extremos, eliminación de saltos
      de
      línea finales superfluos y comparación numérica con tolerancia de `1e-9` para valores de punto flotante.
    - **Aserciones estructurales del AST (Catálogo cerrado):** Cuando el enunciado exige restricciones de diseño, se
      comprueban hasta cinco condiciones sobre el resumen `ProgramStructure`:
        1. Contiene construcción sintáctica (`ContainsConstructAssertion`).
        2. No contiene construcción sintáctica (`NotContainsConstructAssertion`).
        3. Declara subprograma con nombre y aridad (`SubprogramSignatureAssertion`).
        4. Declara miembro de clase con visibilidad (`ClassMemberAssertion`).
        5. No supera N repeticiones de una construcción (`MaxOccurrencesAssertion`).
    - **Filosofía no punitiva:** No se muestran calificaciones ni porcentajes. Si fallan casos ocultos, se aísla y
      revela **exclusivamente el primer caso oculto fallido** con sus entradas y salidas esperadas.
    - **Código base inicial (`starterCode`) para ejercicios interactivos:** Los ejercicios con tipología `completar` o
      `modificar` definen código de arranque en sus activos JSON (`starterCode`). Al resolver un ejercicio desde la base
      de conocimiento, `ExerciseCreationLauncher` crea el documento pre-poblando el editor con este código base.
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
    - `SessionStorage` delega la persistencia del token de refresco a almacenamiento seguro de plataforma
      (`FlutterSecureStorage`)
      inyectando un adaptador `GotrueAsyncStorage` en `AuthClientOptions`.
    - `AccountCubit` gestiona el estado inmutable `AccountState` y tipifica cualquier fallo en `AccountError`.
- **Alternativas descartadas y por qué:**
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
    - *Conservar el código de autorización de Apple para revocación:* Descartado mientras la aplicación no ofrezca
      borrado de
      cuenta remota; un dato de sesión sin consumidor es superficie de exposición sin contrapartida.

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

- **Problema:** Sincronizar el avance curricular (módulos visitados y ejercicios resueltos) y las preferencias del
  usuario
  entre dispositivos sin generar conflictos textuales y sin acoplar configuraciones ergonómicas del dispositivo a la
  cuenta personal.
- **Elección:**
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
      los transforma mediante funciones puras desacopladas (`projectLibraryMetrics`, `projectTrackCoverage`,
      `projectNextModule`, `projectExerciseCoverage`, `projectConceptUsage`, `projectSpecificationCoverage`,
      `projectActivityWeeks`, `projectSyncHealth`), respetando el límite de 5 métodos públicos por clase.
    - **Cimas y recuentos calculados en el estado:** Estructuras como `ActivityTimeline`, `ConceptCoverage` y
      `SpecificationCoverage` transportan valores agregados definitivos hacia los widgets, dando estricto cumplimiento a
      la
      prohibición de `where`, `fold` y `sort` en la capa de presentación.
    - **Conceptos ejercitados derivados del AST:** El adaptador `CoreProgramConstructReader` analiza el código de los
      documentos locales mediante `ProgramStructure` (el mismo analizador de aserciones de ejercicios), deduciendo qué
      estructuras de control y programación orientada a objetos ha escrito realmente el estudiante sin almacenar
      telemetría
      adicional.
    - **Cobertura de especificación acotada a lo observable:** Cruza construcciones ejercitadas contra las secciones
      normativas correspondientes publicadas en los manifiestos, omitiendo del denominador aquellas secciones
      conceptuales
      no asociadas a nodos sintácticos verificables.
    - **Línea de actividad semanal fija de 8 semanas:** Muestra barras descriptivas continuas sin penalizar períodos de
      inactividad ni introducir rachas gamificadas punitivas.
- **Alternativas descartadas y por qué:**
    - *Panel alojado dentro de la pantalla de Cuenta:* Descartada porque exigiría iniciar sesión para consultar el
      propio
      progreso, violando el principio local-first.
    - *Cálculo de cobertura leyendo los archivos Markdown en tiempo real:* Descartada por el impacto prohibitivo en el
      tiempo
      de renderizado de la interfaz al analizar 15 módulos en cada apertura.
    - *Almacenamiento de número de intentos, tasas de acierto o tiempos por módulo:* Descartado por contravenir las
      directrices
      de privacidad y la filosofía pedagógica formativa no punitiva.

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
  vacío todo su lado derecho. El emparejamiento además es honesto de leer: *«Sin problemas»* junto a un botón de
  ejecutar activo, *«2 problemas»* junto al mismo botón apagado. El estado y su acción viven en la misma línea.
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

- **Problema:** el paquete no lleva renderizador de SVG y `pubspec.yaml` no puede declarar activos fuera del directorio
  del paquete, así que los vectores que emite `packages/pseudolearn_brand` son inalcanzables desde aquí. Cargarlos exigía una dependencia de
  terceros
  y una copia a mano de un artefacto generado.
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
  medidas contra los `viewBox` que el generador escribe, y un golden reduce el símbolo a 16, 24, 32 y 48 px.
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
  familia empaquetada, igual que el resto de la interfaz, y los goldens que lo retrataban cambian. A cambio, un
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

---

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
  `ExerciseCheckResult`, etc.).

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

### 6.8 Reserva de columnas institucionales en el esquema local

Para evitar migraciones disruptivas de base de datos ante futuras integraciones institucionales o multiusuario, el
esquema local SQLite incluye
columnas nulas para metadatos institucionales (`institution_id`, `class_id`, `membership_id`,
`submission_id`). La aplicación no las puebla ni añade abstracciones en el dominio para ellas.

### 6.9 Comprobación pedagógica no punitiva

La resolución de ejercicios tiene carácter formativo. Se informa qué casos de prueba cumplen y se orienta sobre el
primer caso anómalo sin asociar notas numéricas, calificaciones ni penalizaciones.

### 6.10 Salida de sesión con preservación o borrado local selectivo

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

### 6.11 Arquitectura de sincronización offline-first y resolución no destructiva

- **Outbox persistente:** Toda mutación de documento encola una entrada en la tabla SQLite `sync_outbox`. El usuario
  siempre interactúa a velocidad de disco local, independientemente de la latencia o disponibilidad del backend.
- **Pull antes que push:** Cada ciclo de vaciado de cola drena primero los cambios remotos pendientes antes de empujar
  los locales. Esto garantiza que cualquier edición concurrente se evalúe contra la versión común más reciente.
- **Conflictos conservados (`KeepBoth`):** Los conflictos nunca descartan silenciosamente el trabajo del usuario. Se
  adopta la versión remota
  en el ID principal y se genera una copia local con el contenido en conflicto titulada `... (conflicto)`.
- **Composición incondicional:** `SyncingDocumentRepository` decora siempre a `FileDocumentRepository` en la raíz de
  composición, eliminando ramas condicionales de runtime entre modos online y offline.

### 6.12 Unión monotónica de progreso y partición de preferencias

- **Convergencia sin intervención:** El progreso de aprendizaje es un conjunto de crecimiento monótono. Al no existir
  eliminaciones ni regresiones de avance en el uso ordinario, cualquier sincronización converge calculando la unión
  lógica
  de las banderas de visita y completado, y el mínimo temporal de las fechas de primer logro. Reenviar un lote es seguro
  e idempotente.
- **Partición de preferencias por ciclo de vida:** Los datos de personalización de la experiencia pertenecen a la
  identidad
  del usuario (`AccountPreferences`), mientras que los parámetros de renderizado visual y fuentes pertenecen al entorno
  físico de ejecución (`DevicePreferences`). Solo los primeros se sincronizan.

### 6.13 El panel de progreso mide cobertura, nunca rendimiento

El panel resume el trabajo hecho sin emitir juicio: cuenta módulos visitados, ejercicios resueltos, algoritmos
escritos y construcciones ejercitadas, siempre como «hechos de un total» y nunca como porcentaje de logro, nota ni
racha. Una semana sin actividad se dibuja como una barra a cero, no como una marca de fallo, y no existe comparación
con nadie. Quedan fuera por decisión de producto, no por alcance: intentos por ejercicio y tasa de acierto —el
sistema no almacena intentos—, tiempo dedicado por módulo —sería telemetría de comportamiento— y cualquier
comparación entre estudiantes.

---

## 7. Verificación, testing y aseguramiento de calidad

### 7.1 Matriz de verificadores mecánicos

| Verificador                    | Comando / Script                                                         | Qué valida                                                                                                                                       | Regla en                        |
|:-------------------------------|:-------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------|
| Linter estricto                | `flutter analyze --fatal-infos --fatal-warnings`                         | Errores de tipo, null safety, dead code, imports no usados                                                                                       | `analysis_options.yaml`         |
| Límites métricos y comentarios | `dart run tool/check_limits.dart`                                        | Líneas de archivo, funciones, build, anidación, métodos, parámetros, y ausencia total de comentarios en código                                   | `architecture.yaml`             |
| Invariantes de contenido       | `dart run tool/check_content.dart`                                       | Paridad de manifiestos, resolución de marcadores, 7 partes de módulos, sintaxis de ejemplos y soluciones de ejercicios                           | `architecture.yaml`             |
| Sistema de diseño              | `dart run tool/check_design_system.dart`                                 | Familias tipográficas en disco, ausencia de medidas crudas en padding/espacios y unicidad de `DesignCanvas`                                      | `architecture.yaml`             |
| Cobertura de especificación    | `flutter test test/tool/spec_coverage_test.dart`                         | Proyección completa de las secciones de `language-spec.md` en especificaciones publicadas                                                        | `architecture.yaml`             |
| Capas y dependencias           | `flutter test test/architecture/layering_test.dart`                      | Matriz de `may_import`, `forbidden_imports` y ausencia de imports package propios                                                                | `architecture.yaml`             |
| Pureza de presentación         | `flutter test test/architecture/presentation_purity_test.dart`           | Prohibición de constructores adaptativos, métodos de derivación de colecciones, `await` y `MediaQuery` fuera de shell                            | `architecture.yaml`             |
| Pureza de composición          | `flutter test test/architecture/composition_purity_test.dart`            | Ausencia total de condicionales en `composition/`                                                                                                | `architecture.yaml`             |
| Inmutabilidad de estados       | `flutter test test/architecture/state_immutability_test.dart`            | Campos estrictamente `final` en archivos `*_state.dart`                                                                                          | `architecture.yaml`             |
| Cadenas visibles               | `flutter test test/architecture/no_user_facing_strings_test.dart`        | Ausencia de literales de texto en español fuera de capas de localización y vocabulario autorizado                                                | `architecture.yaml`             |
| Consultas de plataforma        | `flutter test test/presentation/platform_target_verification_test.dart`  | Constructores adaptativos prohibidos en todo `lib/`, y `Platform.isX` / `defaultTargetPlatform` / `TargetPlatform.` solo en las rutas declaradas | `architecture.yaml`             |
| Familias empaquetadas          | `flutter test test/presentation/theme/bundled_fonts_test.dart`           | Que la suite rasterice con IBM Plex y no con el tipo de relleno del motor, con un caso negativo sobre una familia inexistente                    | `test/flutter_test_config.dart` |
| Fidelidad de la marca          | `flutter test test/presentation/brand/ test/presentation/goldens/brand/` | Que las medidas del lockup sigan coincidiendo con las del generador de vectores, y que el símbolo aguante la reducción a 16, 24, 32 y 48 px      | `brand/README.md`               |

### 7.2 Estrategia y pirámide de pruebas

- **Estructura espejo:** La carpeta `test/` reproduce con exactitud la jerarquía de carpetas de `lib/`.
- **Doble camino:** Toda unidad se prueba en su camino exitoso, en sus caminos de fallo controlados
  y ante casos límite (árboles vacíos, identificadores de un carácter, recursión profunda, programas sin salida).
- **Pruebas de verificadores (Casos negativos):** En `test/architecture/fixtures/` se mantienen violaciones deliberadas
  para constatar que cada verificador falla efectivamente ante infracciones.
- **Suite de pruebas de regresión visual (Goldens):** Renderizado a ocho anchos clave (360, 480, 600, 800, 960, 1280,
  1920 y 2560 dp) en modos claro y oscuro para certificar la estabilidad del lienzo y componentes.
- **Los goldens se rasterizan con las familias empaquetadas.** `test/flutter_test_config.dart` las registra antes del
  primer test. No es un detalle de montaje: mientras no lo hacía, el motor rasterizaba con su tipo de relleno —cada
  glifo
  un bloque de avance constante— y ningún golden podía detectar un cambio tipográfico. Al cargarlas, 172 de los 178
  goldens cambiaron; ese diff es exactamente la tipografía que no se estaba verificando.

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

## 8. Fuentes consultadas y genealogía conceptual

| Fuente consultada                                                 | Qué se tomó                                                                                                                                         | Qué se rechazó deliberadamente y por qué                                                                                             |
|:------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|
| Material Design 3 (Google)                                        | Corte base de 600 dp entre clases de ventana compacta y mediana.                                                                                    | Escala de cinco clases y comportamientos adaptativos automáticos de widgets que rompen la consistencia multiplataforma.              |
| Guía de diseño adaptativo de Flutter                              | Estructura de armazón con navegación compartida entre barra inferior y riel lateral.                                                                | Variaciones automáticas de densidad, física de scroll y estilos dependientes del sistema operativo.                                  |
| Arquitectura Hexagonal (A. Cockburn)                              | Puertos independientes de la tecnología y adaptadores periféricos intercambiables.                                                                  | Terminología empresarial compleja (DTOs, repositorios genéricos pesados) innecesaria en un cliente de aplicación interactivo.        |
| BLoC Pattern (`package:bloc`)                                     | Modelo de estados inmutables precalculados y comandos unidireccionales mediante `Cubit`.                                                            | Patrón completo de eventos por introducir burocracia redundante frente a la traza ya provista por el núcleo.                         |
| ISO 5807:1985 (Símbolos para diagramas de procesamiento de datos) | Convenciones geométricas: terminal ovalado, proceso rectangular, decisión en rombo, E/S en romboide y proceso predefinido en rectángulo con barras. | Símbolos de almacenamiento físico (cintas magnéticas, discos, tarjetas perforadas) por carecer de sentido en pseudocódigo abstracto. |
| PSeInt (Pablo Novara)                                             | Representación del bucle `Para` como nodo único de preparación e inspiración en estructogramas integrados.                                          | Estética visual no estructurada, diagramado como imágenes fijas no interactivas y falta de determinismo algorítmico documentado.     |
| Nassi, I. y Shneiderman, B. (1973)                                | Principio fundamental del estructograma: modelado jerárquico de control estructurado sin aristas explícitas de salto.                               | Repertorio original sin normalizar previo a la adopción de selección múltiple estandarizada.                                         |
| DIN 66261:1985-11                                                 | Catálogo de celdas para estructogramas: proceso, selección con cabecera de cuñas, bucles con franja indentada y subprogramas con doble barra.       | Proporciones fijas inflexibles y ausencia de representaciones explícitas para salida anticipada (`Retornar`).                        |
| Ruteo ortogonal y diagramas de clases UML (OMG UML 2.5)           | Caja de tres compartimentos, visibilidad `+`/`-`, jerarquía de generalización y relación de asociación.                                             | Diagramado libre manual, multiplicidades complejas innecesarias en el nivel de abstracción del lenguaje y conectores diagonales.     |
| Sign in with Apple (Human Interface Guidelines y App Store 4.8)   | Prioridad del acceso con Apple, colores y contraste del botón de marca, y flujo de nonce con resumen SHA-256 contra reutilización de token.         | Botón nativo del complemento, por imponer métricas, radios y tipografía propias que rompen el sistema de diseño de la aplicación.    |
