import 'package:flutter/widgets.dart';
import 'color_primitives.dart';

const _lightLevel1 = <BoxShadow>[
  BoxShadow(
    color: ColorPrimitives.shadowLightAmbient1,
    offset: Offset(0, 1),
    blurRadius: 2,
  ),
  BoxShadow(
    color: ColorPrimitives.shadowLightPenumbra1,
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: -1,
  ),
];

const _lightLevel2 = <BoxShadow>[
  BoxShadow(
    color: ColorPrimitives.shadowLightAmbient2,
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: -1,
  ),
  BoxShadow(
    color: ColorPrimitives.shadowLightPenumbra2,
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -2,
  ),
];

const _lightLevel3 = <BoxShadow>[
  BoxShadow(
    color: ColorPrimitives.shadowLightAmbient3,
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: -2,
  ),
  BoxShadow(
    color: ColorPrimitives.shadowLightPenumbra3,
    offset: Offset(0, 10),
    blurRadius: 16,
    spreadRadius: -4,
  ),
];

const _lightLevel4 = <BoxShadow>[
  BoxShadow(
    color: ColorPrimitives.shadowLightAmbient4,
    offset: Offset(0, 8),
    blurRadius: 16,
    spreadRadius: -4,
  ),
  BoxShadow(
    color: ColorPrimitives.shadowLightPenumbra4,
    offset: Offset(0, 20),
    blurRadius: 32,
    spreadRadius: -8,
  ),
];

const _darkLevel3 = <BoxShadow>[
  BoxShadow(
    color: ColorPrimitives.shadowDarkAmbient3,
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: -2,
  ),
];

const _darkLevel4 = <BoxShadow>[
  BoxShadow(
    color: ColorPrimitives.shadowDarkAmbient4,
    offset: Offset(0, 12),
    blurRadius: 24,
    spreadRadius: -6,
  ),
];

final class AppElevation {
  final List<BoxShadow> level0;
  final List<BoxShadow> level1;
  final List<BoxShadow> level2;
  final List<BoxShadow> level3;
  final List<BoxShadow> level4;

  const AppElevation({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
  });

  const AppElevation.light()
      : level0 = const [],
        level1 = _lightLevel1,
        level2 = _lightLevel2,
        level3 = _lightLevel3,
        level4 = _lightLevel4;

  const AppElevation.dark()
      : level0 = const [],
        level1 = const [],
        level2 = const [],
        level3 = _darkLevel3,
        level4 = _darkLevel4;
}
