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
  "texto": "Registro nombre, una declaración Definir por línea y FinRegistro declaran un tipo agregado por valor en el módulo. Cada campo tiene un tipo entero, real, lógico, carácter, cadena, enumerado, clase u otro registro; un registro necesita al menos un campo (recordWithoutFields) y solo contiene declaraciones de campo (expectedRecordField). Un registro no puede contenerse a sí mismo por valor, directa ni indirectamente (recursiveRecordContainment); contener una clase que lo referencia sí es válido. Un registro tiene como máximo 65535 hojas, contadas como los campos que no son registros, incluidos los de sus registros anidados; el primer registro que supera ese máximo produce recordLayoutLimit, una sola vez aunque otros registros lo contengan. Un registro es una unidad de módulo: es privado salvo que lleve el prefijo Publico y se importa por símbolo (LANG.MODULE.IMPORT#R2). Puede usarse como tipo de variable, parámetro, resultado, elemento de arreglo y campo de clase (R5).",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C20",
    "C48",
    "C49"
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
  "texto": "Un registro es válido como elemento de arreglo, campo de clase y parámetro o resultado de subprograma, método y constructor, incluida la sobrescritura y la realización de interfaces. a[i] es un registro que se copia al leerse y que se escribe completo al asignarlo, y a[i].campo lee o actualiza solo ese campo del elemento; pasar el arreglo como parámetro comparte sus elementos. Un campo de clase de tipo registro guarda el registro por valor dentro del objeto: leerlo o asignarlo copia sus campos, designador.campo.subcampo <- valor actualiza el subcampo del objeto, Copiar de un objeto copia el registro que contiene y un campo de clase dentro del registro sigue compartiendo su objeto. Un registro de más de 1024 hojas no puede ser elemento de un arreglo (recordArrayTooWide). Las reglas de R2, R3 y R4 se cumplen igual en cada una de estas posiciones.",
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
    "C44",
    "C45",
    "C46",
    "C47"
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

```caso
{
  "id": "C45",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Ancho\nDefinir f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29, f30, f31, f32, f33, f34, f35, f36, f37, f38, f39, f40, f41, f42, f43, f44, f45, f46, f47, f48, f49, f50, f51, f52, f53, f54, f55, f56, f57, f58, f59, f60, f61, f62, f63, f64, f65, f66, f67, f68, f69, f70, f71, f72, f73, f74, f75, f76, f77, f78, f79, f80, f81, f82, f83, f84, f85, f86, f87, f88, f89, f90, f91, f92, f93, f94, f95, f96, f97, f98, f99, f100, f101, f102, f103, f104, f105, f106, f107, f108, f109, f110, f111, f112, f113, f114, f115, f116, f117, f118, f119, f120, f121, f122, f123, f124, f125, f126, f127, f128, f129, f130, f131, f132, f133, f134, f135, f136, f137, f138, f139, f140, f141, f142, f143, f144, f145, f146, f147, f148, f149, f150, f151, f152, f153, f154, f155, f156, f157, f158, f159, f160, f161, f162, f163, f164, f165, f166, f167, f168, f169, f170, f171, f172, f173, f174, f175, f176, f177, f178, f179, f180, f181, f182, f183, f184, f185, f186, f187, f188, f189, f190, f191, f192, f193, f194, f195, f196, f197, f198, f199, f200, f201, f202, f203, f204, f205, f206, f207, f208, f209, f210, f211, f212, f213, f214, f215, f216, f217, f218, f219, f220, f221, f222, f223, f224, f225, f226, f227, f228, f229, f230, f231, f232, f233, f234, f235, f236, f237, f238, f239, f240, f241, f242, f243, f244, f245, f246, f247, f248, f249, f250, f251, f252, f253, f254, f255, f256, f257, f258, f259, f260, f261, f262, f263, f264, f265, f266, f267, f268, f269, f270, f271, f272, f273, f274, f275, f276, f277, f278, f279, f280, f281, f282, f283, f284, f285, f286, f287, f288, f289, f290, f291, f292, f293, f294, f295, f296, f297, f298, f299, f300, f301, f302, f303, f304, f305, f306, f307, f308, f309, f310, f311, f312, f313, f314, f315, f316, f317, f318, f319, f320, f321, f322, f323, f324, f325, f326, f327, f328, f329, f330, f331, f332, f333, f334, f335, f336, f337, f338, f339, f340, f341, f342, f343, f344, f345, f346, f347, f348, f349, f350, f351, f352, f353, f354, f355, f356, f357, f358, f359, f360, f361, f362, f363, f364, f365, f366, f367, f368, f369, f370, f371, f372, f373, f374, f375, f376, f377, f378, f379, f380, f381, f382, f383, f384, f385, f386, f387, f388, f389, f390, f391, f392, f393, f394, f395, f396, f397, f398, f399, f400, f401, f402, f403, f404, f405, f406, f407, f408, f409, f410, f411, f412, f413, f414, f415, f416, f417, f418, f419, f420, f421, f422, f423, f424, f425, f426, f427, f428, f429, f430, f431, f432, f433, f434, f435, f436, f437, f438, f439, f440, f441, f442, f443, f444, f445, f446, f447, f448, f449, f450, f451, f452, f453, f454, f455, f456, f457, f458, f459, f460, f461, f462, f463, f464, f465, f466, f467, f468, f469, f470, f471, f472, f473, f474, f475, f476, f477, f478, f479, f480, f481, f482, f483, f484, f485, f486, f487, f488, f489, f490, f491, f492, f493, f494, f495, f496, f497, f498, f499, f500, f501, f502, f503, f504, f505, f506, f507, f508, f509, f510, f511, f512, f513, f514, f515, f516, f517, f518, f519, f520, f521, f522, f523, f524, f525, f526, f527, f528, f529, f530, f531, f532, f533, f534, f535, f536, f537, f538, f539, f540, f541, f542, f543, f544, f545, f546, f547, f548, f549, f550, f551, f552, f553, f554, f555, f556, f557, f558, f559, f560, f561, f562, f563, f564, f565, f566, f567, f568, f569, f570, f571, f572, f573, f574, f575, f576, f577, f578, f579, f580, f581, f582, f583, f584, f585, f586, f587, f588, f589, f590, f591, f592, f593, f594, f595, f596, f597, f598, f599, f600, f601, f602, f603, f604, f605, f606, f607, f608, f609, f610, f611, f612, f613, f614, f615, f616, f617, f618, f619, f620, f621, f622, f623, f624, f625, f626, f627, f628, f629, f630, f631, f632, f633, f634, f635, f636, f637, f638, f639, f640, f641, f642, f643, f644, f645, f646, f647, f648, f649, f650, f651, f652, f653, f654, f655, f656, f657, f658, f659, f660, f661, f662, f663, f664, f665, f666, f667, f668, f669, f670, f671, f672, f673, f674, f675, f676, f677, f678, f679, f680, f681, f682, f683, f684, f685, f686, f687, f688, f689, f690, f691, f692, f693, f694, f695, f696, f697, f698, f699, f700, f701, f702, f703, f704, f705, f706, f707, f708, f709, f710, f711, f712, f713, f714, f715, f716, f717, f718, f719, f720, f721, f722, f723, f724, f725, f726, f727, f728, f729, f730, f731, f732, f733, f734, f735, f736, f737, f738, f739, f740, f741, f742, f743, f744, f745, f746, f747, f748, f749, f750, f751, f752, f753, f754, f755, f756, f757, f758, f759, f760, f761, f762, f763, f764, f765, f766, f767, f768, f769, f770, f771, f772, f773, f774, f775, f776, f777, f778, f779, f780, f781, f782, f783, f784, f785, f786, f787, f788, f789, f790, f791, f792, f793, f794, f795, f796, f797, f798, f799, f800, f801, f802, f803, f804, f805, f806, f807, f808, f809, f810, f811, f812, f813, f814, f815, f816, f817, f818, f819, f820, f821, f822, f823, f824, f825, f826, f827, f828, f829, f830, f831, f832, f833, f834, f835, f836, f837, f838, f839, f840, f841, f842, f843, f844, f845, f846, f847, f848, f849, f850, f851, f852, f853, f854, f855, f856, f857, f858, f859, f860, f861, f862, f863, f864, f865, f866, f867, f868, f869, f870, f871, f872, f873, f874, f875, f876, f877, f878, f879, f880, f881, f882, f883, f884, f885, f886, f887, f888, f889, f890, f891, f892, f893, f894, f895, f896, f897, f898, f899, f900, f901, f902, f903, f904, f905, f906, f907, f908, f909, f910, f911, f912, f913, f914, f915, f916, f917, f918, f919, f920, f921, f922, f923, f924, f925, f926, f927, f928, f929, f930, f931, f932, f933, f934, f935, f936, f937, f938, f939, f940, f941, f942, f943, f944, f945, f946, f947, f948, f949, f950, f951, f952, f953, f954, f955, f956, f957, f958, f959, f960, f961, f962, f963, f964, f965, f966, f967, f968, f969, f970, f971, f972, f973, f974, f975, f976, f977, f978, f979, f980, f981, f982, f983, f984, f985, f986, f987, f988, f989, f990, f991, f992, f993, f994, f995, f996, f997, f998, f999, f1000, f1001, f1002, f1003, f1004, f1005, f1006, f1007, f1008, f1009, f1010, f1011, f1012, f1013, f1014, f1015, f1016, f1017, f1018, f1019, f1020, f1021, f1022, f1023, f1024 Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[2] Como Ancho;\nFinAlgoritmo\n",
    "en": "record Ancho\ndefine f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29, f30, f31, f32, f33, f34, f35, f36, f37, f38, f39, f40, f41, f42, f43, f44, f45, f46, f47, f48, f49, f50, f51, f52, f53, f54, f55, f56, f57, f58, f59, f60, f61, f62, f63, f64, f65, f66, f67, f68, f69, f70, f71, f72, f73, f74, f75, f76, f77, f78, f79, f80, f81, f82, f83, f84, f85, f86, f87, f88, f89, f90, f91, f92, f93, f94, f95, f96, f97, f98, f99, f100, f101, f102, f103, f104, f105, f106, f107, f108, f109, f110, f111, f112, f113, f114, f115, f116, f117, f118, f119, f120, f121, f122, f123, f124, f125, f126, f127, f128, f129, f130, f131, f132, f133, f134, f135, f136, f137, f138, f139, f140, f141, f142, f143, f144, f145, f146, f147, f148, f149, f150, f151, f152, f153, f154, f155, f156, f157, f158, f159, f160, f161, f162, f163, f164, f165, f166, f167, f168, f169, f170, f171, f172, f173, f174, f175, f176, f177, f178, f179, f180, f181, f182, f183, f184, f185, f186, f187, f188, f189, f190, f191, f192, f193, f194, f195, f196, f197, f198, f199, f200, f201, f202, f203, f204, f205, f206, f207, f208, f209, f210, f211, f212, f213, f214, f215, f216, f217, f218, f219, f220, f221, f222, f223, f224, f225, f226, f227, f228, f229, f230, f231, f232, f233, f234, f235, f236, f237, f238, f239, f240, f241, f242, f243, f244, f245, f246, f247, f248, f249, f250, f251, f252, f253, f254, f255, f256, f257, f258, f259, f260, f261, f262, f263, f264, f265, f266, f267, f268, f269, f270, f271, f272, f273, f274, f275, f276, f277, f278, f279, f280, f281, f282, f283, f284, f285, f286, f287, f288, f289, f290, f291, f292, f293, f294, f295, f296, f297, f298, f299, f300, f301, f302, f303, f304, f305, f306, f307, f308, f309, f310, f311, f312, f313, f314, f315, f316, f317, f318, f319, f320, f321, f322, f323, f324, f325, f326, f327, f328, f329, f330, f331, f332, f333, f334, f335, f336, f337, f338, f339, f340, f341, f342, f343, f344, f345, f346, f347, f348, f349, f350, f351, f352, f353, f354, f355, f356, f357, f358, f359, f360, f361, f362, f363, f364, f365, f366, f367, f368, f369, f370, f371, f372, f373, f374, f375, f376, f377, f378, f379, f380, f381, f382, f383, f384, f385, f386, f387, f388, f389, f390, f391, f392, f393, f394, f395, f396, f397, f398, f399, f400, f401, f402, f403, f404, f405, f406, f407, f408, f409, f410, f411, f412, f413, f414, f415, f416, f417, f418, f419, f420, f421, f422, f423, f424, f425, f426, f427, f428, f429, f430, f431, f432, f433, f434, f435, f436, f437, f438, f439, f440, f441, f442, f443, f444, f445, f446, f447, f448, f449, f450, f451, f452, f453, f454, f455, f456, f457, f458, f459, f460, f461, f462, f463, f464, f465, f466, f467, f468, f469, f470, f471, f472, f473, f474, f475, f476, f477, f478, f479, f480, f481, f482, f483, f484, f485, f486, f487, f488, f489, f490, f491, f492, f493, f494, f495, f496, f497, f498, f499, f500, f501, f502, f503, f504, f505, f506, f507, f508, f509, f510, f511, f512, f513, f514, f515, f516, f517, f518, f519, f520, f521, f522, f523, f524, f525, f526, f527, f528, f529, f530, f531, f532, f533, f534, f535, f536, f537, f538, f539, f540, f541, f542, f543, f544, f545, f546, f547, f548, f549, f550, f551, f552, f553, f554, f555, f556, f557, f558, f559, f560, f561, f562, f563, f564, f565, f566, f567, f568, f569, f570, f571, f572, f573, f574, f575, f576, f577, f578, f579, f580, f581, f582, f583, f584, f585, f586, f587, f588, f589, f590, f591, f592, f593, f594, f595, f596, f597, f598, f599, f600, f601, f602, f603, f604, f605, f606, f607, f608, f609, f610, f611, f612, f613, f614, f615, f616, f617, f618, f619, f620, f621, f622, f623, f624, f625, f626, f627, f628, f629, f630, f631, f632, f633, f634, f635, f636, f637, f638, f639, f640, f641, f642, f643, f644, f645, f646, f647, f648, f649, f650, f651, f652, f653, f654, f655, f656, f657, f658, f659, f660, f661, f662, f663, f664, f665, f666, f667, f668, f669, f670, f671, f672, f673, f674, f675, f676, f677, f678, f679, f680, f681, f682, f683, f684, f685, f686, f687, f688, f689, f690, f691, f692, f693, f694, f695, f696, f697, f698, f699, f700, f701, f702, f703, f704, f705, f706, f707, f708, f709, f710, f711, f712, f713, f714, f715, f716, f717, f718, f719, f720, f721, f722, f723, f724, f725, f726, f727, f728, f729, f730, f731, f732, f733, f734, f735, f736, f737, f738, f739, f740, f741, f742, f743, f744, f745, f746, f747, f748, f749, f750, f751, f752, f753, f754, f755, f756, f757, f758, f759, f760, f761, f762, f763, f764, f765, f766, f767, f768, f769, f770, f771, f772, f773, f774, f775, f776, f777, f778, f779, f780, f781, f782, f783, f784, f785, f786, f787, f788, f789, f790, f791, f792, f793, f794, f795, f796, f797, f798, f799, f800, f801, f802, f803, f804, f805, f806, f807, f808, f809, f810, f811, f812, f813, f814, f815, f816, f817, f818, f819, f820, f821, f822, f823, f824, f825, f826, f827, f828, f829, f830, f831, f832, f833, f834, f835, f836, f837, f838, f839, f840, f841, f842, f843, f844, f845, f846, f847, f848, f849, f850, f851, f852, f853, f854, f855, f856, f857, f858, f859, f860, f861, f862, f863, f864, f865, f866, f867, f868, f869, f870, f871, f872, f873, f874, f875, f876, f877, f878, f879, f880, f881, f882, f883, f884, f885, f886, f887, f888, f889, f890, f891, f892, f893, f894, f895, f896, f897, f898, f899, f900, f901, f902, f903, f904, f905, f906, f907, f908, f909, f910, f911, f912, f913, f914, f915, f916, f917, f918, f919, f920, f921, f922, f923, f924, f925, f926, f927, f928, f929, f930, f931, f932, f933, f934, f935, f936, f937, f938, f939, f940, f941, f942, f943, f944, f945, f946, f947, f948, f949, f950, f951, f952, f953, f954, f955, f956, f957, f958, f959, f960, f961, f962, f963, f964, f965, f966, f967, f968, f969, f970, f971, f972, f973, f974, f975, f976, f977, f978, f979, f980, f981, f982, f983, f984, f985, f986, f987, f988, f989, f990, f991, f992, f993, f994, f995, f996, f997, f998, f999, f1000, f1001, f1002, f1003, f1004, f1005, f1006, f1007, f1008, f1009, f1010, f1011, f1012, f1013, f1014, f1015, f1016, f1017, f1018, f1019, f1020, f1021, f1022, f1023, f1024 as integer;\nendRecord\nalgorithm P\ndimension a[2] as Ancho;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recordArrayTooWide",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C46",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Ancho\nDefinir f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29, f30, f31, f32, f33, f34, f35, f36, f37, f38, f39, f40, f41, f42, f43, f44, f45, f46, f47, f48, f49, f50, f51, f52, f53, f54, f55, f56, f57, f58, f59, f60, f61, f62, f63, f64, f65, f66, f67, f68, f69, f70, f71, f72, f73, f74, f75, f76, f77, f78, f79, f80, f81, f82, f83, f84, f85, f86, f87, f88, f89, f90, f91, f92, f93, f94, f95, f96, f97, f98, f99, f100, f101, f102, f103, f104, f105, f106, f107, f108, f109, f110, f111, f112, f113, f114, f115, f116, f117, f118, f119, f120, f121, f122, f123, f124, f125, f126, f127, f128, f129, f130, f131, f132, f133, f134, f135, f136, f137, f138, f139, f140, f141, f142, f143, f144, f145, f146, f147, f148, f149, f150, f151, f152, f153, f154, f155, f156, f157, f158, f159, f160, f161, f162, f163, f164, f165, f166, f167, f168, f169, f170, f171, f172, f173, f174, f175, f176, f177, f178, f179, f180, f181, f182, f183, f184, f185, f186, f187, f188, f189, f190, f191, f192, f193, f194, f195, f196, f197, f198, f199, f200, f201, f202, f203, f204, f205, f206, f207, f208, f209, f210, f211, f212, f213, f214, f215, f216, f217, f218, f219, f220, f221, f222, f223, f224, f225, f226, f227, f228, f229, f230, f231, f232, f233, f234, f235, f236, f237, f238, f239, f240, f241, f242, f243, f244, f245, f246, f247, f248, f249, f250, f251, f252, f253, f254, f255, f256, f257, f258, f259, f260, f261, f262, f263, f264, f265, f266, f267, f268, f269, f270, f271, f272, f273, f274, f275, f276, f277, f278, f279, f280, f281, f282, f283, f284, f285, f286, f287, f288, f289, f290, f291, f292, f293, f294, f295, f296, f297, f298, f299, f300, f301, f302, f303, f304, f305, f306, f307, f308, f309, f310, f311, f312, f313, f314, f315, f316, f317, f318, f319, f320, f321, f322, f323, f324, f325, f326, f327, f328, f329, f330, f331, f332, f333, f334, f335, f336, f337, f338, f339, f340, f341, f342, f343, f344, f345, f346, f347, f348, f349, f350, f351, f352, f353, f354, f355, f356, f357, f358, f359, f360, f361, f362, f363, f364, f365, f366, f367, f368, f369, f370, f371, f372, f373, f374, f375, f376, f377, f378, f379, f380, f381, f382, f383, f384, f385, f386, f387, f388, f389, f390, f391, f392, f393, f394, f395, f396, f397, f398, f399, f400, f401, f402, f403, f404, f405, f406, f407, f408, f409, f410, f411, f412, f413, f414, f415, f416, f417, f418, f419, f420, f421, f422, f423, f424, f425, f426, f427, f428, f429, f430, f431, f432, f433, f434, f435, f436, f437, f438, f439, f440, f441, f442, f443, f444, f445, f446, f447, f448, f449, f450, f451, f452, f453, f454, f455, f456, f457, f458, f459, f460, f461, f462, f463, f464, f465, f466, f467, f468, f469, f470, f471, f472, f473, f474, f475, f476, f477, f478, f479, f480, f481, f482, f483, f484, f485, f486, f487, f488, f489, f490, f491, f492, f493, f494, f495, f496, f497, f498, f499, f500, f501, f502, f503, f504, f505, f506, f507, f508, f509, f510, f511, f512, f513, f514, f515, f516, f517, f518, f519, f520, f521, f522, f523, f524, f525, f526, f527, f528, f529, f530, f531, f532, f533, f534, f535, f536, f537, f538, f539, f540, f541, f542, f543, f544, f545, f546, f547, f548, f549, f550, f551, f552, f553, f554, f555, f556, f557, f558, f559, f560, f561, f562, f563, f564, f565, f566, f567, f568, f569, f570, f571, f572, f573, f574, f575, f576, f577, f578, f579, f580, f581, f582, f583, f584, f585, f586, f587, f588, f589, f590, f591, f592, f593, f594, f595, f596, f597, f598, f599, f600, f601, f602, f603, f604, f605, f606, f607, f608, f609, f610, f611, f612, f613, f614, f615, f616, f617, f618, f619, f620, f621, f622, f623, f624, f625, f626, f627, f628, f629, f630, f631, f632, f633, f634, f635, f636, f637, f638, f639, f640, f641, f642, f643, f644, f645, f646, f647, f648, f649, f650, f651, f652, f653, f654, f655, f656, f657, f658, f659, f660, f661, f662, f663, f664, f665, f666, f667, f668, f669, f670, f671, f672, f673, f674, f675, f676, f677, f678, f679, f680, f681, f682, f683, f684, f685, f686, f687, f688, f689, f690, f691, f692, f693, f694, f695, f696, f697, f698, f699, f700, f701, f702, f703, f704, f705, f706, f707, f708, f709, f710, f711, f712, f713, f714, f715, f716, f717, f718, f719, f720, f721, f722, f723, f724, f725, f726, f727, f728, f729, f730, f731, f732, f733, f734, f735, f736, f737, f738, f739, f740, f741, f742, f743, f744, f745, f746, f747, f748, f749, f750, f751, f752, f753, f754, f755, f756, f757, f758, f759, f760, f761, f762, f763, f764, f765, f766, f767, f768, f769, f770, f771, f772, f773, f774, f775, f776, f777, f778, f779, f780, f781, f782, f783, f784, f785, f786, f787, f788, f789, f790, f791, f792, f793, f794, f795, f796, f797, f798, f799, f800, f801, f802, f803, f804, f805, f806, f807, f808, f809, f810, f811, f812, f813, f814, f815, f816, f817, f818, f819, f820, f821, f822, f823, f824, f825, f826, f827, f828, f829, f830, f831, f832, f833, f834, f835, f836, f837, f838, f839, f840, f841, f842, f843, f844, f845, f846, f847, f848, f849, f850, f851, f852, f853, f854, f855, f856, f857, f858, f859, f860, f861, f862, f863, f864, f865, f866, f867, f868, f869, f870, f871, f872, f873, f874, f875, f876, f877, f878, f879, f880, f881, f882, f883, f884, f885, f886, f887, f888, f889, f890, f891, f892, f893, f894, f895, f896, f897, f898, f899, f900, f901, f902, f903, f904, f905, f906, f907, f908, f909, f910, f911, f912, f913, f914, f915, f916, f917, f918, f919, f920, f921, f922, f923, f924, f925, f926, f927, f928, f929, f930, f931, f932, f933, f934, f935, f936, f937, f938, f939, f940, f941, f942, f943, f944, f945, f946, f947, f948, f949, f950, f951, f952, f953, f954, f955, f956, f957, f958, f959, f960, f961, f962, f963, f964, f965, f966, f967, f968, f969, f970, f971, f972, f973, f974, f975, f976, f977, f978, f979, f980, f981, f982, f983, f984, f985, f986, f987, f988, f989, f990, f991, f992, f993, f994, f995, f996, f997, f998, f999, f1000, f1001, f1002, f1003, f1004, f1005, f1006, f1007, f1008, f1009, f1010, f1011, f1012, f1013, f1014, f1015, f1016, f1017, f1018, f1019, f1020, f1021, f1022, f1023 Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[2] Como Ancho;\na[1].f7 <- 5;\nEscribir a[1].f7;\nFinAlgoritmo\n",
    "en": "record Ancho\ndefine f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28, f29, f30, f31, f32, f33, f34, f35, f36, f37, f38, f39, f40, f41, f42, f43, f44, f45, f46, f47, f48, f49, f50, f51, f52, f53, f54, f55, f56, f57, f58, f59, f60, f61, f62, f63, f64, f65, f66, f67, f68, f69, f70, f71, f72, f73, f74, f75, f76, f77, f78, f79, f80, f81, f82, f83, f84, f85, f86, f87, f88, f89, f90, f91, f92, f93, f94, f95, f96, f97, f98, f99, f100, f101, f102, f103, f104, f105, f106, f107, f108, f109, f110, f111, f112, f113, f114, f115, f116, f117, f118, f119, f120, f121, f122, f123, f124, f125, f126, f127, f128, f129, f130, f131, f132, f133, f134, f135, f136, f137, f138, f139, f140, f141, f142, f143, f144, f145, f146, f147, f148, f149, f150, f151, f152, f153, f154, f155, f156, f157, f158, f159, f160, f161, f162, f163, f164, f165, f166, f167, f168, f169, f170, f171, f172, f173, f174, f175, f176, f177, f178, f179, f180, f181, f182, f183, f184, f185, f186, f187, f188, f189, f190, f191, f192, f193, f194, f195, f196, f197, f198, f199, f200, f201, f202, f203, f204, f205, f206, f207, f208, f209, f210, f211, f212, f213, f214, f215, f216, f217, f218, f219, f220, f221, f222, f223, f224, f225, f226, f227, f228, f229, f230, f231, f232, f233, f234, f235, f236, f237, f238, f239, f240, f241, f242, f243, f244, f245, f246, f247, f248, f249, f250, f251, f252, f253, f254, f255, f256, f257, f258, f259, f260, f261, f262, f263, f264, f265, f266, f267, f268, f269, f270, f271, f272, f273, f274, f275, f276, f277, f278, f279, f280, f281, f282, f283, f284, f285, f286, f287, f288, f289, f290, f291, f292, f293, f294, f295, f296, f297, f298, f299, f300, f301, f302, f303, f304, f305, f306, f307, f308, f309, f310, f311, f312, f313, f314, f315, f316, f317, f318, f319, f320, f321, f322, f323, f324, f325, f326, f327, f328, f329, f330, f331, f332, f333, f334, f335, f336, f337, f338, f339, f340, f341, f342, f343, f344, f345, f346, f347, f348, f349, f350, f351, f352, f353, f354, f355, f356, f357, f358, f359, f360, f361, f362, f363, f364, f365, f366, f367, f368, f369, f370, f371, f372, f373, f374, f375, f376, f377, f378, f379, f380, f381, f382, f383, f384, f385, f386, f387, f388, f389, f390, f391, f392, f393, f394, f395, f396, f397, f398, f399, f400, f401, f402, f403, f404, f405, f406, f407, f408, f409, f410, f411, f412, f413, f414, f415, f416, f417, f418, f419, f420, f421, f422, f423, f424, f425, f426, f427, f428, f429, f430, f431, f432, f433, f434, f435, f436, f437, f438, f439, f440, f441, f442, f443, f444, f445, f446, f447, f448, f449, f450, f451, f452, f453, f454, f455, f456, f457, f458, f459, f460, f461, f462, f463, f464, f465, f466, f467, f468, f469, f470, f471, f472, f473, f474, f475, f476, f477, f478, f479, f480, f481, f482, f483, f484, f485, f486, f487, f488, f489, f490, f491, f492, f493, f494, f495, f496, f497, f498, f499, f500, f501, f502, f503, f504, f505, f506, f507, f508, f509, f510, f511, f512, f513, f514, f515, f516, f517, f518, f519, f520, f521, f522, f523, f524, f525, f526, f527, f528, f529, f530, f531, f532, f533, f534, f535, f536, f537, f538, f539, f540, f541, f542, f543, f544, f545, f546, f547, f548, f549, f550, f551, f552, f553, f554, f555, f556, f557, f558, f559, f560, f561, f562, f563, f564, f565, f566, f567, f568, f569, f570, f571, f572, f573, f574, f575, f576, f577, f578, f579, f580, f581, f582, f583, f584, f585, f586, f587, f588, f589, f590, f591, f592, f593, f594, f595, f596, f597, f598, f599, f600, f601, f602, f603, f604, f605, f606, f607, f608, f609, f610, f611, f612, f613, f614, f615, f616, f617, f618, f619, f620, f621, f622, f623, f624, f625, f626, f627, f628, f629, f630, f631, f632, f633, f634, f635, f636, f637, f638, f639, f640, f641, f642, f643, f644, f645, f646, f647, f648, f649, f650, f651, f652, f653, f654, f655, f656, f657, f658, f659, f660, f661, f662, f663, f664, f665, f666, f667, f668, f669, f670, f671, f672, f673, f674, f675, f676, f677, f678, f679, f680, f681, f682, f683, f684, f685, f686, f687, f688, f689, f690, f691, f692, f693, f694, f695, f696, f697, f698, f699, f700, f701, f702, f703, f704, f705, f706, f707, f708, f709, f710, f711, f712, f713, f714, f715, f716, f717, f718, f719, f720, f721, f722, f723, f724, f725, f726, f727, f728, f729, f730, f731, f732, f733, f734, f735, f736, f737, f738, f739, f740, f741, f742, f743, f744, f745, f746, f747, f748, f749, f750, f751, f752, f753, f754, f755, f756, f757, f758, f759, f760, f761, f762, f763, f764, f765, f766, f767, f768, f769, f770, f771, f772, f773, f774, f775, f776, f777, f778, f779, f780, f781, f782, f783, f784, f785, f786, f787, f788, f789, f790, f791, f792, f793, f794, f795, f796, f797, f798, f799, f800, f801, f802, f803, f804, f805, f806, f807, f808, f809, f810, f811, f812, f813, f814, f815, f816, f817, f818, f819, f820, f821, f822, f823, f824, f825, f826, f827, f828, f829, f830, f831, f832, f833, f834, f835, f836, f837, f838, f839, f840, f841, f842, f843, f844, f845, f846, f847, f848, f849, f850, f851, f852, f853, f854, f855, f856, f857, f858, f859, f860, f861, f862, f863, f864, f865, f866, f867, f868, f869, f870, f871, f872, f873, f874, f875, f876, f877, f878, f879, f880, f881, f882, f883, f884, f885, f886, f887, f888, f889, f890, f891, f892, f893, f894, f895, f896, f897, f898, f899, f900, f901, f902, f903, f904, f905, f906, f907, f908, f909, f910, f911, f912, f913, f914, f915, f916, f917, f918, f919, f920, f921, f922, f923, f924, f925, f926, f927, f928, f929, f930, f931, f932, f933, f934, f935, f936, f937, f938, f939, f940, f941, f942, f943, f944, f945, f946, f947, f948, f949, f950, f951, f952, f953, f954, f955, f956, f957, f958, f959, f960, f961, f962, f963, f964, f965, f966, f967, f968, f969, f970, f971, f972, f973, f974, f975, f976, f977, f978, f979, f980, f981, f982, f983, f984, f985, f986, f987, f988, f989, f990, f991, f992, f993, f994, f995, f996, f997, f998, f999, f1000, f1001, f1002, f1003, f1004, f1005, f1006, f1007, f1008, f1009, f1010, f1011, f1012, f1013, f1014, f1015, f1016, f1017, f1018, f1019, f1020, f1021, f1022, f1023 as integer;\nendRecord\nalgorithm P\ndimension a[2] as Ancho;\na[1].f7 <- 5;\nwrite a[1].f7;\nendAlgorithm\n"
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
  "id": "C47",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso mover(p Como Punto Por Referencia)\np.x <- 1;\nFinSubProceso\nAlgoritmo P\nDimension a[2] Como Punto;\nEscribir 1;\nmover(a[5]);\nEscribir 2;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine mover(p as Punto by reference)\np.x <- 1;\nendSubroutine\nalgorithm P\ndimension a[2] as Punto;\nwrite 1;\nmover(a[5]);\nwrite 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C48",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R0\nDefinir a, b Como Entero;\nFinRegistro\nRegistro R1\nDefinir a, b Como R0;\nFinRegistro\nRegistro R2\nDefinir a, b Como R1;\nFinRegistro\nRegistro R3\nDefinir a, b Como R2;\nFinRegistro\nRegistro R4\nDefinir a, b Como R3;\nFinRegistro\nRegistro R5\nDefinir a, b Como R4;\nFinRegistro\nRegistro R6\nDefinir a, b Como R5;\nFinRegistro\nRegistro R7\nDefinir a, b Como R6;\nFinRegistro\nRegistro R8\nDefinir a, b Como R7;\nFinRegistro\nRegistro R9\nDefinir a, b Como R8;\nFinRegistro\nRegistro R10\nDefinir a, b Como R9;\nFinRegistro\nRegistro R11\nDefinir a, b Como R10;\nFinRegistro\nRegistro R12\nDefinir a, b Como R11;\nFinRegistro\nRegistro R13\nDefinir a, b Como R12;\nFinRegistro\nRegistro R14\nDefinir a, b Como R13;\nFinRegistro\nRegistro R15\nDefinir a, b Como R14;\nFinRegistro\nRegistro R16\nDefinir a, b Como R15;\nFinRegistro\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "record R0\ndefine a, b as integer;\nendRecord\nrecord R1\ndefine a, b as R0;\nendRecord\nrecord R2\ndefine a, b as R1;\nendRecord\nrecord R3\ndefine a, b as R2;\nendRecord\nrecord R4\ndefine a, b as R3;\nendRecord\nrecord R5\ndefine a, b as R4;\nendRecord\nrecord R6\ndefine a, b as R5;\nendRecord\nrecord R7\ndefine a, b as R6;\nendRecord\nrecord R8\ndefine a, b as R7;\nendRecord\nrecord R9\ndefine a, b as R8;\nendRecord\nrecord R10\ndefine a, b as R9;\nendRecord\nrecord R11\ndefine a, b as R10;\nendRecord\nrecord R12\ndefine a, b as R11;\nendRecord\nrecord R13\ndefine a, b as R12;\nendRecord\nrecord R14\ndefine a, b as R13;\nendRecord\nrecord R15\ndefine a, b as R14;\nendRecord\nrecord R16\ndefine a, b as R15;\nendRecord\nalgorithm P\nwrite \"listo\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recordLayoutLimit",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C49",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro R0\nDefinir a, b Como Entero;\nFinRegistro\nRegistro R1\nDefinir a, b Como R0;\nFinRegistro\nRegistro R2\nDefinir a, b Como R1;\nFinRegistro\nRegistro R3\nDefinir a, b Como R2;\nFinRegistro\nRegistro R4\nDefinir a, b Como R3;\nFinRegistro\nRegistro R5\nDefinir a, b Como R4;\nFinRegistro\nRegistro R6\nDefinir a, b Como R5;\nFinRegistro\nRegistro R7\nDefinir a, b Como R6;\nFinRegistro\nRegistro R8\nDefinir a, b Como R7;\nFinRegistro\nRegistro R9\nDefinir a, b Como R8;\nFinRegistro\nRegistro R10\nDefinir a, b Como R9;\nFinRegistro\nRegistro R11\nDefinir a, b Como R10;\nFinRegistro\nRegistro R12\nDefinir a, b Como R11;\nFinRegistro\nRegistro R13\nDefinir a, b Como R12;\nFinRegistro\nRegistro R14\nDefinir a, b Como R13;\nFinRegistro\nAlgoritmo P\nEscribir \"listo\";\nFinAlgoritmo\n",
    "en": "record R0\ndefine a, b as integer;\nendRecord\nrecord R1\ndefine a, b as R0;\nendRecord\nrecord R2\ndefine a, b as R1;\nendRecord\nrecord R3\ndefine a, b as R2;\nendRecord\nrecord R4\ndefine a, b as R3;\nendRecord\nrecord R5\ndefine a, b as R4;\nendRecord\nrecord R6\ndefine a, b as R5;\nendRecord\nrecord R7\ndefine a, b as R6;\nendRecord\nrecord R8\ndefine a, b as R7;\nendRecord\nrecord R9\ndefine a, b as R8;\nendRecord\nrecord R10\ndefine a, b as R9;\nendRecord\nrecord R11\ndefine a, b as R10;\nendRecord\nrecord R12\ndefine a, b as R11;\nendRecord\nrecord R13\ndefine a, b as R12;\nendRecord\nrecord R14\ndefine a, b as R13;\nendRecord\nalgorithm P\nwrite \"listo\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "listo\n",
    "terminacion": "completed"
  }
}
```
