# 30 — Revisión integral (RA-7)

Registro de la revisión de cierre de la ruta. Vale para la versión publicada en la rama
`feature/agregar-ruta-de-especificacion` al cerrar RA-7.

## 1. Cobertura (`reference coverage`)

| Medida | Valor |
|---|---|
| Lecciones | 41 (unidad 0, 31 lecciones de parte y 6 proyectos contando P·F) |
| Ejercicios por edición | 224 |
| Secciones de la Especificación enlazadas desde la ruta | 61 |
| Secciones sin enlazar | 44 |

Ejercicios por tipo y nivel:

| Tipo | Semilla | Brote | Árbol |
|---|---|---|---|
| predecir | 34 | 1 | — |
| rastrear | — | 3 | 1 |
| ordenar | — | 5 | 5 |
| encontrar-error | — | 11 | — |
| romperlo | — | 10 | 1 |
| diseñar pruebas | — | 2 | 5 |
| modificar | — | 8 | 2 |
| resolver | 13 | 27 | 27 |
| comparar | 3 | 9 | — |
| clasificar | 28 | 1 | 8 |
| explicar | 14 | 5 | 1 |

Las secciones sin enlazar son, en su mayoría, de lectura de la propia Especificación (`lectura.*`), léxico
(`lexico.*`), motor (`motor.*`), visión general (`vision.*`) y apéndices (`apendice.*`): explican el lenguaje o la
herramienta y no tienen una lección dueña en la ruta. Quedan también sin enlazar `biblioteca.azar`,
`biblioteca.tiempo`, `biblioteca.modelo`, `tipos.bytes`, `tipos.inferencia`, `tipos.niveles`, `tipos.relaciones`,
`expresiones.potencia` y cuatro de `declaraciones.*`, que la ruta no enseña. Durante la revisión se agregó en 6.1 el
enlace a `biblioteca.texto`, que la lección usa (`PosicionDe`, `Subcadena`).

## 2. Lista de cierre por lección (03 §11)

Los puntos mecánicos los garantizan los verificadores en verde (`reference check`, `cargo xtask verify`): términos
antes de su dueña (`RUTA-TERM-ORDER`), salidas y ejercicios ejecutados con el motor (`RUTA-EXAMPLE-VERIFIED`,
`RUTA-EXERCISE-VERIFIED`), mezcla de ejercicios (`RUTA-EXERCISE-MIX`), pistas y variante (`RUTA-HINTS`), enunciados
sin receta (`RUTA-STATEMENT-NO-RECIPE`), fases (`RUTA-SCAFFOLD`), paridad `es`/`en` (`RUTA-PARITY`) y figuras de 340
de ancho (`REF-FIGURE-CONTRACT`, `REF-FIGURE-NARROW`). La puerta de la app (`route_exercise_gate_test`) comprueba
además que cada solución de referencia pasa el comprobador de la app en las cuatro ediciones.

Recorrido de los puntos de juicio en las 41 lecciones:

| Punto | Resultado |
|---|---|
| «Inténtalo» coincide con el motor | Sí en las 41: cada respuesta numérica se ejecutó al redactar. Única diferencia con el plan: 5.3, donde la cantidad de consultas cortadas depende de los turnos y la respuesta lo dice |
| La herramienta nueva enlaza a la Especificación | Sí en las lecciones con herramienta del lenguaje. 1.6, 1.8, 3.6 y 4.5 no introducen construcciones (esquemas, estrategias, responsabilidades y comparación de paradigmas) y no llevan bloque de Especificación; los proyectos tampoco |
| Fases completas | Sí: cinco fases en la unidad 0, la Parte I y los proyectos; fases 1 y 2 condensadas en las Partes II a VI |
| Caso borde en la ficha, en Probar y en los ocultos | Sí; 6.3 y los proyectos no tienen casos ocultos en la lección porque sus ejercicios comprobados los llevan |
| Ejercicios que no regalan la solución | Sí; el verificador de recetas obligó a reescribir varios enunciados de las Partes V y VI («canal», «objeto», «registro» en inglés) |
| «Siguiente» deja un problema abierto | Sí en 36. 1.8, 2.7, 3.6 y 4.5 anuncian el proyecto de su parte, que es el problema abierto. P·F cierra la ruta y remite a la Especificación |

## 3. Prueba de humo en el simulador

Se hizo en el simulador iOS disponible (iPhone 18 Pro) con la app de depuración: índice de la ruta, lecciones 0.1 y
1.3, el pie «Aprender en la ruta» de la sección 6.3 de la Especificación (abre la lección 1.3) y un ejercicio resuelto
de nueve tipos: predecir (con una respuesta incorrecta antes, que muestra la línea que no coincide), comparar, explicar,
clasificar, ordenar, rastrear (con el programa concurrente de la lección 5.2), romperlo, diseñar pruebas y encontrar el
error en el editor. Resolver y modificar comparten con encontrar el error la apertura en el editor y el comprobador por
casos; no se resolvieron a mano en el simulador y quedan cubiertos por `route_exercise_gate_test`, que ejecuta cada
solución de referencia en las cuatro ediciones. Las capturas quedaron fuera del repositorio. Las capturas de producto y el material de tiendas
no se regeneraron: son un pendiente declarado en el README de la app.
