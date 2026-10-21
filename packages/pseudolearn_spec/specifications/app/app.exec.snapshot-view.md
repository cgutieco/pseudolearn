---
{
  "formato": "see/1",
  "id": "APP.EXEC.SNAPSHOT-VIEW",
  "titulo": "Proyección del estado de ejecución",
  "dominio": "app",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-aplicacion"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "app"
  ],
  "resumen": "La vista preserva forma, identidad, relaciones y horizonte del estado consultado.",
  "depende_de": [
    {
      "id": "API.STATE.QUERY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.PROGRAM.VIEW",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.STATE.SNAPSHOT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "MEM.IDENTITY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.ARRAY.DIMENSION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution state projection"
}
---

# Proyección del estado de ejecución

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La tabla muestra el tipo de cada valor y preserva el estado sin valor. Un arreglo conserva su rango, dimensiones, índices desde cero y orden de celdas; una dimensión de tamaño cero se muestra como una colección vacía, no como ausencia.",
  "verificacion": ["C1", "C2"]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "snapshot", "input": {"program": "Algoritmo P\nDimension vacio[0] Como Entero;\nFinAlgoritmo\n", "query": "array"}},
  "espera": {"aplicacion": {"array": {"rank": 1, "dimensions": [0], "indices": [], "cells": []}}}
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "snapshot", "input": {"program": "Algoritmo P\nDimension matriz[2, 2] Como Entero;\nmatriz[0, 1] <- 7;\nFinAlgoritmo\n", "query": "array"}},
  "espera": {"aplicacion": {"array": {"rank": 2, "dimensions": [2, 2], "cells_by_index": {"0,0": {"uninitialized": true}, "0,1": {"value": "7"}, "1,0": {"uninitialized": true}, "1,1": {"uninitialized": true}}}}}
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un objeto se representa una vez por identidad y sus referencias se muestran como enlaces. Alias conservan la misma identidad; campos heredados conservan su origen; autorreferencias y ciclos mutuos no expanden recursivamente la vista.",
  "verificacion": ["C3", "C4"]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "snapshot", "input": {"program": "Clase Nodo\nPublico Definir siguiente Como Nodo;\nFinClase\nAlgoritmo P\nDefinir a, alias Como Nodo;\na <- Nuevo Nodo();\nalias <- a;\na.siguiente <- a;\nFinAlgoritmo\n", "query": "object_graph"}},
  "espera": {"aplicacion": {"references": {"a": "1", "alias": "1"}, "objects": {"1": {"class": "Nodo", "fields": {"siguiente": {"ref": "1"}}}}}}
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "snapshot", "input": {"program": "Clase Base\nPublico Definir valor Como Entero;\nFinClase\nClase Hija Hereda De Base\nFinClase\nAlgoritmo P\nDefinir x Como Hija;\nx <- Nuevo Hija();\nx.valor <- 9;\nFinAlgoritmo\n", "query": "object_graph"}},
  "espera": {"aplicacion": {"objects": {"1": {"class": "Hija", "fields": {"valor": {"value": "9", "declared_in": "Base"}}}}}}
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda proyección corresponde al evento solicitado y declara el horizonte retenido. Consultar un evento anterior al horizonte devuelve error de uso; consultar un evento vigente no cambia la continuación de la ejecución ni sus efectos.",
  "verificacion": ["C5"]
}
```

```caso
{
  "id": "C5",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "snapshot", "input": {"program": "Algoritmo P\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n", "retention_events": 1, "query_event": 0}},
  "espera": {"aplicacion": {"query": {"error": "usage"}, "continuation_unchanged": true}}
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Las colecciones grandes se consultan por páginas acotadas. Cada página declara si fue truncada y entrega un cursor opaco ligado a recurso, revisión, evento, consulta y límite; un cursor de otra consulta, evento, ejecución o recurso devuelve error de uso. La interfaz ofrece continuar, truncar o paginar explícitamente y nunca presenta un prefijo como colección completa.",
  "verificacion": ["C6", "C7"]
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "snapshot", "input": {"program": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n", "page_size": 2, "query": "array"}},
  "espera": {"aplicacion": {"first_page": {"indices": [0, 1], "truncated": true, "next_cursor": "opaque"}, "last_page": {"indices": [4], "truncated": false, "next_cursor": null}}}
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "snapshot", "input": {"program": "Algoritmo P\nDimension a[2] Como Entero;\nFinAlgoritmo\n", "page_size": 1, "reuse_cursor_for_event": 1}},
  "espera": {"aplicacion": {"next_query": {"error": "usage"}, "previous_page_unchanged": true}}
}
```
