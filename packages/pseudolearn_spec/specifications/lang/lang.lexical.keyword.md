---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.KEYWORD",
  "titulo": "Palabras reservadas",
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
  "resumen": "Palabras reservadas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Palabras reservadas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los lexemas de tokens del vocabulario oficial, incluidos alias, son reservados bajo las políticas del perfil. Español ignora caja y acentos del vocabulario; inglés ignora caja y conserva acentos. Y/O y and/or son operadores reservados. Las grafías de Importar y Exportar del perfil activo son contextuales únicamente en un texto suelto: en posición de unidad superior introducen sintaxis de módulo y producen moduleSyntaxOutsideProject, y dentro de un programa suelto pueden ser nombres. En un proyecto siguen siendo palabras reservadas. No hay otras palabras contextuales ni escape general de nombres en la edición vigente. Las funciones incorporadas no son reservadas. Un lexema reservado en una posición de nombre inequívoca produce reservedLexemeUsedAsName; en una expresión incompleta se informa el error de expresión.",
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
    "es": "Algoritmo P\nDefinir Mientras Como Entero <- 0;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine while as integer <- 0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "reservedLexemeUsedAsName",
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir sen Como Entero <- 4;\nEscribir sen;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine sen as integer <- 4;\nwrite sen;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Verdadero Y NO Falso;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite true and not false;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
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
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Importar Como Entero <- 1;\nDefinir Mutable Exportar Como Entero <- 0;\nExportar <- 2;\nEscribir Importar, Exportar;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine import as integer <- 1;\ndefine mutable export as integer <- 0;\nexport <- 2;\nwrite import, export;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  }
}
```
