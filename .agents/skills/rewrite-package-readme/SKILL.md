---
name: rewrite-package-readme
description: Reescribe el README.md de un paquete o app de PseudoLearn con la plantilla corta y visual (propósito, dónde encaja, arquitectura, flujo, comandos). Úsala cuando se pida reescribir, acortar o actualizar el README de cualquier miembro del monorepo.
---

# Reescribir el README de un paquete

El README es una presentación para quien quiere entender el paquete sin leer su código. No es un registro de decisiones ni de historia: el comportamiento del lenguaje vive en el corpus y el resto vive en el código. Cada reescritura **sustituye por completo** el README anterior; no se conserva su estructura.

## Antes de escribir

1. Leer `AGENTS.md`, el `architecture.yaml` o `architecture.json` del miembro y su README actual.
2. **Contrastar cada afirmación con el código.** El README actual puede estar desfasado y no es fuente de verdad. Fuentes aceptadas:
    - Dependencias internas: `Cargo.toml`, `pubspec.yaml`, `package.json`, `deno.json`, no la prosa.
    - Consumidores: buscar quién referencia al miembro en los manifiestos y scripts de los demás.
    - Capas y reglas: el archivo de reglas del miembro.
    - Comandos: scripts, `xtask`, `package.json`, `Makefile`; confirmar que existen y con qué opciones.
3. Todo lo heredado del README viejo que no se pueda confirmar se omite o se manda a los pendientes; nunca se copia como hecho.

## Plantilla (80 a 150 líneas)

1. **Título y propósito**: un párrafo corto y una línea **No hace:** con lo que alguien podría suponer y no es.
2. **Dónde encaja**: un diagrama Mermaid `flowchart BT`. Debajo, las dependencias del miembro; en el centro, el miembro; arriba, quienes lo usan. Las flechas van de la dependencia a quien la usa. Sin frase explicativa debajo.
3. **Arquitectura**: un diagrama de las piezas internas agrupadas por capa, con las mismas reglas de flecha, y una tabla de una línea por capa o pieza. Si omite aristas muy comunes, se dice en una línea.
4. **Flujo principal**: un diagrama `flowchart LR` del camino que más importa, indicando que es de flujo y no de dependencias cuando la dirección difiere.
5. **Reglas que conviene saber**: 3 a 5 viñetas que salgan del archivo de reglas del miembro, no de memoria.
6. **Comandos útiles**: tabla «para qué / comando» con los que se usan de verdad, más una línea de requisitos.

Las secciones que no apliquen se omiten; no se rellenan. Un miembro pequeño puede quedar en 60 líneas.

## Qué no entra

- Historia, genealogía, fuentes consultadas, resultados de mediciones pasadas.
- Reglas del lenguaje o comportamiento observable: eso es del corpus.
- Decisiones de diseño narradas: si importan, se reflejan en los nombres, los tipos y el archivo de reglas.
- Pendientes: van a la sección «Pendientes declarados» del README del miembro, solo si exigen una acción de la persona o una decisión que el corpus aún no toma; lo resuelto o decidido se escribe como regla del paquete.
- Afirmaciones de plataformas, rendimiento o cobertura que no se hayan comprobado.

## Diagramas

- Mermaid para todo; un SVG a medida solo en el README raíz.
- Un diagrama, una idea. Si pasa de unos 15 nodos, se agrupa por capa y se omiten las aristas hacia las bases compartidas.
- Nombres de nodo cortos; la ruta completa solo en el diagrama de «Dónde encaja».
- Sin colores ni estilos propios: que el renderizador decida.

## Al terminar

1. Releer el README contra el código una vez más: nodos y flechas de cada diagrama, nombres de comandos, cifras (número de crates, versiones).
2. Dejar en «Pendientes declarados» únicamente lo que sigue abierto y contrastarlo con el código.
3. Comprobar que ningún verificador del miembro depende de los encabezados del README (buscar en sus scripts de comprobación) y que no se pierde una tabla que un verificador exija, como la de invariantes de `unsafe` en Rust.
4. Informar qué se verificó contra el código y qué no, sin hacer commit salvo que se pida.
