---
id: exterior.archivos
numero: "6.1"
tipo: leccion
titulo: Guardar para mañana
duracion: 35
problema_breve: El stock que se pierde al cerrar
necesita: [concurrente.elegir]
introduce: [archivo, capacidad, limpieza-diferida]
usa: [nucleo-puro, funcion-pura, resultado-con-error, efecto]
---

::: frase
Lo que está en la memoria se pierde al cerrar; lo que se guarda en un archivo queda para mañana.
:::

## El problema {#problema}

::: problema
El kiosco cierra cada día con el stock de sus cinco productos: jugo 10, sándwich 5, alfajor 8, agua 12 y fruta 6. Al día siguiente el programa empieza otra vez desde cero y **el stock se perdió**.

**¿Cómo se guarda el stock para la próxima vez, y qué pasa si todavía no se guardó nada?**
:::

## Inténtalo {#intentalo}

::: intento
¿Qué tendría que decir el programa el primer día, cuando nunca se guardó nada?
:::

::: respuesta
Que no hay inventario guardado, y empezar con el stock inicial. No es un error del programa: es una situación esperable, y el programa la trata.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra el stock de los cinco productos; sale un texto guardado fuera del programa, que mañana se vuelve a leer.
- **¿A qué se parece?** Al núcleo puro y el borde de la Parte IV: armar las líneas es cálculo; guardarlas toca el mundo.
- **¿Qué puede fallar afuera del programa?** El archivo puede no existir, y la carpeta puede no dar permiso.

## La herramienta nueva {#herramienta}

Un [[def:archivo|archivo]] guarda texto fuera de la memoria: sigue ahí cuando el programa termina.

```figura id=ruta-memoria-y-disco
pie: Las cajas viven en la memoria y desaparecen al cerrar; el archivo queda en el disco.
paso: El programa guarda el stock en el archivo.
paso: El programa se cerró: la memoria quedó vacía y el archivo sigue ahí.
```

Para tocar una carpeta, el programa pide permiso. Ese permiso es una [[def:capacidad|capacidad]]: `SolicitarDirectorio` da la de una carpeta, y con ella se abre un archivo. Cada paso puede fallar, así que devuelve un `Resultado`, y `Propagar` pasa el error a quien llamó.

```figura-especificacion seccion=biblioteca.archivos figura=archivo-capas
```

Un archivo abierto hay que cerrarlo, aunque el subprograma salga antes por un error. Para no olvidarlo, se escribe una [[def:limpieza-diferida|limpieza diferida]]: `Diferir` guarda unas órdenes que se ejecutan al salir, en orden inverso.

```figura-especificacion seccion=control.diferir figura=diferir-pila
```

```programa id=puerta-luz titulo="Entrar y salir del cuarto" ejecutar
SubProceso Visitar()
  Escribir "abro la puerta";
  Diferir
    Escribir "cierro la puerta";
  FinDiferir
  Escribir "enciendo la luz";
  Diferir
    Escribir "apago la luz";
  FinDiferir
  Escribir "leo un rato";
FinSubProceso

Algoritmo Cuarto
  Visitar();
FinAlgoritmo
```

```salida
abro la puerta
enciendo la luz
leo un rato
apago la luz
cierro la puerta
```

::: especificacion
- biblioteca.archivos
- biblioteca.texto
- control.diferir
- tareas.efectos
:::

## Escribir {#escribir fase=3}

```programa id=inventario-archivo titulo="Guardar y leer el stock" ejecutar
Funcion linea <- LineaStock(nombre Como Cadena, stock Como Entero)
  Definir linea Como Cadena;
  linea <- nombre + ";" + ATexto(stock);
FinFuncion

SubProceso Guardar(texto Como Cadena) Como Resultado<Entero, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("stock.txt", "escritura");
  Diferir
    Descartar archivo.Cerrar();
  FinDiferir
  Retornar archivo.EscribirTexto(texto);
FinSubProceso

SubProceso Cargar() Como Resultado<Cadena, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("stock.txt", "lectura");
  Diferir
    Descartar archivo.Cerrar();
  FinDiferir
  Retornar archivo.LeerTexto();
FinSubProceso

Algoritmo Inventario
  Definir texto Como Cadena <- LineaStock("jugo", 10) + "\n" + LineaStock("sandwich", 5) + "\n" + LineaStock("alfajor", 8) + "\n" + LineaStock("agua", 12) + "\n" + LineaStock("fruta", 6);
  Segun Guardar(texto) Hacer
    Exito(bytes): Escribir "Guardado: ", bytes, " bytes";
    Error(problema): Escribir "No se pudo guardar: ", problema.Codigo;
  FinSegun
  Segun Cargar() Hacer
    Exito(leido): Escribir leido;
    Error(problema): Escribir "No hay inventario guardado (", problema.Codigo, ")";
  FinSegun
FinAlgoritmo
```

```anfitrion
{}
```

```salida
Guardado: 44 bytes
jugo;10
sandwich;5
alfajor;8
agua;12
fruta;6
```

`LineaStock` es una función pura: arma una línea del archivo. `Guardar` y `Cargar` son el borde: piden la capacidad, abren el archivo y lo cierran con una limpieza diferida. `Descartar` deja explícito que no interesa si cerrar salió bien.

El primer día no hay archivo. Leer no detiene el programa: llega un `Error` con el código `no_encontrado`, y el programa decide qué hacer.

```programa id=inventario-sin-archivo titulo="El primer día" ejecutar
SubProceso Cargar() Como Resultado<Cadena, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("stock.txt", "lectura");
  Diferir
    Descartar archivo.Cerrar();
  FinDiferir
  Retornar archivo.LeerTexto();
FinSubProceso

Algoritmo PrimerDia
  Segun Cargar() Hacer
    Exito(leido): Escribir leido;
    Error(problema): Escribir "No hay inventario guardado (", problema.Codigo, ")";
  FinSegun
FinAlgoritmo
```

```anfitrion
{}
```

```salida
No hay inventario guardado (no_encontrado)
```

## Probar {#probar fase=4}

| Caso | Qué pasa |
|---|---|
| Primer día, sin archivo | `No hay inventario guardado` |
| Día con archivo | se leen las cinco líneas |
| Una línea vacía en el archivo | `StockDeLinea` la marca como inválida |

La parte pura, `LineaStock` y su inversa `StockDeLinea`, se prueba con casos como cualquier función. La parte con efectos se prueba con un anfitrión de memoria: una carpeta simulada que empieza vacía.

## Mejorar {#mejorar fase=5}

En una frase: «Las líneas se arman con funciones puras, y solo el borde abre, escribe y cierra el archivo».

Es el núcleo puro y el borde de la Parte IV: si mañana el stock se guarda en otro lugar, solo cambia el borde.

## Lo que aprendiste {#aprendiste}

::: resumen
- {archivo} Un archivo guarda texto fuera de la memoria; sigue ahí cuando el programa termina.
- {capacidad} Una capacidad es el permiso que el programa pide para tocar algo de afuera; pedirla puede fallar.
- {limpieza-diferida} Una limpieza diferida se escribe junto a lo que la necesita y se ejecuta al salir, en orden inverso.
:::

## Practica {#practica}

::: practica
- exterior.archivos.orden-diferir
- exterior.archivos.linea-stock
- exterior.archivos.stock-de-linea
- exterior.archivos.que-puede-fallar
- exterior.archivos.limpieza-lugar
- exterior.archivos.linea-pruebas
:::

::: profundizar titulo="Tropiezos frecuentes"
- **«El archivo se guarda solo».** No queda nada guardado si el programa no lo escribe.
- **«Si el archivo no existe, el programa se cae».** Llega un `Error` que se trata, como en el primer día.
- **Creer que la limpieza diferida se ejecuta donde se escribe.** Se ejecuta al salir del subprograma; el programa de la puerta y la luz lo muestra.
:::

::: siguiente
Otra aplicación quiere leer el inventario. ¿En qué forma se escribe para que cualquier programa lo entienda?
:::
