import 'package:flutter/painting.dart';
import 'tokens/typography.dart';

extension AppFontRoleStyle on TextStyle {
  TextStyle inRole(AppFontRole role) => copyWith(
        fontFamily: TypographyTokens.familyFor(role),
        fontFamilyFallback: TypographyTokens.fallbacksFor(role),
      );
}
