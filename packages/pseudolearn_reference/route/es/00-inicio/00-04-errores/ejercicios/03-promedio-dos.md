---
id: inicio.errores.promedio-dos
leccion: inicio.errores
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: El promedio de dos notas
---

::: enunciado
El programa lee dos notas y muestra su promedio. Con 7 y 8 muestra 7. Encuentra el error y corrígelo.
:::

```programa rol=inicial
Algoritmo Promedio
  Definir primera Como Entero;
  Definir segunda Como Entero;
  Leer primera;
  Leer segunda;
  Escribir (primera + segunda) div 2;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Promedio
  Definir primera Como Entero;
  Definir segunda Como Entero;
  Leer primera;
  Leer segunda;
  Escribir (primera + segunda) / 2;
FinAlgoritmo
```

```casos
visible | 7 ; 8 | 7.5
visible | 6 ; 6 | 6.0
oculto | 10 ; 9 | 9.5
oculto | 0 ; 1 | 0.5
oculto | 5 ; 8 | 6.5
```

::: pistas
1. ¿Es un error al compilar, al ejecutar o de lógica? ¿Cómo lo sabes?
2. Haz el ejemplo a mano con 7 y 8. ¿Qué parte de 7,5 se perdió?
3. Hay dos maneras de dividir. Repasa la diferencia en [la Especificación](especificacion:expresiones.division).
4. Cambia `div` por `/`: `Escribir (primera + segunda) / 2;`. Cierra con la variante.
:::

::: variante
Con 6 y 6 el programa corregido muestra `6.0`, no `6`. ¿Por qué? (Porque `/` siempre da un número con decimales.)
:::

::: explicacion
Es un error de lógica: compila, termina y muestra un número. El caso 6 y 6 es el que no lo descubre; por eso hace falta más de un caso.
:::
