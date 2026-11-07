---
id: procedimental.ambito.retorno-o-referencia
leccion: procedimental.ambito
tipo: comparar
nivel: brote
obligatorio: false
titulo: ¿Cómo devolver el doble?
---

::: enunciado
Hay que escribir una pieza que calcule el doble de un precio. ¿Cómo conviene que devuelva el resultado?
:::

```opciones
- [x] Retornar el doble, y que quien llama lo guarde. | Quien lee `precio <- Doble(precio);` ve que el precio cambia.
- [ ] Recibir el precio por referencia y cambiarlo adentro. | Funciona, pero la llamada `Doble(precio);` esconde que el precio cambia.
- [ ] Mostrar el doble con `Escribir` dentro de la pieza. | Así no se puede usar el resultado en otra cuenta.
```

::: explicacion
Con un solo resultado, retornar deja el cambio a la vista de quien lee el programa. Prestar la caja conviene cuando hay que devolver más de un valor.
:::
