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
  introducida_en: "2026"
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
- Cesar Antonio Gutierrez Contreras
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
    "C9"
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
  "texto": "AnalizarJson devuelve el primer error en orden de lectura con línea y columna desde uno, según LANG.SOURCE.POSITION.",
  "verificacion": [
    "C12"
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
  "texto": "Campo busca una clave exacta. Elemento usa índices desde cero y devuelve Nada si el receptor no es un arreglo o el índice está fuera de rango. Claves devuelve las claves de un objeto en su orden original. ConCampo reemplaza en su posición original una clave existente y añade una nueva al final. ConElemento añade al final de un arreglo. ConElemento y ConCampo sobre un tipo JSON incorrecto atrapan con jsonKindMismatch.",
  "verificacion": [
    "C13",
    "C14",
    "C15"
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
  "texto": "ValorJson, TipoJson, ErrorJson y CodigoErrorJson son valores inmutables y transferibles. No se define igualdad estructural para ValorJson en esta edición; TextoJson permite comparar sus representaciones.",
  "verificacion": [
    "C16"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir array Como ValorJson <- ArregloJson();\nDefinir object Como ValorJson <- ObjetoJson();\nEscribir array.Longitud(), \":\", object.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine array as JsonValue <- jsonArray();\ndefine object as JsonValue <- jsonObject();\nwrite array.length(), \":\", object.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:0\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('\"\\uD83D\\uDE00\"');\nSegun parsed Hacer\nExito(document): Escribir TextoJson(document);\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('\"\\uD83D\\uDE00\"');\nswitch parsed do\nsuccess(document): write jsonText(document);\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "\"😀\"\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir negativeZero Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('-0');\nDefinir hugeReal Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('1e400');\nDefinir hugeInteger Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('9223372036854775808');\nSegun negativeZero Hacer\nExito(document): Escribir TextoJson(document), \":\", document.ComoEntero();\nError(problem): Escribir \"error\";\nFinSegun\nSegun hugeReal Hacer\nExito(document): Segun document.ComoReal() Hacer\nNada: Escribir \"none\";\nAlgo(number): Escribir number;\nFinSegun\nError(problem): Escribir \"error\";\nFinSegun\nSegun hugeInteger Hacer\nExito(document): Segun document.ComoEntero() Hacer\nNada: Escribir \"none\";\nAlgo(number): Escribir number;\nFinSegun\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine negativeZero as result<JsonValue, JsonError> <- parseJson('-0');\ndefine hugeReal as result<JsonValue, JsonError> <- parseJson('1e400');\ndefine hugeInteger as result<JsonValue, JsonError> <- parseJson('9223372036854775808');\nswitch negativeZero do\nsuccess(document): write jsonText(document), \":\", document.asInteger();\nfailure(problem): write \"error\";\nendSwitch\nswitch hugeReal do\nsuccess(document): switch document.asReal() do\nnone: write \"none\";\nsome(number): write number;\nendSwitch\nfailure(problem): write \"error\";\nendSwitch\nswitch hugeInteger do\nsuccess(document): switch document.asInteger() do\nnone: write \"none\";\nsome(number): write number;\nendSwitch\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-0:0\nnone\nnone\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('\"\\uD800\"');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('\"\\uD800\"');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidEscape}}\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('[1,]');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('[1,]');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeInvalidSyntax}}\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('[\\n  1,\\n    x\\n]');\nSegun parsed Hacer\nExito(document): Escribir \"unexpected\";\nError(problem): Escribir problem.Linea, \":\", problem.Columna;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('[\\n  1,\\n    x\\n]');\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.line, \":\", problem.column;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3:5\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir object Como ValorJson <- ObjetoJson();\nobject.ConElemento(JsonNulo());\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine object as JsonValue <- jsonObject();\nobject.withElement(jsonNull());\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "jsonKindMismatch"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson('{\"b\":2,\"a\":[1]}');\nSegun parsed Hacer\nExito(document): Definir keys Como Vector<Cadena> <- document.Claves();\nEscribir keys[0], \":\", keys[1], \":\", document.Campo(\"missing\"), \":\", document.Elemento(0);\nError(problem): Escribir \"error\";\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson('{\"b\":2,\"a\":[1]}');\nswitch parsed do\nsuccess(document): define keys as vector<string> <- document.keys();\nwrite keys[0], \":\", keys[1], \":\", document.field(\"missing\"), \":\", document.element(0);\nfailure(problem): write \"error\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "b:a:Nada:Nada\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
