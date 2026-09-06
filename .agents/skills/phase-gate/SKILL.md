---
name: phase-gate
description: Cierre de una fase de trabajo. Usar cuando se ha terminado el trabajo de una fase y antes de informar. Cubre la comprobación obligatoria antes de declarar la fase cerrada, el formato del informe, y la regla de parar y esperar confirmación explícita antes de la fase siguiente.
---

# Cierre de fase

## La regla que más se incumple

**Terminar de describir una fase no es luz verde para la siguiente.** Al cerrar una fase se para y se
espera confirmación explícita en un mensaje nuevo, aunque técnicamente haya contexto y capacidad para
seguir. Tener la capacidad de continuar no es tener la autorización.

Si crees que un orden distinto sería mejor, proponelo y justificalo **antes** de empezar la fase, no a
mitad de camino y nunca en silencio.

## Comprobación antes de declarar la fase cerrada

En este orden. Si algo falla, la fase no está cerrada: no se informa como cerrada con una nota al pie.

1. **Tests en verde.** Todos, no solo los de la fase.
2. **Análisis estático en verde**, con los umbrales estrictos del paquete.
3. **Test de arquitectura en verde.**
4. **Script de límites en verde.**
5. **Camino feliz e infeliz** cubiertos para cada pieza nueva, más los casos límite explícitos:
   entradas vacías, colecciones de tamaño cero, recursión profunda, bordes numéricos, identificadores
   de un carácter, programas vacíos.
6. **Ninguna excepción sin control** cruza la frontera pública del paquete.
7. **Documentación al día.** Toda decisión de diseño de la fase está en el `README.md` del paquete, y
   toda construcción nueva del lenguaje está en la especificación. Si esto quedó pendiente, la fase no
   está terminada: el código quedó sin la mitad de su información.
8. **Ningún literal de texto para personas** fuera de la capa que tiene esa responsabilidad.

## Formato del informe

Cuatro apartados, sin relleno:

**Qué se construyó.** Los archivos y qué responsabilidad tiene cada uno. Breve.

**Resultado de los tests.** Cuántos pasan, y **la salida real si algo falla**. No se informa «en verde»
sin haberlo ejecutado, y no se omite un fallo. Si algo quedó fuera, se dice qué y por qué.

**Resultado de los verificadores.** Uno por uno, con su resultado.

**Decisiones que conviene conocer o cuestionar.** La parte más valiosa del informe. Incluye:

- Lo que se decidió sin que estuviera dictado, y con qué criterio.
- Lo que se descartó y por qué, si alguien podría razonablemente esperar lo contrario.
- Las ambigüedades que aparecieron y cómo se resolvieron.
- Lo que quedó anotado como riesgo a medir más adelante.

Después de los cuatro apartados: **parar.** Sin proponer empezar lo siguiente en el mismo mensaje, y
sin dejar trabajo a medias esperando que alguien diga que siga.

## Qué hacer si aparece algo fuera de alcance

Si a mitad de la fase resulta que algo requeriría tocar material que está declarado fuera de alcance:
**parar y decirlo**, no implementarlo porque parezca trivial. Una construcción fuera de alcance que
«ya estaba ahí» es la forma habitual en la que el alcance se dobla sin que nadie lo decida.

Lo mismo con los conflictos: si una instrucción de la conversación choca con las reglas del repositorio,
o dos documentos se contradicen, se reporta. No se elige en silencio.
