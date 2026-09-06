:::parte pregunta

`Gato` y `Perro` son mascotas: comparten un nombre y la capacidad de hablar, pero cada una habla
distinto. Escribir esa relación copiando el atributo `nombre` en cada clase duplica lo que ya es común;
este módulo introduce la herencia, para declarar «esto es una mascota, además de lo suyo» una sola vez.

:::parte modelo-maquina

Una subclase no vuelve a crear las casillas de su superclase: las hereda enteras. `Gato Hereda De
Mascota` significa que todo objeto `Gato` tiene, además de sus propias casillas, las de `Mascota`. Al
construirlo, primero se ejecuta el constructor de `Mascota` sobre esas casillas heredadas, y después el
de `Gato` sobre las suyas: el objeto se construye de afuera hacia adentro de la jerarquía, superclase
primero.

:::parte desarrollo

## Una cadena de construcción, no dos constructores sueltos

{{ejemplo:example-c4-mascotas}}

{{diagrama:example-c4-mascotas#clases}}

El constructor de `Gato` empieza con `Super.Constructor(unNombre)`: es obligatorio porque el
constructor de `Mascota` tiene parámetros, y sin esa llamada las casillas heredadas de `Mascota`
quedarían sin asignar. `Este.Nombre()` dentro de `Hablar` de `Gato` llama al método heredado sin
volver a declararlo: `Gato` no tiene su propio método `Nombre`, y no le hace falta.

## El despacho mira el objeto real, no la variable que lo nombra

{{ejemplo:example-c4-despacho}}

{{diagrama:example-c4-despacho#clases}}

`uno` y `dos` están declaradas `Como Mascota`, pero `uno.Hablar()` ejecuta el `Hablar` de `Perro` y
`dos.Hablar()` el de `Gato`: la llamada a un método siempre se resuelve contra la clase real del
objeto, nunca contra el tipo con el que se declaró la variable que lo nombra. Es la diferencia entre
qué tipo **dice** el texto y qué tipo **es** el objeto en ese momento, y es lo que hace útil declarar
código que trabaja con `Mascota` sin saber de antemano si va a recibir un `Perro` o un `Gato`.

## Sobrescribir es tener el mismo nombre y la misma firma

`Hablar` en `Gato` sobrescribe el `Hablar` de `Mascota` sin ninguna marca especial: basta con
declararlo otra vez, con el mismo número de parámetros, los mismos tipos y el mismo tipo de retorno. Una
firma distinta no es una segunda versión: es un error, porque deja de tener sentido decir cuál de las
dos «es» el método que la subclase sobrescribió.

:::parte prediccion

- example-c4-despacho#12# ¿Qué dos líneas escribe el programa, en orden?

Antes de comprobarlo, decide si el resultado depende del tipo declarado de `uno` y `dos` —`Mascota` en
los dos casos— o del tipo real del objeto que cada una contiene.

:::parte errores-frecuentes

## Más de una superclase

Este lenguaje solo tiene herencia simple. Una lista de superclases separadas por coma es exactamente el
patrón de la herencia múltiple, y se rechaza en el propio análisis.

```pseudo
Clase Volador
FinClase

Clase Nadador
FinClase

Clase PatoDeGoma Hereda De Volador, Nadador
FinClase

Algoritmo Probar
FinAlgoritmo
```

{{diagnostico:multipleInheritanceNotSupported}}

## Una jerarquía que se hereda a sí misma

Si `A` hereda de `B` y `B` hereda de `A`, ninguna de las dos tiene una base real de la que partir: la
cadena de construcción nunca podría empezar.

```pseudo
Clase A Hereda De B
FinClase

Clase B Hereda De A
FinClase

Algoritmo Probar
FinAlgoritmo
```

{{diagnostico:circularInheritance}}

## Olvidar la llamada obligatoria al constructor de la superclase

Si la superclase tiene un constructor con parámetros, la subclase tiene que invocarlo como primera
sentencia de su propio constructor. Sin esa llamada, las casillas heredadas se quedan sin el valor que
el constructor de la superclase les daría.

```pseudo
Clase Mascota
    Privado Definir nombre Como Cadena;

    Metodo Constructor(unNombre Como Cadena)
        Este.nombre <- unNombre;
    FinMetodo
FinClase

Clase Gato Hereda De Mascota
    Metodo Constructor(unNombre Como Cadena)
        Escribir unNombre;
    FinMetodo
FinClase

Algoritmo Probar
FinAlgoritmo
```

{{diagnostico:missingSuperConstructorCall}}

## Sobrescribir con una firma distinta

Un método con el mismo nombre que uno heredado, pero con otro número o tipo de parámetros, no es una
sobrescritura válida: es una declaración incompatible con la que ya existe.

```pseudo
Clase Mascota
    Publico Metodo Hablar() Como Cadena
        Retornar "...";
    FinMetodo
FinClase

Clase Gato Hereda De Mascota
    Publico Metodo Hablar(volumen Como Entero) Como Cadena
        Retornar "Miau";
    FinMetodo
FinClase

Algoritmo Probar
FinAlgoritmo
```

{{diagnostico:incompatibleMethodOverride}}

:::parte especificacion

- esp-o-clases Herencia, objeto actual y superclase, y despacho dinámico

:::parte ejercicios

- CON-C4-E1 Jerarquía Figura con Area sobrescrito
- CON-C4-E2 Empleado y Gerente con bono heredado
- CON-C4-E3 Vehiculo y Motocicleta con Super
- CON-C4-E4 Despacho de tres formas distintas
- CON-C4-E5 Cuenta de ahorro que hereda de Cuenta
- CON-C4-E6 Jerarquía de tres niveles
