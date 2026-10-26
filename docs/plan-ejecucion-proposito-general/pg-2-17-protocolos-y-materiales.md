# PG-2.17 · Protocolos de E-PG-03 y E-PG-04, candidatos `PERF.PG.*` y materiales de E-PG-10

Documento transitorio de `docs/`. Fija lo que `PG-2.17.01`, `.02` y `.05` piden antes de recolectar nada. Las campañas
de E-PG-03 y E-PG-04 se ejecutaron el 2026-10-26 en la Mac de referencia (§5).

## 1. Candidatos `PERF.PG.*`

Son candidatos hasta que la persona los apruebe; no sustituyen ningún `PERF` vigente (`PERF.PROTOCOL`,
`PERF.SUITE.CORE`, `PERF.ARTIFACT.SIZE`, `PERF.AOT.LEVEL`). Los marcados «determinista» pueden ser tests; los demás
solo se miden en campaña.

| Candidato | Magnitud | Tipo |
|---|---|---|
| `PERF.PG.VALUE` | asignaciones de montón por registro en marco (cero esperado); bytes copiados por asignación | determinista; copia por bytes medida |
| `PERF.PG.RESULT` | propagación frente a rama manual equivalente; bytes por variante | medida; bytes determinista |
| `PERF.PG.MATCH` | `Segun` exhaustivo frente a selección equivalente; bytes de código | medida; sin cociente inventado |
| `PERF.PG.GENERICS` | instancias, bytes de RI/bytecode/objeto, tiempo de compilación por fase | instancias y bytes deterministas |
| `PERF.PG.CLOSURE` | asignaciones, retención tras el último dueño, coste de llamada indirecta | asignaciones deterministas; coste medido |
| `PERF.PG.COLLECTION` | operaciones, colisiones adversarias, bytes por elemento, colección vacía | bytes deterministas; peor caso informado |
| `PERF.PG.CLEANUP` | mismas instrucciones que el control sin limpieza; cero doble ejecución | determinista |

## 2. E-PG-03 · Genéricos y registros

- Cargas sembradas con `Vector`, `Resultado` y registros para 1, 10 y 60 combinaciones de tipos, más recursión de
  tipos e instanciación expansiva (esta última debe terminar en el límite tipado de 64 instancias; por eso la carga mayor es de 60 combinaciones y no de 100, que el propio límite rechaza).
- Control no genérico escrito a mano con la misma semántica y salida; la salida textual se compara exactamente.
- Se mide: instancias, bytes de RI/bytecode/objeto, tiempo de compilación por fase y tiempo de recorrido.
- Éxito: crecimiento como máximo proporcional al número de instancias; recorrido ≤ 1,10× control; límite tipado ante
  expansión. Un fallo se reporta antes de cambiar la estrategia.
- Procedencia: release, ≥ 10 procesos × 30 muestras por carga, bootstrap 95 % sobre medias por proceso, revisión,
  toolchain, flags, hashes, hardware y semilla. Una máquina por campaña.

## 3. E-PG-04 · Clausuras y recolector

- Capturas inmutables, ciclos a través de entornos, escape, identidad y recolección forzada por asignación.
- Control: llamada directa equivalente con la misma salida.
- Se mide: asignaciones, retención tras cerrar el último dueño y coste de llamada indirecta.
- Éxito: cero pérdida y cero alias indebido, memoria liberable, llamada indirecta ≤ 1,25× control. Los marcos
  suspendidos se registran como no aplicables hasta PG-4.

## 4. Formato de campaña (`e-pg-2/1`)

`pseudolearn_bench_worker pg-verify <campaña.json>` valida el archivo antes de cualquier análisis:

```json
{"protocol": "e-pg-2/1", "experiment": "E-PG-03", "processes": [
  {"process": 0, "machine": "referencia", "clock_resolution_nanoseconds": 1.0,
   "samples": [{"workload": "generic-10", "candidate_nanoseconds": 120, "control_nanoseconds": 100,
                "candidate_output": "<hash>", "control_output": "<hash>"}]}]}
```

Se rechaza: menos de diez procesos, identidad de proceso repetida, distinta de treinta muestras, resolución de reloj
nula, duración cero, salida del candidato distinta de la del control, máquinas mezcladas, protocolo o experimento
desconocidos.

## 5. Ejecución de `.17` (2026-10-26)

Máquina de referencia: esta Mac (Apple M2), designada por la persona. Cargas en `pseudolearn_bench_worker`
(`pg_workloads.rs`), recolección con `pg-collect`, resumen con `pg-summary` y orquestación con
`tool/e_pg_campaign.sh`; los crudos y la procedencia quedan en el directorio local ignorado
`packages/pseudolearn_spec/results/pg-2-campaign-2026-10-26/`.

| Carga | Razón candidato/control | Intervalo 95 % | Umbral | Resultado |
|---|---|---|---|---|
| `generic-1` | 1,002 | 0,749–1,303 | ≤1,10 | cumple en la estimación puntual |
| `generic-10` | 1,007 | 0,971–1,042 | ≤1,10 | cumple |
| `generic-60` | 1,011 | 1,003–1,017 | ≤1,10 | cumple |
| `closure-call` | 1,140 | 0,850–1,515 | ≤1,25 | cumple en la estimación puntual; el intervalo supera el umbral |
| `closure-create` | 4,741 | 4,196–5,301 | sin umbral | informativo (crea una clausura por iteración) |

Forma determinista: el objeto nativo de las cargas genéricas mide lo mismo que el del control no genérico (2168, 6448
y 30208 bytes) y crece por debajo de proporcional al número de instancias (1, 10, 60); la recursión polimórfica
expansiva es rechazada por el límite tipado; la salida con recolección forzada coincide con la normal en todas las
cargas de clausuras. La llamada indirecta cumple por estimación puntual, pero con un intervalo ancho (cada muestra dura
unos 0,3 ms); se informa sin ajustar controles ni umbrales.

## 6. E-PG-10 · Materiales para la persona

La IA no produce participación humana; la persona aporta el resultado o difiere el experimento (decisión del
2026-10-22: complementario y no bloqueante).

**Tareas (por participante, orden contrabalanceado es/en):**
1. Archivo: leer un programa con un enumerado y un registro y decir qué imprime.
2. Error: corregir un programa con un `Resultado` sin tratar guiándose solo por el diagnóstico.
3. Captura: explicar por qué un `SubProceso` anidado no puede capturar una variable `Mutable` y reescribirlo.
4. Genéricos: completar una función `identidad<T>` y usarla con dos tipos.

**Guion:** presentación de 3 minutos sin explicar la sintaxis; pensar en voz alta; máximo 10 minutos por tarea; el
facilitador solo responde «¿qué estás pensando?». Se registran tiempo, intentos, diagnóstico leído y confusión
declarada. Orden de idiomas alternado por participante.

**Consentimiento:** participación voluntaria, sin datos personales; se registran únicamente respuestas y tiempos con un
código anónimo; puede retirarse sin consecuencias; los datos se conservan solo para evaluar el diseño del lenguaje.

**Plantilla de análisis:** por tarea, tasa de éxito, mediana de tiempo, errores más repetidos y citas literales de
confusión; comparación es/en; decisión sobre si algún diagnóstico o forma de sintaxis necesita cambio. Piloto previsto
de al menos 12 principiantes.
