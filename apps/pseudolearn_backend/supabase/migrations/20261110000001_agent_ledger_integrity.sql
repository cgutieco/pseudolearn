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
  v_balance jsonb;
  v_remaining bigint;
  v_turn_spent bigint;
  v_recent integer;
  v_in_flight integer;
begin
  perform pg_advisory_xact_lock(hashtext('agent_ledger:' || p_user::text));
  v_balance := agent_balance(p_user, p_now);
  v_remaining := (v_balance->>'period_remaining_milli')::bigint + (v_balance->>'top_up_milli')::bigint;
  if not (v_balance->>'period_active')::boolean and (v_balance->>'top_up_milli')::bigint = 0 then
    return jsonb_build_object('error', 'subscription_required', 'balance', v_balance);
  end if;
  if exists(select 1 from agent_ledger_events where user_id = p_user and request_id = p_request_id) then
    return jsonb_build_object('error', 'invalid_request', 'balance', v_balance);
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

  select count(*) into v_in_flight from agent_ledger_events a
  where a.user_id = p_user and a.kind = 'authorize' and a.created_at > p_now - interval '150 seconds'
    and not exists(
      select 1 from agent_ledger_events d
      where d.user_id = p_user and d.request_id = a.request_id and d.kind = 'debit'
    );
  if v_in_flight > 0 and v_remaining <= v_in_flight * p_cap_milli then
    return jsonb_build_object('error', 'rate_limited', 'balance', v_balance);
  end if;

  insert into agent_ledger_events (user_id, request_id, turn_id, kind, created_at)
  values (p_user, p_request_id, p_turn_id, 'authorize', p_now);
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
  perform pg_advisory_xact_lock(hashtext('agent_ledger:' || p_user::text));
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
  perform pg_advisory_xact_lock(hashtext('agent_purchase:' || p_store || ':' || p_transaction_id));
  perform pg_advisory_xact_lock(hashtext('agent_ledger:' || p_user::text));
  if not agent_link_store_purchase(p_user, p_store, p_original_id, p_customer, p_now) then
    return jsonb_build_object('error', 'purchase_owned_elsewhere', 'balance', agent_balance(p_user, p_now));
  end if;

  if p_product = 'top_up' then
    if exists(
      select 1 from agent_ledger_top_ups
      where store = p_store and transaction_id = p_transaction_id and user_id <> p_user
    ) then
      return jsonb_build_object('error', 'purchase_owned_elsewhere', 'balance', agent_balance(p_user, p_now));
    end if;
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

  if (p_product = 'trial' or p_trial) and exists(
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
