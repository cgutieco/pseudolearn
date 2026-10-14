---
{
  "formato": "see/1",
  "id": "ENG.STATE.SNAPSHOT",
  "titulo": "Estado observable",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Máquina nocional de marcos, variables, arreglos y objetos.",
  "depende_de": [
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "MEM.IDENTITY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.IO.VALUE-FORMAT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Observable state"
}
---

# Estado observable

```definicion
{
  "id": "D1",
  "termino": "vista de estado",
  "texto": "Objeto con marcos y objetos. marcos lista los marcos activos del exterior al interior; cada uno tiene unidad (nombre del algoritmo, del subprograma o Clase.método), receptor para métodos y variables por nombre, incluidos los parámetros. Un valor es {valor: representación de LANG.IO.VALUE-FORMAT}, {sin_valor: true}, {ref: identidad} para arreglos y objetos o {alias: destino} para un parámetro por referencia, cuyo destino es {marco, variable}, {ref, indice} o {ref, campo}. objetos asocia cada identidad alcanzable desde los marcos con {clase, campos} o {arreglo: {dimensiones, celdas}}, celdas en orden por filas."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El estado en un evento es el de la máquina nocional inmediatamente después de producirse ese evento, con la forma de D1. Contiene todos los marcos activos y sus variables declaradas.",
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
    "salida": "3\n",
    "terminacion": "completed",
    "estado_en": {
      "evento": 3,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "x": {
                "valor": "3"
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
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una variable declarada y nunca asignada aparece con sin_valor; el estado nunca inventa un valor por defecto.",
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
  "texto": "Un arreglo aparece en objetos con sus dimensiones y todas sus celdas; una celda sin asignar aparece con sin_valor.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
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
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los objetos alcanzables forman un grafo identificado por MEM.IDENTITY; un ciclo aparece una sola vez como referencias entre identidades.",
  "verificacion": [
    "C4"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
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
      "evento": 5,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "n": {
                "ref": 1
              }
            }
          }
        ],
        "objetos": {
          "1": {
            "clase": "Nodo",
            "campos": {
              "siguiente": {
                "ref": 1
              }
            }
          }
        }
      }
    }
  },
  "programa": "Clase Nodo\nPublico Definir siguiente Como Nodo;\nFinClase\nAlgoritmo P\nDefinir n Como Nodo;\nn <- Nuevo Nodo();\nn.siguiente <- n;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un parámetro por referencia aparece como alias de su destino y no como copia de su valor.",
  "verificacion": [
    "C5"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R5",
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
      "evento": 6,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "x": {
                "valor": "1"
              }
            }
          },
          {
            "unidad": "inc",
            "variables": {
              "v": {
                "alias": {
                  "marco": 0,
                  "variable": "x"
                }
              }
            }
          }
        ],
        "objetos": {}
      }
    }
  },
  "programa": "SubProceso inc(v Como Entero Por Referencia)\nv <- v + 1;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Entero;\nx <- 1;\ninc(x);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El marco de un método muestra su receptor.",
  "verificacion": [
    "C6"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R6",
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
      "evento": 7,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "c": {
                "ref": 1
              }
            }
          },
          {
            "unidad": "C.poner",
            "variables": {
              "cantidad": {
                "valor": "4"
              }
            },
            "receptor": {
              "ref": 1
            }
          }
        ],
        "objetos": {
          "1": {
            "clase": "C",
            "campos": {
              "valor": {
                "valor": "4"
              }
            }
          }
        }
      }
    }
  },
  "programa": "Clase C\nPublico Definir valor Como Entero;\nMetodo poner(cantidad Como Entero)\nEste.valor <- cantidad;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como C;\nc <- Nuevo C();\nc.poner(4);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una vista de estado es inmutable: avanzar la ejecución no modifica una vista ya entregada.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R7",
  "generador": {
    "programas": "casos trace del corpus",
    "consultas": "cada evento"
  },
  "propiedad": "Una vista entregada en el evento k es igual antes y después de avanzar hasta el final.",
  "oraculo": "Copia profunda de la vista en el momento de entregarla.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```
