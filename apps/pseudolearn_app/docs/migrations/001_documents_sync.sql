-- Sincronización de documentos
-- Tablas, políticas RLS y RPC atómica de asignación de revisión.

-- 1. Tablas
create table if not exists account_revision (
  user_id       uuid primary key references auth.users on delete cascade,
  last_revision bigint not null default 0
);

create table if not exists documents (
  id              uuid primary key,
  user_id         uuid not null references auth.users on delete cascade,
  title           text not null,
  content         text not null,
  profile_id      text not null,
  exercise_id     text,
  created_at      timestamptz not null,
  updated_at      timestamptz not null,
  server_revision bigint not null,
  deleted_at      timestamptz,
  origin_device   text not null,
  institution_id  uuid,
  class_id        uuid,
  membership_id   uuid,
  submission_id   uuid
);

create index if not exists documents_user_server_revision_idx on documents (user_id, server_revision);

create table if not exists devices (
  device_id    text not null,
  user_id      uuid not null references auth.users on delete cascade,
  label        text,
  last_seen_at timestamptz not null,
  primary key (user_id, device_id)
);

-- 2. Row Level Security (RLS)
alter table account_revision enable row level security;
alter table documents enable row level security;
alter table devices enable row level security;

create policy own_account_revision on account_revision
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy own_documents on documents
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy own_devices on devices
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- 3. Función RPC atómica para push de documentos (D1)
create or replace function push_documents(payload jsonb)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_next_rev bigint;
  doc jsonb;
begin
  if v_user_id is null then
    raise exception 'Unauthorized';
  end if;

  -- Bloquea la fila de revisión del usuario o la crea
  insert into account_revision (user_id, last_revision)
  values (v_user_id, 0)
  on conflict (user_id) do nothing;

  select last_revision + 1 into v_next_rev
  from account_revision
  where user_id = v_user_id
  for update;

  update account_revision
  set last_revision = v_next_rev
  where user_id = v_user_id;

  for doc in select * from jsonb_array_elements(payload)
  loop
    insert into documents (
      id, user_id, title, content, profile_id, exercise_id,
      created_at, updated_at, server_revision, deleted_at, origin_device
    ) values (
      (doc->>'id')::uuid,
      v_user_id,
      doc->>'title',
      doc->>'content',
      doc->>'profile_id',
      doc->>'exercise_id',
      (doc->>'created_at')::timestamptz,
      (doc->>'updated_at')::timestamptz,
      v_next_rev,
      (doc->>'deleted_at')::timestamptz,
      coalesce(doc->>'origin_device', 'unknown')
    )
    on conflict (id) do update set
      title = excluded.title,
      content = excluded.content,
      profile_id = excluded.profile_id,
      exercise_id = excluded.exercise_id,
      updated_at = excluded.updated_at,
      server_revision = v_next_rev,
      deleted_at = excluded.deleted_at,
      origin_device = excluded.origin_device
    where documents.user_id = v_user_id;
  end loop;

  return v_next_rev;
end;
$$;

-- 4. Función RPC para purga completa de cuenta
create or replace function delete_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Unauthorized';
  end if;

  delete from documents where user_id = v_user_id;
  delete from account_revision where user_id = v_user_id;
  delete from devices where user_id = v_user_id;
end;
$$;
