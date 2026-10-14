# E-02: techo semántico y representación

Captura final en Apple M2, Rust release, diez procesos independientes y treinta muestras por núcleo y variante. Cada muestra acumula ejecuciones completas durante al menos 5 ms; V3 exige al menos un punto de control real. Las salidas de las cuatro variantes coinciden con los dos tamaños del corpus en los tests.

Procedencia previa a compilación: commit `bceb6889daaca54b6d87c25b36c5d60ea5dcd2b3`; hashes en capture.json. Resolución mínima observada: 41 ns. Se conservan 12.000 muestras, con cero descartadas. CPU y máximo de RSS del proceso se conservan como salida de time en processes.json; no se atribuyen a cada núcleo.

| Familia | V1/V0 [IC 95 %] | V2/V1 [IC 95 %] | V3/V2 [IC 95 %] | Revisar antes de R5 |
|---|---|---|---|---|
| arrays | 2.3099 [2.1023, 2.7506] | 4.0548 [3.2911, 5.5906] | 0.9946 [0.7455, 1.1965] | Sí |
| numeric | 1.7158 [1.6864, 1.7382] | 2.0575 [1.9962, 2.1611] | 1.0045 [0.9735, 1.0266] | Sí |
| objects | 1.1139 [1.0882, 1.1609] | 3.6046 [3.4272, 3.7087] | 1.1092 [1.0992, 1.1232] | Sí |
| recursive | 2.7728 [2.7524, 2.8071] | 2.5893 [2.5514, 2.6174] | 1.1206 [1.1021, 1.1463] | Sí |

## Por núcleo

| Núcleo | V1/V0 | V2/V1 | V3/V2 |
|---|---|---|---|
| bounce | 1.8136 [1.7936, 1.8384] | 8.9019 [8.6229, 9.1817] | 1.1251 [1.1115, 1.1390] |
| list | 0.8454 [0.8419, 0.8487] | 2.2340 [2.2206, 2.2553] | 1.1882 [1.1539, 1.2514] |
| mandelbrot | 1.3223 [1.2752, 1.3505] | 1.1366 [1.0938, 1.2042] | 0.9910 [0.9513, 1.0176] |
| nbody | 2.2264 [2.1883, 2.2511] | 3.7246 [3.6168, 3.8847] | 1.0183 [0.9964, 1.0358] |
| permute | 2.7728 [2.7524, 2.8071] | 2.5893 [2.5514, 2.6174] | 1.1206 [1.1021, 1.1463] |
| queens | 2.4275 [2.0066, 3.4421] | 4.9080 [3.2522, 9.1878] | 0.7600 [0.4301, 1.0957] |
| richards | 1.9431 [1.7525, 2.3762] | 2.4801 [1.9420, 2.8134] | 1.0895 [1.0667, 1.1091] |
| sieve | 2.1981 [2.1772, 2.2161] | 3.3500 [3.3058, 3.4060] | 1.3017 [1.2878, 1.3116] |
| storage | 0.2027 [0.2004, 0.2060] | 2.8597 [2.8507, 2.8676] | 1.0493 [1.0466, 1.0526] |
| towers | 2.8402 [2.8188, 2.8583] | 4.3142 [4.2913, 4.3506] | 1.0984 [1.0891, 1.1045] |

## Decisión y límites

El criterio V2/V1 > 1,30 activa una revisión de la representación de memoria antes de autorizar R5. R3 conserva el diseño especificado y publica la evidencia desfavorable; no reajusta el diseño para ocultar el resultado. Las hipótesis provisionales no son resultados confirmados.

Las medias por proceso se emparejan; las familias usan media geométrica y bootstrap reproducible de 1.000 remuestras sobre logaritmos. Los candidatos de cambio se conservan por núcleo y proceso en summary.json; no se declara estacionariedad. El hardware y la carga externa no están controlados.

El experimento mide núcleos compilados, no despacho de VM, recolector completo, servicio de lenguaje ni acceso a texto Unicode. Los bancos se reservan antes del intervalo; el estado lógico y el montón se reinician en cada ejecución. Los puntos de control guardan páginas y regiones activas de bancos, pero no una continuación serializable de CPU.

initial/ conserva la primera captura completa, donde Storage y Towers no tomaban puntos de control. La corrección añade consultas en llamadas y rechaza V3 sin puntos. Sus muestras no se mezclan con la captura final.
