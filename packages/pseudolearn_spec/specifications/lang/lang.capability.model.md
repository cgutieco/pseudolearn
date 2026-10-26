---
{
  "formato": "see/1",
  "id": "LANG.CAPABILITY.MODEL",
  "titulo": "Modelo de capacidades explícitas",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Tipos de capacidad opacos, denegación por defecto, atenuación sin amplificación e invalidación por cierre.",
  "titulo_en": "Explicit capability model",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "RT.HOST.INTERFACE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Modelo de capacidades explícitas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las capacidades son valores opacos en el banco de referencias correspondientes a los tipos bilingües Consola/Console, Argumentos/Arguments, DirectorioCap/DirCap, ArchivoCap/FileCap, Reloj/Clock y Temporizador/Timer. Cada capacidad posee ranura, generación y máscara de derechos, impidiendo la falsificación o manipulación directa de descriptores de bajo nivel.",
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
    "salida": "capacidad_valida\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"capacidad_valida\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Rige la denegación por defecto: un programa no posee autoridad ambiental implícita. Las capacidades deben solicitarse en el manifiesto del proyecto o proveerse explícitamente por el anfitrión mediante la intersección de autoridad solicitada y concedida. Todo acceso a un recurso sin permiso concedido es denegado deterministamente.",
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
    "salida": "denegado\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"denegado\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las capacidades de directorio permiten atenuar derechos y derivar subcapacidades para rutas lógicas hijas sin amplificación (los derechos de la hija son subconjunto estricto o igual a los del padre). Cualquier intento de solicitar derechos adicionales o escapar de la raíz mediante componentes de ruta especiales como .. o rutas absolutas es rechazado deterministamente.",
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
    "salida": "atenuacion_segura\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"atenuacion_segura\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cerrar una capacidad de archivo o directorio incrementa su número de generación en la tabla de capacidades. Cualquier uso posterior de una capacidad con generación obsoleta produce deterministamente el error CapacidadCerrada.",
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
    "salida": "cerrado\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir \"cerrado\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```
