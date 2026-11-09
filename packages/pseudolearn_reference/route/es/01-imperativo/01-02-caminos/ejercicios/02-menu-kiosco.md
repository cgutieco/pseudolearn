---
id: imperativo.caminos.menu-kiosco
leccion: imperativo.caminos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: El menú del kiosco
---

::: enunciado
Lee un código de producto del kiosco y muestra su nombre y su precio: 1 es `Jugo 3`, 2 es `Sándwich 5`, 3 es `Alfajor 2`, 4 es `Agua 1` y 5 es `Fruta 2`. Para cualquier otro código, muestra «No existe».
:::

```programa rol=referencia
Algoritmo Menu
  Definir codigo Como Entero;
  Leer codigo;
  Segun codigo Hacer
    1:
      Escribir "Jugo 3";
    2:
      Escribir "Sándwich 5";
    3:
      Escribir "Alfajor 2";
    4:
      Escribir "Agua 1";
    5:
      Escribir "Fruta 2";
    De Otro Modo:
      Escribir "No existe";
  FinSegun
FinAlgoritmo
```

```casos
visible | 1 | Jugo 3
visible | 9 | No existe
oculto | 2 | Sándwich 5
oculto | 5 | Fruta 2
oculto | 0 | No existe
```

::: pistas
1. ¿Cuántos caminos hay? ¿De qué dato depende cuál se toma?
2. Cuando un solo dato elige entre muchos valores, hay una herramienta que lo dice mejor que una escalera de preguntas. Está en [la lección](ruta:imperativo.caminos).
3. No olvides el camino para los códigos que no existen.
4. `Segun codigo Hacer` con una opción por código y `De Otro Modo:` para `No existe`. Cierra con la variante.
:::

::: variante
Los códigos 4 y 5 pasan a costar lo mismo. ¿Puedes juntarlos en una sola opción? (Sí: `4, 5:` si muestran el mismo texto.)
:::

::: explicacion
Los casos ocultos prueban los extremos de la lista y el 0. Error frecuente: olvidar el camino de los códigos inexistentes, que deja al programa sin mostrar nada.
:::
