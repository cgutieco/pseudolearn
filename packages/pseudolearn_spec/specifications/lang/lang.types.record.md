---
{
  "formato": "see/1",
  "id": "LANG.TYPES.RECORD",
  "titulo": "Registros por valor",
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
  "resumen": "Tipo agregado por valor con copia en asignación, paso y retorno.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.OPS.COMPARISON",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CLASS.COPY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.PARAMETERS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Registros por valor

Un registro agrupa campos en un valor que se copia, a diferencia de un objeto de clase.

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Registro nombre, una declaración Definir por línea y FinRegistro declaran un tipo agregado por valor en el módulo. Cada campo tiene un tipo entero, real, lógico, carácter, cadena, enumerado, clase u otro registro; un registro necesita al menos un campo (recordWithoutFields) y solo contiene declaraciones de campo (expectedRecordField). Un registro no puede contenerse a sí mismo por valor, directa ni indirectamente (recursiveRecordContainment); contener una clase que lo referencia sí es válido. Un registro es una unidad de módulo: es privado salvo que lleve el prefijo Publico y se importa por símbolo (LANG.MODULE.IMPORT#R2). Puede usarse como tipo de variable, parámetro, resultado, elemento de arreglo y campo de clase (R5).",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C20"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Nombre(argumentos) construye un registro con un argumento por campo en orden de declaración, con las conversiones de la asignación; un número distinto de argumentos es argumentCountMismatch. expresión.campo lee un campo y designador.campo <- valor actualiza el campo de la variable que contiene el registro, también en registros anidados.",
  "verificacion": [
    "C8",
    "C9",
    "C10",
    "C22"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Asignar, pasar como argumento y devolver un registro copia todos sus campos: las variables no comparten estado, pero un campo de clase copia la referencia y comparte el objeto. Un parámetro de tipo registro se pasa por valor, o por referencia con Por Referencia: el parámetro es un alias del destino (variable, campo de objeto o elemento de arreglo), cada campo del parámetro es el campo del destino, y toda escritura es visible de inmediato por cualquier otro alias del mismo destino. El argumento por referencia es un designador (byReferenceArgumentRequiresDesignator) y su tipo de registro coincide exactamente (byReferenceArgumentTypeMismatch). Leer un campo de un registro sin valor es uninitializedVariableRead; cada campo de un elemento de arreglo o de un campo de clase conserva su propio estado de definición: escribir un campo de un elemento sin valor es válido, y leer un campo sin valor es uninitializedVariableRead. Una variable no declarada no puede guardar un registro (recordNotInferable).",
  "verificacion": [
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C21",
    "C26",
    "C34",
    "C35",
    "C36",
    "C37",
    "C38"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un registro es válido como elemento de arreglo, campo de clase y parámetro o resultado de subprograma, método y constructor, incluida la sobrescritura y la realización de interfaces. a[i] es un registro que se copia al leerse y que se escribe completo al asignarlo, y a[i].campo lee o actualiza solo ese campo del elemento; pasar el arreglo como parámetro comparte sus elementos. Un campo de clase de tipo registro guarda el registro por valor dentro del objeto: leerlo o asignarlo copia sus campos, designador.campo.subcampo <- valor actualiza el subcampo del objeto, Copiar de un objeto copia el registro que contiene y un campo de clase dentro del registro sigue compartiendo su objeto. Las reglas de R2, R3 y R4 se cumplen igual en cada una de estas posiciones.",
  "verificacion": [
    "C23",
    "C24",
    "C25",
    "C27",
    "C28",
    "C29",
    "C30",
    "C31",
    "C32",
    "C33",
    "C40",
    "C41",
    "C42",
    "C43",
    "C44"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dos registros del mismo tipo son iguales con = si todos sus campos lo son, comparados como sus tipos, y distintos con <>; el orden no está definido y el cero real positivo y negativo son iguales. Escribir un registro es recordCannotBeWritten.",
  "verificacion": [
    "C16",
    "C17",
    "C18",
    "C19",
    "C39"
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
    "es": "Registro Caja\nDefinir v Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir c Como Caja <- Caja(5);\nEscribir c.v;\nFinAlgoritmo\n",
    "en": "record Caja\ndefine v as integer;\nendRecord\nalgorithm P\ndefine c as Caja <- Caja(5);\nwrite c.v;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
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
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nRegistro Linea\nDefinir a, b Como Punto;\nFinRegistro\nAlgoritmo P\nDefinir Mutable l Como Linea <- Linea(Punto(1, 2), Punto(3, 4));\nl.b.z <- 9;\nEscribir l.a.x, l.b.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nrecord Linea\ndefine a, b as Punto;\nendRecord\nalgorithm P\ndefine mutable l as Linea <- Linea(Punto(1, 2), Punto(3, 4));\nl.b.z <- 9;\nwrite l.a.x, l.b.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "19\n",
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
    "es": "Registro R\nDefinir r Como R;\nFinRegistro\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record R\ndefine r as R;\nendRecord\nalgorithm P\nendAlgorithm\n"
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
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro A\nDefinir b Como B;\nFinRegistro\nRegistro B\nDefinir a Como A;\nFinRegistro\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record A\ndefine b as B;\nendRecord\nrecord B\ndefine a as A;\nendRecord\nalgorithm P\nendAlgorithm\n"
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
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Vacio\nFinRegistro\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record Vacio\nendRecord\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recordWithoutFields",
        "severidad": "error"
      }
    ]
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
    "es": "Registro P\nDimension a[3] Como Entero;\nFinRegistro\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record P\ndimension a[3] as integer;\nendRecord\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedRecordField",
        "severidad": "error"
      }
    ]
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
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[2] Como Punto;\na[0] <- Punto(1, 2);\nEscribir a[0].x, a[0].z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension a[2] as Punto;\na[0] <- Punto(1, 2);\nwrite a[0].x, a[0].z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "12\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto <- Punto(1);\nEscribir p.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto <- Punto(1);\nwrite p.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Medida\nDefinir v Como Real;\nFinRegistro\nAlgoritmo P\nDefinir m Como Medida <- Medida(2);\nEscribir m.v;\nFinAlgoritmo\n",
    "en": "record Medida\ndefine v as real;\nendRecord\nalgorithm P\ndefine m as Medida <- Medida(2);\nwrite m.v;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto <- Punto(1, 2);\nEscribir p.w;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto <- Punto(1, 2);\nwrite p.w;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undefinedMember",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto <- Punto(1, 2);\nDefinir Mutable q Como Punto <- Punto(0, 0);\nq <- p;\nq.x <- 10;\nEscribir p.x, q.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto <- Punto(1, 2);\ndefine mutable q as Punto <- Punto(0, 0);\nq <- p;\nq.x <- 10;\nwrite p.x, q.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "110\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso mover(p Como Punto) Como Punto\np.x <- p.x + 1;\nRetornar p;\nFinSubProceso\nAlgoritmo P\nDefinir a Como Punto <- Punto(1, 2);\nDefinir Mutable b Como Punto <- Punto(0, 0);\nb <- mover(a);\nEscribir a.x, b.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine mover(p as Punto) as Punto\np.x <- p.x + 1;\nreturn p;\nendSubroutine\nalgorithm P\ndefine a as Punto <- Punto(1, 2);\ndefine mutable b as Punto <- Punto(0, 0);\nb <- mover(a);\nwrite a.x, b.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "12\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja\nDefinir v Como Entero;\nMetodo Constructor(v Como Entero)\nEste.v <- v;\nFinMetodo\nFinClase\nRegistro Par\nDefinir c Como Caja;\nFinRegistro\nAlgoritmo P\nDefinir p Como Par <- Par(Nuevo Caja(1));\nDefinir q Como Par <- p;\nq.c.v <- 5;\nEscribir p.c.v;\nFinAlgoritmo\n",
    "en": "class Caja\ndefine v as integer;\nmethod constructor(v as integer)\nthis.v <- v;\nendMethod\nendClass\nrecord Par\ndefine c as Caja;\nendRecord\nalgorithm P\ndefine p as Par <- Par(new Caja(1));\ndefine q as Par <- p;\nq.c.v <- 5;\nwrite p.c.v;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso mover(p Como Punto Por Referencia)\np.x <- p.x + 10;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable a Como Punto <- Punto(1, 2);\nmover(a);\nEscribir a.x, a.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine mover(p as Punto by reference)\np.x <- p.x + 10;\nendSubroutine\nalgorithm P\ndefine mutable a as Punto <- Punto(1, 2);\nmover(a);\nwrite a.x, a.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "112\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto;\nEscribir p.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto;\nwrite p.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "missingBindingInitializer",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nEscribir Punto(1, 2) = Punto(1, 2), Punto(1, 2) <> Punto(1, 3);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\nwrite Punto(1, 2) = Punto(1, 2), Punto(1, 2) <> Punto(1, 3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Medida\nDefinir v Como Real;\nFinRegistro\nAlgoritmo P\nDefinir a Como Medida <- Medida(0.0);\nDefinir Mutable b Como Medida <- Medida(0.0);\nb <- Medida(-0.0);\nEscribir a = b;\nFinAlgoritmo\n",
    "en": "record Medida\ndefine v as real;\nendRecord\nalgorithm P\ndefine a as Medida <- Medida(0.0);\ndefine mutable b as Medida <- Medida(0.0);\nb <- Medida(-0.0);\nwrite a = b;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto <- Punto(1, 2);\nEscribir p;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto <- Punto(1, 2);\nwrite p;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recordCannotBeWritten",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nEscribir Punto(1, 2) < Punto(1, 3);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\nwrite Punto(1, 2) < Punto(1, 3);\nendAlgorithm\n"
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
  "id": "C20",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase K\nMetodo m(p Como Punto) Como Punto\nRetornar Punto(p.x + 1, p.z);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir k Como K <- Nuevo K();\nDefinir r Como Punto <- k.m(Punto(1, 2));\nEscribir r.x, r.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass K\nmethod m(p as Punto) as Punto\nreturn Punto(p.x + 1, p.z);\nendMethod\nendClass\nalgorithm P\ndefine k as K <- new K();\ndefine r as Punto <- k.m(Punto(1, 2));\nwrite r.x, r.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "22\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nq <- Punto(1, 2);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\nq <- Punto(1, 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredVariable",
        "severidad": "error"
      }
    ]
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
    "es": "Registro Punto\nDefinir x Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir Mutable p Como Punto <- Punto(9223372036854775807);\np.x <- p.x + 1;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x as integer;\nendRecord\nalgorithm P\ndefine mutable p as Punto <- Punto(9223372036854775807);\np.x <- p.x + 1;\nendAlgorithm\n"
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
  "id": "C23",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[2] Como Punto;\na[0] <- Punto(1, 2);\na[1].x <- 3;\na[1].z <- 4;\nEscribir a[0].x + a[1].z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension a[2] as Punto;\na[0] <- Punto(1, 2);\na[1].x <- 3;\na[1].z <- 4;\nwrite a[0].x + a[1].z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[1] Como Punto;\na[0] <- Punto(1, 2);\nDefinir Mutable q Como Punto <- a[0];\nq.x <- 9;\nEscribir a[0].x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension a[1] as Punto;\na[0] <- Punto(1, 2);\ndefine mutable q as Punto <- a[0];\nq.x <- 9;\nwrite a[0].x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso llenar(v[] Como Punto)\nv[0] <- Punto(7, 8);\nFinSubProceso\nAlgoritmo P\nDimension a[1] Como Punto;\nllenar(a);\nEscribir a[0].z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine llenar(v[] as Punto)\nv[0] <- Punto(7, 8);\nendSubroutine\nalgorithm P\ndimension a[1] as Punto;\nllenar(a);\nwrite a[0].z;\nendAlgorithm\n"
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
  "id": "C26",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[1] Como Punto;\na[0].x <- 1;\nEscribir a[0].x;\nEscribir a[0].z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension a[1] as Punto;\na[0].x <- 1;\nwrite a[0].x;\nwrite a[0].z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "fallo": {
      "codigo": "uninitializedVariableRead"
    }
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[2] Como Punto;\na[2] <- Punto(1, 1);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension a[2] as Punto;\na[2] <- Punto(1, 1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Caja\nDefinir p Como Punto;\nMetodo Constructor()\nEste.p <- Punto(1, 2);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nc.p.x <- 5;\nEscribir c.p.x, c.p.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Caja\ndefine p as Punto;\nmethod constructor()\nthis.p <- Punto(1, 2);\nendMethod\nendClass\nalgorithm P\ndefine c as Caja <- new Caja();\nc.p.x <- 5;\nwrite c.p.x, c.p.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "52\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Caja\nDefinir p Como Punto;\nMetodo Constructor()\nEste.p <- Punto(1, 2);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nDefinir Mutable q Como Punto <- c.p;\nq.x <- 9;\nEscribir c.p.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Caja\ndefine p as Punto;\nmethod constructor()\nthis.p <- Punto(1, 2);\nendMethod\nendClass\nalgorithm P\ndefine c as Caja <- new Caja();\ndefine mutable q as Punto <- c.p;\nq.x <- 9;\nwrite c.p.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C30",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Caja\nDefinir p Como Punto;\nMetodo Constructor()\nEste.p <- Punto(1, 2);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nDefinir d Como Caja <- Copiar(c);\nd.p.x <- 9;\nEscribir c.p.x, d.p.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Caja\ndefine p as Punto;\nmethod constructor()\nthis.p <- Punto(1, 2);\nendMethod\nendClass\nalgorithm P\ndefine c as Caja <- new Caja();\ndefine d as Caja <- copy(c);\nd.p.x <- 9;\nwrite c.p.x, d.p.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "19\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C31",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Base\nMetodo mover(p Como Punto) Como Punto\nRetornar p;\nFinMetodo\nFinClase\nClase Derivada Hereda De Base\nMetodo mover(p Como Punto) Como Punto\nRetornar Punto(p.x * 10, p.z * 10);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir item Como Base <- Nuevo Derivada();\nDefinir r Como Punto <- item.mover(Punto(1, 2));\nEscribir r.x, r.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Base\nmethod mover(p as Punto) as Punto\nreturn p;\nendMethod\nendClass\nclass Derivada extends Base\nmethod mover(p as Punto) as Punto\nreturn Punto(p.x * 10, p.z * 10);\nendMethod\nendClass\nalgorithm P\ndefine item as Base <- new Derivada();\ndefine r as Punto <- item.mover(Punto(1, 2));\nwrite r.x, r.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1020\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C32",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Base\nDefinir total Como Entero;\nMetodo Constructor(p Como Punto)\nEste.total <- p.x + p.z;\nFinMetodo\nFinClase\nClase Derivada Hereda De Base\nMetodo Constructor(p Como Punto)\nSuper.Constructor(p);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir d Como Derivada <- Nuevo Derivada(Punto(3, 4));\nEscribir d.total;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Base\ndefine total as integer;\nmethod constructor(p as Punto)\nthis.total <- p.x + p.z;\nendMethod\nendClass\nclass Derivada extends Base\nmethod constructor(p as Punto)\nsuper.constructor(p);\nendMethod\nendClass\nalgorithm P\ndefine d as Derivada <- new Derivada(Punto(3, 4));\nwrite d.total;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C33",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nInterfaz Mapeador\nMetodo aplicar(p Como Punto) Como Punto;\nFinInterfaz\nClase Doble Realiza Mapeador\nMetodo aplicar(p Como Punto) Como Punto\nRetornar Punto(p.x * 2, p.z * 2);\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir d Como Doble <- Nuevo Doble();\nDefinir r Como Punto <- d.aplicar(Punto(5, 6));\nEscribir r.x, r.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\ninterface Mapeador\nmethod aplicar(p as Punto) as Punto;\nendInterface\nclass Doble implements Mapeador\nmethod aplicar(p as Punto) as Punto\nreturn Punto(p.x * 2, p.z * 2);\nendMethod\nendClass\nalgorithm P\ndefine d as Doble <- new Doble();\ndefine r as Punto <- d.aplicar(Punto(5, 6));\nwrite r.x, r.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1012\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C34",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Caja\nDefinir p Como Punto;\nMetodo Constructor()\nEste.p <- Punto(1, 2);\nFinMetodo\nFinClase\nSubProceso poner(p Como Punto Por Referencia)\np <- Punto(0, 0);\nFinSubProceso\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nponer(c.p);\nEscribir c.p.x + c.p.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Caja\ndefine p as Punto;\nmethod constructor()\nthis.p <- Punto(1, 2);\nendMethod\nendClass\nsubroutine poner(p as Punto by reference)\np <- Punto(0, 0);\nendSubroutine\nalgorithm P\ndefine c as Caja <- new Caja();\nponer(c.p);\nwrite c.p.x + c.p.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C35",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso subir(p Como Punto Por Referencia)\np.x <- p.x + 1;\nFinSubProceso\nAlgoritmo P\nDimension a[2] Como Punto;\na[1] <- Punto(1, 1);\nsubir(a[1]);\nEscribir a[1].x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine subir(p as Punto by reference)\np.x <- p.x + 1;\nendSubroutine\nalgorithm P\ndimension a[2] as Punto;\na[1] <- Punto(1, 1);\nsubir(a[1]);\nwrite a[1].x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C36",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nRegistro Gemelo\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso mover(p Como Punto Por Referencia)\np.x <- 1;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable g Como Gemelo <- Gemelo(1, 2);\nmover(g);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nrecord Gemelo\ndefine x, z as integer;\nendRecord\nsubroutine mover(p as Punto by reference)\np.x <- 1;\nendSubroutine\nalgorithm P\ndefine mutable g as Gemelo <- Gemelo(1, 2);\nmover(g);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "byReferenceArgumentTypeMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C37",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso mover(p Como Punto Por Referencia)\np.x <- 1;\nFinSubProceso\nAlgoritmo P\nmover(Punto(1, 2));\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine mover(p as Punto by reference)\np.x <- 1;\nendSubroutine\nalgorithm P\nmover(Punto(1, 2));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "byReferenceArgumentRequiresDesignator",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C38",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso fijar(a Como Punto Por Referencia, b Como Punto Por Referencia)\na.x <- 5;\nEscribir b.x;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable q Como Punto <- Punto(1, 2);\nfijar(q, q);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine fijar(a as Punto by reference, b as Punto by reference)\na.x <- 5;\nwrite b.x;\nendSubroutine\nalgorithm P\ndefine mutable q as Punto <- Punto(1, 2);\nfijar(q, q);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C39",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[1] Como Punto;\na[0] <- Punto(1, 2);\nEscribir a[0] = Punto(1, 2), a[0] <> Punto(1, 2);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension a[1] as Punto;\na[0] <- Punto(1, 2);\nwrite a[0] = Punto(1, 2), a[0] <> Punto(1, 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C40",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension g[2, 2] Como Punto;\ng[1, 0] <- Punto(4, 5);\nEscribir g[1, 0].z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension g[2, 2] as Punto;\ng[1, 0] <- Punto(4, 5);\nwrite g[1, 0].z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C41",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Uno\nDefinir v Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[1] Como Uno;\na[0] <- Uno(3);\nEscribir a[0].v;\nFinAlgoritmo\n",
    "en": "record Uno\ndefine v as integer;\nendRecord\nalgorithm P\ndimension a[1] as Uno;\na[0] <- Uno(3);\nwrite a[0].v;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C42",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nRegistro Linea\nDefinir a, b Como Punto;\nFinRegistro\nClase Caja\nDefinir l Como Linea;\nMetodo Constructor()\nEste.l <- Linea(Punto(1, 2), Punto(3, 4));\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nc.l.b.z <- 8;\nc.l.a <- Punto(5, 6);\nEscribir c.l.a.x + c.l.b.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nrecord Linea\ndefine a, b as Punto;\nendRecord\nclass Caja\ndefine l as Linea;\nmethod constructor()\nthis.l <- Linea(Punto(1, 2), Punto(3, 4));\nendMethod\nendClass\nalgorithm P\ndefine c as Caja <- new Caja();\nc.l.b.z <- 8;\nc.l.a <- Punto(5, 6);\nwrite c.l.a.x + c.l.b.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "13\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C43",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Caja\nDefinir p Como Punto;\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nEscribir c.p.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Caja\ndefine p as Punto;\nendClass\nalgorithm P\ndefine c as Caja <- new Caja();\nwrite c.p.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "uninitializedVariableRead"
    }
  }
}
```


```caso
{
  "id": "C44",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase Caja\nDefinir p Como Punto;\nDefinir p Como Punto;\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass Caja\ndefine p as Punto;\ndefine p as Punto;\nendClass\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateMember",
        "severidad": "error"
      }
    ]
  }
}
```
