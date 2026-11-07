---
id: procedimental.modulos.ciclo
leccion: procedimental.modulos
tipo: explicar
nivel: brote
obligatorio: false
titulo: Dos archivos que se necesitan
---

::: enunciado
El archivo de ventas importa al de tickets, y el de tickets importa al de ventas. ¿Qué problema hay?
:::

```opciones
- [x] Ninguno se entiende ni se prueba sin el otro: hay una dependencia circular. | Para probar las ventas hacen falta los tickets, y para probar los tickets, las ventas.
- [ ] Ninguno: importar no ejecuta nada. | Es cierto que importar no ejecuta nada, pero el ciclo ata los dos archivos para siempre.
- [ ] El programa va a ser más lento. | El problema no es la velocidad, sino que los dos archivos ya no se pueden separar.
```

::: explicacion
Las dependencias tienen que ir en un solo sentido. Si dos archivos se necesitan mutuamente, lo que comparten suele merecer un tercer archivo del que dependan los dos.
:::
