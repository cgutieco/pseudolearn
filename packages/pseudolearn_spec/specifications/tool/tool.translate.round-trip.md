---
{
  "formato": "see/1",
  "id": "TOOL.TRANSLATE.ROUND-TRIP",
  "titulo": "Traducción bilingüe de ida y vuelta",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
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
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.LOSSLESS-TREE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.FORMAT.STYLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Bilingual round-trip translation",
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ]
}
---

# Traducción bilingüe de ida y vuelta

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El traductor convierte todas las palabras clave, tipos primitivos, operadores verbales y llamadas a funciones estándar no sombreadas del perfil de origen al perfil de destino, conservando la modalidad. Cada palabra clave conserva su identidad: Funcion se traduce a Function y no a Subroutine. También convierte las palabras contextuales en su posición propia, incluidas las llamadas de construcción de colección, como Vector() o Diccionario(), también dentro de los argumentos de otra llamada y aunque el análisis semántico rechace el programa, como Suspendible tras SubProceso y Recibir y Desde en una rama de Elegir, y las escribe con la misma grafía que el formateador.",
  "verificacion": [
    "C1",
    "C5",
    "C6",
    "C7",
    "C8"
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
  "origen": "derivado",
  "revisado_por": "César Antonio Gutiérrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Algorithm Principal\n  Define x As Real <- 0.0;\n  x <- sqrt(4.0);\n  Write x;\nEndAlgorithm\n",
      "vuelta": "Algoritmo Principal\n  Definir x Como Real <- 0.0;\n  x <- rc(4.0);\n  Escribir x;\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "translate_roundtrip",
    "documento": "Algoritmo Principal\n  Definir x Como Real <- 0.0;\n  x <- rc(4.0);\n  Escribir x;\nFinAlgoritmo\n",
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
  "origen": "derivado",
  "revisado_por": "César Antonio Gutiérrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Algorithm Sombras\n  Define rc As Real <- 0.0;\n  rc <- 5.0;\n  Define total As Integer <- 0;\n  total <- round(rc);\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "translate",
    "documento": "Algoritmo Sombras\n  Definir rc Como Real <- 0.0;\n  rc <- 5.0;\n  Definir total Como Entero <- 0;\n  total <- redon(rc);\nFinAlgoritmo\n",
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
  "origen": "derivado",
  "revisado_por": "César Antonio Gutiérrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "colision": "reservedLexemeUsedAsName"
    }
  },
  "servicio": {
    "suboperacion": "translate",
    "documento": "Algorithm Colision\n  Define fin As Integer <- 0;\nEndAlgorithm\n",
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

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "revisado_por": "César Antonio Gutiérrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Subroutine Suspendable Tomar(c As Channel<Integer>)\n  Select\n    Receive x From c:\n      Write x;\n    Receive z From c:\n      Write z;\n  EndSelect\nEndSubroutine\n\nAlgorithm P\n  Define base As Vector<Integer> <- vector();\n  Define datos As Immutable<Vector<Integer>> <- snapshot(base);\n  For Each d In datos Do\n    Write d;\n  EndFor\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "translate",
    "documento": "SubProceso Suspendible Tomar(c Como Canal<Entero>)\n  Elegir\n    Recibir x Desde c:\n      Escribir x;\n    Recibir z Desde c:\n      Escribir z;\n  FinElegir\nFinSubProceso\n\nAlgoritmo P\n  Definir base Como Vector<Entero> <- Vector();\n  Definir datos Como Inmutable<Vector<Entero>> <- Instantanea(base);\n  Para Cada d En datos Hacer\n    Escribir d;\n  FinPara\nFinAlgoritmo\n",
    "hacia": "en"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Function r <- Doble(a As Integer)\n  Define r As Integer;\n  r <- a * 2;\nEndFunction\n\nAlgorithm P\n  Write Doble(4);\nEndAlgorithm\n",
      "vuelta": "Funcion r <- Doble(a Como Entero)\n  Definir r Como Entero;\n  r <- a * 2;\nFinFuncion\n\nAlgoritmo P\n  Escribir Doble(4);\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "translate_roundtrip",
    "documento": "Funcion r <- Doble(a Como Entero)\n  Definir r Como Entero;\n  r <- a * 2;\nFinFuncion\n\nAlgoritmo P\n  Escribir Doble(4);\nFinAlgoritmo\n",
    "hacia": "en"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Algorithm P\n  Define d As Dictionary<Real, Integer> <- dictionary();\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "translate",
    "documento": "Algoritmo P\n  Definir d Como Diccionario<Real, Entero> <- Diccionario();\nFinAlgoritmo\n",
    "hacia": "en"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "traducido": "Algorithm P\n  Define v As Immutable<Vector<Integer>> <- snapshot(vector());\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "translate",
    "documento": "Algoritmo P\n  Definir v Como Inmutable<Vector<Entero>> <- Instantanea(Vector());\nFinAlgoritmo\n",
    "hacia": "en"
  }
}
```
