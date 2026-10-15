---
{
  "formato": "see/1",
  "id": "LANG.CLASS.COPY",
  "titulo": "Copia superficial",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Copia superficial.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CLASS.INSTANTIATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Copia superficial

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Copiar(objeto) crea una instancia nueva de la misma clase sin ejecutar constructor; copia valores primitivos y referencias de campos. El original y copia tienen identidades diferentes. Referencias a objetos anidados se comparten, incluidos ciclos. Un argumento no objeto se rechaza semánticamente.",
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
