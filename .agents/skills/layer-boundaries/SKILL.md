---
name: layer-boundaries
description: Decidir en qué capa vive un archivo nuevo y qué puede importar, antes de escribir la primera línea. Usar al crear cualquier archivo, al añadir un import, y cuando un cambio parece necesitar acceso a algo de una capa superior. Lee las reglas del architecture.yaml del paquete en el que se está trabajando.
---

# Fronteras de capa

## Antes de crear el archivo

1. **Identificá el paquete** y abrí su `architecture.yaml`. Las capas y la matriz de imports permitidos
   son distintas en cada paquete: el núcleo del lenguaje y la app de Flutter no comparten arquitectura.
2. **Respondé las tres preguntas**, en este orden:
    - ¿En qué capa vive este archivo?
    - ¿Qué puede importar esa capa, y qué tiene prohibido importar?
    - ¿La responsabilidad que voy a escribir ya tiene un archivo dueño, o estoy creando una segunda
      razón de cambio en un archivo que ya tenía una?
3. Si la tercera respuesta es «estoy mezclando», el código va en un archivo nuevo en la capa que le
   corresponde. No en el archivo que tenías abierto porque era cómodo.

## Cómo decidir la capa

No preguntes «dónde encaja mejor». Preguntá **qué necesita saber para funcionar**, y ponelo en la capa
más interna que se lo permita. El código gravita hacia fuera solo, y cada gramo que se queda dentro es
un consumidor futuro que no se rompe.

Dos preguntas que resuelven casi todos los casos:

- **¿Describe un dato o hace algo con un dato?** Lo que solo describe va a la capa de dominio. Un tipo
  con un método que decide comportamiento —no que construye ni valida datos— no pertenece ahí.
- **¿Quién lo consume?** Si lo consumen dos capas distintas, pertenece a una común más interna, no
  duplicado en las dos ni en la más externa de ellas.

## Cuando parece que hace falta importar hacia arriba

Casi nunca es cierto, y la salida correcta casi siempre es una de estas tres:

- **Invertir la dependencia.** La capa interna define una interfaz de lo que necesita; la externa la
  implementa y se la inyecta. Es la salida correcta para «el evaluador necesita avisar a alguien».
- **Mover el tipo hacia dentro.** Si dos capas necesitan nombrar el mismo concepto, el concepto está
  mal ubicado, no la regla. El caso típico: una enumeración que la capa de presentación necesita
  nombrar tiene que vivir en dominio, no en la capa que la usa para trabajar.
- **Partir la responsabilidad.** Lo que parece una necesidad de subir suele ser un archivo que hace dos
  cosas, una de las cuales sí pertenece arriba.

Si ninguna de las tres aplica, **paralo y reportalo**. Una violación de capa no se negocia con un
comentario que la justifique.

## Imports

- Dentro del código fuente del paquete, los imports son **relativos**. Un import del propio paquete por
  `package:` oculta la capa de origen y hace indetectable la violación.
- El archivo de entrada público es el único que exporta. Nada de exportar desde dentro.
- Un `export` de una capa superior es exactamente la misma violación que un `import`.
- Los imports de plataforma prohibidos por el `architecture.yaml` lo están en todo el código fuente,
  sin excepción de carpeta. Son lo que garantiza los objetivos de compilación del paquete.

## Verificación

El test de arquitectura del paquete comprueba esto mecánicamente y falla el build. No es una convención
de honor. Si tu cambio lo hace fallar, la respuesta no es ajustar el test.
