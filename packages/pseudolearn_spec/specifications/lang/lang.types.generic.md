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
  "resumen": "Parámetros de tipo en registros y subprogramas, inferencia local e instancias acotadas.",
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
  "texto": "Un registro o un subprograma declara parámetros de tipo con <T, U> tras su nombre; un tipo genérico se escribe nombre<argumentos de tipo> con exactamente tantos argumentos como parámetros (typeArgumentCountMismatch). El cuerpo genérico se comprueba una sola vez con cada parámetro opaco: solo puede copiarse, pasarse, retornarse, almacenarse en campos y construir registros genéricos; operarlo, compararlo o escribirlo es error en la definición, haya o no instancias. Una llamada infiere cada argumento de tipo unificando estructuralmente los tipos de los parámetros con los de los argumentos (parámetro directo, registro genérico, arreglo o tipo función); construir un registro genérico infiere desde sus campos; no hay instanciación explícita en llamadas. Un parámetro de tipo sin determinar o con dos valores distintos produce cannotInferTypeArgument. Cada combinación de genérico y argumentos de tipo canónicos es una instancia única con función o registro propios, nombrada nombre<tipos>; las instancias alcanzables se recogen de forma cerrada y un genérico sin instanciar no genera ninguna. El programa admite como máximo 64 instancias; superar el límite, incluida la recursión polimórfica expansiva, produce genericInstanceLimitExceeded. Los parámetros de tipo no se restringen en esta edición, los genéricos son privados del módulo y los genéricos de clases no pertenecen a la edición.",
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
    "C19"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```
