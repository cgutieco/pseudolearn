---
id: objetos.identidad.dos-tarjetas
leccion: objetos.identidad
tipo: resolver
nivel: brote
obligatorio: true
titulo: Dos tarjetas con el mismo saldo
---

::: enunciado
Lee un saldo inicial y crea dos tarjetas del comedor con ese saldo. Cóbrale 5 pesos a la primera y muestra los dos saldos, separados por un espacio. Si a la primera no le alcanza, no se cobra nada.
:::

::: restriccion
Usa la clase `Tarjeta` de la lección anterior, con su saldo privado.
:::

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

Algoritmo DosTarjetas
  Definir inicial Como Entero;
  Leer inicial;
  Definir primera Como Tarjeta <- Nuevo Tarjeta(inicial);
  Definir segunda Como Tarjeta <- Nuevo Tarjeta(inicial);
  Definir cobrado Como Logico <- primera.Cobrar(5);
  Escribir primera.Saldo(), " ", segunda.Saldo();
FinAlgoritmo
```

```casos
visible | 20 | 15 20
visible | 10 | 5 10
oculto | 5 | 0 5
oculto | 3 | 3 3
oculto | 0 | 0 0
```

::: pistas
1. ¿Cuántas tarjetas tiene que haber al final? ¿Cuántas veces hay que crear una?
2. Repasa el alias de [la lección](ruta:objetos.identidad): asignar no crea una tarjeta nueva.
3. Crea cada tarjeta con su propio `Nuevo`.
4. Dos `Nuevo Tarjeta(inicial)`, un `Cobrar(5)` a la primera y los dos `Saldo()`. Cierra con la variante.
:::

::: variante
Haz que la segunda tarjeta sea un alias de la primera. ¿Qué muestra ahora con 20?
:::

::: docentes
Error frecuente: crear una tarjeta y asignarla a las dos variables, que muestra 15 15. Casos ocultos: cobrar justo el saldo, un saldo que no alcanza y uno vacío.
:::
