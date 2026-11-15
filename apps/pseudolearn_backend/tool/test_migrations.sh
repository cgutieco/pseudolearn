#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

package_root="$(cd "$(dirname "$0")/.." && pwd)"
cluster="$(mktemp -d)"
trap 'pg_ctl -D "$cluster/data" -m immediate stop >/dev/null 2>&1 || true; rm -rf "$cluster"' EXIT

initdb -D "$cluster/data" -U postgres --auth=trust --no-instructions --locale=C --encoding=UTF8 >/dev/null
pg_ctl -D "$cluster/data" -o "-k $cluster -c listen_addresses=''" -l "$cluster/log" -w start >/dev/null

run_sql() {
  psql -h "$cluster" -U postgres -d postgres -v ON_ERROR_STOP=1 -q -X -f "$1" >/dev/null
}

run_sql "$package_root/test/migrations/supabase_stub.sql"
for migration in "$package_root"/supabase/migrations/*.sql; do
  run_sql "$migration"
done
for test_file in "$package_root"/test/migrations/*_test.sql; do
  run_sql "$test_file"
  echo "ok $(basename "$test_file")"
done
for negative_file in "$package_root"/test/migrations/negative/*.sql; do
  if run_sql "$negative_file" 2>/dev/null; then
    echo "negative case passed: $(basename "$negative_file")" >&2
    exit 1
  fi
  echo "ok negative $(basename "$negative_file")"
done
