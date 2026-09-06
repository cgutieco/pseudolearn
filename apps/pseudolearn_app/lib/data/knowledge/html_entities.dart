const Map<String, String> _entities = {
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
  '&amp;': '&',
};

String unescapeHtmlEntities(String text) {
  var result = text;
  for (final entity in _entities.entries) {
    result = result.replaceAll(entity.key, entity.value);
  }
  return result;
}
