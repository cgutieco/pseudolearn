import 'package:equatable/equatable.dart';

import 'account_session.dart';

final class AccountAvatarIdentity extends Equatable {
  final String? initials;
  final int colorSeed;

  const AccountAvatarIdentity({
    required this.initials,
    required this.colorSeed,
  });

  factory AccountAvatarIdentity.fromSession(AccountSession session) {
    return AccountAvatarIdentity(
      initials: _initialsFromName(session.displayName) ??
          _initialFromAddress(session.email),
      colorSeed: _colorSeedOf(session.userId),
    );
  }

  @override
  List<Object?> get props => [initials, colorSeed];
}

String? _initialsFromName(String? displayName) {
  final words = _wordsOf(displayName);
  if (words.isEmpty) return null;
  final first = _leadingLetterOf(words.first);
  if (first == null) return null;
  if (words.length == 1) return first;
  final last = _leadingLetterOf(words.last);
  return last == null ? first : '$first$last';
}

String? _initialFromAddress(String? email) {
  final address = email?.trim() ?? '';
  if (address.isEmpty) return null;
  return _leadingLetterOf(address);
}

List<String> _wordsOf(String? text) {
  final words = <String>[];
  for (final candidate in (text ?? '').split(' ')) {
    final word = candidate.trim();
    if (word.isNotEmpty) words.add(word);
  }
  return words;
}

String? _leadingLetterOf(String word) {
  final character = word.substring(0, 1);
  return _isLetter(character) ? character.toUpperCase() : null;
}

bool _isLetter(String character) {
  if (character.toUpperCase() != character.toLowerCase()) return true;
  return character.codeUnitAt(0) > 127;
}

int _colorSeedOf(String userId) {
  var seed = 0;
  for (final codeUnit in userId.codeUnits) {
    seed = (seed * 31 + codeUnit) % 1000003;
  }
  return seed;
}
