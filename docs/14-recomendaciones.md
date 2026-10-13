# 14 · Recomendaciones

> **Estado:** **propuestas**, no decisiones. Cada recomendación remite a la sección que contiene su
> análisis completo para no repetirlo, declara su evidencia y las condiciones que la invalidarían. Las
> decisiones correspondientes están en [17](17-riesgos-preguntas-y-decisiones.md).

---

## 1. Las cinco que más importan

### REC-01 · Construir primero el sistema de especificaciones, pequeño y sobre lo que ya falla

- **Qué.** Producto mínimo de [11](11-especificaciones-ejecutables-diseno.md) §14, con migración de tres
  secciones de `language-spec.md` y adaptador del núcleo, antes de cualquier construcción nueva del
  lenguaje.
- **Evidencia.** Once hallazgos del diagnóstico (H-01 a H-07, H-18, H-27, H-29, H-37) son divergencias
  entre lo escrito y lo ejecutado que ningún verificador detectó; las especificaciones ejecutables las
  habrían detectado el día en que se escribió cada regla ([12](12-especificaciones-ejecutables-ejemplos.md) §10).
  Precedentes: SpecTec y JEST encontraron errores en especificaciones y en implementaciones maduras.
- **Condiciones.** CI disponible (REC-12); coste de autoría aceptable (E-15).
- **Cambiaría de opinión si** E-15 muestra un coste de autoría desproporcionado o que el sistema no
  encuentra defectos que los tests ya no encontraran.
- **Decisiones.** D-09, D-10, D-23.

### REC-02 · Separar observar de ejecutar, y especificar lo observable

- **Qué.** Contrato de eventos y de estado observable ([06](06-ejecucion-pedagogica-y-app.md) §1–2);
  VM observable para la app; motor rápido para ejecutar; reproducción determinista como puente.
- **Evidencia.** El tope de 10 000 micro-pasos impide terminar programas válidos en la app (H-14);
  observar cuesta de 1,3× a 4,6× (H-12); las instantáneas omiten arreglos y no son inmutables (H-10); el
  núcleo ya es determinista, lo que abarata la reproducción (O5 de [06](06-ejecucion-pedagogica-y-app.md)).
- **Cambiaría de opinión si** E-03 muestra que una única VM basta para todos los usos, o si la
  conformidad diferencial encuentra divergencias persistentes entre motores.
- **Decisiones.** D-05, D-18.

### REC-03 · No elegir backend ni JIT todavía; medir el techo semántico

- **Qué.** E-02 (techo semántico) y E-05 (C frente a Go) antes de construir un backend; sin JIT en la
  hoja de ruta inicial ([05](05-rendimiento-motor-y-compilacion.md) §6).
- **Evidencia.** El lenguaje es estático y nominal: la mayor parte de lo que hace rápidas a las JIT de
  JavaScript no aplica; iOS no permite generar código en ejecución; el calentamiento de las JIT es
  impredecible (Barrett et al., 2017). El intérprete está a ≈500×–1900× del nativo por su diseño, no por
  cómo se compiló el motor.
- **Cambiaría de opinión si** el modo interactivo de escritorio se vuelve prioritario sobre el
  rendimiento máximo.
- **Decisiones.** D-06, D-07.

### REC-04 · Memoria administrada con tipos valor

- **Qué.** Recolección por trazado como semántica («nada observa la recuperación»), `Registro` como tipo
  valor, recursos con liberación estructurada, propiedad opcional como horizonte
  ([09](09-gestion-de-memoria.md) §5).
- **Evidencia.** Los ciclos de referencias son válidos hoy (H-35), lo que descarta el conteo sin
  recolector de ciclos; el aliasing de objetos mutables es pedagogía central, lo que descarta la
  propiedad estilo Rust y la semántica de valores mutables como modelos únicos; la evidencia de
  aprendibilidad de la propiedad (Crichton et al., 2023) muestra que es difícil aunque enseñable.
- **Cambiaría de opinión si** E-11 muestra que los ciclos son rarísimos y E-12 que el conteo con
  reutilización rinde claramente mejor; o si el alcance de D-03 incluye sistemas sin recolector.
- **Decisiones.** D-04.

### REC-05 · Trayectoria arquitectónica A3, empezando por lo común

- **Qué.** Front-end sin pérdida, servicio de lenguaje y VM en Dart; RI tipada especificada; backend
  decidido por experimento ([13](13-arquitecturas-candidatas.md) §4).
- **Evidencia.** Conserva un núcleo con 772 tests verdes y una disciplina verificada; la mitad común es
  útil con cualquier backend; la RI especificada mantiene reversible la elección.
- **Cambiaría de opinión si** E-08 muestra que el front-end en Dart no cumple las latencias del servidor
  de lenguaje.
- **Decisiones.** D-05.

---

## 2. Lenguaje e identidad

| ID     | Recomendación                                                                                                                            | Detalle                                                                       | Decisión |
|--------|------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|----------|
| REC-06 | Tratar PseudoLearn como **destino** y sustituir el criterio de desempate vigente por el orden F-01 → legibilidad → coherencia → familiaridad → coste | [04](04-filosofia-y-modelo-del-lenguaje.md) §1.2                              | D-02     |
| REC-07 | **Niveles como subconjuntos** del lenguaje, con el invariante del eje de rigor (solo invalidan, nunca cambian el significado)            | [04](04-filosofia-y-modelo-del-lenguaje.md) §1.3                              | —        |
| REC-08 | Vocabulario nuevo **contextual**, presupuesto reservado medido, reabrir `Y`/`O` con datos, normalización **NFC**                          | [03](03-identidad-bilingue-y-gramatica.md) §4, §6                              | D-13, D-14 |
| REC-09 | **Gramática formal** especificada como fuente de generadores (editores, plantillas, referencia) y de un parser de referencia diferencial | [03](03-identidad-bilingue-y-gramatica.md) §5                                  | —        |
| REC-10 | Orden de construcciones: (A) módulos, constantes, enumerados/opcional, registros, `Resultado`, interfaces; (B, con edición) ámbitos de bloque, closures, genéricos | [04](04-filosofia-y-modelo-del-lenguaje.md) §4; [15](15-evolucion-y-hoja-de-ruta.md) F4, F7 | D-12, D-15, D-16 |
| REC-11 | Biblioteca estándar **bilingüe por construcción**; un perfil por archivo; nombres bilingües opcionales verificados para terceros           | [03](03-identidad-bilingue-y-gramatica.md) §7                                  | D-21     |

## 3. Herramientas, módulos y gobierno

| ID     | Recomendación                                                                                                                                 | Detalle                                                                       | Decisión |
|--------|-----------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|----------|
| REC-12 | **CI** que ejecute todos los verificadores y la conformidad                                                                                    | [17](17-riesgos-preguntas-y-decisiones.md) D-23                               | D-23     |
| REC-13 | **Servicio de lenguaje** único (app en proceso, LSP y DAP para editores); autocompletado determinista generado de la gramática y verificado   | [07](07-herramientas-y-autocompletado.md)                                     | —        |
| REC-14 | **Resolutor único** de módulos y aliases; aliases solo en manifiestos; espacios de trabajo con un archivo de bloqueo                          | [08](08-modulos-paquetes-y-monorepos.md) §4–5, §8                             | D-19     |
| REC-15 | Garantía de que la eliminación de código **nunca cambia el significado** (inicialización sin efectos); modo sin eliminación opcional         | [08](08-modulos-paquetes-y-monorepos.md#tree-shaking)                          | D-08     |
| REC-16 | **Ediciones** por paquete con migración automática y deprecación atada a estados de especificación                                            | [04](04-filosofia-y-modelo-del-lenguaje.md) §5.3                              | D-11     |
| REC-17 | Contrato de fuentes de verdad **R2**: comportamiento en especificaciones; arquitectura y operación en `README.md`                              | [11](11-especificaciones-ejecutables-diseno.md#transicion-readme)             | D-09     |
| REC-18 | Política de **oráculos independientes**: origen de valores esperados, dos sujetos para estabilizar, mutación, ejecución en todos los objetivos | [11](11-especificaciones-ejecutables-diseno.md) §10                            | —        |
| REC-19 | Resolver la tensión entre **licencia propietaria y comunidad** antes de invertir en herramientas públicas                                     | [17](17-riesgos-preguntas-y-decisiones.md) C-05, D-01                         | D-01     |
| REC-20 | Corregir los hallazgos de contrato (H-05 a H-10, H-18, H-25, H-27, H-37) **convirtiendo cada corrección en un caso**                          | [15](15-evolucion-y-hoja-de-ruta.md) F2                                       | D-22     |

---

## 4. Lo que se recomienda **no** hacer

| No hacer                                                                    | Por qué                                                                                                   |
|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| Reescribir el núcleo desde cero en otro lenguaje ahora                      | Pierde un activo verificado sin evidencia de que el front-end en Dart sea el cuello de botella            |
| Adoptar una JIT como motor principal                                        | Resuelve un problema de lenguajes dinámicos; incompatible con iOS; calentamiento impredecible             |
| Adoptar propiedad y préstamos como modelo por omisión                       | Rompe programas válidos y la pedagogía del aliasing; coste de aprendizaje documentado                      |
| Adoptar SDD como sistema de especificaciones                                | No produce veredictos ni gestiona versiones ([10](10-especificaciones-ejecutables-fundamentos.md) §4.3)    |
| Introducir la interfaz implícita de cada clase (Dart)                       | Confunde clase e interfaz y obliga después a modificadores para controlarlo                               |
| Reservar cada palabra nueva                                                  | Encoge el vocabulario disponible con cada versión (H-22)                                                 |
| Traducir automáticamente nombres de API entre idiomas                       | Crea alias que nadie decidió; contradice §2.3 de la especificación vigente                                |
| Prometer «rendimiento como Rust» sin nivel, familia, plataforma e intervalo | No es comprobable y la evidencia propia aún no existe                                                     |
