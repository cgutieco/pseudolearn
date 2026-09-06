# Estructuras de control

Cinco construcciones deciden qué se ejecuta y cuántas veces: una selección de dos ramas, una selección
por etiquetas y tres bucles. No hay ninguna sexta, y en particular **no hay ninguna forma de salto**:
ni salida anticipada de un bucle, ni continuación, ni etiquetas. Es lo que hace que todo programa
escrito en esta notación se pueda dibujar como un estructograma sin huecos.

## Reglas comunes a las cinco

- El cuerpo de un bloque es una lista de sentencias que **puede estar vacía**, y un bloque vacío no es
  un error en ninguna de las cinco.
- Cualquier construcción se anida dentro de cualquier otra, sin límite declarado de profundidad.
- La condición de un condicional o de un bucle **tiene que ser de tipo lógico**. Que no lo sea es un
  fallo de significado, no de escritura: la sentencia está bien formada y lo que falla es de qué tipo
  es lo que se preguntó.
- Un bloque que se queda sin cerrar al final del archivo produce **un** diagnóstico, no una cascada, y
  ese diagnóstico señala también la línea donde el bloque se abrió.

## Condicional

Su forma es {{lexema:ifKeyword}} condición {{lexema:then}} cuerpo, con una rama contraria opcional
introducida por {{lexema:elseKeyword}}, y cierra con {{lexema:endIf}}.

La palabra intermedia {{lexema:then}} es **obligatoria siempre**, sin bandera de rigor que la relaje:
es lo que da al analizador un punto de sincronización limpio y permite decir «falta la palabra
intermedia» en vez de un error genérico. La rama contraria, ausente, equivale a un cuerpo vacío.

**No existe una construcción propia para el caso contrario encadenado.** Escribir varias condiciones en
cascada es anidar un condicional dentro de la rama contraria, cada uno con su propio cierre. El árbol
tampoco tiene un nodo de cadena: que la única sentencia de una rama contraria sea otro condicional es
un patrón que el dibujo puede reconocer, no una construcción distinta.

{{ejemplo:example-esp-control-condicional}}

## Selección múltiple

Su forma es {{lexema:switchKeyword}} expresión {{lexema:doKeyword}}, seguida de ramas donde cada lista
de etiquetas va separada de su cuerpo por {{lexema:branchSeparator}}, con una rama por defecto opcional
introducida por {{lexema:defaultCase}} y siempre la última, y cierra con {{lexema:endSwitch}}.

- **El selector es una expresión completa y se evalúa exactamente una vez**, antes de compararla con
  ninguna etiqueta.
- **Las etiquetas son literales**, no expresiones ni nombres de variable. Esa restricción es lo que
  permite detectar una etiqueta repetida comparando literales, sin conocer ni tipos ni valores; con
  expresiones como etiqueta, una rama muerta pasaría inadvertida hasta la ejecución.
- **No hay caída de una rama a la siguiente.** Ejecutada la rama que coincide, la ejecución continúa
  después del cierre.
- **No hay rangos como etiqueta**, y una etiqueta de tipo real está prohibida en cualquier perfil:
  comparar reales por igualdad es una trampa, no una exigencia que se pueda relajar.

Que ninguna rama coincida y no haya rama por defecto **no es un error**: no se ejecuta nada.

{{ejemplo:example-esp-control-seleccion}}

## Bucle condicional anterior

Su forma es {{lexema:whileKeyword}} condición {{lexema:doKeyword}} cuerpo, y cierra con
{{lexema:endWhile}}.

La condición se evalúa **antes de cada iteración, incluida la primera**, así que el cuerpo se ejecuta
**cero o más veces**. Un bucle cuya condición es falsa desde el principio no ejecuta nada y no es un
error: es el caso normal de recorrer una colección vacía.

{{ejemplo:example-esp-control-mientras}}

## Bucle condicional posterior

Su forma es {{lexema:repeat}} cuerpo {{lexema:until}} condición, y **no lleva palabra de cierre
propia**: la palabra que introduce la condición cierra el bloque.

La condición se evalúa **después de cada iteración**, así que el cuerpo se ejecuta **una o más veces**.
El bucle termina cuando la condición **se hace verdadera**: es una condición de salida, no de
permanencia, y es el punto donde más se confunde con el anterior.

**Solo hay una construcción posterior.** Una segunda con condición de permanencia sería la misma
construcción con la condición negada, y duplicar nodo, analizador, evaluador y tests no enseña nada
nuevo.

{{ejemplo:example-esp-control-repetir}}

## Bucle contado

Su forma es {{lexema:forKeyword}} variable {{lexema:assignment}} valor inicial {{lexema:to}} valor
final, con una cláusula opcional {{lexema:step}} paso, seguida de {{lexema:doKeyword}} y del cuerpo, y
cierra con {{lexema:endFor}}.

La variable de control es un **identificador**, no un designador cualquiera: un elemento de arreglo
como variable de control no tiene lectura pedagógica y complica el diagnóstico sin comprar nada.

{{ejemplo:example-esp-control-para}}

## Qué garantiza el bucle contado, paso a paso

Cada punto es observable en la tabla de prueba, y por eso está fijado y no se deja al motor:

1. El valor inicial, el valor final y el paso se evalúan **exactamente una vez y en ese orden**.
   Omitido el paso, vale uno.
2. Si el paso es **cero**, se emite un fallo de ejecución y el bucle no se ejecuta.
3. Se asigna el valor inicial a la variable de control.
4. **La prueba va antes del cuerpo.** Con paso positivo se itera mientras la variable sea menor o igual
   que el valor final; con paso negativo, mientras sea mayor o igual.
5. Se ejecuta el cuerpo.
6. Se suma el paso a la variable de control y se vuelve al punto 4.
7. Al salir, **la variable de control conserva el primer valor que falló la prueba**.

De ahí salen tres consecuencias que conviene tener presentes: los tres valores **se congelan**, de modo
que modificar dentro del cuerpo la variable que se usó como valor final no cambia el bucle; **la
dirección la decide el signo del paso** y nunca la relación entre el valor inicial y el final, así que
un bucle cuyo inicial es mayor que su final y cuyo paso es positivo simplemente no itera; y la variable
de control **conserva un valor definido al salir**, porque un valor indefinido es justo lo que una
tabla de prueba no puede mostrar.

Modificar la variable de control dentro del cuerpo es una advertencia y no un error. Prohibirlo
exigiría demostrar que no ocurre, y con el paso por referencia eso es indecidible en general: una
advertencia es honesta, un error que a veces no se detecta no lo es.

{{ejemplo:example-esp-control-para-garantias}}
