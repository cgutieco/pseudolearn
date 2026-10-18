---
{
  "formato": "see/1",
  "id": "LANG.CLASS.DECLARATION",
  "titulo": "Declaración de clases",
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
  "resumen": "Declaración de clases.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.CLASS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Declaración de clases

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una clase con nombre y cierre contiene atributos, métodos y constructor; es hermana del algoritmo y subprogramas. No se admite anidamiento, subprograma dentro de clase ni clase dentro de unidad. El orden no restringe referencias a clases posteriores. La inicial mayúscula es estilo y no requisito. Nombre duplicado y ciclos son semánticos.",
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
    "es": "Clase C\nFinClase\nAlgoritmo P\nDefinir x Como C;\nx <- Nuevo C();\nFinAlgoritmo\n",
    "en": "class C\nendClass\nalgorithm P\ndefine x as C;\nx <- new C();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
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
    "es": "Algoritmo P\nClase C\nFinClase\nFinAlgoritmo\n",
    "en": "algorithm P\nclass C\nendClass\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "classInsideAlgorithm",
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
    "es": "Clase\nFinClase\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "class\nendClass\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedClassName",
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
