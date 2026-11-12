enum CoverageRepresentation { exact, declaredExtension, notApplicable }

final class CoverageCell {
  final CoverageRepresentation representation;
  final String reason;
  final String helpEntry;

  const CoverageCell.exact()
    : representation = CoverageRepresentation.exact,
      reason = '',
      helpEntry = '';

  const CoverageCell.help(this.helpEntry)
    : representation = CoverageRepresentation.exact,
      reason = '';

  const CoverageCell.extension(this.reason)
    : representation = CoverageRepresentation.declaredExtension,
      helpEntry = '';

  const CoverageCell.notApplicable(this.reason)
    : representation = CoverageRepresentation.notApplicable,
      helpEntry = '';

  bool get isExact => representation == CoverageRepresentation.exact;

  bool get isNotApplicable =>
      representation == CoverageRepresentation.notApplicable;

  bool get needsReason => !isExact;
}
