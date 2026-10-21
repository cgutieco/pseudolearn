---
{
  "formato": "see/1",
  "id": "LIB.CORE.COPY",
  "titulo": "Función de copia superficial",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Función de copia superficial.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CLASS.COPY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Función de copia superficial

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Copiar acepta una referencia de objeto y devuelve referencia a una nueva instancia de la misma clase. Conserva campos sin inicializar, copia valores primitivos y comparte referencias anidadas, sin ejecutar constructor. El resultado conserva tipo del argumento. Argumentos no objeto producen incompatibleArgumentType.",
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
    "es": "Clase C\nPublico Definir value Como Entero;\nFinClase\nAlgoritmo P\nDefinir x, other Como C;\nx <- Nuevo C();\nx.value <- 4;\nother <- Copiar(x);\nother.value <- 8;\nEscribir x.value, other.value, x = other;\nFinAlgoritmo\n",
    "en": "class C\npublic define value as integer;\nendClass\nalgorithm P\ndefine x, other as C;\nx <- new C();\nx.value <- 4;\nother <- copy(x);\nother.value <- 8;\nwrite x.value, other.value, x = other;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "48{{lexema:booleanFalse}}\n",
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
    "es": "Algoritmo P\nEscribir Copiar(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite copy(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
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
