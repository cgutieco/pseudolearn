import 'package:flutter/material.dart';
import '../../../domain/model/account/account_avatar_identity.dart';
import '../../../domain/model/account/account_session.dart';
import '../../components/typography/app_text.dart';
import '../../theme/tokens/color_primitives.dart';
import '../../theme/tokens/icon_metrics.dart';

const List<Color> _avatarPalette = [
  ColorPrimitives.brand500,
  ColorPrimitives.brand700,
  ColorPrimitives.orange500,
  ColorPrimitives.orange700,
];

final class AccountAvatar extends StatelessWidget {
  final AccountSession session;
  final double size;

  const AccountAvatar({
    super.key,
    required this.session,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final identity = AccountAvatarIdentity.fromSession(session);
    final placeholder = _AvatarMonogram(initials: identity.initials);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _avatarPalette[identity.colorSeed % _avatarPalette.length],
      ),
      alignment: Alignment.center,
      child: _AvatarPhoto(
        photoUrl: session.photoUrl,
        size: size,
        placeholder: placeholder,
      ),
    );
  }
}

final class _AvatarPhoto extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final Widget placeholder;

  const _AvatarPhoto({
    required this.photoUrl,
    required this.size,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url == null || url.isEmpty) return placeholder;

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

final class _AvatarMonogram extends StatelessWidget {
  final String? initials;

  const _AvatarMonogram({required this.initials});

  @override
  Widget build(BuildContext context) {
    final letters = initials;
    if (letters == null) {
      return const Icon(
        Icons.person_outline,
        size: IconMetricsTokens.iconLg,
        color: ColorPrimitives.neutral0,
      );
    }

    return AppText(
      letters,
      variant: AppTextVariant.heading2,
      color: ColorPrimitives.neutral0,
    );
  }
}
