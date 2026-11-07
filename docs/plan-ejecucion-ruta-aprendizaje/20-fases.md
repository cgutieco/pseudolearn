# 20 — Fases

Cada fase cierra con `PHASE-GREEN`: todos los tests y todos los verificadores de cada paquete tocado en verde. Al cerrar,
se hace commit con el formato de la skill `commit-message` y push ordinario a `feature/agregar-ruta-de-especificacion`
(`GIT-SINGLE-BRANCH`), y se comprueba que el push llegó. Salvo instrucción directa de la persona, al cerrar una fase se
para y se espera autorización nueva (`PHASE-STOP`).

Antes de cada build pesado (cargo, flutter, simulador) se revisa el espacio libre con `df -h`. Si falta, se liberan solo
cachés regenerables (directorios `target/`, `build/` y `.dart_tool/`, DerivedData, cachés de cargo y pub con sus
comandos, simuladores no disponibles). Los comandos largos corren en segundo plano.

---

## RA-1 — El segundo libro del compilador

**Entrega.** `packages/pseudolearn_reference` compila dos libros: `especificacion` y `ruta` (01 §2 a §4, 02).

- Modelo de lección y de ejercicio en `reference_model`; lectura de cabeceras, recuadros y cercas nuevos en
  `reference_format`.
- Crate `route_resolve` declarado en `architecture.yaml` con su `may_import`; resuelve tarjetas de recuerdo, enlaces a la
  Especificación, figuras de la Especificación incrustadas y bloques nuevos.
- Verificadores `RUTA-*` en módulos `route_*` de `reference_verify`, cada uno con su caso negativo en `fixtures/route/` y
  un test que demuestra que falla.
- `schemas/route-bundle.schema.json` validado por un test.
- `build`, `check` y `coverage` procesan los dos libros; `build` escribe `assets/reference/` y `assets/route/`.
- README del miembro reescrito (decisión D1) en el mismo cambio.
- Primer contenido: la lección 0.1 en `es` y `en`, con sus figuras propias y sus ejercicios en forma fuente.

**Cierre.** `cargo xtask verify` en verde desde `packages/pseudolearn_reference`.

## RA-2 — Verificación por tipo de ejercicio

**Entrega.** `RUTA-EXERCISE-VERIFIED` con las comprobaciones de 02 §3.3, incluida la instrumentación de `rastrear`
(inserción de `Escribir` antes de la línea marcada y lectura de una fila por línea), y la publicación de
`exercises/<id>.json` con su objeto `evaluacion` (02 §3.5). Los ejercicios de la lección 0.1 quedan verificados y
publicados.

**Cierre.** `cargo xtask verify` en verde.

## RA-3 — La ruta en la app

**Entrega** (01 §5 y §7):

- `domain/model/route/`, puerto `RouteRepository`, `data/route/` (lector del paquete), `engine/route_exercise/` (un
  evaluador por tipo), `application/route/` (cubits de índice, lección y ejercicio con mapa de evaluadores inyectado) y
  `presentation/route/`, reutilizando las vistas de bloque de la Especificación.
- Rutas `/conocimiento/ruta`, `/conocimiento/ruta/:leccion` y `/conocimiento/ruta/:leccion/:ejercicio`, y su registro
  en composición.
- Progreso con `ruta.leccion:<id>` y `ruta.ejercicio:<id>`; banco de ejercicios como proyección de la ruta; tablero e
  incorporación con partes y lecciones.
- Eliminación completa de la ruta anterior, con su inventario previo en el informe de la fase. Los ejemplos que otras
  partes usan (por ejemplo `guided_demo_*`) se mueven a una ruta neutral y se actualizan sus consumidores.
- README de la app actualizado.

**Cierre.** Todas las verificaciones de §2.5 del README de la app que no requieren dispositivo físico.

## RA-4 — Unidad 0 y Parte I

**Entrega.** Lecciones 0.1 a 0.4, 1.1 a 1.8 y P·I en `es` y `en`, con sus figuras y ejercicios (fichas 10 y 11). Cada
número del plan se verifica con el motor (`RA-NUMBERS-ORACLE`); cada discrepancia se registra.

**Cierre.** `cargo xtask verify` en verde, paquete regenerado y tests de la app en verde.

## RA-5 — Partes II y III

**Entrega.** Lecciones 2.1 a 2.7, P·II, 3.1 a 3.6 y P·III en `es` y `en` (fichas 12 y 13).

**Cierre.** Igual que RA-4.

## RA-6 — Partes IV, V y VI

**Entrega.** Lecciones 4.1 a 4.5, P·IV, 5.1 a 5.3, 6.1 a 6.3 y P·F en `es` y `en` (fichas 14 y 15).

**Cierre.** Igual que RA-4.

## RA-7 — Revisión integral

**Entrega.**

- Informe de `reference coverage` para la ruta (términos por lección, lecciones por sección, ejercicios por tipo y nivel,
  secciones sin enlazar).
- Enlaces «Aprender en la ruta» al pie de cada sección de la Especificación, desde `spec-links.json`.
- Recorrido de la lista de cierre de 03 §11 en cada lección.
- Prueba de humo en el simulador iOS disponible: índice de la ruta, lecciones 0.1 y 1.3, y un ejercicio resuelto de cada
  tipo, con capturas guardadas fuera del repositorio.
- Las capturas de producto y el material de tiendas no se regeneran sin autorización: quedan como pendiente declarado.

**Cierre.** Todas las verificaciones de RA-3 y RA-4 en verde.
