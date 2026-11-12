# Contribuir a PseudoLearn

Gracias por el interés. Este monorepo aloja el lenguaje, sus herramientas y sus aplicaciones, y las
contribuciones son bienvenidas. Al participar aceptas el [código de conducta](CODE_OF_CONDUCT.md); tu
contribución se distribuye bajo [Apache-2.0](LICENSE).

## Qué se acepta

- Correcciones de errores, de accesibilidad, de rendimiento y de SEO.
- Mejoras de traducción en español e inglés.
- Mejoras de las herramientas de verificación y de la documentación.
- Cambios al comportamiento del lenguaje, que empiezan por el corpus de especificaciones.

## Qué no se acepta

- Cambios de identidad visual o de texto de producto sin acuerdo previo en una issue.
- Dependencias nuevas sin justificación explícita.
- Analítica, píxeles de seguimiento o recursos de terceros en el sitio web.
- Copias a mano de artefactos generados o de tablas del lenguaje en otro miembro.

## Cómo orientarte

1. Ubica el miembro de tu cambio: `packages/<nombre>/` o `apps/<nombre>/`.
2. Lee su `README.md` para entender cómo está organizado y por qué. Su archivo de reglas (`architecture.yaml` o
   `architecture.json`) declara las capas y qué puede importar cada una.
3. El comportamiento del lenguaje se define en el corpus de `packages/pseudolearn_spec`. Si tu cambio lo
   altera, empieza por ahí: especificación, casos, tests y código, en ese orden.

## Convenciones del código

- **Sin comentarios.** El código se explica con nombres claros, tipos y funciones pequeñas. Cada miembro
  tiene un verificador que lo comprueba.
- **Inglés en el código, español en la documentación.** Identificadores, nombres de test y mensajes de
  commit en inglés; README, guías y corpus en español.
- **Respeta las capas.** Un archivo solo importa de lo que el archivo de reglas de su miembro permite.
- **Lo generado se regenera.** Usa la herramienta del miembro y su verificación; no edites el resultado.
- **Prueba el éxito y el fallo.** Cada pieza lleva un caso feliz, un caso infeliz y sus límites.

El detalle de las reglas y sus identificadores está en [`AGENTS.md`](AGENTS.md).

### Reglas propias del sitio web

- Ninguna palabra visible vive en el código: todo texto pasa por `t()` y por los dos diccionarios, que
  deben tener claves idénticas.
- Toda ruta existe en los dos idiomas.
- Las clases siguen BEM estricto, y el prefijo `pl-` está reservado al vocabulario compartido.
- El sitio no usa frameworks de cliente ni librerías de componentes: es una decisión, no una carencia.

## Verificar antes de abrir un pull request

Cada miembro usa solo su cadena de herramientas y se verifica desde su carpeta. Debe pasar entero.

| Miembro                                                                                              | Comando base                                                                                     |
|------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| Miembros Rust (`pseudolearn_engine`, `pseudolearn_spec`, `pseudolearn_cli`, `pseudolearn_reference`) | `cargo xtask verify`                                                                             |
| `apps/pseudolearn_app`                                                                               | `flutter pub get`, `flutter test` y las reglas de la frontera nativa                             |
| `apps/pseudolearn_web`                                                                               | `pnpm install --frozen-lockfile` y `pnpm check:all`                                              |
| `apps/pseudolearn_vscode`                                                                            | `pnpm install --frozen-lockfile`, `pnpm check:types`, `pnpm test`, `pnpm build` y `pnpm package` |
| `apps/pseudolearn_backend`                                                                           | `deno task verify`                                                                               |
| `packages/pseudolearn_brand`                                                                         | `python3 -m pseudolearn_brand check`                                                             |
| `packages/pseudolearn_benchmarks`                                                                    | `dart test` y `dart run tool/check.dart`                                                         |

Las suites de navegador del sitio van aparte: `pnpm test:e2e && pnpm test:a11y && pnpm test:visual`. Los
comandos completos están en la sección «Cómo se verifica» del README de cada miembro. Los resultados de un
sistema operativo no certifican otro.

## Mensajes de commit

Conventional Commits en inglés. El formato y los ejemplos están en
[`.agents/skills/commit-message/SKILL.md`](.agents/skills/commit-message/SKILL.md).

## Pull requests

- Un cambio por pull request, con el motivo explicado y los miembros afectados.
- Incluye los tests que el cambio necesita.
- Si tu cambio altera la arquitectura de un miembro o deja desactualizado lo que su README muestra,
  ajusta el README.
