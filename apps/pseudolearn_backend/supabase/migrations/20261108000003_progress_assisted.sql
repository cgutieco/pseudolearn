alter table progress add column if not exists assisted boolean not null default false;

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
      first_visited_at, first_completed_at, assisted, server_revision
    ) values (
      v_user_id,
      entry->>'content_id',
      coalesce((entry->>'visited')::boolean, false),
      coalesce((entry->>'completed')::boolean, false),
      (entry->>'first_visited_at')::timestamptz,
      (entry->>'first_completed_at')::timestamptz,
      coalesce((entry->>'assisted')::boolean, false),
      v_next_rev
    )
    on conflict (user_id, content_id) do update set
      visited = progress.visited or excluded.visited,
      completed = progress.completed or excluded.completed,
      assisted = progress.assisted or excluded.assisted,
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

revoke execute on function public.push_progress(jsonb) from public, anon;
grant execute on function public.push_progress(jsonb) to authenticated;
