---
{
  "formato": "see/1",
  "id": "LANG.CLASS.INSTANTIATION",
  "titulo": "Instanciación explícita",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "0.2.0",
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
  "resumen": "Instanciación explícita.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.CONSTRUCTOR",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Instanciación explícita

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Nuevo seguido de nombre de clase y paréntesis es expresión primaria. No se crea objeto al declarar una variable. Constructor recibe argumentos según su firma. No hay nulo escribible. Acceder a una referencia no instanciada falla en ejecución. Se admite acceso encadenado sobre el resultado de Nuevo.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo C(9).get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\nwrite new C(9).get();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir x Como C;\nx <- Nuevo C;\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine x as C;\nx <- new C;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "missingInstantiationParentheses",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir x Como C;\nx <- Nuevo C(1);\nEscribir x = x;\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine x as C;\nx <- new C(1);\nwrite x = x;\nendAlgorithm\n"
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
