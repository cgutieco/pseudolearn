---
{
  "formato": "see/1",
  "id": "API.STATE.QUERY",
  "titulo": "Consulta de estado",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Consulta por referencia y por instante con horizonte declarado.",
  "depende_de": [
    {
      "id": "API.EXECUTE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.STATE.INCREMENTAL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "State query"
}
---

# Consulta de estado

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El estado se consulta por referencia: la lista de marcos, las variables de un marco, un objeto por identidad y un intervalo de celdas de un arreglo por desplazamiento y cantidad, sin materializar el estado completo.",
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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "estado_en": {
      "evento": 3,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "a": {
                "ref": 1
              }
            }
          }
        ],
        "objetos": {
          "1": {
            "arreglo": {
              "dimensiones": [
                2
              ],
              "celdas": [
                {
                  "valor": "5"
                },
                {
                  "sin_valor": true
                }
              ]
            }
          }
        }
      }
    }
  },
  "programa": "Algoritmo P\nDimension a[2] Como Entero;\na[0] <- 5;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda consulta indica el instante como índice de evento; con seek puede ser un evento pasado y sin seek solo el actual.",
  "verificacion": [
    "C2"
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
  "operacion": "trace",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed",
    "estado_en": {
      "evento": 1,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "x": {
                "sin_valor": true
              }
            }
          }
        ],
        "objetos": {}
      }
    }
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nx <- 3;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La ejecución declara su horizonte retenido: el primer evento consultable. Consultar un evento anterior al horizonte devuelve un error de uso, nunca un estado aproximado.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {
    "ejecuciones": "ejecuciones largas con presupuesto de retención pequeño"
  },
  "propiedad": "Toda consulta dentro del horizonte es exacta y fuera de él es un error de uso.",
  "oraculo": "Estado completo registrado.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```
