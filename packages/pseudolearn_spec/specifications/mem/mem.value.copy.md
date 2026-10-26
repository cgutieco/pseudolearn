---
{
  "formato": "see/1",
  "id": "MEM.VALUE.COPY",
  "titulo": "Copia y compartición de valores",
  "dominio": "memoria",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Qué se copia al asignar y al pasar argumentos.",
  "depende_de": [
    {
      "id": "MEM.IDENTITY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.PARAMETERS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LIB.CORE.COPY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Value copy and sharing",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Copia y compartición de valores

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los valores primitivos y las cadenas se copian al asignar y al pasar por valor: modificar la variable de origen después no cambia la copia.",
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
    "salida": "1:ab\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nDefinir Mutable z Como Entero <- 0;\nDefinir Mutable s Como Cadena <- \"\";\nDefinir Mutable t Como Cadena <- \"\";\nz <- 1;\nx <- z;\nz <- 2;\nt <- \"ab\";\ns <- t;\nt <- t + \"c\";\nEscribir x, \":\", s;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los objetos se comparten al asignar y al pasar por valor, y los arreglos se pasan por referencia: las escrituras a través de cualquier nombre son visibles por todos.",
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
    "salida": "9\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso poner(datos[] Como Entero)\ndatos[0] <- 9;\nFinSubProceso\nAlgoritmo P\nDimension a[1] Como Entero;\na[0] <- 1;\nponer(a);\nEscribir a[0];\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Copiar crea un objeto nuevo y copia un solo nivel: los campos primitivos se copian y los campos de referencia se comparten con el original.",
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
    "salida": "1:7\n",
    "terminacion": "completed"
  },
  "programa": "Clase C\nPublico Definir valor Como Entero;\nPublico Definir otro Como C;\nFinClase\nAlgoritmo P\nDefinir a Como C <- Nuevo C();\na.valor <- 1;\na.otro <- Nuevo C();\nDefinir b Como C <- Copiar(a);\nb.valor <- 2;\nb.otro.valor <- 7;\nEscribir a.valor, \":\", a.otro.valor;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un parámetro por referencia es un alias de su destino: dos parámetros por referencia al mismo destino observan cada escritura del otro de inmediato.",
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
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso dos(a Como Entero Por Referencia, b Como Entero Por Referencia)\na <- 1;\nEscribir b;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable x Como Entero <- 0;\nx <- 0;\ndos(x, x);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

## Colecciones e interfaces

Vector y Diccionario se asignan y pasan por valor copiando la referencia a la misma cabecera. Los alias comparten cambios, versión e identidad aun al sustituirse los bancos durante el crecimiento. Leer o reemplazar un elemento copia su valor según su tipo: las hojas escalares de un registro son independientes y sus referencias conservan alias. Eliminar borra enlaces de valores y claves descartados; no conserva raíces ocultas. Snapshots y deltas contienen cabecera, bancos e índice y restauran orden y versión sin tablas laterales.
