import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/credits/legal_document.dart';

void main() {
  test('Spanish and every other language read the default edition', () {
    expect(LegalDocument.terms.urlFor('es').toString(), 'https://pseudolearn.app/terms');
    expect(LegalDocument.privacy.urlFor('pt').toString(), 'https://pseudolearn.app/privacy');
  });

  test('English reads the English edition', () {
    expect(LegalDocument.terms.urlFor('en').toString(), 'https://pseudolearn.app/en/terms');
    expect(LegalDocument.privacy.urlFor('en').toString(), 'https://pseudolearn.app/en/privacy');
  });
}
