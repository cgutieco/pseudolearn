---
{
  "formato": "see/1",
  "id": "APP.EDITOR.COMPLETION",
  "titulo": "Completado en el editor",
  "dominio": "app",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": ["responsable-aplicacion"],
  "sujetos": ["app"],
  "resumen": "El editor consume el servicio Rust y mantiene posiciones, revisiones y perfiles coherentes.",
  "depende_de": [
    {"id": "TOOL.SERVICE.COMPLETION", "version": ">=0.1.0, <1.0.0", "tipo": "usa"},
    {"id": "API.VERSIONING", "version": ">=0.1.0, <1.0.0", "tipo": "usa"},
    {"id": "API.WIRE-FORMAT", "version": ">=0.1.0, <1.0.0", "tipo": "usa"},
    {"id": "LANG.SOURCE.POSITION", "version": ">=0.1.0, <1.0.0", "tipo": "usa"}
  ],
  "titulo_en": "Editor completion"
}
---

# Completado en el editor

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El editor consulta TOOL.SERVICE.COMPLETION con el texto, revisión, perfil del pseudocódigo y posición del cursor actuales. No mantiene una tabla paralela de palabras, firmas, ámbitos ni candidatos.",
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
  "aplicacion": {"scenario": "completion", "input": {"document": "Algoritmo P\nDefinir total Como \nFinAlgoritmo\n", "cursor_utf16": 31, "profile": "es", "interface_language": "en"}},
  "espera": {"aplicacion": {"candidates_include": ["Entero", "Real", "Logico", "Caracter", "Cadena"], "source": "TOOL.SERVICE.COMPLETION"}}
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["en"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "completion", "input": {"document": "algorithm P\nwrite \"🧩\";\nendAlgorithm\n", "cursor_utf16": 21, "profile": "en", "interface_language": "es"}},
  "espera": {"aplicacion": {"position_unit": "utf16", "service_position_unit": "utf8", "candidate_matches_service": true}}
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El cursor del editor se expresa en unidades de código UTF-16 desde cero. El adaptador convierte el límite seleccionado a desplazamiento UTF-8 para el servicio y convierte cada tramo de edición devuelto a UTF-16. Un cursor dentro de un par sustituto se rechaza sin solicitar candidatos ni modificar el documento.",
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
  "aplicacion": {"scenario": "completion", "input": {"document": "Algoritmo P\nEscribir \"🧩\";\nFinAlgoritmo\n", "cursor_utf16": 24, "expected_boundary": "after_supplementary_scalar"}},
  "espera": {"aplicacion": {"service_offset_utf8": 26, "round_trip_utf16": 24}}
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
  "aplicacion": {"scenario": "completion", "input": {"document": "Algoritmo P\nEscribir \"🧩\";\nFinAlgoritmo\n", "cursor_utf16": 23, "invalid_reason": "inside_surrogate_pair"}},
  "espera": {"aplicacion": {"error": "usage", "request_sent": false, "document_changed": false}}
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada solicitud de completado se asocia a una revisión monotónica del documento. Una respuesta de una revisión sustituida se descarta aunque llegue después y no puede alterar candidatos, selección ni texto de la revisión vigente.",
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
  "aplicacion": {"scenario": "completion", "input": {"requests": [{"revision": 1, "document": "Algoritmo P\nDefinir x Como \nFinAlgoritmo\n"}, {"revision": 2, "document": "Algoritmo P\nDefinir x Como Real;\nFinAlgoritmo\n"}], "responses": [2, 1]}},
  "espera": {"aplicacion": {"visible_revision": 2, "stale_response_applied": false}}
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El perfil del pseudocódigo y el idioma de interfaz son parámetros independientes. Cambiar el idioma de interfaz solo cambia la prosa y etiquetas localizadas; no cambia los lexemas, firmas, identidad ni orden normativo de candidatos del perfil activo.",
  "verificacion": ["C6"]
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": ["es", "en"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {"scenario": "completion", "input": {"document": "Algoritmo P\nFinAlgoritmo\n", "profile": "es", "interface_languages": ["es", "en"], "query": "algorithm_header"}},
  "espera": {"aplicacion": {"candidate_lexemes_equal": true, "localized_labels_may_differ": true}}
}
```
