# Plan de ejecución — Ruta de aprendizaje de PseudoLearn

Estado: aprobado para ejecutar por fases. Ninguna fase de implementación ha empezado.

Este plan convierte la propuesta de [`../plan-ruta-aprendizaje.md`](../plan-ruta-aprendizaje.md) en trabajo ejecutable.
Lo ejecuta un agente que no participó en el diseño. Por eso cada decisión, cada lección, cada figura y cada
ejercicio están descritos con su propósito, y no solo con su nombre.

---

## 1. Cómo usar este plan

### 1.1 Orden de lectura obligatorio antes de la primera línea

1. `AGENTS.md` de la raíz. Rige todo: idioma, cero comentarios, capas, `PHASE-STOP`, `PHASE-GREEN` y la rama única.
2. Este archivo completo.
3. [`01-arquitectura.md`](01-arquitectura.md): dónde vive cada cosa y por qué.
4. [`02-formato-y-verificadores.md`](02-formato-y-verificadores.md): cómo se escribe una lección y un ejercicio, y qué
   rechaza el compilador.
5. [`03-pedagogia-y-estilo.md`](03-pedagogia-y-estilo.md): las reglas de redacción. Sin ellas el contenido sale como la
   ruta actual: correcto y sin valor.
6. [`04-terminos-maquina-figuras.md`](04-terminos-maquina-figuras.md): catálogo de términos con su lección dueña,
   piezas de la máquina nocional y catálogo de figuras.
7. La ficha de la parte que toque: [`10-unidad-0.md`](10-unidad-0.md), [`11-parte-1.md`](11-parte-1.md),
   [`12-parte-2.md`](12-parte-2.md), [`13-parte-3.md`](13-parte-3.md), [`14-parte-4.md`](14-parte-4.md),
   [`15-parte-5-y-6.md`](15-parte-5-y-6.md).
8. [`20-fases.md`](20-fases.md): qué entrega cada fase, cómo se verifica y dónde se para.

Además, antes de tocar un paquete se leen su `README.md` y su `architecture.yaml`, como exige `AGENTS.md` §1:

- `packages/pseudolearn_reference/README.md` y `architecture.yaml`, para el compilador.
- `apps/pseudolearn_app/README.md` y `architecture.yaml`, para la app.

### 1.2 Muestras de referencia

[`../ruta-aprendizaje-ejemplos/`](../ruta-aprendizaje-ejemplos/) contiene tres lecciones maquetadas a mano (0.1, 1.3 y
4.1). Son la referencia de **tono, densidad, orden de bloques y tipo de ejercicio**. No son la referencia de formato
fuente ni de numeración: donde difieran de este plan, manda el plan.

### 1.3 Reglas que este plan agrega a `AGENTS.md`

| ID | Regla |
|---|---|
| `RA-PLAN-TRUTH` | Este plan manda sobre las muestras. `AGENTS.md`, los README y el corpus mandan sobre este plan. Un choque se reporta (`CONFLICT-REPORT`); no se resuelve en silencio |
| `RA-NUMBERS-ORACLE` | Toda salida, número o respuesta que este plan da para un problema está derivada a mano. El agente la verifica ejecutando con el motor. Si el motor da otra cosa, se para y se reporta: o el plan se equivocó, o el motor tiene un fallo. Nunca se ajusta el número para que pase |
| `RA-NO-RECIPE` | Un enunciado de problema o de ejercicio nunca nombra la construcción, el rol de variable ni el esquema que lo resuelve. Hay un verificador mecánico para esto (`RUTA-STATEMENT-NO-RECIPE`) |
| `RA-ONE-OWNER` | Cada término, figura y explicación tiene un solo dueño. Lo que la Especificación explica se enlaza; no se reescribe |
| `RA-ES-FIRST` | Cada lección se redacta primero en español y se cierra con su par inglés en la misma fase, con paridad estructural |
| `RA-SCOPE` | Solo se implementa lo que pide una fase. Un hallazgo fuera de alcance se anota como pendiente en el README del paquete afectado |

Las referencias a este plan **no** pueden aparecer en código, README ni contenido publicado (`DOC-NO-TRANSIENT-REFS`).
Toda decisión que el agente tome a partir de este plan se registra en el README del paquete con su porqué
(`DOC-NO-ORPHAN-DECISION`).

---

## 2. Qué se construye, en una página

Una **ruta de aprendizaje nueva** que reemplaza por completo la actual (`apps/pseudolearn_app/assets/knowledge/`),
sin retrocompatibilidad. Tiene una unidad inicial, seis partes, 36 lecciones y cinco proyectos. Enseña a resolver
problemas con el ciclo PseudoLearn (entender, planear, escribir, probar y mejorar) y cinco paradigmas: imperativo
y estructurado, procedimental y modular, orientado a objetos, funcional y concurrente.

- **Fuente:** Markdown con directivas, en `packages/pseudolearn_reference/route/`. Se compila con el mismo compilador
  que la Especificación ilustrada, como un segundo libro.
- **Verificación:** cada programa se ejecuta con el motor real; cada ejercicio se verifica según su tipo; un grafo de
  términos impide usar un concepto antes de explicarlo.
- **Publicación:** un paquete de datos neutral en `apps/pseudolearn_app/assets/route/`, que la app pinta reutilizando
  los bloques del lector de la Especificación.
- **App:** nueva sección «Ruta de aprendizaje» con lector de lecciones, diez tipos de ejercicio y progreso por lección.

---

## 3. Mapa de la ruta

| N.º | Id | Título | Problema | Archivo |
|---|---|---|---|---|
| 0.1 | `inicio.primer-problema` | Tu primer problema | ¿Cuántas pizzas pedir? | [10](10-unidad-0.md) |
| 0.2 | `inicio.nombres` | Darle nombre a los datos | Los invitados cambian cada día | [10](10-unidad-0.md) |
| 0.3 | `inicio.preguntar` | Preguntar antes de calcular | La calculadora de propinas | [10](10-unidad-0.md) |
| 0.4 | `inicio.errores` | Cuando algo sale mal | Los tres programas del compañero | [10](10-unidad-0.md) |
| 1.1 | `imperativo.decidir` | Decidir | La entrada al cine | [11](11-parte-1.md) |
| 1.2 | `imperativo.caminos` | Muchos caminos | ¿Es bisiesto? | [11](11-parte-1.md) |
| 1.3 | `imperativo.mientras` | Repetir mientras haga falta | La alcancía de Lucía | [11](11-parte-1.md) |
| 1.4 | `imperativo.contado` | Repetir un número conocido de veces | ¿Es primo? | [11](11-parte-1.md) |
| 1.5 | `imperativo.arreglos` | Muchos datos con un solo nombre | Los días más calurosos | [11](11-parte-1.md) |
| 1.6 | `imperativo.esquemas` | Buscar, contar y filtrar | Olas de calor | [11](11-parte-1.md) |
| 1.7 | `imperativo.cuadriculas` | Tableros y cuadrículas | ¿Quién ganó el tres en raya? | [11](11-parte-1.md) |
| 1.8 | `imperativo.estrategias` | Más de una manera | Adivina el número | [11](11-parte-1.md) |
| P·I | `imperativo.proyecto` | Proyecto: la caja del kiosco | Ticket, descuento y lo más vendido | [11](11-parte-1.md) |
| 2.1 | `procedimental.dividir` | Dividir el problema | El boletín de notas | [12](12-parte-2.md) |
| 2.2 | `procedimental.ambito` | Lo que cada parte ve | El saldo que no se duplica | [12](12-parte-2.md) |
| 2.3 | `procedimental.puras` | Funciones que no tocan nada | El precio que no se puede probar | [12](12-parte-2.md) |
| 2.4 | `procedimental.recursion` | Problemas que se contienen a sí mismos | La torre de Hanói | [12](12-parte-2.md) |
| 2.5 | `procedimental.datos` | Darle forma a los datos | La agenda del curso | [12](12-parte-2.md) |
| 2.6 | `procedimental.fallos` | Cuando algo puede fallar | La inscripción con datos raros | [12](12-parte-2.md) |
| 2.7 | `procedimental.modulos` | Programas grandes | El kiosco no cabe en un archivo | [12](12-parte-2.md) |
| P·II | `procedimental.proyecto` | Proyecto: el kiosco en partes | Pedidos con productos inválidos | [12](12-parte-2.md) |
| 3.1 | `objetos.cosas` | Cosas que saben y hacen | La máquina expendedora | [13](13-parte-3.md) |
| 3.2 | `objetos.invariantes` | Proteger lo que debe ser cierto | La tarjeta del comedor en negativo | [13](13-parte-3.md) |
| 3.3 | `objetos.identidad` | Dos nombres, un objeto | La copia que no era copia | [13](13-parte-3.md) |
| 3.4 | `objetos.contratos` | Contratos | Efectivo, tarjeta o vale | [13](13-parte-3.md) |
| 3.5 | `objetos.componer` | Heredar o componer | Productos que vencen y productos en oferta | [13](13-parte-3.md) |
| 3.6 | `objetos.responsabilidades` | ¿A quién le toca? | La clase que hace todo | [13](13-parte-3.md) |
| P·III | `objetos.proyecto` | Proyecto: el kiosco con objetos | Inventario que nunca queda negativo | [13](13-parte-3.md) |
| 4.1 | `funcional.sin-cambiar` | Calcular sin cambiar nada | El ticket que no coincide | [14](14-parte-4.md) |
| 4.2 | `funcional.orden-superior` | Funciones que reciben funciones | Tres bucles casi iguales | [14](14-parte-4.md) |
| 4.3 | `funcional.clausuras` | Funciones que recuerdan | Descuentos configurables | [14](14-parte-4.md) |
| 4.4 | `funcional.tipos-dominio` | Datos que no pueden estar mal | El pedido entregado sin hora | [14](14-parte-4.md) |
| 4.5 | `funcional.cara-a-cara` | Cara a cara | El kiosco en tres paradigmas | [14](14-parte-4.md) |
| P·IV | `funcional.proyecto` | Proyecto: el kiosco funcional | Reportes de ventas sin estado | [14](14-parte-4.md) |
| 5.1 | `concurrente.tareas` | Varias cosas a la vez | Tres cocineros, una cocina | [15](15-parte-5-y-6.md) |
| 5.2 | `concurrente.canales` | Pasarse mensajes | La cocina y el mostrador | [15](15-parte-5-y-6.md) |
| 5.3 | `concurrente.elegir` | Lo primero que llegue | Dos proveedores | [15](15-parte-5-y-6.md) |
| 6.1 | `exterior.archivos` | Guardar para mañana | El inventario que se borra | [15](15-parte-5-y-6.md) |
| 6.2 | `exterior.json` | Datos que se entienden entre programas | Exportar el inventario | [15](15-parte-5-y-6.md) |
| 6.3 | `exterior.http` | Hablar con internet | El tipo de cambio del día | [15](15-parte-5-y-6.md) |
| P·F | `exterior.proyecto` | Proyecto final: el kiosco completo | Todo junto | [15](15-parte-5-y-6.md) |

---

## 4. Glosario de este plan

| Término | Significado aquí |
|---|---|
| Libro | Conjunto de contenido que el compilador publica como un paquete: `especificacion` (existente) y `ruta` (nuevo) |
| Lección | Una unidad de la ruta, un archivo fuente, una pantalla en la app |
| Ficha de lección | La descripción de una lección en este plan (archivos `1x-*.md`) |
| Término | Concepto que una lección introduce y del que es dueña (`04-terminos-maquina-figuras.md` §1) |
| Pieza | Una de las siete partes de la máquina nocional (`04-terminos-maquina-figuras.md` §2) |
| Tarjeta de recuerdo | Bloque «Recuerda» generado desde la lección dueña de un término |
| Ejemplo a mano | Caso resuelto con lápiz y papel en la fase Entender |
| Problema hilo | El kiosco de la escuela, que reaparece en cada proyecto y en las aperturas de paradigma |
