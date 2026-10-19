#!/usr/bin/env bash
set -euo pipefail

engine_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
browser_directory="${engine_directory}/crates/pseudolearn_wasm/browser"
package_directory="${engine_directory}/target/wasm-browser/pkg"
wasm_file="${engine_directory}/target/wasm32-unknown-unknown/release/pseudolearn_wasm.wasm"
action="${1:-build}"
staging_directory=""

trap 'if [[ -n "$staging_directory" ]]; then rm -rf "$staging_directory"; fi' EXIT

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Required tool is missing: %s\n' "$1" >&2
    exit 1
  fi
}

require_generator() {
  require_tool wasm-bindgen
  local generator_version
  generator_version="$(wasm-bindgen --version)"
  if [[ "$generator_version" != "wasm-bindgen 0.2.129" ]]; then
    printf 'Expected wasm-bindgen 0.2.129, found %s\n' "$generator_version" >&2
    exit 1
  fi
}

build_package() {
  require_tool cargo
  require_generator
  local dependency_tree
  dependency_tree="$(cargo tree --manifest-path "${engine_directory}/Cargo.toml" -p pseudolearn_wasm --target wasm32-unknown-unknown)"
  if printf '%s\n' "$dependency_tree" | grep -Eq 'pseudolearn_codegen|pseudolearn_aot_rt|cranelift'; then
    printf 'The Wasm dependency graph contains the native backend\n' >&2
    exit 1
  fi
  RUSTFLAGS="-C link-arg=--max-memory=268435456" cargo build \
    --manifest-path "${engine_directory}/Cargo.toml" \
    --locked \
    --release \
    --target wasm32-unknown-unknown \
    --package pseudolearn_wasm \
    --lib
  mkdir -p "$package_directory"
  wasm-bindgen --target web --out-name pseudolearn_wasm --out-dir "$package_directory" "$wasm_file"
  staging_directory="$(mktemp -d)"
  wasm-bindgen --target web --out-name pseudolearn_wasm --out-dir "${staging_directory}/pkg" "$wasm_file"
  diff -r "$package_directory" "${staging_directory}/pkg"
}

case "$action" in
  build)
    build_package
    ;;
  test)
    build_package
    require_tool pnpm
    pnpm --dir "$browser_directory" install --frozen-lockfile --package-import-method=copy
    pnpm --dir "$browser_directory" test
    ;;
  *)
    printf 'Usage: bash tool/wasm.sh [build|test]\n' >&2
    exit 2
    ;;
esac
