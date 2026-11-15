alter table agent_ledger_periods
  add column if not exists store text not null default 'simulated',
  add column if not exists original_transaction_id text,
  add column if not exists revoked_at timestamptz;

alter table agent_ledger_top_ups
  add column if not exists store text not null default 'simulated',
  add column if not exists revoked_at timestamptz;

create table if not exists agent_store_links (
  store                   text not null,
  original_transaction_id text not null,
  user_id                 uuid not null references auth.users on delete cascade,
  customer_id             text,
  linked_at               timestamptz not null,
  primary key (store, original_transaction_id)
);

create index if not exists agent_store_links_user_idx on agent_store_links (user_id, store);

alter table agent_store_links enable row level security;

create or replace function agent_balance(p_user uuid, p_now timestamptz)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_period agent_ledger_periods%rowtype;
  v_top_up bigint;
  v_trial_used boolean;
begin
  select * into v_period from agent_ledger_periods
  where user_id = p_user and starts_at <= p_now and ends_at > p_now and revoked_at is null
  order by ends_at desc limit 1;

  select coalesce(sum(granted_milli - spent_milli), 0) into v_top_up
  from agent_ledger_top_ups where user_id = p_user and revoked_at is null;

  select exists(select 1 from agent_ledger_periods where user_id = p_user and kind = 'trial')
  into v_trial_used;

  return jsonb_build_object(
    'period_active', v_period.transaction_id is not null,
    'trial', coalesce(v_period.kind = 'trial', false),
    'trial_used', v_trial_used,
    'allowance_milli', coalesce(v_period.allowance_milli, 0),
    'period_remaining_milli', greatest(coalesce(v_period.allowance_milli - v_period.spent_milli, 0), 0),
    'top_up_milli', greatest(v_top_up, 0),
    'renews_at', v_period.ends_at,
    'store', v_period.store
  );
end;
$$;

create or replace function agent_debit(
  p_user uuid, p_request_id text, p_turn_id text, p_milli bigint, p_now timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_left bigint := greatest(p_milli, 0);
  v_take bigint;
  v_period agent_ledger_periods%rowtype;
  v_top_up agent_ledger_top_ups%rowtype;
begin
  insert into agent_ledger_events (user_id, request_id, turn_id, kind, milli, created_at)
  values (p_user, p_request_id, p_turn_id, 'debit', v_left, p_now)
  on conflict do nothing;
  if not found then
    return agent_balance(p_user, p_now);
  end if;

  select * into v_period from agent_ledger_periods
  where user_id = p_user and starts_at <= p_now and ends_at > p_now and revoked_at is null
  order by ends_at desc limit 1 for update;
  if v_period.transaction_id is not null then
    v_take := least(v_left, greatest(v_period.allowance_milli - v_period.spent_milli, 0));
    update agent_ledger_periods set spent_milli = spent_milli + v_take
    where user_id = p_user and transaction_id = v_period.transaction_id;
    v_left := v_left - v_take;
  end if;

  for v_top_up in select * from agent_ledger_top_ups
    where user_id = p_user and granted_milli > spent_milli and revoked_at is null
    order by granted_at for update
  loop
    exit when v_left <= 0;
    v_take := least(v_left, v_top_up.granted_milli - v_top_up.spent_milli);
    update agent_ledger_top_ups set spent_milli = spent_milli + v_take
    where user_id = p_user and transaction_id = v_top_up.transaction_id;
    v_left := v_left - v_take;
  end loop;

  return agent_balance(p_user, p_now);
end;
$$;

create or replace function agent_link_store_purchase(
  p_user uuid, p_store text, p_original_id text, p_customer text, p_now timestamptz
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner uuid;
begin
  if p_original_id is null then
    return true;
  end if;
  insert into agent_store_links (store, original_transaction_id, user_id, customer_id, linked_at)
  values (p_store, p_original_id, p_user, p_customer, p_now)
  on conflict (store, original_transaction_id) do nothing;
  select user_id into v_owner from agent_store_links
  where store = p_store and original_transaction_id = p_original_id;
  if v_owner <> p_user then
    return false;
  end if;
  if p_customer is not null then
    update agent_store_links set customer_id = p_customer
    where store = p_store and original_transaction_id = p_original_id;
  end if;
  return true;
end;
$$;

create or replace function agent_apply_purchase(
  p_user uuid, p_store text, p_product text, p_transaction_id text, p_original_id text,
  p_milli bigint, p_starts timestamptz, p_ends timestamptz, p_trial boolean, p_customer text,
  p_now timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not agent_link_store_purchase(p_user, p_store, p_original_id, p_customer, p_now) then
    return jsonb_build_object('error', 'purchase_owned_elsewhere', 'balance', agent_balance(p_user, p_now));
  end if;

  if p_product = 'top_up' then
    if exists(select 1 from agent_ledger_top_ups where user_id = p_user and transaction_id = p_transaction_id) then
      return jsonb_build_object('balance', agent_balance(p_user, p_now), 'repeated', true);
    end if;
    if not exists(
      select 1 from agent_ledger_periods
      where user_id = p_user and starts_at <= p_now and ends_at > p_now and revoked_at is null
    ) then
      return jsonb_build_object('error', 'subscription_required', 'balance', agent_balance(p_user, p_now));
    end if;
    insert into agent_ledger_top_ups (user_id, transaction_id, granted_milli, granted_at, store)
    values (p_user, p_transaction_id, p_milli, p_now, p_store);
    return jsonb_build_object('balance', agent_balance(p_user, p_now), 'repeated', false);
  end if;

  if p_product not in ('trial', 'monthly') then
    return jsonb_build_object('error', 'invalid_product', 'balance', agent_balance(p_user, p_now));
  end if;

  if exists(select 1 from agent_ledger_periods where user_id = p_user and transaction_id = p_transaction_id) then
    update agent_ledger_periods set ends_at = p_ends
    where user_id = p_user and transaction_id = p_transaction_id and revoked_at is null;
    return jsonb_build_object('balance', agent_balance(p_user, p_now), 'repeated', true);
  end if;

  if p_product = 'trial' and exists(
    select 1 from agent_ledger_periods where user_id = p_user and kind = 'trial'
  ) then
    return jsonb_build_object('error', 'trial_used', 'balance', agent_balance(p_user, p_now));
  end if;

  update agent_ledger_periods set ends_at = p_starts
  where user_id = p_user and revoked_at is null and starts_at <= p_starts and ends_at > p_starts;

  insert into agent_ledger_periods (
    user_id, transaction_id, kind, allowance_milli, starts_at, ends_at, store, original_transaction_id
  )
  values (
    p_user, p_transaction_id,
    case when p_product = 'trial' or p_trial then 'trial' else 'monthly' end,
    p_milli, p_starts, p_ends, p_store, p_original_id
  );
  return jsonb_build_object('balance', agent_balance(p_user, p_now), 'repeated', false);
end;
$$;

create or replace function agent_revoke_purchase(
  p_store text, p_transaction_id text, p_original_id text, p_now timestamptz
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_periods integer;
  v_top_ups integer;
begin
  update agent_ledger_periods set revoked_at = p_now
  where store = p_store and revoked_at is null and (
    transaction_id = p_transaction_id
    or (p_original_id is not null and original_transaction_id = p_original_id and ends_at > p_now)
  );
  get diagnostics v_periods = row_count;
  update agent_ledger_top_ups set revoked_at = p_now
  where store = p_store and revoked_at is null and transaction_id = p_transaction_id;
  get diagnostics v_top_ups = row_count;
  return v_periods + v_top_ups;
end;
$$;

create or replace function agent_end_subscription(
  p_store text, p_original_id text, p_ends timestamptz
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  update agent_ledger_periods set ends_at = greatest(starts_at, p_ends)
  where store = p_store and original_transaction_id = p_original_id
    and revoked_at is null and ends_at > p_ends;
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

create or replace function agent_store_owner(p_store text, p_original_id text)
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select user_id from agent_store_links
  where store = p_store and original_transaction_id = p_original_id;
$$;

create or replace function agent_store_customer(p_user uuid, p_store text)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select customer_id from agent_store_links
  where user_id = p_user and store = p_store and customer_id is not null
  order by linked_at desc limit 1;
$$;

drop function if exists public.agent_grant_purchase(uuid, text, text, bigint, integer, timestamptz);

revoke execute on function public.agent_balance(uuid, timestamptz) from public, anon, authenticated;
revoke execute on function public.agent_debit(uuid, text, text, bigint, timestamptz)
  from public, anon, authenticated;
revoke execute on function public.agent_link_store_purchase(uuid, text, text, text, timestamptz)
  from public, anon, authenticated;
revoke execute on function public.agent_apply_purchase(
  uuid, text, text, text, text, bigint, timestamptz, timestamptz, boolean, text, timestamptz
) from public, anon, authenticated;
revoke execute on function public.agent_revoke_purchase(text, text, text, timestamptz)
  from public, anon, authenticated;
revoke execute on function public.agent_end_subscription(text, text, timestamptz)
  from public, anon, authenticated;
revoke execute on function public.agent_store_owner(text, text) from public, anon, authenticated;
revoke execute on function public.agent_store_customer(uuid, text) from public, anon, authenticated;

grant execute on function public.agent_balance(uuid, timestamptz) to service_role;
grant execute on function public.agent_debit(uuid, text, text, bigint, timestamptz) to service_role;
grant execute on function public.agent_apply_purchase(
  uuid, text, text, text, text, bigint, timestamptz, timestamptz, boolean, text, timestamptz
) to service_role;
grant execute on function public.agent_revoke_purchase(text, text, text, timestamptz) to service_role;
grant execute on function public.agent_end_subscription(text, text, timestamptz) to service_role;
grant execute on function public.agent_store_owner(text, text) to service_role;
grant execute on function public.agent_store_customer(uuid, text) to service_role;
