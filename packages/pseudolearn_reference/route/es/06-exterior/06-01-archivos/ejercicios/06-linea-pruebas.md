---
id: exterior.archivos.linea-pruebas
leccion: exterior.archivos
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: Las pruebas de la línea
---

::: enunciado
No escribas código. Escribe entre dos y cuatro líneas para el ejercicio de leer una línea, con la respuesta correcta de cada una, de modo que cualquier versión equivocada falle al menos una.
:::

```programa rol=referencia
Funcion mensaje <- StockDeLinea(linea Como Cadena)
  Definir mensaje Como Cadena;
  Segun PosicionDe(linea, ";") Hacer
    Algo(corte):
      mensaje <- Subcadena(linea, 0, corte - 1) + " tiene " + Subcadena(linea, corte + 1, Longitud(linea) - 1);
    Nada: mensaje <- "Línea inválida";
  FinSegun
FinFuncion

Algoritmo LeerLinea
  Definir linea Como Cadena;
  Leer linea;
  Escribir StockDeLinea(linea);
FinAlgoritmo
```

```programa rol=mutante id=sin-revisar
Funcion mensaje <- StockDeLinea(linea Como Cadena)
  Definir mensaje Como Cadena;
  Segun PosicionDe(linea, ";") Hacer
    Algo(corte):
      mensaje <- Subcadena(linea, 0, corte - 1) + " tiene " + Subcadena(linea, corte + 1, Longitud(linea) - 1);
    Nada: mensaje <- linea + " tiene ";
  FinSegun
FinFuncion

Algoritmo LeerLinea
  Definir linea Como Cadena;
  Leer linea;
  Escribir StockDeLinea(linea);
FinAlgoritmo
```

```programa rol=mutante id=ultimo-corte
Funcion mensaje <- StockDeLinea(linea Como Cadena)
  Definir mensaje Como Cadena;
  Definir corte Como Entero <- -1;
  Para posicion <- 0 Hasta Longitud(linea) - 1 Hacer
    Si Subcadena(linea, posicion, posicion) = ";" Entonces
      corte <- posicion;
    FinSi
  FinPara
  Si corte = -1 Entonces
    mensaje <- "Línea inválida";
  Sino
    mensaje <- Subcadena(linea, 0, corte - 1) + " tiene " + Subcadena(linea, corte + 1, Longitud(linea) - 1);
  FinSi
FinFuncion

Algoritmo LeerLinea
  Definir linea Como Cadena;
  Leer linea;
  Escribir StockDeLinea(linea);
FinAlgoritmo
```

```programa rol=mutante id=sin-stock
Funcion mensaje <- StockDeLinea(linea Como Cadena)
  Definir mensaje Como Cadena;
  Segun PosicionDe(linea, ";") Hacer
    Algo(corte):
      mensaje <- Subcadena(linea, 0, corte - 1) + " tiene ";
    Nada: mensaje <- "Línea inválida";
  FinSegun
FinFuncion

Algoritmo LeerLinea
  Definir linea Como Cadena;
  Leer linea;
  Escribir StockDeLinea(linea);
FinAlgoritmo
```

```casos
visible | jugo;10 | jugo tiene 10
```

```casos-solucion minimo=2 maximo=4
jugo;10 | jugo tiene 10
agua | Línea inválida
x;y;3 | x tiene y;3
```

::: pistas
1. Piensa errores posibles: no revisar si hay punto y coma, cortar en otro lugar, olvidar una parte.
2. Hace falta una línea sin punto y coma.
3. Hace falta una línea con dos puntos y coma.
4. «jugo;10», «agua» y «x;y;3» descubren a las tres versiones equivocadas. Cierra con la variante.
:::

::: variante
¿Cuál de tus líneas podrías quitar sin dejar escapar ninguna versión equivocada?
:::

::: explicacion
Versiones equivocadas: no revisa el punto y coma, corta en el último y muestra el nombre sin el stock. Sin una línea de dos puntos y coma, la segunda sobrevive.
:::
