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
    if not exists(
      select 1 from agent_ledger_periods
      where user_id = p_user and starts_at <= p_now and ends_at > p_now
    ) then
      return jsonb_build_object('error', 'subscription_required', 'balance', agent_balance(p_user, p_now));
    end if;
    insert into agent_ledger_top_ups (user_id, transaction_id, granted_milli, granted_at)
    values (p_user, p_transaction_id, p_milli, p_now);
  else
    return jsonb_build_object('error', 'invalid_product', 'balance', agent_balance(p_user, p_now));
  end if;

  return jsonb_build_object('balance', agent_balance(p_user, p_now), 'repeated', false);
end;
$$;

revoke execute on function public.agent_grant_purchase(uuid, text, text, bigint, integer, timestamptz)
  from public, anon, authenticated;
grant execute on function public.agent_grant_purchase(uuid, text, text, bigint, integer, timestamptz) to service_role;
