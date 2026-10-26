# PG-2.17 · Protocolos de E-PG-03 y E-PG-04, candidatos `PERF.PG.*` y materiales de E-PG-10

Documento transitorio de `docs/`. Fija lo que `PG-2.17.01`, `.02` y `.05` piden antes de recolectar nada. Ninguna
campaña se ha ejecutado; `PG-2.17.06` queda pendiente (campañas en segundo plano bajo `PERF.PROTOCOL`, con
autorización aparte).

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

- Cargas sembradas con `Vector`, `Resultado` y registros para 1, 10 y 100 combinaciones de tipos, más recursión de
  tipos e instanciación expansiva (esta última debe terminar en el límite tipado de 64 instancias).
- Control no genérico escrito a mano con la misma semántica y salida; la salida se compara por resumen criptográfico.
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

## 5. Pendiente declarado de `.17`

Cargas fuente (1/10/100 combinaciones y sus controles), recolección de tiempos en el trabajador, los orquestadores
`tool/e_pg_03.sh` y `tool/e_pg_04.sh` (modelo `e_pg_11.sh`) y la ejecución de campañas. Dependen de que `.06` de
`PG-2.07` y `PG-2.08` midan primero sus señales tempranas y de la máquina de referencia que fije la persona.

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
