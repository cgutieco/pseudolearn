---
id: procedimental.ambito.quien-existe
leccion: procedimental.ambito
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: ¿Quién existe aquí?
---

::: enunciado
En este programa, la línea `Retornar base * 2;` está dentro de `Doble`. Ubica cada nombre según exista o no en esa línea.

```programa id=ambitos titulo="Dos subprogramas"
SubProceso Doble(base Como Entero) Como Entero
  Retornar base * 2;
FinSubProceso

SubProceso Triple(valor Como Entero) Como Entero
  Definir calculado Como Entero <- valor * 3;
  Retornar calculado;
FinSubProceso

Algoritmo Principal
  Definir total Como Entero <- Doble(4) + Triple(5);
  Escribir total;
FinAlgoritmo
```
:::

```categorias
- Existe en esa línea
- No existe en esa línea
```

```elementos
- `base` | Existe en esa línea
- `valor` | No existe en esa línea
- `calculado` | No existe en esa línea
- `total` | No existe en esa línea
```

::: explicacion
Dentro de `Doble` solo existe su parámetro `base`. `valor` y `calculado` son de `Triple`, y `total` es del principal: desde `Doble` no se ven.
:::
