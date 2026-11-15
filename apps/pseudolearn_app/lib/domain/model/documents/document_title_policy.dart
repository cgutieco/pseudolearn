enum DocumentTitleValidation {
  valid,
  empty,
  duplicate,
}

String normalizeDocumentTitle(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) return '';

  final buffer = StringBuffer();
  var inWhitespace = false;

  for (var i = 0; i < trimmed.length; i++) {
    final char = trimmed[i];
    final isWhitespace = char == ' ' || char == '\t' || char == '\n' || char == '\r';

    if (isWhitespace) {
      if (!inWhitespace) {
        buffer.write(' ');
        inWhitespace = true;
      }
    } else {
      buffer.write(char);
      inWhitespace = false;
    }
  }

  return buffer.toString();
}

String normalizeDocumentTitleForComparison(String title) {
  return normalizeDocumentTitle(title).toLowerCase();
}

DocumentTitleValidation validateDocumentTitle(
  String candidateTitle,
  Iterable<String> existingTitles, {
  String? currentTitle,
}) {
  final cleanCandidate = normalizeDocumentTitle(candidateTitle);
  if (cleanCandidate.isEmpty) {
    return DocumentTitleValidation.empty;
  }

  final comparisonCandidate = normalizeDocumentTitleForComparison(candidateTitle);

  if (currentTitle != null) {
    final comparisonCurrent = normalizeDocumentTitleForComparison(currentTitle);
    if (comparisonCandidate == comparisonCurrent) {
      return DocumentTitleValidation.valid;
    }
  }

  for (final existing in existingTitles) {
    if (currentTitle != null &&
        normalizeDocumentTitleForComparison(existing) ==
            normalizeDocumentTitleForComparison(currentTitle)) {
      continue;
    }
    if (normalizeDocumentTitleForComparison(existing) == comparisonCandidate) {
      return DocumentTitleValidation.duplicate;
    }
  }

  return DocumentTitleValidation.valid;
}

bool isDocumentTitleAvailable(
  String candidateTitle,
  Iterable<String> existingTitles, {
  String? currentTitle,
}) {
  return validateDocumentTitle(
        candidateTitle,
        existingTitles,
        currentTitle: currentTitle,
      ) ==
      DocumentTitleValidation.valid;
}

int? _parseFamilyNumber(String normExisting, String normBase) {
  if (normExisting == normBase) return 1;
  if (!normExisting.startsWith('$normBase ')) return null;

  final suffix = normExisting.substring(normBase.length + 1);
  final parsed = int.tryParse(suffix);
  if (parsed == null || parsed <= 0 || parsed.toString() != suffix) {
    return null;
  }
  return parsed;
}

String suggestNextDocumentTitle(
  String baseTitle,
  Iterable<String> existingTitles,
) {
  final cleanBase = normalizeDocumentTitle(baseTitle);
  if (cleanBase.isEmpty) return '';

  final normBase = normalizeDocumentTitleForComparison(cleanBase);
  final familyNumbers = <int>[];

  for (final existing in existingTitles) {
    final normExisting = normalizeDocumentTitleForComparison(existing);
    final number = _parseFamilyNumber(normExisting, normBase);
    if (number != null) {
      familyNumbers.add(number);
    }
  }

  if (familyNumbers.isEmpty) {
    return cleanBase;
  }

  var maxNumber = familyNumbers.first;
  for (final number in familyNumbers) {
    if (number > maxNumber) {
      maxNumber = number;
    }
  }

  return '$cleanBase ${maxNumber + 1}';
}
