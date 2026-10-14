---
{
  "formato": "see/1",
  "id": "SEE.FEATURE-MANIFEST",
  "titulo": "Manifiesto de característica",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Manifiesto de característica.",
  "depende_de": []
}
---

# Manifiesto de característica

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un manifiesto enlaza contratos existentes sin reglas ni versión propia; su estado se agrega desde las especificaciones.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
