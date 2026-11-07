---
id: procedimental.fallos.fecha
leccion: procedimental.fallos
tipo: resolver
nivel: arbol
obligatorio: false
titulo: ¿Es una fecha válida?
---

::: enunciado
Lee un día y un mes de un año que no es bisiesto, en ese orden. Muestra «válida», «día fuera de rango» o «mes fuera de rango». Si el mes no existe, ese es el motivo, aunque el día también esté mal.
:::

```programa rol=referencia
SubProceso DiasDelMes(mes Como Entero) Como Entero
  Segun mes Hacer
    2:
      Retornar 28;
    4, 6, 9, 11:
      Retornar 30;
    De Otro Modo:
      Retornar 31;
  FinSegun
FinSubProceso

SubProceso ValidarFecha(dia Como Entero, mes Como Entero) Como Resultado<Entero, Cadena>
  Si mes < 1 O mes > 12 Entonces
    Retornar Error("mes fuera de rango");
  FinSi
  Si dia < 1 O dia > DiasDelMes(mes) Entonces
    Retornar Error("día fuera de rango");
  FinSi
  Retornar Exito(dia);
FinSubProceso

Algoritmo Fecha
  Definir dia, mes Como Entero;
  Leer dia;
  Leer mes;
  Segun ValidarFecha(dia, mes) Hacer
    Exito(valor): Escribir "válida";
    Error(motivo): Escribir motivo;
  FinSegun
FinAlgoritmo
```

```casos
visible | 31 ; 4 | día fuera de rango
visible | 15 ; 13 | mes fuera de rango
oculto | 29 ; 2 | día fuera de rango
oculto | 31 ; 12 | válida
oculto | 30 ; 4 | válida
oculto | 0 ; 5 | día fuera de rango
oculto | 0 ; 13 | mes fuera de rango
```

::: pistas
1. ¿Cuántos días tiene cada mes? ¿Qué se valida primero, el día o el mes?
2. Son los dos filtros en fila de [la lección](ruta:procedimental.fallos).
3. Un subprograma dice cuántos días tiene un mes; otro aplica los filtros y retorna el motivo del primero que falla.
4. Primero el mes entre 1 y 12; después el día entre 1 y los días de ese mes. Cierra con la variante.
:::

::: variante
Agrega el año y ten en cuenta los bisiestos de [la lección 1.2](ruta:imperativo.caminos).
:::

::: docentes
Casos ocultos: el 29 de febrero, los bordes de abril y diciembre, el día 0 y un caso con los dos datos mal, donde manda el mes.
:::
