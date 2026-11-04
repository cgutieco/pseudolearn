---
{
  "formato": "see/1",
  "id": "LIB.CORE.MATH",
  "titulo": "Funciones matemáticas",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Funciones matemáticas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Funciones matemáticas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "rc, abs, ln, exp, sen, cos y atan aceptan un número y devuelven real finito. rc es raíz cuadrada no negativa, ln logaritmo natural, exp exponencial base e; funciones trigonométricas usan radianes. Dominio inválido, infinito o NaN produce nonFiniteRealResult. Se aplica ampliación entero a real; nunca se consulta entorno. El resultado de cada función es el binario64 más cercano al valor matemático exacto, con empates al significando par; esta regla incluye subnormales y ceros con signo y es independiente de la biblioteca matemática del anfitrión.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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
  "programas": {
    "es": "Algoritmo P\nEscribir rc(4), \":\", abs(-3), \":\", ln(1), \":\", exp(0), \":\", sen(0), \":\", cos(0), \":\", atan(0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(4), \":\", abs(-3), \":\", ln(1), \":\", exp(0), \":\", sin(0), \":\", cos(0), \":\", atan(0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0:3.0:0.0:1.0:0.0:1.0:0.0\n",
    "terminacion": "completed"
  }
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
  "programas": {
    "es": "Algoritmo P\nEscribir rc(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir ln(0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ln(0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
    }
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir rc(\"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(\"ab\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nEscribir rc(2.0), \":\", ln(2.0), \":\", exp(1.0), \":\", sen(1.0), \":\", cos(1.0), \":\", atan(1.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(2.0), \":\", ln(2.0), \":\", exp(1.0), \":\", sin(1.0), \":\", cos(1.0), \":\", atan(1.0);\nendAlgorithm\n"
  },
  "espera": {
    "salida": "1.4142135623730951:0.6931471805599453:2.718281828459045:0.8414709848078965:0.5403023058681398:0.7853981633974483\n",
    "terminacion": "completed"
  },
  "id": "C5"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "tan, asen/asin, acos, atan2(y,x), log10 y log2 aceptan números ampliados a real. Devuelven el binario64 más cercano con empates al par, incluidos subnormales y ceros con signo, sin consultar entorno ni libm del anfitrión. asen y acos requieren -1 <= x <= 1; log10 y log2 requieren x > 0. Dominio inválido o resultado no finito produce nonFiniteRealResult. atan2 usa el cuadrante de (x,y): atan2(±0,+0)=±0 y atan2(±0,-0)=±pi. tan(±0) y asen(±0) conservan signo; acos(1)=+0; log2(2^k)=k y log10(10^k)=k cuando el argumento es exactamente esa potencia.",
  "verificacion": [
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C13",
    "C14",
    "C16",
    "C17"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "min y max aceptan dos números; devuelven Entero si ambos son enteros y Real si alguno es real, ampliando ambos en ese caso. Seleccionan el menor o mayor valor. Los ceros reales se desempatan por signo: min(-0,+0)=-0 y max(-0,+0)=+0. No reservan sus nombres frente a identificadores de usuario.",
  "verificacion": [
    "C11",
    "C12",
    "C15"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir tan(0), \":\", asen(0), \":\", acos(1), \":\", atan2(0,1), \":\", log10(1000), \":\", log2(0.5);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite tan(0), \":\", asin(0), \":\", acos(1), \":\", atan2(0,1), \":\", log10(1000), \":\", log2(0.5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.0:0.0:0.0:0.0:3.0:-1.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir asen(2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite asin(2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir log10(0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite log10(0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
    }
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir log2(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite log2(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir atan2(1,1), \":\", asen(1), \":\", acos(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite atan2(1,1), \":\", asin(1), \":\", acos(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.7853981633974483:1.5707963267948966:3.141592653589793\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir min(3,4), \":\", max(-3,2), \":\", min(3,2.5), \":\", max(-0.0,0.0), \":\", min(0.0,-0.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite min(3,4), \":\", max(-3,2), \":\", min(3,2.5), \":\", max(-0.0,0.0), \":\", min(0.0,-0.0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3:2:2.5:0.0:-0.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir min(\"ab\",2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite min(\"ab\",2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
      }
    ]
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "programas": "Muestras binarias reproducibles de las seis funciones nuevas con semilla y extremos de dominio."
  },
  "propiedad": "Cada resultado coincide con el redondeo binario64 del intervalo racional independiente.",
  "oraculo": "see_oracles calcula intervalos racionales sin ejecutar código del sujeto.",
  "justificacion": "La precisión se contrasta sobre muestras sembradas y casos límite."
}
```

```caso
{
  "id": "C13",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir atan2(0.0,-0.0), \":\", atan2(-0.0,-0.0), \":\", atan2(-0.0,0.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite atan2(0.0,-0.0), \":\", atan2(-0.0,-0.0), \":\", atan2(-0.0,0.0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3.141592653589793:-3.141592653589793:-0.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir log2(0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004940656458412465441765687928682213723650598026143247644255856825006755072702087518652998363616359923797965646954457177309266567103559397963987747960107818781263007131903114045278458171678489821036887186360569987307230500063874091535649843873124733972731696151400317153853980741262385655911710266585566867681870395603106249319452715914924553293054565444011274801297099995419319894090804165633245247571478690147267801593552386115501348035264934720193790268107107491703332226844753335720832431936092382893458368060106011506169809753078342277318329247904982524730776375927247874656084778203734469699533647017972677717585125660551199131504891101451037862738167250955837389733598993664809941164205702637090279242767544565229087538682506419718265533447265625);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite log2(0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004940656458412465441765687928682213723650598026143247644255856825006755072702087518652998363616359923797965646954457177309266567103559397963987747960107818781263007131903114045278458171678489821036887186360569987307230500063874091535649843873124733972731696151400317153853980741262385655911710266585566867681870395603106249319452715914924553293054565444011274801297099995419319894090804165633245247571478690147267801593552386115501348035264934720193790268107107491703332226844753335720832431936092382893458368060106011506169809753078342277318329247904982524730776375927247874656084778203734469699533647017972677717585125660551199131504891101451037862738167250955837389733598993664809941164205702637090279242767544565229087538682506419718265533447265625);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-1074.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir min(9223372036854775807,9223372036854775806);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite min(9223372036854775807,9223372036854775806);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9223372036854775806\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir atan2(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite atan2(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir tan(\"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite tan(\"ab\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
      }
    ]
  }
}
```
