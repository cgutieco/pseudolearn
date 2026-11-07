---
id: objetos.cosas.cronometro-objeto
leccion: objetos.cosas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El cronómetro como objeto
---

::: enunciado
Lee dos cantidades de segundos, avanza un cronómetro con cada una y muéstralo con el formato `1 h 2 min 5 s`.
:::

::: restriccion
Una clase `Cronometro` con un método `Avanzar(segundos)` y otro `Lectura()` que retorna el texto.
:::

```programa rol=referencia
Clase Cronometro
  Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Avanzar(segundos Como Entero)
    Este.total <- Este.total + segundos;
  FinMetodo

  Metodo Lectura() Como Cadena
    Definir horas Como Entero <- Este.total div 3600;
    Definir minutos Como Entero <- Este.total mod 3600 div 60;
    Retornar ConvertirATexto(horas) + " h " + ConvertirATexto(minutos) + " min " + ConvertirATexto(Este.total mod 60) + " s";
  FinMetodo
FinClase

Algoritmo Carrera
  Definir reloj Como Cronometro <- Nuevo Cronometro();
  Definir segundos Como Entero;
  Leer segundos;
  reloj.Avanzar(segundos);
  Leer segundos;
  reloj.Avanzar(segundos);
  Escribir reloj.Lectura();
FinAlgoritmo
```

```casos
visible | 3600 ; 125 | 1 h 2 min 5 s
visible | 30 ; 30 | 0 h 1 min 0 s
oculto | 0 ; 0 | 0 h 0 min 0 s
oculto | 59 ; 0 | 0 h 0 min 59 s
oculto | 3600 ; 0 | 1 h 0 min 0 s
oculto | 86399 ; 0 | 23 h 59 min 59 s
```

```aserciones
- declara-miembro | Cronometro | Avanzar | publico | Falta el método público Avanzar en la clase Cronometro.
- declara-miembro | Cronometro | Lectura | publico | Falta el método público Lectura en la clase Cronometro.
```

::: pistas
1. ¿Qué tiene que recordar el cronómetro entre una llamada y otra?
2. El formato es el del cronómetro de [la lección 0.2](ruta:inicio.nombres); el estado se guarda como el contador de [la lección](ruta:objetos.cosas).
3. Un atributo con el total de segundos; `Avanzar` suma; `Lectura` reparte en horas, minutos y segundos.
4. `Lectura` arma el texto con `ConvertirATexto` y concatenación. Cierra con la variante.
:::

::: variante
Agrega `Reiniciar()`, que vuelve el cronómetro a 0.
:::

::: docentes
Casos ocultos: el cronómetro sin avanzar, justo antes del minuto, una hora exacta y el último segundo del día.
:::
