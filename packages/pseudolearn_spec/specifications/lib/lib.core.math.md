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
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
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
    "C5",
    "C18",
    "C19",
    "C20"
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
    "es": "Algoritmo P\n  Escribir rc(-1);\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write sqrt(-1);\nEndAlgorithm\n"
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
    "C17",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29",
    "P1"
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
    "C15",
    "C21",
    "C22",
    "C23"
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
    "es": "Algoritmo P\n  Escribir asen(2);\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write asin(2);\nEndAlgorithm\n"
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
    "es": "Algoritmo P\n  Escribir log10(0);\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write log10(0);\nEndAlgorithm\n"
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
    "es": "Algoritmo P\n  Escribir log2(-1);\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Write log2(-1);\nEndAlgorithm\n"
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

```caso
{
  "id": "C18",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo SenoDeTreinta\n  Definir grados, radianes Como Real;\n  grados <- 30;\n  radianes <- grados * 3.141592653589793 / 180;\n  Escribir Decimales(radianes, 4);\n  Escribir Decimales(sen(radianes), 2);\nFinAlgoritmo\n",
    "en": "Algorithm SineOfThirty\n  Define degrees, radians As Real;\n  degrees <- 30;\n  radians <- degrees * 3.141592653589793 / 180;\n  Write decimals(radians, 4);\n  Write decimals(sin(radians), 2);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.5236\n0.50\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo RaizYDistancia\n  Definir area, diferencia Como Real;\n  area <- 49;\n  diferencia <- 3 - 15;\n  Escribir rc(area);\n  Escribir abs(diferencia);\nFinAlgoritmo\n",
    "en": "Algorithm RootAndDistance\n  Define area, difference As Real;\n  area <- 49;\n  difference <- 3 - 15;\n  Write sqrt(area);\n  Write abs(difference);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7.0\n12.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo SenoEnGrados\n  Definir grados Como Real;\n  grados <- 30;\n  Escribir sen(grados);\nFinAlgoritmo\n",
    "en": "Algorithm SineInDegrees\n  Define degrees As Real;\n  degrees <- 30;\n  Write sin(degrees);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-0.9880316240928618\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo PrecioMasBajo\n  Definir tiendaA, tiendaB Como Entero;\n  tiendaA <- 250;\n  tiendaB <- 199;\n  Escribir min(tiendaA, tiendaB);\n  Escribir min(10, 7.5);\nFinAlgoritmo\n",
    "en": "Algorithm LowestPrice\n  Define storeA, storeB As Integer;\n  storeA <- 250;\n  storeB <- 199;\n  Write min(storeA, storeB);\n  Write min(10, 7.5);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "199\n7.5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo MejorNota\n  Definir nota1, nota2 Como Entero;\n  nota1 <- 6;\n  nota2 <- 8;\n  Escribir max(nota1, nota2);\n  Escribir max(4, 4.5);\nFinAlgoritmo\n",
    "en": "Algorithm BestGrade\n  Define grade1, grade2 As Integer;\n  grade1 <- 6;\n  grade2 <- 8;\n  Write max(grade1, grade2);\n  Write max(4, 4.5);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\n4.5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo MenorDeTres\n  Escribir min(4, 9, 2);\nFinAlgoritmo\n",
    "en": "Algorithm SmallestOfThree\n  Write min(4, 9, 2);\nEndAlgorithm\n"
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
  "id": "C24",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo TangenteDe45\n  Definir grados, radianes Como Real;\n  grados <- 45;\n  radianes <- grados * 3.141592653589793 / 180;\n  Escribir Decimales(tan(radianes), 2);\nFinAlgoritmo\n",
    "en": "Algorithm TangentOf45\n  Define degrees, radians As Real;\n  degrees <- 45;\n  radians <- degrees * 3.141592653589793 / 180;\n  Write decimals(tan(radians), 2);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1.00\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo AnguloDesdeSeno\n  Definir radianes Como Real;\n  radianes <- asen(0.5);\n  Escribir radianes;\n  Escribir redon(radianes * 180 / 3.141592653589793);\nFinAlgoritmo\n",
    "en": "Algorithm AngleFromSine\n  Define radians As Real;\n  radians <- asin(0.5);\n  Write radians;\n  Write round(radians * 180 / 3.141592653589793);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.5235987755982989\n30\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo AnguloDesdeCoseno\n  Definir radianes Como Real;\n  radianes <- acos(0.5);\n  Escribir radianes;\n  Escribir redon(radianes * 180 / 3.141592653589793);\nFinAlgoritmo\n",
    "en": "Algorithm AngleFromCosine\n  Define radians As Real;\n  radians <- acos(0.5);\n  Write radians;\n  Write round(radians * 180 / 3.141592653589793);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1.0471975511965979\n60\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo DireccionDeUnPunto\n  Definir puntoX, puntoY Como Real;\n  puntoX <- -1;\n  puntoY <- 1;\n  Escribir atan2(puntoY, puntoX) * 180 / 3.141592653589793;\nFinAlgoritmo\n",
    "en": "Algorithm DirectionOfAPoint\n  Define pointX, pointY As Real;\n  pointX <- -1;\n  pointY <- 1;\n  Write atan2(pointY, pointX) * 180 / 3.141592653589793;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "135.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo ContarCeros\n  Escribir log10(1000);\n  Escribir log10(100000);\nFinAlgoritmo\n",
    "en": "Algorithm CountZeros\n  Write log10(1000);\n  Write log10(100000);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3.0\n5.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo MitadesHastaUno\n  Escribir log2(8);\n  Escribir log2(1024);\nFinAlgoritmo\n",
    "en": "Algorithm HalvesDownToOne\n  Write log2(8);\n  Write log2(1024);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3.0\n10.0\n",
    "terminacion": "completed"
  }
}
```
