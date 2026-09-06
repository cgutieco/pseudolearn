import 'package:flutter/foundation.dart';
import '../../domain/ports/text_entry_modality.dart';

final class PlatformTextEntryModality implements TextEntryModality {
  const PlatformTextEntryModality();

  @override
  bool get hasOnscreenTextEntry => defaultTargetPlatform == TargetPlatform.iOS;
}
