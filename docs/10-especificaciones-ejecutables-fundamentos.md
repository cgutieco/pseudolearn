# 10 · Especificaciones ejecutables: fundamentos y estado del arte

> **Estado:** investigación, no normativo. Define conceptos y evalúa enfoques. El diseño propuesto
> está en [11](11-especificaciones-ejecutables-diseno.md) y los ejemplos en
> [12](12-especificaciones-ejecutables-ejemplos.md). Nada cambia la regla vigente
> `DOC-README-TRUTH`.

Responde a V-46, V-48, V-49, V-57, V-59 y V-60.

---

## 1. El problema, con evidencia del propio repositorio

El proyecto ya es más riguroso que la media: especificación antes del parser, reglas con
identificador, verificadores con caso negativo. Aun así,
el [diagnóstico](02-diagnostico-del-sistema-actual.md)
encontró que **lo escrito y lo ejecutado divergen sin que nada lo detecte**:

| Síntoma                                                                                          | Hallazgo   | Qué faltó                                                               |
|--------------------------------------------------------------------------------------------------|------------|-------------------------------------------------------------------------|
| La especificación dice que el motor no ejecuta clases; las ejecuta                               | H-02       | Que cada afirmación normativa tuviera un caso que se ejecute            |
| Reglas de recuperación (§1.3) incumplidas                                                        | H-05, H-06 | Ídem                                                                    |
| Una advertencia exigida (modificar la variable de control del bucle contado) nunca se implementó | H-37       | Ídem: la regla está en dos tablas de la especificación y en ningún test |
| El `README.md` nombra tipos y métodos públicos que no existen                                    | H-07       | Extraer la superficie pública en vez de copiarla                        |
| Una plantilla de autocompletado contradice la gramática                                          | H-18       | Que una afirmación sobre la gramática se compruebe contra la gramática  |
| «Paridad semántica entre objetivos» comprobada solo compilando                                   | H-27       | Distinguir «compila» de «se comporta igual»                             |
| Dos documentos del mismo nivel se contradicen (perfiles institucionales)                         | H-04       | Identidad de cada regla y detección de reglas contradictorias           |
| Cifras de estado escritas a mano y desactualizadas                                               | H-01       | Que el estado derivado se genere                                        |

**[INFERENCIA]** Ninguno de estos fallos se debe a descuido: es lo que ocurre a cualquier texto
normativo que no está **atado mecánicamente** a lo que pretende gobernar. El sistema que pide la
visión es ese atado.

---

## 2. Qué significa que una especificación sea ejecutable

### 2.1 Definiciones

- **Especificación.** Conjunto de **afirmaciones normativas** sobre un sistema, con identidad
  estable, versión y estado. Una afirmación normativa dice qué **debe**, **no debe** o **puede**
  ocurrir.
- **Sujeto.** Lo que se juzga contra la especificación: el núcleo, una VM, el compilador, la app,
  una herramienta.
- **Ejecutable.** Una afirmación es ejecutable si existe un **procedimiento mecánico** que, dados la
  afirmación y un sujeto, produce un **veredicto** (cumple, incumple) sin que una persona tenga que
  interpretar la afirmación en el momento de ejecutarla. La ejecutabilidad es **por afirmación** y
  **graduada**; una especificación es ejecutable en la medida en que lo son sus afirmaciones, y
  declara explícitamente las que no lo son.

### 2.2 Niveles de ejecutabilidad

| Nivel | Nombre                   | Qué se ejecuta                                                                 | Veredicto                                        | Ejemplo en PseudoLearn                                           |
|-------|--------------------------|--------------------------------------------------------------------------------|--------------------------------------------------|------------------------------------------------------------------|
| N0    | Declarativa              | Nada; la afirmación se revisa por personas                                     | Revisión registrada                              | «Los diagnósticos usan lenguaje sencillo»                        |
| N1    | Estructural              | La forma de la especificación y sus enlaces                                    | Bien formada, referencias resueltas, cobertura   | Toda regla tiene caso o justificación                            |
| N2    | Por ejemplos             | Casos concretos: entrada → observable esperado                                 | Cumple o no cada caso                            | `Escribir 1 +` produce un solo `expectedExpression`              |
| N3    | Por propiedades          | Afirmaciones cuantificadas sobre entradas generadas, con oráculo independiente | Cumple en N entradas; contraejemplo mínimo si no | Para todo `a`, `b ≠ 0` en rango: `(a div b) * b + (a mod b) = a` |
| N4    | Por modelo de referencia | Un modelo ejecutable de la semántica y comparación diferencial                 | Coincide o no con el modelo                      | Traza del intérprete de referencia = traza de la VM              |
| N5    | Demostrada               | Una prueba formal                                                              | Teorema verificado                               | «El chequeo de tipos es sólido» en un asistente de pruebas       |

**[INFERENCIA]** Para PseudoLearn el valor está en N1–N4. N5 queda fuera del alcance razonable para
un equipo pequeño, salvo piezas acotadas.

### 2.3 Qué no es una especificación ejecutable

- **Una suite de tests** por sí sola: ejecuta, pero no tiene texto normativo, identidad por regla,
  versión ni estado. Los tests son uno de los **mecanismos** con que se ejecuta una especificación.
- **Un *prompt*** para un agente: no produce veredicto. Puede derivarse de una especificación, no
  sustituirla.
- **Documentación descriptiva**: describe lo que hay, no lo que debe haber, y no se puede comprobar.

---

## 3. «Los tests ejecutan las especificaciones» y «el código ejecuta las especificaciones»

Son dos relaciones distintas y conviene no confundirlas, porque una puede anular la utilidad de la
otra.

### 3.1 Los tests ejecutan las especificaciones

Un **ejecutor de conformidad** lee los casos y propiedades de la especificación **como datos** y los
aplica al sujeto a través de un adaptador, emitiendo un veredicto **por identificador y versión de
regla**. Consecuencias:

- El test no contiene copias de los valores esperados; los lee de la especificación (extensión
  natural de `GEN-NO-HAND-COPY`).
- Un test escrito a mano puede seguir existiendo, pero **declara qué regla verifica** (vínculo de
  conformidad, [11](11-especificaciones-ejecutables-diseno.md) §9). Como el código no admite
  comentarios (`QUALITY-NO-COMMENTS`), ese vínculo vive en un archivo de datos, no en el test.
- El informe resultante es una **matriz regla × sujeto**, no una lista de tests.

### 3.2 El código ejecuta las especificaciones

Tiene tres sentidos legítimos:

| Sentido                     | Qué ocurre                                                               | Ejemplos (vigentes o propuestos)                                                                                            |
|-----------------------------|--------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| **Generación**              | Código o datos del sujeto se **generan** desde la especificación         | Inventario de tokens y léxicos de perfil; catálogo de diagnósticos; gramáticas de tree-sitter; plantillas de autocompletado |
| **Interpretación de datos** | El sujeto **lee** tablas de la especificación al construir o al ejecutar | Política de severidad (hoy es un dato del perfil, pero escrito en Dart)                                                     |
| **Semántica ejecutable**    | La especificación **es** o **contiene** un modelo que ejecuta programas  | SpecTec genera un intérprete de la especificación de Wasm; K y PLT Redex ejecutan semánticas                                |

### 3.3 El riesgo de tautología

**[INFERENCIA, con apoyo en Knight y Leveson, 1986]** Si una parte del sujeto se **genera** de la
especificación y sus tests **también** se generan de ella, la conformidad de esa parte es
**tautológica**: si la especificación está mal, ambos coinciden en el error. Por tanto:

- Lo generado se verifica contra **oráculos independientes** (corpus de programas reales con
  resultados conocidos por otra vía, comparación con una implementación escrita a mano, revisión
  humana de la especificación misma).
- Lo escrito a mano se verifica contra los casos de la especificación.
- Nunca ambas cosas salen de la misma fuente sin una tercera que las contraste.

---

## 4. Enfoques existentes

### 4.1 Criterios

Los criterios salen de V-50 a V-58: estructura normalizada (E), identidad estable (I), versionado
por unidad (V), ejecutabilidad (X, con nivel), dependencias entre especificaciones (D), detección de
impacto (Im), clasificación de cambios (Cl), trazabilidad a código, tests y documentación (T),
independencia de oráculos (O), separación entre propuesta y aprobado (P), y coste de adopción.

### 4.2 Evaluación

● cubre bien · ◐ parcial · ○ no cubre

| Enfoque                                                                                          | E | I | V                | X (nivel)        | D | Im | Cl | T | O | P | Coste    | Lo que aporta a PseudoLearn                                                                                                                                                                                                |
|--------------------------------------------------------------------------------------------------|---|---|------------------|------------------|---|----|----|---|---|---|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **SDD con herramientas de 2025** (GitHub Spec Kit, Kiro, Tessl)                                  | ◐ | ○ | ○                | ○ (N0)           | ○ | ○  | ○  | ◐ | ○ | ◐ | Bajo     | Disciplina de flujo «especificar → planificar → tareas»; plantillas                                                                                                                                                        |
| BDD / Gherkin (Cucumber)                                                                         | ● | ◐ | ○                | ● (N2)           | ○ | ○  | ○  | ◐ | ◐ | ○ | Medio    | Formato legible de casos; palabras clave de Gherkin traducidas, incluido español (`Dado`, `Cuando`, `Entonces`)                                                                                                            |
| Especificación por ejemplos (Adzic, 2011; FIT)                                                   | ◐ | ○ | ○                | ● (N2)           | ○ | ○  | ○  | ◐ | ◐ | ○ | Medio    | Ejemplos como contrato compartido entre negocio y desarrollo                                                                                                                                                               |
| Diseño por contrato (Eiffel; Dafny)                                                              | ● | ○ | ○                | ● (N2–N5)        | ○ | ○  | ○  | ● | ◐ | ○ | Medio    | Precondiciones, poscondiciones e invariantes en el sujeto                                                                                                                                                                  |
| Pruebas por propiedades (QuickCheck, 2000; Hypothesis)                                           | ◐ | ○ | ○                | ● (N3)           | ○ | ○  | ○  | ◐ | ● | ○ | Medio    | Generadores y contraejemplos mínimos                                                                                                                                                                                       |
| Suites de conformidad (test262, pruebas de la especificación de Wasm)                            | ● | ● | ◐                | ● (N2)           | ○ | ◐  | ○  | ● | ◐ | ● | Alto     | Casos con metadatos que enlazan la sección de la especificación (`esid` en test262); TC39 exige pruebas y **dos implementaciones** para aprobar una propuesta                                                              |
| Semántica mecanizada (K; PLT Redex; Ott/Lem)                                                     | ● | ◐ | ◐                | ● (N4)           | ◐ | ○  | ○  | ◐ | ● | ○ | Muy alto | Un modelo ejecutable independiente                                                                                                                                                                                         |
| **SpecTec** (Youn et al., PLDI 2024)                                                             | ● | ● | ●                | ● (N4)           | ◐ | ◐  | ○  | ● | ● | ● | Muy alto | Una fuente que genera prosa, notación formal e intérprete; adoptado por el grupo de trabajo de Wasm; su intérprete pasa el 100 % de la suite aplicable de Wasm 2.0 y encontró errores en la especificación y en propuestas |
| **JISET / JEST** (Park et al., ICSE 2021)                                                        | ◐ | ● | ●                | ● (N4)           | ○ | ○  | ○  | ● | ● | ○ | Alto     | Pruebas diferenciales «N+1 versiones»: la especificación como una implementación más; 44 errores en motores y 27 en la especificación de ES2020                                                                            |
| Especificación formal (TLA+, Alloy)                                                              | ● | ○ | ○                | ● (N3–N5)        | ◐ | ○  | ○  | ○ | ● | ○ | Alto     | Comprobación de modelos de protocolos (sincronización de la app)                                                                                                                                                           |
| Trazabilidad de requisitos (OpenFastTrace, Sphinx-needs, StrictDoc, Doorstop)                    | ● | ● | ● (por revisión) | ○ (N1)           | ● | ●  | ◐  | ● | ○ | ◐ | Medio    | Identificadores con revisión (`req~nombre~1` en OpenFastTrace), cobertura hacia delante y hacia atrás, enlaces obsoletos al cambiar la revisión                                                                            |
| Esquemas y lenguajes de configuración (JSON Schema, CUE, Pkl)                                    | ● | ○ | ○                | ● (N1)           | ○ | ○  | ○  | ○ | ○ | ○ | Bajo     | Validación estructural de las especificaciones                                                                                                                                                                             |
| Comprobadores de compatibilidad de API (cargo-semver-checks, `elm diff`, apidiff de Go)          | ◐ | ● | ●                | ● (sobre la API) | ○ | ●  | ●  | ○ | ○ | ○ | Bajo     | Clasificación mecánica de cambios (compatible / incompatible)                                                                                                                                                              |
| Procesos de evolución (RFC de Rust, PEP, Swift Evolution, KEEP, etapas de TC39)                  | ◐ | ● | ◐                | ○                | ◐ | ○  | ◐  | ◐ | ○ | ● | Bajo     | Estados de una propuesta y criterios de paso entre estados                                                                                                                                                                 |
| **Lo vigente en el repositorio** (`architecture.yaml` + verificadores; `check_content`; paridad) | ● | ● | ○                | ● (N1–N2)        | ○ | ○  | ○  | ◐ | ○ | ○ | —        | La prueba de que el equipo ya trabaja así con reglas de arquitectura                                                                                                                                                       |

### 4.3 SDD en detalle

**[HECHO EXTERNO]** Böckeler (martinfowler.com, 15 de octubre de 2025) distingue tres niveles de
«desarrollo guiado por especificaciones» en las herramientas de IA: **spec-first** (se escribe una
especificación para la tarea actual), **spec-anchored** (se conserva y mantiene con la
funcionalidad)
y **spec-as-source** (la especificación es el único artefacto que se edita). Observa que todas las
herramientas analizadas son *spec-first*, y que el plan para mantener la especificación en el tiempo
suele ser vago. GitHub publicó Spec Kit el 2 de septiembre de 2025 (plantillas, CLI y *prompts* para
`/specify`, `/plan`, `/tasks`).

**[INFERENCIA]** SDD, tal como existe, resuelve **cómo pedirle código a un agente**, no **cómo
comprobar que el sistema cumple un contrato**. Sus especificaciones son texto libre para un modelo
de lenguaje: no tienen veredicto, ni identidad por regla, ni versión, ni detección de impacto. Lo
que sí aporta es disciplina de flujo y la observación de que una especificación sin plan de
mantenimiento se abandona. El sistema propuesto puede **alimentar** un flujo SDD (las
especificaciones aprobadas son el mejor contexto posible para un agente), pero no puede **ser** SDD.

### 4.4 Conclusión

Ningún enfoque cubre todos los criterios. Los que mejor cubren la ejecución (SpecTec, JEST, suites
de conformidad) no cubren la gestión del cambio; los que cubren la gestión (trazabilidad de
requisitos, comprobadores de API) no ejecutan. **[INFERENCIA]** Lo que hace falta es una **capa de
integración**:
identidad y revisión al estilo de OpenFastTrace, casos al estilo de test262 y Gherkin, propiedades
al estilo de QuickCheck, diferencial al estilo de JEST, validación estructural con un esquema,
clasificación de cambios al estilo de cargo-semver-checks, estados al estilo de TC39, y semántica
mecanizada selectiva como horizonte. Más tres requisitos propios de PseudoLearn que ninguno trae:
**bilingüismo** (casos que se ejecutan en los dos perfiles), **comportamientos de la app** (no solo
del lenguaje) y **código sin comentarios** (los vínculos no pueden vivir en comentarios, como hacen
OpenFastTrace o test262). Ese es el diseño de [11](11-especificaciones-ejecutables-diseno.md).

---

<a id="errores-compartidos"></a>

## 5. Cómo evitar que implementación y pruebas compartan un error

### 5.1 La lección de Knight y Leveson

**[HECHO EXTERNO]** Knight y Leveson (IEEE TSE, 1986) desarrollaron 27 versiones independientes de
un programa a partir de la misma especificación y las sometieron a un millón de pruebas: los fallos
coincidentes fueron muchos más de los que predice la independencia. La independencia **no se supone;
se construye**, y aun así es parcial.

### 5.2 Fuentes de error compartido en un proyecto como este

| Fuente                                                                                        | Ejemplo plausible aquí                                                                                  |
|-----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| Quien implementa escribe también los valores esperados                                        | Una regla ambigua leída igual (mal) en el código y en el test                                           |
| Valores esperados **capturados** ejecutando la implementación («golden» aprobado sin revisar) | Se fija como correcto lo que el motor hace hoy, incluidos sus defectos                                  |
| Código compartido entre oráculo y sujeto                                                      | El test formatea el resultado con el mismo formateador que el motor (H-25 es de esta familia)           |
| Generación de código y de pruebas desde la misma fuente                                       | Tautología de §3.3                                                                                      |
| Un solo objetivo de ejecución                                                                 | Un comportamiento que depende del anfitrión (el desplazamiento de 32 bits de `dart2js`, anexo A §A.3.1) |

### 5.3 Contramedidas

| Contramedida                                                                                                                                       | Qué detecta                                               | Coste        |
|----------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|--------------|
| **Valores esperados escritos en la especificación**, nunca capturados sin una marca de revisión                                                    | Defectos que el motor tiene hoy                           | Bajo         |
| **Oráculos diversos**: intérprete de referencia, VM, AOT; objetivos nativo, JS y Wasm                                                              | Defectos de una implementación concreta o de un anfitrión | Medio        |
| **Oráculos de propiedad independientes** (aritmética comprobada con enteros de precisión arbitraria; identidades algebraicas de la especificación) | Errores numéricos en bordes                               | Bajo         |
| **Relaciones metamórficas** (traducir el programa al otro perfil, renombrar, reordenar declaraciones de nivel superior)                            | Dependencias ocultas de lexemas o de orden                | Bajo         |
| **Pruebas de mutación del sujeto**: los casos deben matar mutantes                                                                                 | Casos débiles que pasan con cualquier implementación      | Medio        |
| **Mutación de la especificación**: alterar una regla debe hacer fallar al menos un caso                                                            | Reglas sin verificación real                              | Bajo         |
| **Separación de roles** para pasar a «estable»: quien escribe la regla no es quien aprueba sus casos                                               | Lecturas idénticas de una ambigüedad                      | Organizativo |
| **Diferencial «N+1 versiones»** (JEST): la especificación ejecutable como una implementación más, con localización estadística                     | Errores en la propia especificación                       | Alto         |
| **Regla de arquitectura del ejecutor de conformidad**: solo puede usar la API del adaptador, nunca internos del sujeto                             | Código compartido entre oráculo y sujeto                  | Bajo         |
| **Requisito de dos implementaciones** para estabilizar una regla del lenguaje (como TC39)                                                          | Reglas que solo una implementación entiende               | Alto         |

**Límite:** ninguna contramedida demuestra la ausencia de errores compartidos; todas reducen su
probabilidad. Se mide su efecto con [E-16](16-experimentos-y-benchmarks.md#e-16).

---

## 6. Qué garantías se pueden comprobar y cuáles no

| Se puede comprobar mecánicamente                                                                 | No se puede comprobar mecánicamente                                                                   |
|--------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| Que la especificación está bien formada y sus enlaces se resuelven                               | Que la especificación dice lo que se quería (validación frente a verificación)                        |
| Que cada regla normativa tiene al menos una verificación o una justificación de revisión humana  | Que el conjunto de reglas es completo                                                                 |
| Que cada caso se cumple en cada sujeto declarado                                                 | El comportamiento en entradas no probadas (salvo demostración)                                        |
| Que las propiedades se cumplen en las entradas generadas                                         | La calidad de la prosa y de los diagnósticos para una persona                                         |
| Que los motores coinciden en el corpus (diferencial)                                             | La eficacia pedagógica (requiere estudios con personas)                                               |
| Que las restricciones de versión entre especificaciones son satisfacibles                        | Que dos lectores entiendan igual una regla en lenguaje natural                                        |
| Que los vínculos de implementación y prueba apuntan a versiones vigentes                         | La ausencia de errores compartidos entre especificación, implementación y pruebas                     |
| Que un cambio textual en una regla se detecta y se clasifica de forma preliminar                 | La clasificación definitiva de un cambio de significado (requiere juicio)                             |
| Que el rendimiento cae dentro de un presupuesto, con método estadístico y en máquinas declaradas | El rendimiento «universal» o en plataformas no medidas                                                |
| Que las afirmaciones de documentación generadas coinciden con la especificación                  | Que la documentación escrita a mano sigue siendo cierta (salvo que cite identificadores verificables) |
