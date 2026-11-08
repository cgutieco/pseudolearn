create table if not exists agent_ledger_periods (
  user_id         uuid not null references auth.users on delete cascade,
  transaction_id  text not null,
  kind            text not null check (kind in ('trial', 'monthly')),
  allowance_milli bigint not null check (allowance_milli >= 0),
  spent_milli     bigint not null default 0 check (spent_milli >= 0),
  starts_at       timestamptz not null,
  ends_at         timestamptz not null,
  primary key (user_id, transaction_id)
);

create table if not exists agent_ledger_top_ups (
  user_id        uuid not null references auth.users on delete cascade,
  transaction_id text not null,
  granted_milli  bigint not null check (granted_milli >= 0),
  spent_milli    bigint not null default 0 check (spent_milli >= 0),
  granted_at     timestamptz not null,
  primary key (user_id, transaction_id)
);

create table if not exists agent_ledger_events (
  user_id    uuid not null references auth.users on delete cascade,
  request_id text not null,
  turn_id    text not null,
  kind       text not null check (kind in ('authorize', 'debit')),
  milli      bigint not null default 0,
  created_at timestamptz not null,
  primary key (user_id, request_id, kind)
);

create index if not exists agent_ledger_events_recent_idx
  on agent_ledger_events (user_id, kind, created_at);

alter table agent_ledger_periods enable row level security;
alter table agent_ledger_top_ups enable row level security;
alter table agent_ledger_events enable row level security;

create policy read_own_agent_periods on agent_ledger_periods for select using (user_id = auth.uid());
create policy read_own_agent_top_ups on agent_ledger_top_ups for select using (user_id = auth.uid());
create policy read_own_agent_events on agent_ledger_events for select using (user_id = auth.uid());

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
  where user_id = p_user and starts_at <= p_now and ends_at > p_now
  order by ends_at desc limit 1;

  select coalesce(sum(granted_milli - spent_milli), 0) into v_top_up
  from agent_ledger_top_ups where user_id = p_user;

  select exists(select 1 from agent_ledger_periods where user_id = p_user and kind = 'trial')
  into v_trial_used;

  return jsonb_build_object(
    'period_active', v_period.transaction_id is not null,
    'trial', coalesce(v_period.kind = 'trial', false),
    'trial_used', v_trial_used,
    'allowance_milli', coalesce(v_period.allowance_milli, 0),
    'period_remaining_milli', greatest(coalesce(v_period.allowance_milli - v_period.spent_milli, 0), 0),
    'top_up_milli', greatest(v_top_up, 0),
    'renews_at', v_period.ends_at
  );
end;
$$;

create or replace function agent_authorize(
  p_user uuid, p_request_id text, p_turn_id text, p_now timestamptz,
  p_cap_milli bigint, p_calls_per_minute integer
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance jsonb := agent_balance(p_user, p_now);
  v_remaining bigint;
  v_turn_spent bigint;
  v_recent integer;
begin
  v_remaining := (v_balance->>'period_remaining_milli')::bigint + (v_balance->>'top_up_milli')::bigint;
  if not (v_balance->>'period_active')::boolean and (v_balance->>'top_up_milli')::bigint = 0 then
    return jsonb_build_object('error', 'subscription_required', 'balance', v_balance);
  end if;
  if v_remaining <= 0 then
    return jsonb_build_object('error', 'credits_exhausted', 'balance', v_balance);
  end if;

  select coalesce(sum(milli), 0) into v_turn_spent from agent_ledger_events
  where user_id = p_user and turn_id = p_turn_id and kind = 'debit';
  if v_turn_spent >= p_cap_milli then
    return jsonb_build_object('error', 'request_cap', 'balance', v_balance);
  end if;

  select count(*) into v_recent from agent_ledger_events
  where user_id = p_user and kind = 'authorize' and created_at > p_now - interval '1 minute';
  if v_recent >= p_calls_per_minute then
    return jsonb_build_object('error', 'rate_limited', 'balance', v_balance);
  end if;

  insert into agent_ledger_events (user_id, request_id, turn_id, kind, created_at)
  values (p_user, p_request_id, p_turn_id, 'authorize', p_now)
  on conflict do nothing;
  return jsonb_build_object('balance', v_balance);
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
  where user_id = p_user and starts_at <= p_now and ends_at > p_now
  order by ends_at desc limit 1 for update;
  if v_period.transaction_id is not null then
    v_take := least(v_left, greatest(v_period.allowance_milli - v_period.spent_milli, 0));
    update agent_ledger_periods set spent_milli = spent_milli + v_take
    where user_id = p_user and transaction_id = v_period.transaction_id;
    v_left := v_left - v_take;
  end if;

  for v_top_up in select * from agent_ledger_top_ups
    where user_id = p_user and granted_milli > spent_milli
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

create or replace function agent_grant_purchase(
  p_user uuid, p_transaction_id text, p_product text, p_milli bigint, p_days integer, p_now timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if exists(select 1 from agent_ledger_periods where user_id = p_user and transaction_id = p_transaction_id)
    or exists(select 1 from agent_ledger_top_ups where user_id = p_user and transaction_id = p_transaction_id) then
    return jsonb_build_object('balance', agent_balance(p_user, p_now), 'repeated', true);
  end if;

  if p_product = 'trial' then
    if exists(select 1 from agent_ledger_periods where user_id = p_user and kind = 'trial') then
      return jsonb_build_object('error', 'trial_used', 'balance', agent_balance(p_user, p_now));
    end if;
    insert into agent_ledger_periods (user_id, transaction_id, kind, allowance_milli, starts_at, ends_at)
    values (p_user, p_transaction_id, 'trial', p_milli, p_now, p_now + make_interval(days => p_days));
  elsif p_product = 'monthly' then
    update agent_ledger_periods set ends_at = p_now
    where user_id = p_user and starts_at <= p_now and ends_at > p_now;
    insert into agent_ledger_periods (user_id, transaction_id, kind, allowance_milli, starts_at, ends_at)
    values (p_user, p_transaction_id, 'monthly', p_milli, p_now, p_now + make_interval(days => p_days));
  elsif p_product = 'top_up' then
    insert into agent_ledger_top_ups (user_id, transaction_id, granted_milli, granted_at)
    values (p_user, p_transaction_id, p_milli, p_now);
  else
    return jsonb_build_object('error', 'invalid_product', 'balance', agent_balance(p_user, p_now));
  end if;

  return jsonb_build_object('balance', agent_balance(p_user, p_now), 'repeated', false);
end;
$$;

revoke execute on function public.agent_balance(uuid, timestamptz) from public, anon, authenticated;
revoke execute on function public.agent_authorize(uuid, text, text, timestamptz, bigint, integer)
  from public, anon, authenticated;
revoke execute on function public.agent_debit(uuid, text, text, bigint, timestamptz)
  from public, anon, authenticated;
revoke execute on function public.agent_grant_purchase(uuid, text, text, bigint, integer, timestamptz)
  from public, anon, authenticated;
grant execute on function public.agent_balance(uuid, timestamptz) to service_role;
grant execute on function public.agent_authorize(uuid, text, text, timestamptz, bigint, integer) to service_role;
grant execute on function public.agent_debit(uuid, text, text, bigint, timestamptz) to service_role;
grant execute on function public.agent_grant_purchase(uuid, text, text, bigint, integer, timestamptz) to service_role;
