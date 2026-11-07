---
id: inicio.nombres.cronometro
leccion: inicio.nombres
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El cronómetro
---

::: enunciado
El cronómetro de la carrera marca 3725 segundos. Muéstralo como `1 h 2 min 5 s`, calculando cada número a partir de los segundos.
:::

```programa rol=inicial
Algoritmo Cronometro
  Definir segundos Como Entero <- 3725;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Cronometro
  Definir segundos Como Entero <- 3725;
  Definir horas Como Entero <- segundos div 3600;
  Definir minutos Como Entero <- segundos mod 3600 div 60;
  Escribir horas, " h ", minutos, " min ", segundos mod 60, " s";
FinAlgoritmo
```

```casos
visible | — | 1 h 2 min 5 s
```

::: pistas
1. A mano: ¿cuántos segundos tiene una hora? ¿Y un minuto? ¿Cuántas horas completas caben en 3725 segundos?
2. Es un reparto en dos etapas, como los caramelos de [la lección](ruta:inicio.nombres): primero en horas y lo que sobra, en minutos.
3. Guarda las horas y los minutos en cajas con nombre antes de mostrarlos.
4. `horas <- segundos div 3600`, `minutos <- segundos mod 3600 div 60` y los segundos son `segundos mod 60`. Cierra con la variante.
:::

::: variante
Con 90061 segundos hace falta contar también los días: `1 d 1 h 1 min 1 s`.
:::

::: docentes
Solución: en 3725 segundos cabe 1 hora y sobran 125; en 125 caben 2 minutos y sobran 5 segundos. Error frecuente: calcular los minutos como `segundos div 60`, que da 62.
:::
