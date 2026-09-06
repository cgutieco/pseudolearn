---
name: ast-node-authoring
description: Añadir o modificar un nodo del árbol sintáctico del núcleo. Usar al implementar una construcción nueva del lenguaje. Cubre la forma obligatoria del nodo, por qué los nodos no tienen métodos, el registro en el recorrido estructural, y cómo atender los consumidores que el compilador señale.
---

# Nodos del árbol sintáctico

## Forma obligatoria

Un nodo es **datos y nada más**: una clase sellada y final, con campos inmutables, su span y su
identificador de nodo. Sin ningún método.

**Sin métodos significa sin ninguno.** Ni de evaluación, ni de impresión, ni de chequeo de tipos, ni de
recorrido. Un árbol «inteligente» con lógica repartida en sus nodos es la primera forma en la que un
proyecto así se vuelve inmanejable: la misma preocupación acaba repartida en treinta archivos y no hay
un sitio donde leerla completa.

El identificador de nodo lo asigna el parser con el generador inyectado. Nunca se genera dentro del
nodo, porque entonces el nodo tendría comportamiento y dejaría de ser reproducible en un test.

## Por qué clases selladas y no un visitor

El árbol lo recorren, en momentos distintos, el chequeador de tipos, el evaluador, el impresor de
pseudocódigo, los exportadores a lenguajes reales y el cálculo del diagrama.

Un visitor abstracto con implementaciones por defecto **se traga en silencio** un nodo nuevo: compila
perfectamente y el consumidor simplemente no hace nada con la construcción nueva. Es un fallo que no
rompe el build y que aparece semanas después.

Con clases selladas, una coincidencia de patrones que no cubra el subtipo nuevo **no compila**. El
compilador se convierte en la lista exacta de los sitios que hay que atender. Eso es exactamente lo que
se quiere al añadir una construcción al lenguaje.

Corolario: **el nodo tiene que ser `final`**. Si admite subclases externas, la exhaustividad se pierde y
con ella la garantía entera.

## Al añadir un nodo

1. **Especificá antes la construcción** en la especificación del lenguaje. La sintaxis se escribe antes
   del parser, no después.
2. Creá el nodo como clase final del árbol sellado que le corresponde: sentencia, expresión o
   declaración.
3. **Registralo en el recorrido estructural**, la única función del paquete que conoce los hijos de cada
   nodo y su orden. Olvidarlo es el fallo más silencioso posible: todo compila y los consumidores
   genéricos —recolectar identificadores, buscar el nodo en una posición del editor, calcular el span
   envolvente— dejan de ver la subestructura.
4. **Compilá y atendé cada error de exhaustividad** que el compilador señale. Esa lista es la checklist.
   No hay ninguna rama por defecto que puedas añadir para silenciarla: añadirla es renunciar a la
   garantía.
5. Escribí los tests: construcción del nodo con su span exacto, y el recorrido estructural devolviendo
   los hijos en el orden correcto.

## Sobre el orden de los hijos

El recorrido estructural devuelve los hijos **en orden de aparición en el código fuente**. No en orden
de evaluación, no en orden de declaración de los campos. De eso dependen el resaltado del editor y la
búsqueda del nodo que contiene una posición, y un orden incorrecto produce un fallo que se manifiesta
como una interfaz que resalta lo que no debe.

## Errores frecuentes

- Un nodo sin span, o con el span de otra cosa. El span de un nodo abarca desde su primer token hasta su
  último token, incluidos los de cierre.
- Un nodo que guarda el lexema con el que se escribió una palabra clave. El árbol referencia tipos de
  token; el lexema pertenece al perfil. Si el árbol recuerda el texto, el impresor y los exportadores
  quedan atados al perfil con el que se escribió el programa.
- Un nodo con un campo mutable.
- Un nodo que reutiliza otro «porque se parece». Dos construcciones distintas del lenguaje son dos
  nodos, aunque hoy tengan los mismos campos: divergirán, y para entonces el árbol tendrá consumidores.
- Añadir una rama por defecto a una coincidencia de patrones para que compile.
