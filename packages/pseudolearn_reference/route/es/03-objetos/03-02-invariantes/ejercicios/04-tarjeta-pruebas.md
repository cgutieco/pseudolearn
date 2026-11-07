---
id: objetos.invariantes.tarjeta-pruebas
leccion: objetos.invariantes
tipo: disenar-pruebas
nivel: brote
obligatorio: true
titulo: Las pruebas de la tarjeta
---

::: enunciado
Un programa lee el saldo inicial, un monto a cobrar y un monto a cargar, y muestra el resultado de cobrar, el de cargar y el saldo final. Escribe entre 3 y 4 casos de prueba de modo que cualquier versión equivocada de la tarjeta falle al menos uno.
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

Algoritmo Pruebas
  Definir inicial, cobro, carga Como Entero;
  Leer inicial;
  Leer cobro;
  Leer carga;
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta(inicial);
  Escribir tarjeta.Cobrar(cobro), " ", tarjeta.Cargar(carga), " ", tarjeta.Saldo();
FinAlgoritmo
```

```programa rol=mutante id=sin-cobro-justo
Clase Tarjeta
  Privado Definir saldo Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.saldo <- 0;
    Si inicial > 0 Entonces
      Este.saldo <- inicial;
    FinSi
  FinMetodo

  Metodo Cobrar(monto Como Entero) Como Logico
    Si monto <= 0 O monto >= Este.saldo Entonces
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

Algoritmo Pruebas
  Definir inicial, cobro, carga Como Entero;
  Leer inicial;
  Leer cobro;
  Leer carga;
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta(inicial);
  Escribir tarjeta.Cobrar(cobro), " ", tarjeta.Cargar(carga), " ", tarjeta.Saldo();
FinAlgoritmo
```

```programa rol=mutante id=permite-negativo
Clase Tarjeta
  Privado Definir saldo Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.saldo <- 0;
    Si inicial > 0 Entonces
      Este.saldo <- inicial;
    FinSi
  FinMetodo

  Metodo Cobrar(monto Como Entero) Como Logico
    Si monto <= 0 Entonces
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

Algoritmo Pruebas
  Definir inicial, cobro, carga Como Entero;
  Leer inicial;
  Leer cobro;
  Leer carga;
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta(inicial);
  Escribir tarjeta.Cobrar(cobro), " ", tarjeta.Cargar(carga), " ", tarjeta.Saldo();
FinAlgoritmo
```

```programa rol=mutante id=carga-negativa
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
    Este.saldo <- Este.saldo + monto;
    Retornar Verdadero;
  FinMetodo

  Metodo Saldo() Como Entero
    Retornar Este.saldo;
  FinMetodo
FinClase

Algoritmo Pruebas
  Definir inicial, cobro, carga Como Entero;
  Leer inicial;
  Leer cobro;
  Leer carga;
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta(inicial);
  Escribir tarjeta.Cobrar(cobro), " ", tarjeta.Cargar(carga), " ", tarjeta.Saldo();
FinAlgoritmo
```

```casos
visible | 30 ; 10 ; 5 | Verdadero Verdadero 25
```

```casos-solucion minimo=3 maximo=4
30 ; 30 ; 10 | Verdadero Verdadero 10
30 ; 31 ; 10 | Falso Verdadero 40
30 ; 5 ; -5 | Verdadero Falso 25
```

::: pistas
1. Escribe el invariante de la tarjeta. ¿En qué bordes se puede romper?
2. Repasa la tabla de casos de [la lección](ruta:objetos.invariantes).
3. Hace falta un cobro justo del saldo, un cobro de uno más y una carga negativa.
4. 30, 30 y 10; 30, 31 y 10; 30, 5 y -5, con sus respuestas. Cierra con la variante.
:::

::: variante
¿Qué caso agregarías para un error que cobrara montos negativos?
:::

::: docentes
Versiones equivocadas: no deja cobrar justo el saldo, permite quedar en negativo y acepta cargas negativas. Cada caso de la solución descubre a una.
:::
