import 'package:flutter/widgets.dart';
import 'memory_boxes_illustration.dart';

typedef IllustrationBuilder = Widget Function();

const Map<String, IllustrationBuilder> illustrationCatalog = {
  'cajas-memoria': MemoryBoxesIllustration.new,
};
