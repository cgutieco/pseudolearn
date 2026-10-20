---
{
  "formato": "see/1",
  "id": "SEE.VALIDATION",
  "titulo": "Validación por capas",
  "dominio": "proceso",
  "estado": "estable",
  "version": "0.3.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Validación por capas.",
  "depende_de": [],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ],
  "cambio": {
    "clase": "editorial",
    "impacto_usuarios": "Contrato existente respaldado; no cambia su comportamiento observable.",
    "impacto_implementaciones": "Se conserva la versión numérica y las exenciones explícitas de cada sujeto.",
    "justificacion": "Promoción revisada con evidencias vigentes y verificadores locales ejecutados.",
    "revisado_por": "revision-independiente-automatizada-r9"
  }
}
---

# Validación por capas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La validación rechaza esquema inválido, duplicados, referencias no resueltas, reglas huérfanas, capturas sin revisor, hashes mutados y perfiles incompletos.",
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
  "clase": "semantica",
  "texto": "Los errores de lectura y configuración impiden afirmar que un corpus valida.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "La validación comprueba integridad de lexemas bilingües, firmas, marcadores de diagnósticos, tipos de argumento, políticas de severidad, gramática alcanzable y correspondencia completa de secciones hacia contratos existentes.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas felices e infelices en las capas responsables y verificación local completa."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "La validación rechaza clases de evento ausentes del alfabeto declarado por ENG.TRACE.EVENTS y datos de evento no declarados (SEE-TRACE-CLASS); casos ir sin resultado esperado válido (SEE-IR-EXPECTATION); códigos de salida no declarados por TOOL.CLI.CONVENTIONS (SEE-CLI-EXIT); límite alcanzado sin tipo sentencias o tiempo, o tipo sin límite alcanzado (SEE-LIMIT-KIND); mediciones cuyo protocolo no es una regla de PERF.PROTOCOL (SEE-MEASUREMENT-PROTOCOL); reglas de LANG o LIB de clase semantica, ejecucion o ampliacion sin exactamente una cobertura (SEE-IR-COVERAGE); instrucciones o trampas citadas que no existen (SEE-IR-UNKNOWN); aperturas de nivel superior cuyo lexema o alias coincide con cualquier lexema o alias del otro perfil tras normalizar caja y acentos (SEE-PROFILE-OPENERS), y mensajes de la CLI sin par bilingüe o con argumentos distintos (SEE-MESSAGE-PARITY, SEE-MESSAGE-ARGUMENTS). Alfabetos, tablas y catálogos se leen de bloques definicion del corpus, nunca de listas del código.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas espejo de cada validación y un fixture negativo por identificador; verificación mecánica en cargo xtask verify."
}
```
