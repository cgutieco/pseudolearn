# 06 · Flujo de trabajo por especificación

> **Estado:** propuesta. Es el procedimiento que seguiría la skill nueva `spec-authoring`
> ([08](08-decisiones-riesgos-y-cambios-de-reglas.md) §3). Detalla el orden de
> [01](01-principios-y-reglas.md) §1 para una unidad de trabajo concreta.

---

## 1. Unidad de trabajo

La unidad de trabajo es **una especificación**: desde que nace en `borrador` hasta que el sujeto
`engine` la cumple. Un cambio (un commit, una revisión) toca **una especificación y lo que la
implementa**. Así se conserva el cambio atómico «regla + caso + código» que justificó tener el corpus en
el mismo repositorio.

## 2. Ciclo completo, con el ejemplo de `LANG.CONTROL.FOR`

### Paso 1 · Redactar (`borrador`)

```bash
(cd packages/pseudolearn_spec && cargo run -p see_cli -- new LANG.CONTROL.FOR --domain lang)
```

1. Leer la sección de origen (`language-spec.md` §8.5) y los hallazgos que la tocan (H-37).
2. Escribir **definiciones**, **reglas** (una afirmación cada una, con su fuerza), **errores** y **no
   objetivos**.
3. Declarar `depende_de` con rangos (`LANG.TYPES.INTEGER ^1`). Si la dependencia no existe todavía, se
   crea primero en `borrador`, siguiendo el grafo de [03](03-catalogo-de-especificaciones.md) §3.
4. `see validate` en verde para esquema, referencias e identidad. Las reglas sin verificación quedan
   avisadas.

### Paso 2 · Casos (`propuesta`)

1. Para cada regla: al menos un caso de camino feliz, uno de camino infeliz y los límites que apliquen
   (`AGENTS.md` §5).
2. Cada valor esperado declara su **origen**: `escrito` por quien lee la regla, `derivado` de una
   propiedad, o `capturado` con `revisado_por`.
3. `see validate` en verde: ninguna regla huérfana.
4. `see conform --subject reference --only LANG.CONTROL.FOR`. Cada diferencia con el núcleo Dart se
   clasifica en una de tres:
   - **El núcleo Dart tiene razón y la especificación está mal** → se corrige la especificación.
   - **La especificación tiene razón** (por ejemplo, H-37) → vínculo `exento` en
     `packages/pseudolearn_core/conformance.yaml`, con el hallazgo como justificación.
   - **No está claro** → pregunta abierta en el cuerpo no normativo. La especificación no avanza hasta
     que la persona responsable decida (`CONFLICT-REPORT`).

### Paso 3 · Revisión (`experimental`)

- Revisa alguien distinto de quien escribió los casos, o, si el equipo es una sola persona, en una sesión
  separada con la lista de comprobación de §4.
- La persona responsable aprueba el paso a `experimental` y queda registrado (`see` guarda quién y
  cuándo en el historial de la especificación).

### Paso 4 · Tests de unidad en rojo

En el crate dueño (aquí `pseudolearn_syntax` para la forma y `pseudolearn_semantic` para H-37):

```rust
#[test]
fn reports_control_variable_modified_inside_counted_loop_body() {
    let analysis = analyze_spanish_program(COUNTED_LOOP_MODIFYING_CONTROL_VARIABLE);
    assert_eq!(
        analysis.diagnostic_codes(),
        vec![DiagnosticCode::ControlVariableModified]
    );
}
```

El test falla por la razón esperada: el diagnóstico no se emite, no un error de compilación.

### Paso 5 · Código

- El mínimo que pone en verde los tests de unidad **y** los casos de `see conform --subject engine --only
  LANG.CONTROL.FOR`.
- Se añade el vínculo `cumple` en `packages/pseudolearn_engine/conformance.yaml`.
- Se ejecutan todos los verificadores del workspace (`cargo xtask verify`).

### Paso 6 · Estabilización (`estable`)

- Casos verdes en `engine`, y en `reference` o con `exento` justificado.
- Ninguna pregunta abierta.
- `see lock` fija la versión `1.0.0` y su hash.

## 3. Cambiar una especificación existente

1. Se edita el texto normativo.
2. `see diff` propone la clase de cambio ([11](../11-especificaciones-ejecutables-diseno.md) §6.2) y la
   persona la confirma.
3. `see impact` lista dependientes, vínculos desactualizados y artefactos que hay que regenerar.
4. Se sube la versión. Si es un cambio incompatible de `LANG`, exige edición nueva (D-11).
5. Se actualizan los vínculos de los sujetos y se regeneran las exportaciones. Todo en el **mismo
   cambio**.

## 4. Lista de comprobación de revisión de una especificación

- [ ] Cada regla es **una** afirmación y se entiende sin leer el código de nadie.
- [ ] Ninguna regla describe *cómo* se implementa (estructuras, algoritmos, el `i64`, el `BigInt`).
- [ ] Cada regla tiene camino feliz, camino infeliz y límites.
- [ ] Los valores esperados se escribieron leyendo la regla, no ejecutando un sujeto. Los `capturado`
      llevan revisor.
- [ ] Casos en los dos perfiles, o exclusión justificada.
- [ ] Los no objetivos dicen lo que deliberadamente no se cubre.
- [ ] Las dependencias usan rangos y el grafo sigue acíclico.
- [ ] Los diagnósticos nuevos existen en `DIAG.CATALOG` con ficha bilingüe.
- [ ] Si toca el presupuesto de palabras reservadas, el impacto está medido (E-10).

## 5. Definición de «terminado» para una unidad de trabajo

Una especificación está terminada cuando:

1. está en `estable` (o en `experimental`, con la razón registrada en la fase);
2. el vínculo `engine` está en `cumple`;
3. `cargo xtask verify` y `see validate`, `see lock --check`, `see export --check` y
   `see conform --subject engine` están en verde;
4. el `README.md` del crate que la implementa explica las decisiones de *cómo* que haya tomado
   (`DOC-README-TRUTH`, contrato R2);
5. el commit sigue la skill `commit-message` y nombra la especificación por su identificador en el
   cuerpo.
