---
{
  "formato": "see/1",
  "id": "ENG.STATE.INCREMENTAL",
  "titulo": "Estado incremental",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Cambios de estado por evento y consulta de eventos pasados.",
  "depende_de": [
    {
      "id": "ENG.STATE.SNAPSHOT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Incremental state",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Estado incremental

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada evento puede llevar el cambio de estado respecto del evento anterior: variables escritas, celdas y campos modificados, objetos creados y marcos apilados o retirados.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "casos trace del corpus"
  },
  "propiedad": "Cada cambio menciona solo elementos cuyo valor difiere entre los estados consecutivos.",
  "oraculo": "Diferencia calculada entre las vistas completas de ENG.STATE.SNAPSHOT.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El estado reconstruido acumulando los cambios desde el inicio es igual al estado completo en todo evento.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "programas": "casos trace del corpus y programas generados con arreglos, objetos y llamadas"
  },
  "propiedad": "Para todo evento k, aplicar los cambios 0..k al estado inicial produce la vista completa del evento k.",
  "oraculo": "Vista completa de ENG.STATE.SNAPSHOT.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Consultar el estado de un evento pasado, una vez avanzada la ejecución, da el mismo resultado que haberlo consultado en su momento.",
  "verificacion": [
    "C1",
    "P3"
  ]
}
```

```caso
{
  "id": "C1",
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
            "variables": {}
          }
        ],
        "objetos": {
          "1": {
            "arreglo": {
              "dimensiones": [
                1
              ],
              "celdas": [
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
  "programa": "Algoritmo P\nDimension a[1] Como Entero;\na[0] <- 3;\nEscribir a[0];\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```propiedad
{
  "id": "P3",
  "regla": "R3",
  "generador": {
    "programas": "casos trace del corpus",
    "consultas": "cada evento después de terminar"
  },
  "propiedad": "La vista consultada al final para el evento k es igual a la vista entregada en el evento k.",
  "oraculo": "Vistas registradas durante la ejecución observada.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```
