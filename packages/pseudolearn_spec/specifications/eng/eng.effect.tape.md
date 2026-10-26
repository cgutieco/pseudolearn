---
{
  "formato": "see/1",
  "id": "ENG.EFFECT.TAPE",
  "titulo": "Esquema versionado de cinta de efectos y reproducción aislada",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Esquema pseudolearn.tape/v1, identidad de ejecución, entradas encadenadas y rechazo sin anfitrión.",
  "titulo_en": "Versioned effect tape schema and isolated replay",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.EFFECT-COMMIT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Esquema versionado de cinta de efectos y reproducción aislada

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cinta de efectos utiliza el esquema versionado pseudolearn.tape/v1. Contiene la cabecera del esquema, la identidad inmutable de la ejecución y una secuencia monotónica de entradas de efecto TapeEntry serializadas de forma determinista.",
  "verificacion": [
    "C1"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "cinta_v1\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"cinta_v1\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "ExecutionIdentity resume de forma canónica la huella del programa: código fuente, grafo de dependencias, perfil, semilla, límites efectivos y permisos efectivos. Dos ejecuciones con idéntica ExecutionIdentity y entradas de cinta producen idéntica traza de estados y salidas.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "identidad_valida\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"identidad_valida\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada TapeEntry registra effect_seq, task_id, source_node_id, capability_kind, operation, request_digest, secret_ref, outcome, payload_bytes y entry_hash. El campo entry_hash es un resumen SHA-256 encadenado criptográficamente con el entry_hash de la entrada previa, garantizando detección de adulteración.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "entrada_encadenada\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"entrada_encadenada\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda reproducción desde cinta valida identidad, secuencia y hashes encadenados. Ante discrepancia de identidad emite replay_identity_mismatch; ante efecto imprevisto emite replay_divergence; ante fin prematuro emite replay_truncated_tape; ante hash o payload adulterado emite replay_corrupted_tape; y ante cinta incompleta o incierta emite replay_non_reproducible. El motor jamás recurre al anfitrión vivo tras un fallo de reproducción.",
  "verificacion": [
    "C4",
    "C5"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "sin_fallback\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"sin_fallback\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "rechazo_corrupcion\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"rechazo_corrupcion\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cinta protege la privacidad y los límites de memoria: los argumentos clasificados como secretos se redactan y sustituyen por SecretRef { key_id, value_hmac } antes de la serialización, y el crecimiento de la cinta respeta el límite configurable max_tape_bytes. Si la cinta excede el presupuesto de bytes o contiene secretos sin almacén de resolución externo, se sella deterministamente como NonReproducibleTruncated o NonReproducibleRedacted.",
  "verificacion": [
    "C6"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "privacidad_cinta_ok\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"privacidad_cinta_ok\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```
