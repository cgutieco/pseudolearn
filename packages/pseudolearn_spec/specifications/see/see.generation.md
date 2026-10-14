---
{
  "formato": "see/1",
  "id": "SEE.GENERATION",
  "titulo": "Exportación para consumidores",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Exportación para consumidores.",
  "depende_de": [],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Se explicitan contratos existentes y casos límite sin añadir construcciones.",
    "impacto_implementaciones": "Los consumidores comprueban las reglas ampliadas; reference permanece congelado.",
    "justificacion": "Migración completa del lenguaje vigente y de sus recursos normativos.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
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

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "La exportación incluye recursos normativos de vocabulario, funciones, diagnósticos y gramática. El vocabulario consumidor, incluidos alias y función por identidad, se deriva del corpus; --check rechaza cualquier artefacto desactualizado.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas felices e infelices en las capas responsables y verificación local completa."
}
```
