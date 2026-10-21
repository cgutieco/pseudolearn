---
{
  "formato": "see/1",
  "id": "RT.FAULT.REPORTING",
  "titulo": "Informe de fallos del ejecutable",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "aot"
  ],
  "resumen": "Los fallos del programa nunca son señales ni pánicos y conservan código, posición y salida previa.",
  "depende_de": [
    {
      "id": "RT.ABI",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.EFFECT-ORDER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Executable fault reporting",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Informe de fallos del ejecutable

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ningún fallo semántico del lenguaje, ni de los límites de ENG.LIMITS, se manifiesta como una señal del sistema operativo ni como un pánico del lenguaje anfitrión: se detecta, se informa con su diagnóstico y el proceso termina de forma ordenada.",
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nx <- 0;\nEscribir 1 div x;\nFinAlgoritmo\n",
  "perfil_base": "es"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
  },
  "programa": "Algoritmo P\nDimension a[3] Como Entero;\na[4] <- 1;\nFinAlgoritmo\n",
  "perfil_base": "es"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "integerOverflow"
    }
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nx <- 9223372036854775807;\nEscribir x + 1;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El diagnóstico de un fallo conserva el mismo código, los mismos argumentos y la misma posición de origen que produce la ejecución observada del mismo programa.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "programas": "casos de ejecución del corpus que terminan en failed"
  },
  "propiedad": "El código, los argumentos y la posición del diagnóstico coinciden con los del sujeto engine.",
  "oraculo": "Diagnóstico del sujeto engine.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La salida que el programa produjo antes del fallo se conserva en la salida estándar, en el orden de ENG.EXEC.EFFECT-ORDER, antes de informar el fallo en la salida de error.",
  "verificacion": [
    "C4"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "failed",
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 1 div 0;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```
