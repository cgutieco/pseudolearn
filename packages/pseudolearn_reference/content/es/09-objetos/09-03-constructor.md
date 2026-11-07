---
id: objetos.constructor
numero: "9.3"
tipo: construccion
titulo: "Constructores y `Nuevo`"
anclas: [LANG.CLASS.CONSTRUCTOR#R1, LANG.CLASS.INSTANTIATION#R1]
fichas: [help.constructor, help.instantiation]
diagnosticos: [variableUsedUninitialized, argumentCountMismatch]
terminos: [constructor, instancia]
---

::: frase
`Nuevo` crea un objeto y ejecuta su constructor, que prepara los atributos antes de que nadie lo use.
:::

## Cómo se escribe {#escribe}

```forma
Metodo Constructor(«parámetros»)
  «instrucciones»
FinMetodo
Nuevo «Clase»(«argumentos»)
```

```railes produccion=constructorMember
```

::: partes
- `Metodo Constructor` declara el constructor. No lleva visibilidad ni tipo de retorno.
- Cada clase tiene **como mucho uno**. Si no se escribe, existe uno implícito sin parámetros que no da valor a nada.
- `Nuevo` seguido del nombre de la clase y los argumentos crea el objeto. Los paréntesis son obligatorios.
:::

## Cómo funciona {#funciona}

Declarar una variable de tipo clase **no crea ningún objeto**: la variable queda sin valor hasta que se le asigna uno creado con `Nuevo`.

```figura id=nuevo-pasos
pie: Lo que ocurre al evaluar `Nuevo Contador(10)`.
paso: Se reserva un objeto nuevo con sus atributos sin valor.
paso: Se ejecuta el constructor con `inicial` = 10, y `Este.valor` recibe 10.
paso: La referencia al objeto se guarda en la variable.
```

```programa id=con-constructor titulo="Un constructor que prepara el objeto" ejecutar
Clase Contador
  Privado Definir valor Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.valor <- inicial;
  FinMetodo

  Metodo Actual() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Crear
  Escribir Nuevo Contador(10).Actual();
FinAlgoritmo
```

```salida
10
```

Si la clase hereda, antes del cuerpo del constructor se construye la parte de la superclase. Cuando el constructor de la superclase pide argumentos, la primera sentencia tiene que ser `Super.Constructor(…)`.

::: errores
Una variable de clase sin `Nuevo` no tiene objeto:

```programa id=sin-nuevo titulo="Usar un objeto que no se creó" ejecutar
Clase Punto
  Definir x Como Entero;
FinClase

Algoritmo SinNuevo
  Definir p Como Punto;
  p.x <- 1;
FinAlgoritmo
```

```diagnosticos
variableUsedUninitialized
```
:::

::: por-dentro
`Nuevo` es una instrucción de reserva seguida de una llamada al constructor con el objeto recién creado como receptor.

```ri programa=con-constructor
```
:::

::: resumen
- `Nuevo Clase(…)` crea un objeto y ejecuta su constructor.
- Hay como mucho un constructor; sin él, uno implícito que no inicializa.
- Declarar una variable de clase no crea el objeto.
- La superclase se construye primero.
:::

::: vease
- [Clases y atributos](#objetos.clase)
- [Herencia y sobrescritura](#objetos.herencia)
:::
