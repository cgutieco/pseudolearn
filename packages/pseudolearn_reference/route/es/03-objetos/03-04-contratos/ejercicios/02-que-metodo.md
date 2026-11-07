---
id: objetos.contratos.que-metodo
leccion: objetos.contratos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: ¿Qué método se ejecuta?
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Interfaz MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero;
FinInterfaz

Clase Efectivo Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto;
  FinMetodo
FinClase

Clase Tarjeta Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto + monto * 5 div 100;
  FinMetodo
FinClase

Clase Vale Realiza MedioDePago
  Privado Definir disponible Como Entero;

  Metodo Constructor(saldo Como Entero)
    Este.disponible <- saldo;
  FinMetodo

  Metodo Cobrar(monto Como Entero) Como Entero
    Si monto > Este.disponible Entonces
      Retornar Este.disponible;
    FinSi
    Retornar monto;
  FinMetodo
FinClase

SubProceso CobrarCon<T: MedioDePago>(medio Como T, monto Como Entero) Como Entero
  Retornar medio.Cobrar(monto);
FinSubProceso

Algoritmo Cobros
  Escribir CobrarCon(Nuevo Tarjeta(), 10);
  Escribir CobrarCon(Nuevo Efectivo(), 10);
  Escribir CobrarCon(Nuevo Vale(4), 10);
FinAlgoritmo
```

```salida
10
10
4
```

::: explicacion
La misma línea de `CobrarCon` ejecuta el `Cobrar` de la clase real que recibe. La tarjeta suma `10 * 5 div 100`, que es 0 con enteros; el efectivo cobra lo mismo; el vale de 4 no alcanza y cobra 4.
:::
