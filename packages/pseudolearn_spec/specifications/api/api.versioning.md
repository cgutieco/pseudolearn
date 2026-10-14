---
{
  "formato": "see/1",
  "id": "API.VERSIONING",
  "titulo": "Versión y capacidades de la API",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Versión, ediciones soportadas y negociación de capacidades.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.EDITION.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "API versioning"
}
---

# Versión y capacidades de la API

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API declara una versión semántica, las ediciones del lenguaje que admite (la vigente es 2026) y sus capacidades: analyze, execute, observe, seek e interface_language.",
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
    "sesiones": "sesiones nuevas"
  },
  "propiedad": "La declaración incluye versión, ediciones y capacidades.",
  "oraculo": "Esquema de API.WIRE-FORMAT.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un consumidor negocia las capacidades que usará; pedir una capacidad o una edición no declarada devuelve un error de versión y no cambia el estado de la sesión. seek permite consultar el estado en un evento pasado.",
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
    "peticiones": "capacidades y ediciones declaradas y no declaradas"
  },
  "propiedad": "Las no declaradas producen error de versión sin efectos.",
  "oraculo": "Lista declarada.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```
