---
{
  "formato": "see/1",
  "id": "LANG.CLASS.SELF-AND-SUPER",
  "titulo": "Objeto actual y superclase",
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
  "resumen": "Objeto actual y superclase.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.METHODS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Objeto actual y superclase

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Este.<miembro> es obligatorio dentro de métodos y constructor para miembros del objeto actual. Un nombre suelto solo refiere local o parámetro. Super solo se usa dentro de subclase y seguido de llamada a método o constructor; usa implementación de superclase sobre el mismo objeto. Este o Super fuera de método y Super sin superclase son sintácticos.",
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
    "es": "Clase C\nPrivado Definir value Como Entero;\nMetodo Constructor(value Como Entero)\nEste.value <- value;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nEscribir Nuevo C(5).get();\nFinAlgoritmo\n",
    "en": "class C\nprivate define value as integer;\nmethod constructor(value as integer)\nthis.value <- value;\nendMethod\nmethod get() as integer\nreturn this.value;\nendMethod\nendClass\nalgorithm P\nwrite new C(5).get();\nendAlgorithm\n"
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
    "es": "Algoritmo P\nEscribir Este.value;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite this.value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "thisOutsideMethod",
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
    "es": "Algoritmo P\nSuper.f();\nFinAlgoritmo\n",
    "en": "algorithm P\nsuper.f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "superOutsideMethod",
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
