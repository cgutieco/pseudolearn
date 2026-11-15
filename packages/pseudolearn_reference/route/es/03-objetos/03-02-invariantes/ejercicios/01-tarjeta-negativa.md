---
id: objetos.invariantes.tarjeta-negativa
leccion: objetos.invariantes
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: La tarjeta que queda en negativo
---

::: enunciado
Este programa lee el saldo inicial de una tarjeta y un monto a cobrar, y muestra si se pudo cobrar y el saldo que queda. Con saldo 30 y un cobro de 50 deja la tarjeta en -20. Encuentra el error y corrígelo para que la tarjeta nunca quede en negativo.
:::

```programa rol=inicial
Clase Tarjeta
  Privado Definir saldo Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.saldo <- 0;
    Si inicial > 0 Entonces
      Este.saldo <- inicial;
    FinSi
  FinMetodo

  Metodo Cobrar(monto Como Entero) Como Logico
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
  Escribir tarjeta.Cobrar(monto), " ", tarjeta.Saldo();
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
  Escribir tarjeta.Cobrar(monto), " ", tarjeta.Saldo();
FinAlgoritmo
```

```casos
visible | 30 ; 10 | Verdadero 20
visible | 30 ; 50 | Falso 30
oculto | 30 ; 30 | Verdadero 0
oculto | 30 ; 31 | Falso 30
oculto | 0 ; 1 | Falso 0
oculto | 100 ; 0 | Falso 100
```

::: pistas
1. ¿Qué tiene que ser cierto siempre de una tarjeta? ¿Qué método lo rompe?
2. Compara `Cobrar` con el de la tarjeta de [la lección](ruta:objetos.invariantes).
3. Antes de restar, el método tiene que decidir si el cobro es posible; si no, retorna falso sin tocar nada.
4. Agrega al principio de `Cobrar` la comprobación de que el monto sea positivo y no supere el saldo. Cierra con la variante.
:::

::: variante
Agrega un método `Transferir(otra, monto)` que pase saldo de una tarjeta a otra sin romper el invariante en ninguna de las dos.
:::

::: explicacion
El método resta sin preguntar. Casos ocultos: cobrar justo el saldo, uno más, cobrar de una tarjeta vacía y un cobro de 0.
:::
