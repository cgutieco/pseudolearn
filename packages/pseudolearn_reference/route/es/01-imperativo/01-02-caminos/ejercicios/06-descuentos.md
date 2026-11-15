---
id: imperativo.caminos.descuentos
leccion: imperativo.caminos
tipo: clasificar
nivel: arbol
obligatorio: false
titulo: ¿Qué descuento le toca?
---

::: enunciado
La librería tiene esta regla: un estudiante que compra 10 pesos o más tiene 10 % de descuento; quien cumple años ese día tiene 15 %; si le tocan los dos, gana el mayor. Ubica a cada cliente en su descuento.
:::

```categorias
- Sin descuento
- 10 %
- 15 %
```

```elementos
- Estudiante, compra 12, no cumple años | 10 %
- No es estudiante, compra 12, cumple años | 15 %
- Estudiante, compra 8, no cumple años | Sin descuento
- Estudiante, compra 20, cumple años | 15 %
- No es estudiante, compra 5, no cumple años | Sin descuento
```

::: explicacion
Una tabla de decisión con tres filas (estudiante, compra de 10 o más, cumpleaños) ordena los cinco casos. El cumpleaños gana siempre que aplica, porque es el mayor; el 10 % necesita las dos condiciones a la vez.
:::
