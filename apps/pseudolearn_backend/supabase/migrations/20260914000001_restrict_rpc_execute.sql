revoke execute on function public.push_documents(jsonb) from public, anon;
revoke execute on function public.push_progress(jsonb) from public, anon;
grant execute on function public.push_documents(jsonb) to authenticated;
grant execute on function public.push_progress(jsonb) to authenticated;
