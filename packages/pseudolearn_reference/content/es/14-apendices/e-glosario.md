---
id: apendice.glosario
numero: "E.1"
tipo: apendice
titulo: Glosario
---

Los términos técnicos del libro con una definición breve y la sección donde se explican.

| Término | Definición |
|---|---|
| algoritmo | La unidad principal de un programa; cada texto tiene exactamente una. [Estructura](#programas.estructura) |
| ámbito | El tramo de texto donde un nombre existe, desde su declaración hasta el cierre de su bloque. [Ámbitos](#subprogramas.ambito) |
| anfitrión | Quien ejecuta el programa —la app, la terminal o un ejecutable— y le da entrada, salida y capacidades. [Efectos](#tareas.efectos) |
| argumento | El valor que se pasa en una llamada. [Parámetros](#subprogramas.parametros) |
| asa | El valor `Tarea` que guarda una tarea lanzada para esperar su resultado. [Ámbitos de tareas](#tareas.ambitos) |
| asignación | Guardar un valor nuevo en un lugar con `<-`. [Asignación](#declaraciones.asignacion) |
| capacidad | Una llave opaca que da acceso a un recurso exterior. [Efectos y capacidades](#tareas.efectos) |
| caso base | El caso de una recursión que se resuelve sin volver a llamarse. [Recursión](#subprogramas.recursion) |
| cinta | El registro de los efectos de una ejecución, que permite reproducirla. [Efectos y cinta](#motor.efectos) |
| clase | Un tipo que agrupa atributos y métodos; sus valores son objetos. [Clases](#objetos.clase) |
| constante | Un nombre para un valor fijo que se calcula al analizar. [Constantes](#declaraciones.constante) |
| cortocircuito | Dejar sin calcular la parte derecha de `Y` u `O` cuando la izquierda ya decide. [Lógicos](#expresiones.logicos) |
| designador | Una expresión que nombra un lugar donde guardar: variable, casilla o atributo. [Designadores](#declaraciones.designadores) |
| despacho | Elegir el método según la clase real del objeto. [Herencia](#objetos.herencia) |
| diagnóstico | Un aviso del motor con código, clase, severidad y posición. [Anatomía](#diagnosticos.anatomia) |
| efecto | Cualquier acción hacia fuera del programa: escribir, leer, abrir un archivo. [Orden de los efectos](#motor.efectos) |
| expresión | Una combinación de valores y operadores que se calcula. [Aritméticos](#expresiones.aritmeticos) |
| función pura | Una `Funcion`, que solo calcula y no tiene efectos. [Pureza](#subprogramas.pureza) |
| identidad | El número de creación de un objeto o arreglo; nunca cambia ni se reutiliza. [Copia e identidad](#objetos.copia) |
| interfaz | Una lista de firmas que una clase promete cumplir. [Interfaces](#objetos.interfaces) |
| marco | El espacio propio de cada llamada para sus parámetros y variables. [Llamadas](#subprogramas.llamada) |
| módulo | Un archivo de un proyecto. [Módulos](#programas.modulos) |
| montón | La memoria donde viven los objetos, arreglos y textos creados al ejecutar. [Memoria](#motor.memoria) |
| objeto | Un valor de tipo clase, creado con `Nuevo`. [Constructores](#objetos.constructor) |
| paso por referencia | Pasar la variable misma, no una copia. [Por referencia](#subprogramas.referencia) |
| perfil | El idioma de las palabras del programa: español o inglés. [Perfiles](#lectura.perfiles) |
| precedencia | El orden en que se agrupan los operadores. [Precedencia](#expresiones.precedencia) |
| receptor | El objeto sobre el que se llama un método, nombrado `Este` dentro de él. [Métodos](#objetos.metodos) |
| representación intermedia | La forma de instrucciones simples a la que el motor traduce el programa. [Capas](#motor.capas) |
| severidad | La consecuencia de un diagnóstico: error, advertencia o información. [Severidad](#diagnosticos.severidad) |
| suspendible | Una unidad que puede pausarse en `Aguardar`. [Suspendibles](#tareas.suspendible) |
| tarea | Una ejecución que avanza a la vez que otras dentro de un ámbito `Tareas`. [Ámbitos de tareas](#tareas.ambitos) |
| traza | La lista de eventos de una ejecución, paso a paso. [Observar la ejecución](#motor.observacion) |
| trampa | Un fallo durante la ejecución que detiene el programa. [Errores](#vision.errores) |
| variable | Un nombre ligado a un lugar de la memoria cuyo valor puede cambiar. [Definir](#declaraciones.definir) |
