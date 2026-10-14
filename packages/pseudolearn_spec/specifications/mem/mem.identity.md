---
{
  "formato": "see/1",
  "id": "MEM.IDENTITY",
  "titulo": "Identidad de objetos y arreglos",
  "dominio": "memoria",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Identidad por ordinal de asignación, aliasing y ciclos.",
  "depende_de": [
    {
      "id": "LANG.TYPES.CLASS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CLASS.INSTANTIATION",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Object and array identity"
}
---

# Identidad de objetos y arreglos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La identidad observable de un objeto o arreglo es su ordinal de asignación dentro de la ejecución: el primer arreglo u objeto creado por Dimension, Nuevo o Copiar tiene identidad 1 y cada creación posterior la siguiente.",
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
      "evento": 5,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "a": {
                "ref": 1
              },
              "b": {
                "ref": 2
              }
            }
          }
        ],
        "objetos": {
          "1": {
            "clase": "C",
            "campos": {
              "valor": {
                "sin_valor": true
              }
            }
          },
          "2": {
            "clase": "C",
            "campos": {
              "valor": {
                "sin_valor": true
              }
            }
          }
        }
      }
    }
  },
  "programa": "Clase C\nPublico Definir valor Como Entero;\nFinClase\nAlgoritmo P\nDefinir a, b Como C;\na <- Nuevo C();\nb <- Nuevo C();\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La identidad no depende de la recuperación de memoria: un objeto conserva su identidad durante toda la ejecución y una identidad nunca se reutiliza.",
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
    "programas": "programas generados que crean y abandonan objetos"
  },
  "propiedad": "Las identidades observadas son las mismas con recuperación forzada en cada asignación y sin ella.",
  "oraculo": "Numeración de creaciones en orden de programa.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dos nombres que comparten un objeto o arreglo observan la misma identidad: una escritura por un nombre es visible por el otro, y la igualdad de objetos compara identidad.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
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
    "salida": "5{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "programa": "Clase C\nPublico Definir valor Como Entero;\nFinClase\nAlgoritmo P\nDefinir a, b Como C;\na <- Nuevo C();\nb <- a;\nb.valor <- 5;\nEscribir a.valor, a = b;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los ciclos de referencias son válidos y no impiden la ejecución, la igualdad ni la consulta de estado.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
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
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "programa": "Clase Nodo\nPublico Definir siguiente Como Nodo;\nFinClase\nAlgoritmo P\nDefinir n Como Nodo;\nn <- Nuevo Nodo();\nn.siguiente <- n;\nEscribir n.siguiente.siguiente = n;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```
