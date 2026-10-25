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
  "texto": "Registro nombre, una declaración Definir por línea y FinRegistro declaran un tipo agregado por valor en el módulo. Cada campo tiene un tipo entero, real, lógico, carácter, cadena, enumerado, clase u otro registro; un registro necesita al menos un campo (recordWithoutFields) y solo contiene declaraciones de campo (expectedRecordField). Un registro no puede contenerse a sí mismo por valor, directa ni indirectamente (recursiveRecordContainment); contener una clase que lo referencia sí es válido. Un registro no puede ser elemento de arreglo (recordArrayElementNotSupported), campo de clase (recordClassFieldNotSupported) ni parámetro o resultado de un método o constructor (recordMemberSignatureNotSupported) en esta edición. El tipo es privado del módulo.",
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
    "C10"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Asignar, pasar como argumento y devolver un registro copia todos sus campos: las variables no comparten estado, pero un campo de clase copia la referencia y comparte el objeto. Un parámetro de tipo registro se pasa por valor y por referencia es recordPassedByReference. Leer un campo de un registro sin valor es uninitializedVariableRead. En el rigor flexible, una variable no declarada no puede guardar un registro (recordNotInferable).",
  "verificacion": [
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C21"
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
    "es": "Registro Caja\nDefinir v Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir c Como Caja;\nc <- Caja(5);\nEscribir c.v;\nFinAlgoritmo\n",
    "en": "record Caja\ndefine v as integer;\nendRecord\nalgorithm P\ndefine c as Caja;\nc <- Caja(5);\nwrite c.v;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
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
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nRegistro Linea\nDefinir a, b Como Punto;\nFinRegistro\nAlgoritmo P\nDefinir l Como Linea;\nl <- Linea(Punto(1, 2), Punto(3, 4));\nl.b.z <- 9;\nEscribir l.a.x, l.b.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nrecord Linea\ndefine a, b as Punto;\nendRecord\nalgorithm P\ndefine l as Linea;\nl <- Linea(Punto(1, 2), Punto(3, 4));\nl.b.z <- 9;\nwrite l.a.x, l.b.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "19\n",
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
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDimension a[2] Como Punto;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndimension a[2] as Punto;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recordArrayElementNotSupported",
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
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto;\np <- Punto(1);\nEscribir p.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto;\np <- Punto(1);\nwrite p.x;\nendAlgorithm\n"
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
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Medida\nDefinir v Como Real;\nFinRegistro\nAlgoritmo P\nDefinir m Como Medida;\nm <- Medida(2);\nEscribir m.v;\nFinAlgoritmo\n",
    "en": "record Medida\ndefine v as real;\nendRecord\nalgorithm P\ndefine m as Medida;\nm <- Medida(2);\nwrite m.v;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0\n",
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
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto;\np <- Punto(1, 2);\nEscribir p.w;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto;\np <- Punto(1, 2);\nwrite p.w;\nendAlgorithm\n"
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
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p, q Como Punto;\np <- Punto(1, 2);\nq <- p;\nq.x <- 10;\nEscribir p.x, q.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p, q as Punto;\np <- Punto(1, 2);\nq <- p;\nq.x <- 10;\nwrite p.x, q.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "110\n",
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
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso mover(p Como Punto) Como Punto\np.x <- p.x + 1;\nRetornar p;\nFinSubProceso\nAlgoritmo P\nDefinir a, b Como Punto;\na <- Punto(1, 2);\nb <- mover(a);\nEscribir a.x, b.x;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine mover(p as Punto) as Punto\np.x <- p.x + 1;\nreturn p;\nendSubroutine\nalgorithm P\ndefine a, b as Punto;\na <- Punto(1, 2);\nb <- mover(a);\nwrite a.x, b.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "12\n",
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
  "id": "C13",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Caja\nDefinir v Como Entero;\nMetodo Constructor(v Como Entero)\nEste.v <- v;\nFinMetodo\nFinClase\nRegistro Par\nDefinir c Como Caja;\nFinRegistro\nAlgoritmo P\nDefinir p, q Como Par;\np <- Par(Nuevo Caja(1));\nq <- p;\nq.c.v <- 5;\nEscribir p.c.v;\nFinAlgoritmo\n",
    "en": "class Caja\ndefine v as integer;\nmethod constructor(v as integer)\nthis.v <- v;\nendMethod\nendClass\nrecord Par\ndefine c as Caja;\nendRecord\nalgorithm P\ndefine p, q as Par;\np <- Par(new Caja(1));\nq <- p;\nq.c.v <- 5;\nwrite p.c.v;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
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
  "id": "C14",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nSubProceso mover(p Como Punto Por Referencia)\nEscribir p.x;\nFinSubProceso\nAlgoritmo P\nDefinir a Como Punto;\na <- Punto(1, 2);\nmover(a);\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nsubroutine mover(p as Punto by reference)\nwrite p.x;\nendSubroutine\nalgorithm P\ndefine a as Punto;\na <- Punto(1, 2);\nmover(a);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recordPassedByReference",
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
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "uninitializedVariableRead"
    }
  },
  "rigor": [
    "flexible"
  ]
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
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Medida\nDefinir v Como Real;\nFinRegistro\nAlgoritmo P\nDefinir a, b Como Medida;\na <- Medida(0.0);\nb <- Medida(-0.0);\nEscribir a = b;\nFinAlgoritmo\n",
    "en": "record Medida\ndefine v as real;\nendRecord\nalgorithm P\ndefine a, b as Medida;\na <- Medida(0.0);\nb <- Medida(-0.0);\nwrite a = b;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
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
  "id": "C18",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto;\np <- Punto(1, 2);\nEscribir p;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto;\np <- Punto(1, 2);\nwrite p;\nendAlgorithm\n"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nClase K\nMetodo m(p Como Punto)\nEscribir p.x;\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nclass K\nmethod m(p as Punto)\nwrite p.x;\nendMethod\nendClass\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "recordMemberSignatureNotSupported",
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
        "codigo": "recordNotInferable",
        "severidad": "error"
      },
      {
        "codigo": "undeclaredVariable",
        "severidad": "advertencia"
      }
    ]
  },
  "rigor": [
    "flexible"
  ]
}
```
