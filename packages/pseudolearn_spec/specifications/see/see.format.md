---
formato: see/1
id: SEE.FORMAT
titulo: Formato de especificaciones
dominio: proceso
estado: estable
version: 1.0.0
duenos: [responsable-especificaciones]
revisado_por: [Cesar Antonio Gutierrez Contreras]
sujetos: [see]
resumen: Formato de especificaciones.
---

# Formato de especificaciones

```regla
id: R1
fuerza: DEBE
clase: sistema
texto: El formato see/1 contiene metadatos YAML completos y bloques tipados regla, caso, definicion, error, propiedad, invariante, precondicion y resultado; rechaza campos desconocidos.
verificacion: [revision_humana]
justificacion: Revisión estructural manual contra el plan aprobado; la revisión independiente de la persona registrada en revisado_por aprueba su estabilidad.
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los casos admiten sujetos opcional como subconjunto no vacío de los sujetos declarados: ausente aplica a todos; un sujeto excluido no ejecuta ni aporta evidencia para ese caso. Las definiciones admiten valor como objeto normativo; los casos admiten semilla opcional de entero con signo de 64 bits, transmitida a seed sin alterar el valor; ausente usa 42. diagnosticos compara multiconjuntos y diagnosticos_ordenados exige el orden exacto sin ordenar ni deduplicar evidencia.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de esquema, semilla y recursos; no se atribuye revisión humana."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los bloques medicion, instruccion y cobertura son tipados. medicion declara métrica, unidad, suite, comparador, umbral, carácter provisional, plataformas y la regla de PERF.PROTOCOL que la rige. instruccion declara nombre, firma, clases de valor, semántica, trampas, efectos y observación. cobertura asocia una regla con instrucciones o con un motivo sin RI. Los casos admiten las operaciones trace, ir y cli con sus fuentes programa_ri y cli, límites del anfitrión y cancelación; las expectativas admiten la terminación cancelled, el tipo de límite alcanzado, eventos ordenados, el estado en un índice de evento, el resultado de RI, el código de salida, la salida de error y el JSON de máquina.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de esquema y validación, fixtures negativos y verificación mecánica en cargo xtask verify."
}
```


Los casos pueden declarar anfitrion como datos de un proveedor en memoria. files contiene rutas
relativas y textos UTF-8 o listas de octetos; args contiene argumentos; clock contiene instantes
enteros no negativos en nanosegundos; permissions y requested_permissions declaran autoridad
concedida y solicitada. faults contiene fallos por operación, ruta, código portable e incertidumbre;
secrets contiene referencias con identidad de clave y valor solo para el proveedor de prueba, y
secret_keys asocia cada identidad de clave con la clave que autentica la referencia; el corredor
rechaza cualquier cinta viva que contenga el valor de un secreto en forma textual, escapada,
decimal o hexadecimal. detached declara que el anfitrión resuelve cada efecto fuera del motor
mediante effect_result, y cancel_on_awaiting_effect indica el número de secuencia de efecto en el
que el anfitrión cancela la ejecución mientras el efecto permanece en awaiting_effect.
grabar_y_reproducir exige reproducir la cinta viva con la misma identidad de autoridad, sin archivos,
argumentos ni instantes de reloj, y comparar salida y terminación; la reproducción no consulta al
proveedor. alterar_cinta permite truncar la última entrada, corromper el resumen criptográfico o la
carga útil o cambiar la semilla antes de reproducir la cinta grabada para comprobar su rechazo. La
clave anfitrion_observado, dentro de espera, compara las llamadas recibidas por el proveedor
(llamadas), los recursos que siguen abiertos tras el cierre final del anfitrión (recursos_abiertos),
el estado de reproducibilidad de la cinta (estado_cinta), la secuencia ordenada de entradas de
efecto del anfitrión con su effect_seq, capacidad, operación, desenlace e identidad de clave de
secreto (efectos), y el código de rechazo al reproducir la cinta (reproduccion_fallo). Cuando la
terminación esperada es awaiting_effect, efecto_pendiente compara effect_seq, capability_kind,
operation, arguments_summary y source_node_id del efecto suspendido. Las llamadas de casos api
admiten también start, advance, input, effect_result y cancel sobre recursos de ejecución. El
esquema rechaza campos desconocidos, rutas no relativas, octetos fuera de 0 a 255, fallos inciertos
en operaciones de solo lectura, secuencias de efectos no crecientes y combinaciones incoherentes de
alteración de cinta o efecto pendiente. Estos datos no autorizan acceso a disco ni red.
