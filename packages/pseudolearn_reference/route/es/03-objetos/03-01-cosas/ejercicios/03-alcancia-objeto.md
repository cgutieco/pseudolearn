---
id: objetos.cosas.alcancia-objeto
leccion: objetos.cosas
tipo: resolver
nivel: semilla
obligatorio: true
titulo: La alcancía como objeto
---

::: enunciado
Lee depósitos de monedas hasta un 0 y muestra el total juntado. El programa muestra solo el número.
:::

::: restriccion
Una clase `Alcancia` con un método público `Depositar(monedas)` y otro `Total()`; el algoritmo principal solo lee, deposita y muestra.
:::

```programa rol=referencia
Clase Alcancia
  Definir juntado Como Entero;

  Metodo Constructor()
    Este.juntado <- 0;
  FinMetodo

  Metodo Depositar(monedas Como Entero)
    Este.juntado <- Este.juntado + monedas;
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.juntado;
  FinMetodo
FinClase

Algoritmo Ahorro
  Definir alcancia Como Alcancia <- Nuevo Alcancia();
  Definir monedas Como Entero;
  Leer monedas;
  Mientras monedas <> 0 Hacer
    alcancia.Depositar(monedas);
    Leer monedas;
  FinMientras
  Escribir alcancia.Total();
FinAlgoritmo
```

```casos
visible | 2 ; 3 ; 4 ; 0 | 9
visible | 0 | 0
oculto | 50 ; 0 | 50
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 0 | 10
oculto | 7 ; 0 | 7
```

```aserciones
- declara-miembro | Alcancia | Depositar | publico | Falta el método público Depositar en la clase Alcancia.
```

::: pistas
1. ¿Qué sabe una alcancía? ¿Qué sabe hacer?
2. Es la alcancía dictada de [la lección 1.3](ruta:imperativo.mientras), con la caja del total guardada dentro de un objeto, como el contador de [la lección](ruta:objetos.cosas).
3. Un atributo para lo juntado, que empieza en 0 en el constructor; `Depositar` suma y `Total` lo retorna.
4. El principal crea la alcancía, deposita cada dato hasta el 0 y muestra `Total()`. Cierra con la variante.
:::

::: variante
Agrega un método `Romper()` que retorna el total y deja la alcancía en 0.
:::

::: docentes
La aserción comprueba que `Depositar` exista y sea público. Error frecuente: sumar en el principal y usar la clase solo para guardar el número.
:::
