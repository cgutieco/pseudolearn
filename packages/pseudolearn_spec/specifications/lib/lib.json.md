---
formato: see/1
id: LIB.JSON
titulo: Valores JSON
dominio: biblioteca
estado: estable
version: "1.0.0"
duenos:
- responsable-lenguaje
sujetos:
- engine
- aot
resumen: Análisis, consulta, construcción y serialización de JSON.
titulo_en: JSON values
edicion:
  introducida_en: "2027"
depende_de:
- id: LIB.MODEL
  version: ">=1.0.0, <2.0.0"
  tipo: requiere
- id: ENG.LIMITS
  version: ">=1.0.0, <2.0.0"
  tipo: requiere
- id: LANG.SOURCE.POSITION
  version: ">=1.0.0, <2.0.0"
  tipo: requiere
- id: DIAG.CATALOG
  version: ">=1.0.0, <2.0.0"
  tipo: usa
revisado_por:
- César Antonio Gutiérrez Contreras
---

# Valores JSON

```regla
{
  "id": "J1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "AnalizarJson acepta exactamente un valor JSON estricto con espacios U+0020, U+0009, U+000A y U+000D. No acepta BOM, comentarios, comas finales, NaN ni Infinity. Admite los escapes JSON y pares sustitutos válidos; rechaza sustitutos sueltos con EscapeInvalido. Una cadena JSON con un par sustituto válido produce el escalar Unicode correspondiente.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C6",
    "C7",
    "C8",
    "C9",
    "C17",
    "C18",
    "C19",
    "C20",
    "C21",
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29",
    "C30",
    "C31",
    "C32",
    "C33",
    "C34",
    "C35",
    "C36",
    "C37",
    "C38"
  ]
}
```

```regla
{
  "id": "J2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las claves repetidas dentro del mismo objeto producen ClaveDuplicada. La comparación es exacta por puntos de código y no aplica NFC.",
  "verificacion": [
    "C5"
  ]
}
```

```regla
{
  "id": "J3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La profundidad de contenedores JSON se limita por max_json_depth del anfitrión; cada arreglo u objeto cuenta un nivel y el valor raíz contenedor es el nivel uno. El límite es inclusivo. Al superarlo, AnalizarJson devuelve ProfundidadExcedida sin recursión del anfitrión.",
  "verificacion": [
    "C10",
    "C11"
  ]
}
```

```regla
{
  "id": "J4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "AnalizarJson devuelve el primer error en orden de lectura con línea y columna desde uno, según LANG.SOURCE.POSITION: la columna cuenta puntos de código Unicode, no bytes. La posición es la del carácter donde se detecta el error; para FinInesperado es el final del texto, inmediatamente después de su último carácter, de modo que el texto vacío informa 1:1 y un texto de una línea con n puntos de código informa 1:n+1.",
  "verificacion": [
    "C12",
    "C41",
    "C42"
  ]
}
```

```regla
{
  "id": "J5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los números JSON conservan su texto de origen. ComoEntero devuelve Algo solo si el texto no tiene fracción ni exponente y cabe en Entero. ComoReal devuelve el binario64 correctamente redondeado o Nada si no es finito. Las conversiones a un tipo distinto del contenido devuelven Nada.",
  "verificacion": [
    "C4",
    "C15"
  ]
}
```

```regla
{
  "id": "J6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Campo busca una clave exacta. Elemento usa índices desde cero y devuelve Nada si el receptor no es un arreglo o el índice está fuera de rango. Claves devuelve las claves de un objeto en su orden original. Longitud devuelve la cantidad de elementos de un arreglo o de campos de un objeto, y 0 para null, lógicos, números y cadenas JSON: no cuenta los caracteres de una cadena. ConCampo reemplaza en su posición original una clave existente y añade una nueva al final. ConElemento añade al final de un arreglo. ConElemento y ConCampo sobre un tipo JSON incorrecto atrapan con jsonKindMismatch.",
  "verificacion": [
    "C13",
    "C14",
    "C15",
    "C43"
  ]
}
```

```regla
{
  "id": "J7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "TextoJson produce JSON compacto, conserva el orden de las claves y el texto de los números originales, y usa los escapes mínimos definidos por el formato. Para cada valor JSON válido d, AnalizarJson(TextoJson(d)) reconstruye el mismo valor.",
  "verificacion": [
    "C1",
    "C3",
    "C4",
    "C13",
    "P1"
  ]
}
```

```regla
{
  "id": "J8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "ValorJson, TipoJson, ErrorJson y CodigoErrorJson son valores inmutables y transferibles. No se define igualdad estructural para ValorJson en esta edición; TextoJson permite comparar sus representaciones. Los valores de TipoJson y CodigoErrorJson se obtienen con Tipo() y con el campo Codigo de un ErrorJson: sus nombres no son palabras reservadas, el programa no los escribe como expresiones y Escribir muestra el nombre del perfil. Dos valores del mismo de esos tipos admiten igualdad y desigualdad.",
  "verificacion": [
    "C16",
    "C39",
    "C40"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('{\"null\":null,\"boolean\":true,\"integer\":-2,\"real\":1.5,\"string\":\"x\",\"array\":[1],\"object\":{\"k\":2}}');\nSegun parsed Hacer\nExito(document): Escribir TextoJson(document);\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('{\"null\":null,\"boolean\":true,\"integer\":-2,\"real\":1.5,\"string\":\"x\",\"array\":[1],\"object\":{\"k\":2}}');\nswitch parsed do\nsuccess(document): write jsonText(document);\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{\"null\":null,\"boolean\":true,\"integer\":-2,\"real\":1.5,\"string\":\"x\",\"array\":[1],\"object\":{\"k\":2}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir items Como ValorJson <- ArregloJson();\nDefinir mapping Como ValorJson <- ObjetoJson();\nEscribir items.Longitud(), \":\", mapping.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine items as JsonValue <- jsonArray();\ndefine mapping as JsonValue <- jsonObject();\nwrite items.length(), \":\", mapping.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('\"\\\\uD83D\\\\uDE00\"');\nSegun parsed Hacer\nExito(document): Escribir TextoJson(document);\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('\"\\\\uD83D\\\\uDE00\"');\nswitch parsed do\nsuccess(document): write jsonText(document);\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "\"😀\"\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "J5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir negativeZero Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('-0');\nDefinir hugeReal Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('1e400');\nDefinir hugeInteger Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('9223372036854775808');\nSegun negativeZero Hacer\nExito(document): Segun document.ComoEntero() Hacer\nNada: Escribir \"none\";\nAlgo(value): Escribir TextoJson(document), \":\", value;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun hugeReal Hacer\nExito(document): Segun document.ComoReal() Hacer\nNada: Escribir \"none\";\nAlgo(number): Escribir number;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun hugeInteger Hacer\nExito(document): Segun document.ComoEntero() Hacer\nNada: Escribir \"none\";\nAlgo(number): Escribir number;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine negativeZero as result<JsonValue, JsonError> <- parseJson('-0');\ndefine hugeReal as result<JsonValue, JsonError> <- parseJson('1e400');\ndefine hugeInteger as result<JsonValue, JsonError> <- parseJson('9223372036854775808');\nswitch negativeZero do\nsuccess(document): switch document.asInteger() do\nnone: write \"none\";\nsome(value): write jsonText(document), \":\", value;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nswitch hugeReal do\nsuccess(document): switch document.asReal() do\nnone: write \"none\";\nsome(number): write number;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nswitch hugeInteger do\nsuccess(document): switch document.asInteger() do\nnone: write \"none\";\nsome(number): write number;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-0:0\nnone\nnone\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C5",
  "regla": "J2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('{\"a\":1,\"a\":2}');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('{\"a\":1,\"a\":2}');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeDuplicateKey}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('\"\\\\uD800\"');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('\"\\\\uD800\"');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidEscape}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n  Definir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('[1,]');\n  Segun parsed Hacer\n    Exito(document): Escribir \"unexpected\";\n    Error(problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Define parsed As Result<JsonValue, JsonError> <- parseJson('[1,]');\n  Switch parsed Do\n    Success(document): Write \"unexpected\";\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidSyntax}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('﻿1');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('﻿1');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidSyntax}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('true false');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('true false');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeTrailingContent}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "J3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]');\nSegun parsed Hacer\nExito(document): Escribir document.Tipo;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]');\nswitch parsed do\nsuccess(document): write document.kind;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "limites": {
    "max_json_depth": 64
  },
  "espera": {
    "salida": "{{lexema:jsonKindArray}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "J3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[0]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "limites": {
    "max_json_depth": 64
  },
  "espera": {
    "salida": "{{lexema:jsonErrorCodeDepthExceeded}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "J4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('[\\n  1,\\n    x\\n]');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.JsonLinea, \":\", problem.JsonColumna;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('[\\n  1,\\n    x\\n]');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.jsonLine, \":\", problem.jsonColumn;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3:5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "J6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('{\"a\":1,\"b\":2,\"c\":3}');\nSegun parsed Hacer\nExito(document): Escribir TextoJson(document.ConCampo(\"b\", JsonEntero(9)));\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('{\"a\":1,\"b\":2,\"c\":3}');\nswitch parsed do\nsuccess(document): write jsonText(document.withField(\"b\", jsonInteger(9)));\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{\"a\":1,\"b\":9,\"c\":3}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "J6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n  Definir mapping Como ValorJson <- ObjetoJson();\n  mapping.ConElemento(JsonNulo());\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Define mapping As JsonValue <- jsonObject();\n  mapping.withElement(jsonNull());\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "jsonKindMismatch"
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "J5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('{\"b\":2,\"a\":[1]}');\nSegun parsed Hacer\nExito(document): Definir keys Como Vector<Cadena> <- document.Claves();\nDefinir missing Como Cadena <- \"Nada\";\nDefinir absent Como Cadena <- \"Nada\";\nSegun document.Campo(\"missing\") Hacer\nAlgo(value): missing <- \"Algo\";\nNada: missing <- \"Nada\";\nFinSegun\nSegun document.Elemento(0) Hacer\nAlgo(value): absent <- \"Algo\";\nNada: absent <- \"Nada\";\nFinSegun\nEscribir keys[0], \":\", keys[1], \":\", missing, \":\", absent;\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('{\"b\":2,\"a\":[1]}');\nswitch parsed do\nsuccess(document): define keys as vector<string> <- document.keys();\ndefine missing as string <- \"Nada\";\ndefine absent as string <- \"Nada\";\nswitch document.field(\"missing\") do\nsome(value): missing <- \"Algo\";\nnone: missing <- \"Nada\";\nendSwitch\nswitch document.element(0) do\nsome(value): absent <- \"Algo\";\nnone: absent <- \"Nada\";\nendSwitch\nwrite keys[0], \":\", keys[1], \":\", missing, \":\", absent;\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "b:a:Nada:Nada\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C16",
  "regla": "J8",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Suspendible Child(value Como ValorJson) Como Cadena\nRetornar TextoJson(value);\nFinSubProceso\nAlgoritmo P\nDefinir value Como ValorJson <- JsonCadena(\"ok\");\nTareas\nDefinir child Como Tarea<Cadena> <- Lanzar Child(value);\nEscribir Aguardar child;\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Child(value as JsonValue) as string\nreturn jsonText(value);\nendSubroutine\nalgorithm P\ndefine value as JsonValue <- jsonString(\"ok\");\ntasks\ndefine child as task<string> <- spawn Child(value);\nwrite await child;\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "\"ok\"\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo LeerAlumno\n  Segun AnalizarJson('{\"nombre\": \"Ana\", \"edad\": 15}') Hacer\n    Exito(alumno): Escribir TextoJson(alumno);\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm ReadStudent\n  Switch parseJson('{\"nombre\": \"Ana\", \"edad\": 15}') Do\n    Success(student): Write jsonText(student);\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{\"nombre\":\"Ana\",\"edad\":15}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C18",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo FichaAlumno\n  Definir alumno Como ValorJson <- ObjetoJson();\n  alumno <- alumno.ConCampo(\"nombre\", JsonCadena(\"Ana\"));\n  alumno <- alumno.ConCampo(\"edad\", JsonEntero(15));\n  Escribir TextoJson(alumno);\nFinAlgoritmo\n",
    "en": "Algorithm StudentRecord\n  Define student As JsonValue <- jsonObject();\n  student <- student.withField(\"nombre\", jsonString(\"Ana\"));\n  student <- student.withField(\"edad\", jsonInteger(15));\n  Write jsonText(student);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{\"nombre\":\"Ana\",\"edad\":15}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C19",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Cumpleanios\n  Definir alumno Como ValorJson <- ObjetoJson();\n  alumno <- alumno.ConCampo(\"nombre\", JsonCadena(\"Ana\"));\n  alumno <- alumno.ConCampo(\"edad\", JsonEntero(15));\n  alumno <- alumno.ConCampo(\"edad\", JsonEntero(16));\n  Escribir TextoJson(alumno);\nFinAlgoritmo\n",
    "en": "Algorithm Birthday\n  Define student As JsonValue <- jsonObject();\n  student <- student.withField(\"nombre\", jsonString(\"Ana\"));\n  student <- student.withField(\"edad\", jsonInteger(15));\n  student <- student.withField(\"edad\", jsonInteger(16));\n  Write jsonText(student);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{\"nombre\":\"Ana\",\"edad\":16}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C20",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo ListaDeNotas\n  Definir vacia Como ValorJson <- ArregloJson();\n  Definir notas Como ValorJson <- vacia.ConElemento(JsonEntero(8));\n  notas <- notas.ConElemento(JsonEntero(10));\n  Escribir TextoJson(notas);\n  Escribir vacia.Longitud(), \" \", notas.Longitud();\nFinAlgoritmo\n",
    "en": "Algorithm GradeList\n  Define empty As JsonValue <- jsonArray();\n  Define grades As JsonValue <- empty.withElement(jsonInteger(8));\n  grades <- grades.withElement(jsonInteger(10));\n  Write jsonText(grades);\n  Write empty.length(), \" \", grades.length();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "[8,10]\n0 2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Medidas\n  Definir persona Como ValorJson <- ObjetoJson();\n  persona <- persona.ConCampo(\"altura\", JsonReal(1.65));\n  persona <- persona.ConCampo(\"apodo\", JsonNulo());\n  Escribir TextoJson(persona);\nFinAlgoritmo\n",
    "en": "Algorithm Measurements\n  Define person As JsonValue <- jsonObject();\n  person <- person.withField(\"altura\", jsonReal(1.65));\n  person <- person.withField(\"apodo\", jsonNull());\n  Write jsonText(person);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{\"altura\":1.65,\"apodo\":null}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo TiposDeDatos\n  Escribir JsonNulo().Tipo();\n  Escribir JsonEntero(15).Tipo();\n  Escribir JsonReal(1.65).Tipo();\n  Escribir JsonCadena(\"Ana\").Tipo();\n  Escribir ArregloJson().Tipo();\n  Escribir ObjetoJson().Tipo();\nFinAlgoritmo\n",
    "en": "Algorithm DataKinds\n  Write jsonNull().kind();\n  Write jsonInteger(15).kind();\n  Write jsonReal(1.65).kind();\n  Write jsonString(\"Ana\").kind();\n  Write jsonArray().kind();\n  Write jsonObject().kind();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonKindNull}}\n{{lexema:jsonKindNumber}}\n{{lexema:jsonKindNumber}}\n{{lexema:jsonKindString}}\n{{lexema:jsonKindArray}}\n{{lexema:jsonKindObject}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Aprobado\n  Segun AnalizarJson('true') Hacer\n    Exito(dato):\n      Escribir dato.Tipo();\n      Segun dato.ComoLogico() Hacer\n        Algo(aprobado): Escribir aprobado;\n        Nada: Escribir \"?\";\n      FinSegun\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm Passed\n  Switch parseJson('true') Do\n    Success(item):\n      Write item.kind();\n      Switch item.asBoolean() Do\n        Some(passed): Write passed;\n        None: Write \"?\";\n      EndSwitch\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonKindBoolean}}\n{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C24",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo EdadSiguiente\n  Definir edad Como ValorJson <- JsonEntero(15);\n  Definir texto Como ValorJson <- JsonCadena(\"15\");\n  Segun edad.ComoEntero() Hacer\n    Algo(numero): Escribir numero + 1;\n    Nada: Escribir \"?\";\n  FinSegun\n  Segun texto.ComoEntero() Hacer\n    Algo(numero): Escribir numero + 1;\n    Nada: Escribir \"?\";\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm NextAge\n  Define age As JsonValue <- jsonInteger(15);\n  Define text As JsonValue <- jsonString(\"15\");\n  Switch age.asInteger() Do\n    Some(number): Write number + 1;\n    None: Write \"?\";\n  EndSwitch\n  Switch text.asInteger() Do\n    Some(number): Write number + 1;\n    None: Write \"?\";\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "16\n?\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C25",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo DoblePrecio\n  Definir precio Como ValorJson <- JsonReal(12.5);\n  Definir texto Como ValorJson <- JsonCadena(\"12.5\");\n  Segun precio.ComoReal() Hacer\n    Algo(valor): Escribir valor * 2;\n    Nada: Escribir \"?\";\n  FinSegun\n  Segun texto.ComoReal() Hacer\n    Algo(valor): Escribir valor * 2;\n    Nada: Escribir \"?\";\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm DoublePrice\n  Define price As JsonValue <- jsonReal(12.5);\n  Define text As JsonValue <- jsonString(\"12.5\");\n  Switch price.asReal() Do\n    Some(amount): Write amount * 2;\n    None: Write \"?\";\n  EndSwitch\n  Switch text.asReal() Do\n    Some(amount): Write amount * 2;\n    None: Write \"?\";\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "25.0\n?\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C26",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo NombreSinComillas\n  Definir nombre Como ValorJson <- JsonCadena(\"Ana\");\n  Segun nombre.ComoCadena() Hacer\n    Algo(texto): Escribir texto;\n    Nada: Escribir \"?\";\n  FinSegun\n  Escribir TextoJson(nombre);\nFinAlgoritmo\n",
    "en": "Algorithm NameWithoutQuotes\n  Define name As JsonValue <- jsonString(\"Ana\");\n  Switch name.asText() Do\n    Some(text): Write text;\n    None: Write \"?\";\n  EndSwitch\n  Write jsonText(name);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Ana\n\"Ana\"\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C27",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo NotasDelCurso\n  Segun AnalizarJson('[7, 9, 10]') Hacer\n    Exito(notas):\n      Segun notas.Elemento(1) Hacer\n        Algo(nota): Escribir TextoJson(nota);\n        Nada: Escribir \"?\";\n      FinSegun\n      Segun notas.Elemento(3) Hacer\n        Algo(nota): Escribir TextoJson(nota);\n        Nada: Escribir \"?\";\n      FinSegun\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm CourseGrades\n  Switch parseJson('[7, 9, 10]') Do\n    Success(grades):\n      Switch grades.element(1) Do\n        Some(grade): Write jsonText(grade);\n        None: Write \"?\";\n      EndSwitch\n      Switch grades.element(3) Do\n        Some(grade): Write jsonText(grade);\n        None: Write \"?\";\n      EndSwitch\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n?\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C28",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo EdadDelAlumno\n  Segun AnalizarJson('{\"nombre\": \"Ana\", \"edad\": 15}') Hacer\n    Exito(alumno):\n      Segun alumno.Campo(\"edad\") Hacer\n        Algo(edad): Escribir TextoJson(edad);\n        Nada: Escribir \"?\";\n      FinSegun\n      Segun alumno.Campo(\"Edad\") Hacer\n        Algo(edad): Escribir TextoJson(edad);\n        Nada: Escribir \"?\";\n      FinSegun\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm StudentAge\n  Switch parseJson('{\"nombre\": \"Ana\", \"edad\": 15}') Do\n    Success(student):\n      Switch student.field(\"edad\") Do\n        Some(age): Write jsonText(age);\n        None: Write \"?\";\n      EndSwitch\n      Switch student.field(\"Edad\") Do\n        Some(age): Write jsonText(age);\n        None: Write \"?\";\n      EndSwitch\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "15\n?\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C29",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo ListarClaves\n  Segun AnalizarJson('{\"nombre\": \"Ana\", \"edad\": 15, \"curso\": \"3B\"}') Hacer\n    Exito(alumno):\n      Para Cada clave En alumno.Claves() Hacer\n        Escribir clave;\n      FinPara\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm ListKeys\n  Switch parseJson('{\"nombre\": \"Ana\", \"edad\": 15, \"curso\": \"3B\"}') Do\n    Success(student):\n      For Each key In student.keys() Do\n        Write key;\n      EndFor\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "nombre\nedad\ncurso\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C30",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo QueTipoEs\n  Definir notas Como ValorJson <- ArregloJson();\n  Definir tipo Como TipoJson <- notas.Tipo();\n  Escribir tipo;\nFinAlgoritmo\n",
    "en": "Algorithm WhichKind\n  Define grades As JsonValue <- jsonArray();\n  Define valueKind As JsonKind <- grades.kind();\n  Write valueKind;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonKindArray}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C31",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo RevisarFicha\n  Segun AnalizarJson('{\\n  \"edad\": 15,\\n  nombre: \"Ana\"\\n}') Hacer\n    Exito(alumno): Escribir TextoJson(alumno);\n    Error(problema):\n      Definir codigo Como CodigoErrorJson <- problema.Codigo;\n      Escribir codigo;\n      Escribir problema.JsonLinea, \":\", problema.JsonColumna;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm CheckRecord\n  Switch parseJson('{\\n  \"edad\": 15,\\n  nombre: \"Ana\"\\n}') Do\n    Success(student): Write jsonText(student);\n    Failure(problem):\n      Define errorCode As JsonErrorCode <- problem.code;\n      Write errorCode;\n      Write problem.jsonLine, \":\", problem.jsonColumn;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidSyntax}}\n3:3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C32",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo ComillasSimples\n  Segun AnalizarJson(\"{'nombre': 'Ana'}\") Hacer\n    Exito(alumno): Escribir TextoJson(alumno);\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm SingleQuotes\n  Switch parseJson(\"{'nombre': 'Ana'}\") Do\n    Success(student): Write jsonText(student);\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidSyntax}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C33",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo FaltaCerrar\n  Segun AnalizarJson('{\"nombre\": \"Ana\"') Hacer\n    Exito(alumno): Escribir TextoJson(alumno);\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm MissingClose\n  Switch parseJson('{\"nombre\": \"Ana\"') Do\n    Success(student): Write jsonText(student);\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeUnexpectedEnd}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C34",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo ClaveRepetida\n  Segun AnalizarJson('{\"nombre\": \"Ana\", \"nombre\": \"Luis\"}') Hacer\n    Exito(alumno): Escribir TextoJson(alumno);\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm RepeatedKey\n  Switch parseJson('{\"nombre\": \"Ana\", \"nombre\": \"Luis\"}') Do\n    Success(student): Write jsonText(student);\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeDuplicateKey}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C35",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo RutaDeArchivo\n  Segun AnalizarJson('\"C:\\\\datos\"') Hacer\n    Exito(ruta): Escribir TextoJson(ruta);\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm FilePath\n  Switch parseJson('\"C:\\\\datos\"') Do\n    Success(path): Write jsonText(path);\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidEscape}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C36",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo DosObjetos\n  Segun AnalizarJson('{\"nombre\": \"Ana\"} {\"nombre\": \"Luis\"}') Hacer\n    Exito(alumnos): Escribir TextoJson(alumnos);\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm TwoObjects\n  Switch parseJson('{\"nombre\": \"Ana\"} {\"nombre\": \"Luis\"}') Do\n    Success(students): Write jsonText(students);\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeTrailingContent}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C37",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo CajasDentroDeCajas\n  Definir texto Como Cadena <- \"\";\n  Para nivel <- 1 Hasta 65 Hacer\n    texto <- texto + \"[\";\n  FinPara\n  Para nivel <- 1 Hasta 65 Hacer\n    texto <- texto + \"]\";\n  FinPara\n  Segun AnalizarJson(texto) Hacer\n    Exito(dato): Escribir dato.Tipo();\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm BoxesInsideBoxes\n  Define text As String <- \"\";\n  For level <- 1 To 65 Do\n    text <- text + \"[\";\n  EndFor\n  For level <- 1 To 65 Do\n    text <- text + \"]\";\n  EndFor\n  Switch parseJson(text) Do\n    Success(item): Write item.kind();\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "limites": {
    "max_json_depth": 64
  },
  "espera": {
    "salida": "{{lexema:jsonErrorCodeDepthExceeded}}\n",
    "terminacion": "completed"
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "J7",
  "generador": {
    "programas": "valores JSON válidos de profundidad no mayor que max_json_depth"
  },
  "propiedad": "AnalizarJson(TextoJson(d)) reconstruye estructuralmente d para todo valor JSON válido d.",
  "oraculo": "El analizador independiente de see_oracles acepta la gramática JSON estricta y compara los árboles ordenados del valor original y del texto serializado.",
  "justificacion": "La propiedad cubre la composición de escapes, orden de claves y conservación de lexemas numéricos que no cabe en una lista finita de casos."
}
```

```caso
{
  "id": "C38",
  "regla": "J1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Aprobacion\n  Definir aprobado Como Logico <- Verdadero;\n  Definir dato Como ValorJson <- JsonLogico(aprobado);\n  Escribir TextoJson(dato);\n  Escribir dato.Tipo();\nFinAlgoritmo\n",
    "en": "Algorithm Approval\n  Define passed As Boolean <- True;\n  Define item As JsonValue <- jsonBoolean(passed);\n  Write jsonText(item);\n  Write item.kind();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "true\n{{lexema:jsonKindBoolean}}\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C39",
  "regla": "J8",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir objeto Como ValorJson <- ObjetoJson();\nDefinir lista Como ValorJson <- ArregloJson();\nEscribir objeto.Tipo() = ArregloJson().Tipo();\nEscribir lista.Tipo() = ArregloJson().Tipo();\nEscribir objeto.Tipo() <> lista.Tipo();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine object as JsonValue <- jsonObject();\ndefine list as JsonValue <- jsonArray();\nwrite object.kind() = jsonArray().kind();\nwrite list.kind() = jsonArray().kind();\nwrite object.kind() <> list.kind();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n{{lexema:booleanTrue}}\n{{lexema:booleanTrue}}\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C40",
  "regla": "J8",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir lista Como ValorJson <- ArregloJson();\nEscribir lista.Tipo() = Arreglo;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine list as JsonValue <- jsonArray();\nwrite list.kind() = Array;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredVariable",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C41",
  "regla": "J4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Probar(texto Como Cadena)\nSegun AnalizarJson(texto) Hacer\nExito(document): Escribir TextoJson(document);\nError(problem): Escribir problem.Codigo, \" \", problem.JsonLinea, \":\", problem.JsonColumna;\nFinSegun\nFinSubProceso\nAlgoritmo P\nProbar('{\"nombre\": \"Ana\"');\nProbar('[1,');\nProbar('[\\n');\nProbar('[\\n  ');\nProbar('');\nFinAlgoritmo\n",
    "en": "subroutine Probe(source as string)\nswitch parseJson(source) do\nsuccess(document): write jsonText(document);\nfailure(problem): write problem.code, \" \", problem.jsonLine, \":\", problem.jsonColumn;\nendSwitch\nendSubroutine\nalgorithm P\nProbe('{\"nombre\": \"Ana\"');\nProbe('[1,');\nProbe('[\\n');\nProbe('[\\n  ');\nProbe('');\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeUnexpectedEnd}} 1:17\n{{lexema:jsonErrorCodeUnexpectedEnd}} 1:4\n{{lexema:jsonErrorCodeUnexpectedEnd}} 2:1\n{{lexema:jsonErrorCodeUnexpectedEnd}} 2:3\n{{lexema:jsonErrorCodeUnexpectedEnd}} 1:1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C42",
  "regla": "J4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Probar(texto Como Cadena)\nSegun AnalizarJson(texto) Hacer\nExito(document): Escribir TextoJson(document);\nError(problem): Escribir problem.Codigo, \" \", problem.JsonLinea, \":\", problem.JsonColumna;\nFinSegun\nFinSubProceso\nAlgoritmo P\nProbar('[\"ñ\",x]');\nProbar('[\"ññ\"');\nProbar('\"😀');\nFinAlgoritmo\n",
    "en": "subroutine Probe(source as string)\nswitch parseJson(source) do\nsuccess(document): write jsonText(document);\nfailure(problem): write problem.code, \" \", problem.jsonLine, \":\", problem.jsonColumn;\nendSwitch\nendSubroutine\nalgorithm P\nProbe('[\"ñ\",x]');\nProbe('[\"ññ\"');\nProbe('\"😀');\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidSyntax}} 1:6\n{{lexema:jsonErrorCodeUnexpectedEnd}} 1:6\n{{lexema:jsonErrorCodeUnexpectedEnd}} 1:3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C43",
  "regla": "J6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir JsonCadena(\"hola\").Longitud(), \":\", JsonCadena(\"\").Longitud(), \":\", JsonEntero(42).Longitud(), \":\", JsonNulo().Longitud(), \":\", JsonLogico(Falso).Longitud(), \":\", ArregloJson().ConElemento(JsonNulo()).Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite jsonString(\"hola\").length(), \":\", jsonString(\"\").length(), \":\", jsonInteger(42).length(), \":\", jsonNull().length(), \":\", jsonBoolean(false).length(), \":\", jsonArray().withElement(jsonNull()).length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:0:0:0:0:1\n",
    "terminacion": "completed"
  }
}
```
