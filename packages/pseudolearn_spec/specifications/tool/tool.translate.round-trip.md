---
{
  "formato": "see/1",
  "id": "TOOL.TRANSLATE.ROUND-TRIP",
  "titulo": "Traducción bilingüe de ida y vuelta",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Traductor de código entre perfiles es y en con preservación de nombres de usuario y detección de colisiones.",
  "depende_de": [
    {
      "id": "LANG.PROFILE.TRANSLATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.LOSSLESS-TREE",
      "version": ">=0.2.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.FORMAT.STYLE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Bilingual round-trip translation"
}
---

# Traducción bilingüe de ida y vuelta

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El traductor convierte todas las palabras clave, tipos primitivos, operadores verbales y llamadas a funciones estándar no sombreadas del perfil de origen al perfil de destino, conservando la modalidad.",
  "verificacion": [
    "C1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los nombres de usuario, literales y comentarios se conservan intactos; si una función estándar está sombreada por una declaración de usuario, esa ocurrencia no se traduce.",
  "verificacion": [
    "C2"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si un identificador de usuario coincide con una palabra reservada del perfil destino, el servicio reporta el diagnóstico reservedLexemeUsedAsName con la posición exacta y no emite traducción silenciosa con colisión.",
  "verificacion": [
    "C3"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Para todo programa en forma canónica libre de colisiones, la doble traducción origen hacia destino y de vuelta hacia origen devuelve un texto idéntico al original.",
  "verificacion": [
    "C1",
    "C4",
    "P1"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Algorithm Principal\n  Define x As Real;\n  x <- sqrt(4.0);\n  Write x;\nEndAlgorithm\n",
      "vuelta": "Algoritmo Principal\n  Definir x Como Real;\n  x <- rc(4.0);\n  Escribir x;\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "translate_roundtrip",
    "documento": "Algoritmo Principal\n  Definir x Como Real;\n  x <- rc(4.0);\n  Escribir x;\nFinAlgoritmo\n",
    "hacia": "en"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Algorithm Sombras\n  Define longitud As Integer;\n  longitud <- 5;\n  s <- uppercase(\"texto\");\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "translate",
    "documento": "Algoritmo Sombras\n  Definir longitud Como Entero;\n  longitud <- 5;\n  s <- mayusculas(\"texto\");\nFinAlgoritmo\n",
    "hacia": "en"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "colision": "reservedLexemeUsedAsName"
    }
  },
  "servicio": {
    "suboperacion": "translate",
    "documento": "Algorithm Colision\n  Define fin As Integer;\nEndAlgorithm\n",
    "hacia": "es"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Algorithm Alias\nEndAlgorithm\n",
      "vuelta": "Algoritmo Alias\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "translate_roundtrip",
    "documento": "Proceso Alias\nFinProceso\n",
    "hacia": "en"
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R4",
  "generador": {
    "programas": "programas válidos del corpus sin colisiones con el vocabulario del otro idioma"
  },
  "propiedad": "La doble traducción sobre la forma canónica es la identidad.",
  "oraculo": "Igualdad byte a byte entre el programa canónico de origen y la doble traducción.",
  "justificacion": "La ejecuta el sujeto service mediante comprobación de doble traducción."
}
```
