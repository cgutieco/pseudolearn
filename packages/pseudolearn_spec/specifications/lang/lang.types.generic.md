---
{
  "formato": "see/1",
  "id": "LANG.TYPES.GENERIC",
  "titulo": "Genéricos de primer orden",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Parámetros de tipo en registros, subprogramas, clases, interfaces y variantes, inferencia local e instancias acotadas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.FUNCTION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.RECORD",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Genéricos de primer orden

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un registro, un subprograma, una clase, una interfaz o una variante declara parámetros de tipo con <T, U> tras su nombre; un tipo genérico se escribe nombre<argumentos de tipo> con exactamente tantos argumentos como parámetros (typeArgumentCountMismatch). Cada plantilla (subprograma, registro, clase, interfaz o variante), tenga o no instancias y sea o no pública, se comprueba una sola vez en su propio módulo con cada parámetro opaco: un valor opaco solo puede copiarse, pasarse, retornarse, almacenarse en campos y construir registros y variantes genéricos; operarlo, compararlo o escribirlo es error en la definición, haya o no instancias. Una llamada infiere cada argumento de tipo unificando estructuralmente los tipos de los parámetros con los de los argumentos (parámetro directo, registro, clase o variante genéricos, arreglo o tipo función); construir un registro genérico infiere desde sus campos; no hay instanciación explícita en llamadas. Un parámetro de tipo sin determinar o con dos valores distintos produce cannotInferTypeArgument. Cada combinación de plantilla y argumentos de tipo canónicos es una instancia única con función, registro, clase, interfaz o variante propios, nombrada nombre<tipos>; las instancias alcanzables se recogen de forma cerrada y una plantilla sin instanciar no genera ninguna. El programa admite como máximo 64 instancias entre todas las formas; superar el límite, incluida la recursión polimórfica expansiva, produce genericInstanceLimitExceeded. Los parámetros de tipo admiten una restricción nominal T: I o T: I<argumentos>, cuyos argumentos pueden nombrar parámetros de la misma plantilla, comprobada en la definición y en cada argumento concreto. Un error de la definición se notifica una sola vez en la plantilla aunque varias instancias o varios módulos la usen.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C16",
    "C17",
    "C18",
    "C19",
    "C20",
    "C41",
    "C53",
    "C54",
    "C55",
    "C56"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Clase nombre<T> declara una plantilla de clase e Interfaz nombre<T> una plantilla de interfaz. Nuevo nombre<argumentos>(...) crea un objeto de la instancia indicada; los argumentos pueden omitirse solo cuando el tipo esperado por una declaración, una asignación, un retorno o un argumento ya es una instancia de la misma plantilla, que los fija; en otro caso Nuevo nombre(...) es typeArgumentCountMismatch. Cada instancia es una clase concreta con campos, constructor, métodos y ranuras virtuales propios, obtenidos al sustituir los parámetros por los argumentos, y conserva el despacho virtual ordinario. Hereda De Base<argumentos> y Realiza I<argumentos> admiten argumentos que nombran parámetros de la clase; una clase no genérica puede heredar de una instancia concreta. Las instancias son invariantes: dos instancias con argumentos distintos son tipos distintos sin asignabilidad entre ellas (incompatibleTypesInAssignment) y la asignabilidad de objetos solo sigue la cadena de herencia de cada instancia. Cada I<argumentos> es una interfaz nominal distinta que se realiza y se exige como restricción exactamente con esos argumentos. Los métodos no declaran parámetros de tipo propios: usan los de su clase. Una cadena de herencia entre plantillas que vuelve a una plantilla ya recorrida es circularInheritance, notificada una vez en la plantilla donde empieza el recorrido.",
  "verificacion": [
    "C21",
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29",
    "C30",
    "C31",
    "C32",
    "C33",
    "C34",
    "C35",
    "C36",
    "C37",
    "C38",
    "C39",
    "C40"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una plantilla de nivel superior sigue la visibilidad de las demás unidades del módulo: con Publico se importa por símbolo, con o sin alias, se reexporta con Exportar y, si es un subprograma, también se invoca como nombre-local.plantilla(argumentos) a través de un módulo importado; sin Publico, importarla o reexportarla produce privateImport o privateReexport. Una plantilla importada conserva la identidad de su declaración: su cuerpo, sus firmas y sus restricciones se resuelven en el módulo que la declara y nunca en el que la usa, y cada combinación de plantilla y argumentos de tipo canónicos es una única instancia en todo el programa, compartida por todos los módulos que la nombran. En un proyecto, el nombre de una instancia se califica con el módulo de la plantilla (paquete.modulo.nombre<tipos>). Dos plantillas homónimas de módulos distintos, importadas con alias distintos, producen instancias distintas e incompatibles entre sí. Las restricciones se comprueban con cada argumento concreto del módulo que instancia y el diagnóstico genericConstraintNotSatisfied se ubica en ese uso. El límite de 64 instancias cuenta las instancias de todos los módulos del programa. El conjunto de instancias y la salida de un proyecto no dependen del orden de sus archivos.",
  "verificacion": [
    "C42",
    "C43",
    "C44",
    "C45",
    "C46",
    "C47",
    "C48",
    "C49",
    "C50",
    "C51",
    "C52"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4);\nFinAlgoritmo\n",
    "en": "subroutine identity<T>(value as T) as T\nreturn value;\nendSubroutine\nalgorithm P\nwrite identity(4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4);\nEscribir identidad(2.5);\nEscribir identidad(\"hola\");\nFinAlgoritmo\n",
    "en": "subroutine identity<T>(value as T) as T\nreturn value;\nendSubroutine\nalgorithm P\nwrite identity(4);\nwrite identity(2.5);\nwrite identity(\"hola\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n2.5\nhola\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Caja<T>\nDefinir v Como T;\nFinRegistro\nSubProceso desenvolver<T>(c Como Caja<T>) Como T\nRetornar c.v;\nFinSubProceso\nAlgoritmo P\nDefinir c Como Caja<Entero> <- Caja(7);\nEscribir desenvolver(c);\nEscribir desenvolver(Caja(\"x\"));\nFinAlgoritmo\n",
    "en": "record Box<T>\ndefine v as T;\nendRecord\nsubroutine unwrap<T>(c as Box<T>) as T\nreturn c.v;\nendSubroutine\nalgorithm P\ndefine c as Box<integer> <- Box(7);\nwrite unwrap(c);\nwrite unwrap(Box(\"x\"));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\nx\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Par<K, V>\nDefinir primero Como K;\nDefinir segundo Como V;\nFinRegistro\nSubProceso intercambiar<K, V>(p Como Par<K, V>) Como Par<V, K>\nRetornar Par(p.segundo, p.primero);\nFinSubProceso\nAlgoritmo P\nDefinir q Como Par<Cadena, Entero> <- intercambiar(Par(1, \"hola\"));\nEscribir q.primero;\nEscribir q.segundo;\nFinAlgoritmo\n",
    "en": "record Pair<K, V>\ndefine first as K;\ndefine second as V;\nendRecord\nsubroutine swap<K, V>(p as Pair<K, V>) as Pair<V, K>\nreturn Pair(p.second, p.first);\nendSubroutine\nalgorithm P\ndefine q as Pair<string, integer> <- swap(Pair(1, \"hola\"));\nwrite q.first;\nwrite q.second;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\nSubProceso aplicar<T, U>(f Como SubProceso(T) Como U, x Como T) Como U\nRetornar f(x);\nFinSubProceso\nAlgoritmo P\nEscribir aplicar(doble, 4);\nFinAlgoritmo\n",
    "en": "subroutine double(n as integer) as integer\nreturn n * 2;\nendSubroutine\nsubroutine apply<T, U>(f as subroutine(T) as U, x as T) as U\nreturn f(x);\nendSubroutine\nalgorithm P\nwrite apply(double, 4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso contar<T>(x Como T, n Como Entero)\nSi n > 0 Entonces\nEscribir n;\ncontar(x, n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\ncontar(\"a\", 3);\nFinAlgoritmo\n",
    "en": "subroutine count<T>(x as T, n as integer)\nif n > 0 then\nwrite n;\ncount(x, n - 1);\nendIf\nendSubroutine\nalgorithm P\ncount(\"a\", 3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n2\n1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R1\nDefinir v Como Entero;\nFinRegistro\nRegistro R2\nDefinir v Como Entero;\nFinRegistro\nRegistro R3\nDefinir v Como Entero;\nFinRegistro\nRegistro R4\nDefinir v Como Entero;\nFinRegistro\nRegistro R5\nDefinir v Como Entero;\nFinRegistro\nRegistro R6\nDefinir v Como Entero;\nFinRegistro\nRegistro R7\nDefinir v Como Entero;\nFinRegistro\nRegistro R8\nDefinir v Como Entero;\nFinRegistro\nRegistro R9\nDefinir v Como Entero;\nFinRegistro\nRegistro R10\nDefinir v Como Entero;\nFinRegistro\nSubProceso usar<T>(x Como T)\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nusar(R1(1));\nusar(R2(1));\nusar(R3(1));\nusar(R4(1));\nusar(R5(1));\nusar(R6(1));\nusar(R7(1));\nusar(R8(1));\nusar(R9(1));\nusar(R10(1));\nFinAlgoritmo\n",
    "en": "record R1\ndefine v as integer;\nendRecord\nrecord R2\ndefine v as integer;\nendRecord\nrecord R3\ndefine v as integer;\nendRecord\nrecord R4\ndefine v as integer;\nendRecord\nrecord R5\ndefine v as integer;\nendRecord\nrecord R6\ndefine v as integer;\nendRecord\nrecord R7\ndefine v as integer;\nendRecord\nrecord R8\ndefine v as integer;\nendRecord\nrecord R9\ndefine v as integer;\nendRecord\nrecord R10\ndefine v as integer;\nendRecord\nsubroutine consume<T>(x as T)\nwrite 1;\nendSubroutine\nalgorithm P\nconsume(R1(1));\nconsume(R2(1));\nconsume(R3(1));\nconsume(R4(1));\nconsume(R5(1));\nconsume(R6(1));\nconsume(R7(1));\nconsume(R8(1));\nconsume(R9(1));\nconsume(R10(1));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R1\nDefinir v Como Entero;\nFinRegistro\nRegistro R2\nDefinir v Como Entero;\nFinRegistro\nRegistro R3\nDefinir v Como Entero;\nFinRegistro\nRegistro R4\nDefinir v Como Entero;\nFinRegistro\nRegistro R5\nDefinir v Como Entero;\nFinRegistro\nRegistro R6\nDefinir v Como Entero;\nFinRegistro\nRegistro R7\nDefinir v Como Entero;\nFinRegistro\nRegistro R8\nDefinir v Como Entero;\nFinRegistro\nRegistro R9\nDefinir v Como Entero;\nFinRegistro\nRegistro R10\nDefinir v Como Entero;\nFinRegistro\nRegistro R11\nDefinir v Como Entero;\nFinRegistro\nRegistro R12\nDefinir v Como Entero;\nFinRegistro\nRegistro R13\nDefinir v Como Entero;\nFinRegistro\nRegistro R14\nDefinir v Como Entero;\nFinRegistro\nRegistro R15\nDefinir v Como Entero;\nFinRegistro\nRegistro R16\nDefinir v Como Entero;\nFinRegistro\nRegistro R17\nDefinir v Como Entero;\nFinRegistro\nRegistro R18\nDefinir v Como Entero;\nFinRegistro\nRegistro R19\nDefinir v Como Entero;\nFinRegistro\nRegistro R20\nDefinir v Como Entero;\nFinRegistro\nRegistro R21\nDefinir v Como Entero;\nFinRegistro\nRegistro R22\nDefinir v Como Entero;\nFinRegistro\nRegistro R23\nDefinir v Como Entero;\nFinRegistro\nRegistro R24\nDefinir v Como Entero;\nFinRegistro\nRegistro R25\nDefinir v Como Entero;\nFinRegistro\nRegistro R26\nDefinir v Como Entero;\nFinRegistro\nRegistro R27\nDefinir v Como Entero;\nFinRegistro\nRegistro R28\nDefinir v Como Entero;\nFinRegistro\nRegistro R29\nDefinir v Como Entero;\nFinRegistro\nRegistro R30\nDefinir v Como Entero;\nFinRegistro\nRegistro R31\nDefinir v Como Entero;\nFinRegistro\nRegistro R32\nDefinir v Como Entero;\nFinRegistro\nRegistro R33\nDefinir v Como Entero;\nFinRegistro\nRegistro R34\nDefinir v Como Entero;\nFinRegistro\nRegistro R35\nDefinir v Como Entero;\nFinRegistro\nRegistro R36\nDefinir v Como Entero;\nFinRegistro\nRegistro R37\nDefinir v Como Entero;\nFinRegistro\nRegistro R38\nDefinir v Como Entero;\nFinRegistro\nRegistro R39\nDefinir v Como Entero;\nFinRegistro\nRegistro R40\nDefinir v Como Entero;\nFinRegistro\nRegistro R41\nDefinir v Como Entero;\nFinRegistro\nRegistro R42\nDefinir v Como Entero;\nFinRegistro\nRegistro R43\nDefinir v Como Entero;\nFinRegistro\nRegistro R44\nDefinir v Como Entero;\nFinRegistro\nRegistro R45\nDefinir v Como Entero;\nFinRegistro\nRegistro R46\nDefinir v Como Entero;\nFinRegistro\nRegistro R47\nDefinir v Como Entero;\nFinRegistro\nRegistro R48\nDefinir v Como Entero;\nFinRegistro\nRegistro R49\nDefinir v Como Entero;\nFinRegistro\nRegistro R50\nDefinir v Como Entero;\nFinRegistro\nRegistro R51\nDefinir v Como Entero;\nFinRegistro\nRegistro R52\nDefinir v Como Entero;\nFinRegistro\nRegistro R53\nDefinir v Como Entero;\nFinRegistro\nRegistro R54\nDefinir v Como Entero;\nFinRegistro\nRegistro R55\nDefinir v Como Entero;\nFinRegistro\nRegistro R56\nDefinir v Como Entero;\nFinRegistro\nRegistro R57\nDefinir v Como Entero;\nFinRegistro\nRegistro R58\nDefinir v Como Entero;\nFinRegistro\nRegistro R59\nDefinir v Como Entero;\nFinRegistro\nRegistro R60\nDefinir v Como Entero;\nFinRegistro\nRegistro R61\nDefinir v Como Entero;\nFinRegistro\nRegistro R62\nDefinir v Como Entero;\nFinRegistro\nRegistro R63\nDefinir v Como Entero;\nFinRegistro\nRegistro R64\nDefinir v Como Entero;\nFinRegistro\nSubProceso usar<T>(x Como T)\nFinSubProceso\nAlgoritmo P\nusar(R1(1));\nusar(R2(1));\nusar(R3(1));\nusar(R4(1));\nusar(R5(1));\nusar(R6(1));\nusar(R7(1));\nusar(R8(1));\nusar(R9(1));\nusar(R10(1));\nusar(R11(1));\nusar(R12(1));\nusar(R13(1));\nusar(R14(1));\nusar(R15(1));\nusar(R16(1));\nusar(R17(1));\nusar(R18(1));\nusar(R19(1));\nusar(R20(1));\nusar(R21(1));\nusar(R22(1));\nusar(R23(1));\nusar(R24(1));\nusar(R25(1));\nusar(R26(1));\nusar(R27(1));\nusar(R28(1));\nusar(R29(1));\nusar(R30(1));\nusar(R31(1));\nusar(R32(1));\nusar(R33(1));\nusar(R34(1));\nusar(R35(1));\nusar(R36(1));\nusar(R37(1));\nusar(R38(1));\nusar(R39(1));\nusar(R40(1));\nusar(R41(1));\nusar(R42(1));\nusar(R43(1));\nusar(R44(1));\nusar(R45(1));\nusar(R46(1));\nusar(R47(1));\nusar(R48(1));\nusar(R49(1));\nusar(R50(1));\nusar(R51(1));\nusar(R52(1));\nusar(R53(1));\nusar(R54(1));\nusar(R55(1));\nusar(R56(1));\nusar(R57(1));\nusar(R58(1));\nusar(R59(1));\nusar(R60(1));\nusar(R61(1));\nusar(R62(1));\nusar(R63(1));\nusar(R64(1));\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "record R1\ndefine v as integer;\nendRecord\nrecord R2\ndefine v as integer;\nendRecord\nrecord R3\ndefine v as integer;\nendRecord\nrecord R4\ndefine v as integer;\nendRecord\nrecord R5\ndefine v as integer;\nendRecord\nrecord R6\ndefine v as integer;\nendRecord\nrecord R7\ndefine v as integer;\nendRecord\nrecord R8\ndefine v as integer;\nendRecord\nrecord R9\ndefine v as integer;\nendRecord\nrecord R10\ndefine v as integer;\nendRecord\nrecord R11\ndefine v as integer;\nendRecord\nrecord R12\ndefine v as integer;\nendRecord\nrecord R13\ndefine v as integer;\nendRecord\nrecord R14\ndefine v as integer;\nendRecord\nrecord R15\ndefine v as integer;\nendRecord\nrecord R16\ndefine v as integer;\nendRecord\nrecord R17\ndefine v as integer;\nendRecord\nrecord R18\ndefine v as integer;\nendRecord\nrecord R19\ndefine v as integer;\nendRecord\nrecord R20\ndefine v as integer;\nendRecord\nrecord R21\ndefine v as integer;\nendRecord\nrecord R22\ndefine v as integer;\nendRecord\nrecord R23\ndefine v as integer;\nendRecord\nrecord R24\ndefine v as integer;\nendRecord\nrecord R25\ndefine v as integer;\nendRecord\nrecord R26\ndefine v as integer;\nendRecord\nrecord R27\ndefine v as integer;\nendRecord\nrecord R28\ndefine v as integer;\nendRecord\nrecord R29\ndefine v as integer;\nendRecord\nrecord R30\ndefine v as integer;\nendRecord\nrecord R31\ndefine v as integer;\nendRecord\nrecord R32\ndefine v as integer;\nendRecord\nrecord R33\ndefine v as integer;\nendRecord\nrecord R34\ndefine v as integer;\nendRecord\nrecord R35\ndefine v as integer;\nendRecord\nrecord R36\ndefine v as integer;\nendRecord\nrecord R37\ndefine v as integer;\nendRecord\nrecord R38\ndefine v as integer;\nendRecord\nrecord R39\ndefine v as integer;\nendRecord\nrecord R40\ndefine v as integer;\nendRecord\nrecord R41\ndefine v as integer;\nendRecord\nrecord R42\ndefine v as integer;\nendRecord\nrecord R43\ndefine v as integer;\nendRecord\nrecord R44\ndefine v as integer;\nendRecord\nrecord R45\ndefine v as integer;\nendRecord\nrecord R46\ndefine v as integer;\nendRecord\nrecord R47\ndefine v as integer;\nendRecord\nrecord R48\ndefine v as integer;\nendRecord\nrecord R49\ndefine v as integer;\nendRecord\nrecord R50\ndefine v as integer;\nendRecord\nrecord R51\ndefine v as integer;\nendRecord\nrecord R52\ndefine v as integer;\nendRecord\nrecord R53\ndefine v as integer;\nendRecord\nrecord R54\ndefine v as integer;\nendRecord\nrecord R55\ndefine v as integer;\nendRecord\nrecord R56\ndefine v as integer;\nendRecord\nrecord R57\ndefine v as integer;\nendRecord\nrecord R58\ndefine v as integer;\nendRecord\nrecord R59\ndefine v as integer;\nendRecord\nrecord R60\ndefine v as integer;\nendRecord\nrecord R61\ndefine v as integer;\nendRecord\nrecord R62\ndefine v as integer;\nendRecord\nrecord R63\ndefine v as integer;\nendRecord\nrecord R64\ndefine v as integer;\nendRecord\nsubroutine consume<T>(x as T)\nendSubroutine\nalgorithm P\nconsume(R1(1));\nconsume(R2(1));\nconsume(R3(1));\nconsume(R4(1));\nconsume(R5(1));\nconsume(R6(1));\nconsume(R7(1));\nconsume(R8(1));\nconsume(R9(1));\nconsume(R10(1));\nconsume(R11(1));\nconsume(R12(1));\nconsume(R13(1));\nconsume(R14(1));\nconsume(R15(1));\nconsume(R16(1));\nconsume(R17(1));\nconsume(R18(1));\nconsume(R19(1));\nconsume(R20(1));\nconsume(R21(1));\nconsume(R22(1));\nconsume(R23(1));\nconsume(R24(1));\nconsume(R25(1));\nconsume(R26(1));\nconsume(R27(1));\nconsume(R28(1));\nconsume(R29(1));\nconsume(R30(1));\nconsume(R31(1));\nconsume(R32(1));\nconsume(R33(1));\nconsume(R34(1));\nconsume(R35(1));\nconsume(R36(1));\nconsume(R37(1));\nconsume(R38(1));\nconsume(R39(1));\nconsume(R40(1));\nconsume(R41(1));\nconsume(R42(1));\nconsume(R43(1));\nconsume(R44(1));\nconsume(R45(1));\nconsume(R46(1));\nconsume(R47(1));\nconsume(R48(1));\nconsume(R49(1));\nconsume(R50(1));\nconsume(R51(1));\nconsume(R52(1));\nconsume(R53(1));\nconsume(R54(1));\nconsume(R55(1));\nconsume(R56(1));\nconsume(R57(1));\nconsume(R58(1));\nconsume(R59(1));\nconsume(R60(1));\nconsume(R61(1));\nconsume(R62(1));\nconsume(R63(1));\nconsume(R64(1));\nwrite \"listo\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "listo\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R1\nDefinir v Como Entero;\nFinRegistro\nRegistro R2\nDefinir v Como Entero;\nFinRegistro\nRegistro R3\nDefinir v Como Entero;\nFinRegistro\nRegistro R4\nDefinir v Como Entero;\nFinRegistro\nRegistro R5\nDefinir v Como Entero;\nFinRegistro\nRegistro R6\nDefinir v Como Entero;\nFinRegistro\nRegistro R7\nDefinir v Como Entero;\nFinRegistro\nRegistro R8\nDefinir v Como Entero;\nFinRegistro\nRegistro R9\nDefinir v Como Entero;\nFinRegistro\nRegistro R10\nDefinir v Como Entero;\nFinRegistro\nRegistro R11\nDefinir v Como Entero;\nFinRegistro\nRegistro R12\nDefinir v Como Entero;\nFinRegistro\nRegistro R13\nDefinir v Como Entero;\nFinRegistro\nRegistro R14\nDefinir v Como Entero;\nFinRegistro\nRegistro R15\nDefinir v Como Entero;\nFinRegistro\nRegistro R16\nDefinir v Como Entero;\nFinRegistro\nRegistro R17\nDefinir v Como Entero;\nFinRegistro\nRegistro R18\nDefinir v Como Entero;\nFinRegistro\nRegistro R19\nDefinir v Como Entero;\nFinRegistro\nRegistro R20\nDefinir v Como Entero;\nFinRegistro\nRegistro R21\nDefinir v Como Entero;\nFinRegistro\nRegistro R22\nDefinir v Como Entero;\nFinRegistro\nRegistro R23\nDefinir v Como Entero;\nFinRegistro\nRegistro R24\nDefinir v Como Entero;\nFinRegistro\nRegistro R25\nDefinir v Como Entero;\nFinRegistro\nRegistro R26\nDefinir v Como Entero;\nFinRegistro\nRegistro R27\nDefinir v Como Entero;\nFinRegistro\nRegistro R28\nDefinir v Como Entero;\nFinRegistro\nRegistro R29\nDefinir v Como Entero;\nFinRegistro\nRegistro R30\nDefinir v Como Entero;\nFinRegistro\nRegistro R31\nDefinir v Como Entero;\nFinRegistro\nRegistro R32\nDefinir v Como Entero;\nFinRegistro\nRegistro R33\nDefinir v Como Entero;\nFinRegistro\nRegistro R34\nDefinir v Como Entero;\nFinRegistro\nRegistro R35\nDefinir v Como Entero;\nFinRegistro\nRegistro R36\nDefinir v Como Entero;\nFinRegistro\nRegistro R37\nDefinir v Como Entero;\nFinRegistro\nRegistro R38\nDefinir v Como Entero;\nFinRegistro\nRegistro R39\nDefinir v Como Entero;\nFinRegistro\nRegistro R40\nDefinir v Como Entero;\nFinRegistro\nRegistro R41\nDefinir v Como Entero;\nFinRegistro\nRegistro R42\nDefinir v Como Entero;\nFinRegistro\nRegistro R43\nDefinir v Como Entero;\nFinRegistro\nRegistro R44\nDefinir v Como Entero;\nFinRegistro\nRegistro R45\nDefinir v Como Entero;\nFinRegistro\nRegistro R46\nDefinir v Como Entero;\nFinRegistro\nRegistro R47\nDefinir v Como Entero;\nFinRegistro\nRegistro R48\nDefinir v Como Entero;\nFinRegistro\nRegistro R49\nDefinir v Como Entero;\nFinRegistro\nRegistro R50\nDefinir v Como Entero;\nFinRegistro\nRegistro R51\nDefinir v Como Entero;\nFinRegistro\nRegistro R52\nDefinir v Como Entero;\nFinRegistro\nRegistro R53\nDefinir v Como Entero;\nFinRegistro\nRegistro R54\nDefinir v Como Entero;\nFinRegistro\nRegistro R55\nDefinir v Como Entero;\nFinRegistro\nRegistro R56\nDefinir v Como Entero;\nFinRegistro\nRegistro R57\nDefinir v Como Entero;\nFinRegistro\nRegistro R58\nDefinir v Como Entero;\nFinRegistro\nRegistro R59\nDefinir v Como Entero;\nFinRegistro\nRegistro R60\nDefinir v Como Entero;\nFinRegistro\nRegistro R61\nDefinir v Como Entero;\nFinRegistro\nRegistro R62\nDefinir v Como Entero;\nFinRegistro\nRegistro R63\nDefinir v Como Entero;\nFinRegistro\nRegistro R64\nDefinir v Como Entero;\nFinRegistro\nRegistro R65\nDefinir v Como Entero;\nFinRegistro\nSubProceso usar<T>(x Como T)\nFinSubProceso\nAlgoritmo P\nusar(R1(1));\nusar(R2(1));\nusar(R3(1));\nusar(R4(1));\nusar(R5(1));\nusar(R6(1));\nusar(R7(1));\nusar(R8(1));\nusar(R9(1));\nusar(R10(1));\nusar(R11(1));\nusar(R12(1));\nusar(R13(1));\nusar(R14(1));\nusar(R15(1));\nusar(R16(1));\nusar(R17(1));\nusar(R18(1));\nusar(R19(1));\nusar(R20(1));\nusar(R21(1));\nusar(R22(1));\nusar(R23(1));\nusar(R24(1));\nusar(R25(1));\nusar(R26(1));\nusar(R27(1));\nusar(R28(1));\nusar(R29(1));\nusar(R30(1));\nusar(R31(1));\nusar(R32(1));\nusar(R33(1));\nusar(R34(1));\nusar(R35(1));\nusar(R36(1));\nusar(R37(1));\nusar(R38(1));\nusar(R39(1));\nusar(R40(1));\nusar(R41(1));\nusar(R42(1));\nusar(R43(1));\nusar(R44(1));\nusar(R45(1));\nusar(R46(1));\nusar(R47(1));\nusar(R48(1));\nusar(R49(1));\nusar(R50(1));\nusar(R51(1));\nusar(R52(1));\nusar(R53(1));\nusar(R54(1));\nusar(R55(1));\nusar(R56(1));\nusar(R57(1));\nusar(R58(1));\nusar(R59(1));\nusar(R60(1));\nusar(R61(1));\nusar(R62(1));\nusar(R63(1));\nusar(R64(1));\nusar(R65(1));\nFinAlgoritmo\n",
    "en": "record R1\ndefine v as integer;\nendRecord\nrecord R2\ndefine v as integer;\nendRecord\nrecord R3\ndefine v as integer;\nendRecord\nrecord R4\ndefine v as integer;\nendRecord\nrecord R5\ndefine v as integer;\nendRecord\nrecord R6\ndefine v as integer;\nendRecord\nrecord R7\ndefine v as integer;\nendRecord\nrecord R8\ndefine v as integer;\nendRecord\nrecord R9\ndefine v as integer;\nendRecord\nrecord R10\ndefine v as integer;\nendRecord\nrecord R11\ndefine v as integer;\nendRecord\nrecord R12\ndefine v as integer;\nendRecord\nrecord R13\ndefine v as integer;\nendRecord\nrecord R14\ndefine v as integer;\nendRecord\nrecord R15\ndefine v as integer;\nendRecord\nrecord R16\ndefine v as integer;\nendRecord\nrecord R17\ndefine v as integer;\nendRecord\nrecord R18\ndefine v as integer;\nendRecord\nrecord R19\ndefine v as integer;\nendRecord\nrecord R20\ndefine v as integer;\nendRecord\nrecord R21\ndefine v as integer;\nendRecord\nrecord R22\ndefine v as integer;\nendRecord\nrecord R23\ndefine v as integer;\nendRecord\nrecord R24\ndefine v as integer;\nendRecord\nrecord R25\ndefine v as integer;\nendRecord\nrecord R26\ndefine v as integer;\nendRecord\nrecord R27\ndefine v as integer;\nendRecord\nrecord R28\ndefine v as integer;\nendRecord\nrecord R29\ndefine v as integer;\nendRecord\nrecord R30\ndefine v as integer;\nendRecord\nrecord R31\ndefine v as integer;\nendRecord\nrecord R32\ndefine v as integer;\nendRecord\nrecord R33\ndefine v as integer;\nendRecord\nrecord R34\ndefine v as integer;\nendRecord\nrecord R35\ndefine v as integer;\nendRecord\nrecord R36\ndefine v as integer;\nendRecord\nrecord R37\ndefine v as integer;\nendRecord\nrecord R38\ndefine v as integer;\nendRecord\nrecord R39\ndefine v as integer;\nendRecord\nrecord R40\ndefine v as integer;\nendRecord\nrecord R41\ndefine v as integer;\nendRecord\nrecord R42\ndefine v as integer;\nendRecord\nrecord R43\ndefine v as integer;\nendRecord\nrecord R44\ndefine v as integer;\nendRecord\nrecord R45\ndefine v as integer;\nendRecord\nrecord R46\ndefine v as integer;\nendRecord\nrecord R47\ndefine v as integer;\nendRecord\nrecord R48\ndefine v as integer;\nendRecord\nrecord R49\ndefine v as integer;\nendRecord\nrecord R50\ndefine v as integer;\nendRecord\nrecord R51\ndefine v as integer;\nendRecord\nrecord R52\ndefine v as integer;\nendRecord\nrecord R53\ndefine v as integer;\nendRecord\nrecord R54\ndefine v as integer;\nendRecord\nrecord R55\ndefine v as integer;\nendRecord\nrecord R56\ndefine v as integer;\nendRecord\nrecord R57\ndefine v as integer;\nendRecord\nrecord R58\ndefine v as integer;\nendRecord\nrecord R59\ndefine v as integer;\nendRecord\nrecord R60\ndefine v as integer;\nendRecord\nrecord R61\ndefine v as integer;\nendRecord\nrecord R62\ndefine v as integer;\nendRecord\nrecord R63\ndefine v as integer;\nendRecord\nrecord R64\ndefine v as integer;\nendRecord\nrecord R65\ndefine v as integer;\nendRecord\nsubroutine consume<T>(x as T)\nendSubroutine\nalgorithm P\nconsume(R1(1));\nconsume(R2(1));\nconsume(R3(1));\nconsume(R4(1));\nconsume(R5(1));\nconsume(R6(1));\nconsume(R7(1));\nconsume(R8(1));\nconsume(R9(1));\nconsume(R10(1));\nconsume(R11(1));\nconsume(R12(1));\nconsume(R13(1));\nconsume(R14(1));\nconsume(R15(1));\nconsume(R16(1));\nconsume(R17(1));\nconsume(R18(1));\nconsume(R19(1));\nconsume(R20(1));\nconsume(R21(1));\nconsume(R22(1));\nconsume(R23(1));\nconsume(R24(1));\nconsume(R25(1));\nconsume(R26(1));\nconsume(R27(1));\nconsume(R28(1));\nconsume(R29(1));\nconsume(R30(1));\nconsume(R31(1));\nconsume(R32(1));\nconsume(R33(1));\nconsume(R34(1));\nconsume(R35(1));\nconsume(R36(1));\nconsume(R37(1));\nconsume(R38(1));\nconsume(R39(1));\nconsume(R40(1));\nconsume(R41(1));\nconsume(R42(1));\nconsume(R43(1));\nconsume(R44(1));\nconsume(R45(1));\nconsume(R46(1));\nconsume(R47(1));\nconsume(R48(1));\nconsume(R49(1));\nconsume(R50(1));\nconsume(R51(1));\nconsume(R52(1));\nconsume(R53(1));\nconsume(R54(1));\nconsume(R55(1));\nconsume(R56(1));\nconsume(R57(1));\nconsume(R58(1));\nconsume(R59(1));\nconsume(R60(1));\nconsume(R61(1));\nconsume(R62(1));\nconsume(R63(1));\nconsume(R64(1));\nconsume(R65(1));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "genericInstanceLimitExceeded",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Caja<T>\nDefinir v Como T;\nFinRegistro\nSubProceso crecer<T>(valor Como T)\ncrecer(Caja(valor));\nFinSubProceso\nAlgoritmo P\ncrecer(1);\nFinAlgoritmo\n",
    "en": "record Box<T>\ndefine v as T;\nendRecord\nsubroutine grow<T>(value as T)\ngrow(Box(value));\nendSubroutine\nalgorithm P\ngrow(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "genericInstanceLimitExceeded",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso sinUso<T>(x Como T) Como T\nRetornar x;\nFinSubProceso\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "subroutine unused<T>(x as T) as T\nreturn x;\nendSubroutine\nalgorithm P\nwrite \"listo\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "listo\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso sumar<T>(a Como T, b Como T) Como T\nRetornar a + b;\nFinSubProceso\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "subroutine add<T>(a as T, b as T) as T\nreturn a + b;\nendSubroutine\nalgorithm P\nwrite \"listo\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleOperandTypes",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso primero<T>(a Como T, b Como T) Como T\nRetornar a;\nFinSubProceso\nAlgoritmo P\nEscribir primero(1, 2.5);\nFinAlgoritmo\n",
    "en": "subroutine first<T>(a as T, b as T) as T\nreturn a;\nendSubroutine\nalgorithm P\nwrite first(1, 2.5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "cannotInferTypeArgument",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso marcar<T>(n Como Entero)\nEscribir n;\nFinSubProceso\nAlgoritmo P\nmarcar(1);\nFinAlgoritmo\n",
    "en": "subroutine mark<T>(n as integer)\nwrite n;\nendSubroutine\nalgorithm P\nmark(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "cannotInferTypeArgument",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Caja<T>\nDefinir v Como T;\nFinRegistro\nSubProceso desenvolver<T>(c Como Caja<T>) Como T\nRetornar c.v;\nFinSubProceso\nAlgoritmo P\nDefinir c Como Caja<Entero, Real> <- Caja(1);\nFinAlgoritmo\n",
    "en": "record Box<T>\ndefine v as T;\nendRecord\nsubroutine unwrap<T>(c as Box<T>) as T\nreturn c.v;\nendSubroutine\nalgorithm P\ndefine c as Box<integer, real> <- Box(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "typeArgumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Caja<T>\nDefinir v Como T;\nFinRegistro\nSubProceso desenvolver<T>(c Como Caja<T>) Como T\nRetornar c.v;\nFinSubProceso\nAlgoritmo P\nDefinir c Como Caja <- Caja(1);\nFinAlgoritmo\n",
    "en": "record Box<T>\ndefine v as T;\nendRecord\nsubroutine unwrap<T>(c as Box<T>) as T\nreturn c.v;\nendSubroutine\nalgorithm P\ndefine c as Box <- Box(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "typeArgumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Nodo<T>\nDefinir siguiente Como Nodo<T>;\nFinRegistro\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record Node<T>\ndefine next as Node<T>;\nendRecord\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recursiveRecordContainment",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso f<T>(x Como T)\nFinSubProceso\nSubProceso f(x Como Entero)\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "subroutine f<T>(x as T)\nendSubroutine\nsubroutine f(x as integer)\nendSubroutine\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateSubroutine",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso g<T, T>(x Como T)\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "subroutine g<T, T>(x as T)\nendSubroutine\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateTypeDeclaration",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(9223372036854775807) + 1;\nFinAlgoritmo\n",
    "en": "subroutine identity<T>(value as T) as T\nreturn value;\nendSubroutine\nalgorithm P\nwrite identity(9223372036854775807) + 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "integerOverflow"
    }
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nMetodo guardar(otro Como T)\nEste.valor <- otro;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir a Como Caja<Entero> <- Nuevo Caja<Entero>(3);\nDefinir b Como Caja<Cadena> <- Nuevo Caja<Cadena>(\"uno\");\na.guardar(a.actual() + 4);\nEscribir a.actual();\nEscribir b.actual();\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nmethod store(fresh as T)\nthis.content <- fresh;\nendMethod\nendClass\nalgorithm P\ndefine a as Box<integer> <- new Box<integer>(3);\ndefine b as Box<string> <- new Box<string>(\"uno\");\na.store(a.current() + 4);\nwrite a.current();\nwrite b.current();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\nuno\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nMetodo guardar(otro Como T)\nEste.valor <- otro;\nFinMetodo\nFinClase\nSubProceso crear() Como Caja<Cadena>\nRetornar Nuevo Caja(\"dos\");\nFinSubProceso\nAlgoritmo P\nDefinir c Como Caja<Entero> <- Nuevo Caja(5);\nEscribir c.actual();\nEscribir crear().actual();\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nmethod store(fresh as T)\nthis.content <- fresh;\nendMethod\nendClass\nsubroutine make() as Box<string>\nreturn new Box(\"dos\");\nendSubroutine\nalgorithm P\ndefine c as Box<integer> <- new Box(5);\nwrite c.current();\nwrite make().current();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\ndos\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nMetodo guardar(otro Como T)\nEste.valor <- otro;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo Caja(5).actual();\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nmethod store(fresh as T)\nthis.content <- fresh;\nendMethod\nendClass\nalgorithm P\nwrite new Box(5).current();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "typeArgumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nMetodo guardar(otro Como T)\nEste.valor <- otro;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja<Entero> <- Nuevo Caja<Entero, Cadena>(1);\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nmethod store(fresh as T)\nthis.content <- fresh;\nendMethod\nendClass\nalgorithm P\ndefine c as Box<integer> <- new Box<integer, string>(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "typeArgumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nMetodo guardar(otro Como T)\nEste.valor <- otro;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja<Entero, Cadena> <- Nuevo Caja<Entero>(1);\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nmethod store(fresh as T)\nthis.content <- fresh;\nendMethod\nendClass\nalgorithm P\ndefine c as Box<integer, string> <- new Box<integer>(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "typeArgumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nMetodo guardar(otro Como T)\nEste.valor <- otro;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja<Entero> <- Nuevo Caja<Cadena>(\"xy\");\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nmethod store(fresh as T)\nthis.content <- fresh;\nendMethod\nendClass\nalgorithm P\ndefine c as Box<integer> <- new Box<string>(\"xy\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleTypesInAssignment",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Base<T>\nDefinir dato Como T;\nMetodo Constructor(d Como T)\nEste.dato <- d;\nFinMetodo\nMetodo describir() Como Cadena\nRetornar \"base\";\nFinMetodo\nFinClase\nClase Hija<T> Hereda De Base<T>\nMetodo Constructor(d Como T)\nSuper.Constructor(d);\nFinMetodo\nMetodo describir() Como Cadena\nRetornar \"hija\";\nFinMetodo\nFinClase\nClase Concreta Hereda De Base<Entero>\nMetodo Constructor(d Como Entero)\nSuper.Constructor(d * 2);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir x Como Base<Entero> <- Nuevo Hija<Entero>(1);\nEscribir x.describir();\nEscribir x.dato;\nDefinir z Como Base<Entero> <- Nuevo Concreta(5);\nEscribir z.describir();\nEscribir z.dato;\nFinAlgoritmo\n",
    "en": "class Base<T>\ndefine datum as T;\nmethod constructor(d as T)\nthis.datum <- d;\nendMethod\nmethod describe() as string\nreturn \"base\";\nendMethod\nendClass\nclass Child<T> inherits from Base<T>\nmethod constructor(d as T)\nsuper.constructor(d);\nendMethod\nmethod describe() as string\nreturn \"hija\";\nendMethod\nendClass\nclass Concrete inherits from Base<integer>\nmethod constructor(d as integer)\nsuper.constructor(d * 2);\nendMethod\nendClass\nalgorithm P\ndefine x as Base<integer> <- new Child<integer>(1);\nwrite x.describe();\nwrite x.datum;\ndefine y as Base<integer> <- new Concrete(5);\nwrite y.describe();\nwrite y.datum;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hija\n1\nbase\n10\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Base<T>\nDefinir dato Como T;\nMetodo Constructor(d Como T)\nEste.dato <- d;\nFinMetodo\nMetodo describir() Como Cadena\nRetornar \"base\";\nFinMetodo\nFinClase\nClase Hija<T> Hereda De Base<T>\nMetodo Constructor(d Como T)\nSuper.Constructor(d);\nFinMetodo\nMetodo describir() Como Cadena\nRetornar \"hija\";\nFinMetodo\nFinClase\nClase Concreta Hereda De Base<Entero>\nMetodo Constructor(d Como Entero)\nSuper.Constructor(d * 2);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir x Como Base<Cadena> <- Nuevo Hija<Entero>(1);\nFinAlgoritmo\n",
    "en": "class Base<T>\ndefine datum as T;\nmethod constructor(d as T)\nthis.datum <- d;\nendMethod\nmethod describe() as string\nreturn \"base\";\nendMethod\nendClass\nclass Child<T> inherits from Base<T>\nmethod constructor(d as T)\nsuper.constructor(d);\nendMethod\nmethod describe() as string\nreturn \"hija\";\nendMethod\nendClass\nclass Concrete inherits from Base<integer>\nmethod constructor(d as integer)\nsuper.constructor(d * 2);\nendMethod\nendClass\nalgorithm P\ndefine x as Base<string> <- new Child<integer>(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleTypesInAssignment",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Comparable<T>\nMetodo comparar(otro Como T) Como Entero;\nFinInterfaz\nInterfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nClase Numero Realiza Comparable<Numero>\nDefinir v Como Entero;\nMetodo Constructor(inicial Como Entero)\nEste.v <- inicial;\nFinMetodo\nMetodo comparar(otro Como Numero) Como Entero\nRetornar Este.v - otro.v;\nFinMetodo\nFinClase\nClase Fijo<T> Realiza Medible<T>\nDefinir dato Como T;\nMetodo Constructor(inicial Como T)\nEste.dato <- inicial;\nFinMetodo\nMetodo medir() Como T\nRetornar Este.dato;\nFinMetodo\nFinClase\nSubProceso mayor<T: Comparable<T>>(a Como T, b Como T) Como T\nSi a.comparar(b) > 0 Entonces\nRetornar a;\nFinSi\nRetornar b;\nFinSubProceso\nSubProceso medida<M: Medible<Cadena>>(m Como M) Como Cadena\nRetornar m.medir();\nFinSubProceso\nAlgoritmo P\nEscribir mayor(Nuevo Numero(3), Nuevo Numero(8)).v;\nEscribir medida(Nuevo Fijo<Cadena>(\"ok\"));\nFinAlgoritmo\n",
    "en": "interface Comparable<T>\nmethod compare(other as T) as integer;\nendInterface\ninterface Measurable<T>\nmethod measure() as T;\nendInterface\nclass Number implements Comparable<Number>\ndefine v as integer;\nmethod constructor(initial as integer)\nthis.v <- initial;\nendMethod\nmethod compare(other as Number) as integer\nreturn this.v - other.v;\nendMethod\nendClass\nclass Fixed<T> implements Measurable<T>\ndefine datum as T;\nmethod constructor(initial as T)\nthis.datum <- initial;\nendMethod\nmethod measure() as T\nreturn this.datum;\nendMethod\nendClass\nsubroutine larger<T: Comparable<T>>(a as T, b as T) as T\nif a.compare(b) > 0 then\nreturn a;\nendIf\nreturn b;\nendSubroutine\nsubroutine measured<M: Measurable<string>>(m as M) as string\nreturn m.measure();\nendSubroutine\nalgorithm P\nwrite larger(new Number(3), new Number(8)).v;\nwrite measured(new Fixed<string>(\"ok\"));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\nok\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C30",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Comparable<T>\nMetodo comparar(otro Como T) Como Entero;\nFinInterfaz\nInterfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nClase Numero Realiza Comparable<Numero>\nDefinir v Como Entero;\nMetodo Constructor(inicial Como Entero)\nEste.v <- inicial;\nFinMetodo\nMetodo comparar(otro Como Numero) Como Entero\nRetornar Este.v - otro.v;\nFinMetodo\nFinClase\nClase Fijo<T> Realiza Medible<T>\nDefinir dato Como T;\nMetodo Constructor(inicial Como T)\nEste.dato <- inicial;\nFinMetodo\nMetodo medir() Como T\nRetornar Este.dato;\nFinMetodo\nFinClase\nSubProceso mayor<T: Comparable<T>>(a Como T, b Como T) Como T\nSi a.comparar(b) > 0 Entonces\nRetornar a;\nFinSi\nRetornar b;\nFinSubProceso\nSubProceso medida<M: Medible<Cadena>>(m Como M) Como Cadena\nRetornar m.medir();\nFinSubProceso\nAlgoritmo P\nEscribir medida(Nuevo Fijo<Entero>(4));\nFinAlgoritmo\n",
    "en": "interface Comparable<T>\nmethod compare(other as T) as integer;\nendInterface\ninterface Measurable<T>\nmethod measure() as T;\nendInterface\nclass Number implements Comparable<Number>\ndefine v as integer;\nmethod constructor(initial as integer)\nthis.v <- initial;\nendMethod\nmethod compare(other as Number) as integer\nreturn this.v - other.v;\nendMethod\nendClass\nclass Fixed<T> implements Measurable<T>\ndefine datum as T;\nmethod constructor(initial as T)\nthis.datum <- initial;\nendMethod\nmethod measure() as T\nreturn this.datum;\nendMethod\nendClass\nsubroutine larger<T: Comparable<T>>(a as T, b as T) as T\nif a.compare(b) > 0 then\nreturn a;\nendIf\nreturn b;\nendSubroutine\nsubroutine measured<M: Measurable<string>>(m as M) as string\nreturn m.measure();\nendSubroutine\nalgorithm P\nwrite measured(new Fixed<integer>(4));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "genericConstraintNotSatisfied",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C31",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nClase Mal Realiza Medible<Entero>\nMetodo medir() Como Cadena\nRetornar \"xy\";\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "interface Measurable<T>\nmethod measure() as T;\nendInterface\nclass Wrong implements Measurable<integer>\nmethod measure() as string\nreturn \"xy\";\nendMethod\nendClass\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "interfaceMethodSignatureMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C32",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Par<T>\nDefinir primero, segundo Como T;\nFinRegistro\nClase Almacen<T>\nDefinir par Como Par<T>;\nMetodo Constructor(a Como T, b Como T)\nEste.par <- Par(a, b);\nFinMetodo\nMetodo segundo() Como T\nRetornar Este.par.segundo;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir v Como Vector<Almacen<Entero>> <- Vector();\nv.Agregar(Nuevo Almacen<Entero>(1, 2));\nv.Agregar(Nuevo Almacen<Entero>(3, 4));\nEscribir v[0].segundo() + v[1].segundo();\nFinAlgoritmo\n",
    "en": "record Pair<T>\ndefine first, second as T;\nendRecord\nclass Store<T>\ndefine pair as Pair<T>;\nmethod constructor(a as T, b as T)\nthis.pair <- Pair(a, b);\nendMethod\nmethod second() as T\nreturn this.pair.second;\nendMethod\nendClass\nalgorithm P\ndefine v as vector<Store<integer>> <- vector();\nv.append(new Store<integer>(1, 2));\nv.append(new Store<integer>(3, 4));\nwrite v[0].second() + v[1].second();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "6\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C33",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Suma<T>\nDefinir a Como T;\nMetodo doble() Como T\nRetornar Este.a + Este.a;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "class Sum<T>\ndefine a as T;\nmethod twice() as T\nreturn this.a + this.a;\nendMethod\nendClass\nalgorithm P\nwrite \"listo\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleOperandTypes",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C34",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase A<T> Hereda De B<T>\nFinClase\nClase B<T> Hereda De A<T>\nFinClase\nAlgoritmo P\nDefinir x Como A<Entero> <- Nuevo A<Entero>();\nFinAlgoritmo\n",
    "en": "class A<T> inherits from B<T>\nendClass\nclass B<T> inherits from A<T>\nendClass\nalgorithm P\ndefine x as A<integer> <- new A<integer>();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "circularInheritance",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C35",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Nodo<T>\nMetodo crecer(n Como Nodo<Nodo<T>>)\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir r Como Nodo<Entero> <- Nuevo Nodo<Entero>();\nFinAlgoritmo\n",
    "en": "class Node<T>\nmethod grow(n as Node<Node<T>>)\nendMethod\nendClass\nalgorithm P\ndefine r as Node<integer> <- new Node<integer>();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "genericInstanceLimitExceeded",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C36",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R1\nDefinir v Como Entero;\nFinRegistro\nRegistro R2\nDefinir v Como Entero;\nFinRegistro\nRegistro R3\nDefinir v Como Entero;\nFinRegistro\nRegistro R4\nDefinir v Como Entero;\nFinRegistro\nRegistro R5\nDefinir v Como Entero;\nFinRegistro\nRegistro R6\nDefinir v Como Entero;\nFinRegistro\nRegistro R7\nDefinir v Como Entero;\nFinRegistro\nRegistro R8\nDefinir v Como Entero;\nFinRegistro\nRegistro R9\nDefinir v Como Entero;\nFinRegistro\nRegistro R10\nDefinir v Como Entero;\nFinRegistro\nRegistro R11\nDefinir v Como Entero;\nFinRegistro\nRegistro R12\nDefinir v Como Entero;\nFinRegistro\nRegistro R13\nDefinir v Como Entero;\nFinRegistro\nRegistro R14\nDefinir v Como Entero;\nFinRegistro\nRegistro R15\nDefinir v Como Entero;\nFinRegistro\nRegistro R16\nDefinir v Como Entero;\nFinRegistro\nRegistro R17\nDefinir v Como Entero;\nFinRegistro\nRegistro R18\nDefinir v Como Entero;\nFinRegistro\nRegistro R19\nDefinir v Como Entero;\nFinRegistro\nRegistro R20\nDefinir v Como Entero;\nFinRegistro\nRegistro R21\nDefinir v Como Entero;\nFinRegistro\nRegistro R22\nDefinir v Como Entero;\nFinRegistro\nRegistro R23\nDefinir v Como Entero;\nFinRegistro\nRegistro R24\nDefinir v Como Entero;\nFinRegistro\nRegistro R25\nDefinir v Como Entero;\nFinRegistro\nRegistro R26\nDefinir v Como Entero;\nFinRegistro\nRegistro R27\nDefinir v Como Entero;\nFinRegistro\nRegistro R28\nDefinir v Como Entero;\nFinRegistro\nRegistro R29\nDefinir v Como Entero;\nFinRegistro\nRegistro R30\nDefinir v Como Entero;\nFinRegistro\nRegistro R31\nDefinir v Como Entero;\nFinRegistro\nRegistro R32\nDefinir v Como Entero;\nFinRegistro\nRegistro R33\nDefinir v Como Entero;\nFinRegistro\nRegistro R34\nDefinir v Como Entero;\nFinRegistro\nRegistro R35\nDefinir v Como Entero;\nFinRegistro\nRegistro R36\nDefinir v Como Entero;\nFinRegistro\nRegistro R37\nDefinir v Como Entero;\nFinRegistro\nRegistro R38\nDefinir v Como Entero;\nFinRegistro\nRegistro R39\nDefinir v Como Entero;\nFinRegistro\nRegistro R40\nDefinir v Como Entero;\nFinRegistro\nRegistro R41\nDefinir v Como Entero;\nFinRegistro\nRegistro R42\nDefinir v Como Entero;\nFinRegistro\nRegistro R43\nDefinir v Como Entero;\nFinRegistro\nRegistro R44\nDefinir v Como Entero;\nFinRegistro\nRegistro R45\nDefinir v Como Entero;\nFinRegistro\nRegistro R46\nDefinir v Como Entero;\nFinRegistro\nRegistro R47\nDefinir v Como Entero;\nFinRegistro\nRegistro R48\nDefinir v Como Entero;\nFinRegistro\nRegistro R49\nDefinir v Como Entero;\nFinRegistro\nRegistro R50\nDefinir v Como Entero;\nFinRegistro\nRegistro R51\nDefinir v Como Entero;\nFinRegistro\nRegistro R52\nDefinir v Como Entero;\nFinRegistro\nRegistro R53\nDefinir v Como Entero;\nFinRegistro\nRegistro R54\nDefinir v Como Entero;\nFinRegistro\nRegistro R55\nDefinir v Como Entero;\nFinRegistro\nRegistro R56\nDefinir v Como Entero;\nFinRegistro\nRegistro R57\nDefinir v Como Entero;\nFinRegistro\nRegistro R58\nDefinir v Como Entero;\nFinRegistro\nRegistro R59\nDefinir v Como Entero;\nFinRegistro\nRegistro R60\nDefinir v Como Entero;\nFinRegistro\nRegistro R61\nDefinir v Como Entero;\nFinRegistro\nRegistro R62\nDefinir v Como Entero;\nFinRegistro\nRegistro R63\nDefinir v Como Entero;\nFinRegistro\nRegistro R64\nDefinir v Como Entero;\nFinRegistro\nClase Celda<T>\nMetodo valor() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo Celda<R1>().valor();\nEscribir Nuevo Celda<R2>().valor();\nEscribir Nuevo Celda<R3>().valor();\nEscribir Nuevo Celda<R4>().valor();\nEscribir Nuevo Celda<R5>().valor();\nEscribir Nuevo Celda<R6>().valor();\nEscribir Nuevo Celda<R7>().valor();\nEscribir Nuevo Celda<R8>().valor();\nEscribir Nuevo Celda<R9>().valor();\nEscribir Nuevo Celda<R10>().valor();\nEscribir Nuevo Celda<R11>().valor();\nEscribir Nuevo Celda<R12>().valor();\nEscribir Nuevo Celda<R13>().valor();\nEscribir Nuevo Celda<R14>().valor();\nEscribir Nuevo Celda<R15>().valor();\nEscribir Nuevo Celda<R16>().valor();\nEscribir Nuevo Celda<R17>().valor();\nEscribir Nuevo Celda<R18>().valor();\nEscribir Nuevo Celda<R19>().valor();\nEscribir Nuevo Celda<R20>().valor();\nEscribir Nuevo Celda<R21>().valor();\nEscribir Nuevo Celda<R22>().valor();\nEscribir Nuevo Celda<R23>().valor();\nEscribir Nuevo Celda<R24>().valor();\nEscribir Nuevo Celda<R25>().valor();\nEscribir Nuevo Celda<R26>().valor();\nEscribir Nuevo Celda<R27>().valor();\nEscribir Nuevo Celda<R28>().valor();\nEscribir Nuevo Celda<R29>().valor();\nEscribir Nuevo Celda<R30>().valor();\nEscribir Nuevo Celda<R31>().valor();\nEscribir Nuevo Celda<R32>().valor();\nEscribir Nuevo Celda<R33>().valor();\nEscribir Nuevo Celda<R34>().valor();\nEscribir Nuevo Celda<R35>().valor();\nEscribir Nuevo Celda<R36>().valor();\nEscribir Nuevo Celda<R37>().valor();\nEscribir Nuevo Celda<R38>().valor();\nEscribir Nuevo Celda<R39>().valor();\nEscribir Nuevo Celda<R40>().valor();\nEscribir Nuevo Celda<R41>().valor();\nEscribir Nuevo Celda<R42>().valor();\nEscribir Nuevo Celda<R43>().valor();\nEscribir Nuevo Celda<R44>().valor();\nEscribir Nuevo Celda<R45>().valor();\nEscribir Nuevo Celda<R46>().valor();\nEscribir Nuevo Celda<R47>().valor();\nEscribir Nuevo Celda<R48>().valor();\nEscribir Nuevo Celda<R49>().valor();\nEscribir Nuevo Celda<R50>().valor();\nEscribir Nuevo Celda<R51>().valor();\nEscribir Nuevo Celda<R52>().valor();\nEscribir Nuevo Celda<R53>().valor();\nEscribir Nuevo Celda<R54>().valor();\nEscribir Nuevo Celda<R55>().valor();\nEscribir Nuevo Celda<R56>().valor();\nEscribir Nuevo Celda<R57>().valor();\nEscribir Nuevo Celda<R58>().valor();\nEscribir Nuevo Celda<R59>().valor();\nEscribir Nuevo Celda<R60>().valor();\nEscribir Nuevo Celda<R61>().valor();\nEscribir Nuevo Celda<R62>().valor();\nEscribir Nuevo Celda<R63>().valor();\nEscribir Nuevo Celda<R64>().valor();\nFinAlgoritmo\n",
    "en": "record R1\ndefine v as integer;\nendRecord\nrecord R2\ndefine v as integer;\nendRecord\nrecord R3\ndefine v as integer;\nendRecord\nrecord R4\ndefine v as integer;\nendRecord\nrecord R5\ndefine v as integer;\nendRecord\nrecord R6\ndefine v as integer;\nendRecord\nrecord R7\ndefine v as integer;\nendRecord\nrecord R8\ndefine v as integer;\nendRecord\nrecord R9\ndefine v as integer;\nendRecord\nrecord R10\ndefine v as integer;\nendRecord\nrecord R11\ndefine v as integer;\nendRecord\nrecord R12\ndefine v as integer;\nendRecord\nrecord R13\ndefine v as integer;\nendRecord\nrecord R14\ndefine v as integer;\nendRecord\nrecord R15\ndefine v as integer;\nendRecord\nrecord R16\ndefine v as integer;\nendRecord\nrecord R17\ndefine v as integer;\nendRecord\nrecord R18\ndefine v as integer;\nendRecord\nrecord R19\ndefine v as integer;\nendRecord\nrecord R20\ndefine v as integer;\nendRecord\nrecord R21\ndefine v as integer;\nendRecord\nrecord R22\ndefine v as integer;\nendRecord\nrecord R23\ndefine v as integer;\nendRecord\nrecord R24\ndefine v as integer;\nendRecord\nrecord R25\ndefine v as integer;\nendRecord\nrecord R26\ndefine v as integer;\nendRecord\nrecord R27\ndefine v as integer;\nendRecord\nrecord R28\ndefine v as integer;\nendRecord\nrecord R29\ndefine v as integer;\nendRecord\nrecord R30\ndefine v as integer;\nendRecord\nrecord R31\ndefine v as integer;\nendRecord\nrecord R32\ndefine v as integer;\nendRecord\nrecord R33\ndefine v as integer;\nendRecord\nrecord R34\ndefine v as integer;\nendRecord\nrecord R35\ndefine v as integer;\nendRecord\nrecord R36\ndefine v as integer;\nendRecord\nrecord R37\ndefine v as integer;\nendRecord\nrecord R38\ndefine v as integer;\nendRecord\nrecord R39\ndefine v as integer;\nendRecord\nrecord R40\ndefine v as integer;\nendRecord\nrecord R41\ndefine v as integer;\nendRecord\nrecord R42\ndefine v as integer;\nendRecord\nrecord R43\ndefine v as integer;\nendRecord\nrecord R44\ndefine v as integer;\nendRecord\nrecord R45\ndefine v as integer;\nendRecord\nrecord R46\ndefine v as integer;\nendRecord\nrecord R47\ndefine v as integer;\nendRecord\nrecord R48\ndefine v as integer;\nendRecord\nrecord R49\ndefine v as integer;\nendRecord\nrecord R50\ndefine v as integer;\nendRecord\nrecord R51\ndefine v as integer;\nendRecord\nrecord R52\ndefine v as integer;\nendRecord\nrecord R53\ndefine v as integer;\nendRecord\nrecord R54\ndefine v as integer;\nendRecord\nrecord R55\ndefine v as integer;\nendRecord\nrecord R56\ndefine v as integer;\nendRecord\nrecord R57\ndefine v as integer;\nendRecord\nrecord R58\ndefine v as integer;\nendRecord\nrecord R59\ndefine v as integer;\nendRecord\nrecord R60\ndefine v as integer;\nendRecord\nrecord R61\ndefine v as integer;\nendRecord\nrecord R62\ndefine v as integer;\nendRecord\nrecord R63\ndefine v as integer;\nendRecord\nrecord R64\ndefine v as integer;\nendRecord\nclass Cell<T>\nmethod amount() as integer\nreturn 1;\nendMethod\nendClass\nalgorithm P\nwrite new Cell<R1>().amount();\nwrite new Cell<R2>().amount();\nwrite new Cell<R3>().amount();\nwrite new Cell<R4>().amount();\nwrite new Cell<R5>().amount();\nwrite new Cell<R6>().amount();\nwrite new Cell<R7>().amount();\nwrite new Cell<R8>().amount();\nwrite new Cell<R9>().amount();\nwrite new Cell<R10>().amount();\nwrite new Cell<R11>().amount();\nwrite new Cell<R12>().amount();\nwrite new Cell<R13>().amount();\nwrite new Cell<R14>().amount();\nwrite new Cell<R15>().amount();\nwrite new Cell<R16>().amount();\nwrite new Cell<R17>().amount();\nwrite new Cell<R18>().amount();\nwrite new Cell<R19>().amount();\nwrite new Cell<R20>().amount();\nwrite new Cell<R21>().amount();\nwrite new Cell<R22>().amount();\nwrite new Cell<R23>().amount();\nwrite new Cell<R24>().amount();\nwrite new Cell<R25>().amount();\nwrite new Cell<R26>().amount();\nwrite new Cell<R27>().amount();\nwrite new Cell<R28>().amount();\nwrite new Cell<R29>().amount();\nwrite new Cell<R30>().amount();\nwrite new Cell<R31>().amount();\nwrite new Cell<R32>().amount();\nwrite new Cell<R33>().amount();\nwrite new Cell<R34>().amount();\nwrite new Cell<R35>().amount();\nwrite new Cell<R36>().amount();\nwrite new Cell<R37>().amount();\nwrite new Cell<R38>().amount();\nwrite new Cell<R39>().amount();\nwrite new Cell<R40>().amount();\nwrite new Cell<R41>().amount();\nwrite new Cell<R42>().amount();\nwrite new Cell<R43>().amount();\nwrite new Cell<R44>().amount();\nwrite new Cell<R45>().amount();\nwrite new Cell<R46>().amount();\nwrite new Cell<R47>().amount();\nwrite new Cell<R48>().amount();\nwrite new Cell<R49>().amount();\nwrite new Cell<R50>().amount();\nwrite new Cell<R51>().amount();\nwrite new Cell<R52>().amount();\nwrite new Cell<R53>().amount();\nwrite new Cell<R54>().amount();\nwrite new Cell<R55>().amount();\nwrite new Cell<R56>().amount();\nwrite new Cell<R57>().amount();\nwrite new Cell<R58>().amount();\nwrite new Cell<R59>().amount();\nwrite new Cell<R60>().amount();\nwrite new Cell<R61>().amount();\nwrite new Cell<R62>().amount();\nwrite new Cell<R63>().amount();\nwrite new Cell<R64>().amount();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C37",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R1\nDefinir v Como Entero;\nFinRegistro\nRegistro R2\nDefinir v Como Entero;\nFinRegistro\nRegistro R3\nDefinir v Como Entero;\nFinRegistro\nRegistro R4\nDefinir v Como Entero;\nFinRegistro\nRegistro R5\nDefinir v Como Entero;\nFinRegistro\nRegistro R6\nDefinir v Como Entero;\nFinRegistro\nRegistro R7\nDefinir v Como Entero;\nFinRegistro\nRegistro R8\nDefinir v Como Entero;\nFinRegistro\nRegistro R9\nDefinir v Como Entero;\nFinRegistro\nRegistro R10\nDefinir v Como Entero;\nFinRegistro\nRegistro R11\nDefinir v Como Entero;\nFinRegistro\nRegistro R12\nDefinir v Como Entero;\nFinRegistro\nRegistro R13\nDefinir v Como Entero;\nFinRegistro\nRegistro R14\nDefinir v Como Entero;\nFinRegistro\nRegistro R15\nDefinir v Como Entero;\nFinRegistro\nRegistro R16\nDefinir v Como Entero;\nFinRegistro\nRegistro R17\nDefinir v Como Entero;\nFinRegistro\nRegistro R18\nDefinir v Como Entero;\nFinRegistro\nRegistro R19\nDefinir v Como Entero;\nFinRegistro\nRegistro R20\nDefinir v Como Entero;\nFinRegistro\nRegistro R21\nDefinir v Como Entero;\nFinRegistro\nRegistro R22\nDefinir v Como Entero;\nFinRegistro\nRegistro R23\nDefinir v Como Entero;\nFinRegistro\nRegistro R24\nDefinir v Como Entero;\nFinRegistro\nRegistro R25\nDefinir v Como Entero;\nFinRegistro\nRegistro R26\nDefinir v Como Entero;\nFinRegistro\nRegistro R27\nDefinir v Como Entero;\nFinRegistro\nRegistro R28\nDefinir v Como Entero;\nFinRegistro\nRegistro R29\nDefinir v Como Entero;\nFinRegistro\nRegistro R30\nDefinir v Como Entero;\nFinRegistro\nRegistro R31\nDefinir v Como Entero;\nFinRegistro\nRegistro R32\nDefinir v Como Entero;\nFinRegistro\nRegistro R33\nDefinir v Como Entero;\nFinRegistro\nRegistro R34\nDefinir v Como Entero;\nFinRegistro\nRegistro R35\nDefinir v Como Entero;\nFinRegistro\nRegistro R36\nDefinir v Como Entero;\nFinRegistro\nRegistro R37\nDefinir v Como Entero;\nFinRegistro\nRegistro R38\nDefinir v Como Entero;\nFinRegistro\nRegistro R39\nDefinir v Como Entero;\nFinRegistro\nRegistro R40\nDefinir v Como Entero;\nFinRegistro\nRegistro R41\nDefinir v Como Entero;\nFinRegistro\nRegistro R42\nDefinir v Como Entero;\nFinRegistro\nRegistro R43\nDefinir v Como Entero;\nFinRegistro\nRegistro R44\nDefinir v Como Entero;\nFinRegistro\nRegistro R45\nDefinir v Como Entero;\nFinRegistro\nRegistro R46\nDefinir v Como Entero;\nFinRegistro\nRegistro R47\nDefinir v Como Entero;\nFinRegistro\nRegistro R48\nDefinir v Como Entero;\nFinRegistro\nRegistro R49\nDefinir v Como Entero;\nFinRegistro\nRegistro R50\nDefinir v Como Entero;\nFinRegistro\nRegistro R51\nDefinir v Como Entero;\nFinRegistro\nRegistro R52\nDefinir v Como Entero;\nFinRegistro\nRegistro R53\nDefinir v Como Entero;\nFinRegistro\nRegistro R54\nDefinir v Como Entero;\nFinRegistro\nRegistro R55\nDefinir v Como Entero;\nFinRegistro\nRegistro R56\nDefinir v Como Entero;\nFinRegistro\nRegistro R57\nDefinir v Como Entero;\nFinRegistro\nRegistro R58\nDefinir v Como Entero;\nFinRegistro\nRegistro R59\nDefinir v Como Entero;\nFinRegistro\nRegistro R60\nDefinir v Como Entero;\nFinRegistro\nRegistro R61\nDefinir v Como Entero;\nFinRegistro\nRegistro R62\nDefinir v Como Entero;\nFinRegistro\nRegistro R63\nDefinir v Como Entero;\nFinRegistro\nRegistro R64\nDefinir v Como Entero;\nFinRegistro\nRegistro R65\nDefinir v Como Entero;\nFinRegistro\nClase Celda<T>\nMetodo valor() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo Celda<R1>().valor();\nEscribir Nuevo Celda<R2>().valor();\nEscribir Nuevo Celda<R3>().valor();\nEscribir Nuevo Celda<R4>().valor();\nEscribir Nuevo Celda<R5>().valor();\nEscribir Nuevo Celda<R6>().valor();\nEscribir Nuevo Celda<R7>().valor();\nEscribir Nuevo Celda<R8>().valor();\nEscribir Nuevo Celda<R9>().valor();\nEscribir Nuevo Celda<R10>().valor();\nEscribir Nuevo Celda<R11>().valor();\nEscribir Nuevo Celda<R12>().valor();\nEscribir Nuevo Celda<R13>().valor();\nEscribir Nuevo Celda<R14>().valor();\nEscribir Nuevo Celda<R15>().valor();\nEscribir Nuevo Celda<R16>().valor();\nEscribir Nuevo Celda<R17>().valor();\nEscribir Nuevo Celda<R18>().valor();\nEscribir Nuevo Celda<R19>().valor();\nEscribir Nuevo Celda<R20>().valor();\nEscribir Nuevo Celda<R21>().valor();\nEscribir Nuevo Celda<R22>().valor();\nEscribir Nuevo Celda<R23>().valor();\nEscribir Nuevo Celda<R24>().valor();\nEscribir Nuevo Celda<R25>().valor();\nEscribir Nuevo Celda<R26>().valor();\nEscribir Nuevo Celda<R27>().valor();\nEscribir Nuevo Celda<R28>().valor();\nEscribir Nuevo Celda<R29>().valor();\nEscribir Nuevo Celda<R30>().valor();\nEscribir Nuevo Celda<R31>().valor();\nEscribir Nuevo Celda<R32>().valor();\nEscribir Nuevo Celda<R33>().valor();\nEscribir Nuevo Celda<R34>().valor();\nEscribir Nuevo Celda<R35>().valor();\nEscribir Nuevo Celda<R36>().valor();\nEscribir Nuevo Celda<R37>().valor();\nEscribir Nuevo Celda<R38>().valor();\nEscribir Nuevo Celda<R39>().valor();\nEscribir Nuevo Celda<R40>().valor();\nEscribir Nuevo Celda<R41>().valor();\nEscribir Nuevo Celda<R42>().valor();\nEscribir Nuevo Celda<R43>().valor();\nEscribir Nuevo Celda<R44>().valor();\nEscribir Nuevo Celda<R45>().valor();\nEscribir Nuevo Celda<R46>().valor();\nEscribir Nuevo Celda<R47>().valor();\nEscribir Nuevo Celda<R48>().valor();\nEscribir Nuevo Celda<R49>().valor();\nEscribir Nuevo Celda<R50>().valor();\nEscribir Nuevo Celda<R51>().valor();\nEscribir Nuevo Celda<R52>().valor();\nEscribir Nuevo Celda<R53>().valor();\nEscribir Nuevo Celda<R54>().valor();\nEscribir Nuevo Celda<R55>().valor();\nEscribir Nuevo Celda<R56>().valor();\nEscribir Nuevo Celda<R57>().valor();\nEscribir Nuevo Celda<R58>().valor();\nEscribir Nuevo Celda<R59>().valor();\nEscribir Nuevo Celda<R60>().valor();\nEscribir Nuevo Celda<R61>().valor();\nEscribir Nuevo Celda<R62>().valor();\nEscribir Nuevo Celda<R63>().valor();\nEscribir Nuevo Celda<R64>().valor();\nEscribir Nuevo Celda<R65>().valor();\nFinAlgoritmo\n",
    "en": "record R1\ndefine v as integer;\nendRecord\nrecord R2\ndefine v as integer;\nendRecord\nrecord R3\ndefine v as integer;\nendRecord\nrecord R4\ndefine v as integer;\nendRecord\nrecord R5\ndefine v as integer;\nendRecord\nrecord R6\ndefine v as integer;\nendRecord\nrecord R7\ndefine v as integer;\nendRecord\nrecord R8\ndefine v as integer;\nendRecord\nrecord R9\ndefine v as integer;\nendRecord\nrecord R10\ndefine v as integer;\nendRecord\nrecord R11\ndefine v as integer;\nendRecord\nrecord R12\ndefine v as integer;\nendRecord\nrecord R13\ndefine v as integer;\nendRecord\nrecord R14\ndefine v as integer;\nendRecord\nrecord R15\ndefine v as integer;\nendRecord\nrecord R16\ndefine v as integer;\nendRecord\nrecord R17\ndefine v as integer;\nendRecord\nrecord R18\ndefine v as integer;\nendRecord\nrecord R19\ndefine v as integer;\nendRecord\nrecord R20\ndefine v as integer;\nendRecord\nrecord R21\ndefine v as integer;\nendRecord\nrecord R22\ndefine v as integer;\nendRecord\nrecord R23\ndefine v as integer;\nendRecord\nrecord R24\ndefine v as integer;\nendRecord\nrecord R25\ndefine v as integer;\nendRecord\nrecord R26\ndefine v as integer;\nendRecord\nrecord R27\ndefine v as integer;\nendRecord\nrecord R28\ndefine v as integer;\nendRecord\nrecord R29\ndefine v as integer;\nendRecord\nrecord R30\ndefine v as integer;\nendRecord\nrecord R31\ndefine v as integer;\nendRecord\nrecord R32\ndefine v as integer;\nendRecord\nrecord R33\ndefine v as integer;\nendRecord\nrecord R34\ndefine v as integer;\nendRecord\nrecord R35\ndefine v as integer;\nendRecord\nrecord R36\ndefine v as integer;\nendRecord\nrecord R37\ndefine v as integer;\nendRecord\nrecord R38\ndefine v as integer;\nendRecord\nrecord R39\ndefine v as integer;\nendRecord\nrecord R40\ndefine v as integer;\nendRecord\nrecord R41\ndefine v as integer;\nendRecord\nrecord R42\ndefine v as integer;\nendRecord\nrecord R43\ndefine v as integer;\nendRecord\nrecord R44\ndefine v as integer;\nendRecord\nrecord R45\ndefine v as integer;\nendRecord\nrecord R46\ndefine v as integer;\nendRecord\nrecord R47\ndefine v as integer;\nendRecord\nrecord R48\ndefine v as integer;\nendRecord\nrecord R49\ndefine v as integer;\nendRecord\nrecord R50\ndefine v as integer;\nendRecord\nrecord R51\ndefine v as integer;\nendRecord\nrecord R52\ndefine v as integer;\nendRecord\nrecord R53\ndefine v as integer;\nendRecord\nrecord R54\ndefine v as integer;\nendRecord\nrecord R55\ndefine v as integer;\nendRecord\nrecord R56\ndefine v as integer;\nendRecord\nrecord R57\ndefine v as integer;\nendRecord\nrecord R58\ndefine v as integer;\nendRecord\nrecord R59\ndefine v as integer;\nendRecord\nrecord R60\ndefine v as integer;\nendRecord\nrecord R61\ndefine v as integer;\nendRecord\nrecord R62\ndefine v as integer;\nendRecord\nrecord R63\ndefine v as integer;\nendRecord\nrecord R64\ndefine v as integer;\nendRecord\nrecord R65\ndefine v as integer;\nendRecord\nclass Cell<T>\nmethod amount() as integer\nreturn 1;\nendMethod\nendClass\nalgorithm P\nwrite new Cell<R1>().amount();\nwrite new Cell<R2>().amount();\nwrite new Cell<R3>().amount();\nwrite new Cell<R4>().amount();\nwrite new Cell<R5>().amount();\nwrite new Cell<R6>().amount();\nwrite new Cell<R7>().amount();\nwrite new Cell<R8>().amount();\nwrite new Cell<R9>().amount();\nwrite new Cell<R10>().amount();\nwrite new Cell<R11>().amount();\nwrite new Cell<R12>().amount();\nwrite new Cell<R13>().amount();\nwrite new Cell<R14>().amount();\nwrite new Cell<R15>().amount();\nwrite new Cell<R16>().amount();\nwrite new Cell<R17>().amount();\nwrite new Cell<R18>().amount();\nwrite new Cell<R19>().amount();\nwrite new Cell<R20>().amount();\nwrite new Cell<R21>().amount();\nwrite new Cell<R22>().amount();\nwrite new Cell<R23>().amount();\nwrite new Cell<R24>().amount();\nwrite new Cell<R25>().amount();\nwrite new Cell<R26>().amount();\nwrite new Cell<R27>().amount();\nwrite new Cell<R28>().amount();\nwrite new Cell<R29>().amount();\nwrite new Cell<R30>().amount();\nwrite new Cell<R31>().amount();\nwrite new Cell<R32>().amount();\nwrite new Cell<R33>().amount();\nwrite new Cell<R34>().amount();\nwrite new Cell<R35>().amount();\nwrite new Cell<R36>().amount();\nwrite new Cell<R37>().amount();\nwrite new Cell<R38>().amount();\nwrite new Cell<R39>().amount();\nwrite new Cell<R40>().amount();\nwrite new Cell<R41>().amount();\nwrite new Cell<R42>().amount();\nwrite new Cell<R43>().amount();\nwrite new Cell<R44>().amount();\nwrite new Cell<R45>().amount();\nwrite new Cell<R46>().amount();\nwrite new Cell<R47>().amount();\nwrite new Cell<R48>().amount();\nwrite new Cell<R49>().amount();\nwrite new Cell<R50>().amount();\nwrite new Cell<R51>().amount();\nwrite new Cell<R52>().amount();\nwrite new Cell<R53>().amount();\nwrite new Cell<R54>().amount();\nwrite new Cell<R55>().amount();\nwrite new Cell<R56>().amount();\nwrite new Cell<R57>().amount();\nwrite new Cell<R58>().amount();\nwrite new Cell<R59>().amount();\nwrite new Cell<R60>().amount();\nwrite new Cell<R61>().amount();\nwrite new Cell<R62>().amount();\nwrite new Cell<R63>().amount();\nwrite new Cell<R64>().amount();\nwrite new Cell<R65>().amount();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "genericInstanceLimitExceeded",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C38",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nMetodo guardar(otro Como T)\nEste.valor <- otro;\nFinMetodo\nFinClase\nClase Fila<T>\nDefinir cabeza Como Caja<T>;\nMetodo Constructor(v Como T)\nEste.cabeza <- Nuevo Caja<T>(v);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir f Como Fila<Cadena> <- Nuevo Fila<Cadena>(\"zz\");\nEscribir f.cabeza.actual();\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nmethod store(fresh as T)\nthis.content <- fresh;\nendMethod\nendClass\nclass Row<T>\ndefine head as Box<T>;\nmethod constructor(v as T)\nthis.head <- new Box<T>(v);\nendMethod\nendClass\nalgorithm P\ndefine f as Row<string> <- new Row<string>(\"zz\");\nwrite f.head.current();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "zz\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C39",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Clase Caja<T>\nDefinir valor Como T;\nFinClase\nVariante Talvez<T>\nAlternativa Uno(v Como T)\nAlternativa Ninguno\nFinVariante\nSubProceso doble<T>(x Como T) Como Caja<T>\nDefinir c Como Caja<T> <- Nuevo Caja<T>();\nc.valor <- x;\nRetornar c;\nFinSubProceso\nAlgoritmo P\nDefinir t Como Talvez<Entero> <- Talvez.Uno(doble(4).valor);\nSegun t Hacer\nTalvez.Uno(n): Escribir n;\nTalvez.Ninguno: Escribir 0;\nFinSegun\nFinAlgoritmo\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El caso C40 ejerce el mismo programa en inglés."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "4\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C40",
  "regla": "R2",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "en",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "class Box<T>\ndefine content as T;\nendClass\nvariant Maybe<T>\ncase One(v as T)\ncase Nothing\nendVariant\nsubroutine wrap<T>(x as T) as Box<T>\ndefine c as Box<T> <- new Box<T>();\nc.content <- x;\nreturn c;\nendSubroutine\nalgorithm P\ndefine t as Maybe<integer> <- Maybe.One(wrap(4).content);\nswitch t do\nMaybe.One(n): write n;\nMaybe.Nothing: write 0;\nendSwitch\nendAlgorithm\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "es": "El caso C39 ejerce el mismo programa en español."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "4\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C41",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja<T>\nDefinir valor Como T;\nFinClase\nVariante Talvez<T>\nAlternativa Uno(v Como T)\nAlternativa Ninguno\nFinVariante\nSubProceso abrir<T>(c Como Caja<T>, t Como Talvez<T>) Como T\nDefinir r Como T <- c.valor;\nSegun t Hacer\nTalvez.Uno(v): r <- v;\nTalvez.Ninguno: r <- c.valor;\nFinSegun\nRetornar r;\nFinSubProceso\nAlgoritmo P\nDefinir c Como Caja<Entero> <- Nuevo Caja<Entero>();\nc.valor <- 3;\nDefinir t Como Talvez<Entero> <- Talvez.Ninguno;\nEscribir abrir(c, t);\nEscribir abrir(c, Talvez.Uno(9));\nFinAlgoritmo\n",
    "en": "class Box<T>\ndefine content as T;\nendClass\nvariant Maybe<T>\ncase One(v as T)\ncase Nothing\nendVariant\nsubroutine open<T>(c as Box<T>, t as Maybe<T>) as T\ndefine r as T <- c.content;\nswitch t do\nMaybe.One(v): r <- v;\nMaybe.Nothing: r <- c.content;\nendSwitch\nreturn r;\nendSubroutine\nalgorithm P\ndefine c as Box<integer> <- new Box<integer>();\nc.content <- 3;\ndefine t as Maybe<integer> <- Maybe.Nothing;\nwrite open(c, t);\nwrite open(c, Maybe.One(9));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n9\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C42",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.genericos.identidad;\nImportar geo.genericos.Par;\nImportar geo.genericos.Medible;\nImportar geo.genericos.Caja;\nImportar geo.genericos.Talvez;\nImportar app.otro.crear;\nClase Metro Realiza Medible<Entero>\nMetodo medir() Como Entero\nRetornar 3;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir p Como Par<Entero> <- Par(1, 2);\nSi p = crear() Entonces\nEscribir \"misma instancia\";\nFinSi\nDefinir c Como Caja<Cadena> <- Nuevo Caja<Cadena>(\"hola\");\nDefinir t Como Talvez<Entero> <- Talvez.Uno(identidad(p.segundo));\nSegun t Hacer\nTalvez.Uno(n): Escribir n, \" \", c.actual();\nTalvez.Ninguno: Escribir 0;\nFinSegun\nEscribir Nuevo Metro().medir();\nFinAlgoritmo\n"
              },
              {
                "path": "app/otro",
                "source_id": 2,
                "text": "Importar geo.genericos.Par;\nPublico SubProceso crear() Como Par<Entero>\nRetornar Par(1, 2);\nFinSubProceso\n"
              },
              {
                "path": "geo/genericos",
                "source_id": 3,
                "text": "Publico SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nPublico Registro Par<T>\nDefinir primero, segundo Como T;\nFinRegistro\nPublico Interfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nPublico Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nFinClase\nPublico Variante Talvez<T>\nAlternativa Uno(v Como T)\nAlternativa Ninguno\nFinVariante\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El caso C43 ejerce el mismo proyecto en inglés."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "misma instancia\n2 hola\n3\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C43",
  "regla": "R3",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "en",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "import geo.generics.identity;\nimport geo.generics.Pair;\nimport geo.generics.Measurable;\nimport geo.generics.Box;\nimport geo.generics.Maybe;\nimport app.other.build;\nclass Meter implements Measurable<integer>\nmethod measure() as integer\nreturn 3;\nendMethod\nendClass\nalgorithm P\ndefine p as Pair<integer> <- Pair(1, 2);\nif p = build() then\nwrite \"same instance\";\nendIf\ndefine c as Box<string> <- new Box<string>(\"hello\");\ndefine t as Maybe<integer> <- Maybe.One(identity(p.second));\nswitch t do\nMaybe.One(n): write n, \" \", c.current();\nMaybe.Nothing: write 0;\nendSwitch\nwrite new Meter().measure();\nendAlgorithm\n"
              },
              {
                "path": "app/other",
                "source_id": 2,
                "text": "import geo.generics.Pair;\npublic subroutine build() as Pair<integer>\nreturn Pair(1, 2);\nendSubroutine\n"
              },
              {
                "path": "geo/generics",
                "source_id": 3,
                "text": "public subroutine identity<T>(value as T) as T\nreturn value;\nendSubroutine\npublic record Pair<T>\ndefine first, second as T;\nendRecord\npublic interface Measurable<T>\nmethod measure() as T;\nendInterface\npublic class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nendClass\npublic variant Maybe<T>\ncase One(v as T)\ncase Nothing\nendVariant\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "es": "El caso C42 ejerce el mismo proyecto en español."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "same instance\n2 hello\n3\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C44",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "geo/genericos",
                "source_id": 1,
                "text": "Publico SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nPublico Registro Par<T>\nDefinir primero, segundo Como T;\nFinRegistro\nPublico Interfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nPublico Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nFinClase\nPublico Variante Talvez<T>\nAlternativa Uno(v Como T)\nAlternativa Ninguno\nFinVariante\n"
              },
              {
                "path": "app/otro",
                "source_id": 2,
                "text": "Importar geo.genericos.Par;\nPublico SubProceso crear() Como Par<Entero>\nRetornar Par(1, 2);\nFinSubProceso\n"
              },
              {
                "path": "app/main",
                "source_id": 3,
                "text": "Importar geo.genericos.identidad;\nImportar geo.genericos.Par;\nImportar geo.genericos.Medible;\nImportar geo.genericos.Caja;\nImportar geo.genericos.Talvez;\nImportar app.otro.crear;\nClase Metro Realiza Medible<Entero>\nMetodo medir() Como Entero\nRetornar 3;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir p Como Par<Entero> <- Par(1, 2);\nSi p = crear() Entonces\nEscribir \"misma instancia\";\nFinSi\nDefinir c Como Caja<Cadena> <- Nuevo Caja<Cadena>(\"hola\");\nDefinir t Como Talvez<Entero> <- Talvez.Uno(identidad(p.segundo));\nSegun t Hacer\nTalvez.Uno(n): Escribir n, \" \", c.actual();\nTalvez.Ninguno: Escribir 0;\nFinSegun\nEscribir Nuevo Metro().medir();\nFinAlgoritmo\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El caso C43 ejerce el mismo proyecto en inglés; el orden de archivos no depende del perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "misma instancia\n2 hola\n3\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C45",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.privados.oculta;\nImportar geo.privados.Celda;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/privados",
                "source_id": 2,
                "text": "SubProceso oculta<T>(x Como T) Como T\nRetornar x;\nFinSubProceso\nRegistro Celda<T>\nDefinir v Como T;\nFinRegistro\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La visibilidad de plantillas no depende del perfil; la forma inglesa de Importar se verifica en C43."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "privateImport"
              },
              {
                "code": "privateImport"
              }
            ],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C46",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.conteo.contar;\nImportar geo.conteo.Contable;\nAlgoritmo P\nEscribir contar(5);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/conteo",
                "source_id": 2,
                "text": "Publico Interfaz Contable\nMetodo cuenta() Como Entero;\nFinInterfaz\nPublico SubProceso contar<T: Contable>(x Como T) Como Entero\nRetornar x.cuenta();\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La restricción se comprueba igual en ambos perfiles; C43 cubre el perfil inglés del proyecto."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "genericConstraintNotSatisfied"
              }
            ],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C47",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.conteo.contar;\nImportar geo.conteo.Contable;\nClase Uno Realiza Contable\nMetodo cuenta() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir contar(Nuevo Uno());\nFinAlgoritmo\n"
              },
              {
                "path": "geo/conteo",
                "source_id": 2,
                "text": "Publico Interfaz Contable\nMetodo cuenta() Como Entero;\nFinInterfaz\nPublico SubProceso contar<T: Contable>(x Como T) Como Entero\nRetornar x.cuenta();\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La restricción se comprueba igual en ambos perfiles; C43 cubre el perfil inglés del proyecto."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "7\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C48",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.celdas.Celda;\nImportar app.otro.uno;\nSubProceso dos(p Como Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Cadena>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>) Como Entero\nRetornar 2;\nFinSubProceso\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n"
              },
              {
                "path": "app/otro",
                "source_id": 2,
                "text": "Importar geo.celdas.Celda;\nPublico SubProceso uno(p Como Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Entero>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>) Como Entero\nRetornar 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/celdas",
                "source_id": 3,
                "text": "Publico Registro Celda<T>\nDefinir v Como T;\nFinRegistro\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El recuento de instancias no depende del perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "unusedSubroutine"
              },
              {
                "code": "unusedParameter"
              },
              {
                "code": "unusedParameter"
              }
            ],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C49",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.celdas.Celda;\nImportar app.otro.uno;\nSubProceso dos(p Como Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Cadena>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>) Como Entero\nRetornar 2;\nFinSubProceso\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n"
              },
              {
                "path": "app/otro",
                "source_id": 2,
                "text": "Importar geo.celdas.Celda;\nPublico SubProceso uno(p Como Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Celda<Entero>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>) Como Entero\nRetornar 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/celdas",
                "source_id": 3,
                "text": "Publico Registro Celda<T>\nDefinir v Como T;\nFinRegistro\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El recuento de instancias no depende del perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "genericInstanceLimitExceeded"
              }
            ],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C50",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.fachada.Par;\nImportar geo.otra.Par Como Doble;\nAlgoritmo P\nDefinir a Como Par<Entero> <- Par(4, 5);\nDefinir b Como Doble<Entero> <- a;\nEscribir b.segundo;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/fachada",
                "source_id": 2,
                "text": "Exportar geo.genericos.Par;\n"
              },
              {
                "path": "geo/otra",
                "source_id": 3,
                "text": "Exportar geo.fachada.Par;\n"
              },
              {
                "path": "geo/genericos",
                "source_id": 4,
                "text": "Publico SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nPublico Registro Par<T>\nDefinir primero, segundo Como T;\nFinRegistro\nPublico Interfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nPublico Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nFinClase\nPublico Variante Talvez<T>\nAlternativa Uno(v Como T)\nAlternativa Ninguno\nFinVariante\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La reexportación no depende del perfil; C43 cubre el perfil inglés."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "5\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C51",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.a.Par Como ParX;\nImportar geo.b.Par Como ParY;\nAlgoritmo P\nDefinir a Como ParX<Entero> <- ParX(1);\nDefinir b Como ParY<Entero> <- a;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Publico Registro Par<T>\nDefinir v Como T;\nFinRegistro\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "Publico Registro Par<T>\nDefinir v Como T;\nFinRegistro\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La identidad de homónimos no depende del perfil; C43 cubre el perfil inglés."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "incompatibleTypesInAssignment"
              }
            ],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C52",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.genericos Como G;\nAlgoritmo P\nEscribir G.identidad(4), \" \", G.identidad(\"ab\");\nFinAlgoritmo\n"
              },
              {
                "path": "geo/genericos",
                "source_id": 2,
                "text": "Publico SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nPublico Registro Par<T>\nDefinir primero, segundo Como T;\nFinRegistro\nPublico Interfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nPublico Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nFinClase\nPublico Variante Talvez<T>\nAlternativa Uno(v Como T)\nAlternativa Ninguno\nFinVariante\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La llamada por alias de módulo no depende del perfil; C43 cubre el perfil inglés."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "4 ab\n",
            "diagnostics": [],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

```caso
{
  "id": "C53",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Algoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n"
              },
              {
                "path": "geo/sumas",
                "source_id": 2,
                "text": "Publico SubProceso sumar<T>(a Como T, b Como T) Como T\nRetornar a + b;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La comprobación de definición no depende del perfil; C12 la ejerce en ambos perfiles."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "incompatibleOperandTypes"
              }
            ],
            "project_errors": []
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C54",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Caja<T>\nDefinir v Como Ausente;\nFinRegistro\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "record Box<T>\ndefine v as Missing;\nendRecord\nalgorithm P\nwrite \"done\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredClass",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C55",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Medible<T>\nMetodo medir() Como Ausente;\nFinInterfaz\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "interface Measurable<T>\nmethod measure() as Missing;\nendInterface\nalgorithm P\nwrite \"done\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredClass",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C56",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Variante Talvez<T>\nAlternativa Uno(v Como Ausente)\nAlternativa Ninguno\nFinVariante\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "variant Maybe<T>\ncase One(v as Missing)\ncase Nothing\nendVariant\nalgorithm P\nwrite \"done\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredClass",
        "severidad": "error"
      }
    ]
  }
}
```
