import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/auth/sign_in_nonce.dart';

void main() {
  group('SignInNonce', () {
    test('hashed value is the SHA-256 of the raw value', () {
      final nonce = SignInNonce.generate();

      expect(
        nonce.hashed,
        sha256.convert(utf8.encode(nonce.raw)).toString(),
      );
    });

    test('hashed value is a 64 character hexadecimal digest', () {
      const hexDigits = '0123456789abcdef';
      final nonce = SignInNonce.generate();

      expect(nonce.hashed.length, 64);
      for (final character in nonce.hashed.split('')) {
        expect(hexDigits.contains(character), isTrue);
      }
    });

    test('raw value is never empty and carries at least 32 bytes of entropy', () {
      final nonce = SignInNonce.generate();

      expect(nonce.raw, isNotEmpty);
      expect(base64Url.decode(nonce.raw).length, 32);
    });

    test('consecutive nonces never repeat', () {
      final values = <String>{};
      for (var attempt = 0; attempt < 100; attempt++) {
        values.add(SignInNonce.generate().raw);
      }

      expect(values.length, 100);
    });

    test('two nonces generated in the same instant differ', () {
      final first = SignInNonce.generate();
      final second = SignInNonce.generate();

      expect(first.raw, isNot(second.raw));
      expect(first.hashed, isNot(second.hashed));
    });
  });
}
