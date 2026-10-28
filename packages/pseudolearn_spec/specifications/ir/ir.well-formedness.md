---
{
  "formato": "see/1",
  "id": "IR.WELL-FORMEDNESS",
  "titulo": "Buena formación de la RI",
  "dominio": "ri",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Reglas del verificador de la RI.",
  "depende_de": [
    {
      "id": "IR.INSTRUCTIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "IR.TEXT-FORMAT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "IR.SOURCE-MAP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Intermediate representation well-formedness",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Buena formación de la RI

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El texto respeta la gramática de IR.TEXT-FORMAT y cada operación existe en IR.INSTRUCTIONS.",
  "verificacion": [
    "C2"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada valor se define una sola vez y todo uso está dominado por su definición.",
  "verificacion": [
    "C3"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada operando tiene el tipo y la clase de valor que declara la firma de su instrucción.",
  "verificacion": [
    "C4",
    "C13",
    "C14"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada bloque termina en exactamente un terminador y el terminador es su última instrucción.",
  "verificacion": [
    "C5"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada salto entrega tantos argumentos como parámetros tiene el bloque destino, con sus tipos.",
  "verificacion": [
    "C6"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La masa declarada de cada bloque es igual al número de instrucciones stmt.enter que contiene.",
  "verificacion": [
    "C7"
  ]
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda instrucción con trampas u observación lleva un tramo fuente.",
  "verificacion": [
    "C8"
  ]
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los nombres de funciones y clases son únicos; cada llamada nombra una función existente con su aridad y tipos, y cada campo o método citado existe en su clase.",
  "verificacion": [
    "C9"
  ]
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El verificador acepta una RI si cumple todas las reglas; si no, informa la regla de la primera violación en orden de texto y, a igual posición, la de menor número.",
  "verificacion": [
    "C1"
  ]
}
```

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los campos de una clase tienen nombres únicos y tipos que admiten almacenamiento (ni unit ni cell); los campos de una clase de entorno de captura (nombre que empieza por $environment) se llaman capture seguido de su desplazamiento, en orden estrictamente creciente.",
  "verificacion": [
    "C10",
    "C11",
    "C12"
  ]
}
```

```regla
{
  "id": "R11",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los conteos de clases, funciones, campos por clase y parámetros por función o bloque no superan 65535, el máximo de un operando de 16 bits.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El caso mínimo exige un texto de RI de más de 65535 campos; los tests de ir y bytecode lo ejercitan en el límite y por encima."
}
```

```caso
{
  "id": "C1",
  "regla": "R9",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n"
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R1"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = int.teleport\n  return\n}\n"
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R2"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = int.cmp lt, %1, %1\n  %1 = const.i64 1\n  return\n}\n"
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R3"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = const.bool true\n  %2 = int.add %0, %1 @1:1-1:2\n  return\n}\n"
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R4"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n}\n"
}
```

```caso
{
  "id": "C6",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R5"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  jump b1()\nb1(%0: i64) mass 0:\n  return\n}\n"
}
```

```caso
{
  "id": "C7",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R6"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 2:\n  stmt.enter @1:1-1:2\n  stmt.exit @1:1-1:2\n  return\n}\n"
}
```

```caso
{
  "id": "C8",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R7"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = int.div %0, %0\n  return\n}\n"
}
```

```caso
{
  "id": "C9",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R8"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  call @sub.missing() @1:1-1:2\n  return\n}\n"
}
```

```caso
{
  "id": "C10",
  "regla": "R10",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R10"
    }
  },
  "programa_ri": "module P es\nclass C { value: i64, value: i64 }\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n"
}
```

```caso
{
  "id": "C11",
  "regla": "R10",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R10"
    }
  },
  "programa_ri": "module P es\nclass \"$environment1\" { capture2: i64, capture0: i64 }\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n"
}
```

```caso
{
  "id": "C12",
  "regla": "R10",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nclass \"$environment1\" { capture0: i64, capture3: str }\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n"
}
```

```caso
{
  "id": "C13",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = task.scope_open\n  %1 = task.spawn %0, @worker() -> i64\n  %2 = task.await %1, i64\n  task.scope_join %0\n  return\n}\nfunc @worker() -> i64 {\nb0() mass 0:\n  %0 = const.i64 7\n  return %0\n}\n"
}
```

```caso
{
  "id": "C14",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": false,
      "regla": "IR.WELL-FORMEDNESS#R3"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"scope\"\n  %1 = task.spawn %0, @worker() -> i64\n  return\n}\nfunc @worker() -> i64 {\nb0() mass 0:\n  %0 = const.i64 7\n  return %0\n}\n"
}
```
