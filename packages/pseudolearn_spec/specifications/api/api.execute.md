---
{
  "formato": "see/1",
  "id": "API.EXECUTE",
  "titulo": "Ejecución",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
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
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.STEP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.INPUT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
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
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n",
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

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API distingue tres modos de ejecución mutuamente excluyentes: LiveRecord (ejecuta contra el anfitrión y graba la cinta de efectos), ReplayFromTape (reproduce fielmente a partir de la cinta sin consultar al anfitrión) y HistorySeek (reconstruye estados pasados para inspección interactiva desconectado del anfitrión). En ReplayFromTape y HistorySeek el aislamiento externo es absoluto: ninguna llamada a disco, red ni reloj real es realizada.",
  "verificacion": [
    "C4"
  ]
}
```

```caso
{
  "id": "C4",
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
  "operacion": "execute",
  "espera": {
    "salida": "aislamiento_garantizado\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"aislamiento_garantizado\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API proyecta la terminación awaiting_effect con su efecto pendiente y proporciona la operación effect_result para reanudar la ejecución con el resultado entregado por el anfitrión. Enviar input cuando se espera effect_result o effect_result cuando se espera input produce un error de uso.",
  "verificacion": [
    "C5"
  ]
}
```

```caso
{
  "id": "C5",
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
  "operacion": "execute",
  "espera": {
    "salida": "efecto_resultado_ok\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"efecto_resultado_ok\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```
