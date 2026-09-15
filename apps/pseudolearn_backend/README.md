# pseudolearn_backend

Fuente de verdad técnica del backend de Supabase de PseudoLearn. Aquí vive el _por qué_ de cada
decisión, para que el código no necesite comentarios que lo expliquen. Un cambio de arquitectura o
de decisión de diseño se documenta aquí en el mismo cambio que lo introduce (`DOC-README-TRUTH`).

Las reglas transversales del monorepo están en el `AGENTS.md` de la raíz. Las reglas que los
verificadores ejecutan están en `architecture.json`, junto a este archivo.

**Estado:** Una Edge Function (`delete-account`) con 71 tests en verde, verificador de arquitectura
con casos negativos, y el esquema SQL de sincronización versionado como migraciones de la CLI de
Supabase. Proyecto de producción: `iugecdkguazwhdngnoao` (`pseudolearn-db`).

---

## 1. Qué es y qué no es

### 1.1 Propósito y problema que resuelve

`pseudolearn_backend` es la parte servidor de PseudoLearn que no cabe en políticas RLS ni en
funciones SQL: operaciones que exigen un secreto que el cliente no puede tener (la clave `.p8` de
Sign in with Apple, la clave secreta de Supabase) o una llamada a un tercero. Es también el dueño
del esquema de Postgres (tablas, RLS, RPC) que `apps/pseudolearn_app` consume con la clave
publicable.

Lo consume `apps/pseudolearn_app` por HTTP: `supabase.functions.invoke('delete-account')` y las RPC
`push_documents` / `push_progress`. No existe dependencia de compilación entre ambos miembros.

### 1.2 Responsabilidades primarias

1. **Eliminación de cuenta conforme a la directriz 5.1.1(v) de App Store:** validación de la sesión,
   revocación del token de Sign in with Apple ante `https://appleid.apple.com/auth/revoke` y borrado
   definitivo del usuario de `auth.users`, que arrastra por `ON DELETE CASCADE` todas sus filas de
   `public`.
2. **Esquema de base de datos:** migraciones SQL en `supabase/migrations/`, en el orden en que se
   aplican a producción.
3. **Secretos del servidor:** declaración de qué secretos existen, quién los lee y dónde se guardan
   (§2.1). Ningún secreto vive en el repositorio.

### 1.3 Fuera de alcance a propósito

#### De producto

- **Sincronización de documentos y progreso:** vive en las RPC SQL `push_documents` y
  `push_progress` bajo bloqueo de fila; una Edge Function en ese camino añade latencia y un punto de
  fallo sin aportar un secreto ni un tercero.
- **Borrado diferido o recuperable de cuentas:** la eliminación es inmediata e irreversible
  (`should_soft_delete: false`). Una ventana de recuperación exige conservar datos de una cuenta que
  la persona pidió eliminar.
- **Revocación de tokens de Google:** la app no conserva tokens de Google y Supabase no los guarda
  en el canje por `id_token`; no hay nada que revocar. La directriz 5.1.1(v) exige revocación solo
  para Sign in with Apple.
- **Borrado de objetos de Storage:** el proyecto no usa Storage. Si lo usara,
  `auth.admin.deleteUser` falla mientras el usuario sea dueño de objetos, y la función tendría que
  borrarlos antes.

#### De implementación técnica

- **Dependencias remotas en el código de la función (`npm:`, `jsr:`, `https:`):** la función usa
  solo la API web de Deno (`fetch`, `crypto.subtle`, `Response`). `@supabase/supabase-js` no aporta
  nada que dos llamadas REST a GoTrue no hagan, y obliga a descargar el paquete en cada arranque en
  frío y a tener red para verificar tipos. `architecture.json` prohíbe esos prefijos.
- **Claves heredadas `anon` / `service_role`:** la función lee `SUPABASE_SECRET_KEYS`. Las heredadas
  dejan de funcionar al retirarse del proyecto, y una clave secreta nueva es rotable sin tiempo de
  corte.
- **`verify_jwt = true`:** la verificación de la pasarela solo entiende claves heredadas. La función
  valida el JWT del usuario ella misma contra `GET /auth/v1/user` (§4.4).

### 1.4 Casos de uso principales

1. **Eliminar una cuenta de Google o de enlace mágico:** `POST /functions/v1/delete-account` con
   `Authorization: Bearer <jwt>` y cuerpo vacío → `200 {"status":"deleted"}`.
2. **Eliminar una cuenta de Apple:** la app reabre la hoja nativa de Apple, obtiene un
   `authorizationCode` nuevo y lo envía como `{"apple_authorization_code": "…"}`. La función lo
   canjea, comprueba que el `sub` del `id_token` sea el de la identidad vinculada, revoca el token y
   borra.
3. **Reintento tras un fallo:** cualquier respuesta distinta de `200` deja la cuenta intacta salvo
   `delete_failed` después de revocar; el reintento con un código nuevo termina el borrado.

### 1.5 Pendientes técnicos declarados

| Pendiente                                        | De quién depende                                                                                                                                                                                                                           | Estado actual |
| :----------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------ |
| Eliminar `public.delete_account()` en producción | Publicación del build de `apps/pseudolearn_app` 1.0.0 que invoca `delete-account`: el build rechazado de la misma versión todavía llama a la RPC. Mover `supabase/deferred/…_drop_delete_account.sql` a `supabase/migrations/` y aplicarla | Abierto       |
| Límite de líneas por función en el verificador   | Un analizador de TypeScript sin dependencias remotas; hoy el tamaño de función se revisa en revisión de código                                                                                                                             | Abierto       |
| Prueba de extremo a extremo contra Apple real    | Una cuenta de Apple de prueba y un build de la app firmado; los tests cubren el contrato REST con respuestas simuladas                                                                                                                     | Abierto       |

---

## 2. Guía operativa y ciclo de vida

### 2.1 Requisitos previos y plataformas objetivo

- **Entorno de ejecución y SDKs:** Deno `>=2.9` para tests y verificadores; CLI de Supabase para
  desplegar y aplicar migraciones. Las Edge Functions de producción corren sobre el runtime de Deno
  de Supabase.
- **Plataformas soportadas:** Supabase Edge Functions (proyecto `iugecdkguazwhdngnoao`).
- **Secretos de la función** (Dashboard → Edge Functions → Secrets, o `supabase secrets set`):

| Secreto                | Valor                                                                                            | Lo inyecta |
| :--------------------- | :----------------------------------------------------------------------------------------------- | :--------- |
| `SUPABASE_URL`         | URL del proyecto                                                                                 | Supabase   |
| `SUPABASE_SECRET_KEYS` | JSON con las claves secretas; se usa la de nombre `default`                                      | Supabase   |
| `APPLE_TEAM_ID`        | Team ID de la cuenta de Apple Developer                                                          | Operador   |
| `APPLE_KEY_ID`         | Key ID de la clave con _Sign in with Apple_ habilitado, asociada al App ID `com.pseudolearn.app` | Operador   |
| `APPLE_CLIENT_ID`      | `com.pseudolearn.app` (Bundle ID compartido por iOS y macOS; no el Services ID)                  | Operador   |
| `APPLE_PRIVATE_KEY`    | Contenido PEM completo del archivo `AuthKey_<KeyID>.p8`; admite saltos de línea reales o `\n`    | Operador   |

Sin los cuatro secretos de Apple, las cuentas de Apple responden `misconfigured` y las demás se
eliminan con normalidad. El `.p8` no se versiona (`.gitignore` excluye `*.p8` y `.env*`).

### 2.2 Preparación e instalación

```bash
brew install deno supabase/tap/supabase
cd apps/pseudolearn_backend
deno install
supabase login
supabase link --project-ref iugecdkguazwhdngnoao
```

### 2.3 Ejecución en desarrollo

```bash
# Requiere Docker; lee secretos de supabase/functions/.env (no versionado)
supabase functions serve delete-account --env-file supabase/functions/.env
```

### 2.4 Compilación y build

No hay artefacto de build: la CLI empaqueta la función al desplegar. `deno check` valida los tipos
del punto de entrada (`deno task check`).

### 2.5 Pruebas y verificación inmediata

```bash
cd apps/pseudolearn_backend
deno task verify
```

`verify` encadena `fmt --check`, `lint`, `check`, `architecture` y `test`; ninguno necesita red
salvo la primera descarga de `@std/assert` para los tests.

### 2.6 Despliegue y distribución

Orden obligatorio, porque cada paso es seguro solo si el anterior ya está en producción:

```bash
cd apps/pseudolearn_backend
supabase secrets set --project-ref iugecdkguazwhdngnoao APPLE_TEAM_ID=<team> APPLE_KEY_ID=<key> APPLE_CLIENT_ID=com.pseudolearn.app APPLE_PRIVATE_KEY="$(cat <ruta-fuera-del-repo>/AuthKey_<key>.p8)"
supabase functions deploy delete-account --project-ref iugecdkguazwhdngnoao
supabase migration repair --status applied 20260101000001 20260101000002 --linked
supabase db push --linked
```

1. Secretos → función: la función desplegada sin secretos de Apple rechaza cuentas de Apple.
2. Función → build nuevo de la app: ese build invoca la función; sin función responde `http_404`.
3. `migration repair`: el esquema de las migraciones `20260101000001` y `20260101000002` ya existe
   en producción, aplicado fuera de la CLI; `repair` las registra sin volver a ejecutarlas.
4. `db push`: aplica `20260914000001_restrict_rpc_execute.sql`, compatible con el build rechazado de
   la 1.0.0.
5. Tras la publicación del build que invoca `delete-account`: mover
   `supabase/deferred/20260914000002_drop_delete_account.sql` a `supabase/migrations/` y ejecutar
   `supabase db push --linked`.

- **Checklist de release:**
  - [ ] `deno task verify` en verde.
  - [ ] `supabase secrets list` muestra los cuatro secretos de Apple.
  - [ ] Tras desplegar: una cuenta de prueba de Apple eliminada desaparece de `auth.users` y de
        Ajustes → Apple ID → Iniciar sesión con Apple en el dispositivo.
  - [ ] Documentación actualizada en el mismo commit (`DOC-README-TRUTH`).

---

## 3. Arquitectura y modelo del sistema

### 3.1 Paradigma arquitectónico

Arquitectura hexagonal por función. Cada carpeta de `supabase/functions/<función>/` se divide en
capas; el caso de uso depende de puertos, los adaptadores los implementan, y el punto de entrada es
el único archivo que conoce el entorno (`Deno`, `fetch`) y ensambla todo.

### 3.2 Diagrama de capas y dirección de dependencias

```
index.ts (composition) ──► http ──► application ──► domain
        │                                              ▲
        └──────────────► infrastructure ───────────────┘
```

Una capa importa de sí misma y de las que declara `may_import` en `architecture.json`
(`LAYER-DIRECTION`). Toda carpeta de una función es una capa declarada, y toda capa declarada existe
(`LAYER-DECLARED`).

### 3.3 Catálogo de carpetas, responsabilidades e invariantes

| Ruta (bajo `supabase/functions/<función>/`) | Responsabilidad única                                                   | Puede importar          | Prohibido                                             |
| :------------------------------------------ | :---------------------------------------------------------------------- | :---------------------- | :---------------------------------------------------- |
| `domain/`                                   | Tipos de resultado, entidad `AccountUser` y puertos                     | —                       | `Deno`, `fetch`, `crypto`, `console`, imports remotos |
| `application/`                              | Orquestación ordenada del borrado (`deleteAccount`)                     | `domain`                | `Deno`, `fetch`, `crypto`, `console`, imports remotos |
| `infrastructure/`                           | Adaptadores REST de Apple y de GoTrue, firma ES256, lectura del entorno | `domain`                | `Deno`, `fetch` global, `console`, imports remotos    |
| `http/`                                     | Parseo de la petición, mapeo resultado → estado HTTP, manejador         | `domain`, `application` | `Deno`, `fetch`, `crypto`, `console`, imports remotos |
| `index.ts`                                  | Composición: lee `Deno.env`, inyecta `fetch`, registra el resultado     | todas                   | imports remotos                                       |
| `supabase/migrations/`                      | Migraciones SQL aplicadas a producción, en orden                        | —                       | Comentarios                                           |
| `supabase/deferred/`                        | Migraciones listas cuya aplicación espera una condición de §1.5         | —                       | Aplicarse con `db push` mientras estén aquí           |
| `test/`                                     | Espejo de `supabase/functions/` y `tool/`; `test/support/` con fakes    | todo                    | Red real                                              |
| `tool/`                                     | Verificador de arquitectura (`check_architecture.ts`) y su lexer        | —                       | Comentarios                                           |

### 3.4 Flujo de datos y ciclo de vida

`POST /functions/v1/delete-account`:

1. `http/delete_account_request.ts`: método distinto de `POST` → `405 method_not_allowed`; sin
   `Authorization: Bearer <token>` → `401 unauthorized`; cuerpo que no es objeto JSON o
   `apple_authorization_code` vacío o no textual → `400 invalid_body`. Cuerpo vacío equivale a `{}`.
2. Sin entorno válido (`SUPABASE_URL` o clave secreta `default` ausentes) → `500 misconfigured`.
3. `application/delete_account.ts`, cortando al primer fallo:
   1. `UserVerifier.verify` (`GET /auth/v1/user`) → `null` → `401 unauthorized`.
   2. Si la cuenta tiene identidad `apple`:
      - sin configuración de Apple → `500 misconfigured`;
      - sin código → `409 apple_reauthentication_required`;
      - canje `POST /auth/token` fallido → `502 apple_token_exchange_failed`;
      - `sub` del `id_token` distinto del `sub` de la identidad → `403 apple_identity_mismatch`;
      - `POST /auth/revoke` distinto de `200` → `502 apple_revoke_failed`.
   3. `UserDeleter.delete` (`DELETE /auth/v1/admin/users/{id}`, `should_soft_delete: false`) sin
      `2xx` → `500 delete_failed`.
4. `200 {"status":"deleted"}`. Toda respuesta de error es `{"code": "<código>"}`.
5. Una excepción no prevista en cualquier paso → `500 unexpected_failure`.
6. `index.ts` escribe una línea JSON por petición con el código de resultado. Nunca registra tokens,
   códigos de autorización, correos ni identificadores de usuario.

El borrado de `auth.users` arrastra `documents`, `progress`, `account_revision` y `devices` por
`ON DELETE CASCADE` en sus claves foráneas `user_id`.

### 3.5 Concurrencia, asincronía y modelo de threading

Cada invocación es independiente y sin estado compartido. Las llamadas remotas son secuenciales —el
orden es parte del contrato (§4.2)— y cada una lleva `AbortSignal.timeout(10 s)`. Dos peticiones
simultáneas del mismo usuario son posibles: la segunda falla en `verify` o en `delete` y no deja
estado parcial; la app impide la doble pulsación.

---

## 4. Decisiones de diseño y fundamentos técnicos

### 4.1 Revocación de Apple por reautenticación en el momento del borrado

- **Problema:** la directriz 5.1.1(v) exige revocar el token de Sign in with Apple al eliminar la
  cuenta. El flujo nativo entrega `identityToken` y `authorizationCode`, no un token revocable;
  Supabase no guarda tokens de Apple en el canje por `id_token`. Revocar exige canjear un código en
  `/auth/token`, y el código caduca a los cinco minutos y es de un solo uso.
- **Elección:** la app vuelve a pedir la autorización de Apple al pulsar «Eliminar cuenta» y envía
  solo el `authorizationCode` nuevo. La función lo canjea, revoca el `refresh_token` recibido (o el
  `access_token` si Apple no emite `refresh_token`) y borra, en una sola petición. No se persiste
  ningún token de Apple.
- **Alternativas descartadas y por qué:**
  - _Canjear el código al iniciar sesión y guardar el `refresh_token`:_ un secreto de larga vida por
    usuario con tabla, cifrado y RLS; una segunda función en el camino de acceso; y las cuentas de
    Apple creadas antes de guardarlo nunca tendrían token que revocar.
  - _Revocar con el access token:_ sale del mismo canje; no ahorra ningún paso.

### 4.2 Revocar antes de borrar

- **Problema:** revocación y borrado son dos llamadas a dos sistemas sin transacción común.
- **Elección:** verificar → canjear → comprobar identidad → revocar → borrar. Cualquier fallo antes
  de borrar deja la cuenta intacta y el error es reintentable. Si falla el borrado después de
  revocar, el reintento pide un código nuevo, revoca de nuevo (Apple lo acepta) y termina.
- **Alternativas descartadas y por qué:**
  - _Borrar primero y revocar como mejor esfuerzo:_ un fallo de Apple deja una cuenta borrada con la
    autorización de Apple viva, que es exactamente el incumplimiento, sin forma de reintentar porque
    la sesión ya no existe.

### 4.3 Identidad de Apple verificada por el `id_token` del canje, no por un token enviado por el cliente

- **Problema:** un código de autorización válido podría pertenecer a otro Apple ID de la misma
  persona; revocarlo desvincularía la app de esa otra cuenta.
- **Elección:** la función toma el `sub` del `id_token` que Apple devuelve en la respuesta de
  `/auth/token` —recibida por TLS directamente de Apple— y exige `aud == APPLE_CLIENT_ID` y
  `sub == identity_data.sub` de la identidad `apple` del usuario. Si no coincide, responde
  `apple_identity_mismatch` **sin revocar**.
- **Alternativas descartadas y por qué:**
  - _Que el cliente envíe `identityToken` y nonce, y verificarlo contra las JWKS de Apple:_ repite
    lo que el canje ya prueba, añade una descarga de JWKS por petición y obliga a transportar el
    nonce.

### 4.4 Sesión validada por GoTrue, no por la pasarela ni localmente

- **Problema:** `verify_jwt = true` en la pasarela solo entiende las claves heredadas; validar el
  JWT localmente con `SUPABASE_JWKS` no detecta una sesión cerrada ni un usuario ya eliminado.
- **Elección:** `verify_jwt = false` en `supabase/config.toml` y `GET /auth/v1/user` con
  `Authorization: Bearer <jwt>` y `apikey: <clave secreta>`. Solo `200` con `id` no vacío es sesión
  válida. Un fallo de red en esa llamada es `unexpected_failure`, no `unauthorized`, para no afirmar
  que la sesión es inválida cuando no se pudo comprobar.
- **Alternativas descartadas y por qué:**
  - _Verificación local con JWKS:_ acepta tokens de usuarios eliminados hasta que expiran.

### 4.5 Borrado definitivo del usuario y cascada, sin RPC SQL

- **Problema:** la directriz exige eliminar la cuenta, no solo sus datos; una RPC `SECURITY DEFINER`
  invocable por `PUBLIC` es una segunda vía de borrado sin revocación.
- **Elección:** `DELETE /auth/v1/admin/users/{id}` con `should_soft_delete: false`. Las claves
  foráneas `user_id → auth.users ON DELETE CASCADE` de las cuatro tablas borran los datos en la
  misma transacción de GoTrue. Solo `2xx` cuenta como borrado; `404` es fallo, porque también lo
  produce una URL mal configurada. `public.delete_account()` se elimina con la migración diferida de
  §1.5.
- **Alternativas descartadas y por qué:**
  - _Borrar tabla por tabla antes de `deleteUser`:_ redundante con la cascada y deja datos borrados
    con la cuenta viva si `deleteUser` falla.
  - _Conservar `delete_account()` quitando `EXECUTE` a `PUBLIC`:_ código muerto que un `GRANT`
    futuro reactiva.

### 4.6 `client_secret` de Apple firmado en cada petición con WebCrypto

- **Problema:** Apple exige un JWT ES256 como `client_secret` con `exp` máximo de seis meses; uno
  pregenerado caduca y hay que rotarlo.
- **Elección:** `createAppleClientSecret` firma con `crypto.subtle` (ECDSA P-256, SHA-256) un JWT
  con `iss = APPLE_TEAM_ID`, `sub = APPLE_CLIENT_ID`, `aud = https://appleid.apple.com`,
  `kid = APPLE_KEY_ID` y vida de 300 s. La firma de WebCrypto es `r‖s` de 64 bytes, el formato JWS,
  sin conversión DER.
- **Alternativas descartadas y por qué:**
  - _Secreto pregenerado en un secreto de la función:_ caduca a los seis meses y rompe el borrado
    sin aviso.
  - _Librería `jose`:_ import remoto sin necesidad (§1.3).

### 4.7 Migraciones diferidas en carpeta propia

- **Problema:** `public.delete_account()` debe desaparecer, pero el build rechazado de la 1.0.0 la
  invoca y `supabase db push` aplica todo lo que hay en `supabase/migrations/`.
- **Elección:** la migración lista vive en `supabase/deferred/` con su nombre definitivo hasta que
  se cumple su condición (§1.5); entonces se mueve a `supabase/migrations/`. La restricción de
  `EXECUTE` en `push_documents` y `push_progress` (revocado a `public` y `anon`, concedido a
  `authenticated`) no rompe a ningún cliente publicado y va directamente en `migrations/`.
- **Alternativas descartadas y por qué:**
  - _Escribir la migración cuando llegue el momento:_ la decisión quedaría solo en la memoria de
    quien la tomó (`DOC-NO-ORPHAN-DECISION`).

### 4.8 Verificador de arquitectura con lexer propio

- **Problema:** `deno lint` no tiene regla contra comentarios ni matriz de capas, y un análisis por
  expresiones regulares sobre el texto confunde `//` dentro de URLs, cadenas y expresiones
  regulares.
- **Elección:** `tool/source_lexer.ts` tokeniza comentarios, cadenas, plantillas con expresiones
  anidadas y literales de expresión regular; `tool/architecture_rules.ts` aplica sobre los tokens
  las reglas de `architecture.json`: comentarios, líneas por archivo, dirección de imports, prefijos
  remotos, identificadores prohibidos por capa (excepto como nombre de propiedad) y capas
  declaradas.
- **Alternativas descartadas y por qué:**
  - _Compilador de TypeScript por `npm:typescript`:_ dependencia de varios megabytes y red para una
    tarea que el lexer resuelve.

---

## 5. Reglas de legibilidad, estilo y estructura de código

### 5.1 Filosofía de código auto-explicativo

Un archivo, una responsabilidad. Los fallos esperables son valores (`DeletionOutcome`,
`AppleCodeExchange`, `null`), nunca excepciones que crucen un puerto; el manejador HTTP es la única
frontera que captura excepciones no previstas.

### 5.2 Límites métricos obligatorios

Los valores viven en `architecture.json` (`limits`, `limits_exempt`). `test/` y `tool/` están
exentos del límite de líneas, no de la prohibición de comentarios. El tamaño de función se revisa en
revisión de código (§1.5).

### 5.3 Política estricta de comentarios (`QUALITY-NO-COMMENTS`)

Cero comentarios en `supabase/functions/`, `test/` y `tool/`, verificado por
`deno task architecture`. Las migraciones SQL tampoco llevan comentarios; esto se revisa en revisión
de código.

### 5.4 Convenciones técnicas y anti-patrones prohibidos

- `deno fmt` con `lineWidth: 100` y reglas `recommended` de `deno lint`.
- Toda llamada remota recibe un `Fetcher` inyectado; el `fetch` global solo aparece en `index.ts`.
- Los códigos de error son un tipo cerrado (`DeletionFailureCode`) y su estado HTTP vive en una sola
  tabla (`statusByFailureCode`); la app mapea los mismos códigos.

### 5.5 Gestión tipada de errores

| Código                            | HTTP | Cuenta tras la respuesta                               |
| :-------------------------------- | :--- | :----------------------------------------------------- |
| `method_not_allowed`              | 405  | Intacta                                                |
| `invalid_body`                    | 400  | Intacta                                                |
| `unauthorized`                    | 401  | Intacta                                                |
| `apple_reauthentication_required` | 409  | Intacta                                                |
| `apple_identity_mismatch`         | 403  | Intacta                                                |
| `apple_token_exchange_failed`     | 502  | Intacta                                                |
| `apple_revoke_failed`             | 502  | Intacta                                                |
| `delete_failed`                   | 500  | Intacta; Apple puede estar revocado                    |
| `misconfigured`                   | 500  | Intacta                                                |
| `unexpected_failure`              | 500  | Intacta o, si ocurrió tras revocar, con Apple revocado |

---

## 6. Decisiones de producto que condicionan el código

### 6.1 La cuenta solo se da por eliminada cuando el servidor lo confirma

La app borra los datos locales únicamente ante `200`. Cualquier otra respuesta deja la sesión y los
datos del dispositivo intactos y ofrece reintentar. Por eso la función nunca responde `200` ante un
borrado dudoso (`404` es fallo, §4.5).

### 6.2 Eliminar es inmediato e irreversible

No hay periodo de gracia ni borrado lógico. El diálogo de confirmación de la app lo declara, y
anticipa que las cuentas de Apple piden confirmar la identidad.

---

## 7. Verificación, testing y aseguramiento de calidad

### 7.1 Matriz de verificadores mecánicos

| Verificador  | Comando                  | Qué valida                                                                                                         | Regla en            |
| :----------- | :----------------------- | :----------------------------------------------------------------------------------------------------------------- | :------------------ |
| Formato      | `deno task fmt`          | Estilo `deno fmt`                                                                                                  | `deno.json`         |
| Lint         | `deno task lint`         | Reglas `recommended`                                                                                               | `deno.json`         |
| Tipos        | `deno task check`        | Tipado estricto de la función, el verificador y los tests                                                          | `deno.json`         |
| Arquitectura | `deno task architecture` | Comentarios, líneas por archivo, dirección de imports, imports remotos, identificadores por capa, capas declaradas | `architecture.json` |
| Tests        | `deno task test`         | Contratos de cada capa y del verificador                                                                           | `test/`             |

Casos negativos del verificador: `test/tool/architecture_rules_test.ts` (comentario, import hacia
fuera, import remoto, identificador prohibido, archivo largo, capa no declarada) y
`test/tool/source_lexer_test.ts` (`//` dentro de cadenas, plantillas y expresiones regulares).

### 7.2 Estrategia y pirámide de pruebas

- **Espejo (`TEST-MIRROR`):** `test/functions/delete-account/<capa>/` refleja
  `supabase/functions/delete-account/<capa>/`; `test/tool/` refleja `tool/`.
- **Doble camino (`TEST-BOTH-PATHS`):** el caso de uso se prueba con el orden exacto de llamadas en
  éxito y con la ausencia de `delete` en cada fallo previo; los adaptadores, con respuestas `2xx`,
  `4xx`, `5xx`, JSON inválido y red caída; el parser, con cada método, cabecera y cuerpo inválido.
- **Casos límite:** cuerpo vacío, código con espacios, `null` explícito, `id_token` sin `sub` o con
  otra audiencia, Apple sin `refresh_token`, PEM con `\n` escapados, clave malformada, identificador
  de usuario con `/`, archivo exactamente en el límite.

### 7.3 Señales de alerta al revisar (Code Review Checklist)

- [ ] Un `200` posible sin `deleteUser` confirmado.
- [ ] Una revocación de Apple sin comprobar antes el `sub`.
- [ ] Un log que incluya token, código, correo o identificador de usuario.
- [ ] Un import `npm:`, `jsr:` o `https:` dentro de `supabase/functions/`.
- [ ] Un secreto, `.env` o `.p8` añadido al repositorio.
- [ ] Una migración en `supabase/migrations/` que rompa a una versión publicada de la app.

---

## 8. Fuentes consultadas y genealogía conceptual

| Fuente                                                                       | Qué se tomó                                                                                     | Qué se rechazó y por qué                                                                                     |
| :--------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------- |
| App Store Review Guidelines 5.1.1(v)                                         | Eliminación de cuenta dentro de la app y revocación de Sign in with Apple                       | —                                                                                                            |
| Sign in with Apple REST API (`/auth/token`, `/auth/revoke`, `client_secret`) | Parámetros de canje y revocación, JWT ES256 con `kid`, `iss`, `sub`, `aud`, `exp` ≤ 6 meses     | Verificación del `identityToken` del cliente con JWKS: el `id_token` del canje ya prueba la identidad (§4.3) |
| Supabase Auth Admin API y guía de gestión de usuarios                        | `DELETE /auth/v1/admin/users/{id}`, cascada por clave foránea, bloqueo por objetos de Storage   | `supabase-js` en la función (§1.3)                                                                           |
| Supabase: claves publicables y secretas en Edge Functions                    | `SUPABASE_SECRET_KEYS`, clave solo en `apikey`, `verify_jwt = false` con autorización en código | Claves heredadas `service_role` (§1.3)                                                                       |
