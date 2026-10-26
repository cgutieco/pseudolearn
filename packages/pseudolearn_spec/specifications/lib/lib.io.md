---
{
  "formato": "see/1",
  "id": "LIB.IO",
  "titulo": "Tipos y operaciones de entrada y salida",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Tipo Bytes, variantes portables de ErrorES, separación estricta texto/binario y limpieza con Diferir.",
  "titulo_en": "Input and output types and operations",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CONTROL.CLEANUP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Tipos y operaciones de entrada y salida

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El tipo incorporado Bytes representa una secuencia contigua y gestionada de octetos en el montón. Proporciona longitud y acceso posicional seguro impidiendo corrupciones de memoria.",
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
    "salida": "bytes_ok\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nEscribir \"bytes_ok\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"bytes_ok\";\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El tipo ErrorES modela de manera portable los errores de entrada y salida con variantes para NoEncontrado, PermisoDenegado, YaExiste, FinDeArchivo, Utf8Invalido, RutaInvalida, CapacidadCerrada, TiempoAgotado e Interrumpido, junto a una bandera booleana incierto para indicar incertidumbre sobre si la mutación externa llegó a confirmarse.",
  "verificacion": [
    "C2"
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
    "salida": "error_es_ok\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nEscribir \"error_es_ok\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"error_es_ok\";\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las operaciones de lectura y escritura textual sobre capacidades exigen validación UTF-8 estricta. Todo contenido no conforme con UTF-8 produce ErrorES::Utf8Invalido sin sustitución silenciosa de bytes inválidos.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
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
    "salida": "utf8_validado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nEscribir \"utf8_validado\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"utf8_validado\";\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La sentencia Diferir ejecuta la limpieza léxica al salir del ámbito, retornar o propagar errores con Propagar. Si ocurre un fallo en la operación primaria, la limpieza se ejecuta y preserva el ErrorES primario intacto sin ocultarlo.",
  "verificacion": [
    "C4"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
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
    "salida": "limpieza_diferir_ok\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nDiferir\nEscribir \"limpieza_diferir_ok\";\nFinDiferir\nFinAlgoritmo\n",
    "en": "algorithm P\ndefer\nwrite \"limpieza_diferir_ok\";\nendDefer\nendAlgorithm\n"
  }
}
```
