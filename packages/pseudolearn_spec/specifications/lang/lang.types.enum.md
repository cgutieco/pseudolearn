---
{
  "formato": "see/1",
  "id": "LANG.TYPES.ENUM",
  "titulo": "Enumerados",
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
  "resumen": "Tipo enumerado nominal con ordinales densos.",
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
      "id": "LANG.DECL.CONSTANT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Enumerados

Un enumerado es un conjunto cerrado de nombres con un ordinal por miembro.

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Enumerado nombre, una línea de miembros separados por comas y FinEnumerado declaran un tipo nuevo en el módulo. Los miembros se escriben nombre.miembro, no se repiten dentro del enumerado y pueden repetirse en otro enumerado. Cada miembro tiene un ordinal entero sin signo de 32 bits desde cero en orden de declaración. El enumerado vacío y el de un solo miembro son válidos. El tipo es privado del módulo y comparte espacio de nombres con clases y registros.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un valor de enumerado se asigna, se pasa, se devuelve y se guarda en constantes o variables de su tipo. Solo admite igualdad y desigualdad con otro valor del mismo enumerado; no admite orden, aritmética ni conversión a número. Escribir imprime el nombre del miembro tal como se declaró. Leer una variable de enumerado sin valor es uninitializedVariableRead.",
  "verificacion": [
    "C6",
    "C7",
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
  "texto": "Un miembro inexistente es undefinedEnumMember, un miembro repetido es duplicateEnumMember y un tipo con el nombre de otro tipo del módulo es duplicateTypeDeclaration.",
  "verificacion": [
    "C11",
    "C12",
    "C13"
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
    "es": "Enumerado Color\nRojo, Verde, Azul\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nc <- Color.Verde;\nEscribir c;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\ndefine c as Color;\nc <- Color.Verde;\nwrite c;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Verde\n",
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
    "es": "Enumerado Solo\nUnico\nFinEnumerado\nEnumerado Nada\nFinEnumerado\nAlgoritmo P\nEscribir Solo.Unico;\nFinAlgoritmo\n",
    "en": "enum Solo\nUnico\nendEnum\nenum Nada\nendEnum\nalgorithm P\nwrite Solo.Unico;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Unico\n",
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
    "es": "Enumerado A\nx, z\nFinEnumerado\nEnumerado B\nx\nFinEnumerado\nAlgoritmo P\nEscribir A.z, B.x;\nFinAlgoritmo\n",
    "en": "enum A\nx, z\nendEnum\nenum B\nx\nendEnum\nalgorithm P\nwrite A.z, B.x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "zx\n",
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
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nConstante F Como Color <- Color.Verde;\nAlgoritmo P\nEscribir F;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nconstant F as Color <- Color.Verde;\nalgorithm P\nwrite F;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Verde\n",
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
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nSubProceso otro(c Como Color) Como Color\nSi c = Color.Rojo Entonces\nRetornar Color.Verde;\nFinSi\nRetornar Color.Rojo;\nFinSubProceso\nAlgoritmo P\nEscribir otro(Color.Rojo), otro(Color.Verde);\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nsubroutine otro(c as Color) as Color\nif c = Color.Rojo then\nreturn Color.Verde;\nendIf\nreturn Color.Rojo;\nendSubroutine\nalgorithm P\nwrite otro(Color.Rojo), otro(Color.Verde);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "VerdeRojo\n",
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
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde, Azul\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nc <- Color.Verde;\nEscribir c = Color.Verde, c <> Color.Rojo, Color.Azul = Color.Rojo;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\ndefine c as Color;\nc <- Color.Verde;\nwrite c = Color.Verde, c <> Color.Rojo, Color.Azul = Color.Rojo;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}{{lexema:booleanTrue}}{{lexema:booleanFalse}}\n",
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
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde, Azul\nFinEnumerado\nAlgoritmo P\nEscribir Color.Rojo + 1;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\nwrite Color.Rojo + 1;\nendAlgorithm\n"
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
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde, Azul\nFinEnumerado\nAlgoritmo P\nEscribir Color.Rojo < Color.Verde;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\nwrite Color.Rojo < Color.Verde;\nendAlgorithm\n"
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
  "id": "C9",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde, Azul\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nEscribir c;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\ndefine c as Color;\nwrite c;\nendAlgorithm\n"
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
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde, Azul\nFinEnumerado\nAlgoritmo P\nDefinir n Como Entero;\nn <- Color.Rojo;\nEscribir n;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\ndefine n as integer;\nn <- Color.Rojo;\nwrite n;\nendAlgorithm\n"
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
    "es": "Enumerado Color\nRojo, Verde, Azul\nFinEnumerado\nAlgoritmo P\nEscribir Color.Negro;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\nwrite Color.Negro;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undefinedEnumMember",
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
  "id": "C12",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Rojo\nFinEnumerado\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Rojo\nendEnum\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateEnumMember",
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
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo\nFinEnumerado\nEnumerado Color\nVerde\nFinEnumerado\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "enum Color\nRojo\nendEnum\nenum Color\nVerde\nendEnum\nalgorithm P\nendAlgorithm\n"
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
