---
{
  "formato": "see/1",
  "id": "ENG.INPUT",
  "titulo": "Entrada del programa",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Suspensión por Leer, entrega por lotes y cinta de entradas.",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.IO.INPUT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "refina"
    }
  ],
  "titulo_en": "Program input"
}
---

# Entrada del programa

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Leer suspende la ejecución con awaiting_input cuando no hay un valor disponible y la reanuda con el valor entregado. La suspensión conserva el estado y no repite efectos ya producidos.",
  "verificacion": [
    "C1",
    "C2"
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
    "salida": "antes\n",
    "terminacion": "awaiting_input"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nEscribir \"antes\";\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C2",
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
    "salida": "antes\n5\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nEscribir \"antes\";\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "5"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El anfitrión puede entregar varios valores por adelantado. Cada posición de Leer consume un valor, en orden; los valores sobrantes no son un error y no se consumen.",
  "verificacion": [
    "C3",
    "C4"
  ]
}
```

```caso
{
  "id": "C3",
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
    "salida": "5\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir a, b Como Entero;\nLeer a, b;\nEscribir a + b;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "2",
    "3",
    "9"
  ]
}
```

```caso
{
  "id": "C4",
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
    "salida": "",
    "terminacion": "awaiting_input"
  },
  "programa": "Algoritmo P\nDefinir a, b Como Entero;\nLeer a;\nLeer b;\nEscribir a + b;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "2"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La secuencia de valores entregados, con el evento en que se consumió cada uno, junto con el programa, la configuración y la semilla, determina la ejecución completa y permite reproducirla.",
  "verificacion": [
    "C5",
    "P1"
  ]
}
```

```caso
{
  "id": "C5",
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
    "salida": "7\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir total, valor Como Entero;\ntotal <- 0;\nLeer valor;\nMientras valor <> 0 Hacer\ntotal <- total + valor;\nLeer valor;\nFinMientras\nEscribir total;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "3",
    "4",
    "0"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {
    "programas": "casos con entrada del corpus",
    "cortes": "toda partición de la cinta en lotes"
  },
  "propiedad": "Entregar la misma cinta en cualquier partición de lotes produce la misma ejecución.",
  "oraculo": "Comparación con la ejecución que recibe toda la cinta de una vez.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una entrada que no se convierte al tipo del destino emite readValueTypeMismatch, se consume y vuelve a pedir la misma posición sin modificar el destino.",
  "verificacion": [
    "C6",
    "C7"
  ]
}
```

```caso
{
  "id": "C6",
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
    "salida": "5\n",
    "terminacion": "completed",
    "diagnosticos": [
      {
        "codigo": "readValueTypeMismatch",
        "severidad": "warning"
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "abc",
    "5"
  ]
}
```

```caso
{
  "id": "C7",
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
    "salida": "",
    "terminacion": "awaiting_input",
    "diagnosticos": [
      {
        "codigo": "readValueTypeMismatch",
        "severidad": "warning"
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "abc"
  ]
}
```
