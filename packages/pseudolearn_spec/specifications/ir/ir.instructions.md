---
{
  "formato": "see/1",
  "id": "IR.INSTRUCTIONS",
  "titulo": "Catálogo de instrucciones",
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
  "resumen": "Instrucciones de la RI con su semántica, trampas, efectos, observación y cobertura de reglas.",
  "depende_de": [
    {
      "id": "IR.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.EFFECT-ORDER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Instruction catalog",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Catálogo de instrucciones

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las instrucciones de la RI son exactamente las de los bloques instruccion de este contrato. Cada una declara su firma, las clases de valor que maneja, su semántica, sus trampas, sus efectos y los eventos que produce. Una instrucción sin efectos ni observación es pura.",
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
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La aritmética entera es exacta en 64 bits con signo y comprobada; la real es IEEE 754 binario64 con redondeo al más cercano y empates al par, y todo resultado no finito atrapa. Los textos se comparan por puntos de código sin normalizar.",
  "verificacion": [
    "C2",
    "C3"
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
    "salida": "",
    "fallo": {
      "codigo": "integerOverflow"
    }
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nx <- 9223372036854775807;\nx <- x * 2;\nFinAlgoritmo\n",
  "perfil_base": "es"
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
    "salida": "-1:0\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir Mutable a Como Entero <- 0;\nDefinir Mutable b Como Entero <- 0;\na <- -9223372036854775807 - 1;\nb <- -1;\nEscribir -7 mod 2 + 0, \":\", a mod b;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una trampa detiene la ejecución con su diagnóstico y el tramo de su instrucción; se informa la primera trampa en orden de programa y ningún efecto posterior es visible. Dentro de una secuencia de instrucciones puras, una implementación puede comprobar las trampas al final de la secuencia siempre que vuelva a evaluarla para atribuir la primera trampa exacta.",
  "verificacion": [
    "C4",
    "P1"
  ]
}
```

```caso
{
  "id": "C4",
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
    "salida": "1\n",
    "fallo": {
      "codigo": "negativeIntegerExponent"
    }
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nDefinir Mutable z Como Entero <- 0;\nx <- -1;\nEscribir 1;\nz <- (2 ^ x) + (1 div 0);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {
    "programas": "regiones puras generadas con trampas en distintas posiciones"
  },
  "propiedad": "La comprobación diferida con reevaluación informa la misma primera trampa y tramo que la comprobación por instrucción.",
  "oraculo": "Comprobación por instrucción en orden de programa.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada regla de LANG y LIB de clase semantica, ejecucion o ampliacion tiene exactamente un bloque cobertura que lista las instrucciones que exige o declara por qué no llega a la RI.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "see validate rechaza con SEE-IR-COVERAGE cualquier hueco o duplicado y con SEE-IR-UNKNOWN cualquier instrucción inexistente."
}
```

```instruccion
{
  "id": "O1",
  "nombre": "const.i64",
  "firma": "const.i64 <entero> -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Produce el entero literal.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O2",
  "nombre": "const.f64",
  "firma": "const.f64 <real> -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Produce el real literal finito, redondeado a binario64.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O3",
  "nombre": "const.bool",
  "firma": "const.bool <true|false> -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Produce el valor lógico literal.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O4",
  "nombre": "const.char",
  "firma": "const.char <punto de código> -> char",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Produce el carácter cuyo escalar Unicode es el operando.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O5",
  "nombre": "const.str",
  "firma": "const.str <literal> -> str",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Produce la cadena literal del programa; no ocupa celdas.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O6",
  "nombre": "value.undefined",
  "firma": "value.undefined <tipo> -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Produce el estado sin valor de una variable o campo declarado.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O7",
  "nombre": "value.require",
  "firma": "value.require %v -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Devuelve el valor si existe; si es sin valor, atrapa.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O8",
  "nombre": "int.add",
  "firma": "int.add %a: i64, %b: i64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Suma entera exacta; un resultado fuera de 64 bits con signo atrapa.",
  "trampas": [
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O9",
  "nombre": "int.sub",
  "firma": "int.sub %a: i64, %b: i64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Resta entera exacta comprobada.",
  "trampas": [
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O10",
  "nombre": "int.mul",
  "firma": "int.mul %a: i64, %b: i64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Producto entero exacto comprobado.",
  "trampas": [
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O11",
  "nombre": "int.neg",
  "firma": "int.neg %a: i64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Opuesto entero; el opuesto del mínimo atrapa.",
  "trampas": [
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O12",
  "nombre": "int.div",
  "firma": "int.div %a: i64, %b: i64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Cociente truncado hacia cero; divisor cero o mínimo entre -1 atrapan.",
  "trampas": [
    "divisionByZero",
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O13",
  "nombre": "int.mod",
  "firma": "int.mod %a: i64, %b: i64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Resto con el signo del dividendo tal que a = (a div b) * b + resto; divisor cero atrapa; el mínimo módulo -1 es cero.",
  "trampas": [
    "divisionByZero"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O14",
  "nombre": "int.pow",
  "firma": "int.pow %a: i64, %b: i64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Potencia entera exacta; exponente cero da uno, incluido cero elevado a cero.",
  "trampas": [
    "negativeIntegerExponent",
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O15",
  "nombre": "int.cmp",
  "firma": "int.cmp <eq|ne|lt|le|gt|ge>, %a: i64, %b: i64 -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Compara dos enteros con el predicado indicado.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O16",
  "nombre": "int.to_real",
  "firma": "int.to_real %a: i64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Amplía un entero al real binario64 más cercano, con empates al par.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O17",
  "nombre": "real.add",
  "firma": "real.add %a: f64, %b: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Suma binario64 con redondeo al más cercano; un resultado no finito atrapa.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O18",
  "nombre": "real.sub",
  "firma": "real.sub %a: f64, %b: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Resta binario64 comprobada.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O19",
  "nombre": "real.mul",
  "firma": "real.mul %a: f64, %b: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Producto binario64 comprobado.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O20",
  "nombre": "real.div",
  "firma": "real.div %a: f64, %b: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Cociente binario64; un divisor cero atrapa como división por cero y un resultado no finito como real no finito.",
  "trampas": [
    "divisionByZero",
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O21",
  "nombre": "real.neg",
  "firma": "real.neg %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Opuesto real; nunca atrapa.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O22",
  "nombre": "real.pow",
  "firma": "real.pow %a: f64, %b: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Potencia real; exponente cero da uno; un resultado no finito o indefinido atrapa.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O23",
  "nombre": "real.cmp",
  "firma": "real.cmp <eq|ne|lt|le|gt|ge>, %a: f64, %b: f64 -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Compara dos reales finitos; cero y menos cero son iguales.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O24",
  "nombre": "real.trunc",
  "firma": "real.trunc %a: f64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Trunca hacia cero; un resultado fuera de 64 bits atrapa.",
  "trampas": [
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O25",
  "nombre": "real.round",
  "firma": "real.round %a: f64 -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Redondea al entero más cercano con empates alejándose de cero; fuera de rango atrapa.",
  "trampas": [
    "integerOverflow"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O26",
  "nombre": "math.sqrt",
  "firma": "math.sqrt %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Raíz cuadrada no negativa; un argumento negativo atrapa.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O27",
  "nombre": "math.abs",
  "firma": "math.abs %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Valor absoluto real.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O28",
  "nombre": "math.ln",
  "firma": "math.ln %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Logaritmo natural; un argumento no positivo atrapa.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O29",
  "nombre": "math.exp",
  "firma": "math.exp %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Exponencial de base e; el desbordamiento atrapa.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O30",
  "nombre": "math.sin",
  "firma": "math.sin %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Seno en radianes.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O31",
  "nombre": "math.cos",
  "firma": "math.cos %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Coseno en radianes.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O32",
  "nombre": "math.atan",
  "firma": "math.atan %a: f64 -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Arcotangente en radianes.",
  "trampas": [
    "nonFiniteRealResult"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O33",
  "nombre": "bool.not",
  "firma": "bool.not %a: bool -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Negación lógica.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O34",
  "nombre": "bool.cmp",
  "firma": "bool.cmp <eq|ne>, %a: bool, %b: bool -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Igualdad entre lógicos.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O35",
  "nombre": "char.cmp",
  "firma": "char.cmp <eq|ne|lt|le|gt|ge>, %a: char, %b: char -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Compara caracteres por escalar Unicode.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O36",
  "nombre": "char.code",
  "firma": "char.code %a: char -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Devuelve el escalar Unicode del carácter.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O37",
  "nombre": "char.from_code",
  "firma": "char.from_code %a: i64 -> char",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Devuelve el carácter de un escalar en [0, 1114111] fuera de [55296, 57343]; otro valor atrapa.",
  "trampas": [
    "invalidCharacterCode"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O38",
  "nombre": "text.concat",
  "firma": "text.concat %a: str|char, %b: str|char -> str",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Concatena los puntos de código de ambos operandos en una cadena nueva.",
  "trampas": [
    "cellLimitExceeded"
  ],
  "efectos": [
    "asigna"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O39",
  "nombre": "text.length",
  "firma": "text.length %a: str -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Cuenta los puntos de código.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O40",
  "nombre": "text.char_at",
  "firma": "text.char_at %a: str, %i: i64 -> char",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Devuelve el punto de código de la posición cero basada; fuera de rango atrapa.",
  "trampas": [
    "stringPositionOutOfRange"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O41",
  "nombre": "text.cmp",
  "firma": "text.cmp <eq|ne|lt|le|gt|ge>, %a: str|char, %b: str|char -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Compara lexicográficamente por puntos de código, sin normalizar.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O42",
  "nombre": "text.format",
  "firma": "text.format %v -> str",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Crea la representación de un primitivo según LANG.IO.VALUE-FORMAT con el vocabulario de la fuente del sitio o, si esta no tiene perfil, el del módulo.",
  "trampas": [
    "cellLimitExceeded"
  ],
  "efectos": [
    "asigna"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O43",
  "nombre": "text.to_integer",
  "firma": "text.to_integer %a: str -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Convierte una cadena decimal a entero en rango; otro texto atrapa.",
  "trampas": [
    "stringToNumberConversionFailed"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O44",
  "nombre": "text.to_real",
  "firma": "text.to_real %a: str -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Convierte una cadena decimal a real finito; otro texto atrapa.",
  "trampas": [
    "stringToNumberConversionFailed"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O45",
  "nombre": "array.new",
  "firma": "array.new <tipo>, %d: i64... -> array<T, n>",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Crea un arreglo con las dimensiones dadas y todas sus celdas sin valor; un tamaño negativo o el límite de celdas atrapan.",
  "trampas": [
    "negativeArraySize",
    "cellLimitExceeded"
  ],
  "efectos": [
    "asigna"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O46",
  "nombre": "array.load",
  "firma": "array.load %a: array<T, n>, %i: i64... -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee una celda cero basada; un índice fuera de rango o una celda sin valor atrapan.",
  "trampas": [
    "arrayIndexOutOfRange",
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O47",
  "nombre": "array.store",
  "firma": "array.store %a: array<T, n>, %i: i64..., %v: T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Escribe una celda cero basada; un índice fuera de rango atrapa.",
  "trampas": [
    "arrayIndexOutOfRange"
  ],
  "efectos": [
    "escribe_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O48",
  "nombre": "object.new",
  "firma": "object.new <clase> -> obj<C>",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Crea un objeto de la clase con todos sus campos sin valor, sin ejecutar constructor.",
  "trampas": [
    "cellLimitExceeded"
  ],
  "efectos": [
    "asigna"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O49",
  "nombre": "object.load",
  "firma": "object.load %o: obj<C>, <campo> -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee un campo; un campo sin valor atrapa.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O50",
  "nombre": "object.store",
  "firma": "object.store %o: obj<C>, <campo>, %v: T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Escribe un campo.",
  "trampas": [],
  "efectos": [
    "escribe_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O51",
  "nombre": "object.copy",
  "firma": "object.copy %o: obj<C> -> obj<C>",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Crea un objeto de la misma clase real con los mismos valores de campo, sin ejecutar constructor.",
  "trampas": [
    "cellLimitExceeded"
  ],
  "efectos": [
    "asigna",
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O52",
  "nombre": "ref.cmp",
  "firma": "ref.cmp <eq|ne>, %a: obj<C>, %b: obj<D> -> bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Compara identidades de objetos.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O53",
  "nombre": "cell.local",
  "firma": "cell.local <tipo> -> cell<T>",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Crea la celda de una variable local que se pasa por referencia; no ocupa celdas de memoria.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O54",
  "nombre": "cell.element",
  "firma": "cell.element %a: array<T, n>, %i: i64... -> cell<T>",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Fija una vez la celda de un elemento; un índice fuera de rango atrapa.",
  "trampas": [
    "arrayIndexOutOfRange"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O55",
  "nombre": "cell.field",
  "firma": "cell.field %o: obj<C>, <campo> -> cell<T>",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Fija la celda de un campo.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O56",
  "nombre": "cell.load",
  "firma": "cell.load %c: cell<T> -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee la ubicación de la celda; sin valor atrapa.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O57",
  "nombre": "cell.store",
  "firma": "cell.store %c: cell<T>, %v: T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Escribe la ubicación de la celda; las celdas de la misma ubicación observan la escritura.",
  "trampas": [],
  "efectos": [
    "escribe_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O58",
  "nombre": "call",
  "firma": "call @f(%a...) -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Crea el marco de la función y la ejecuta; superar la profundidad atrapa.",
  "trampas": [
    "recursionDepthExceeded"
  ],
  "efectos": [
    "llamada"
  ],
  "observacion": [
    "call",
    "return"
  ]
}
```

```instruccion
{
  "id": "O59",
  "nombre": "call.virtual",
  "firma": "call.virtual %o: obj<C>, <método>(%a...) -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Selecciona la implementación por la clase real del receptor y la llama.",
  "trampas": [
    "recursionDepthExceeded",
    "uninitializedVariableRead"
  ],
  "efectos": [
    "llamada"
  ],
  "observacion": [
    "call",
    "return"
  ]
}
```

```instruccion
{
  "id": "O60",
  "nombre": "out.write",
  "firma": "out.write %v..., [newline]",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Escribe la concatenación de las representaciones de los valores, con el vocabulario de la fuente del sitio como text.format, y, si se indica, un salto de línea, como un único efecto; no crea valores del programa.",
  "trampas": [],
  "efectos": [
    "salida"
  ],
  "observacion": [
    "output"
  ]
}
```

```instruccion
{
  "id": "O61",
  "nombre": "in.read",
  "firma": "in.read <tipo> -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Pide un valor; si no hay, suspende con awaiting_input; si el texto no se convierte, emite readValueTypeMismatch y vuelve a pedir.",
  "trampas": [],
  "efectos": [
    "entrada"
  ],
  "observacion": [
    "input_requested",
    "input_received"
  ]
}
```

```instruccion
{
  "id": "O62",
  "nombre": "host.random",
  "firma": "host.random -> f64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Toma el siguiente valor de la fuente aleatoria inyectada, en [0, 1).",
  "trampas": [],
  "efectos": [
    "azar"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O63",
  "nombre": "stmt.enter",
  "firma": "stmt.enter",
  "clases_de_valor": [],
  "semantica": "Marca la entrada a una sentencia: cuenta una sentencia, comprueba el presupuesto y la cancelación.",
  "trampas": [
    "statementBudgetExhausted"
  ],
  "efectos": [
    "control"
  ],
  "observacion": [
    "statement_entered"
  ]
}
```

```instruccion
{
  "id": "O64",
  "nombre": "stmt.exit",
  "firma": "stmt.exit",
  "clases_de_valor": [],
  "semantica": "Marca la terminación normal de una sentencia.",
  "trampas": [],
  "efectos": [],
  "observacion": [
    "statement_exited"
  ]
}
```

```instruccion
{
  "id": "O65",
  "nombre": "decide.bool",
  "firma": "decide.bool %c: bool",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Registra una decisión con rama afirmativa si c es verdadero y negativa si no.",
  "trampas": [],
  "efectos": [],
  "observacion": [
    "decision"
  ]
}
```

```instruccion
{
  "id": "O66",
  "nombre": "decide.case",
  "firma": "decide.case <índice>",
  "clases_de_valor": [],
  "semantica": "Registra la elección de la rama con etiquetas de ese índice.",
  "trampas": [],
  "efectos": [],
  "observacion": [
    "decision"
  ]
}
```

```instruccion
{
  "id": "O67",
  "nombre": "decide.default",
  "firma": "decide.default",
  "clases_de_valor": [],
  "semantica": "Registra la elección de De Otro Modo.",
  "trampas": [],
  "efectos": [],
  "observacion": [
    "decision"
  ]
}
```

```instruccion
{
  "id": "O68",
  "nombre": "decide.none",
  "firma": "decide.none",
  "clases_de_valor": [],
  "semantica": "Registra que Segun no ejecuta ninguna rama.",
  "trampas": [],
  "efectos": [],
  "observacion": [
    "decision"
  ]
}
```

```instruccion
{
  "id": "O69",
  "nombre": "loop.check_step",
  "firma": "loop.check_step %p: i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Atrapa si el paso de Para es cero.",
  "trampas": [
    "zeroStepInCountedLoop"
  ],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O70",
  "nombre": "jump",
  "firma": "jump b(%a...)",
  "clases_de_valor": [],
  "semantica": "Terminador: salta al bloque con argumentos.",
  "trampas": [],
  "efectos": [
    "control"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O71",
  "nombre": "branch",
  "firma": "branch %c: bool, b1(%a...), b2(%b...)",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Terminador: salta a b1 si c es verdadero y a b2 si no.",
  "trampas": [],
  "efectos": [
    "control"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O72",
  "nombre": "return",
  "firma": "return [%v]",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Terminador: termina la función y devuelve el control a la llamada, que produce el evento return; en la función principal termina la ejecución con completed.",
  "trampas": [],
  "efectos": [
    "control"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O73",
  "nombre": "trap.missing_return",
  "firma": "trap.missing_return",
  "clases_de_valor": [],
  "semantica": "Terminador: una función con tipo de retorno alcanzó su cierre.",
  "trampas": [
    "subroutineEndedWithoutReturn"
  ],
  "efectos": [
    "control"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O74",
  "nombre": "unreachable",
  "firma": "unreachable",
  "clases_de_valor": [],
  "semantica": "Terminador que la RI verificada nunca alcanza; alcanzarlo es un defecto interno.",
  "trampas": [],
  "efectos": [
    "control"
  ],
  "observacion": []
}
```

```cobertura
{
  "id": "V1",
  "regla": "LANG.ARRAY.ACCESS#R1",
  "instrucciones": [
    "array.load",
    "array.store",
    "cell.element"
  ]
}
```

```cobertura
{
  "id": "V2",
  "regla": "LANG.ARRAY.DIMENSION#R1",
  "instrucciones": [
    "array.new"
  ]
}
```

```cobertura
{
  "id": "V3",
  "regla": "LANG.CLASS.CONSTRUCTOR#R1",
  "instrucciones": [
    "object.new",
    "call",
    "return"
  ]
}
```

```cobertura
{
  "id": "V4",
  "regla": "LANG.CLASS.COPY#R1",
  "instrucciones": [
    "object.copy"
  ]
}
```

```cobertura
{
  "id": "V5",
  "regla": "LANG.CLASS.DECLARATION#R1",
  "sin_ri": "La declaración define la tabla de clases del módulo de IR.MODEL; sus restricciones son estáticas."
}
```

```cobertura
{
  "id": "V6",
  "regla": "LANG.CLASS.FIELDS#R1",
  "instrucciones": [
    "object.new",
    "object.load",
    "object.store"
  ]
}
```

```cobertura
{
  "id": "V7",
  "regla": "LANG.CLASS.INHERITANCE#R1",
  "instrucciones": [
    "object.new",
    "call.virtual"
  ]
}
```

```cobertura
{
  "id": "V8",
  "regla": "LANG.CLASS.INSTANTIATION#R1",
  "instrucciones": [
    "object.new",
    "call",
    "value.require"
  ]
}
```

```cobertura
{
  "id": "V9",
  "regla": "LANG.CLASS.MEMBER-ACCESS#R1",
  "instrucciones": [
    "object.load",
    "object.store",
    "call.virtual",
    "value.require"
  ]
}
```

```cobertura
{
  "id": "V10",
  "regla": "LANG.CLASS.METHODS#R1",
  "instrucciones": [
    "call.virtual",
    "return"
  ]
}
```

```cobertura
{
  "id": "V11",
  "regla": "LANG.CLASS.OUT-OF-SCOPE#R1",
  "sin_ri": "Diagnósticos pedagógicos del análisis; ningún programa con esas formas llega a la RI."
}
```

```cobertura
{
  "id": "V12",
  "regla": "LANG.CLASS.OVERRIDE#R1",
  "instrucciones": [
    "call.virtual",
    "call"
  ]
}
```

```cobertura
{
  "id": "V13",
  "regla": "LANG.CLASS.SELF-AND-SUPER#R1",
  "instrucciones": [
    "call",
    "object.load",
    "object.store"
  ]
}
```

```cobertura
{
  "id": "V14",
  "regla": "LANG.CONTROL.FOR#R1",
  "instrucciones": [
    "jump",
    "branch"
  ]
}
```

```cobertura
{
  "id": "V15",
  "regla": "LANG.CONTROL.FOR#R2",
  "instrucciones": [
    "loop.check_step"
  ]
}
```

```cobertura
{
  "id": "V16",
  "regla": "LANG.CONTROL.FOR#R3",
  "instrucciones": [
    "int.cmp",
    "branch",
    "decide.bool"
  ]
}
```

```cobertura
{
  "id": "V17",
  "regla": "LANG.CONTROL.FOR#R4",
  "instrucciones": [
    "int.add",
    "jump"
  ]
}
```

```cobertura
{
  "id": "V18",
  "regla": "LANG.CONTROL.FOR#R5",
  "sin_ri": "Advertencia del análisis estático."
}
```

```cobertura
{
  "id": "V19",
  "regla": "LANG.CONTROL.FOR#R6",
  "instrucciones": [
    "int.add",
    "int.cmp"
  ]
}
```

```cobertura
{
  "id": "V20",
  "regla": "LANG.CONTROL.IF#R1",
  "instrucciones": [
    "branch",
    "decide.bool"
  ]
}
```

```cobertura
{
  "id": "V21",
  "regla": "LANG.CONTROL.REPEAT#R1",
  "instrucciones": [
    "branch",
    "decide.bool"
  ]
}
```

```cobertura
{
  "id": "V22",
  "regla": "LANG.CONTROL.SWITCH#R1",
  "instrucciones": [
    "int.cmp",
    "char.cmp",
    "text.cmp",
    "bool.cmp",
    "branch",
    "decide.case",
    "decide.default",
    "decide.none"
  ]
}
```

```cobertura
{
  "id": "V23",
  "regla": "LANG.CONTROL.WHILE#R1",
  "instrucciones": [
    "branch",
    "decide.bool",
    "jump"
  ]
}
```

```cobertura
{
  "id": "V24",
  "regla": "LANG.DECL.DESIGNATOR#R1",
  "instrucciones": [
    "array.store",
    "object.store",
    "cell.element",
    "cell.field"
  ]
}
```

```cobertura
{
  "id": "V25",
  "regla": "LANG.DECL.UNINITIALIZED#R1",
  "instrucciones": [
    "value.undefined",
    "value.require",
    "cell.load"
  ]
}
```

```cobertura
{
  "id": "V26",
  "regla": "LANG.DECL.UNUSED#R1",
  "sin_ri": "Advertencias del análisis estático."
}
```

```cobertura
{
  "id": "V27",
  "regla": "LANG.DECL.VARIABLE#R1",
  "instrucciones": [
    "value.undefined"
  ]
}
```

```cobertura
{
  "id": "V28",
  "regla": "LANG.EDITION.MODEL#R1",
  "sin_ri": "Metadato del corpus sin representación en la RI."
}
```

```cobertura
{
  "id": "V29",
  "regla": "LANG.IO.INPUT#R1",
  "instrucciones": [
    "in.read"
  ]
}
```

```cobertura
{
  "id": "V30",
  "regla": "LANG.IO.OUTPUT#R1",
  "instrucciones": [
    "out.write"
  ]
}
```

```cobertura
{
  "id": "V31",
  "regla": "LANG.IO.VALUE-FORMAT#R1",
  "instrucciones": [
    "out.write",
    "text.format"
  ]
}
```

```cobertura
{
  "id": "V32",
  "regla": "LANG.LEXICAL.CHARACTER-LITERAL#R1",
  "instrucciones": [
    "const.char"
  ]
}
```

```cobertura
{
  "id": "V33",
  "regla": "LANG.LEXICAL.COMMENT#R1",
  "sin_ri": "Los comentarios no llegan a la RI."
}
```

```cobertura
{
  "id": "V34",
  "regla": "LANG.LEXICAL.ERRORS#R1",
  "sin_ri": "Un error léxico impide producir RI."
}
```

```cobertura
{
  "id": "V35",
  "regla": "LANG.LEXICAL.IDENTIFIER#R1",
  "sin_ri": "La identidad de nombres se resuelve antes de la RI."
}
```

```cobertura
{
  "id": "V36",
  "regla": "LANG.LEXICAL.KEYWORD#R1",
  "sin_ri": "Política léxica sin representación en la RI."
}
```

```cobertura
{
  "id": "V37",
  "regla": "LANG.LEXICAL.NUMBER-LITERAL#R1",
  "instrucciones": [
    "const.i64",
    "const.f64"
  ]
}
```

```cobertura
{
  "id": "V38",
  "regla": "LANG.LEXICAL.OPERATOR-TOKEN#R1",
  "sin_ri": "La tokenización precede a la RI."
}
```

```cobertura
{
  "id": "V39",
  "regla": "LANG.LEXICAL.TEXT-LITERAL#R1",
  "instrucciones": [
    "const.str",
    "const.char"
  ]
}
```

```cobertura
{
  "id": "V40",
  "regla": "LANG.LEXICAL.WHITESPACE#R1",
  "sin_ri": "La trivia no llega a la RI."
}
```

```cobertura
{
  "id": "V41",
  "regla": "LANG.OPS.ARITHMETIC#R1",
  "instrucciones": [
    "int.add",
    "int.sub",
    "int.mul",
    "int.neg",
    "real.add",
    "real.sub",
    "real.mul",
    "real.neg",
    "int.to_real"
  ]
}
```

```cobertura
{
  "id": "V42",
  "regla": "LANG.OPS.COMPARISON#R1",
  "instrucciones": [
    "int.cmp",
    "real.cmp",
    "char.cmp",
    "text.cmp",
    "bool.cmp",
    "ref.cmp",
    "int.to_real"
  ]
}
```

```cobertura
{
  "id": "V43",
  "regla": "LANG.OPS.CONCATENATION#R1",
  "instrucciones": [
    "text.concat"
  ]
}
```

```cobertura
{
  "id": "V44",
  "regla": "LANG.OPS.DIVISION#R1",
  "instrucciones": [
    "real.div",
    "int.div",
    "int.mod",
    "int.to_real"
  ]
}
```

```cobertura
{
  "id": "V45",
  "regla": "LANG.OPS.LOGICAL#R1",
  "instrucciones": [
    "bool.not",
    "branch"
  ]
}
```

```cobertura
{
  "id": "V46",
  "regla": "LANG.OPS.POWER#R1",
  "instrucciones": [
    "int.pow",
    "real.pow",
    "int.to_real"
  ]
}
```

```cobertura
{
  "id": "V47",
  "regla": "LANG.OPS.PRECEDENCE#R1",
  "sin_ri": "La agrupación se resuelve al analizar; la RI recibe expresiones ya agrupadas."
}
```

```cobertura
{
  "id": "V48",
  "regla": "LANG.PROFILE.MODEL#R1",
  "sin_ri": "Los ejes de perfil se resuelven antes de la RI; el vocabulario solo fija la representación lógica de text.format."
}
```

```cobertura
{
  "id": "V49",
  "regla": "LANG.PROFILE.STRICTNESS#R1",
  "sin_ri": "El rigor solo afecta al análisis."
}
```

```cobertura
{
  "id": "V50",
  "regla": "LANG.PROFILE.TRANSLATION#R1",
  "sin_ri": "La traducción opera sobre el texto fuente."
}
```

```cobertura
{
  "id": "V51",
  "regla": "LANG.PROFILE.VOCABULARY#R1",
  "sin_ri": "El vocabulario opera sobre el texto fuente."
}
```

```cobertura
{
  "id": "V52",
  "regla": "LANG.PROGRAM.STRUCTURE#R1",
  "sin_ri": "La estructura determina las funciones del módulo de IR.MODEL."
}
```

```cobertura
{
  "id": "V53",
  "regla": "LANG.SOURCE.ENCODING#R1",
  "sin_ri": "La decodificación precede a la RI."
}
```

```cobertura
{
  "id": "V54",
  "regla": "LANG.SOURCE.ENCODING#R2",
  "sin_ri": "La normalización de nombres precede a la RI."
}
```

```cobertura
{
  "id": "V55",
  "regla": "LANG.SOURCE.POSITION#R1",
  "sin_ri": "Los tramos llegan a la RI como datos de IR.SOURCE-MAP."
}
```

```cobertura
{
  "id": "V56",
  "regla": "LANG.STMT.ASSIGNMENT#R1",
  "instrucciones": [
    "array.store",
    "object.store",
    "cell.store"
  ]
}
```

```cobertura
{
  "id": "V57",
  "regla": "LANG.STMT.TERMINATION#R1",
  "sin_ri": "La terminación de sentencias es sintáctica."
}
```

```cobertura
{
  "id": "V58",
  "regla": "LANG.SUBPROGRAM.BY-REFERENCE#R1",
  "instrucciones": [
    "cell.local",
    "cell.element",
    "cell.field",
    "cell.load",
    "cell.store"
  ]
}
```

```cobertura
{
  "id": "V59",
  "regla": "LANG.SUBPROGRAM.CALL#R1",
  "instrucciones": [
    "call"
  ]
}
```

```cobertura
{
  "id": "V60",
  "regla": "LANG.SUBPROGRAM.DECLARATION#R1",
  "instrucciones": [
    "call",
    "return"
  ]
}
```

```cobertura
{
  "id": "V61",
  "regla": "LANG.SUBPROGRAM.INTERACTIONS#R1",
  "instrucciones": [
    "return",
    "in.read"
  ]
}
```

```cobertura
{
  "id": "V62",
  "regla": "LANG.SUBPROGRAM.PARAMETERS#R1",
  "instrucciones": [
    "call",
    "cell.local"
  ]
}
```

```cobertura
{
  "id": "V63",
  "regla": "LANG.SUBPROGRAM.RECURSION#R1",
  "instrucciones": [
    "call"
  ]
}
```

```cobertura
{
  "id": "V64",
  "regla": "LANG.SUBPROGRAM.RETURN#R1",
  "instrucciones": [
    "return",
    "trap.missing_return"
  ]
}
```

```cobertura
{
  "id": "V65",
  "regla": "LANG.SUBPROGRAM.SCOPE#R1",
  "sin_ri": "Los ámbitos se resuelven antes de la RI."
}
```

```cobertura
{
  "id": "V66",
  "regla": "LANG.SYNTAX.GRAMMAR#R1",
  "sin_ri": "La gramática precede a la RI."
}
```

```cobertura
{
  "id": "V67",
  "regla": "LANG.SYNTAX.RECOVERY#R1",
  "sin_ri": "Un programa con errores sintácticos no produce RI."
}
```

```cobertura
{
  "id": "V68",
  "regla": "LANG.SYNTAX.RECOVERY#R2",
  "sin_ri": "Un programa con errores sintácticos no produce RI."
}
```

```cobertura
{
  "id": "V69",
  "regla": "LANG.TYPES.ARRAY#R1",
  "sin_ri": "Restricciones estáticas del tipo; el acceso por elementos está cubierto por LANG.ARRAY.ACCESS."
}
```

```cobertura
{
  "id": "V70",
  "regla": "LANG.TYPES.BOOLEAN#R1",
  "instrucciones": [
    "const.bool",
    "bool.not",
    "bool.cmp",
    "text.format"
  ]
}
```

```cobertura
{
  "id": "V71",
  "regla": "LANG.TYPES.CHARACTER#R1",
  "instrucciones": [
    "const.char",
    "char.code"
  ]
}
```

```cobertura
{
  "id": "V72",
  "regla": "LANG.TYPES.CHECKING-LEVELS#R1",
  "instrucciones": [
    "int.div",
    "array.load",
    "value.require"
  ]
}
```

```cobertura
{
  "id": "V73",
  "regla": "LANG.TYPES.CLASS#R1",
  "instrucciones": [
    "ref.cmp"
  ]
}
```

```cobertura
{
  "id": "V74",
  "regla": "LANG.TYPES.INFERENCE#R1",
  "sin_ri": "La inferencia fija tipos antes de la RI."
}
```

```cobertura
{
  "id": "V75",
  "regla": "LANG.TYPES.INTEGER#R1",
  "instrucciones": [
    "const.i64",
    "text.format"
  ]
}
```

```cobertura
{
  "id": "V76",
  "regla": "LANG.TYPES.INTEGER#R2",
  "instrucciones": [
    "int.add"
  ]
}
```

```cobertura
{
  "id": "V77",
  "regla": "LANG.TYPES.INTEGER#R3",
  "instrucciones": [
    "int.add"
  ]
}
```

```cobertura
{
  "id": "V78",
  "regla": "LANG.TYPES.REAL#R1",
  "instrucciones": [
    "real.add",
    "real.sub",
    "real.mul",
    "real.div",
    "text.format"
  ]
}
```

```cobertura
{
  "id": "V79",
  "regla": "LANG.TYPES.RELATIONS#R1",
  "instrucciones": [
    "int.to_real"
  ]
}
```

```cobertura
{
  "id": "V80",
  "regla": "LANG.TYPES.TEXT#R1",
  "instrucciones": [
    "text.length",
    "text.char_at",
    "text.concat"
  ]
}
```

```cobertura
{
  "id": "V81",
  "regla": "LIB.CORE.CONVERSION#R1",
  "instrucciones": [
    "text.format",
    "text.to_integer",
    "text.to_real"
  ]
}
```

```cobertura
{
  "id": "V82",
  "regla": "LIB.CORE.COPY#R1",
  "instrucciones": [
    "object.copy"
  ]
}
```

```cobertura
{
  "id": "V83",
  "regla": "LIB.CORE.MATH#R1",
  "instrucciones": [
    "math.sqrt",
    "math.abs",
    "math.ln",
    "math.exp",
    "math.sin",
    "math.cos",
    "math.atan",
    "int.to_real"
  ]
}
```

```cobertura
{
  "id": "V84",
  "regla": "LIB.CORE.RANDOM#R1",
  "instrucciones": [
    "host.random"
  ]
}
```

```cobertura
{
  "id": "V85",
  "regla": "LIB.CORE.ROUNDING#R1",
  "instrucciones": [
    "real.trunc",
    "real.round",
    "int.to_real"
  ]
}
```

```cobertura
{
  "id": "V86",
  "regla": "LIB.CORE.TEXT#R1",
  "instrucciones": [
    "text.length",
    "text.char_at",
    "char.code",
    "char.from_code"
  ]
}
```

```cobertura
{
  "id": "V87",
  "regla": "LIB.MODEL#R1",
  "sin_ri": "Nombres y firmas estáticos; cada función incorporada tiene instrucción propia en las coberturas de LIB.CORE."
}
```

```cobertura
{
  "id": "V88",
  "regla": "LANG.MODULE.MODEL#R1",
  "sin_ri": "La pertenencia de módulos a paquetes se resuelve antes de la RI; la RI recibe un único módulo enlazado."
}
```

```cobertura
{
  "id": "V89",
  "regla": "LANG.MODULE.MODEL#R2",
  "sin_ri": "La selección de entrada y la presencia de algoritmos se validan antes de la RI."
}
```

```cobertura
{
  "id": "V90",
  "regla": "LANG.MODULE.MODEL#R3",
  "sin_ri": "Diagnóstico de análisis sobre formas que no llegan a la RI."
}
```

```cobertura
{
  "id": "V91",
  "regla": "LANG.MODULE.IMPORT#R1",
  "sin_ri": "Los imports se resuelven por identidad antes de la RI; la RI contiene llamadas directas a la función importada."
}
```

```cobertura
{
  "id": "V92",
  "regla": "LANG.MODULE.IMPORT#R2",
  "sin_ri": "La visibilidad es una comprobación estática previa a la RI."
}
```

```cobertura
{
  "id": "V93",
  "regla": "LANG.MODULE.IMPORT#R3",
  "sin_ri": "Las colisiones de nombres se diagnostican antes de la RI."
}
```

```cobertura
{
  "id": "V94",
  "regla": "LANG.MODULE.IMPORT#R4",
  "sin_ri": "Las exportaciones y reexportaciones son una tabla estática de símbolos sin representación en la RI."
}
```

```cobertura
{
  "id": "V95",
  "regla": "LANG.MODULE.IMPORT#R5",
  "sin_ri": "Importar no genera instrucciones: la RI no contiene código de inicialización de módulo."
}
```

```cobertura
{
  "id": "V96",
  "regla": "LANG.MODULE.IMPORT#R6",
  "sin_ri": "Los ciclos de importación se rechazan antes de la RI: un grafo cíclico no produce programa."
}
```

```cobertura
{
  "id": "V97",
  "regla": "LANG.MODULE.MODEL#R4",
  "sin_ri": "Los ciclos de paquetes se rechazan al construir el proyecto, antes de cualquier análisis y de la RI."
}
```

```cobertura
{
  "id": "V98",
  "regla": "LANG.MODULE.IMPORT#R7",
  "sin_ri": "El alias obligatorio de un nombre reservado se exige al enlazar, antes de la RI: un símbolo importado se referencia por identidad y no por su lexema."
}
```

```cobertura
{
  "id": "V99",
  "regla": "LANG.PROFILE.MODEL#R2",
  "sin_ri": "El perfil de cada archivo se resuelve antes de la RI; la tabla de perfiles por fuente solo fija la representación lógica de text.format y out.write."
}
```

```cobertura
{
  "id": "V100",
  "regla": "LANG.CONTROL.SWITCH#R2",
  "instrucciones": [
    "int.cmp",
    "branch",
    "decide.case",
    "decide.default",
    "decide.none"
  ]
}
```

```cobertura
{
  "id": "V101",
  "regla": "LANG.DECL.CONSTANT#R1",
  "sin_ri": "El valor de la constante se calcula al analizar y se emite como constante de la RI; no existe variable en ejecución."
}
```

```cobertura
{
  "id": "V102",
  "regla": "LANG.DECL.CONSTANT#R2",
  "sin_ri": "El subconjunto evaluable se resuelve antes de la RI."
}
```

```cobertura
{
  "id": "V103",
  "regla": "LANG.DECL.CONSTANT#R3",
  "sin_ri": "Los ciclos y el presupuesto se comprueban antes de la RI."
}
```

```cobertura
{
  "id": "V104",
  "regla": "LANG.DECL.CONSTANT#R4",
  "sin_ri": "La forma y el tipo del inicializador se comprueban antes de la RI."
}
```

```cobertura
{
  "id": "V105",
  "regla": "LANG.TYPES.ENUM#R1",
  "sin_ri": "El enumerado define ordinales enteros que la RI trata como enteros; la declaración es estática."
}
```

```cobertura
{
  "id": "V106",
  "regla": "LANG.TYPES.ENUM#R2",
  "instrucciones": [
    "int.cmp",
    "const.str",
    "out.write",
    "branch",
    "value.undefined",
    "value.require"
  ]
}
```

```cobertura
{
  "id": "V107",
  "regla": "LANG.TYPES.ENUM#R3",
  "sin_ri": "Los miembros y nombres de tipo se resuelven antes de la RI."
}
```

```cobertura
{
  "id": "V108",
  "regla": "LANG.TYPES.RECORD#R1",
  "sin_ri": "La declaración, la contención y los límites del registro se comprueban antes de la RI, que lo aplana en valores."
}
```

```cobertura
{
  "id": "V109",
  "regla": "LANG.TYPES.RECORD#R2",
  "sin_ri": "La construcción y el acceso a campos se resuelven antes de la RI, que opera sobre un valor por campo."
}
```

```cobertura
{
  "id": "V110",
  "regla": "LANG.TYPES.RECORD#R3",
  "instrucciones": [
    "call",
    "return",
    "cell.local",
    "cell.store",
    "cell.load",
    "value.undefined",
    "value.require"
  ]
}
```

```cobertura
{
  "id": "V111",
  "regla": "LANG.TYPES.RECORD#R4",
  "instrucciones": [
    "int.cmp",
    "real.cmp",
    "bool.cmp",
    "char.cmp",
    "text.cmp",
    "ref.cmp",
    "branch"
  ]
}
```

```instruccion
{
  "id": "O75",
  "nombre": "value.reinterpret",
  "firma": "value.reinterpret <tipo>, %v -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Reinterpreta bits entre tipos del mismo banco sin conversión numérica; escalar hacia o desde i64, referencia hacia o desde str. No fabrica un valor del lenguaje y no cambia los bits. Se usa en la unión de variantes; las cargas activas se comprueban antes de empaquetarlas.",
  "trampas": [],
  "efectos": [],
  "observacion": []
}
```

```instruccion
{
  "id": "O76",
  "nombre": "cell.load_raw",
  "firma": "cell.load_raw %cell -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee la palabra de una celda local de transporte sin rechazar un centinela de referencia inactiva. Una celda administrada conserva la comprobación normal. No es una extracción del lenguaje ni elude la comprobación de una carga activa.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O77",
  "nombre": "switch",
  "firma": "switch %selector, <defecto>, { <ordinal>, <destino> }",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Termina el bloque seleccionando por entero una arista, o la arista de defecto. Los ordinales son distintos, crecientes, no negativos y menores de 65536. Cada destino conserva los argumentos de bloque. No ejecuta efectos de otra rama.",
  "trampas": [],
  "efectos": [
    "control"
  ],
  "observacion": []
}
```

```cobertura
{
  "id": "V112",
  "regla": "LANG.TYPES.RELATIONS#R2",
  "instrucciones": [
    "value.reinterpret",
    "cell.load_raw",
    "branch",
    "return"
  ]
}
```

```cobertura
{
  "id": "V113",
  "regla": "LANG.TYPES.RELATIONS#R3",
  "instrucciones": [
    "value.reinterpret",
    "cell.load_raw",
    "branch",
    "return"
  ]
}
```

```cobertura
{
  "id": "V114",
  "regla": "LANG.TYPES.RELATIONS#R4",
  "instrucciones": [
    "value.reinterpret",
    "cell.load_raw",
    "branch",
    "return"
  ]
}
```

```cobertura
{
  "id": "V115",
  "regla": "LANG.TYPES.RELATIONS#R5",
  "instrucciones": [
    "call",
    "return"
  ]
}
```

```instruccion
{
  "id": "O78",
  "nombre": "call.indirect",
  "firma": "call.indirect %code: i64, @prototype(%a...) -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Selecciona una función de la tabla de código por identidad u32 y llama con el entorno como primer argumento. La firma debe coincidir con la del prototipo; un destino ausente o incompatible es invalidFunctionReference. La identidad de código no es una dirección.",
  "trampas": [
    "recursionDepthExceeded",
    "invalidFunctionReference"
  ],
  "efectos": [
    "llamada"
  ],
  "observacion": [
    "call",
    "return"
  ]
}
```

```cobertura
{
  "id": "V116",
  "regla": "LANG.TYPES.FUNCTION#R1",
  "instrucciones": [
    "call.indirect"
  ]
}
```

```cobertura
{
  "id": "V117",
  "regla": "LANG.TYPES.GENERIC#R1",
  "sin_ri": "Los parámetros de tipo, la inferencia y las instancias se resuelven antes de la RI, que recibe una función o un registro concreto por instancia."
}
```

```instruccion
{
  "id": "O79",
  "nombre": "object.load_raw",
  "firma": "object.load_raw %o: obj<C>, field -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee los bits de un campo de un entorno tipado sin interpretar centinelas inactivos. El receptor y campo deben existir. El acceso ordinario a campos sigue usando object.load y conserva la comprobación de definición.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O80",
  "nombre": "collection.new",
  "firma": "collection.new obj<C> -> obj<C>",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Crea una colección vacía con disposición declarada y cabecera estable.",
  "trampas": [
    "cellLimitExceeded",
    "collectionLimitExceeded"
  ],
  "efectos": [
    "asigna",
    "escribe_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O81",
  "nombre": "collection.length",
  "firma": "collection.length %collection -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee la cantidad de elementos o entradas activas.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O82",
  "nombre": "collection.version",
  "firma": "collection.version %collection -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee la versión estructural u32 sin modificarla.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O83",
  "nombre": "collection.check",
  "firma": "collection.check %collection, %version -> unit",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Comprueba la versión inicial y atrapa si cambió.",
  "trampas": [
    "uninitializedVariableRead",
    "collectionModifiedDuringIteration"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O84",
  "nombre": "collection.lookup",
  "firma": "collection.lookup %dictionary, %key -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Devuelve la posición física de la clave o -1 si está ausente.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O85",
  "nombre": "collection.load",
  "firma": "collection.load T, %collection, %position, leaf -> T",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee una hoja de elemento usando su banco declarado; no interpreta centinelas inactivos.",
  "trampas": [
    "uninitializedVariableRead",
    "arrayIndexOutOfRange",
    "missingDictionaryKey"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O86",
  "nombre": "collection.store",
  "firma": "collection.store %collection, %key, %leaves... -> unit",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Reemplaza un elemento de vector o inserta/reemplaza una entrada de diccionario; consume todas las hojas de una vez.",
  "trampas": [
    "uninitializedVariableRead",
    "arrayIndexOutOfRange",
    "cellLimitExceeded",
    "collectionLimitExceeded",
    "collectionVersionExhausted"
  ],
  "efectos": [
    "lee_memoria",
    "escribe_memoria",
    "asigna"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O87",
  "nombre": "collection.insert",
  "firma": "collection.insert %vector, %position, %leaves... -> unit",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Inserta un elemento completo en el vector con crecimiento comprobado.",
  "trampas": [
    "uninitializedVariableRead",
    "arrayIndexOutOfRange",
    "cellLimitExceeded",
    "collectionLimitExceeded",
    "collectionVersionExhausted"
  ],
  "efectos": [
    "lee_memoria",
    "escribe_memoria",
    "asigna"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O88",
  "nombre": "collection.remove",
  "firma": "collection.remove %collection, %key -> unit",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Elimina un elemento o clave; una clave ausente no modifica el diccionario.",
  "trampas": [
    "uninitializedVariableRead",
    "arrayIndexOutOfRange",
    "collectionVersionExhausted"
  ],
  "efectos": [
    "lee_memoria",
    "escribe_memoria",
    "asigna"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O89",
  "nombre": "collection.next",
  "firma": "collection.next %dictionary, %cursor -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Busca la siguiente posición física activa desde cursor, o -1 al terminar.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O90",
  "nombre": "collection.key",
  "firma": "collection.key %dictionary, %position -> K",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee la clave tipada de una posición física activa.",
  "trampas": [
    "uninitializedVariableRead",
    "missingDictionaryKey"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O91",
  "nombre": "array.length",
  "firma": "array.length %array -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Lee la longitud de un arreglo unidimensional.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "lee_memoria"
  ],
  "observacion": []
}
```

```cobertura
{
  "id": "V118",
  "regla": "LANG.TYPES.INTERFACE#R1",
  "instrucciones": [
    "call",
    "call.virtual"
  ]
}
```

```cobertura
{
  "id": "V119",
  "regla": "LANG.TYPES.INTERFACE#R2",
  "instrucciones": [
    "call",
    "call.virtual"
  ]
}
```

```cobertura
{
  "id": "V120",
  "regla": "LANG.TYPES.INTERFACE#R3",
  "instrucciones": [
    "call",
    "call.virtual"
  ]
}
```

```cobertura
{
  "id": "V121",
  "regla": "LANG.TYPES.VECTOR#R1",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V122",
  "regla": "LANG.TYPES.VECTOR#R2",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V123",
  "regla": "LANG.TYPES.VECTOR#R3",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V124",
  "regla": "LANG.TYPES.DICTIONARY#R1",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V125",
  "regla": "LANG.TYPES.DICTIONARY#R2",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V126",
  "regla": "LANG.TYPES.DICTIONARY#R3",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V127",
  "regla": "LANG.CONTROL.FOR-EACH#R1",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V128",
  "regla": "LANG.CONTROL.FOR-EACH#R2",
  "instrucciones": [
    "collection.new",
    "collection.length",
    "collection.version",
    "collection.check",
    "collection.lookup",
    "collection.load",
    "collection.store",
    "collection.insert",
    "collection.remove",
    "collection.next",
    "collection.key",
    "array.length"
  ]
}
```

```cobertura
{
  "id": "V129",
  "regla": "LANG.CONTROL.EXIT#R1",
  "instrucciones": [
    "jump",
    "branch",
    "return"
  ]
}
```

```cobertura
{
  "id": "V130",
  "regla": "LANG.CONTROL.CLEANUP#R1",
  "instrucciones": [
    "jump",
    "branch",
    "return"
  ]
}
```

```cobertura
{
  "id": "V131",
  "regla": "LANG.CONTROL.CLEANUP#R2",
  "instrucciones": [
    "jump",
    "branch",
    "return",
    "effect_call"
  ]
}
```

```instruccion
{
  "id": "O92",
  "nombre": "text.quote",
  "firma": "text.quote %text: str -> str",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Delimita un texto con comillas dobles y escapa comillas, barra inversa y caracteres de control sin normalizar Unicode.",
  "trampas": [
    "uninitializedVariableRead",
    "cellLimitExceeded"
  ],
  "efectos": [
    "asigna"
  ],
  "observacion": []
}
```

```cobertura
{
  "id": "V132",
  "regla": "LANG.CAPABILITY.MODEL#R1",
  "sin_ri": "Los tipos de capacidad se representan como referencias opacas en el banco de referencias."
}
```

```cobertura
{
  "id": "V133",
  "regla": "LANG.CAPABILITY.MODEL#R2",
  "sin_ri": "La denegación por defecto y la autoridad de capacidades se resuelven en el anfitrión."
}
```

```cobertura
{
  "id": "V134",
  "regla": "LANG.CAPABILITY.MODEL#R3",
  "sin_ri": "La comprobación de no amplificación y confinamiento se aplica en la tabla de capacidades."
}
```

```cobertura
{
  "id": "V135",
  "regla": "LANG.CAPABILITY.MODEL#R4",
  "sin_ri": "La invalidación por cierre y conteo generacional opera en el runtime de capacidades."
}
```

```instruccion
{
  "id": "O93",
  "nombre": "effect_call",
  "firma": "effect_call %cap: ref, <operacion>, <tipo>, n<nodo>, %arg..., %celda... -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Despacha una operación sobre una capacidad o sobre Bytes identificando la operación, el tipo de carga útil y el nodo fuente, escribe el resultado o la variante Resultado<T, ErrorES> en las celdas de salida (una celda tipada si es infalible o tres celdas canónicas i64, i64, str si es falible), registra el efecto en la cinta cuando corresponde y suspende en awaiting_effect si el anfitrión opera en modo desacoplado.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "llamada"
  ],
  "observacion": [
    "call",
    "return"
  ]
}
```

```instruccion
{
  "id": "O94",
  "nombre": "task.scope_open",
  "firma": "task.scope_open -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Crea un ámbito de tareas cuyo dueño es la tarea actual y devuelve su identidad. Un ámbito vacío puede unirse sin suspender.",
  "trampas": [
    "taskLimitExceeded"
  ],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O95",
  "nombre": "task.spawn",
  "firma": "task.spawn %scope: i64, @funcion(%arg...): tipo -> i64",
  "clases_de_valor": [
    "escalar"
  ],
  "semantica": "Evalúa antes sus argumentos en el padre, crea una hija lista en el ámbito indicado sin ceder la ejecución y devuelve el asa local de la tarea.",
  "trampas": [
    "taskLimitExceeded",
    "uninitializedVariableRead"
  ],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O96",
  "nombre": "task.await",
  "firma": "task.await %task: i64, <tipo> -> tipo | i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Devuelve el resultado exitoso de la tarea indicada. Si aún no terminó, suspende solo a la tarea actual; una segunda espera devuelve el resultado ya conservado. El tipo unit selecciona el transporte de un resultado compuesto: devuelve un estado i64 y prepara sus hojas para task.value_load.",
  "trampas": [
    "uninitializedVariableRead",
    "taskDeadlock"
  ],
  "efectos": [
    "suspension"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O97",
  "nombre": "task.scope_join",
  "firma": "task.scope_join %scope: i64 -> unit",
  "clases_de_valor": [],
  "semantica": "Une todas las hijas del ámbito. Si quedan hijas vivas, suspende solo a la tarea actual hasta que terminen o el primer fallo solicite cancelación.",
  "trampas": [
    "taskDeadlock"
  ],
  "efectos": [
    "suspension"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O98",
  "nombre": "call.suspendible",
  "firma": "call.suspendible @funcion(%arg...) -> tipo",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Invoca una unidad suspendible dentro de la misma tarea y conserva su continuación si la unidad suspende.",
  "trampas": [
    "recursionDepthExceeded",
    "uninitializedVariableRead"
  ],
  "efectos": [
    "llamada",
    "suspension"
  ],
  "observacion": [
    "call",
    "return"
  ]
}
```

```instruccion
{
  "id": "O99",
  "nombre": "effect.await",
  "firma": "effect.await %cap: ref, <operacion>, <tipo>, n<nodo>, %arg..., %celda... -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Solicita un efecto concurrente para la tarea actual. La tarea queda suspendida mientras las demás tareas listas continúan; la máquina solo sale hacia el anfitrión cuando la agenda está ociosa.",
  "trampas": [
    "uninitializedVariableRead"
  ],
  "efectos": [
    "suspension",
    "llamada"
  ],
  "observacion": [
    "call"
  ]
}
```

```instruccion
{
  "id": "O100",
  "nombre": "task.yield_check",
  "firma": "task.yield_check",
  "clases_de_valor": [],
  "semantica": "En una arista de retorno de bucle de una unidad suspendible, cede si la masa acumulada alcanzó el cuanto y hay otra tarea lista; de lo contrario continúa sin cambio de estado.",
  "trampas": [],
  "efectos": [
    "suspension"
  ],
  "observacion": []
}
```

```cobertura
{
  "id": "V136",
  "regla": "LIB.IO#R1",
  "sin_ri": "La representación y gestión de Bytes en el montón opera a través de las celdas administradas."
}
```

```cobertura
{
  "id": "V137",
  "regla": "LIB.IO#R2",
  "sin_ri": "Los errores de E/S se modelan como variantes de Resultado en tiempo de ejecución."
}
```

```cobertura
{
  "id": "V138",
  "regla": "LANG.CAPABILITY.PURITY#R1",
  "sin_ri": "La pureza de funciones se verifica estáticamente en el análisis semántico."
}
```

```cobertura
{
  "id": "V139",
  "regla": "LANG.CAPABILITY.PURITY#R2",
  "sin_ri": "El cálculo de pureza transitiva sobre el grafo de llamadas opera estáticamente en el análisis semántico."
}
```

```cobertura
{
  "id": "V140",
  "regla": "LANG.CAPABILITY.PURITY#R3",
  "sin_ri": "La verificación de tipos de función pura para clausuras y argumentos se valida en compilación."
}
```

```cobertura
{
  "id": "V141",
  "regla": "LANG.CAPABILITY.PURITY#R4",
  "sin_ri": "La coherencia de pureza en realizaciones de interfaz se comprueba en el verificador de interfaces."
}
```

```cobertura
{
  "id": "V142",
  "regla": "LANG.CAPABILITY.PURITY#R5",
  "sin_ri": "La asignación de permisos de efectos a subprocesos y algoritmos opera en el verificador semántico."
}
```

```cobertura
{
  "id": "V143",
  "regla": "LIB.IO#R3",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V144",
  "regla": "LIB.IO#R4",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V145",
  "regla": "LIB.TIME#R1",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V146",
  "regla": "LIB.TIME#R2",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V147",
  "regla": "LANG.CAPABILITY.PURITY#R6",
  "sin_ri": "El rechazo de Aguardar en una Funcion se determina durante el análisis semántico."
}
```

```cobertura
{
  "id": "V148",
  "regla": "LANG.TASK.SUSPENSION#R1",
  "sin_ri": "La marca suspendible se registra en HIR y no crea una instrucción de la RI."
}
```

```cobertura
{
  "id": "V149",
  "regla": "LANG.TASK.SUSPENSION#R2",
  "sin_ri": "La prohibición de usar una unidad suspendible como valor se verifica durante el análisis semántico."
}
```

```cobertura
{
  "id": "V150",
  "regla": "LANG.TASK.SUSPENSION#R3",
  "sin_ri": "El ámbito suspendible y la prioridad del bloque Diferir se verifican antes del lowering."
}
```

```cobertura
{
  "id": "V151",
  "regla": "LANG.TASK.SUSPENSION#R4",
  "sin_ri": "La validez del operando de Aguardar se comprueba en análisis semántico."
}
```

```cobertura
{
  "id": "V152",
  "regla": "LANG.TASK.SUSPENSION#R5",
  "sin_ri": "La cobertura inmediata de llamadas suspendibles se determina durante el análisis semántico."
}
```

```cobertura
{
  "id": "V153",
  "regla": "LANG.TASK.SUSPENSION#R6",
  "instrucciones": [
    "call.suspendible",
    "task.await",
    "effect.await"
  ]
}
```

```cobertura
{
  "id": "V154",
  "regla": "LANG.TASK.SUSPENSION#R7",
  "sin_ri": "La profundidad de llamadas se restringe por el análisis y el límite de ejecución, no por una instrucción nueva."
}
```

```cobertura
{
  "id": "V155",
  "regla": "LANG.TASK.SUSPENSION#R8",
  "sin_ri": "El anfitrión resuelve la operación síncrona y Aguardar conserva su valor sin transición pendiente."
}
```

```cobertura
{
  "id": "V156",
  "regla": "LANG.TASK.SCOPE#R1",
  "sin_ri": "La pertenencia léxica de Lanzar y las prohibiciones de Diferir se comprueban antes del lowering."
}
```

```cobertura
{
  "id": "V157",
  "regla": "LANG.TASK.SCOPE#R2",
  "sin_ri": "El destino, los modos de parámetros y la transferibilidad se validan durante el análisis semántico."
}
```

```cobertura
{
  "id": "V158",
  "regla": "LANG.TASK.SCOPE#R3",
  "sin_ri": "El tipo de retorno del asa y la obligación de conservar errores se determinan en el análisis semántico."
}
```

```cobertura
{
  "id": "V159",
  "regla": "LANG.TASK.SCOPE#R4",
  "sin_ri": "El uso local permitido de un asa se impone durante el análisis semántico."
}
```

```cobertura
{
  "id": "V160",
  "regla": "LANG.TASK.SCOPE#R5",
  "instrucciones": [
    "task.scope_open",
    "task.spawn",
    "task.await",
    "task.scope_join"
  ]
}
```

```cobertura
{
  "id": "V161",
  "regla": "LANG.TASK.SCOPE#R6",
  "instrucciones": [
    "task.scope_join",
    "effect.await",
    "task.yield_check"
  ]
}
```

```cobertura
{
  "id": "V162",
  "regla": "LANG.TASK.SCOPE#R7",
  "sin_ri": "La prohibición de suspender o lanzar desde Diferir se aplica en el análisis semántico."
}
```

```cobertura
{
  "id": "V163",
  "regla": "LANG.TASK.SCOPE#R8",
  "instrucciones": [
    "effect.await"
  ]
}
```

```cobertura
{
  "id": "V164",
  "regla": "LANG.TASK.SCOPE#R9",
  "sin_ri": "La cancelación del anfitrión conserva el flujo de terminación existente, fuera de instrucciones de la RI."
}
```

```cobertura
{
  "id": "V165",
  "regla": "LANG.TASK.SCOPE#R10",
  "sin_ri": "Las trampas terminan la ejecución mediante la política existente de la máquina virtual."
}
```

```cobertura
{
  "id": "V166",
  "regla": "LANG.TASK.SCOPE#R11",
  "instrucciones": [
    "task.outcome"
  ]
}
```

```cobertura
{
  "id": "V167",
  "regla": "LANG.TASK.SCOPE#R12",
  "instrucciones": [
    "task.outcome",
    "task.cancel_point",
    "task.scope_boundary"
  ]
}
```

```cobertura
{
  "id": "V168",
  "regla": "LANG.TASK.SCOPE#R13",
  "instrucciones": [
    "task.outcome",
    "task.scope_result"
  ]
}
```

```cobertura
{
  "id": "V169",
  "regla": "LANG.TASK.SCOPE#R14",
  "sin_ri": "La política se aplica mediante operaciones de tarea y datos compartidos del runtime; la comprobación estática precede a la ejecución."
}
```

```cobertura
{
  "id": "V170",
  "regla": "LANG.TASK.SCOPE#R15",
  "instrucciones": [
    "task.scope_result",
    "task.value_load"
  ]
}
```

```cobertura
{
  "id": "V171",
  "regla": "LANG.TASK.SCOPE#R16",
  "sin_ri": "La política se aplica mediante operaciones de tarea y datos compartidos del runtime; la comprobación estática precede a la ejecución."
}
```

```cobertura
{
  "id": "V172",
  "regla": "LANG.TASK.CHANNEL#R1",
  "sin_ri": "La política se aplica mediante operaciones de tarea y datos compartidos del runtime; la comprobación estática precede a la ejecución."
}
```

```cobertura
{
  "id": "V173",
  "regla": "LANG.TASK.CHANNEL#R2",
  "instrucciones": [
    "task.channel"
  ]
}
```

```cobertura
{
  "id": "V174",
  "regla": "LANG.TASK.CHANNEL#R3",
  "instrucciones": [
    "task.channel"
  ]
}
```

```cobertura
{
  "id": "V175",
  "regla": "LANG.TASK.CHANNEL#R4",
  "instrucciones": [
    "task.channel",
    "task.value_load"
  ]
}
```

```cobertura
{
  "id": "V176",
  "regla": "LANG.TASK.CHANNEL#R5",
  "instrucciones": [
    "task.channel"
  ]
}
```

```cobertura
{
  "id": "V177",
  "regla": "LANG.TASK.CHANNEL#R6",
  "sin_ri": "La política se aplica mediante operaciones de tarea y datos compartidos del runtime; la comprobación estática precede a la ejecución."
}
```

```cobertura
{
  "id": "V178",
  "regla": "LANG.TASK.CHANNEL#R7",
  "instrucciones": [
    "task.channel",
    "task.value_load",
    "switch"
  ]
}
```

```cobertura
{
  "id": "V179",
  "regla": "LANG.TASK.CHANNEL#R8",
  "instrucciones": [
    "stmt.enter",
    "decide.case",
    "stmt.exit"
  ]
}
```


```instruccion
{
  "id": "O101",
  "nombre": "task.channel",
  "firma": "task.channel <comando>, <tipo>, %arg... -> tipo",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Opera un canal acotado o una elección, con suspensión cooperativa y resultado por tarea.",
  "trampas": [
    "channelCapacityInvalid",
    "channelCapacityExceeded",
    "taskDeadlock",
    "cellLimitExceeded"
  ],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O102",
  "nombre": "task.value_load",
  "firma": "task.value_load <tipo>, <indice> -> tipo",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Carga una hoja del último resultado de tarea o valor recibido por la tarea actual, con cero ausente si no hubo valor.",
  "trampas": [],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O103",
  "nombre": "task.outcome",
  "firma": "task.outcome <desenlace>, %hoja... -> unit",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Conserva el resultado exitoso o el error transferible de una tarea hija antes de su retorno.",
  "trampas": [],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O104",
  "nombre": "task.scope_result",
  "firma": "task.scope_result %scope: i64, <tipo> -> i64",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Después de la unión, prepara el agregado de fallos del ámbito y devuelve presencia.",
  "trampas": [
    "cellLimitExceeded"
  ],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O105",
  "nombre": "task.cancel_point",
  "firma": "task.cancel_point ^limpieza -> unit",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Registra la continuación de limpieza cooperativa del marco actual.",
  "trampas": [],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O106",
  "nombre": "task.scope_boundary",
  "firma": "task.scope_boundary %scope: i64, ^union -> unit",
  "clases_de_valor": [
    "escalar",
    "referencia"
  ],
  "semantica": "Registra la salida cooperativa del cuerpo de un ámbito en su marco dueño.",
  "trampas": [],
  "efectos": [
    "tarea"
  ],
  "observacion": []
}
```

```instruccion
{
  "id": "O107",
  "nombre": "snapshot.copy",
  "firma": "snapshot.copy <count>, %sources..., %destination_cells... -> unit",
  "clases_de_valor": [
    "referencia"
  ],
  "semantica": "Copia el grafo conjunto de las fuentes referenciales preservando alias y ciclos. Guarda cada resultado en una celda del mismo tipo. La cantidad es positiva y el número de fuentes coincide con el de celdas. Comparte cadenas, canales y capacidades.",
  "trampas": [
    "cellLimitExceeded"
  ],
  "efectos": [
    "asigna", "lee_memoria", "escribe_memoria"
  ],
  "observacion": []
}
```



```cobertura
{
  "id": "V181",
  "regla": "LIB.MODEL#M1",
  "sin_ri": "La consistencia de identidad y facetas se verifica sobre recursos generados por el corpus."
}
```

```cobertura
{
  "id": "V182",
  "regla": "LIB.MODEL#M2",
  "sin_ri": "La consistencia de identidad y facetas se verifica sobre recursos generados por el corpus."
}
```

```cobertura
{
  "id": "V183",
  "regla": "LIB.MODEL#M3",
  "sin_ri": "La consistencia de identidad y facetas se verifica sobre recursos generados por el corpus."
}
```

```cobertura
{
  "id": "V184",
  "regla": "LIB.MODEL#M4",
  "sin_ri": "La consistencia de identidad y facetas se verifica sobre recursos generados por el corpus."
}
```

```cobertura
{
  "id": "V185",
  "regla": "LIB.CORE.TEXT#T1",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V186",
  "regla": "LIB.CORE.TEXT#T2",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V187",
  "regla": "LIB.CORE.TEXT#T3",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V188",
  "regla": "LIB.CORE.BYTES#B1",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V189",
  "regla": "LIB.CORE.BYTES#B2",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V190",
  "regla": "LIB.JSON#J1",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V191",
  "regla": "LIB.JSON#J2",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V192",
  "regla": "LIB.JSON#J3",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V193",
  "regla": "LIB.JSON#J4",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V194",
  "regla": "LIB.JSON#J5",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V195",
  "regla": "LIB.JSON#J6",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V196",
  "regla": "LIB.JSON#J7",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V197",
  "regla": "LIB.JSON#J8",
  "instrucciones": [
    "effect_call"
  ]
}
```

```cobertura
{
  "id": "V198",
  "regla": "LIB.HTTP#R1",
  "instrucciones": ["effect_call"]
}
```

```cobertura
{
  "id": "V199",
  "regla": "LIB.HTTP#R2",
  "instrucciones": ["effect_call"]
}
```

```cobertura
{
  "id": "V200",
  "regla": "LIB.HTTP#R3",
  "instrucciones": ["effect_call"]
}
```

```cobertura
{
  "id": "V201",
  "regla": "LIB.HTTP#R4",
  "instrucciones": ["effect_call"]
}
```

```cobertura
{
  "id": "V202",
  "regla": "LIB.HTTP#R5",
  "instrucciones": ["effect_call"]
}
```

```cobertura
{
  "id": "V203",
  "regla": "LIB.HTTP#R6",
  "instrucciones": ["effect_call"]
}
```
