---
id: objetos.invariantes.no-alcanza
leccion: objetos.invariantes
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Cuando no alcanza
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
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
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta(10);
  Escribir tarjeta.Cobrar(15);
  Escribir tarjeta.Saldo();
FinAlgoritmo
```

```salida
Falso
10
```

::: explicacion
15 es más que el saldo: `Cobrar` retorna falso y no cambia nada. El saldo sigue en 10.
:::
