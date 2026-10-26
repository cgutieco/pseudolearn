---
{
  "formato": "see/1",
  "id": "ENG.TRACE.STEP",
  "titulo": "Paso observable",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Paso, lotes de eventos y avance hasta una condición.",
  "depende_de": [
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Observable step",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Paso observable

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un paso observable es el intervalo entre dos eventos consecutivos de la traza. Avanzar un paso entrega exactamente el evento siguiente; no existe una unidad pública menor.",
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
    "salida": "1\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "output",
        "linea": 2,
        "datos": {
          "texto": "1\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "programa": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los eventos se entregan por lotes de tamaño elegido por el anfitrión. La concatenación de los lotes es la traza completa, en orden, sin pérdidas ni duplicados, para cualquier partición.",
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
    "programas": "casos trace del corpus",
    "lotes": "tamaños 1, 2, 7 y 4096"
  },
  "propiedad": "La concatenación de los lotes es igual a la traza entregada evento a evento.",
  "oraculo": "Traza de referencia obtenida con lotes de un evento.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Avanzar hasta una condición se define sobre eventos: siguiente sentencia avanza hasta el próximo statement_entered del mismo marco o de uno exterior; entrar avanza hasta el próximo statement_entered; salir avanza hasta el return que cierra el marco actual; hasta línea avanza hasta un statement_entered con esa línea. Si la condición no se cumple, la ejecución avanza hasta su terminación.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R3",
  "generador": {
    "programas": "casos trace del corpus",
    "condiciones": "las cuatro condiciones en cada evento"
  },
  "propiedad": "El evento en que se detiene cada condición es el primero de la traza que la satisface.",
  "oraculo": "Búsqueda lineal sobre la traza completa.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "No hay un tope de pasos: la longitud de una ejecución solo la limitan los límites de ENG.LIMITS configurados por el anfitrión.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
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
    "salida": "20000100000\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\nDefinir Mutable total Como Entero <- 0;\ntotal <- 0;\nPara i <- 1 Hasta 200000 Con Paso 1 Hacer\ntotal <- total + i;\nFinPara\nEscribir total;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```
