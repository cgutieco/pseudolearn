import '../../semantic/symbols/symbol.dart';
import 'array_storage.dart';
import 'variable_cell.dart';

final class RuntimeScope {
  final Map<Symbol, VariableCell> _cells = {};
  final Map<Symbol, ArrayStorage> _arrays = {};

  VariableCell cellFor(Symbol symbol) =>
      _cells.putIfAbsent(symbol, VariableCell.new);

  void bind(Symbol symbol, VariableCell cell) => _cells[symbol] = cell;

  ArrayStorage? arrayFor(Symbol symbol) => _arrays[symbol];

  void declareArray(Symbol symbol, ArrayStorage storage) =>
      _arrays[symbol] = storage;

  Iterable<MapEntry<Symbol, VariableCell>> get entries => _cells.entries;
}
