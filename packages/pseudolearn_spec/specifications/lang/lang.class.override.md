---
{
  "formato": "see/1",
  "id": "LANG.CLASS.OVERRIDE",
  "titulo": "Sobrescritura y despacho",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Sobrescritura y despacho.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.INHERITANCE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CLASS.METHODS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Sobrescritura y despacho

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un método homónimo de subclase sobrescribe sin marca si conserva número y tipos de parámetros, modos de paso y retorno. Firma diferente es incompatibleMethodOverride, no sobrecarga. Toda llamada ordinaria usa clase real del objeto; Super selecciona implementación de superclase. La existencia del miembro se comprueba contra tipo estático.",
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
    "es": "Clase A\nMetodo get() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nClase B Hereda De A\nMetodo get() Como Entero\nRetornar 2;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir x Como A;\nx <- Nuevo B();\nEscribir x.get();\nFinAlgoritmo\n",
    "en": "class A\nmethod get() as integer\nreturn 1;\nendMethod\nendClass\nclass B inherits from A\nmethod get() as integer\nreturn 2;\nendMethod\nendClass\nalgorithm P\ndefine x as A;\nx <- new B();\nwrite x.get();\nendAlgorithm\n"
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
    "es": "Clase A\nMetodo get() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nClase B Hereda De A\nMetodo get(value Como Entero) Como Entero\nRetornar value;\nFinMetodo\nFinClase\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "class A\nmethod get() as integer\nreturn 1;\nendMethod\nendClass\nclass B inherits from A\nmethod get(value as integer) as integer\nreturn value;\nendMethod\nendClass\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleMethodOverride",
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
