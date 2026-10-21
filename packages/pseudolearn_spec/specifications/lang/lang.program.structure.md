---
{
  "formato": "see/1",
  "id": "LANG.PROGRAM.STRUCTURE",
  "titulo": "Estructura del texto de programa",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "app"
  ],
  "resumen": "Estructura del texto de programa.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROFILE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "cambio": {
    "clase": "verificacion_anadida",
    "impacto_usuarios": "Se conserva la versión numérica por autorización y no se añaden construcciones.",
    "impacto_implementaciones": "Sujetos retirados, alcance de casos y verificaciones de contratos existentes explícitos.",
    "justificacion": "Migración autorizada; la evidencia histórica, AOT y de plataforma conserva sus límites.",
    "revisado_por": "revision-independiente-automatizada"
  }
}
---

# Estructura del texto de programa

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un texto contiene exactamente un algoritmo con nombre y cierre, y cero o más subprogramas y clases hermanos antes o después. No hay unidades anidadas ni sentencias ejecutables al nivel superior. El algoritmo vacío es válido; texto vacío requiere diagnóstico de inicio y un árbol recuperable. El nombre del algoritmo no ocupa un espacio de variables.",
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
  "programas": {
    "es": "Algoritmo P\n\nFinAlgoritmo\n",
    "en": "algorithm P\n\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo\nFinAlgoritmo\n",
    "en": "algorithm\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedAlgorithmName",
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
    "es": "Algoritmo P\n\nFinAlgoritmo\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "algorithm P\n\nendAlgorithm\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "multipleAlgorithms",
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
    "es": "SubProceso f()\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
    "en": "subroutine f()\nendSubroutine\nalgorithm P\nf();\nendAlgorithm\n"
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
