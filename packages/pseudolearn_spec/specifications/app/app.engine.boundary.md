---
{
  "formato": "see/1",
  "id": "APP.ENGINE.BOUNDARY",
  "titulo": "Frontera del motor de la app",
  "dominio": "app",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-aplicacion"
  ],
  "sujetos": [
    "app"
  ],
  "resumen": "El transporte Rust queda en engine y los recursos tienen propiedad y cierre explícitos.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.ERRORS",
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
      "id": "API.PROGRAM.VIEW",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Application engine boundary",
  "cambio": {
    "clase": "verificacion_anadida",
    "impacto_usuarios": "Se conserva la versión numérica autorizada.",
    "impacto_implementaciones": "Los casos de dirección de dependencias apuntan a archivos conservados y reales.",
    "justificacion": "El retiro elimina las rutas antiguas sin alterar el contrato de capas.",
    "revisado_por": "revision-independiente-automatizada"
  }
}
---

# Frontera del motor de la app

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Solo lib/engine consume la API Rust y sus enlaces nativos o Wasm. Los contratos de domain/model, domain/ports y application no contienen ni importan tipos del motor, del transporte o generados; composition selecciona adaptadores y presentation consume solo estado de aplicación.",
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
  "aplicacion": {
    "scenario": "boundary",
    "input": {"file": "lib/domain/model/analysis/source_range.dart", "import": "package:pseudolearn_app/engine/bridge/frb_generated.dart"}
  },
  "espera": {"aplicacion": {"accepted": false, "reason": "layer_direction"}}
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
  "aplicacion": {
    "scenario": "boundary",
    "input": {"file": "lib/engine/rust/rust_program_analyzer.dart", "import": "package:pseudolearn_app/engine/bridge/frb_generated.dart"}
  },
  "espera": {"aplicacion": {"accepted": true, "reason": "engine_adapter"}}
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los adaptadores Dart y Rust satisfacen los mismos puertos segregados y devuelven exclusivamente modelos del dominio. La app no reimplementa análisis, ejecución, completado, semántica ni recorridos del lenguaje; los emisores, diagramas y comprobaciones estructurales consumen API.PROGRAM.VIEW.",
  "verificacion": ["C3"]
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
  "aplicacion": {
    "scenario": "boundary",
    "input": {"port": "ProgramAnalyzer", "adapters": ["dart", "rust"], "output_type": "ProgramAnalysis"}
  },
  "espera": {"aplicacion": {"same_port_contract": true, "language_logic_in_app": false}}
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Cada recurso pertenece a una sesión y a una revisión. Liberar un documento libera análisis y ejecuciones descendientes; volver a liberar un identificador, consultar uno desconocido o negociar una versión incompatible devuelve un error tipado sin alterar otros recursos.",
  "verificacion": ["C4", "C5", "C6"]
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "boundary",
    "input": {"operations": ["create_document", "create_analysis", "start", "release_document", "release_document"]}
  },
  "espera": {"aplicacion": {"descendants_released": true, "second_release": {"error": "usage"}}}
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
  "aplicacion": {
    "scenario": "boundary",
    "input": {"operation": "negotiate", "protocol": "see-protocol/99", "resource_count_before": 0}
  },
  "espera": {"aplicacion": {"error": "version", "resource_count_after": 0}}
}
```

```caso
{
  "id": "C6",
  "regla": "R3",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "boundary",
    "input": {"operation": "query", "resource_id": "unknown", "resource_count_before": 1}
  },
  "espera": {"aplicacion": {"error": "usage", "unrelated_resources_unchanged": true, "resource_count_after": 1}}
}
```
