---
{
  "formato": "see/1",
  "id": "API.EXECUTE",
  "titulo": "Ejecución",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Iniciar, avanzar por lotes o hasta una condición, entregar entrada, cancelar y posicionarse.",
  "depende_de": [
    {
      "id": "API.ANALYZE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.STEP",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.INPUT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution"
}
---

# Ejecución

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Iniciar una ejecución recibe un análisis sin errores, semilla, límites y entradas iniciales; iniciar desde un análisis con errores devuelve un error de uso.",
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
    "salida": "42\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "21"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Avanzar entrega lotes de eventos de un tamaño máximo o avanza hasta una condición de ENG.TRACE.STEP; cada respuesta indica si la ejecución sigue, espera entrada o terminó.",
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
    "salida": "1\n2\n",
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
      },
      {
        "clase": "statement_entered",
        "linea": 3
      },
      {
        "clase": "output",
        "linea": 3,
        "datos": {
          "texto": "2\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 3
      }
    ]
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Entregar entrada reanuda una ejecución que espera; cancelar la termina en la siguiente entrada a sentencia o evaluación de condición o prueba de bucle con cancelled, sin efectos parciales del punto cancelado.",
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
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "cancelled"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 2
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Con la capacidad seek, la ejecución puede posicionarse en un evento pasado para consultar su estado; posicionarse no repite efectos externos ni cambia la continuación.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R4",
  "generador": {
    "programas": "casos trace del corpus",
    "posiciones": "cada evento"
  },
  "propiedad": "Posicionarse en k y continuar produce los mismos eventos posteriores que no haberse posicionado, sin repetir salida.",
  "oraculo": "Traza completa sin posicionamiento.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```
