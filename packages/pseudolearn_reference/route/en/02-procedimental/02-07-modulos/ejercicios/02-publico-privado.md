---
id: procedimental.modulos.publico-privado
leccion: procedimental.modulos
tipo: clasificar
nivel: brote
obligatorio: true
titulo: For outside or for inside?
---

::: enunciado
These are pieces of the sales file. Place each one according to whether it has to be usable from other files or not.
:::

```categorias
- Public
- Private
```

```elementos
- `Vender`, used by the main algorithm. | Public
- `ConDescuento`, used by the sales and the receipts. | Public
- `RedondearCentavos`, a helper of `ConDescuento`. | Private
- `ValidarCodigo`, a helper of `Vender`. | Private
```

::: explicacion
What other files need goes public; the helpers stay private, so that they can change without breaking anyone.
:::
