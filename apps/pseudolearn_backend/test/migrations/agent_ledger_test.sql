insert into auth.users (id) values
  ('00000000-0000-0000-0000-00000000000a'),
  ('00000000-0000-0000-0000-00000000000b'),
  ('00000000-0000-0000-0000-00000000000c');

create function pg_temp.apply(
  p_user text, p_store text, p_product text, p_tx text, p_original text, p_milli bigint,
  p_starts text, p_ends text, p_trial boolean, p_now text
) returns jsonb language sql as $$
  select agent_apply_purchase(
    p_user::uuid, p_store, p_product, p_tx, p_original, p_milli,
    p_starts::timestamptz, p_ends::timestamptz, p_trial, null, p_now::timestamptz
  )
$$;

do $$
declare
  v_reply jsonb;
  v_user text := '00000000-0000-0000-0000-00000000000a';
begin
  v_reply := pg_temp.apply(v_user, 'simulated', 'top_up', 'simulated:t0', null, 150000,
    '2026-11-01', '2026-11-01', false, '2026-11-01');
  assert v_reply->>'error' = 'subscription_required', 'a top-up without a period is refused';
  assert not exists(select 1 from agent_ledger_top_ups where transaction_id = 'simulated:t0'),
    'a refused top-up records nothing';

  v_reply := pg_temp.apply(v_user, 'simulated', 'monthly', 'simulated:m1', null, 300000,
    '2026-11-01', '2026-12-01', false, '2026-11-01');
  assert (v_reply->'balance'->>'period_active')::boolean, 'the plan opens a period';
  assert v_reply->'balance'->>'store' = 'simulated', 'the balance names the store of the period';

  v_reply := pg_temp.apply(v_user, 'simulated', 'top_up', 'simulated:t1', null, 150000,
    '2026-11-02', '2026-11-02', false, '2026-11-02');
  assert (v_reply->'balance'->>'top_up_milli')::bigint = 150000, 'a top-up with a plan is granted';
  v_reply := pg_temp.apply(v_user, 'simulated', 'top_up', 'simulated:t1', null, 150000,
    '2026-11-02', '2026-11-02', false, '2026-11-02');
  assert (v_reply->>'repeated')::boolean, 'a repeated top-up is idempotent';

  v_reply := agent_balance(v_user::uuid, '2026-12-05');
  assert not (v_reply->>'period_active')::boolean, 'the plan lapses at its end';
  assert (v_reply->>'top_up_milli')::bigint = 150000, 'the top-up outlives the plan';

  v_reply := agent_authorize(v_user::uuid, 'r1', 'turn1', '2026-12-05', 15000, 60);
  assert v_reply->>'error' is null, 'a lapsed plan with a top-up is still authorized';
  v_reply := agent_debit(v_user::uuid, 'r1', 'turn1', 1000, '2026-12-05');
  assert (v_reply->>'top_up_milli')::bigint = 149000, 'the debit takes from the top-up';
end;
$$;

do $$
declare
  v_reply jsonb;
  v_a text := '00000000-0000-0000-0000-00000000000a';
  v_b text := '00000000-0000-0000-0000-00000000000b';
begin
  v_reply := pg_temp.apply(v_b, 'app_store', 'monthly', 'app_store:100', 'o-1', 40000,
    '2026-11-01', '2026-11-08 06:00', true, '2026-11-01');
  assert (v_reply->'balance'->>'trial')::boolean, 'a store trial opens a trial period';
  assert (v_reply->'balance'->>'trial_used')::boolean, 'a store trial marks the trial as used';

  v_reply := pg_temp.apply(v_a, 'app_store', 'monthly', 'app_store:101', 'o-1', 300000,
    '2026-11-08', '2026-12-08 06:00', false, '2026-11-08');
  assert v_reply->>'error' = 'purchase_owned_elsewhere', 'a subscription belongs to one account';

  v_reply := pg_temp.apply(v_b, 'app_store', 'monthly', 'app_store:101', 'o-1', 300000,
    '2026-11-08', '2026-12-08 06:00', false, '2026-11-08 01:00');
  assert (v_reply->'balance'->>'allowance_milli')::bigint = 300000, 'the renewal resets the allowance';
  assert not (v_reply->'balance'->>'trial')::boolean, 'the paid period follows the trial';
  assert (select ends_at from agent_ledger_periods where transaction_id = 'app_store:100')
    = '2026-11-08'::timestamptz, 'the renewal cuts the overlapping period at its start';

  v_reply := pg_temp.apply(v_b, 'app_store', 'monthly', 'app_store:100', 'o-1', 40000,
    '2026-11-01', '2026-11-08 06:00', true, '2026-11-08 02:00');
  assert (v_reply->>'repeated')::boolean, 'an older transaction arriving late is a repetition';
  v_reply := agent_balance(v_b::uuid, '2026-11-08 03:00');
  assert (v_reply->>'allowance_milli')::bigint = 300000, 'a late older period does not displace the renewal';

  v_reply := pg_temp.apply(v_b, 'app_store', 'monthly', 'app_store:101', 'o-1', 300000,
    '2026-11-08', '2026-12-20', false, '2026-11-09');
  assert (v_reply->'balance'->>'renews_at')::timestamptz = '2026-12-20'::timestamptz,
    'a repeated transaction takes the new end date';

  assert agent_store_owner('app_store', 'o-1') = v_b::uuid, 'the link names the owner';
  assert agent_store_owner('app_store', 'missing') is null, 'an unknown subscription has no owner';

  v_reply := pg_temp.apply(v_b, 'app_store', 'top_up', 'app_store:200', null, 150000,
    '2026-11-09', '2026-11-09', false, '2026-11-09');
  assert agent_revoke_purchase('app_store', 'app_store:200', null, '2026-11-10') = 1,
    'a refunded top-up is revoked';
  v_reply := agent_balance(v_b::uuid, '2026-11-10');
  assert (v_reply->>'top_up_milli')::bigint = 0, 'a revoked top-up is not spendable';

  assert agent_revoke_purchase('app_store', 'app_store:101', null, '2026-11-10') = 1,
    'a refunded renewal is revoked';
  v_reply := agent_balance(v_b::uuid, '2026-11-10');
  assert not (v_reply->>'period_active')::boolean, 'a revoked period gives no access';
  v_reply := agent_authorize(v_b::uuid, 'r2', 'turn2', '2026-11-10', 15000, 60);
  assert v_reply->>'error' = 'subscription_required', 'nothing left after the refunds';
  assert agent_revoke_purchase('app_store', 'nothing', null, '2026-11-10') = 0,
    'revoking an unknown transaction changes nothing';
end;
$$;

do $$
declare
  v_reply jsonb;
  v_c text := '00000000-0000-0000-0000-00000000000c';
begin
  v_reply := agent_apply_purchase(v_c::uuid, 'paddle', 'monthly', 'paddle:sub_1:2026-11-01', 'sub_1',
    300000, '2026-11-01', '2026-12-01 06:00', false, 'ctm_1', '2026-11-01');
  assert agent_store_customer(v_c::uuid, 'paddle') = 'ctm_1', 'the customer is kept for the portal';
  assert agent_store_customer(v_c::uuid, 'app_store') is null, 'no customer in another store';

  assert agent_end_subscription('paddle', 'sub_1', '2026-11-15') = 1, 'a cancellation ends the period';
  v_reply := agent_balance(v_c::uuid, '2026-11-16');
  assert not (v_reply->>'period_active')::boolean, 'the cancelled period is over';
  assert agent_end_subscription('paddle', 'sub_1', '2026-11-20') = 0,
    'a later end does not extend a period';

  v_reply := agent_apply_purchase(v_c::uuid, 'paddle', 'monthly', 'paddle:sub_2:2026-11-16', 'sub_2',
    300000, '2026-11-16', '2026-12-16 06:00', false, 'ctm_1', '2026-11-16');
  assert agent_revoke_purchase('paddle', null, 'sub_2', '2026-11-17') = 1,
    'a subscription refund revokes its current period';
  v_reply := agent_balance(v_c::uuid, '2026-11-17');
  assert not (v_reply->>'period_active')::boolean, 'the refunded subscription gives no access';

  v_reply := agent_apply_purchase(v_c::uuid, 'simulated', 'trial', 'trial:c', null,
    40000, '2026-11-18', '2026-11-25', false, null, '2026-11-18');
  assert v_reply->>'error' is null, 'the own trial opens once';
  v_reply := agent_apply_purchase(v_c::uuid, 'simulated', 'trial', 'trial:c2', null,
    40000, '2026-11-19', '2026-11-26', false, null, '2026-11-19');
  assert v_reply->>'error' = 'trial_used', 'the own trial is refused a second time';

  v_reply := agent_apply_purchase(v_c::uuid, 'simulated', 'bundle', 'x', null,
    1, '2026-11-19', '2026-11-19', false, null, '2026-11-19');
  assert v_reply->>'error' = 'invalid_product', 'an unknown product is refused';
end;
$$;

insert into auth.users (id) values
  ('00000000-0000-0000-0000-00000000000d'),
  ('00000000-0000-0000-0000-00000000000e');

do $$
declare
  v_reply jsonb;
  v_d text := '00000000-0000-0000-0000-00000000000d';
begin
  v_reply := agent_apply_purchase(v_d::uuid, 'simulated', 'monthly', 'simulated:d1', null,
    300000, '2026-11-01', '2026-12-01', false, null, '2026-11-01');
  v_reply := agent_authorize(v_d::uuid, 'replayed', 'turn-d', '2026-11-10 00:00', 15000, 60);
  assert v_reply->>'error' is null, 'a fresh request is authorized';
  v_reply := agent_debit(v_d::uuid, 'replayed', 'turn-d', 2000, '2026-11-10 00:00:05');
  v_reply := agent_authorize(v_d::uuid, 'replayed', 'turn-d', '2026-11-10 00:01', 15000, 60);
  assert v_reply->>'error' = 'invalid_request', 'a request id that was already used is refused';
  v_reply := agent_authorize(v_d::uuid, 'pending', 'turn-p', '2026-11-10 00:02', 15000, 60);
  v_reply := agent_authorize(v_d::uuid, 'pending', 'turn-p', '2026-11-10 00:02:01', 15000, 60);
  assert v_reply->>'error' = 'invalid_request', 'an authorized request cannot be authorized again';
  v_reply := agent_debit(v_d::uuid, 'pending', 'turn-p', 0, '2026-11-10 00:02:02');
  assert (select spent_milli from agent_ledger_periods where transaction_id = 'simulated:d1') = 2000,
    'only the first call of a request id is charged';
  assert (select count(*) from agent_ledger_events where user_id = v_d::uuid and kind = 'authorize') = 2,
    'every authorized call leaves its own event';

  update agent_ledger_periods set spent_milli = allowance_milli - 1000 where transaction_id = 'simulated:d1';
  v_reply := agent_authorize(v_d::uuid, 'low-1', 'turn-l1', '2026-11-10 00:10', 15000, 60);
  assert v_reply->>'error' is null, 'a low balance still authorizes one call';
  v_reply := agent_authorize(v_d::uuid, 'low-2', 'turn-l2', '2026-11-10 00:10:01', 15000, 60);
  assert v_reply->>'error' = 'rate_limited', 'a low balance does not cover a second call in flight';
  v_reply := agent_debit(v_d::uuid, 'low-1', 'turn-l1', 500, '2026-11-10 00:10:02');
  v_reply := agent_authorize(v_d::uuid, 'low-3', 'turn-l3', '2026-11-10 00:10:03', 15000, 60);
  assert v_reply->>'error' is null, 'the settled call frees the reservation';
  v_reply := agent_authorize(v_d::uuid, 'low-4', 'turn-l4', '2026-11-10 00:13:10', 15000, 60);
  assert v_reply->>'error' is null, 'an abandoned reservation expires';

  update agent_ledger_periods set spent_milli = 0 where transaction_id = 'simulated:d1';
  v_reply := agent_authorize(v_d::uuid, 'wide-1', 'turn-w1', '2026-11-10 00:20', 15000, 60);
  v_reply := agent_authorize(v_d::uuid, 'wide-2', 'turn-w2', '2026-11-10 00:20:01', 15000, 60);
  assert v_reply->>'error' is null, 'a large balance covers several calls in flight';
end;
$$;

do $$
declare
  v_reply jsonb;
  v_d text := '00000000-0000-0000-0000-00000000000d';
  v_e text := '00000000-0000-0000-0000-00000000000e';
begin
  v_reply := agent_apply_purchase(v_e::uuid, 'simulated', 'monthly', 'simulated:e1', null,
    300000, '2026-11-01', '2026-12-01', false, null, '2026-11-01');
  v_reply := agent_apply_purchase(v_d::uuid, 'app_store', 'top_up', 'app_store:7000', null,
    150000, '2026-11-11', '2026-11-11', false, null, '2026-11-11');
  assert (v_reply->>'repeated')::boolean = false, 'the buyer redeems the top-up';
  v_reply := agent_apply_purchase(v_e::uuid, 'app_store', 'top_up', 'app_store:7000', null,
    150000, '2026-11-11', '2026-11-11', false, null, '2026-11-11');
  assert v_reply->>'error' = 'purchase_owned_elsewhere', 'a top-up credits a single account';
  assert (select count(*) from agent_ledger_top_ups where transaction_id = 'app_store:7000') = 1,
    'the refused top-up records nothing';
  v_reply := agent_apply_purchase(v_d::uuid, 'app_store', 'top_up', 'app_store:7000', null,
    150000, '2026-11-11', '2026-11-11', false, null, '2026-11-12');
  assert (v_reply->>'repeated')::boolean, 'the buyer repeating the top-up stays idempotent';
  v_reply := agent_apply_purchase(v_e::uuid, 'simulated', 'top_up', 'app_store:7000', null,
    150000, '2026-11-11', '2026-11-11', false, null, '2026-11-11');
  assert (v_reply->>'repeated')::boolean = false, 'the same id in another store is another purchase';

  v_reply := agent_apply_purchase(v_e::uuid, 'paddle', 'monthly', 'paddle:sub_t1:2026-11-12', 'sub_t1',
    40000, '2026-11-12', '2026-11-19 06:00', true, 'ctm_e', '2026-11-12');
  assert v_reply->>'error' is null, 'the first store trial opens';
  v_reply := agent_apply_purchase(v_e::uuid, 'paddle', 'monthly', 'paddle:sub_t2:2026-11-13', 'sub_t2',
    40000, '2026-11-13', '2026-11-20 06:00', true, 'ctm_e', '2026-11-13');
  assert v_reply->>'error' = 'trial_used', 'a second store trial is refused';
  assert (select count(*) from agent_ledger_periods where user_id = v_e::uuid and kind = 'trial') = 1,
    'one trial period per account';
  v_reply := agent_apply_purchase(v_e::uuid, 'paddle', 'monthly', 'paddle:sub_t1:2026-11-12', 'sub_t1',
    40000, '2026-11-12', '2026-11-19 06:00', true, 'ctm_e', '2026-11-14');
  assert (v_reply->>'repeated')::boolean, 'the same trial delivered again is a repetition';
  v_reply := agent_apply_purchase(v_e::uuid, 'paddle', 'monthly', 'paddle:sub_t1:2026-11-19', 'sub_t1',
    300000, '2026-11-19', '2026-12-19 06:00', false, 'ctm_e', '2026-11-19');
  assert v_reply->>'error' is null, 'the paid renewal after the trial is granted';
end;
$$;

do $$
begin
  assert not has_function_privilege('authenticated',
    'agent_apply_purchase(uuid, text, text, text, text, bigint, timestamptz, timestamptz, boolean, text, timestamptz)',
    'execute'), 'clients cannot grant purchases';
  assert not has_function_privilege('anon', 'agent_revoke_purchase(text, text, text, timestamptz)', 'execute'),
    'clients cannot revoke purchases';
  assert has_function_privilege('service_role', 'agent_store_owner(text, text)', 'execute'),
    'the functions read owners';
  assert not exists(select 1 from pg_proc where proname = 'agent_grant_purchase'),
    'the old grant function is gone';
end;
$$;
