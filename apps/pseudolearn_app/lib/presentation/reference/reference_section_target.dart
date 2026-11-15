const String _anchorSeparator = '#';

String sectionTarget(String sectionId, String? anchor) {
  if (anchor == null || anchor.isEmpty) return sectionId;
  return '$sectionId$_anchorSeparator$anchor';
}

String specificationLocation(String target) {
  final separator = target.indexOf(_anchorSeparator);
  if (separator < 0) return '/conocimiento/especificacion/$target';
  final sectionId = target.substring(0, separator);
  final anchor = target.substring(separator + 1);
  final base = '/conocimiento/especificacion/$sectionId';
  if (anchor.isEmpty) return base;
  return '$base?anchor=${Uri.encodeQueryComponent(anchor)}';
}
