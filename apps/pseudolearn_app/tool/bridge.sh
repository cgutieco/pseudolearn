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
    cp native/src/frb_generated.rs "$snapshot/native/src/frb_generated.rs"
    cp -R lib/engine/bridge "$snapshot/lib/engine/bridge"
    flutter_rust_bridge_codegen generate --config-file .flutter_rust_bridge.yaml
    cargo fmt --manifest-path native/Cargo.toml
    diff -ru "$snapshot/native/src/frb_generated.rs" native/src/frb_generated.rs
    diff -ru "$snapshot/lib/engine/bridge" lib/engine/bridge
    ;;
  clean-checkout)
    checkout="$(mktemp -d)"
    trap 'git worktree remove --force "$checkout" >/dev/null 2>&1 || true; rm -rf "$checkout"' EXIT
    app_path="$(git rev-parse --show-prefix)"
    git worktree add --detach "$checkout" HEAD >/dev/null
    git diff --binary HEAD -- . | git -C "$checkout" apply --allow-empty
    (
      cd "$checkout/$app_path"
      flutter pub get
      before="$(mktemp -d)"
      cp -R native/src/frb_generated.rs "$before/frb_generated.rs"
      cp -R lib/engine/bridge "$before/bridge"
      bash tool/bridge.sh generate
      diff -u "$before/frb_generated.rs" native/src/frb_generated.rs
      diff -ru "$before/bridge" lib/engine/bridge
      rm -rf "$before"
    )
    ;;
  *)
    printf '%s\n' 'Usage: bash tool/bridge.sh [generate|check|clean-checkout]' >&2
    exit 2
    ;;
esac
