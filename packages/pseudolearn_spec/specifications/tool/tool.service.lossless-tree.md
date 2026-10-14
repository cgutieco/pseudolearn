---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.LOSSLESS-TREE",
  "titulo": "Árbol sin pérdida",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
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
  "titulo_en": "Lossless tree"
}
---

# Árbol sin pérdida

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Para todo texto fuente, la concatenación de los textos de los tokens del árbol, incluida la trivia (espacios, saltos de línea, comentarios y BOM) y los fragmentos con error, es exactamente el texto original byte a byte.",
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
  "texto": "Todo texto produce un árbol, también el vacío y el que solo contiene trivia o errores; el árbol nunca omite un fragmento del texto.",
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
