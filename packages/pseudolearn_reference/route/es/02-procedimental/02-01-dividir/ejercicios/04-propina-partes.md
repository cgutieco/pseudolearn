---
id: procedimental.dividir.propina-partes
leccion: procedimental.dividir
tipo: modificar
nivel: brote
obligatorio: true
titulo: La propina en partes
---

::: enunciado
Este programa calcula cuánto paga cada amigo, con la propina incluida. Reescríbelo en dos piezas con nombre: una que calcule el total con la propina y otra que calcule la parte de cada uno, sin cambiar lo que muestra.
:::

::: restriccion
Usa un subprograma `TotalConPropina` que recibe la cuenta y otro `ParteDeCadaUno` que recibe el total y los amigos.
:::

```programa rol=inicial
Algoritmo Propina
  Definir cuenta Como Entero;
  Definir amigos Como Entero;
  Leer cuenta;
  Leer amigos;
  Si amigos = 0 Entonces
    Escribir "No hay quien pague";
  Sino
    Escribir "Cada uno paga: ", techo((cuenta + cuenta div 10) / amigos);
  FinSi
FinAlgoritmo
```

```programa rol=referencia
SubProceso TotalConPropina(cuenta Como Entero) Como Entero
  Retornar cuenta + cuenta div 10;
FinSubProceso

SubProceso ParteDeCadaUno(total Como Entero, amigos Como Entero) Como Entero
  Retornar techo(total / amigos);
FinSubProceso

Algoritmo Propina
  Definir cuenta Como Entero;
  Definir amigos Como Entero;
  Leer cuenta;
  Leer amigos;
  Si amigos = 0 Entonces
    Escribir "No hay quien pague";
  Sino
    Escribir "Cada uno paga: ", ParteDeCadaUno(TotalConPropina(cuenta), amigos);
  FinSi
FinAlgoritmo
```

```casos
visible | 120 ; 4 | Cada uno paga: 33
visible | 100 ; 0 | No hay quien pague
oculto | 100 ; 3 | Cada uno paga: 37
oculto | 100 ; 1 | Cada uno paga: 110
oculto | 0 ; 5 | Cada uno paga: 0
```

```aserciones
- declara-subprograma | TotalConPropina | 1 | Falta el subprograma TotalConPropina, que recibe la cuenta.
- declara-subprograma | ParteDeCadaUno | 2 | Falta el subprograma ParteDeCadaUno, que recibe el total y los amigos.
```

::: pistas
1. ¿Qué cuenta hace el programa en una sola línea? ¿En qué dos partes se puede cortar?
2. Repasa el boletín de [la lección](ruta:procedimental.dividir): cada cuenta tiene su subprograma.
3. Uno recibe la cuenta y retorna el total; el otro recibe el total y los amigos y retorna la parte.
4. `ParteDeCadaUno(TotalConPropina(cuenta), amigos)` reemplaza la cuenta larga. Cierra con la variante.
:::

::: variante
Cambia la propina al 15 %. ¿Cuántas líneas tocaste?
:::

::: explicacion
Los casos son los de la calculadora original: lo que muestra no cambia. Las aserciones comprueban los dos nombres y cuántos parámetros recibe cada uno.
:::
