---
id: concurrente.elegir.pedido-pruebas
leccion: concurrente.elegir
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: Las pruebas del pedido
---

::: enunciado
No escribas código. Escribe entre dos y cuatro casos para el pedido de fruta, con la respuesta correcta de cada uno, de modo que cualquier versión equivocada falle al menos uno.
:::

```programa rol=referencia
SubProceso Suspendible Revisar(nombre Como Cadena, stock Como Entero) Como Cadena
  Si stock = 0 Entonces
    Retornar nombre + " no tiene stock";
  FinSi
  Retornar "";
FinSubProceso

Algoritmo Pedido
  Definir norte Como Entero;
  Definir sur Como Entero;
  Definir oeste Como Entero;
  Leer norte;
  Leer sur;
  Leer oeste;
  Tareas
    Definir deNorte Como Tarea<Cadena> <- Lanzar Revisar("Norte", norte);
    Definir deSur Como Tarea<Cadena> <- Lanzar Revisar("Sur", sur);
    Definir deOeste Como Tarea<Cadena> <- Lanzar Revisar("Oeste", oeste);
    Definir motivo Como Cadena <- Aguardar deNorte + Aguardar deSur + Aguardar deOeste;
    Si motivo = "" Entonces
      Escribir "Pedido confirmado: ", norte + sur + oeste;
    Sino
      Escribir "Pedido suspendido: ", motivo;
    FinSi
  FinTareas
FinAlgoritmo
```

```programa rol=mutante id=solo-el-primero
SubProceso Suspendible Revisar(nombre Como Cadena, stock Como Entero) Como Cadena
  Si nombre = "Norte" Y stock = 0 Entonces
    Retornar nombre + " no tiene stock";
  FinSi
  Retornar "";
FinSubProceso

Algoritmo Pedido
  Definir norte Como Entero;
  Definir sur Como Entero;
  Definir oeste Como Entero;
  Leer norte;
  Leer sur;
  Leer oeste;
  Tareas
    Definir deNorte Como Tarea<Cadena> <- Lanzar Revisar("Norte", norte);
    Definir deSur Como Tarea<Cadena> <- Lanzar Revisar("Sur", sur);
    Definir deOeste Como Tarea<Cadena> <- Lanzar Revisar("Oeste", oeste);
    Definir motivo Como Cadena <- Aguardar deNorte + Aguardar deSur + Aguardar deOeste;
    Si motivo = "" Entonces
      Escribir "Pedido confirmado: ", norte + sur + oeste;
    Sino
      Escribir "Pedido suspendido: ", motivo;
    FinSi
  FinTareas
FinAlgoritmo
```

```programa rol=mutante id=menor-que-cero
SubProceso Suspendible Revisar(nombre Como Cadena, stock Como Entero) Como Cadena
  Si stock < 0 Entonces
    Retornar nombre + " no tiene stock";
  FinSi
  Retornar "";
FinSubProceso

Algoritmo Pedido
  Definir norte Como Entero;
  Definir sur Como Entero;
  Definir oeste Como Entero;
  Leer norte;
  Leer sur;
  Leer oeste;
  Tareas
    Definir deNorte Como Tarea<Cadena> <- Lanzar Revisar("Norte", norte);
    Definir deSur Como Tarea<Cadena> <- Lanzar Revisar("Sur", sur);
    Definir deOeste Como Tarea<Cadena> <- Lanzar Revisar("Oeste", oeste);
    Definir motivo Como Cadena <- Aguardar deNorte + Aguardar deSur + Aguardar deOeste;
    Si motivo = "" Entonces
      Escribir "Pedido confirmado: ", norte + sur + oeste;
    Sino
      Escribir "Pedido suspendido: ", motivo;
    FinSi
  FinTareas
FinAlgoritmo
```

```programa rol=mutante id=suma-de-dos
SubProceso Suspendible Revisar(nombre Como Cadena, stock Como Entero) Como Cadena
  Si stock = 0 Entonces
    Retornar nombre + " no tiene stock";
  FinSi
  Retornar "";
FinSubProceso

Algoritmo Pedido
  Definir norte Como Entero;
  Definir sur Como Entero;
  Definir oeste Como Entero;
  Leer norte;
  Leer sur;
  Leer oeste;
  Tareas
    Definir deNorte Como Tarea<Cadena> <- Lanzar Revisar("Norte", norte);
    Definir deSur Como Tarea<Cadena> <- Lanzar Revisar("Sur", sur);
    Definir deOeste Como Tarea<Cadena> <- Lanzar Revisar("Oeste", oeste);
    Definir motivo Como Cadena <- Aguardar deNorte + Aguardar deSur + Aguardar deOeste;
    Si motivo = "" Entonces
      Escribir "Pedido confirmado: ", norte + sur;
    Sino
      Escribir "Pedido suspendido: ", motivo;
    FinSi
  FinTareas
FinAlgoritmo
```

```casos
visible | 5 ; 3 ; 2 | Pedido confirmado: 10
```

```casos-solucion minimo=2 maximo=4
5 ; 3 ; 2 | Pedido confirmado: 10
0 ; 3 ; 2 | Pedido suspendido: Norte no tiene stock
4 ; 4 ; 0 | Pedido suspendido: Oeste no tiene stock
```

::: pistas
1. Piensa errores posibles: revisar solo un proveedor, comparar mal con 0, sumar de menos.
2. Hace falta un caso que se confirme, para revisar la suma.
3. Hace falta un proveedor sin stock que no sea el primero.
4. 5, 3, 2; 0, 3, 2; y 4, 4, 0 descubren a las tres versiones equivocadas. Cierra con la variante.
:::

::: variante
¿Cuál de tus casos podrías quitar sin dejar escapar ninguna versión equivocada?
:::

::: docentes
Versiones equivocadas: solo revisa el stock de Norte, usa `< 0` en vez de `= 0` y confirma con la suma de los dos primeros. Un conjunto sin un caso confirmado no detecta la tercera; uno donde solo falla Norte no detecta la primera.
:::
