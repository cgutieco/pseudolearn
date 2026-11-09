enum LegalDocument {
  terms('/terms'),
  privacy('/privacy');

  static const String site = 'https://pseudolearn.app';
  static const String englishPrefix = '/en';

  final String path;

  const LegalDocument(this.path);

  Uri urlFor(String languageCode) =>
      Uri.parse(languageCode == 'en' ? '$site$englishPrefix$path' : '$site$path');
}
