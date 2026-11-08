---
id: exterior.archivos.limpieza-lugar
leccion: exterior.archivos
tipo: explicar
nivel: brote
obligatorio: false
titulo: Dónde va la limpieza
---

::: enunciado
¿Por qué la limpieza que cierra el archivo se escribe justo después de abrirlo?
:::

```opciones
- [x] Para que no se olvide aunque el subprograma salga antes. | Se ejecuta al salir, por cualquier camino: un `Retornar` o un error que se propaga.
- [ ] Porque se ejecuta enseguida. | No se ejecuta donde se escribe: se guarda y se ejecuta al salir.
- [ ] Porque así el programa es más rápido. | No cambia la velocidad; cambia que el cierre no dependa de llegar al final.
```

::: explicacion
Escribir la limpieza junto a lo que la necesita evita olvidarla: cualquier salida del subprograma la ejecuta.
:::
