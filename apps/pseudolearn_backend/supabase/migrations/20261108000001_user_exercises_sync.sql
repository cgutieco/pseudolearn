create table if not exists user_exercises (
  id              text not null,
  user_id         uuid not null references auth.users on delete cascade,
  payload         jsonb,
  revision        integer not null default 1,
  created_at      timestamptz not null,
  updated_at      timestamptz not null,
  deleted_at      timestamptz,
  server_revision bigint not null,
  primary key (user_id, id),
  constraint user_exercises_payload_present check (deleted_at is not null or payload is not null)
);

create index if not exists user_exercises_user_server_revision_idx
  on user_exercises (user_id, server_revision);

alter table user_exercises enable row level security;

create policy own_user_exercises on user_exercises
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function push_user_exercises(payload jsonb)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_next_rev bigint;
  item jsonb;
begin
  if v_user_id is null then
    raise exception 'Unauthorized';
  end if;

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

  for item in select * from jsonb_array_elements(payload)
  loop
    insert into user_exercises (
      id, user_id, payload, revision, created_at, updated_at, deleted_at, server_revision
    ) values (
      item->>'id',
      v_user_id,
      case when item->>'payload' is null then null else (item->>'payload')::jsonb end,
      coalesce((item->>'revision')::integer, 1),
      (item->>'created_at')::timestamptz,
      (item->>'updated_at')::timestamptz,
      (item->>'deleted_at')::timestamptz,
      v_next_rev
    )
    on conflict (user_id, id) do update set
      payload = coalesce(excluded.payload, user_exercises.payload),
      revision = excluded.revision,
      updated_at = excluded.updated_at,
      deleted_at = excluded.deleted_at,
      server_revision = v_next_rev
    where user_exercises.updated_at <= excluded.updated_at;
  end loop;

  return v_next_rev;
end;
$$;

revoke execute on function public.push_user_exercises(jsonb) from public, anon;
grant execute on function public.push_user_exercises(jsonb) to authenticated;
