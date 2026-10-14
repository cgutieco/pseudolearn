---
{
  "formato": "see/1",
  "id": "ENG.EXEC.EFFECT-ORDER",
  "titulo": "Orden de los efectos",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Orden normativo de los efectos observables y primera trampa.",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.STMT.ASSIGNMENT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Effect order"
}
---

# Orden de los efectos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los efectos observables son la salida, la petición y el consumo de entrada, el fallo, la terminación y, cuando se observa, los eventos de traza. Ocurren en el orden de programa que fijan las reglas de evaluación del lenguaje. Ningún otro cálculo es observable salvo a través de ellos.",
  "verificacion": [
    "C1"
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
    "salida": "1\n2\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso f(n Como Entero) Como Entero\nEscribir n;\nRetornar n;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Entero;\nx <- f(1) + f(2);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si varias operaciones pueden fallar, se informa la primera trampa en orden de evaluación normativo, con el tramo de su operación, y ningún efecto posterior es visible. Una sentencia que falla no produce efectos parciales: Escribir evalúa todas sus expresiones antes de producir salida.",
  "verificacion": [
    "C2",
    "C3"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
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
    "salida": "1\n",
    "fallo": {
      "codigo": "divisionByZero"
    },
    "diagnosticos": [
      {
        "codigo": "divisionByZero",
        "severidad": "error",
        "tramo": {
          "start": {
            "line": 5,
            "column": 9
          },
          "end": {
            "line": 5,
            "column": 12
          }
        }
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir x, z Como Entero;\nx <- 0;\nEscribir 1;\nz <- (1 div x) + (2 ^ (0 - 1));\nEscribir z;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
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
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nx <- 0;\nEscribir \"a\", 1 div x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El orden de evaluación de subexpresiones sin efectos no es observable. Una implementación puede reordenarlas, combinarlas o comprobar sus trampas al final de una región sin efectos solo si la salida, los eventos y la primera trampa con su tramo coinciden con la evaluación normativa.",
  "verificacion": [
    "C4",
    "P1"
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
    "salida": "",
    "fallo": {
      "codigo": "integerOverflow"
    }
  },
  "programa": "Algoritmo P\nDefinir a, b Como Entero;\na <- 9223372036854775807;\nb <- 0;\nb <- (a + 1) * (b div b);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {
    "programas": "expresiones aritméticas generadas sin efectos con operandos en los bordes de 64 bits"
  },
  "propiedad": "Evaluar con comprobación por operación o con comprobación diferida al final de la región produce la misma primera trampa y tramo.",
  "oraculo": "Evaluación normativa de izquierda a derecha con aritmética de precisión arbitraria.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```
