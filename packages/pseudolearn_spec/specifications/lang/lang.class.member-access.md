---
{
  "formato": "see/1",
  "id": "LANG.CLASS.MEMBER-ACCESS",
  "titulo": "Acceso a miembros",
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
  "resumen": "Acceso a miembros.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.FIELDS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CLASS.METHODS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Acceso a miembros

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El punto permite acceso encadenado sobre expresiones. Un atributo es designador; una llamada a método no. Se resuelve contra el tipo estático cuando se conoce y se respeta visibilidad. Miembro inexistente es semántico con tipo conocido o fallo de ejecución con tipo desconocido. Un receptor se evalúa una vez.",
  "verificacion": [
    "C1",
    "C2"
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo C(2).get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\nwrite new C(2).get();\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo C(2).missing();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\nwrite new C(2).missing();\nendAlgorithm\n"
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
