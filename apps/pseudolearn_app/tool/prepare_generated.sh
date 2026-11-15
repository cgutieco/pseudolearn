set -eu

cd "$(dirname "$0")/.."

(
  cd ../../packages/pseudolearn_spec
  cargo run --locked -p see_cli --bin see -- export --root .
)
flutter gen-l10n
bash tool/bridge.sh check
flutter test tool/generate_app_icons.dart tool/generate_launch_images.dart
