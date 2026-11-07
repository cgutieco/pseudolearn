---
id: procedimental.modulos.publico-privado
leccion: procedimental.modulos
tipo: clasificar
nivel: brote
obligatorio: true
titulo: ¿Para afuera o para adentro?
---

::: enunciado
Estas son piezas del archivo de ventas. Ubica cada uno según tenga que poder usarse desde otros archivos o no.
:::

```categorias
- Público
- Privado
```

```elementos
- `Vender`, que usa el algoritmo principal. | Público
- `ConDescuento`, que usan las ventas y los tickets. | Público
- `RedondearCentavos`, un auxiliar de `ConDescuento`. | Privado
- `ValidarCodigo`, un auxiliar de `Vender`. | Privado
```

::: explicacion
Lo que otros archivos necesitan va público; los auxiliares quedan privados, para poder cambiarlos sin romper a nadie.
:::
