set -eu

cd "$(dirname "$0")/.."

campaign="${1:?usage: bash tool/e_pg_13.sh <new-campaign-directory>}"
if [ -e "$campaign" ]; then
  echo "refusing to reuse existing $campaign" >&2
  exit 1
fi

mkdir -p "$campaign/provenance"
commands="$campaign/commands.txt"

run() {
  printf '%s\n' "$*" >> "$commands"
  "$@"
}

root="$(git rev-parse --show-toplevel)"
{
  git -C "$root" rev-parse HEAD
  git -C "$root" status --porcelain
} > "$campaign/provenance/revision.txt"
git -C "$root" diff HEAD | shasum -a 256 > "$campaign/provenance/diff.sha256"
{
  find crates/pseudolearn_bench_worker/src -type f -name '*.rs' | sort | xargs shasum -a 256
  shasum -a 256 "$root/packages/pseudolearn_spec/specifications/export.json" Cargo.lock rust-toolchain.toml
} > "$campaign/provenance/sources.sha256"
{
  rustc -Vv
  cargo -V
  uname -a
  sw_vers 2>/dev/null || true
  sysctl -n machdep.cpu.brand_string hw.model hw.memsize 2>/dev/null || true
} > "$campaign/provenance/toolchain-and-host.txt"

run cargo build --release --locked -p pseudolearn_bench_worker
shasum -a 256 target/release/pseudolearn_bench_worker > "$campaign/provenance/binary.sha256"

worker=target/release/pseudolearn_bench_worker
run "$worker" service project functional "$campaign"
for series in profiles resolution project; do
  for process in 01 02 03 04 05 06 07 08 09 10; do
    run "$worker" service project run "$series" "$campaign" "$process"
  done
done
run "$worker" service project summary "$campaign"
run "$worker" service project verify "$campaign"
