---
{
  "formato": "see/1",
  "id": "LANG.TYPES.INTERFACE",
  "titulo": "Interfaces nominales como restricciones",
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
  "resumen": "Interfaces nominales como restricciones",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.GENERIC",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Interfaces nominales como restricciones

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Interfaz nombre y FinInterfaz declaran en el módulo un conjunto nominal de firmas Metodo sin cuerpo. Las formas son contextuales por perfil: un identificador homónimo usado al declarar, asignar o llamar permanece ordinario. Una interfaz vacía es válida; firmas y nombres duplicados se rechazan. Una interfaz no es un tipo de valor, no tiene campos ni implementación heredada y no puede declararse dentro del cuerpo de una unidad.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Empty\nFinInterfaz\nAlgoritmo Main\n\nFinAlgoritmo\n",
    "en": "interface Empty\nendInterface\nalgorithm Main\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nAlgoritmo Main\nDefinir value Como Readable <- 1;\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nalgorithm Main\ndefine value as Readable <- 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "interfaceCannotBeValue",
        "severidad": "error"
      }
    ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nInterfaz Local\nFinInterfaz\nFinAlgoritmo\n",
    "en": "algorithm Main\ninterface Local\nendInterface\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "interfaceInsideAlgorithm",
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Incomplete\nAlgoritmo Main\n\nFinAlgoritmo\n",
    "en": "interface Incomplete\nalgorithm Main\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unclosedInterface",
        "severidad": "error"
      }
    ]
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Clase C Realiza I, J declara realizaciones explícitas. Los métodos públicos propios o heredados deben coincidir exactamente en nombre, tipos, modos de paso y retorno. Una subclase hereda la realización nominal y sus sobrescrituras deben conservarla. Firmas coincidentes sin realización explícita en la cadena no satisfacen la interfaz. No existe herencia múltiple de implementación.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C8",
    "C15"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nAlgoritmo Main\nDefinir value Como Reader <- Nuevo Reader();\nEscribir value.readValue();\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nalgorithm Main\ndefine value as Reader <- new Reader();\nwrite value.readValue();\nendAlgorithm\n"
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
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nFinClase\nAlgoritmo Main\n\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nendClass\nalgorithm Main\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "interfaceMethodMissing",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Cadena\nRetornar \"wrong\";\nFinMetodo\nFinClase\nAlgoritmo Main\n\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as string\nreturn \"wrong\";\nendMethod\nendClass\nalgorithm Main\n\nendAlgorithm\n"
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
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz First\nFinInterfaz\nInterfaz Second\nFinInterfaz\nClase Both Realiza First, Second\nFinClase\nAlgoritmo Main\nDefinir value Como Both <- Nuevo Both();\nFinAlgoritmo\n",
    "en": "interface First\nendInterface\ninterface Second\nendInterface\nclass Both implements First, Second\nendClass\nalgorithm Main\ndefine value as Both <- new Both();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un parámetro genérico T: I exige una realización nominal de I. La definición solo puede utilizar las firmas de I; el argumento concreto se comprueba antes de instanciar. La restricción se transmite entre parámetros opacos por identidad nominal. Tras monomorfizar se reutiliza el despacho ordinario: llamada directa cuando la jerarquía lo permite y virtual existente para conservar el método de la clase real. No hay valores ni tablas dinámicas de interfaz.",
  "verificacion": [
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14"
  ]
}
```

```caso
{
  "id": "C9",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nSubProceso readOnce<T: Readable>(value Como T) Como Entero\nRetornar value.readValue();\nFinSubProceso\nAlgoritmo Main\nEscribir readOnce(Nuevo Reader());\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nsubroutine readOnce<T: Readable>(value as T) as integer\nreturn value.readValue();\nendSubroutine\nalgorithm Main\nwrite readOnce(new Reader());\nendAlgorithm\n"
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
  "id": "C10",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nSubProceso readOnce<T: Readable>(value Como T) Como Entero\nRetornar value.readValue();\nFinSubProceso\nAlgoritmo Main\nEscribir readOnce(3);\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nsubroutine readOnce<T: Readable>(value as T) as integer\nreturn value.readValue();\nendSubroutine\nalgorithm Main\nwrite readOnce(3);\nendAlgorithm\n"
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
  "id": "C11",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nClase Child Hereda De Reader\nMetodo readValue() Como Entero\nRetornar 9;\nFinMetodo\nFinClase\nSubProceso readOnce<T: Readable>(value Como T) Como Entero\nRetornar value.readValue();\nFinSubProceso\nAlgoritmo Main\nDefinir value Como Reader <- Nuevo Child();\nEscribir readOnce(value);\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nclass Child inherits from Reader\nmethod readValue() as integer\nreturn 9;\nendMethod\nendClass\nsubroutine readOnce<T: Readable>(value as T) as integer\nreturn value.readValue();\nendSubroutine\nalgorithm Main\ndefine value as Reader <- new Child();\nwrite readOnce(value);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nSubProceso readOnce<T: Readable>(value Como T) Como Entero\nRetornar value.absent();\nFinSubProceso\nAlgoritmo Main\n\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nsubroutine readOnce<T: Readable>(value as T) as integer\nreturn value.absent();\nendSubroutine\nalgorithm Main\n\nendAlgorithm\n"
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
  "id": "C13",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nSubProceso readOnce<T: Readable>(value Como T) Como Entero\nRetornar value.readValue();\nFinSubProceso\nAlgoritmo Main\nEscribir readOnce(Nuevo Reader());\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nsubroutine readOnce<T: Readable>(value as T) as integer\nreturn value.readValue();\nendSubroutine\nalgorithm Main\nwrite readOnce(new Reader());\nendAlgorithm\n"
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
  "id": "C14",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nRegistro Holder<T: Readable>\nDefinir value Como T;\nFinRegistro\nAlgoritmo Main\nDefinir boxed Como Holder<Reader> <- Holder(Nuevo Reader());\nEscribir boxed.value.readValue();\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nrecord Holder<T: Readable>\ndefine value as T;\nendRecord\nalgorithm Main\ndefine boxed as Holder<Reader> <- Holder(new Reader());\nwrite boxed.value.readValue();\nendAlgorithm\n"
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
  "id": "C15",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nClase Reader Realiza Readable\nPrivado Metodo readValue() Como Entero\nRetornar 7;\nFinMetodo\nFinClase\nAlgoritmo Main\nDefinir value Como Reader <- Nuevo Reader();\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nprivate method readValue() as integer\nreturn 7;\nendMethod\nendClass\nalgorithm Main\ndefine value as Reader <- new Reader();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "interfaceMethodNotPublic",
        "severidad": "error"
      }
    ]
  }
}
```
