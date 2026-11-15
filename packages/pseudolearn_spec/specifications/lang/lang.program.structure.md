---
{
  "formato": "see/1",
  "id": "LANG.PROGRAM.STRUCTURE",
  "titulo": "Estructura del texto de programa",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "engine",
    "app"
  ],
  "resumen": "Estructura del texto de programa.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.PROFILE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Estructura del texto de programa

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un texto suelto de la edición 2027 contiene exactamente un algoritmo con nombre y cierre. Puede contener antes o después declaraciones hermanas de subprogramas, clases, interfaces, registros, enumerados y constantes de módulo, cada una con las restricciones de su contrato dueño. No hay unidades anidadas ni sentencias ejecutables al nivel superior. El algoritmo vacío es válido; texto vacío requiere diagnóstico de inicio y un árbol recuperable. El nombre del algoritmo no ocupa un espacio de variables.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Interfaz Readable\nMetodo readValue() Como Entero;\nFinInterfaz\nRegistro Point\nDefinir x Como Entero;\nFinRegistro\nEnumerado Color\nRed, Green\nFinEnumerado\nConstante Limit Como Entero <- 3;\nClase Reader Realiza Readable\nMetodo readValue() Como Entero\nRetornar Limit;\nFinMetodo\nFinClase\nSubProceso helper() Como Entero\nRetornar Limit;\nFinSubProceso\nAlgoritmo Main\nEscribir helper();\nFinAlgoritmo\n",
    "en": "interface Readable\nmethod readValue() as integer;\nendInterface\nrecord Point\ndefine x as integer;\nendRecord\nenum Color\nRed, Green\nendEnum\nconstant Limit as integer <- 3;\nclass Reader implements Readable\nmethod readValue() as integer\nreturn Limit;\nendMethod\nendClass\nsubroutine helper() as integer\nreturn Limit;\nendSubroutine\nalgorithm Main\nwrite helper();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  }
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
    "es": "SubProceso f()\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
    "en": "subroutine f()\nendSubroutine\nalgorithm P\nf();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Saludo\n  Escribir \"Hola\";\n  Escribir \"Adiós\";\nFinAlgoritmo\n",
    "en": "Algorithm Greeting\n  Write \"Hola\";\n  Write \"Adiós\";\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola\nAdiós\n",
    "terminacion": "completed"
  }
}
```
