---
id: procedimental.datos.buscar-telefono
leccion: procedimental.datos
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Buscar un teléfono
---

::: enunciado
Lee 4 contactos, cada uno con nombre, teléfono y mes de cumpleaños, y después un nombre. Muestra el teléfono de ese nombre, o «No está». Si el nombre aparece más de una vez, muestra el primero.
:::

```programa rol=referencia
Registro Contacto
  Definir nombre, telefono Como Cadena;
  Definir mes Como Entero;
FinRegistro

Algoritmo Buscar
  Definir agenda Como Vector<Contacto> <- Vector();
  Definir nombre, telefono Como Cadena;
  Definir mes Como Entero;
  Para i <- 1 Hasta 4 Hacer
    Leer nombre;
    Leer telefono;
    Leer mes;
    agenda.Agregar(Contacto(nombre, telefono, mes));
  FinPara
  Leer nombre;
  Definir encontrado Como Cadena <- "No está";
  Para Cada contacto En agenda Hacer
    Si contacto.nombre = nombre Y encontrado = "No está" Entonces
      encontrado <- contacto.telefono;
    FinSi
  FinPara
  Escribir encontrado;
FinAlgoritmo
```

```casos
visible | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Beto | 222
visible | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Ana | 111
oculto | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Eva | No está
oculto | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Dani | 444
oculto | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Ana ; 999 ; 2 ; Dani ; 444 ; 3 ; Ana | 111
```

::: pistas
1. ¿Qué forma de datos responde mejor «el teléfono de este nombre»?
2. Es la búsqueda de la agenda de [la lección](ruta:procedimental.datos).
3. Guarda los contactos en un vector de fichas y búscalo; cuidado con los nombres repetidos.
4. Recorre el vector y guarda el teléfono solo la primera vez que el nombre coincide. Cierra con la variante.
:::

::: variante
Muestra también cuántos compañeros cumplen años en el mismo mes que el buscado.
:::

::: explicacion
Casos ocultos: un nombre ausente, el último de la lista y un nombre repetido (gana el primero). Error frecuente: reemplazar el teléfono en cada coincidencia, que devuelve el último.
:::
