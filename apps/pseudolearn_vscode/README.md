# pseudolearn_vscode

## 1. Qué es y qué no es

Extensión privada de escritorio que integra PseudoLearn con VS Code. Se distribuye para uso local mediante F5 durante el desarrollo y archivos VSIX instalados manualmente. El primer artefacto calificado es para macOS Apple silicon (`darwin-arm64`). El paquete incluye el ejecutable `pseudo` para ese destino; no busca ejecutables en el workspace ni descarga binarios al activar.

El código propio está reservado para uso local y no se concede una licencia abierta. El empaquetado genera `third-party-notices.md` desde el grafo Cargo específico del binario incluido y conserva los textos de licencia disponibles junto a la lista SPDX de dependencias. La extensión no se publica en Marketplace ni Open VSX.

Fuera de alcance de este incremento: cliente LSP funcional, comandos de edición o ejecución, depuración, plataformas no calificadas, workspace remoto, workspace virtual, actualizaciones automáticas, telemetría y publicación. No se incluye migrador ni selector de compatibilidad: cada edición se ofrece como la oficial aunque introduzca cambios incompatibles.

## 2. Guía operativa y ciclo de vida

Usa Node.js 22.23.3, pnpm 12.8.1, TypeScript 6.0.3, VS Code API 1.144.0 y `@vscode/vsce` 4.0.0. `vscode-languageclient` se fija en 10.1.2 para el cliente LSP fino de la siguiente etapa. El mínimo de VS Code es `^1.144.0`. La versión `0.1.0` identifica este artefacto de extensión, no una versión del lenguaje.

La activación registra el ciclo de vida y no inicia procesos. Para empaquetado de desarrollo, `PSEUDOLEARN_PSEUDO_PATH` puede apuntar a un ejecutable con ruta absoluta solo cuando `NODE_ENV=development`; el empaquetado ordinario compila e incluye el binario `darwin-arm64`. El VSIX usa el binario incluido, sin red ni toolchains en tiempo de ejecución.

F5 requiere el checkout y la cadena de construcción; una instalación VSIX coincidente requiere VS Code Stable para macOS Apple silicon y no requiere Cargo, Rust, Node ni pnpm. En otra plataforma el artefacto no está calificado. La instalación y actualización son manuales: conservar el VSIX anterior permite revertir reinstalándolo. No hay actualización automática.

## 3. Arquitectura y modelo del sistema

Las capas son `contracts`, `application`, `adapters` y `activation`. `contracts` declara puertos y datos; `application` implementa casos de uso sobre esos puertos; `adapters` integra VS Code, Node y el proceso Rust; `activation` compone las capas y registra sus recursos. La dirección de imports está declarada en `architecture.json` y se verifica localmente.

TypeScript no implementa parser, resolución semántica, gramática ni políticas de proyecto. Los contratos observables pertenecen al corpus; Rust es el único analizador y servicio semántico. Ningún módulo de activación inicia el LSP automáticamente en este esqueleto.

El bundle de producción reúne el código JavaScript y sus dependencias runtime. El VSIX incluye solo el bundle, el binario del target declarado, metadata, README, aviso de derechos y avisos de licencias del binario; excluye fuentes, tests, fixtures, scripts de verificación, secretos, mapas y `node_modules`.

## 4. Decisiones de diseño y fundamentos técnicos

La extensión vive en `apps/` porque es un producto distribuible y no una biblioteca. Node/pnpm son una cadena declarada para este miembro; no se importan reglas ni verificadores del frontend. TypeScript no puede elegir rutas de proyecto, leer fuera de raíces autorizadas ni ejecutar un shell.

La activación y desactivación son idempotentes. Los recursos se registran en un `Disposable` de composición y los errores esperables salen por resultados tipados. El proceso y los puertos son dependencias inyectadas para que las pruebas no necesiten VS Code ni el binario.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés y sin comentarios. README y documentación en español. Cada archivo tiene una responsabilidad y reside en una capa declarada. Límites: 300 líneas por archivo, 40 por función, cuatro parámetros posicionales, anidación de tres niveles y siete métodos públicos por clase. Los verificadores propios rechazan imports inversos, capas no declaradas, comentarios fuera de cadenas, tamaños excedidos, secretos y contenido de paquete excluido.

## 6. Verificación y testing

Desde este directorio:

- `pnpm install --frozen-lockfile`
- `pnpm check:types`
- `pnpm check:architecture`
- `pnpm check:comments`
- `pnpm check:size`
- `pnpm check:package`
- `pnpm test`
- `pnpm build`
- `pnpm package`

Los tests reflejan `src/` bajo `tests/`. Los verificadores tienen fixtures positivos y negativos; los tests de activación usan puertos falsos. `pnpm package` crea un VSIX local para macOS Apple silicon, genera los avisos del binario desde `cargo metadata` y valida su lista de contenidos. F5 y la instalación local del VSIX en VS Code Stable 1.144.0 son verificaciones del host, no publicación.
