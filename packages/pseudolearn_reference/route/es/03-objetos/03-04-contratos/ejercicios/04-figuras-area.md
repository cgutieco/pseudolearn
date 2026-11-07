---
id: objetos.contratos.figuras-area
leccion: objetos.contratos
tipo: resolver
nivel: arbol
obligatorio: true
titulo: El área de cualquier figura
---

::: enunciado
Lee el tipo de figura (`rectangulo`, `cuadrado` o `triangulo`) y sus medidas: largo y ancho, lado, o base y altura de un triángulo rectángulo. Muestra el área.
:::

::: restriccion
Un contrato `Figura` con un método `Area()`, una clase por figura que lo cumple y una sola pieza genérica que calcula el área de cualquiera.
:::

```programa rol=referencia
Interfaz Figura
  Metodo Area() Como Real;
FinInterfaz

Clase Rectangulo Realiza Figura
  Definir largo, ancho Como Real;
  Metodo Constructor(l Como Real, a Como Real)
    Este.largo <- l;
    Este.ancho <- a;
  FinMetodo
  Metodo Area() Como Real
    Retornar Este.largo * Este.ancho;
  FinMetodo
FinClase

Clase Cuadrado Realiza Figura
  Definir lado Como Real;
  Metodo Constructor(l Como Real)
    Este.lado <- l;
  FinMetodo
  Metodo Area() Como Real
    Retornar Este.lado * Este.lado;
  FinMetodo
FinClase

Clase Triangulo Realiza Figura
  Definir base, alto Como Real;
  Metodo Constructor(b Como Real, a Como Real)
    Este.base <- b;
    Este.alto <- a;
  FinMetodo
  Metodo Area() Como Real
    Retornar Este.base * Este.alto / 2;
  FinMetodo
FinClase

SubProceso AreaDe<T: Figura>(figura Como T) Como Real
  Retornar figura.Area();
FinSubProceso

Algoritmo Figuras
  Definir tipo Como Cadena;
  Definir primera, segunda Como Real;
  Leer tipo;
  Si tipo = "cuadrado" Entonces
    Leer primera;
    Escribir AreaDe(Nuevo Cuadrado(primera));
  Sino
    Leer primera;
    Leer segunda;
    Si tipo = "rectangulo" Entonces
      Escribir AreaDe(Nuevo Rectangulo(primera, segunda));
    Sino
      Escribir AreaDe(Nuevo Triangulo(primera, segunda));
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | rectangulo ; 3 ; 4 | 12.0
visible | cuadrado ; 5 | 25.0
oculto | triangulo ; 3 ; 5 | 7.5
oculto | rectangulo ; 0 ; 9 | 0.0
oculto | cuadrado ; 0 | 0.0
oculto | triangulo ; 4 ; 4 | 8.0
```

```aserciones
- declara-subprograma | AreaDe | 1 | Falta la pieza genérica AreaDe, que recibe cualquier figura.
```

::: pistas
1. ¿Qué tienen en común las tres figuras? ¿Qué cambia entre ellas?
2. Es la caja de [la lección](ruta:objetos.contratos): el contrato es `Figura` y la pieza genérica es como `CobrarCon`.
3. Una interfaz con `Area()`, tres clases que la realizan y `AreaDe<T: Figura>` que llama a `Area()`.
4. El principal lee el tipo, crea la figura que corresponde y muestra `AreaDe` de ella. Cierra con la variante.
:::

::: variante
Agrega el círculo, con área 3.14 por el radio al cuadrado. ¿Qué piezas cambian?
:::

::: docentes
Casos ocultos: un triángulo con área no entera, medidas 0 y un triángulo de área entera. Error frecuente: calcular el área en el principal con una decisión por figura, que no usa el contrato.
:::
