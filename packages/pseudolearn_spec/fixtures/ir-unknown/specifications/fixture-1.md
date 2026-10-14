---
{
  "formato": "see/1",
  "id": "IR.TEST.CATALOG",
  "titulo": "Fixture",
  "dominio": "ri",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Violación deliberada.",
  "depende_de": []
}
---

# Fixture

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Regla de fixture.",
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "espera": {
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nFinAlgoritmo\n"
  },
  "operacion": "execute"
}
```

```instruccion
{
  "id": "O1",
  "nombre": "int.add",
  "firma": "int.add(entero, entero) -> entero",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Suma.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```cobertura
{
  "id": "V1",
  "regla": "IR.TEST.CATALOG#R1",
  "instrucciones": [
    "int.teleport"
  ]
}
```
