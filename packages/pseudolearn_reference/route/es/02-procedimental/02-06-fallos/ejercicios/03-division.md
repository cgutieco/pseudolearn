---
id: procedimental.fallos.division
leccion: procedimental.fallos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Una división que avisa
---

::: enunciado
Lee dos números enteros y muestra el cociente entero del primero entre el segundo, o «No se puede dividir entre 0».
:::

::: restriccion
La división va en un subprograma `DividirSeguro` que recibe los dos números y retorna el cociente o el motivo.
:::

```programa rol=referencia
SubProceso DividirSeguro(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("No se puede dividir entre 0");
  FinSi
  Retornar Exito(a div b);
FinSubProceso

Algoritmo Division
  Definir a, b Como Entero;
  Leer a;
  Leer b;
  Segun DividirSeguro(a, b) Hacer
    Exito(cociente): Escribir cociente;
    Error(motivo): Escribir motivo;
  FinSegun
FinAlgoritmo
```

```casos
visible | 10 ; 2 | 5
visible | 7 ; 0 | No se puede dividir entre 0
oculto | 0 ; 5 | 0
oculto | 0 ; 0 | No se puede dividir entre 0
oculto | 9 ; 4 | 2
```

```aserciones
- declara-subprograma | DividirSeguro | 2 | Falta el subprograma DividirSeguro, que recibe los dos números.
```

::: pistas
1. ¿Qué entrada tiene que dar un motivo en lugar de un número?
2. Mira la división sin caerse de [la lección](ruta:procedimental.fallos).
3. El subprograma retorna un éxito o un error; el principal los atiende con un `Segun`.
4. `DividirSeguro` retorna `Error` si el divisor es 0 y `Exito(a div b)` si no. Cierra con la variante.
:::

::: variante
Agrega un segundo motivo: «El dividendo es negativo».
:::

::: explicacion
Casos ocultos: 0 en el numerador (es válido) y 0 entre 0 (es un error). Error frecuente: comprobar el numerador en lugar del divisor.
:::
