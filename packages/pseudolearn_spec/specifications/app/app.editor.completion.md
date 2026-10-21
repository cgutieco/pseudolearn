---
{
  "formato": "see/1",
  "id": "APP.EDITOR.COMPLETION",
  "titulo": "Completado en el editor",
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
  "resumen": "El editor consume el servicio Rust y mantiene posiciones, revisiones y perfiles coherentes.",
  "depende_de": [
    {
      "id": "TOOL.SERVICE.COMPLETION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.VERSIONING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.WIRE-FORMAT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SOURCE.POSITION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
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
  "verificacion": [
    "C5"
  ]
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
  "verificacion": [
    "C6"
  ]
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

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El ajuste de asistencia de edición es una preferencia de dispositivo desactivada por omisión. Desactivado, el editor no solicita completado al teclear, no solicita asistencia al teclear y no muestra lista emergente ni sugerencia en línea; la invocación explícita y la fila de plantillas siguen disponibles. Activado, solicita ambas ante cada pulsación. La presentación elige una sola superficie con la capacidad de entrada, presencia de teclado y disponibilidad de la banda, sin condicionales de sistema operativo en los widgets: con banda disponible se muestran candidatos táctiles y se suprimen el fantasma y la lista flotante; sin banda se conserva la asistencia anclada y sus atajos. Cada candidato táctil muestra la primera línea del texto que insertará, sin espacios finales, y conserva su identidad al aceptarlo. El fantasma comparte las métricas tipográficas del campo y alinea su línea base con la del texto escrito; el anclaje se actualiza con el desplazamiento.",
  "verificacion": [
    "C7",
    "C8",
    "C9",
    "C13",
    "C14",
    "C15"
  ]
}
```

```caso
{
  "id": "C7",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "edit_assistance",
    "input": {
      "query": "default"
    }
  },
  "espera": {
    "aplicacion": {
      "assistance_enabled": false
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "edit_assistance",
    "input": {
      "assistance_enabled": false,
      "document": "Algoritmo P\n  Mientras x < 1 Hacer\n\nFinAlgoritmo\n",
      "cursor_utf16": 35,
      "character": "\n"
    }
  },
  "espera": {
    "aplicacion": {
      "on_type_requested": false,
      "document_changed": false
    }
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "edit_assistance",
    "input": {
      "assistance_enabled": true,
      "document": "Algoritmo P\n  Mientras x < 1 Hacer\n\nFinAlgoritmo\n",
      "cursor_utf16": 35,
      "character": "\n"
    }
  },
  "espera": {
    "aplicacion": {
      "on_type_requested": true,
      "document_changed": true
    }
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El editor aplica al búfer, sin interpretarlas, las ediciones que el servicio devuelve al aceptar un candidato y al teclear, y convierte sus posiciones entre UTF-8 y UTF-16. No contiene lógica de sangría, cierre de bloques, terminador ni pares.",
  "verificacion": [
    "C10",
    "C12"
  ]
}
```

```caso
{
  "id": "C10",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "accept_candidate",
    "input": {
      "document": "Algoritmo P\n  Mie\nFinAlgoritmo\n",
      "cursor_utf16": 17,
      "profile": "es",
      "candidate": "Mientras"
    }
  },
  "espera": {
    "aplicacion": {
      "document_after": "Algoritmo P\n  Mientras condicion Hacer\n    \n  FinMientras\nFinAlgoritmo\n",
      "selection_utf16": [
        23,
        32
      ]
    }
  }
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El editor navega las paradas de una plantilla aceptada con las operaciones de navegación del servicio y no conserva rangos propios. Salir de la última parada termina la sesión de plantilla.",
  "verificacion": [
    "C11"
  ]
}
```

```caso
{
  "id": "C11",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "template_navigation",
    "input": {
      "document": "Algoritmo P\n  Par\nFinAlgoritmo\n",
      "cursor_utf16": 17,
      "profile": "es",
      "candidate": "Para",
      "steps": [
        "next",
        "next"
      ]
    }
  },
  "espera": {
    "aplicacion": {
      "selected_texts": [
        "indice",
        "limite"
      ],
      "session_ended": true
    }
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "accept_candidate",
    "input": {
      "document": "Algoritmo P\n  Definir segundos Como Entero;\n  segundos\nFinAlgoritmo\n",
      "cursor_utf16": 54,
      "profile": "es",
      "candidate": "segundos"
    }
  },
  "espera": {
    "aplicacion": {
      "document_after": "Algoritmo P\n  Definir segundos Como Entero;\n  segundos <- \nFinAlgoritmo\n",
      "selection_utf16": [
        58,
        58
      ]
    }
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "edit_assistance",
    "input": {
      "query": "presentation",
      "document": "Algoritmo P\n  Definir area Como Real;\n  area\nFinAlgoritmo\n",
      "cursor_utf16": 44,
      "onscreen_capable": true,
      "keyboard_visible": true
    }
  },
  "espera": {
    "aplicacion": {
      "uses_suggestion_bar": true,
      "allows_anchored_assistance": false,
      "insertion_preview": "area <-"
    }
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "edit_assistance",
    "input": {
      "query": "presentation",
      "document": "Algoritmo P\n  Definir area Como Real;\n  area\nFinAlgoritmo\n",
      "cursor_utf16": 44,
      "onscreen_capable": true,
      "keyboard_visible": false
    }
  },
  "espera": {
    "aplicacion": {
      "uses_suggestion_bar": false,
      "allows_anchored_assistance": true,
      "insertion_preview": "area <-"
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "edit_assistance",
    "input": {
      "query": "presentation",
      "document": "Algoritmo P\n  Definir area Como Real;\n  area\nFinAlgoritmo\n",
      "cursor_utf16": 44,
      "onscreen_capable": false,
      "keyboard_visible": true
    }
  },
  "espera": {
    "aplicacion": {
      "uses_suggestion_bar": false,
      "allows_anchored_assistance": true,
      "insertion_preview": "area <-"
    }
  }
}
```
