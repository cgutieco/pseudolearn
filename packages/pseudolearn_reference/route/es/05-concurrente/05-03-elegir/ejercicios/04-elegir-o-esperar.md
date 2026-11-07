---
id: concurrente.elegir.elegir-o-esperar
leccion: concurrente.elegir
tipo: comparar
nivel: brote
obligatorio: true
titulo: ¿Quién atiende antes?
---

::: enunciado
Dos panaderías mandan su oferta de pan, y solo importa la primera. Ana espera las dos ofertas, una tras otra; Beto atiende la que llegue primero. ¿Quién atiende antes?
:::

```opciones
- [x] Beto: atiende la primera lista sin esperar la otra. | Con una sola respuesta que importa, esperar a la que llega después solo agrega espera.
- [ ] Ana: esperar las dos es más seguro. | Ana termina igual con la primera oferta, pero recién después de que llegaron las dos.
- [ ] Los dos al mismo tiempo. | Solo si las dos ofertas llegan juntas; en cualquier otro caso Ana espera de más.
```

::: explicacion
Es la diferencia entre aguardar una tarea tras otra y usar `Elegir`: la segunda forma atiende la primera respuesta lista.
:::
