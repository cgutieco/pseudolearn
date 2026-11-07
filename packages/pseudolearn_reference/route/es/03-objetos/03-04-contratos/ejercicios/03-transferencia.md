---
id: objetos.contratos.transferencia
leccion: objetos.contratos
tipo: modificar
nivel: brote
obligatorio: true
titulo: Un medio de pago nuevo
---

::: enunciado
El programa lee un medio de pago (1 efectivo, 2 tarjeta, 3 vale de 15) y un monto, y muestra lo que se cobra. Agrega el medio 4, la transferencia, que no tiene recargo pero cuesta 1 peso fijo, sin cambiar `CobrarCon`.
:::

::: restriccion
`CobrarCon` no cambia y el programa no usa `Segun`: el medio nuevo es una clase que cumple el contrato.
:::

```programa rol=inicial
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

Algoritmo Caja
  Definir medio, monto Como Entero;
  Leer medio;
  Leer monto;
  Si medio = 1 Entonces
    Escribir CobrarCon(Nuevo Efectivo(), monto);
  Sino
    Si medio = 2 Entonces
      Escribir CobrarCon(Nuevo Tarjeta(), monto);
    Sino
      Escribir CobrarCon(Nuevo Vale(15), monto);
    FinSi
  FinSi
FinAlgoritmo
```

```programa rol=referencia
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

Clase Transferencia Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto + 1;
  FinMetodo
FinClase

Algoritmo Caja
  Definir medio, monto Como Entero;
  Leer medio;
  Leer monto;
  Si medio = 1 Entonces
    Escribir CobrarCon(Nuevo Efectivo(), monto);
  Sino
    Si medio = 2 Entonces
      Escribir CobrarCon(Nuevo Tarjeta(), monto);
    Sino
      Si medio = 3 Entonces
        Escribir CobrarCon(Nuevo Vale(15), monto);
      Sino
        Escribir CobrarCon(Nuevo Transferencia(), monto);
      FinSi
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | 1 ; 20 | 20
visible | 4 ; 20 | 21
oculto | 2 ; 100 | 105
oculto | 3 ; 20 | 15
oculto | 4 ; 0 | 1
oculto | 4 ; 99 | 100
```

```aserciones
- no-contiene | seleccion-multiple | El medio nuevo se agrega con una clase, sin `Segun`.
```

::: pistas
1. ¿Qué parte del programa sabe cómo se cobra con cada medio?
2. Mira cómo están escritos `Efectivo`, `Tarjeta` y `Vale` en [la lección](ruta:objetos.contratos).
3. Hace falta una clase nueva que realice `MedioDePago`, y un caso más en la elección del principal.
4. `Clase Transferencia Realiza MedioDePago` con `Cobrar` que retorna `monto + 1`, y el principal la usa con el código 4. Cierra con la variante.
:::

::: variante
Agrega un quinto medio, los puntos del kiosco, que cobran el doble del monto. ¿Qué líneas cambiaste?
:::

::: docentes
El inicial no conoce el medio 4 y cobra como vale. La referencia agrega una clase y un caso en el principal; `CobrarCon` queda igual. La aserción impide resolverlo con un `Segun`.
:::
