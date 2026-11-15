---
id: procedimental.dividir.boletin-chico
leccion: procedimental.dividir
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Un boletín más chico
---

::: enunciado
Tres alumnos tienen dos notas cada uno. Lee, para cada alumno, su nombre y sus dos notas. Muestra una línea por alumno con el formato `Ana: 7.5 aprobado` (aprueba con promedio 6 o más) y al final `Mejor promedio: ` con el nombre. Si hay empate en el mejor promedio, gana el primero que se leyó.
:::

```programa rol=referencia
SubProceso Promedio(a Como Entero, b Como Entero) Como Real
  Retornar (a + b) / 2;
FinSubProceso

SubProceso Estado(promedio Como Real) Como Cadena
  Si promedio >= 6 Entonces
    Retornar "aprobado";
  FinSi
  Retornar "desaprobado";
FinSubProceso

Algoritmo Boletin
  Definir nombre Como Cadena;
  Definir n1, n2 Como Entero;
  Definir mejorNombre Como Cadena <- "";
  Definir mejorPromedio Como Real <- -1.0;
  Para i <- 1 Hasta 3 Hacer
    Leer nombre;
    Leer n1;
    Leer n2;
    Definir p Como Real <- Promedio(n1, n2);
    Escribir nombre, ": ", p, " ", Estado(p);
    Si p > mejorPromedio Entonces
      mejorPromedio <- p;
      mejorNombre <- nombre;
    FinSi
  FinPara
  Escribir "Mejor promedio: ", mejorNombre;
FinAlgoritmo
```

```casos
visible | Ana ; 7 ; 8 ; Beto ; 5 ; 4 ; Caro ; 9 ; 10 | Ana: 7.5 aprobado ⏎ Beto: 4.5 desaprobado ⏎ Caro: 9.5 aprobado ⏎ Mejor promedio: Caro
visible | Eva ; 6 ; 6 ; Fede ; 5 ; 7 ; Gabi ; 6 ; 5 | Eva: 6.0 aprobado ⏎ Fede: 6.0 aprobado ⏎ Gabi: 5.5 desaprobado ⏎ Mejor promedio: Eva
oculto | Ana ; 8 ; 8 ; Beto ; 8 ; 8 ; Caro ; 1 ; 1 | Ana: 8.0 aprobado ⏎ Beto: 8.0 aprobado ⏎ Caro: 1.0 desaprobado ⏎ Mejor promedio: Ana
oculto | Ana ; 0 ; 0 ; Beto ; 0 ; 0 ; Caro ; 0 ; 1 | Ana: 0.0 desaprobado ⏎ Beto: 0.0 desaprobado ⏎ Caro: 0.5 desaprobado ⏎ Mejor promedio: Caro
oculto | Ana ; 10 ; 10 ; Beto ; 9 ; 9 ; Caro ; 6 ; 5 | Ana: 10.0 aprobado ⏎ Beto: 9.0 aprobado ⏎ Caro: 5.5 desaprobado ⏎ Mejor promedio: Ana
```

::: pistas
1. Dibuja el árbol de descomposición de este boletín. ¿Qué ramas tiene?
2. Es el boletín de [la lección](ruta:procedimental.dividir) con dos notas y tres alumnos.
3. Un subprograma para el promedio, otro para el estado y el mejor hasta ahora en el principal. ¿Con qué signo se respeta el empate?
4. Reemplaza al mejor solo si el promedio nuevo es estrictamente mayor. Cierra con la variante.
:::

::: variante
Si hay empate, muestra todos los nombres empatados.
:::

::: explicacion
El empate lo gana el primero porque la comparación es estricta. Casos ocultos: empate en el primer lugar, todos desaprobados y un promedio de 6.0 justo en el segundo visible.
:::
