---
{
  "formato": "see/1",
  "id": "ENG.EXEC.MODEL",
  "titulo": "Modelo de ejecución",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Ejecución determinista y sus cinco terminaciones.",
  "depende_de": [
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.IO.INPUT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution model",
  "cambio": {
    "clase": "aclaracion",
    "impacto_usuarios": "Precisa redondeo, formato o recursos sin añadir construcciones.",
    "impacto_implementaciones": "Actualiza contratos y casos derivados para ejecución portable y verificable.",
    "justificacion": "Eliminar ambigüedades antes de implementar la ejecución determinista.",
    "revisado_por": "autorización de la fase R5 en la conversación"
  }
}
---

# Modelo de ejecución

```definicion
{
  "id": "D1",
  "termino": "terminaciones",
  "texto": "completed: el algoritmo principal alcanzó su cierre. failed: un diagnóstico de ejecución detuvo el programa. awaiting_input: Leer necesita un valor que el anfitrión no entregó. cancelled: el anfitrión canceló la ejecución. limit_reached: se agotó un presupuesto del anfitrión."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda ejecución de un programa sin errores de análisis se encuentra en exactamente una de las terminaciones de D1. awaiting_input es una suspensión reanudable; completed, failed, cancelled y limit_reached son finales y no producen efectos posteriores.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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
    "salida": "1\n2\n3\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
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
    "terminacion": "awaiting_input"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C4",
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
    "terminacion": "limit_reached",
    "limite": "sentencias"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "sentencias": 2
  }
}
```

```caso
{
  "id": "C5",
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
    "terminacion": "cancelled"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 3
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La ejecución es determinista: el mismo programa, perfil, rigor, semilla, configuración de límites y secuencia de entradas producen la misma salida, terminación, diagnósticos y traza en cualquier plataforma.",
  "verificacion": [
    "C6",
    "P1"
  ]
}
```

```caso
{
  "id": "C6",
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

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "programas": "todos los casos execute y trace del corpus",
    "repeticiones": 2
  },
  "propiedad": "Dos ejecuciones con la misma configuración producen observaciones idénticas.",
  "oraculo": "Comparación exacta de salida, terminación, diagnósticos y eventos entre ejecuciones.",
  "justificacion": "El ejecutor de propiedades corresponde al sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cancelación surte efecto en la siguiente entrada a sentencia o evaluación de condición o prueba de bucle. El punto cancelado no produce efectos parciales; se conservan los efectos anteriores y la terminación es cancelled sin diagnóstico. Una cancelación posterior al final no altera una ejecución terminada.",
  "verificacion": [
    "C7",
    "C8",
    "C9"
  ]
}
```

```caso
{
  "id": "C7",
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
    "terminacion": "cancelled"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 1
}
```

```caso
{
  "id": "C8",
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
    "salida": "1\n2\n3\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 10
}
```

## Cancelación en los casos

El campo cancelacion de un caso indica la entrada a sentencia, contada desde uno, en la que surte efecto la cancelación que pide el anfitrión.

```caso
{
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
  "programas": {
    "es": "Algoritmo P\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n",
    "en": "algorithm P\nwhile true do\nendWhile\nendAlgorithm\n"
  },
  "espera": {
    "salida": "",
    "terminacion": "cancelled"
  },
  "cancelacion_prueba": 2,
  "id": "C9"
}
```
