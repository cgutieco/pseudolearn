# Tipos primitivos

El lenguaje tiene cinco tipos primitivos. Todo valor pertenece a uno y solo a uno de ellos, y el
tipo de una variable no cambia mientras el programa se ejecuta.

{{tabla:primitiveTypes}}

## Cadena y carácter son dos tipos, no uno

Un carácter es un único punto de código; una cadena es una secuencia de caracteres de longitud no
acotada. No se confunden y no se convierten entre sí de forma implícita. Una cadena tampoco es un
arreglo de caracteres: son dos cosas distintas y el sistema de tipos las trata como tales.

{{ejemplo:example-esp-tipos-cadena-caracter}}

## La única conversión implícita

Un valor entero se puede usar donde se espera un real, porque esa dirección no pierde información. La
contraria no ocurre nunca sola: pasar de real a entero exige pedirlo explícitamente con una función
incorporada, porque decidir si se trunca o se redondea es una decisión de quien escribe el programa y
no del lenguaje.

{{ejemplo:example-esp-tipos-conversion-implicita}}

## Rango de los valores numéricos

Un entero es un número de sesenta y cuatro bits con signo. Un real es un número de coma flotante de
doble precisión. Salirse de esos rangos no da la vuelta en silencio: es un error de ejecución con
nombre.

{{ejemplo:example-esp-tipos-rango}}

## Comparar dos reales

Dos reales calculados por caminos distintos casi nunca son exactamente iguales, así que compararlos
con igualdad es una fuente clásica de programas que parecen correctos y no lo son. El lenguaje avisa
de esa comparación en vez de dejarla pasar.

```pseudo
Algoritmo CompararReales
  Definir a, b Como Real
  a <- 0.1 + 0.2
  b <- 0.3
  Si a = b Entonces
    Escribir "Iguales"
  FinSi
FinAlgoritmo
```

{{diagnostico:realEqualityComparison}}
