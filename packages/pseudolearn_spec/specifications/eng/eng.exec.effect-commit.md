---
{
  "formato": "see/1",
  "id": "ENG.EXEC.EFFECT-COMMIT",
  "titulo": "Confirmación lógica de efectos y estado externo incierto",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Fases de solicitud y confirmación de efectos, orden estricto de effect_seq y estado incierto.",
  "titulo_en": "Effect logical commit and uncertain external state",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.EFFECT-ORDER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Confirmación lógica de efectos y estado externo incierto

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda operación de efecto atraviesa exactamente dos fases en el modelo de ejecución: Requested (cuando todos los argumentos han sido evaluados y se emite la petición asignando el siguiente effect_seq monotónico) y Resolved (cuando el anfitrión o proveedor entrega el resultado). Ningún efecto asigna effect_seq antes de completar la evaluación de sus propios argumentos de izquierda a derecha.",
  "verificacion": [
    "C1",
    "C2",
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
    "salida": "10\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir 10;\nFinAlgoritmo\n",
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
    "salida": "A\nB\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"A\";\nEscribir \"B\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La fase Resolved produce exactamente uno de tres resultados de confirmación: Committed (completado con éxito en el anfitrión), Failed (rechazado o fallido de forma determinista antes de mutar estado externo) o Uncertain (resultado incierto tras cruzar al anfitrión en operaciones con potencial de mutación).",
  "verificacion": [
    "C3",
    "C4"
  ]
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
    "salida": "error_controlado\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"error_controlado\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C4",
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
    "salida": "incierto\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"incierto\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las operaciones de solo lectura jamás producen Uncertain: ante fallo externo se resuelven siempre como Failed. El resultado Uncertain marca de inmediato el estado de reproducibilidad de la cinta como UncertainExternalState, impidiendo su reproducción determinista autónoma.",
  "verificacion": [
    "C4"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando una expresión combina múltiples operaciones de efecto en secuencia, cada efecto solicita y resuelve su entrada antes de que el siguiente comience a evaluar sus argumentos. Los identificadores effect_seq resultantes son contiguos y respetan estrictamente el orden de evaluación.",
  "verificacion": [
    "C5"
  ]
}
```

```caso
{
  "id": "C5",
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
    "salida": "1\n2\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso paso(n Como Entero) Como Entero\nEscribir n;\nRetornar n;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable total Como Entero <- 0;\ntotal <- paso(1) + paso(2);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```
