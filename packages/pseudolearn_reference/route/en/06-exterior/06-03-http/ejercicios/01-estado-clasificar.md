---
id: exterior.http.estado-clasificar
leccion: exterior.http
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: Fine or with problems?
---

::: enunciado
Place each code that an answer can bring: did it go fine or was there a problem?
:::

```categorias
- It went fine
- There was a problem
```

```elementos
- 200 | It went fine
- 404 | There was a problem
- 503 | There was a problem
- 201 | It went fine
```

::: explicacion
The codes from 200 to 299 say the request went fine; 201 also warns that something was created. 404 says that what was asked for does not exist and 503, that the service is not available.
:::
