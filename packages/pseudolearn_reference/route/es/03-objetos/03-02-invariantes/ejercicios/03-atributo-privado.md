---
id: objetos.invariantes.atributo-privado
leccion: objetos.invariantes
tipo: modificar
nivel: brote
obligatorio: true
titulo: El saldo, adentro
---

::: enunciado
En este programa, el saldo de la tarjeta está a la vista y el algoritmo principal lo cambia directamente. Reescribe la tarjeta para que el saldo quede protegido y el principal solo le haga pedidos, sin cambiar lo que muestra.
:::

::: restriccion
El atributo `saldo` de la clase `Tarjeta` es privado; la tarjeta ofrece métodos para crearla con su saldo, cobrar y consultar el saldo.
:::

```programa rol=inicial
Clase Tarjeta
  Definir saldo Como Entero;
FinClase

Algoritmo Comedor
  Definir inicial, monto Como Entero;
  Leer inicial;
  Leer monto;
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta();
  tarjeta.saldo <- inicial;
  Si monto > 0 Y monto <= tarjeta.saldo Entonces
    tarjeta.saldo <- tarjeta.saldo - monto;
  FinSi
  Escribir tarjeta.saldo;
FinAlgoritmo
```

```programa rol=referencia
Clase Tarjeta
  Privado Definir saldo Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.saldo <- 0;
    Si inicial > 0 Entonces
      Este.saldo <- inicial;
    FinSi
  FinMetodo

  Metodo Cobrar(monto Como Entero) Como Logico
    Si monto <= 0 O monto > Este.saldo Entonces
      Retornar Falso;
    FinSi
    Este.saldo <- Este.saldo - monto;
    Retornar Verdadero;
  FinMetodo

  Metodo Cargar(monto Como Entero) Como Logico
    Si monto <= 0 Entonces
      Retornar Falso;
    FinSi
    Este.saldo <- Este.saldo + monto;
    Retornar Verdadero;
  FinMetodo

  Metodo Saldo() Como Entero
    Retornar Este.saldo;
  FinMetodo
FinClase

Algoritmo Comedor
  Definir inicial, monto Como Entero;
  Leer inicial;
  Leer monto;
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta(inicial);
  Definir cobrado Como Logico <- tarjeta.Cobrar(monto);
  Escribir tarjeta.Saldo();
FinAlgoritmo
```

```casos
visible | 30 ; 10 | 20
visible | 30 ; 50 | 30
oculto | 30 ; 30 | 0
oculto | 0 ; 0 | 0
oculto | 100 ; 1 | 99
```

```aserciones
- declara-miembro | Tarjeta | saldo | privado | El atributo saldo de la clase Tarjeta tiene que ser privado.
```

::: pistas
1. ¿Qué líneas del principal tocan el saldo directamente? Esas tendrán que pasar a ser métodos.
2. Mira la tarjeta de [la lección](ruta:objetos.invariantes): constructor, `Cobrar` y `Saldo`.
3. Marca el atributo como privado y mueve la comprobación del cobro a un método.
4. El principal crea la tarjeta con su saldo, le pide cobrar y muestra `Saldo()`. Cierra con la variante.
:::

::: variante
Intenta, desde el principal, asignar el saldo directamente. ¿Qué dice el motor?
:::

::: explicacion
La aserción comprueba que `saldo` sea privado. Los casos son los del programa inicial: lo que se muestra no cambia, pero ahora la regla vive en la clase.
:::
