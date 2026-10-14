---
{
  "formato": "see/1",
  "id": "SEE.LOCK",
  "titulo": "Anclaje de especificaciones",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Anclaje de especificaciones.",
  "depende_de": []
}
---

# Anclaje de especificaciones

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Lock conserva versión exacta y hash canónico por especificación e historial de identidades; --check rechaza anclajes desactualizados.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
