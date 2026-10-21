---
formato: see/1
id: SEE.FORMAT
titulo: Formato de especificaciones
dominio: proceso
estado: estable
version: 1.0.0
duenos: [responsable-especificaciones]
revisado_por: [Cesar Antonio Gutierrez Contreras]
sujetos: [see]
resumen: Formato de especificaciones.
---

# Formato de especificaciones

```regla
id: R1
fuerza: DEBE
clase: sistema
texto: El formato see/1 contiene metadatos YAML completos y bloques tipados regla, caso, definicion, error, propiedad, invariante, precondicion y resultado; rechaza campos desconocidos.
verificacion: [revision_humana]
justificacion: Revisión estructural manual contra el plan aprobado; la revisión independiente de la persona registrada en revisado_por aprueba su estabilidad.
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los casos admiten sujetos opcional como subconjunto no vacío de los sujetos declarados: ausente aplica a todos; un sujeto excluido no ejecuta ni aporta evidencia para ese caso. Las definiciones admiten valor como objeto normativo; los casos admiten semilla opcional de entero con signo de 64 bits, transmitida a seed sin alterar el valor; ausente usa 42. diagnosticos compara multiconjuntos y diagnosticos_ordenados exige el orden exacto sin ordenar ni deduplicar evidencia.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de esquema, semilla y recursos; no se atribuye revisión humana."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los bloques medicion, instruccion y cobertura son tipados. medicion declara métrica, unidad, suite, comparador, umbral, carácter provisional, plataformas y la regla de PERF.PROTOCOL que la rige. instruccion declara nombre, firma, clases de valor, semántica, trampas, efectos y observación. cobertura asocia una regla con instrucciones o con un motivo sin RI. Los casos admiten las operaciones trace, ir y cli con sus fuentes programa_ri y cli, límites del anfitrión y cancelación; las expectativas admiten la terminación cancelled, el tipo de límite alcanzado, eventos ordenados, el estado en un índice de evento, el resultado de RI, el código de salida, la salida de error y el JSON de máquina.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de esquema y validación, fixtures negativos y verificación mecánica en cargo xtask verify."
}
```
