---
id: procedimental.fallos.opcional-o-resultado
leccion: procedimental.fallos
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: ¿Puede faltar o puede fallar?
---

::: enunciado
Ubica cada tarea según lo que tenga que devolver: un dato que puede faltar, o un dato que puede fallar con un motivo.
:::

```categorias
- Puede faltar
- Puede fallar con motivo
```

```elementos
- Buscar un contacto que puede no estar en la agenda. | Puede faltar
- Encontrar el primer número par de una lista. | Puede faltar
- Convertir un texto en número diciendo por qué falló. | Puede fallar con motivo
- Dividir avisando si el divisor es 0. | Puede fallar con motivo
```

::: explicacion
Cuando no encontrar algo es normal y no hay nada que explicar, alcanza con un opcional: `Algo` o `Nada`. Cuando hay que decir qué salió mal, hace falta un resultado: `Exito` o `Error` con su motivo.
:::
