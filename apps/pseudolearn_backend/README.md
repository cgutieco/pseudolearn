# pseudolearn_backend

Backend de Supabase de PseudoLearn: cuatro Edge Functions en Deno y las migraciones SQL del esquema de Postgres. Hace lo
que no cabe en RLS ni en funciones SQL: operaciones que exigen un secreto que la app no puede tener o una llamada a un
tercero (Apple, Paddle, el proveedor del modelo).

**No hace:** sincronizar documentos, progreso ni ejercicios (eso lo resuelven las RPC SQL `push_*` desde la app), ni
guardar tokens de Apple, ni usar Storage.

## Dónde encaja

```mermaid
flowchart BT
    supabase["Supabase: GoTrue y Postgres"] --> backend["apps/pseudolearn_backend"]
    apple["Apple: REST de Sign in with Apple y App Store"] --> backend
    paddle["Paddle: pagos y webhooks"] --> backend
    modelo["Proveedor del modelo: Responses API"] --> backend
    backend --> app["apps/pseudolearn_app"]
```

## Arquitectura

Cada función de `supabase/functions/<función>/` es hexagonal. Las flechas van de la dependencia a quien la usa.

```mermaid
flowchart BT
    domain --> application
    domain --> infrastructure
    application --> http
    domain --> http
    http --> index["index.ts"]
    application --> index
    infrastructure --> index
    domain --> index
```

| Pieza                  | Qué hace                                                                                               | Nota                                                                  |
|:-----------------------|:-------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------|
| `delete-account`       | Elimina la cuenta: valida la sesión, revoca Sign in with Apple y borra el usuario de `auth.users`      | Sesión validada por `GET /auth/v1/user`, `verify_jwt = false`         |
| `agent-responses`      | Proxy del modelo del agente: fija el modelo, autoriza el saldo, reenvía y debita según el `usage` real | Dueño del dominio, el entorno y el libro que reutilizan las otras dos |
| `agent-credits`        | Saldo, canje de compras de App Store y enlaces de pago y portal de Paddle                              | Importa de `agent-responses`                                          |
| `store-events`         | Recibe notificaciones firmadas de App Store y webhooks de Paddle                                       | `verify_jwt = false`: lo autentican las firmas                        |
| `supabase/migrations/` | Esquema, RLS y RPC en el orden en que se aplican                                                       | Sin comentarios                                                       |
| `supabase/deferred/`   | Migración lista que espera una condición antes de pasar a `migrations/`                                | No se aplica con `db push` mientras esté aquí                         |
| `tool/`                | Verificador de arquitectura y su lexer                                                                 |                                                                       |

El diagrama omite las dependencias hacia `domain` de cada capa salvo las de composición; la matriz exacta está en
`architecture.json`.

## Flujo principal

Flujo de datos de `agent-responses`, no de dependencias:

```mermaid
flowchart LR
    app["App"] --> metodo["Método y entorno"]
    metodo --> sesion["Sesión en GoTrue"]
    sesion --> cuerpo["Política del cuerpo"]
    cuerpo --> autoriza["agent_authorize"]
    autoriza --> modelo["Modelo"]
    modelo --> debito["agent_debit"]
    debito --> app
```

Si el modelo falla, responde 429 o no trae `usage`, no hay débito.

## Reglas que conviene saber

- Lo único que se vende es Nodo, así que los productos se llaman `pseudolearn.nodo.trial`, `pseudolearn.nodo.monthly` y
  `pseudolearn.nodo.topup150` en la app, en `agent-credits/domain/purchase.ts`, en App Store Connect y en Paddle. Un
  identificador distinto en una tienda deja la compra sin canjear.
- Las capas solo importan lo que `architecture.json` les permite; `domain`, `application` y `http` no usan `Deno`,
  `fetch`, `crypto` ni `console`, e `infrastructure` no usa `Deno`, `fetch` ni `console`.
- El código de `supabase/functions/` no admite imports `npm:`, `jsr:`, `node:`, `http:` ni `https:`: solo la API web de
  Deno.
- Cero comentarios en `supabase/functions/`, `test/` y `tool/`; cada archivo de función tiene como máximo 120 líneas
  (`test/` y `tool/` exentos).
- El `fetch` global solo aparece en `index.ts`; el resto recibe un `Fetcher` inyectado.
- Ningún secreto vive en el repositorio (`*.p8` y `.env*` ignorados); los logs nunca llevan tokens, códigos, correos ni
  contenido.
- `deno fmt` no formatea este README: lo excluye `deno.json` porque los README del monorepo usan 120 columnas y
  `deno fmt` las reflujaría a 100.

## Integridad del libro de créditos

`20261110000001_agent_ledger_integrity.sql` reescribe `agent_authorize`, `agent_debit` y `agent_apply_purchase`. Las
decisiones salen de una auditoría de seguridad del 2026-11-10.

- **Un `x-request-id` solo autoriza una llamada.** El cliente elige el id y el libro lo usaba como clave de idempotencia:
  repetirlo volvía a autorizar y el segundo débito chocaba con el primero y no cobraba. Ahora `agent_authorize` responde
  `invalid_request` si el id ya tiene cualquier evento. La app genera un id nuevo en cada llamada, así que no le afecta.
- **Reserva mientras hay llamadas en vuelo.** Una autorización sin débito de los últimos 150 s (el modelo corta a los
  120 s) cuenta como en vuelo. Con llamadas en vuelo, se exige que el saldo supere `en vuelo × tope por llamada`; si no,
  `rate_limited`, que la app reintenta. Así el exceso sin cobrar se limita a una llamada, porque el coste real solo se
  conoce después. Se descartó cobrar 0 en los fallos del modelo para liberar la reserva antes: cambiaba la regla «sin
  `usage` no hay débito» y la reserva caduca sola.
- **Bloqueo por usuario.** `agent_authorize`, `agent_debit` y `agent_apply_purchase` toman
  `pg_advisory_xact_lock(hashtext('agent_ledger:' || usuario))`, y `agent_apply_purchase` también uno por
  `tienda:transacción`, para que las comprobaciones y los inserts no se crucen entre peticiones concurrentes.
- **Una recarga acredita una sola cuenta.** Las recargas no tienen `original_transaction_id`, así que no pasan por
  `agent_store_links`; si la misma `tienda + transacción` ya pertenece a otro usuario, se responde
  `purchase_owned_elsewhere`. No se añadió un índice único porque fallaría al desplegar si producción ya tuviera filas
  duplicadas.
- **Una sola prueba gratuita por cuenta, venga de donde venga.** La guarda `trial_used` se aplica cuando
  `p_product = 'trial'` o `p_trial`. Antes, las pruebas de Paddle (`trialing`) y las ofertas introductorias de App Store
  llegaban como `monthly` con `p_trial` y la saltaban.

**Pendientes declarados**

- Las notificaciones de App Store sin vínculo previo se atribuyen al `appAccountToken` que elige el comprador
  (`store_events_service.ts`). Explotarlo exige conocer el UUID de otra cuenta y un build que fije un token arbitrario;
  se registra como pista por validar, no se cambia el flujo de compra.
- Endurecimiento sin impacto demostrado: limitar el cuerpo de `delete-account` antes de leerlo, comprobar las extensiones
  X.509 de Apple analizándolas en vez de buscar bytes, deduplicar `notificationUUID` y el id de evento de Paddle, dejar
  constancia de las revocaciones que llegan antes que la compra, y aplicar la migración diferida que retira
  `delete_account()`.

## Comandos útiles

| Para qué                                                            | Comando                                                                      |
|:--------------------------------------------------------------------|:-----------------------------------------------------------------------------|
| Todos los verificadores (formato, lint, tipos, arquitectura, tests) | `deno task verify`                                                           |
| Solo el verificador de arquitectura                                 | `deno task architecture`                                                     |
| Tests                                                               | `deno task test`                                                             |
| Migraciones contra un Postgres temporal, con casos negativos        | `deno task migrations`                                                       |
| Servir una función en local                                         | `supabase functions serve delete-account --env-file supabase/functions/.env` |
| Aplicar migraciones al proyecto enlazado                            | `supabase db push --linked`                                                  |
| Desplegar funciones                                                 | `supabase functions deploy <función> --project-ref <ref>`                    |
| Declarar secretos                                                   | `supabase secrets set --project-ref <ref> NOMBRE=valor`                      |

Requisitos: Deno `>=2.9` para `verify`; la CLI de Supabase y Docker para servir y desplegar; `initdb`, `pg_ctl` y `psql`
de Postgres 17 en el `PATH` para `migrations`, que no forma parte de `verify`.
