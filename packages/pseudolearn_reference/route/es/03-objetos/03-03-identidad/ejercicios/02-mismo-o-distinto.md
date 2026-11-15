---
id: objetos.identidad.mismo-o-distinto
leccion: objetos.identidad
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: ¿El mismo o distintos?
---

::: enunciado
Al final de este programa, ¿cada par de nombres apunta al mismo `Contador` o a dos distintos?

```programa id=pares titulo="Cuatro contadores… o menos"
Clase Contador
  Definir valor Como Entero;

  Metodo Constructor()
    Este.valor <- 0;
  FinMetodo

  Metodo Incrementar()
    Este.valor <- Este.valor + 1;
  FinMetodo

  Metodo Actual() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Pares
  Definir a Como Contador <- Nuevo Contador();
  Definir b Como Contador <- a;
  Definir c Como Contador <- Nuevo Contador();
  Definir d Como Contador <- Copiar(c);
  Definir e Como Contador <- b;
FinAlgoritmo
```
:::

```categorias
- El mismo contador
- Contadores distintos
```

```elementos
- `a` y `b` | El mismo contador
- `a` y `e` | El mismo contador
- `a` y `c` | Contadores distintos
- `c` y `d` | Contadores distintos
```

::: explicacion
Asignar copia la flecha: `b` y `e` terminan apuntando al contador de `a`. `Nuevo` y `Copiar` crean contadores nuevos.
:::
