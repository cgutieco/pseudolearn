---
{
  "formato": "see/1",
  "id": "LIB.SCENARIO.BILINGUAL",
  "titulo": "Escenario integrador bilingüe entre módulos",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": ["responsable-lenguaje"],
  "sujetos": ["engine"],
  "resumen": "Consumo desde español e inglés de una biblioteca inglesa con JSON y texto.",
  "titulo_en": "Bilingual cross-module scenario",
  "depende_de": [
    {"id": "LANG.MODULE.MODEL", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "LANG.MODULE.IMPORT", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "API.PROJECT", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "LIB.JSON", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "LIB.IO", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "ENG.LIMITS", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "ENG.EXEC.MODEL", "version": ">=1.0.0, <2.0.0", "tipo": "usa"}
  ],
  "revisado_por": ["Cesar Antonio Gutierrez Contreras"]
}
---

# Escenario integrador bilingüe entre módulos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La composición usa LANG.MODULE.MODEL@1.0.0#R1 y R2, LANG.MODULE.IMPORT@1.0.0#R1 y R2, API.PROJECT@1.0.0#R1, LIB.JSON@1.0.0#J1 y J7, LIB.IO@1.0.0#R2, ENG.LIMITS@1.0.0#R10 y ENG.EXEC.MODEL@1.0.0#R3 y R4. En un proyecto de una aplicación y una biblioteca, el módulo de biblioteca usa perfil en, declara Canonical como Público y analiza y serializa JSON dentro de una función que recibe una Cadena y devuelve un Resultado de Cadena o CodigoErrorJson. Un módulo de aplicación es puede importar esa función y produce la misma salida que su traducción en. Ningún tipo genérico cruza la frontera del módulo. Una cadena vacía devuelve el código UnexpectedEnd, con el nombre del perfil de la biblioteca que lo creó y sin importar el perfil del módulo que lo escribe; un programa que intenta leer sin archivos_lectura obtiene PermisoDenegado; cancelar el programa antes de su primera sentencia termina cancelled; el agotamiento de celdas termina failed con cellLimitExceeded.",
  "verificacion": ["C1", "C2", "C3", "C4", "C5"]
}
```

```cobertura
{
  "id": "V1",
  "regla": "LIB.SCENARIO.BILINGUAL#R1",
  "sin_ri": "El contrato fija composición observable de biblioteca y anfitrión; no introduce instrucciones de RI."
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
              {"name": "geo", "root": "geo", "kind": "library", "entries": [], "dependencies": {}}
            ],
            "files": [
              {"path": "app/main", "source_id": 1, "profile": "es", "text": "Importar geo.catalogo.Canonical;\nAlgoritmo Main\nSegun Canonical(\"{\\\"name\\\":\\\"Ada\\\",\\\"score\\\":7}\") Hacer\nExito(text): Escribir text;\nError(reason): Escribir reason;\nFinSegun\nFinAlgoritmo\n"},
              {"path": "geo/catalogo", "source_id": 2, "profile": "en", "text": "Public subroutine Canonical(source as string) as result<string, JsonErrorCode>\ndefine parsed as result<JsonValue, JsonError> <- parseJson(source);\nswitch parsed do\nsuccess(document): return success(jsonText(document));\nfailure(problem): return failure(problem.code);\nendSwitch\nendSubroutine\n"}
            ]
          },
          "entry": "app/main"
        }
      },
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "en",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "2",
            "packages": [
              {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
              {"name": "geo", "root": "geo", "kind": "library", "entries": [], "dependencies": {}}
            ],
            "files": [
              {"path": "app/main", "source_id": 3, "profile": "en", "text": "import geo.catalog.Canonical;\nalgorithm Main\nswitch Canonical(\"{\\\"name\\\":\\\"Ada\\\",\\\"score\\\":7}\") do\nsuccess(text): write text;\nfailure(reason): write reason;\nendSwitch\nendAlgorithm\n"},
              {"path": "geo/catalog", "source_id": 4, "profile": "en", "text": "Public subroutine Canonical(source as string) as result<string, JsonErrorCode>\ndefine parsed as result<JsonValue, JsonError> <- parseJson(source);\nswitch parsed do\nsuccess(document): return success(jsonText(document));\nfailure(problem): return failure(problem.code);\nendSwitch\nendSubroutine\n"}
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {"value": {"output": "{\"name\":\"Ada\",\"score\":7}\n", "diagnostics": [], "project_errors": []}},
        {"value": {"output": "{\"name\":\"Ada\",\"score\":7}\n", "diagnostics": [], "project_errors": []}}
      ]
    }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "3",
            "packages": [
              {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
              {"name": "geo", "root": "geo", "kind": "library", "entries": [], "dependencies": {}}
            ],
            "files": [
              {"path": "app/main", "source_id": 5, "profile": "es", "text": "Importar geo.catalogo.Canonical;\nAlgoritmo Main\nSegun Canonical(\"\") Hacer\nExito(text): Escribir text;\nError(reason): Escribir reason;\nFinSegun\nFinAlgoritmo\n"},
              {"path": "geo/catalogo", "source_id": 6, "profile": "en", "text": "Public subroutine Canonical(source as string) as result<string, JsonErrorCode>\ndefine parsed as result<JsonValue, JsonError> <- parseJson(source);\nswitch parsed do\nsuccess(document): return success(jsonText(document));\nfailure(problem): return failure(problem.code);\nendSwitch\nendSubroutine\n"}
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {"value": {"output": "UnexpectedEnd\n", "diagnostics": [], "project_errors": []}}
      ]
    }
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
    "es": "SubProceso Run() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nSegun directory.Abrir(\"entrada.txt\", \"lectura\") Hacer\nExito(file): Escribir \"inesperado\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Run() Hacer\nExito(value):\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Run() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nswitch directory.open(\"entrada.txt\", \"read\") do\nsuccess(file): write \"unexpected\";\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Run() do\nsuccess(value):\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed"
  },
  "anfitrion": {
    "permissions": [],
    "requested_permissions": ["archivos_lectura"],
    "files": {"entrada.txt": "contenido"}
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "Algoritmo Main\nDimension valores[4] Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndimension values[4] as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "limites": {"celdas": 1},
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {"codigo": "cellLimitExceeded"}
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
    "es": "Algoritmo Main\nEscribir \"cancelacion_pendiente\";\nFinAlgoritmo\n",
    "en": "algorithm Main\nwrite \"cancelation_pending\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "", "terminacion": "cancelled"},
  "cancelacion": 1
}
```
