import 'marketing_audience.dart';

const int maxHeadlineWords = 7;
const int maxHeadlineCharacters = 48;

enum MarketingRule {
  price,
  beta,
  superlative,
  award,
  callToAction,
  rivalPlatform,
  tooLong,
}

final class MarketingViolation {
  final String headline;
  final MarketingRule rule;
  final String evidence;

  const MarketingViolation({
    required this.headline,
    required this.rule,
    required this.evidence,
  });

  @override
  String toString() => '[${rule.name}] "$headline" contains "$evidence"';
}

const Set<String> _priceCharacters = <String>{r'$', '€', '£', '¥', '%'};

final RegExp _amountPattern = RegExp(
  r'\d+([.,]\d+)?\s*(eur|usd|euros?|d[oó]lares?|dollars?)\b',
  caseSensitive: false,
);

const Map<MarketingRule, List<String>> _universalTerms =
    <MarketingRule, List<String>>{
  MarketingRule.price: <String>[
    'gratis', 'gratuita', 'gratuito', 'free', 'precio', 'price', 'coste',
    'cost', 'descuento', 'discount', 'oferta', 'offer', 'rebaja', 'sale',
    'suscripcion', 'subscription', 'euros', 'dolares', 'dollars', 'usd', 'eur',
  ],
  MarketingRule.beta: <String>[
    'beta', 'alfa', 'alpha', 'acceso anticipado', 'early access',
    'proximamente', 'coming soon', 'version previa', 'preview',
  ],
  MarketingRule.superlative: <String>[
    'la mejor', 'el mejor', 'lo mejor', 'mejores', 'best', 'fastest',
    'la mas rapida', 'el mas rapido', 'numero 1', 'no 1', 'lider', 'leading',
    'definitiva', 'definitivo', 'ultimate', 'insuperable', 'perfecta',
    'perfecto', 'unica', 'unico', 'revolucionaria', 'revolutionary',
  ],
  MarketingRule.award: <String>[
    'premio', 'premiada', 'premiado', 'award', 'awarded', 'ganador', 'winner',
    'galardon', 'galardonada', 'top rated', 'mejor valorada', 'ranking',
  ],
  MarketingRule.callToAction: <String>[
    'descarga ahora', 'descargala', 'descargalo', 'download now',
    'instala ahora', 'install now', 'get it now', 'consiguela',
  ],
};

const Map<MarketingAudience, List<String>> _rivalPlatformTerms =
    <MarketingAudience, List<String>>{
  MarketingAudience.appleStore: <String>[
    'android', 'google play', 'play store', 'windows', 'linux', 'chromebook',
    'samsung', 'galaxy', 'microsoft store',
  ],
  MarketingAudience.googlePlay: <String>[
    'ios', 'iphone', 'ipad', 'app store', 'macos', 'apple', 'windows', 'linux',
    'microsoft store',
  ],
  MarketingAudience.landing: <String>[],
};

List<MarketingViolation> auditHeadline(
  String headline,
  MarketingAudience audience,
) {
  final violations = <MarketingViolation>[
    ..._lengthViolations(headline),
    ..._priceCharacterViolations(headline),
  ];
  final normalized = ' ${_normalize(headline)} ';
  _universalTerms.forEach((rule, terms) {
    violations.addAll(_termViolations(headline, normalized, rule, terms));
  });
  violations.addAll(_termViolations(
    headline,
    normalized,
    MarketingRule.rivalPlatform,
    _rivalPlatformTerms[audience]!,
  ));
  return violations;
}

List<MarketingViolation> _lengthViolations(String headline) {
  final words = headline.trim().split(RegExp(r'\s+'));
  final violations = <MarketingViolation>[];
  if (words.length > maxHeadlineWords) {
    violations.add(MarketingViolation(
      headline: headline,
      rule: MarketingRule.tooLong,
      evidence: '${words.length} words (max $maxHeadlineWords)',
    ));
  }
  if (headline.length > maxHeadlineCharacters) {
    violations.add(MarketingViolation(
      headline: headline,
      rule: MarketingRule.tooLong,
      evidence: '${headline.length} characters (max $maxHeadlineCharacters)',
    ));
  }
  return violations;
}

List<MarketingViolation> _priceCharacterViolations(String headline) {
  final violations = <MarketingViolation>[];
  for (final character in _priceCharacters) {
    if (headline.contains(character)) {
      violations.add(MarketingViolation(
        headline: headline,
        rule: MarketingRule.price,
        evidence: character,
      ));
    }
  }
  if (_amountPattern.hasMatch(headline)) {
    violations.add(MarketingViolation(
      headline: headline,
      rule: MarketingRule.price,
      evidence: 'a monetary amount',
    ));
  }
  return violations;
}

List<MarketingViolation> _termViolations(
  String headline,
  String normalized,
  MarketingRule rule,
  List<String> terms,
) {
  final violations = <MarketingViolation>[];
  for (final term in terms) {
    if (normalized.contains(' $term ')) {
      violations.add(MarketingViolation(
        headline: headline,
        rule: rule,
        evidence: term,
      ));
    }
  }
  return violations;
}

const Map<String, String> _accentFolding = <String, String>{
  'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
  'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u', 'ç': 'c',
};

String _normalize(String headline) {
  final folded = StringBuffer();
  for (final character in headline.toLowerCase().split('')) {
    folded.write(_accentFolding[character] ?? character);
  }
  return folded
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}
