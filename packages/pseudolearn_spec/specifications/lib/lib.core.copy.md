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
    "engine",
    "aot"
  ],
  "resumen": "Función de copia superficial.",
  "edicion": {
    "introducida_en": "2027"
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
    "César Antonio Gutiérrez Contreras"
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
    "es": "Clase C\nPublico Definir value Como Entero;\nFinClase\nAlgoritmo P\nDefinir x Como C <- Nuevo C();\nx.value <- 4;\nDefinir other Como C <- Copiar(x);\nother.value <- 8;\nEscribir x.value, other.value, x = other;\nFinAlgoritmo\n",
    "en": "class C\npublic define value as integer;\nendClass\nalgorithm P\ndefine x as C <- new C();\nx.value <- 4;\ndefine other as C <- copy(x);\nother.value <- 8;\nwrite x.value, other.value, x = other;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "48{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\n  Escribir Copiar(1);\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write copy(1);\nEndAlgorithm\n"
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
  }
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
    "es": "Clase Punto\n  Publico Definir x Como Entero;\nFinClase\n\nAlgoritmo CopiarPunto\n  Definir original Como Punto <- Nuevo Punto();\n  original.x <- 5;\n  Definir copia Como Punto <- Copiar(original);\n  copia.x <- 9;\n  Escribir original.x;\n  Escribir copia.x;\nFinAlgoritmo\n",
    "en": "Class Point\n  Public Define x As Integer;\nEndClass\n\nAlgorithm CopyPoint\n  Define original As Point <- New Point();\n  original.x <- 5;\n  Define duplicate As Point <- copy(original);\n  duplicate.x <- 9;\n  Write original.x;\n  Write duplicate.x;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n9\n",
    "terminacion": "completed"
  }
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
    "es": "Clase Punto\n  Publico Definir x Como Entero;\nFinClase\n\nAlgoritmo CopiarOCompartir\n  Definir original Como Punto <- Nuevo Punto();\n  original.x <- 5;\n  Definir mismo Como Punto <- original;\n  Definir copia Como Punto <- Copiar(original);\n  mismo.x <- 7;\n  copia.x <- 9;\n  Escribir original.x;\n  Escribir copia.x;\nFinAlgoritmo\n",
    "en": "Class Point\n  Public Define x As Integer;\nEndClass\n\nAlgorithm CopyOrShare\n  Define original As Point <- New Point();\n  original.x <- 5;\n  Define same As Point <- original;\n  Define duplicate As Point <- copy(original);\n  same.x <- 7;\n  duplicate.x <- 9;\n  Write original.x;\n  Write duplicate.x;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n9\n",
    "terminacion": "completed"
  }
}
```
