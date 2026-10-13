# 08 · Módulos, paquetes, monorepos, aliases y eliminación de código

> **Estado:** investigación, no normativo. Los formatos de manifiesto y las formas de importación
> son
> **propuestas ilustrativas**. La interpretación de «evitar el tree shaking» **no se ha resuelto**:
> requiere respuesta de la persona responsable ([D-08](17-riesgos-preguntas-y-decisiones.md#d-08)).

Responde a V-35 a V-39.

---

## 1. Nueve problemas que suelen confundirse

La visión pide no suponer que aliases, monorepos y *tree shaking* son el mismo problema (V-39). De
hecho son al menos nueve, con dueños distintos:

| Problema                          | Pregunta que responde                                                                 | Dueño natural                       |
|-----------------------------------|---------------------------------------------------------------------------------------|-------------------------------------|
| **Módulo**                        | ¿Cuál es la unidad de nombres y de visibilidad?                                       | Lenguaje                            |
| **Importación**                   | ¿Cómo nombra un módulo a otro y qué trae?                                             | Lenguaje                            |
| **Inicialización**                | ¿Qué ocurre al cargar un módulo? ¿Puede tener efectos?                                | Lenguaje                            |
| **Paquete**                       | ¿Cuál es la unidad de versión y de distribución?                                      | Ecosistema                          |
| **Espacio de trabajo (monorepo)** | ¿Cómo se desarrollan varios paquetes juntos con una sola resolución?                  | Ecosistema                          |
| **Resolución**                    | ¿A qué archivo corresponde una importación, y qué versión de cada dependencia se usa? | Ecosistema (algoritmo especificado) |
| **Alias**                         | ¿Cómo se acorta una ruta larga de importación?                                        | Ecosistema (forma en el lenguaje)   |
| **Construcción**                  | ¿Qué se compila, en qué orden, qué se reutiliza de la caché?                          | Herramientas                        |
| **Eliminación de código**         | ¿Qué de lo importado acaba en el artefacto?                                           | Compilador                          |

Y un décimo transversal: **coherencia**, que el compilador, el servidor de lenguaje, la app y
cualquier editor resuelvan exactamente igual.

---

## 2. Qué resuelve el lenguaje y qué su ecosistema

**Lenguaje (en la especificación):** qué es un módulo (propuesta: un archivo), las formas de
importación y su significado, la visibilidad de módulo, la política de ciclos entre módulos, y la
**semántica de inicialización**. Este último punto, que parece menor, decide si la eliminación de
código puede cambiar el significado de un programa (§6).

**Ecosistema (también especificado, pero como herramienta):** formato del manifiesto, espacio de
trabajo, archivo de bloqueo, algoritmo de selección de versiones, declaración de aliases, registro y
distribución.

**Zona gris resuelta así (propuesta):** la **forma** de una importación por alias es del lenguaje
(`Importar "@comun/texto"`); el **mapa** de alias a ruta es del manifiesto; y la función que
convierte una importación en un archivo es **una única biblioteca de resolución** especificada,
usada por todas las herramientas.

---

## 3. Precedentes

| Ecosistema   | Mecanismo                                                                                                                                                                                        | Lo que se aprende                                                                                                                                                                               |
|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Go           | Módulo (`go.mod`) ⊃ paquete (directorio); espacios de trabajo `go.work` (Go 1.18, 2022); selección de versión mínima (MVS, R. Cox, 2018); directorios `internal/`; ciclos de paquetes prohibidos | Resolución predecible sin resolver de restricciones; visibilidad por ubicación; espacios de trabajo sin tocar los módulos                                                                       |
| Rust (Cargo) | *Crate* con árbol de módulos; espacio de trabajo con un solo `Cargo.lock`; dependencias por ruta; *features*                                                                                     | Archivo de bloqueo único para el espacio de trabajo; las *features* aditivas complican la resolución                                                                                            |
| Dart (pub)   | `package:`; espacios de trabajo pub (Dart 3.6, 2024): un `pubspec.lock` en la raíz y un solo contexto del analizador                                                                             | El analizador gana memoria al compartir contexto; migración sencilla desde paquetes por ruta                                                                                                    |
| TypeScript   | `paths` en `tsconfig.json`; referencias de proyecto                                                                                                                                              | `paths` lo entiende el compilador de tipos pero **no reescribe** las importaciones emitidas: el entorno de ejecución y el empaquetador necesitan otra configuración. Comodidad con incoherencia |
| Node.js      | `imports` de `package.json` (alias `#…` resueltos por el propio entorno); `exports`                                                                                                              | Alias resueltos por el mismo componente que ejecuta: coherentes                                                                                                                                 |
| Deno         | Mapas de importación (estándar WHATWG); espacios de trabajo                                                                                                                                      | Un solo mapa para editor y ejecución                                                                                                                                                            |
| Bazel, Buck  | Sistemas de construcción herméticos para monorepos grandes                                                                                                                                       | Reproducibilidad a costa de complejidad; adecuado a otra escala                                                                                                                                 |

**Lecciones [INFERENCIA]:**

1. La comodidad de `paths` es real; su defecto es que lo resuelve **una** herramienta y no las
   demás. PseudoLearn puede tener la comodidad sin el defecto si el compilador produce artefactos
   con las importaciones ya resueltas y todas las herramientas usan el mismo resolutor.
2. Un solo archivo de bloqueo por espacio de trabajo (Cargo, pub 3.6) es lo que hace sencillo un
   monorepo.
3. La selección de versión mínima de Go da resoluciones reproducibles y explicables, adecuadas para
   quien aprende («se usa la versión más baja que satisface a todos»).

---

## 4. Monorepos con soporte nativo (propuesta)

Un **espacio de trabajo** es un directorio con un manifiesto que lista paquetes miembros. Todos
comparten resolución, archivo de bloqueo, edición por omisión y aliases.

```toml
# pseudo.toml en la raíz del espacio de trabajo (PROPUESTA ILUSTRATIVA)
[espacio]
miembros = ["paquetes/*", "aplicaciones/*"]
edicion = "2027"
perfil = "es"

[alias]
"@comun" = "paquetes/comun/fuente"
"@modelo" = "paquetes/modelo/fuente"
```

```toml
# paquetes/facturacion/pseudo.toml (PROPUESTA ILUSTRATIVA)
[paquete]
nombre = "facturacion"
version = "0.3.0"

[dependencias]
comun = { espacio = true }
texto-csv = "^1.2"
```

Reglas propuestas:

- Una dependencia `espacio = true` se resuelve al miembro del espacio, nunca al registro.
- **Sin ciclos entre paquetes** (como Go). Dentro de un paquete, los ciclos entre módulos se admiten
  si la inicialización no tiene efectos (§6.3), porque entonces el orden no es observable.
- El archivo de bloqueo vive en la raíz, con hashes de integridad.
- El formato del manifiesto (TOML, YAML u otro) y los nombres de sus claves son decisión pendiente;
  el ejemplo usa claves en español por coherencia con la identidad, y tendría alias en inglés.

---

## 5. Aliases de rutas (propuesta)

- **Forma en el lenguaje:** cadena que empieza por `@` en `Importar`, sin significado para el
  lenguaje más allá de «nombre que el resolutor expande».
- **Definición:** solo en manifiestos (espacio de trabajo o paquete), apuntando a directorios
  **dentro**
  del espacio de trabajo o a dependencias declaradas; nunca a rutas arbitrarias del disco.
- **Resolución:** una biblioteca, especificada con casos ejecutables, usada por compilador, servidor
  de lenguaje, app y generador de documentación.
- **Diagnósticos:** alias desconocido, alias ambiguo (dos prefijos que coinciden; gana el más largo,
  como en `paths`), alias que sale del espacio.
- **Artefactos:** el binario no conserva aliases; el paquete publicado los traduce a dependencias
  explícitas, de modo que quien lo consume no necesita el mapa.

Decisión en [D-19](17-riesgos-preguntas-y-decisiones.md#d-19): si los aliases deben poder declararse
también en el código (no se recomienda: dos fuentes de verdad).

---

<a id="tree-shaking"></a>

## 6. «Evitar el tree shaking»

### 6.1 Qué es

*Tree shaking* es el nombre que el ecosistema JavaScript (Rollup, webpack) dio a la **eliminación de
código no alcanzable** a partir de las importaciones estáticas de módulos ES. En compiladores
nativos la misma idea se llama eliminación de código muerto, análisis de alcanzabilidad u
optimización en tiempo de enlace. El compilador AOT de Dart, Go, GraalVM Native Image y R8 la
practican; los tres últimos la combinan con la **hipótesis de mundo cerrado** (todo el código
posible se conoce al compilar), y por eso necesitan que la reflexión y la carga dinámica se declaren
aparte (`@pragma('vm:entry-point')` en Dart, metadatos de alcanzabilidad en GraalVM, reglas `keep`
en R8).

### 6.2 Seis interpretaciones de la exigencia

Ninguna se adopta en silencio. Cada una tiene consecuencias distintas:

| ID   | Interpretación                                                                                           | Qué pide en la práctica                                                                 | Consecuencia sobre tamaño y rendimiento                | Consecuencia sobre semántica y diseño                                                             |
|------|----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|--------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| TS-1 | «Que no se elimine lo que uso de forma dinámica» (reflexión, *plugins*, carga por nombre)                | Raíces de alcanzabilidad explícitas, o ausencia de mecanismos dinámicos                 | Ninguna si no hay dinamismo                            | Refuerza la exclusión de reflexión; si algún día hay *plugins*, se declaran como raíces           |
| TS-2 | «Que no dependa de una herramienta aparte, ni de configurarla» (la experiencia de los empaquetadores JS) | El compilador elimina por sí mismo; cero configuración                                  | Igual que con eliminación                              | Ninguna; es una decisión de herramientas                                                          |
| TS-3 | «Que eliminar código nunca cambie lo que hace el programa» (importaciones con efectos)                   | Inicialización de módulos sin efectos observables                                       | Igual que con eliminación                              | **Regla del lenguaje**: sin variables globales mutables, constantes puras, sin código al importar |
| TS-4 | «Que el resultado sea predecible: saber qué entra en el binario y por qué»                               | Eliminación determinista e informe de qué se incluyó y por qué                          | Igual que con eliminación                              | Herramienta de informe; estabilidad entre versiones                                               |
| TS-5 | «No eliminar nada»: el artefacto contiene todo lo importado                                              | Desactivar la eliminación                                                               | Binarios y descargas web mayores; algo más de arranque | Ninguna semántica; facilita depurar «todo está ahí»                                               |
| TS-6 | «Que no haga falta eliminar»: importar solo lo que se usa, con módulos pequeños                          | Importación por símbolo; biblioteca estándar en módulos finos; compilación por separado | Reduce el problema sin eliminarlo                      | Influye en el diseño de la biblioteca estándar y de las importaciones                             |

### 6.3 Tensiones

- **TS-5 contra V-18 y la web.** Sin eliminación, un «hola mundo» arrastra lo que importe la
  biblioteca estándar. En nativo cuesta tamaño; en web cuesta descarga y arranque.
- **TS-1 contra la hipótesis de mundo cerrado.** Si se quiere carga dinámica real (*plugins*), la
  eliminación agresiva exige declarar raíces; sin eso, se rompen programas en silencio, que es lo
  que F-01 prohíbe.
- **TS-3 es la que más protege y la que menos cuesta** **[INFERENCIA]**: PseudoLearn ya no tiene
  variables globales (§10.7 de la especificación). Si la inicialización de módulos tampoco tiene
  efectos, la eliminación es invisible por construcción y se convierte en una optimización sin
  riesgo.

### 6.4 Propuesta

1. **Garantía semántica (TS-3):** la eliminación de código nunca cambia el significado observable;
   se consigue prohibiendo efectos en la inicialización de módulos.
2. **Sin herramienta aparte (TS-2) y con informe (TS-4)**, por omisión.
3. **Modo «sin eliminación» (TS-5)** como opción de construcción para depurar y enseñar, no por
   omisión.
4. **Sin reflexión** (TS-1 se satisface por exclusión); si un día hay *plugins*, raíces declaradas
   en el manifiesto.
5. **Importación por símbolo** y biblioteca estándar en módulos finos (TS-6) como criterio de
   diseño.

**Lo que hace falta de la persona responsable:** decir cuál de las seis lecturas (o qué combinación)
expresa su intención. Si es TS-5 por omisión, el tamaño y el arranque de los artefactos se resienten
y la aspiración de rendimiento debe excluir esas dimensiones de su definición
([05](05-rendimiento-motor-y-compilacion.md) §2). Se mide
con [E-19](16-experimentos-y-benchmarks.md#e-19).

---

## 7. Distribución

Fuera del alcance de la primera versión, pero condiciona decisiones tempranas:

- **Identificadores de paquete en ASCII** con nombre visible bilingüe opcional: los nombres Unicode
  de paquete abren la puerta a confundibles (UTS #39) en la cadena de suministro.
- **Archivo de bloqueo con hashes** de contenido desde el principio.
- **Firma y procedencia** de paquetes publicados (familia de herramientas tipo Sigstore) cuando
  exista registro.
- **Biblioteca estándar versionada aparte** del compilador
  ([04](04-filosofia-y-modelo-del-lenguaje.md) §5.1).

---

## 8. Coherencia entre editores y entornos

| Consumidor                 | Qué necesita del resolutor                                | Riesgo si no comparte implementación                                            |
|----------------------------|-----------------------------------------------------------|---------------------------------------------------------------------------------|
| Compilador                 | Archivo de cada importación y versión de cada dependencia | —                                                                               |
| Servidor de lenguaje       | Lo mismo, de forma incremental                            | «Ir a definición» lleva a otro archivo del que compila (el problema de `paths`) |
| App                        | Documentos sueltos hoy; paquetes en el futuro             | Ejercicios que funcionan en la app y no en la línea de órdenes                  |
| Generador de documentación | Lo mismo                                                  | Documentación que enlaza a lo que no se usa                                     |

**Propuesta:** el resolutor es un componente del servicio de lenguaje
([07](07-herramientas-y-autocompletado.md)), especificado con casos ejecutables, y ningún consumidor
tiene lógica de resolución propia.
