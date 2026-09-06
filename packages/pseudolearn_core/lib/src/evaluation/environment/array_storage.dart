import 'variable_cell.dart';

final class ArrayStorage {
  final List<int> dimensionSizes;
  final List<VariableCell> _cells;

  ArrayStorage(this.dimensionSizes)
      : _cells = List.generate(
          dimensionSizes.fold<int>(1, (product, size) => product * size),
          (_) => VariableCell(),
        );

  int get elementCount => _cells.length;

  int? _flattenIndex(List<int> indices) {
    if (indices.length != dimensionSizes.length) return null;
    var flat = 0;
    for (var dimension = 0; dimension < indices.length; dimension++) {
      final index = indices[dimension];
      final size = dimensionSizes[dimension];
      if (index < 0 || index >= size) return null;
      flat = flat * size + index;
    }
    return flat;
  }

  VariableCell? cellAt(List<int> indices) {
    final flat = _flattenIndex(indices);
    if (flat == null) return null;
    return _cells[flat];
  }
}
