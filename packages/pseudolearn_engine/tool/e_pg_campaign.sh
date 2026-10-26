set -eu

cd "$(dirname "$0")/.."

experiment="${1:?usage: bash tool/e_pg_campaign.sh <E-PG-03|E-PG-04> <new-campaign-directory> <machine-label>}"
campaign="${2:?missing campaign directory}"
machine="${3:?missing machine label}"
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
  shasum -a 256 Cargo.lock rust-toolchain.toml
} > "$campaign/provenance/sources.sha256"
{
  rustc -Vv
  cargo -V
  uname -a
  sw_vers 2>/dev/null || true
  sysctl -n machdep.cpu.brand_string hw.model hw.memsize 2>/dev/null || true
} > "$campaign/provenance/toolchain-and-host.txt"
printf 'profile=release\nseed=42\nmachine=%s\n' "$machine" > "$campaign/provenance/flags.txt"

run cargo build --release --locked -p pseudolearn_bench_worker
shasum -a 256 target/release/pseudolearn_bench_worker > "$campaign/provenance/binary.sha256"

worker=target/release/pseudolearn_bench_worker
for process in 0 1 2 3 4 5 6 7 8 9; do
  run "$worker" pg-collect "$experiment" "$campaign" "$process" "$machine"
done
run "$worker" pg-summary "$experiment" "$campaign"
