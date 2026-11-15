---
id: exterior.http.estado-clasificar
leccion: exterior.http
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: ¿Bien o con problemas?
---

::: enunciado
Ubica cada código que puede traer una respuesta: ¿salió bien o hubo un problema?
:::

```categorias
- Salió bien
- Hubo un problema
```

```elementos
- 200 | Salió bien
- 404 | Hubo un problema
- 503 | Hubo un problema
- 201 | Salió bien
```

::: explicacion
Los códigos del 200 al 299 dicen que la petición salió bien; 201 avisa además que se creó algo. 404 dice que lo pedido no existe y 503, que el servicio no está disponible.
:::
