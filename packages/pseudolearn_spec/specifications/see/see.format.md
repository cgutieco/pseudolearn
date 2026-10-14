---
formato: see/1
id: SEE.FORMAT
titulo: Formato de especificaciones
dominio: proceso
estado: borrador
version: 0.2.0
duenos: [responsable-especificaciones]
sujetos: [see]
resumen: Formato de especificaciones.
cambio: {"clase": "ampliacion", "impacto_usuarios": "Se explicitan contratos existentes y casos límite sin añadir construcciones.", "impacto_implementaciones": "Los consumidores comprueban las reglas ampliadas; reference permanece congelado.", "justificacion": "Migración completa del lenguaje vigente y de sus recursos normativos.", "revisado_por": "autoría automatizada; no revisión humana independiente"}
---

# Formato de especificaciones

```regla
id: R1
fuerza: DEBE
clase: sistema
texto: El formato see/1 contiene metadatos YAML completos y bloques tipados regla, caso, definicion, error, propiedad, invariante, precondicion y resultado; rechaza campos desconocidos.
verificacion: [revision_humana]
justificacion: Revisión estructural manual de arranque contra el plan aprobado; no constituye aprobación independiente para estabilidad.
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Las definiciones admiten valor como objeto normativo; los casos admiten semilla opcional de entero con signo de 64 bits, transmitida a seed sin alterar el valor; ausente usa 42. diagnosticos compara multiconjuntos y diagnosticos_ordenados exige el orden exacto sin ordenar ni deduplicar evidencia.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de esquema, semilla y recursos; no se atribuye revisión humana."
}
```
