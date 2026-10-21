---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.LOSSLESS-TREE",
  "titulo": "Árbol sin pérdida",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
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
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.LEXICAL.COMMENT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Lossless tree",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
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
