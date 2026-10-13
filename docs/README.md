# Investigación sobre la evolución de PseudoLearn

> **Estado:** investigación, **no normativa**. Fecha: 2026-10-13. Commit de referencia: `b44b2dd`.
>
> Este conjunto de documentos analiza cómo convertir PseudoLearn en un lenguaje de propósito general
> sin perder su identidad pedagógica y bilingüe. **No sustituye** ninguna fuente de verdad vigente: los
> `README.md` de los paquetes, `AGENTS.md` y `packages/pseudolearn_core/docs/language-spec.md` siguen
> mandando según `AGENTS.md` §3. Todo lo que aquí aparece como recomendación es una **propuesta**; las
> decisiones que requieren a la persona responsable están en [17](17-riesgos-preguntas-y-decisiones.md).
> Si alguna propuesta se aprueba, debe trasladarse al `README.md` o a la especificación que corresponda
> en el mismo cambio que la implemente (`DOC-README-TRUTH`).

---

## Documentos

| Nº  | Documento                                                                                  | Contenido                                                                                              |
|-----|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| 01  | [Visión y trazabilidad](01-vision-y-trazabilidad.md)                                       | La visión organizada; exigencias, preferencias e hipótesis; ambigüedades; matriz de trazabilidad       |
| 02  | [Diagnóstico del sistema actual](02-diagnostico-del-sistema-actual.md)                     | Lo comprobado en el repositorio; 37 hallazgos con evidencia; exclusiones vigentes como antecedentes    |
| 03  | [Identidad bilingüe y gramática](03-identidad-bilingue-y-gramatica.md)                     | Pseudocódigo sin estándar; precedentes de bilingüismo; reglas de estilo; palabras reservadas; Unicode; gramática formal; formas propuestas |
| 04  | [Filosofía y modelo del lenguaje](04-filosofia-y-modelo-del-lenguaje.md)                   | Principios verificables; puente o destino; niveles; modelo de objetos; fichas de características; gobierno de la evolución |
| 05  | [Rendimiento, motor y compilación](05-rendimiento-motor-y-compilacion.md)                  | Dimensiones separadas; definición medible de la aspiración; estrategias; la JIT de JavaScript; backends |
| 06  | [Ejecución pedagógica y app](06-ejecucion-pedagogica-y-app.md)                             | Qué es un paso; estado observable; uno o varios motores; reproducción determinista; coherencia         |
| 07  | [Herramientas y autocompletado](07-herramientas-y-autocompletado.md)                       | Responsabilidades; servicio de lenguaje; autocompletado determinista bilingüe; LSP, DAP, VS Code, IntelliJ |
| 08  | [Módulos, paquetes y monorepos](08-modulos-paquetes-y-monorepos.md)                        | Nueve problemas distintos; espacios de trabajo; aliases; seis lecturas de «evitar el tree shaking»     |
| 09  | [Gestión de memoria](09-gestion-de-memoria.md)                                             | Criterios; modelos; efectos sobre el lenguaje; compatibilidad con la semántica vigente; innovaciones   |
| 10  | [Especificaciones ejecutables: fundamentos](10-especificaciones-ejecutables-fundamentos.md) | Qué es ejecutable; tests y código que ejecutan especificaciones; estado del arte (SDD incluido); errores compartidos; límites |
| 11  | [Especificaciones ejecutables: diseño](11-especificaciones-ejecutables-diseno.md)          | Estados; anatomía; formato; identidad; versiones y clasificación de cambios; dependencias; impacto; vínculos; paquete; transición del contrato de los `README.md` |
| 12  | [Especificaciones ejecutables: ejemplos](12-especificaciones-ejecutables-ejemplos.md)      | Bucle contado migrado; recuperación sintáctica; closures; interfaces; memoria; traza; autocompletado; ritmos de la app; rendimiento; cambio e impacto |
| 13  | [Arquitecturas candidatas](13-arquitecturas-candidatas.md)                                 | Cinco arquitecturas de sistema; compromisos; disposición propuesta del monorepo                        |
| 14  | [Recomendaciones](14-recomendaciones.md)                                                   | Veinte recomendaciones con evidencia y condiciones; lo que no conviene hacer                           |
| 15  | [Evolución y hoja de ruta](15-evolucion-y-hoja-de-ruta.md)                                 | Estrategia de sustitución progresiva; fases F0–F10 con dependencias y criterios de aceptación          |
| 16  | [Experimentos y benchmarks](16-experimentos-y-benchmarks.md)                               | 21 experimentos; protocolo de benchmarks reproducibles                                                 |
| 17  | [Conflictos, decisiones, riesgos y preguntas](17-riesgos-preguntas-y-decisiones.md)        | 8 conflictos reportados; 24 decisiones pendientes; 17 riesgos; 13 preguntas abiertas                   |
| 18  | [Fuentes](18-fuentes.md)                                                                   | Fuentes primarias y secundarias con fecha, enlace, uso, límite y estado de verificación               |
| A   | [Anexo A · Experimentos reproducibles](anexos/A-experimentos-reproducibles.md)             | Entorno, arnés, programas, mediciones y sondas sobre el sistema actual                                 |

### Rutas de lectura

- **Visión general (30 minutos):** este índice → [14](14-recomendaciones.md) → [17](17-riesgos-preguntas-y-decisiones.md).
- **Especificaciones ejecutables (lo central):** [10](10-especificaciones-ejecutables-fundamentos.md) →
  [11](11-especificaciones-ejecutables-diseno.md) → [12](12-especificaciones-ejecutables-ejemplos.md).
- **Lenguaje:** [03](03-identidad-bilingue-y-gramatica.md) → [04](04-filosofia-y-modelo-del-lenguaje.md) →
  [09](09-gestion-de-memoria.md).
- **Motor y rendimiento:** [02](02-diagnostico-del-sistema-actual.md) §3 → [05](05-rendimiento-motor-y-compilacion.md) →
  [06](06-ejecucion-pedagogica-y-app.md) → [13](13-arquitecturas-candidatas.md) → [16](16-experimentos-y-benchmarks.md).
- **Herramientas y ecosistema:** [07](07-herramientas-y-autocompletado.md) → [08](08-modulos-paquetes-y-monorepos.md).
- **Planificación:** [15](15-evolucion-y-hoja-de-ruta.md) → [16](16-experimentos-y-benchmarks.md) → [17](17-riesgos-preguntas-y-decisiones.md).

---

<a id="convenciones-de-lectura"></a>

## Convenciones de lectura

### Etiquetas epistémicas

La visión pide distinguir siempre la naturaleza de cada afirmación (V-65). Cada párrafo relevante lleva
una de estas etiquetas:

| Etiqueta                       | Significa                                                                                             |
|--------------------------------|-------------------------------------------------------------------------------------------------------|
| **[COMPROBADO]**               | Implementado y comprobado en esta investigación: test ejecutado, sonda o lectura del código que lo implementa |
| **[DOCUMENTADO]**              | Afirmado en la documentación del repositorio y no comprobado                                          |
| **[DOCUMENTADO, CONTRADICHO]** | Afirmado en la documentación y contradicho por el código o por una sonda                              |
| **[HECHO EXTERNO]**            | Afirmación tomada de una fuente externa citada en [18](18-fuentes.md)                                 |
| **[INFERENCIA]**               | Conclusión de esta investigación a partir de hechos; puede ser errónea                                 |
| **[HIPÓTESIS]**                | Afirmación técnica no demostrada que un experimento podría confirmar o refutar                        |
| **PROPUESTA**                  | Recomendación o diseño no aprobado                                                                     |

### Prefijos de identificadores

| Prefijo  | Qué identifica                                   | Dónde se define |
|----------|--------------------------------------------------|-----------------|
| V-xx     | Exigencia de la visión                           | [01](01-vision-y-trazabilidad.md) §2.1 |
| P-xx     | Preferencia o referencia personal                | [01](01-vision-y-trazabilidad.md) §2.2 |
| HIP-xx   | Hipótesis implícita en la visión                 | [01](01-vision-y-trazabilidad.md) §2.3 |
| A-xx     | Ambigüedad y su interpretación de trabajo        | [01](01-vision-y-trazabilidad.md) §3 |
| H-xx     | Hallazgo del diagnóstico                         | [02](02-diagnostico-del-sistema-actual.md) §6 |
| EST-xx   | Regla de estilo gramatical propuesta             | [03](03-identidad-bilingue-y-gramatica.md) §3 |
| F-xx     | Principio de la filosofía propuesta              | [04](04-filosofia-y-modelo-del-lenguaje.md) §1 |
| N0–N3    | Niveles de cumplimiento de rendimiento           | [05](05-rendimiento-motor-y-compilacion.md) §2.2 |
| O1–O6    | Opciones de configuración de motores             | [06](06-ejecucion-pedagogica-y-app.md) §3 |
| TS-1–6   | Interpretaciones de «evitar el tree shaking»     | [08](08-modulos-paquetes-y-monorepos.md) §6 |
| IN-xx    | Innovación propuesta en memoria                  | [09](09-gestion-de-memoria.md) §6 |
| N0–N5    | Niveles de ejecutabilidad de una especificación  | [10](10-especificaciones-ejecutables-fundamentos.md) §2.2 |
| SEE-Rxx  | Requisito del sistema de especificaciones        | [11](11-especificaciones-ejecutables-diseno.md) §1 |
| A1–A5    | Arquitectura candidata                           | [13](13-arquitecturas-candidatas.md) §2 |
| REC-xx   | Recomendación                                    | [14](14-recomendaciones.md) |
| F0–F10   | Fase de la hoja de ruta                          | [15](15-evolucion-y-hoja-de-ruta.md) |
| E-xx     | Experimento                                      | [16](16-experimentos-y-benchmarks.md) |
| C-xx     | Conflicto entre fuentes                          | [17](17-riesgos-preguntas-y-decisiones.md) §1 |
| D-xx     | Decisión pendiente                               | [17](17-riesgos-preguntas-y-decisiones.md) §2 |
| R-xx     | Riesgo                                           | [17](17-riesgos-preguntas-y-decisiones.md) §3 |
| Q-xx     | Pregunta abierta de investigación                | [17](17-riesgos-preguntas-y-decisiones.md) §4 |

(Los niveles N de [05](05-rendimiento-motor-y-compilacion.md) y de [10](10-especificaciones-ejecutables-fundamentos.md)
son escalas distintas; cada documento indica a cuál se refiere.)

---

## Resumen ejecutivo

1. **El punto de partida es sólido y está desalineado.** El núcleo pasa sus 772 tests y verificadores,
   tiene un modelo bilingüe de dos planos poco común y bien verificado, y diagnósticos estructurados
   independientes del idioma. Pero lo escrito y lo ejecutado divergen sin que nada lo detecte: reglas de
   la especificación incumplidas o nunca implementadas, `README.md` que describen API inexistentes,
   una plantilla de autocompletado inválida (37 hallazgos en [02](02-diagnostico-del-sistema-actual.md)).
2. **Por eso lo primero es el sistema de especificaciones ejecutables**, pequeño y aplicado a lo que ya
   falla ([11](11-especificaciones-ejecutables-diseno.md), [12](12-especificaciones-ejecutables-ejemplos.md)).
   Ningún enfoque existente basta solo; SDD no produce veredictos ni gestiona versiones. Se propone una
   capa de integración con identidad y revisión por regla, casos y propiedades ejecutables, clasificación
   de cambios con dos audiencias, impacto, vínculos como datos (el código no admite comentarios) y una
   política de oráculos independientes.
3. **El motor actual está a unos tres órdenes de magnitud del nativo** por su diseño (máquina de tareas,
   `BigInt` en cada operación, instantáneas completas), no por cómo se compiló. Compilar el motor a
   nativo no compila los programas ([05](05-rendimiento-motor-y-compilacion.md)).
4. **La aspiración «como Rust o Go» necesita definición**: se proponen niveles medibles, comparación de
   misma semántica y de semántica nativa, y un protocolo estadístico. Antes de elegir backend, medir el
   techo semántico (E-02).
5. **Una JIT no es el camino principal**: PseudoLearn es estático y nominal, iOS prohíbe generar código y
   el calentamiento es impredecible. De la JIT de JavaScript se transfiere sobre todo la desoptimización
   como idea para observar código optimizado.
6. **Separar observar de ejecutar** y especificar el estado observable: VM observable para la app, motor
   rápido para ejecutar, reproducción determinista entre ambos (el determinismo vigente la hace barata y
   habilita ir hacia atrás) ([06](06-ejecucion-pedagogica-y-app.md)).
7. **Memoria administrada con tipos valor**: los ciclos ya son válidos y el aliasing es la pedagogía
   central, lo que descarta propiedad estilo Rust o conteo puro como modelos por omisión
   ([09](09-gestion-de-memoria.md)).
8. **El bilingüismo se decide en las API, no en las palabras clave**: biblioteca estándar bilingüe por
   construcción, un perfil por archivo, vocabulario nuevo contextual, normalización NFC
   ([03](03-identidad-bilingue-y-gramatica.md)).
9. **Un servicio de lenguaje único** para la app y los editores (LSP, DAP), con autocompletado
   determinista generado de una gramática formal ([07](07-herramientas-y-autocompletado.md)).
10. **«Evitar el tree shaking» admite seis lecturas** y requiere una respuesta; la más protectora y barata
    es garantizar que eliminar código nunca cambie el significado ([08](08-modulos-paquetes-y-monorepos.md)).
11. **Trayectoria arquitectónica A3**: construir primero la mitad común en Dart y una representación
    intermedia especificada; elegir backend por experimento ([13](13-arquitecturas-candidatas.md)).

---

## Decisiones abiertas más importantes

| Decisión | Por qué es la más urgente |
|---|---|
| [D-02 · Puente o destino](17-riesgos-preguntas-y-decisiones.md#d-02) | Cambia el criterio con que se decide cada construcción nueva (conflicto C-01) |
| [D-09 · Transición de la fuente de verdad](17-riesgos-preguntas-y-decisiones.md#d-09) | Define si las especificaciones pueden mandar sobre los `README.md` (C-02, C-03) |
| [D-01 · Licencia y comunidad](17-riesgos-preguntas-y-decisiones.md#d-01) | La licencia propietaria vigente choca con la comunidad que pide la visión (C-05) |
| [D-08 · «Evitar el tree shaking»](17-riesgos-preguntas-y-decisiones.md#d-08) | Requiere aclarar la intención; condiciona módulos e inicialización |
| [D-07 · Definición del rendimiento](17-riesgos-preguntas-y-decisiones.md#d-07) | Sin ella, «como Rust o Go» no es comprobable |
| [D-04 · Modelo de memoria](17-riesgos-preguntas-y-decisiones.md#d-04) | Condiciona closures, concurrencia, runtime y observación |
| [D-05 · Arquitectura y lenguajes de implementación](17-riesgos-preguntas-y-decisiones.md#d-05) | Determina las cadenas de herramientas del monorepo |
| [D-23 · Integración continua](17-riesgos-preguntas-y-decisiones.md#d-23) | Sin CI, ninguna especificación es ejecutable en la práctica |
