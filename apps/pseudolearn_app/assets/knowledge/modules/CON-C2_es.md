:::parte pregunta

El módulo anterior, **El primer programa con clases**, mostró la forma general de una clase; este módulo fija sus reglas exactas: qué significa que un
miembro sea público o privado, cómo se escribe un método, y qué es —y qué no es— un constructor.

:::parte modelo-maquina

La visibilidad decide quién puede tocar cada casilla desde fuera del objeto: un atributo
{{lexema:privateVisibility}} solo se lee y se escribe desde dentro de un método de su propia clase; uno
{{lexema:publicVisibility}}, o sin marca —que es lo mismo, porque público es lo que se supone por
omisión—, se puede tocar desde cualquier parte. El constructor no es un método más: es la única pieza
que corre exactamente una vez, en el instante en que {{lexema:newInstance}} termina de reservar las
casillas del objeto y antes de que cualquier otro código las toque.

:::parte desarrollo

## La visibilidad es por miembro, no por bloque

{{ejemplo:example-c2-persona}}

{{diagrama:example-c2-persona#clases}}

Cada atributo y cada método lleva su propia marca de visibilidad, escrita justo delante. No hay una
sección «privada» que agrupe varios miembros: quien lee un miembro sabe su visibilidad sin tener que
buscar hacia arriba en el texto. `nombre` y `edad` son privados; `Nombre()`, `Edad()` y `Cumplir()` son
públicos, y son el único camino que el resto del programa tiene para leer o cambiar esas dos casillas.

## El constructor construye, no calcula

El constructor de `Persona` recibe los datos iniciales y los guarda en las casillas del objeto, una por
una, con {{lexema:thisObject}}. Nunca lleva visibilidad ni tipo de retorno: siempre es público y nunca
devuelve nada, porque su trabajo es dejar el objeto listo, no producir un valor. Una clase admite como
máximo un constructor —no hay una versión con dos parámetros y otra con tres—, y si no se declara
ninguno, el objeto se crea con todas sus casillas sin asignar.

## Los paréntesis de una llamada a método nunca faltan

`persona.Cumplir()` necesita sus paréntesis aunque no reciba ningún argumento, exactamente como un
subprograma normal (10.2): son lo que distingue una llamada de un acceso a un atributo que se llamara
igual, y el lenguaje no tiene otra forma de saberlo.

:::parte prediccion

- example-c2-persona#10# Con nombre "Ana" y edad 29, ¿qué edad escribe el programa después de llamar a Cumplir una vez?

Antes de comprobarlo, decide si `Cumplir` podría, en cambio, no cambiar nada visible desde fuera del
objeto si `edad` no fuera un atributo sino una variable local del método.

:::parte errores-frecuentes

## Un constructor con visibilidad

El constructor siempre es público: no tiene sentido crear un objeto y no poder llamar a la pieza que lo
construye. Escribirle una marca de visibilidad es tratarlo como si su visibilidad pudiera variar.

```pseudo
Clase Caja
    Privado Definir contenido Como Entero;

    Privado Metodo Constructor(unContenido Como Entero)
        Este.contenido <- unContenido;
    FinMetodo
FinClase
```

{{diagnostico:constructorVisibilityNotAllowed}}

## Dos constructores en la misma clase

No hay sobrecarga en este lenguaje (10.6), y un constructor no es la excepción: una clase admite como
máximo uno.

```pseudo
Clase Caja
    Privado Definir contenido Como Entero;

    Metodo Constructor()
        Este.contenido <- 0;
    FinMetodo

    Metodo Constructor(unContenido Como Entero)
        Este.contenido <- unContenido;
    FinMetodo
FinClase
```

{{diagnostico:duplicateConstructor}}

:::parte especificacion

- esp-o-clases Notación orientada a objetos: clase, atributos, métodos, constructor e instanciación

:::parte ejercicios

- CON-C2-E1 Clase Circulo con perímetro y área
- CON-C2-E2 Clase CajaFuerte con contraseña
- CON-C2-E3 Clase Empleado con salario neto
- CON-C2-E4 Clase RangoDeEdad con validación
- CON-C2-E5 Clase Libro con estado de préstamo
- CON-C2-E6 Clase Marcador con dos equipos
