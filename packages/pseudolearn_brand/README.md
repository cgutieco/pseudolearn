# pseudolearn_brand

Motor paramétrico de la identidad visual de PseudoLearn. Un catálogo declarativo (`brand.json`) y la geometría del
símbolo producen los vectores maestros de la marca, un módulo de TypeScript para la web y el documento de lineamientos,
y verifican que la app y la web no guarden copias que el motor ya no produce.

**No hace:** definir tokens de interfaz (color, tipografía y radios salen de la app), rasterizar íconos de plataforma ni
generar código Dart: a la app solo le verifica sus medidas.

## Dónde encaja

```mermaid
flowchart BT
    fonts["assets/fonts<br/>IBM Plex Mono y Sans"] --> brand["packages/pseudolearn_brand"]
    brand --> web["apps/pseudolearn_web<br/>symbol-path.generated.ts y favicon.svg"]
    brand -. verifica .-> app["apps/pseudolearn_app<br/>brand_metrics.dart y assets/fonts"]
```

La línea punteada es verificación, no emisión. Las salidas de `out/`, el favicon y el módulo de TypeScript no se
versionan.

## Arquitectura

```mermaid
flowchart BT
    model["model<br/>catalog, geometry, typography, composition"]
    render["render<br/>svg, typescript, dart, html"]
    pipeline["pipeline<br/>artefacts, repository"]
    model --> render
    model --> pipeline
    render --> pipeline
```

| Pieza                       | Responsabilidad                                                                                      |
|-----------------------------|------------------------------------------------------------------------------------------------------|
| `model/`                    | Catálogo tipado, geometría del símbolo, contornos de IBM Plex, composición y medidas derivadas       |
| `render/`                   | Un emisor por destino: SVG, módulo TypeScript, lectura de las constantes Dart y HTML de lineamientos |
| `pipeline/`                 | Plan de artefactos, escritura, comparación y localización de la raíz del monorepo                    |
| `brand.json`                | Variantes, símbolo, tipografía, paleta, colocación, lockups y emisores                               |
| `templates/guidelines.html` | Plantilla con huecos `{{svg:variante}}` y `{{path:pieza}}`                                           |
| `assets/fonts/`             | Las dos caras de las que se contornea el logotipo (ver su README)                                    |
| `tool/check_limits.py`      | Capas, límites de tamaño, comentarios e imports prohibidos                                           |

## Flujo principal

Flujo de datos de `build`, no de dependencias.

```mermaid
flowchart LR
    json["brand.json"] --> catalog[Catálogo]
    fonts["IBM Plex"] --> catalog
    catalog --> emit[Emisores]
    template["guidelines.html"] --> emit
    emit --> out["out/: 12 vectores y lineamientos"]
    emit --> ts["web: módulo TypeScript y favicon"]
    catalog --> check[check]
    check --> dart["app: brand_metrics.dart y fuentes"]
```

## Reglas que conviene saber

- `model/` no importa nada del paquete; `render/` importa `model/`; `pipeline/` importa ambos (`architecture.json`).
- Archivos de 170 líneas, funciones de 40, 6 parámetros posicionales y 3 niveles de anidamiento; sin comentarios en
  `pseudolearn_brand/`.
- Imports prohibidos: `subprocess`, `socket`, `urllib`, `requests` y `shutil`.
- Una variante nueva es una entrada en `brand.json`; el catálogo rechaza claves desconocidas.
- Los archivos generados no se editan a mano. `check` falla con `BRAND-COPY-STALE`, `BRAND-TS-STALE`,
  `BRAND-DART-DRIFT`, `BRAND-FONT-DRIFT` o `BRAND-TEMPLATE-GEOMETRY` cuando un consumidor diverge.

## Comandos útiles

Desde este directorio:

| Para qué                               | Comando                                                                        |
|----------------------------------------|--------------------------------------------------------------------------------|
| Generar todos los artefactos (15)      | `python3 -m pseudolearn_brand build`                                           |
| Verificar consumidores y catálogo      | `python3 -m pseudolearn_brand check`                                           |
| Verificar capas y límites              | `python3 tool/check_limits.py`                                                 |
| Ejecutar los tests                     | `python3 -m unittest discover -s test -t .`                                    |
| Comprobar que la web no pega geometría | `(cd ../../apps/pseudolearn_web && pnpm check:brand)`                          |
| Rasterizar íconos de iOS y macOS       | `(cd ../../apps/pseudolearn_app && flutter test tool/generate_app_icons.dart)` |

Requisitos: Python 3.9 o superior con `fonttools` (`python3 -m pip install fonttools`).
