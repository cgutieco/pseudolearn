---
id: objetos.componer
numero: "3.5"
tipo: leccion
titulo: Heredar o componer
duracion: 35
problema_breve: El yogur que vence y está en oferta
necesita: [objetos.contratos]
introduce: [herencia, composicion, sobrescribir]
usa: [clase, objeto, metodo, constructor, despacho-dinamico, valor-opcional, interfaz]
---

::: frase
Heredar dice qué es algo; componer dice qué tiene. Cuando los rasgos se combinan, componer escala mejor.
:::

## El problema {#problema}

::: problema
En el kiosco hay productos que **vencen** (tienen fecha) y productos **en oferta** (tienen porcentaje). Alguien creó `ProductoVencible` y `ProductoEnOferta` como casos particulares de `Producto`. Ahora llega un yogur que vence **y** está en oferta.

**¿Hace falta un tercer caso particular? ¿Y si mañana aparece un tercer rasgo?**
:::

## Inténtalo {#intentalo}

::: intento
Cuenta cuántos tipos de producto harían falta si hubiera tres rasgos que se pueden combinar: vence, está en oferta y tiene envase retornable.
:::

::: respuesta
Harían falta **8**: uno sin rasgos, tres con un rasgo, tres con dos y uno con los tres. Cada rasgo nuevo duplica la cantidad.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra un producto con sus rasgos; sale su precio final.
- **¿A qué se parece?** A la caja de [la lección 3.4](ruta:objetos.contratos): cada rasgo sabe cómo cambia el precio.
- **¿Quién tiene la información para hacer esto?** Todo rasgo sabe aplicar su parte; el producto sabe qué rasgos tiene.

```figura id=ruta-explosion-clases
pie: Con un caso particular por combinación, los tipos se multiplican. Con rasgos que el producto tiene adentro, se suman.
paso: Un caso particular por cada combinación de rasgos: con tres rasgos, ocho tipos.
paso: Un solo producto que tiene, o no, cada rasgo: con tres rasgos, tres piezas más.
```

## La herramienta nueva {#herramienta}

La [[def:herencia|herencia]] crea una clase que es un caso particular de otra: `Clase Cajero Hereda De Empleado`. La clase hija tiene todo lo de la madre y puede [[def:sobrescribir|sobrescribir]] un método, es decir, declararlo otra vez con la misma firma para hacerlo a su manera. Con `Super` llama a la versión de la madre.

```figura-especificacion seccion=objetos.herencia figura=herencia-despacho
```

```programa id=empleados titulo="Un cajero es un empleado" ejecutar
Clase Empleado
  Definir nombre Como Cadena;

  Metodo Constructor(n Como Cadena)
    Este.nombre <- n;
  FinMetodo

  Metodo Presentarse() Como Cadena
    Retornar "Hola, soy " + Este.nombre;
  FinMetodo
FinClase

Clase Cajero Hereda De Empleado
  Metodo Constructor(n Como Cadena)
    Super.Constructor(n);
  FinMetodo

  Metodo Presentarse() Como Cadena
    Retornar Super.Presentarse() + " y atiendo la caja";
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir ana Como Empleado <- Nuevo Empleado("Ana");
  Definir beto Como Empleado <- Nuevo Cajero("Beto");
  Escribir ana.Presentarse();
  Escribir beto.Presentarse();
FinAlgoritmo
```

```salida
Hola, soy Ana
Hola, soy Beto y atiendo la caja
```

La [[def:composicion|composición]], en cambio, arma un objeto con otros objetos que tiene adentro. Un producto no **es** una oferta: **tiene** una oferta, o no la tiene. Lo que el lenguaje no tiene, como las clases abstractas, está en [la Especificación](especificacion:objetos.ausentes).

::: especificacion
- objetos.herencia
- objetos.ausentes
:::

## Escribir {#escribir fase=3}

```programa id=productos-componer titulo="Un producto que tiene rasgos" ejecutar
Clase Oferta
  Definir porcentaje Como Entero;
  Metodo Constructor(p Como Entero)
    Este.porcentaje <- p;
  FinMetodo
  Metodo Aplicar(precio Como Entero) Como Entero
    Retornar precio - precio * Este.porcentaje div 100;
  FinMetodo
FinClase

Clase Vencimiento
  Definir dias Como Entero;
  Metodo Constructor(d Como Entero)
    Este.dias <- d;
  FinMetodo
  Metodo Aplicar(precio Como Entero) Como Entero
    Si Este.dias <= 2 Entonces
      Retornar precio div 2;
    FinSi
    Retornar precio;
  FinMetodo
FinClase

Clase Producto
  Definir nombre Como Cadena;
  Definir precio Como Entero;
  Definir oferta Como Oferta;
  Definir vencimiento Como Vencimiento;
  Metodo Constructor(n Como Cadena, p Como Entero)
    Este.nombre <- n;
    Este.precio <- p;
    Este.oferta <- Nuevo Oferta(0);
    Este.vencimiento <- Nuevo Vencimiento(365);
  FinMetodo
  Metodo PonerOferta(nueva Como Oferta)
    Este.oferta <- nueva;
  FinMetodo
  Metodo PonerVencimiento(fecha Como Vencimiento)
    Este.vencimiento <- fecha;
  FinMetodo
  Metodo PrecioFinal() Como Entero
    Retornar Este.vencimiento.Aplicar(Este.oferta.Aplicar(Este.precio));
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir jugo Como Producto <- Nuevo Producto("Jugo", 30);
  Definir leche Como Producto <- Nuevo Producto("Leche", 40);
  leche.PonerVencimiento(Nuevo Vencimiento(1));
  Definir galletas Como Producto <- Nuevo Producto("Galletas", 20);
  galletas.PonerOferta(Nuevo Oferta(50));
  Definir yogur Como Producto <- Nuevo Producto("Yogur", 40);
  yogur.PonerOferta(Nuevo Oferta(25));
  yogur.PonerVencimiento(Nuevo Vencimiento(1));
  Escribir jugo.nombre, " ", jugo.PrecioFinal();
  Escribir leche.nombre, " ", leche.PrecioFinal();
  Escribir galletas.nombre, " ", galletas.PrecioFinal();
  Escribir yogur.nombre, " ", yogur.PrecioFinal();
FinAlgoritmo
```

```salida
Jugo 30
Leche 20
Galletas 10
Yogur 15
```

Todo producto tiene una oferta y un vencimiento: si no está en oferta, la suya es del 0 %, y si no vence pronto, la suya está lejos. Un producto que vence en dos días o menos se vende a mitad de precio. El yogur tiene los dos rasgos: primero la oferta lo baja de 40 a 30, y después el vencimiento lo deja en 15.

## Probar {#probar fase=4}

| Producto | Rasgos | Esperado |
|---|---|---|
| Jugo, 30 | ninguno | 30 |
| Leche, 40 | vence en 1 día | 20 |
| Galletas, 20 | 50 % de oferta | 10 |
| Yogur, 40 | 25 % de oferta y vence en 1 día | 15 |

## Mejorar {#mejorar fase=5}

En una frase: «Un producto tiene, o no, cada rasgo, y su precio final aplica los que tiene».

Un tercer rasgo, como el envase retornable, agrega una clase y un atributo, no cuatro casos particulares nuevos.

## Lo que aprendiste {#aprendiste}

::: resumen
- {herencia,sobrescribir} Heredar crea una clase que es un caso particular de otra y puede sobrescribir sus métodos.
- {composicion} Componer es armar un objeto con otros objetos que tiene adentro.
:::

## Practica {#practica}

::: practica
- objetos.componer.es-o-tiene
- objetos.componer.super-predecir
- objetos.componer.yogur
- objetos.componer.empleados
- objetos.componer.cuando-heredar
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Heredar para reutilizar código.** Cuando la hija no es un caso particular de la madre, la herencia ata dos cosas que van a cambiar distinto.
- **Jerarquías profundas.** Entender una clase obliga a leer todas sus madres. Dibuja la jerarquía antes de agregar un nivel.
- **«Componer es menos orientado a objetos».** Componer es armar objetos con objetos: es lo más orientado a objetos que hay.
:::

::: siguiente
La clase del kiosco hace todo y tiene 600 líneas. ¿Cómo se decide a quién le toca cada cosa?
:::
