set -eu

cd "$(dirname "$0")/.."

mode="${1:-generate}"

case "$mode" in
  generate)
    flutter_rust_bridge_codegen generate --config-file .flutter_rust_bridge.yaml
    cargo fmt --manifest-path native/Cargo.toml
    ;;
  check)
    snapshot="$(mktemp -d)"
    trap 'rm -rf "$snapshot"' EXIT
    mkdir -p "$snapshot/native/src" "$snapshot/lib/engine"
    flutter_rust_bridge_codegen generate --config-file .flutter_rust_bridge.yaml
    cargo fmt --manifest-path native/Cargo.toml
    cp native/src/frb_generated.rs "$snapshot/native/src/frb_generated.rs"
    cp -R lib/engine/bridge "$snapshot/lib/engine/bridge"
    flutter_rust_bridge_codegen generate --config-file .flutter_rust_bridge.yaml
    cargo fmt --manifest-path native/Cargo.toml
    diff -ru "$snapshot/native/src/frb_generated.rs" native/src/frb_generated.rs
    diff -ru "$snapshot/lib/engine/bridge" lib/engine/bridge
    ;;
  clean-checkout)
    checkout="$(mktemp -d)"
    trap 'rm -rf "$checkout"' EXIT
    app_path="$(git rev-parse --show-prefix)"
    git clone --shared --quiet . "$checkout"
    git diff --binary HEAD -- . | git -C "$checkout" apply --allow-empty
    while IFS= read -r -d '' path; do
      mkdir -p "$checkout/$(dirname "$path")"
      cp "$path" "$checkout/$path"
    done < <(git ls-files --others --exclude-standard -z)
    (
      cd "$checkout/$app_path"
      flutter pub get
      bash tool/prepare_generated.sh
    )
    ;;
  *)
    printf '%s\n' 'Usage: bash tool/bridge.sh [generate|check|clean-checkout]' >&2
    exit 2
    ;;
esac
