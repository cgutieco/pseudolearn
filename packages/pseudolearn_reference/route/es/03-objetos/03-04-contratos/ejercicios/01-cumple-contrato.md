---
id: objetos.contratos.cumple-contrato
leccion: objetos.contratos
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: ¿Cumple el contrato?
---

::: enunciado
El contrato `MedioDePago` pide `Cobrar(monto Como Entero) Como Entero`. Ubica cada una de estas cuatro candidatas según cumpla el contrato o no.

```programa id=cuatro-clases titulo="Cuatro candidatas"
Clase Efectivo Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto;
  FinMetodo
FinClase

Clase Cupon
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto - 2;
  FinMetodo
FinClase

Clase Cheque Realiza MedioDePago
  Metodo Pagar(monto Como Entero) Como Entero
    Retornar monto;
  FinMetodo
FinClase

Clase Puntos Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto * 10;
  FinMetodo
FinClase
```
:::

```categorias
- Cumple el contrato
- No cumple el contrato
```

```elementos
- `Efectivo` | Cumple el contrato
- `Puntos` | Cumple el contrato
- `Cupon` | No cumple el contrato
- `Cheque` | No cumple el contrato
```

::: explicacion
`Efectivo` y `Puntos` dicen que realizan el contrato y tienen el método con la firma exacta, aunque cobren distinto. `Cupon` tiene el método, pero no dice que realiza el contrato. `Cheque` lo dice, pero su método se llama distinto.
:::
