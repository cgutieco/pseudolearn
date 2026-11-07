---
id: objetos.identidad.pedido-copia
leccion: objetos.identidad
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: El pedido que se copió mal
---

::: enunciado
El programa lee dos productos para un pedido y un tercero para un pedido parecido. El ticket del pedido original tendría que mostrar solo sus dos productos, pero también muestra el tercero. Encuentra el error y corrígelo.
:::

```programa rol=inicial
Clase Pedido
  Privado Definir productos Como Vector<Cadena>;

  Metodo Constructor()
    Este.productos <- Vector();
  FinMetodo

  Metodo Agregar(producto Como Cadena)
    Este.productos.Agregar(producto);
  FinMetodo

  Metodo Ticket() Como Cadena
    Retornar Unir(Este.productos, ", ");
  FinMetodo

  Metodo Duplicar() Como Pedido
    Definir duplicado Como Pedido <- Nuevo Pedido();
    Para Cada producto En Este.productos Hacer
      duplicado.Agregar(producto);
    FinPara
    Retornar duplicado;
  FinMetodo
FinClase

Algoritmo Pedidos
  Definir primero, segundo, extra Como Cadena;
  Leer primero;
  Leer segundo;
  Leer extra;
  Definir pedido Como Pedido <- Nuevo Pedido();
  pedido.Agregar(primero);
  pedido.Agregar(segundo);
  Definir copia Como Pedido <- pedido;
  copia.Agregar(extra);
  Escribir "Original: ", pedido.Ticket();
  Escribir "Copia: ", copia.Ticket();
FinAlgoritmo
```

```programa rol=referencia
Clase Pedido
  Privado Definir productos Como Vector<Cadena>;

  Metodo Constructor()
    Este.productos <- Vector();
  FinMetodo

  Metodo Agregar(producto Como Cadena)
    Este.productos.Agregar(producto);
  FinMetodo

  Metodo Ticket() Como Cadena
    Retornar Unir(Este.productos, ", ");
  FinMetodo

  Metodo Duplicar() Como Pedido
    Definir duplicado Como Pedido <- Nuevo Pedido();
    Para Cada producto En Este.productos Hacer
      duplicado.Agregar(producto);
    FinPara
    Retornar duplicado;
  FinMetodo
FinClase

Algoritmo Pedidos
  Definir primero, segundo, extra Como Cadena;
  Leer primero;
  Leer segundo;
  Leer extra;
  Definir pedido Como Pedido <- Nuevo Pedido();
  pedido.Agregar(primero);
  pedido.Agregar(segundo);
  Definir copia Como Pedido <- pedido.Duplicar();
  copia.Agregar(extra);
  Escribir "Original: ", pedido.Ticket();
  Escribir "Copia: ", copia.Ticket();
FinAlgoritmo
```

```casos
visible | Jugo ; Sándwich ; Alfajor | Original: Jugo, Sándwich ⏎ Copia: Jugo, Sándwich, Alfajor
visible | Agua ; Fruta ; Jugo | Original: Agua, Fruta ⏎ Copia: Agua, Fruta, Jugo
oculto | Jugo ; Jugo ; Jugo | Original: Jugo, Jugo ⏎ Copia: Jugo, Jugo, Jugo
oculto | A ; B ; C | Original: A, B ⏎ Copia: A, B, C
oculto | Alfajor ; Agua ; Sándwich | Original: Alfajor, Agua ⏎ Copia: Alfajor, Agua, Sándwich
```

::: pistas
1. ¿Cuántos pedidos hay en el programa? Cuenta las veces que aparece `Nuevo`.
2. Repasa la figura de las flechas de [la lección](ruta:objetos.identidad).
3. El pedido ya sabe hacer una copia con su propia lista.
4. Arma la copia con `pedido.Duplicar()` en lugar de asignar el pedido. Cierra con la variante.
:::

::: variante
¿Qué pasaría si la copia se armara con `Copiar(pedido)`? Pruébalo y explica el resultado.
:::

::: docentes
`copia <- pedido` da otro nombre al mismo pedido. La corrección usa `Duplicar`, que arma una lista nueva. `Copiar` no alcanza: comparte la lista.
:::
