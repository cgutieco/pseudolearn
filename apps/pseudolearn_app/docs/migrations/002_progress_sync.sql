-- Sincronización de progreso y preferencias
-- Tabla de progreso, política RLS, función RPC atómica de unión monotónica y actualización de purge.

-- 1. Tabla de progreso
create table if not exists progress (
  user_id            uuid not null references auth.users on delete cascade,
  content_id         text not null,
  visited            boolean not null default false,
  completed          boolean not null default false,
  first_visited_at   timestamptz,
  first_completed_at timestamptz,
  server_revision    bigint not null,
  primary key (user_id, content_id)
);

create index if not exists progress_user_server_revision_idx on progress (user_id, server_revision);

-- 2. Row Level Security (RLS)
alter table progress enable row level security;

create policy own_progress on progress
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- 3. Función RPC atómica para push de progreso con unión monotónica (D4)
create or replace function push_progress(payload jsonb)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_next_rev bigint;
  entry jsonb;
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

  for entry in select * from jsonb_array_elements(payload)
  loop
    insert into progress (
      user_id, content_id, visited, completed,
      first_visited_at, first_completed_at, server_revision
    ) values (
      v_user_id,
      entry->>'content_id',
      coalesce((entry->>'visited')::boolean, false),
      coalesce((entry->>'completed')::boolean, false),
      (entry->>'first_visited_at')::timestamptz,
      (entry->>'first_completed_at')::timestamptz,
      v_next_rev
    )
    on conflict (user_id, content_id) do update set
      visited = progress.visited or excluded.visited,
      completed = progress.completed or excluded.completed,
      first_visited_at = case
        when progress.first_visited_at is null then excluded.first_visited_at
        when excluded.first_visited_at is null then progress.first_visited_at
        else least(progress.first_visited_at, excluded.first_visited_at)
      end,
      first_completed_at = case
        when progress.first_completed_at is null then excluded.first_completed_at
        when excluded.first_completed_at is null then progress.first_completed_at
        else least(progress.first_completed_at, excluded.first_completed_at)
      end,
      server_revision = v_next_rev
    where progress.user_id = v_user_id;
  end loop;

  return v_next_rev;
end;
$$;

-- 4. Actualización de función RPC para purga completa de cuenta (incluyendo progreso)
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
  delete from progress where user_id = v_user_id;
  delete from account_revision where user_id = v_user_id;
  delete from devices where user_id = v_user_id;
end;
$$;
