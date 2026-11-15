---
id: objetos.componer.cuando-heredar
leccion: objetos.componer
tipo: explicar
nivel: brote
obligatorio: false
titulo: ¿Cuándo conviene heredar?
---

::: enunciado
¿Cuándo es buena idea escribir un tipo de cosa como caso particular de otro, con `Hereda De`?
:::

```opciones
- [x] Cuando la hija es un caso particular de la madre y no hay rasgos que se combinen. | Un cajero es un empleado; si no hay combinaciones, la jerarquía no explota.
- [ ] Siempre que dos clases compartan código. | Compartir código no alcanza: si la hija no es un caso particular, conviene componer.
- [ ] Cuando un objeto tiene a otro adentro. | Eso es componer: un producto tiene una oferta.
```

::: explicacion
Heredar dice qué es algo, y funciona bien con casos particulares estables. Cuando los rasgos se combinan, los casos particulares se multiplican y componer escala mejor.
:::
