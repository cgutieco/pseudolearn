---
id: procedimental.modulos.ciclo
leccion: procedimental.modulos
tipo: explicar
nivel: brote
obligatorio: false
titulo: Two files that need each other
---

::: enunciado
The sales file imports the receipts file, and the receipts file imports the sales file. What is the problem?
:::

```opciones
- [x] Neither can be understood or tested without the other: there is a circular dependency. | To test the sales you need the receipts, and to test the receipts, the sales.
- [ ] None: importing runs nothing. | It is true that importing runs nothing, but the cycle ties both files together forever.
- [ ] The program will be slower. | The problem is not speed, but that both files can no longer be separated.
```

::: explicacion
Dependencies have to go in a single direction. If two files need each other, what they share usually deserves a third file that both depend on.
:::
