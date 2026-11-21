import 'package:flutter/foundation.dart';
import '../../domain/ports/text_entry_modality.dart';

final class PlatformTextEntryModality implements TextEntryModality {
  static const Set<TargetPlatform> _onscreenKeyboardPlatforms = {TargetPlatform.iOS, TargetPlatform.android};

  const PlatformTextEntryModality();

  @override
  bool get hasOnscreenTextEntry => _onscreenKeyboardPlatforms.contains(defaultTargetPlatform);
}
