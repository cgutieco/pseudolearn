---
id: exterior.proyecto
numero: "P·F"
tipo: proyecto
titulo: "Proyecto final: el kiosco completo"
duracion: 90
problema_breve: El kiosco que recuerda su stock
necesita: [exterior.http]
introduce: []
usa: [nucleo-puro, funcion-pura, archivo, capacidad, limpieza-diferida, json, serializar, registro, vector]
---

::: frase
Un programa completo es un núcleo que calcula y un borde que habla con el mundo.
:::

## El problema {#problema}

::: problema
Al abrir, el kiosco lee su inventario guardado; si todavía no existe, empieza con el stock inicial: jugo 10, sándwich 5, alfajor 8, agua 12 y fruta 6. Vende durante el recreo con las reglas de la Parte II: revisa el código y el stock de cada venta. Al cerrar, muestra el ticket con el total y el descuento, y guarda el inventario nuevo para mañana.

**¿Cómo es el kiosco completo?**
:::

## Inténtalo {#intentalo}

::: intento
Es el primer día y no hay nada guardado. Se venden 3 jugos y 2 sándwiches. ¿Qué dice el ticket, y qué queda guardado?
:::

::: respuesta
El total es **19** y, con descuento, **18**. El inventario nuevo dice jugo **7** y sándwich **3**; los demás productos quedan igual.
:::

## Entender {#entender fase=1}

El primer ejercicio te pide ubicar cada dato del problema: qué entra, qué es un dato fijo, qué sale y qué no importa. Fíjate en que ahora entra algo que no escribe nadie en el recreo: el archivo del día anterior.

::: recuerda termino=nucleo-puro
:::

## Planear {#planear fase=2}

El segundo ejercicio te pide ordenar los pasos del plan. Separa lo que toca el mundo, al principio y al final, de lo que solo calcula, en el medio.

## Escribir {#escribir fase=3}

El tercer ejercicio es el núcleo puro: las ventas, el ticket y el inventario final en JSON, sin archivos. El kiosco completo agrega el borde: carga el inventario, y al final lo guarda con una limpieza diferida que cierra el archivo.

```programa id=kiosco-completo titulo="El kiosco completo, primer día" ejecutar
Registro Producto
  Definir nombre Como Cadena;
  Definir precio, stock Como Entero;
FinRegistro

Funcion importe <- Importe(precio Como Entero, cantidad Como Entero)
  Definir importe Como Entero;
  importe <- precio * cantidad;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Funcion valido <- CodigoValido(codigo Como Entero)
  Definir valido Como Logico;
  valido <- codigo >= 1 Y codigo <= 5;
FinFuncion

Funcion texto <- InventarioJson(productos Como Vector<Producto>)
  Definir texto Como Cadena <- "{";
  Para Cada producto En productos Hacer
    Si texto <> "{" Entonces
      texto <- texto + ", ";
    FinSi
    texto <- texto + '"' + producto.nombre + '": ' + ATexto(producto.stock);
  FinPara
  texto <- texto + "}";
FinFuncion

SubProceso Catalogo() Como Vector<Producto>
  Definir productos Como Vector<Producto> <- Vector();
  productos.Agregar(Producto("Jugo", 3, 10));
  productos.Agregar(Producto("Sándwich", 5, 5));
  productos.Agregar(Producto("Alfajor", 2, 8));
  productos.Agregar(Producto("Agua", 1, 12));
  productos.Agregar(Producto("Fruta", 2, 6));
  Retornar productos;
FinSubProceso

Funcion stock <- StockGuardado(inventario Como ValorJson, producto Como Producto)
  Definir stock Como Entero <- producto.stock;
  Segun inventario.Campo(producto.nombre) Hacer
    Algo(valor):
      Segun valor.ComoEntero() Hacer
        Algo(guardado): stock <- guardado;
        Nada: stock <- producto.stock;
      FinSegun
    Nada: stock <- producto.stock;
  FinSegun
FinFuncion

Funcion cargados <- AplicarInventario(productos Como Vector<Producto>, inventario Como ValorJson)
  Definir cargados Como Vector<Producto> <- Vector();
  Para Cada producto En productos Hacer
    cargados.Agregar(Producto(producto.nombre, producto.precio, StockGuardado(inventario, producto)));
  FinPara
FinFuncion

SubProceso CargarInventario() Como Resultado<Cadena, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("inventario.json", "lectura");
  Diferir
    Descartar archivo.Cerrar();
  FinDiferir
  Retornar archivo.LeerTexto();
FinSubProceso

SubProceso GuardarInventario(texto Como Cadena) Como Resultado<Entero, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("inventario.json", "escritura");
  Diferir
    Descartar archivo.Cerrar();
  FinDiferir
  Retornar archivo.EscribirTexto(texto);
FinSubProceso

Algoritmo Kiosco
  Definir productos Como Vector<Producto> <- Catalogo();
  Segun CargarInventario() Hacer
    Exito(texto):
      Segun AnalizarJson(texto) Hacer
        Exito(inventario):
          productos <- AplicarInventario(productos, inventario);
          Escribir "Inventario cargado";
        Error(roto): Escribir "Inventario roto en la columna ", roto.JsonColumna, ": stock inicial";
      FinSegun
    Error(problema): Escribir "Sin inventario guardado (", problema.Codigo, "): stock inicial";
  FinSegun
  Definir total Como Entero <- 0;
  Definir codigo, cantidad Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer cantidad;
    Si NO CodigoValido(codigo) Entonces
      Escribir "Código ", codigo, " no existe";
    Sino
      Si cantidad < 1 Entonces
        Escribir "Cantidad ", cantidad, " no válida";
      Sino
        Definir producto Como Producto <- productos[codigo - 1];
        Si cantidad > producto.stock Entonces
          Escribir producto.nombre, " x ", cantidad, " rechazado: quedan ", producto.stock;
        Sino
          producto.stock <- producto.stock - cantidad;
          productos[codigo - 1] <- producto;
          Escribir producto.nombre, " x ", cantidad, " = ", Importe(producto.precio, cantidad);
          total <- total + Importe(producto.precio, cantidad);
        FinSi
      FinSi
    FinSi
    Leer codigo;
  FinMientras
  Escribir "Total: ", total;
  Escribir "Con descuento: ", ConDescuento(total);
  Segun GuardarInventario(InventarioJson(productos)) Hacer
    Exito(bytes): Escribir "Inventario guardado: ", bytes, " bytes";
    Error(problema): Escribir "No se pudo guardar: ", problema.Codigo;
  FinSegun
FinAlgoritmo
```

```entrada
1
3
2
2
0
```

```anfitrion
{}
```

```salida
Sin inventario guardado (no_encontrado): stock inicial
Jugo x 3 = 9
Sándwich x 2 = 10
Total: 19
Con descuento: 18
Inventario guardado: 65 bytes
```

## Probar {#probar fase=4}

El segundo día, el archivo ya existe con el inventario que guardó el primero:

```programa id=kiosco-dia-dos titulo="El kiosco completo, segundo día" ejecutar
Registro Producto
  Definir nombre Como Cadena;
  Definir precio, stock Como Entero;
FinRegistro

Funcion importe <- Importe(precio Como Entero, cantidad Como Entero)
  Definir importe Como Entero;
  importe <- precio * cantidad;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Funcion valido <- CodigoValido(codigo Como Entero)
  Definir valido Como Logico;
  valido <- codigo >= 1 Y codigo <= 5;
FinFuncion

Funcion texto <- InventarioJson(productos Como Vector<Producto>)
  Definir texto Como Cadena <- "{";
  Para Cada producto En productos Hacer
    Si texto <> "{" Entonces
      texto <- texto + ", ";
    FinSi
    texto <- texto + '"' + producto.nombre + '": ' + ATexto(producto.stock);
  FinPara
  texto <- texto + "}";
FinFuncion

SubProceso Catalogo() Como Vector<Producto>
  Definir productos Como Vector<Producto> <- Vector();
  productos.Agregar(Producto("Jugo", 3, 10));
  productos.Agregar(Producto("Sándwich", 5, 5));
  productos.Agregar(Producto("Alfajor", 2, 8));
  productos.Agregar(Producto("Agua", 1, 12));
  productos.Agregar(Producto("Fruta", 2, 6));
  Retornar productos;
FinSubProceso

Funcion stock <- StockGuardado(inventario Como ValorJson, producto Como Producto)
  Definir stock Como Entero <- producto.stock;
  Segun inventario.Campo(producto.nombre) Hacer
    Algo(valor):
      Segun valor.ComoEntero() Hacer
        Algo(guardado): stock <- guardado;
        Nada: stock <- producto.stock;
      FinSegun
    Nada: stock <- producto.stock;
  FinSegun
FinFuncion

Funcion cargados <- AplicarInventario(productos Como Vector<Producto>, inventario Como ValorJson)
  Definir cargados Como Vector<Producto> <- Vector();
  Para Cada producto En productos Hacer
    cargados.Agregar(Producto(producto.nombre, producto.precio, StockGuardado(inventario, producto)));
  FinPara
FinFuncion

SubProceso CargarInventario() Como Resultado<Cadena, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("inventario.json", "lectura");
  Diferir
    Descartar archivo.Cerrar();
  FinDiferir
  Retornar archivo.LeerTexto();
FinSubProceso

SubProceso GuardarInventario(texto Como Cadena) Como Resultado<Entero, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("inventario.json", "escritura");
  Diferir
    Descartar archivo.Cerrar();
  FinDiferir
  Retornar archivo.EscribirTexto(texto);
FinSubProceso

Algoritmo Kiosco
  Definir productos Como Vector<Producto> <- Catalogo();
  Segun CargarInventario() Hacer
    Exito(texto):
      Segun AnalizarJson(texto) Hacer
        Exito(inventario):
          productos <- AplicarInventario(productos, inventario);
          Escribir "Inventario cargado";
        Error(roto): Escribir "Inventario roto en la columna ", roto.JsonColumna, ": stock inicial";
      FinSegun
    Error(problema): Escribir "Sin inventario guardado (", problema.Codigo, "): stock inicial";
  FinSegun
  Definir total Como Entero <- 0;
  Definir codigo, cantidad Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer cantidad;
    Si NO CodigoValido(codigo) Entonces
      Escribir "Código ", codigo, " no existe";
    Sino
      Si cantidad < 1 Entonces
        Escribir "Cantidad ", cantidad, " no válida";
      Sino
        Definir producto Como Producto <- productos[codigo - 1];
        Si cantidad > producto.stock Entonces
          Escribir producto.nombre, " x ", cantidad, " rechazado: quedan ", producto.stock;
        Sino
          producto.stock <- producto.stock - cantidad;
          productos[codigo - 1] <- producto;
          Escribir producto.nombre, " x ", cantidad, " = ", Importe(producto.precio, cantidad);
          total <- total + Importe(producto.precio, cantidad);
        FinSi
      FinSi
    FinSi
    Leer codigo;
  FinMientras
  Escribir "Total: ", total;
  Escribir "Con descuento: ", ConDescuento(total);
  Segun GuardarInventario(InventarioJson(productos)) Hacer
    Exito(bytes): Escribir "Inventario guardado: ", bytes, " bytes";
    Error(problema): Escribir "No se pudo guardar: ", problema.Codigo;
  FinSegun
FinAlgoritmo
```

```entrada
1
3
2
4
0
```

```anfitrion
{"files": {"inventario.json": "{\"Jugo\": 7, \"Sándwich\": 3, \"Alfajor\": 8, \"Agua\": 12, \"Fruta\": 6}"}}
```

```salida
Inventario cargado
Jugo x 3 = 9
Sándwich x 4 rechazado: quedan 3
Total: 9
Con descuento: 9
Inventario guardado: 65 bytes
```

| Caso | Por qué |
|---|---|
| El primer día, sin archivo | empieza con el stock inicial |
| El segundo día | el stock sigue donde quedó |
| Una venta que pide más de lo que hay | se rechaza con lo que queda |
| Un archivo roto | se avisa y se empieza con el stock inicial |

## Mejorar {#mejorar fase=5}

En una frase: «El kiosco carga su inventario en el borde, vende y calcula en un núcleo puro, y guarda el inventario nuevo al cerrar».

Mira qué parte del programa cambió desde la Parte II: el núcleo casi nada. Lo nuevo vive en el borde, que es lo que habla con el mundo.

## Lo que aprendiste {#aprendiste}

::: resumen
- Un programa completo junta un núcleo puro, que se prueba con casos, y un borde delgado que lee, escribe y guarda.
- Los errores de afuera, como un archivo que falta, son situaciones esperables que el programa trata.
:::

## Practica {#practica}

::: practica
- exterior.proyecto.final-ficha
- exterior.proyecto.final-plan
- exterior.proyecto.final-nucleo
:::

::: docentes
- **Planear antes de abrir el editor.** La ficha y el plan son ejercicios por algo: el programa es el más largo de la ruta.
- **Separar núcleo y borde.** El ejercicio comprobado es solo el núcleo; el borde se prueba en la lección con el anfitrión de memoria.
- **Probar el día sin archivo.** Es el primer caso que encuentra cualquier persona que usa el kiosco.
:::

::: siguiente
Terminaste la ruta. Desde aquí, la Especificación tiene cada parte del lenguaje contada en detalle: elige un problema tuyo y escríbelo.
:::
