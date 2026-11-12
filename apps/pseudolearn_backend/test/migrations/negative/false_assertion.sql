do $$
begin
  assert (agent_balance('00000000-0000-0000-0000-0000000000ff', now())->>'period_active')::boolean,
    'a user without purchases has no active period';
end;
$$;
