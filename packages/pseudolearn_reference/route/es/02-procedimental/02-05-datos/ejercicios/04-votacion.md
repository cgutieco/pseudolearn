---
id: procedimental.datos.votacion
leccion: procedimental.datos
tipo: resolver
nivel: brote
obligatorio: true
titulo: La elección de delegados
---

::: enunciado
Se votan delegados escribiendo nombres, uno por voto, hasta la palabra `fin`. Muestra el ganador y sus votos, separados por un espacio. Si hay empate, gana el primero en orden alfabético. Si no hubo votos, muestra «Sin votos».
:::

```programa rol=referencia
Algoritmo Votacion
  Definir votos Como Diccionario<Cadena, Entero> <- Diccionario();
  Definir nombre Como Cadena;
  Leer nombre;
  Mientras nombre <> "fin" Hacer
    Segun votos.Buscar(nombre) Hacer
      Algo(cantidad): votos[nombre] <- cantidad + 1;
      Nada: votos[nombre] <- 1;
    FinSegun
    Leer nombre;
  FinMientras
  Definir ganador Como Cadena <- "";
  Definir mayor Como Entero <- 0;
  Para Cada candidato En votos.Claves() Hacer
    Si votos[candidato] > mayor O (votos[candidato] = mayor Y candidato < ganador) Entonces
      ganador <- candidato;
      mayor <- votos[candidato];
    FinSi
  FinPara
  Si mayor = 0 Entonces
    Escribir "Sin votos";
  Sino
    Escribir ganador, " ", mayor;
  FinSi
FinAlgoritmo
```

```casos
visible | Ana ; Beto ; Ana ; fin | Ana 2
visible | Caro ; fin | Caro 1
oculto | Beto ; Ana ; fin | Ana 1
oculto | fin | Sin votos
oculto | Dani ; Caro ; Dani ; Caro ; Beto ; fin | Caro 2
oculto | Eva ; Eva ; Eva ; Ana ; fin | Eva 3
```

::: pistas
1. ¿Qué tienes que recordar de cada nombre mientras llegan los votos?
2. Es la agenda de [la lección](ruta:procedimental.datos), que contaba cumpleaños por mes: aquí se cuentan votos por nombre.
3. Primero cuenta con un diccionario; después recorre sus claves buscando el mayor. ¿Qué pasa en un empate?
4. Reemplaza al ganador si tiene más votos, o los mismos y un nombre que va antes. Cierra con la variante.
:::

::: variante
Muestra el resultado completo: cada candidato con sus votos, en el orden en que recibió el primero.
:::

::: docentes
Casos ocultos: empate (Beto y Ana con 1: gana Ana), ningún voto, empate entre dos con más votos y un ganador claro. Error frecuente: quedarse con el primero que se recorre en un empate, que depende del orden de llegada.
:::
