import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/effect_tape.dart';

void main() {
  group('EffectTape', () {
    test('a document round trips without changing its order or content', () {
      final document = <String, Object?>{
        'format': 'pseudolearn.tape/v1',
        'entries': [
          {'seq': 1, 'hash': 'ab'},
        ],
      };
      final tape = EffectTape.fromDocument(document);
      expect(tape.toDocument(), document);
      expect(EffectTape.fromDocument(tape.toDocument()), tape);
      expect(EffectTape.fromDocument(tape.toDocument()).hashCode, tape.hashCode);
    });

    test('tapes with different content are different', () {
      expect(
        EffectTape.fromDocument({'entries': []}),
        isNot(EffectTape.fromDocument({'entries': [1]})),
      );
    });

    test('mutating the returned document does not alter the tape', () {
      final tape = EffectTape.fromDocument({'entries': []});
      tape.toDocument()['entries'] = [1];
      expect(tape.toDocument()['entries'], isEmpty);
    });
  });
}
