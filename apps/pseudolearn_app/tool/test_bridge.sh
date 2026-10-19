set -eu

cd "$(dirname "$0")/.."

cargo build --locked --lib --manifest-path native/Cargo.toml
flutter test tool/native_bridge_test.dart
