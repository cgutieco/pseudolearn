---
{
  "formato": "see/1",
  "id": "API.ERRORS",
  "titulo": "Errores de la API",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Todo resultado es un valor; ningún pánico cruza la frontera.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.ENGINE.INTERNAL-FAULT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "API errors"
}
---

# Errores de la API

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda operación devuelve un valor: un resultado o un error de una familia. Las familias son uso (identificador desconocido, recurso liberado, operación inválida en el estado del recurso), versión (capacidad o edición no soportada) y fallo interno.",
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
    "operaciones": "todas las operaciones con argumentos válidos e inválidos"
  },
  "propiedad": "Cada operación devuelve un resultado o un error de una de las tres familias.",
  "oraculo": "Clasificación por familia de los argumentos generados.",
  "justificacion": "La ejecuta el sujeto engine en R4 y R5."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ningún pánico, excepción ni aborto cruza la frontera de la API. Un defecto interno se convierte en el fallo interno de DIAG.ENGINE.INTERNAL-FAULT, que es la última barrera y nunca aparece con programas del corpus.",
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
    "inyeccion": "fallos inyectados en cada etapa interna"
  },
  "propiedad": "Cada fallo inyectado produce el fallo interno sin terminar el proceso anfitrión.",
  "oraculo": "Observación del proceso anfitrión.",
  "justificacion": "La ejecuta el sujeto engine en R4 y R5."
}
```
