---
id: procedimental.ambito.quien-existe
leccion: procedimental.ambito
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Who exists here?
---

::: enunciado
In this program, the line that returns `base * 2` is inside `Double`. Place each name according to whether it exists on that line.

```programa id=ambitos titulo="Two subprograms"
SubProceso Double(base Como Entero) Como Entero
  Retornar base * 2;
FinSubProceso

SubProceso Triple(valor Como Entero) Como Entero
  Definir computed Como Entero <- valor * 3;
  Retornar computed;
FinSubProceso

Algoritmo Main
  Definir total Como Entero <- Double(4) + Triple(5);
  Escribir total;
FinAlgoritmo
```
:::

```categorias
- Exists on that line
- Does not exist on that line
```

```elementos
- `base` | Exists on that line
- `valor` | Does not exist on that line
- `computed` | Does not exist on that line
- `total` | Does not exist on that line
```

::: explicacion
Inside `Double` only its parameter `base` exists. `valor` and `computed` belong to `Triple`, and `total` belongs to the main algorithm: they cannot be seen from `Double`.
:::
