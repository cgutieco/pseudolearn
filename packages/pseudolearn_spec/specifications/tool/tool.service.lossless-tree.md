---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.LOSSLESS-TREE",
  "titulo": "Árbol sin pérdida",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "engine",
    "service"
  ],
  "resumen": "Reimprimir el árbol reproduce exactamente el texto.",
  "depende_de": [
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.LEXICAL.COMMENT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Lossless tree",
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "No cambia el texto aceptado ni la obligación de reimpresión exacta.",
    "impacto_implementaciones": "engine declara la obligación de árbol sin pérdida en R4; service conserva la misma obligación. Las propiedades requieren evidencia ejecutada, no solo presencia de árbol.",
    "justificacion": "Alinear los sujetos declarados con el ejecutor engine ya exigido por P1 y P2; explicitar que el BOM se conserva como prefijo sin ser un token del lenguaje y que el dominio es texto UTF-8 válido.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
}
---

# Árbol sin pérdida

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Para todo texto fuente UTF-8 válido, la reimpresión del árbol conserva el prefijo BOM inicial, que no es un token del lenguaje, y concatena los fragmentos originales de sus tokens, trivia (espacios, saltos de línea y comentarios) y fragmentos con error, reproduciendo exactamente el texto original byte a byte. La entrada UTF-8 inválida es un fallo de entrada según LANG.SOURCE.ENCODING y no se decodifica con pérdida para construir un árbol.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "todos los programas del corpus en los dos perfiles, con y sin BOM, con CRLF y CR, y mutaciones que insertan caracteres no reconocidos, literales sin cierre y bloques sin cerrar"
  },
  "propiedad": "reimprimir(analizar(t)) = t.",
  "oraculo": "Igualdad de bytes con el texto de entrada.",
  "justificacion": "La ejecuta el sujeto engine en R4 a través del árbol sintáctico."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todo texto fuente UTF-8 válido produce un árbol, también el vacío y el que solo contiene trivia o errores; la reimpresión del árbol nunca omite un fragmento del texto, incluido su prefijo BOM cuando existe.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "programas": "texto vacío, solo trivia, solo errores y textos aleatorios de hasta 4 KiB"
  },
  "propiedad": "El análisis devuelve árbol y la reimpresión es exacta.",
  "oraculo": "Igualdad de bytes.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```
