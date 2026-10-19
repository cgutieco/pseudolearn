String relatedLocationLabel({
  required String profile,
  required int line,
  required int column,
}) {
  return profile == 'es'
      ? 'Ubicación relacionada en línea $line, col $column'
      : 'Related location at line $line, col $column';
}
