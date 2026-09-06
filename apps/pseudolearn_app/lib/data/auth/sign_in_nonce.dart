import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

const int _nonceByteLength = 32;

final class SignInNonce {
  final String raw;
  final String hashed;

  const SignInNonce._({required this.raw, required this.hashed});

  factory SignInNonce.generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(_nonceByteLength, (_) => random.nextInt(256));
    final raw = base64Url.encode(bytes);
    return SignInNonce._(
      raw: raw,
      hashed: sha256.convert(utf8.encode(raw)).toString(),
    );
  }
}
