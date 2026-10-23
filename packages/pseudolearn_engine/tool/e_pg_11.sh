set -eu

cd "$(dirname "$0")/.."

campaign="${1:?usage: bash tool/e_pg_11.sh <new-campaign-directory>}"
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
  shasum -a 256 "$root/packages/pseudolearn_spec/specifications/export.json" \
    "$root/packages/pseudolearn_spec/specifications/tool/tool.service.catalog.md" \
    Cargo.lock rust-toolchain.toml
  find "$root/apps/pseudolearn_app/assets/knowledge/examples" -type f -name '*.pseudo' | sort | xargs shasum -a 256
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
run "$worker" service help functional "$campaign"
for process in 01 02 03 04 05 06 07 08 09 10; do
  run "$worker" service help latency hot "$campaign" "$process"
done
for process in 01 02 03 04 05 06 07 08 09 10; do
  run "$worker" service help latency cold "$campaign" "$process"
done
run "$worker" service help summary "$campaign"
run "$worker" service help verify "$campaign"
