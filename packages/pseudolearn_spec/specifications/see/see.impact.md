---
{
  "formato": "see/1",
  "id": "SEE.IMPACT",
  "titulo": "Impacto transitivo",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Impacto transitivo.",
  "depende_de": []
}
---

# Impacto transitivo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Impacto incluye la especificación consultada y todos sus dependientes transitivos, sin duplicados; un identificador desconocido es error.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
