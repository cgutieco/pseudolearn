---
{
  "formato": "see/1",
  "id": "SEE.GENERATION",
  "titulo": "Exportación para consumidores",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Exportación para consumidores.",
  "depende_de": []
}
---

# Exportación para consumidores

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La exportación JSON contiene contratos, hashes e índices de áreas; --check rechaza una copia desactualizada.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
