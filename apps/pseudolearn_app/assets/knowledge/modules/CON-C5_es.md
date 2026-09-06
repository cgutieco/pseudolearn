:::parte pregunta

El módulo anterior, **Herencia y despacho dinámico**, mostró cómo una clase hereda de otra: «es un tipo de». Hay una segunda relación entre clases,
igual de común y con una pregunta de diseño propia: una clase que **tiene** un objeto de otra, y le
delega el trabajo que ya sabe hacer. Elegir mal entre las dos —o meter toda la responsabilidad en una
sola clase que hace de todo— es el error de diseño más común de este bloque, y este módulo es sobre
evitarlo.

:::parte modelo-maquina

Cada dato y cada operación pertenecen a una sola clase, la que tiene la información para resolverlos.
`Auto` no sabe calcular la potencia de un motor; su `Motor` sí, porque es suyo. `Auto` no duplica ese
cálculo: guarda un `Motor` como atributo y le pregunta. La casilla que importa —`potencia`— vive en un
solo sitio, y cualquier clase que la necesite pasa por el objeto que la tiene, nunca por una copia.

:::parte desarrollo

## Tiene-un, no es-un

{{ejemplo:example-c5-auto}}

{{diagrama:example-c5-auto#clases}}

`Auto` no hereda de `Motor`: un auto no es un tipo de motor, tiene uno. Por eso `Este.motor` es un
atributo, no una superclase, y `Auto.Potencia()` no repite el cálculo: se limita a preguntarle a
`Este.motor` y devolver lo que responde. Esta es la prueba que decide entre herencia y composición: si
la relación se puede decir con «es un», es herencia; si solo se puede decir con «tiene un», es un
atributo de tipo clase.

## A quién le pertenece cada responsabilidad

La pregunta de diseño de este módulo no es sintáctica: es «¿qué clase tiene los datos para responder
esto?». Una clase que responde preguntas sobre datos que no son suyos —leyendo atributos ajenos en vez
de preguntarle al objeto que los tiene— es la señal de que la responsabilidad está en el lugar
equivocado. Repartir bien evita tanto la clase que sabe demasiado como la clase que no sabe nada de lo
suyo.

:::parte prediccion

- example-c5-auto#7# Con la entrada 120, ¿qué valor escribe el programa?

Antes de comprobarlo, decide qué clase calcula realmente ese valor: `Auto`, o el `Motor` que `Auto`
tiene guardado.

:::parte errores-frecuentes

## Una interfaz

Las interfaces están fuera del alcance de este lenguaje. Es una construcción real de la orientación a
objetos, y el analizador la reconoce para decir exactamente eso en vez de tratarla como un nombre mal
escrito.

```pseudo
Algoritmo Probar
FinAlgoritmo

Interfaz Figura
```

{{diagnostico:unsupportedInterfaceConstruct}}

## Un miembro estático

No hay miembros estáticos en este lenguaje: todo atributo y todo método pertenecen a una instancia, no
a la clase en abstracto.

```pseudo
Clase Contador
    Estatico Definir total Como Entero;
FinClase

Algoritmo Probar
FinAlgoritmo
```

{{diagnostico:unsupportedStaticConstruct}}

:::parte especificacion

- esp-o-clases Notación orientada a objetos: clase, atributos, métodos, constructor e instanciación

:::parte ejercicios

- CON-C5-E1 Pedido que delega en Cliente
- CON-C5-E2 Biblioteca que delega en Libro
- CON-C5-E3 Termostato que delega en Sensor
- CON-C5-E4 Factura que delega en dos Productos
- CON-C5-E5 Equipo que delega en dos Jugadores
- CON-C5-E6 Reproductor que delega en Cancion
