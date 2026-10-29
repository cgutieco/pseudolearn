---
{
  "formato": "see/1",
  "id": "LIB.SCENARIO.FILE-JSON",
  "titulo": "Escenario integrador de archivo y JSON",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": ["responsable-lenguaje"],
  "sujetos": ["engine", "aot"],
  "resumen": "Composición de lectura de texto, análisis JSON, extracción, escritura, límites y cinta.",
  "titulo_en": "Integrated file and JSON scenario",
  "depende_de": [
    {"id": "LIB.IO", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "LIB.JSON", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "ENG.EXEC.MODEL", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "ENG.EFFECT.TAPE", "version": ">=1.0.0, <2.0.0", "tipo": "usa"}
  ],
  "revisado_por": ["Cesar Antonio Gutierrez Contreras"]
}
---

# Escenario integrador de archivo y JSON

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La composición usa LIB.IO@1.0.0#R2 y R4, LIB.JSON@1.0.0#J3, J4 y J7, ENG.EXEC.MODEL@1.0.0#R4 y ENG.EFFECT.TAPE@1.0.0#R5. Con lectura y escritura concedidas, lee entrada.json, analiza exactamente su texto, extrae nombre y visitas, y escribe en salida.json la representación compacta producida por TextoJson. Una entrada vacía produce FinInesperado en línea 1, columna 1 sin abrir salida.json; una escritura sin permiso produce PermisoDenegado sin modificar archivos; la cancelación del anfitrión mientras file_write_text está pendiente termina cancelled, libera los recursos y sella la cinta incomplete; una profundidad max_json_depth + 1 produce ProfundidadExcedida y no escribe el archivo de salida.",
  "verificacion": ["C1", "C2", "C3", "C4", "C5"]
}
```

```cobertura
{
  "id": "V1",
  "regla": "LIB.SCENARIO.FILE-JSON#R1",
  "sin_ri": "El contrato fija composición observable de biblioteca y anfitrión; no introduce instrucciones de RI."
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Ada\n3\n",
    "terminacion": "completed",
    "anfitrion_observado": {"estado_cinta": "reproducible"}
  },
  "programas": {
    "es": "SubProceso Run()\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inputFile Como ArchivoCap <- Propagar directory.Abrir(\"entrada.json\", \"lectura\");\nDiferir\nDescartar inputFile.Cerrar();\nFinDiferir\nDefinir source Como Cadena <- Propagar inputFile.LeerTexto();\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(source);\nSegun parsed Hacer\nExito(document):\nSegun document.Campo(\"nombre\") Hacer\nAlgo(nameValue): Segun nameValue.ComoCadena() Hacer\nAlgo(name): Escribir name;\nNada: Escribir \"tipo_invalido\";\nFinSegun\nNada: Escribir \"campo_ausente\";\nFinSegun\nSegun document.Campo(\"visitas\") Hacer\nAlgo(countValue): Segun countValue.ComoEntero() Hacer\nAlgo(count): Escribir count;\nNada: Escribir \"tipo_invalido\";\nFinSegun\nNada: Escribir \"campo_ausente\";\nFinSegun\nDefinir outputFile Como ArchivoCap <- Propagar directory.Abrir(\"salida.json\", \"escritura\");\nDiferir\nDescartar outputFile.Cerrar();\nFinDiferir\nDescartar outputFile.EscribirTexto(TextoJson(document));\nError(problem): Escribir problem.Codigo, \":\", problem.Linea, \":\", problem.Columna;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nRun();\nFinAlgoritmo\n",
    "en": "subroutine Run()\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inputFile as FileCap <- propagate directory.open(\"entrada.json\", \"read\");\ndefer\ndiscard inputFile.close();\nendDefer\ndefine source as string <- propagate inputFile.readText();\ndefine parsed as result<JsonValue, JsonError> <- parseJson(source);\nswitch parsed do\nsuccess(document):\nswitch document.field(\"nombre\") do\nsome(nameValue): switch nameValue.asText() do\nsome(name): write name;\nnone: write \"tipo_invalido\";\nendSwitch\nnone: write \"campo_ausente\";\nendSwitch\nswitch document.field(\"visitas\") do\nsome(countValue): switch countValue.asInteger() do\nsome(count): write count;\nnone: write \"tipo_invalido\";\nendSwitch\nnone: write \"campo_ausente\";\nendSwitch\ndefine outputFile as FileCap <- propagate directory.open(\"salida.json\", \"write\");\ndefer\ndiscard outputFile.close();\nendDefer\ndiscard outputFile.writeText(jsonText(document));\nfailure(problem): write problem.code, \":\", problem.line, \":\", problem.column;\nendSwitch\nendSubroutine\nalgorithm Main\nRun();\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["archivos_lectura", "archivos_escritura"],
    "requested_permissions": ["archivos_lectura", "archivos_escritura"],
    "files": {"entrada.json": "{\"nombre\":\"Ada\",\"visitas\":3}"},
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "Algoritmo Main\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inputFile Como ArchivoCap <- Propagar directory.Abrir(\"entrada.json\", \"lectura\");\nDiferir\nDescartar inputFile.Cerrar();\nFinDiferir\nDefinir source Como Cadena <- Propagar inputFile.LeerTexto();\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(source);\nSegun parsed Hacer\nExito(document): Escribir \"inesperado\";\nError(problem): Escribir problem.Codigo, \":\", problem.Linea, \":\", problem.Columna;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inputFile as FileCap <- propagate directory.open(\"entrada.json\", \"read\");\ndefer\ndiscard inputFile.close();\nendDefer\ndefine source as string <- propagate inputFile.readText();\ndefine parsed as result<JsonValue, JsonError> <- parseJson(source);\nswitch parsed do\nsuccess(document): write \"unexpected\";\nfailure(problem): write problem.code, \":\", problem.line, \":\", problem.column;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeUnexpectedEnd}}:1:1\n",
    "terminacion": "completed",
    "anfitrion_observado": {"estado_cinta": "reproducible"}
  },
  "anfitrion": {
    "permissions": ["archivos_lectura"],
    "requested_permissions": ["archivos_lectura"],
    "files": {"entrada.json": ""},
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "Algoritmo Main\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inputFile Como ArchivoCap <- Propagar directory.Abrir(\"entrada.json\", \"lectura\");\nDiferir\nDescartar inputFile.Cerrar();\nFinDiferir\nDescartar inputFile.LeerTexto();\nSegun directory.Abrir(\"salida.json\", \"escritura\") Hacer\nExito(file): Escribir \"inesperado\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inputFile as FileCap <- propagate directory.open(\"entrada.json\", \"read\");\ndefer\ndiscard inputFile.close();\nendDefer\ndiscard inputFile.readText();\nswitch directory.open(\"salida.json\", \"write\") do\nsuccess(file): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed",
    "anfitrion_observado": {"estado_cinta": "reproducible"}
  },
  "anfitrion": {
    "permissions": ["archivos_lectura"],
    "requested_permissions": ["archivos_lectura", "archivos_escritura"],
    "files": {"entrada.json": "{\"nombre\":\"Ada\",\"visitas\":3}"}
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "api",
  "programas": {
    "es": "Algoritmo Main\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"salida.json\", \"escritura\");\nDescartar file.EscribirTexto(TextoJson(ObjetoJson()));\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"salida.json\", \"write\");\ndiscard file.writeText(jsonText(jsonObject()));\nendAlgorithm\n"
  },
  "api": {
    "calls": [
      {"operation": "create_analysis"},
      {"operation": "start", "resource_from": 0, "arguments": {"host": {"permissions": ["archivos_escritura"], "requested_permissions": ["archivos_escritura"], "detached": true}}},
      {"operation": "advance", "resource_from": 1, "arguments": {"batch_size": 64}},
      {"operation": "effect_result", "resource_from": 1, "arguments": {"effect_seq": 1, "result": {"outcome": "committed", "value": {"kind": "capability", "value": {"slot": 0, "generation": 1, "rights": 2, "kind": 2}}}}},
      {"operation": "advance", "resource_from": 1, "arguments": {"batch_size": 64}},
      {"operation": "effect_result", "resource_from": 1, "arguments": {"effect_seq": 2, "result": {"outcome": "committed", "value": {"kind": "capability", "value": {"slot": 1, "generation": 1, "rights": 2, "kind": 3}}}}},
      {"operation": "advance", "resource_from": 1, "arguments": {"batch_size": 64}},
      {"operation": "cancel", "resource_from": 1},
      {"operation": "advance", "resource_from": 1, "arguments": {"batch_size": 64}}
    ]
  },
  "espera": {
    "api": {
      "results": [
        {"value": {}},
        {"value": {}},
        {"value": {"termination": {"kind": "awaiting_effect", "effect_seq": 1, "capability_kind": "filesystem", "operation": "request_directory"}}},
        {"value": null},
        {"value": {"termination": {"kind": "awaiting_effect", "effect_seq": 2, "capability_kind": "filesystem", "operation": "file_open"}}},
        {"value": null},
        {"value": {"termination": {"kind": "awaiting_effect", "effect_seq": 3, "capability_kind": "filesystem", "operation": "file_write_text"}}},
        {"value": null},
        {"value": {"termination": {"kind": "cancelled"}, "effect_tape": {"status": "incomplete", "entries": [{"effect_seq": 1, "operation": "request_directory", "outcome": "committed"}, {"effect_seq": 2, "operation": "file_open", "outcome": "committed"}, {"effect_seq": 3, "operation": "file_write_text", "outcome": "requested"}]}, "host_observation": {"open_resources": 0}}}
      ]
    }
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "Algoritmo Main\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"entrada.json\", \"lectura\");\nDefinir source Como Cadena <- Propagar file.LeerTexto();\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(source);\nSegun parsed Hacer\nExito(document): Escribir TextoJson(document);\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"entrada.json\", \"read\");\ndefine source as string <- propagate file.readText();\ndefine parsed as result<JsonValue, JsonError> <- parseJson(source);\nswitch parsed do\nsuccess(document): write jsonText(document);\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "limites": {"max_json_depth": 1},
  "espera": {
    "salida": "{{lexema:jsonErrorCodeDepthExceeded}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {"estado_cinta": "reproducible"}
  },
  "anfitrion": {
    "permissions": ["archivos_lectura"],
    "requested_permissions": ["archivos_lectura"],
    "files": {"entrada.json": "{\"dato\":{}}"},
    "grabar_y_reproducir": true
  }
}
```
