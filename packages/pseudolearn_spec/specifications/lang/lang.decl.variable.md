---
{
  "formato": "see/1",
  "id": "LANG.DECL.VARIABLE",
  "titulo": "Declaración de variables",
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
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Declaración de variables.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Declaración de variables

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Definir nombre Como tipo <- expresión declara un vínculo local individual, inmutable y con inicializador obligatorio en ambos rigores. Definir Mutable permite reasignarlo. La inicialización comprueba el tipo y no permite leer el vínculo que declara. Los campos, parámetros y arreglos conservan sus contratos específicos; las declaraciones locales no crean ámbitos de bloque. Un nombre de un carácter es válido y duplicar el nombre es error. Reasignar un vínculo inmutable, usarlo como destino de Leer o pasarlo por referencia para modificarlo es immutableBindingAssignment. La mutación de un objeto no reasigna su vínculo; escribir un campo de registro por valor sí modifica el vínculo. Un mutable sin modificación recibe mutableBindingNeverModified.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8"
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
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nDefinir value Como Entero <- 2;\nEscribir x, value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\ndefine value as integer <- 2;\nwrite x, value;\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedIdentifierInDeclaration",
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
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
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nx <- 2;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\nx <- 2;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "immutableBindingAssignment",
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
    "es": "Algoritmo P\nDefinir Mutable x Como Entero <- 1;\nx <- 2;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable x as integer <- 1;\nx <- 2;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
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
    "es": "Algoritmo P\nDefinir x Como Entero <- x;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- x;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingReadsOwnInitializer",
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
    "es": "Algoritmo P\nDefinir Mutable x Como Entero <- 1;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable x as integer <- 1;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "mutableBindingNeverModified",
        "severidad": "warning"
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
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\nread x;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "immutableBindingAssignment",
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
