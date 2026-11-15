---
id: inicio.nombres.figuritas
leccion: inicio.nombres
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: Intercambiar figuritas
---

::: enunciado
Ana tiene 12 figuritas y Beto tiene 7. Quieren intercambiar sus montones: Ana se queda con los de Beto y Beto con los de Ana. El programa de un compañero muestra que los dos terminan con 7. Corrígelo para que muestre `Ana: 7 Beto: 12`.
:::

```programa rol=inicial
Algoritmo Figuritas
  Definir ana Como Entero <- 12;
  Definir beto Como Entero <- 7;
  ana <- beto;
  beto <- ana;
  Escribir "Ana: ", ana, " Beto: ", beto;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Figuritas
  Definir ana Como Entero <- 12;
  Definir beto Como Entero <- 7;
  Definir guardado Como Entero <- ana;
  ana <- beto;
  beto <- guardado;
  Escribir "Ana: ", ana, " Beto: ", beto;
FinAlgoritmo
```

```casos
visible | — | Ana: 7 Beto: 12
```

::: pistas
1. Dibuja las dos cajas y ejecuta a mano cada línea. ¿Qué valor tiene `ana` justo después de la primera asignación?
2. Cuando asignas, el valor viejo se pierde. Repasa la figura del intercambio en [la Especificación](especificacion:declaraciones.asignacion).
3. Antes de pisar las figuritas de Ana, guárdalas en una tercera caja.
4. Declara `guardado` con el valor de `ana`, después `ana <- beto;` y `beto <- guardado;`. Cierra con la variante.
:::

::: variante
Ahora también juega Carla, con 3 figuritas. Haz que Ana reciba las de Beto, Beto las de Carla y Carla las de Ana. (Respuesta: `Ana: 7 Beto: 3 Carla: 12`.)
:::

::: explicacion
La primera asignación pisa el 12 antes de copiarlo. La solución usa una caja auxiliar. Error frecuente: invertir las dos líneas, que deja a los dos con 12.
:::
