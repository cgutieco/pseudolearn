---
name: code-quality
description: Estándar de calidad de código de PseudoLearn. Usar antes de dar por terminado cualquier archivo de código, y al revisar código escrito por otro. Cubre la política de comentarios (código autosustentable, sin comentarios de ruido, prohibido citar documentos), el idioma obligatorio, y la lista concreta de defectos que se rechazan en revisión.
---

# Calidad de código

## La regla que sostiene todas las demás

**El código lleva casi ningún comentario porque el *por qué* está en el `README.md` del paquete.**

Hay que entender la política completa o degenera. Quitar comentarios sin escribir la documentación no
es limpieza, es pérdida de información. Las dos mitades van juntas:

1. El código dice **qué** hace y **cómo**, con nombres y estructura. No necesita traducción.
2. El `README.md` del paquete dice **por qué** es así, qué se descartó y con qué razón.

Si al escribir sientes la necesidad de explicar una decisión en un comentario, la decisión va al
README. Si sientes la necesidad de explicar qué hace una línea, el problema es la línea.

## Idioma

- **Todo el código en inglés**: nombres de tipo, de variable, de función, de archivo, de test, más los
  comentarios que sobrevivan y los mensajes de commit.
- **Toda la documentación en español**: `AGENTS.md`, los `README.md`, las skills, los documentos de
  `docs/`.
- El léxico del pseudocódigo en español es **dato**, nunca identificadores de código. Un lexema en
  español dentro de un archivo `.dart` fuera de los datos del perfil es un fallo.

## Comentarios

**Prohibido:**

- El comentario que repite la línea siguiente. `// increment the counter` sobre `counter++`.
- El comentario que traduce un nombre. Si hace falta traducirlo, el nombre está mal.
- **La referencia a un documento o a una sección.** Ni `// ver AGENTS.md §2`, ni `// según el README`,
  ni `// regla LAYER-DIRECTION`. Los documentos se reordenan y se reescriben, y el comentario queda
  mintiendo con total confianza, que es peor que no existir. Se describe la restricción en sí, nunca
  dónde está escrita.
- El comentario de sección que divide un archivo en bloques. Si un archivo necesita separadores
  visuales, son dos archivos.
- El código comentado. Se borra; el historial de git lo conserva.
- El `TODO` sin dueño ni condición de cierre.
- La cabecera de licencia o de autoría en cada archivo.
- El comentario de documentación que solo repite la firma de la función.

**Admisible, y solo esto:**

- Un *por qué* local y no evidente: una decisión contraintuitiva, un orden de operaciones que importa,
  un caso límite que parece un error y no lo es, un rendimiento que justifica una forma menos obvia.
- Documentación pública en la frontera exportada del paquete, cuando explica el contrato y no la
  implementación.

Prueba antes de escribir un comentario: **si renombrando algo o extrayendo una función el comentario
sobra, hazlo en vez de escribirlo.**

## Defectos que se rechazan en revisión

**Estructura**

- La función que hace dos cosas. Si su nombre necesita un «y», son dos funciones.
- El archivo que no se resume en una frase sin «y».
- La anidación que pasa del límite del paquete. Se extrae una función con nombre, o se invierte la
  condición y se sale temprano.
- El `else` que sobra después de un retorno.
- La función larga que en realidad son tres pasos con nombre esperando a ser extraídos.
- La clase con más métodos públicos de los que el paquete permite: tiene más de una responsabilidad.

**Firmas**

- El parámetro booleano que selecciona comportamiento. Son dos funciones con nombres distintos.
- Más parámetros posicionales de los que permite el paquete. Se pasa un objeto de parámetros con
  nombre.
- El parámetro opcional que nadie usa, o el que existe «para el futuro».
- El valor de retorno que puede ser nulo sin que el tipo lo declare.

**Nombres**

- La abreviatura que no es un estándar universal. `idx`, `tmp`, `res`, `val`, `cfg`.
- El nombre de una letra fuera de un índice de bucle trivial.
- El nombre que miente porque el código cambió y el nombre no.
- El sufijo vacío: `Manager`, `Helper`, `Utils`, `Data`, `Info`, `Processor`. Si no sabes cómo llamarlo,
  probablemente no sabes qué es.
- El plural o el singular incorrecto en una colección.

**Alcance**

- La abstracción de un solo uso. Una interfaz con una implementación y ninguna razón declarada para una
  segunda.
- El punto de extensión que ninguna fase aprobada pide.
- El código muerto conservado «por si acaso».
- La generalización que solo tiene sentido para soportar algo que está fuera de alcance.

**Datos frente a ramas**

- El condicional sobre «qué configuración es» —qué perfil, qué política, qué modo—. Eso pertenece a los
  datos que se inyectan, no al código que los consume. Es la señal más fiable de que el diseño se está
  cerrando a la extensión.
- La constante repetida en dos sitios que en realidad es un dato de configuración.

**Errores**

- La excepción que cruza la frontera pública del paquete. Un fallo esperable es un valor de retorno.
- El `catch` que se traga el error sin actuar.
- El mensaje de error construido con concatenación de texto en una capa que no tiene esa
  responsabilidad.

## Antes de dar un archivo por terminado

1. ¿Puedo describir qué hace en una frase sin «y»?
2. ¿Sobra algún comentario según la lista de prohibidos?
3. ¿Falta alguna decisión por documentar en el `README.md` del paquete?
4. ¿Hay algún nombre que necesite un comentario para entenderse?
5. ¿Está en inglés, entero?
6. ¿Pasa los verificadores del paquete?
7. ¿Tiene test de camino feliz **y** de camino infeliz, más los casos límite?
