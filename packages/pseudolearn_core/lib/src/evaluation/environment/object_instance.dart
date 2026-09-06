import '../../semantic/symbols/symbol.dart';
import 'variable_cell.dart';

final class ObjectInstance {
  final int id;
  final ClassSymbol classSymbol;
  final Map<String, VariableCell> _fields;

  ObjectInstance({
    required this.id,
    required this.classSymbol,
    Map<String, VariableCell>? fields,
  }) : _fields = fields ?? _initializeFields(classSymbol);

  static Map<String, VariableCell> _initializeFields(ClassSymbol classSymbol) {
    final fields = <String, VariableCell>{};
    final hierarchy = <ClassSymbol>[];
    ClassSymbol? current = classSymbol;
    while (current != null) {
      hierarchy.add(current);
      current = current.superclass;
    }
    for (final cls in hierarchy.reversed) {
      for (final field in cls.fields.values) {
        fields.putIfAbsent(field.name, VariableCell.new);
      }
    }
    return fields;
  }

  VariableCell? fieldCell(String fieldName) => _fields[fieldName];

  bool hasField(String fieldName) => _fields.containsKey(fieldName);

  Iterable<MapEntry<String, VariableCell>> get fieldEntries => _fields.entries;

  ObjectInstance shallowCopy(int newId) {
    final clonedFields = <String, VariableCell>{};
    for (final entry in _fields.entries) {
      final cell = VariableCell();
      if (entry.value.hasValue) {
        cell.assign(entry.value.value);
      }
      clonedFields[entry.key] = cell;
    }
    return ObjectInstance(
      id: newId,
      classSymbol: classSymbol,
      fields: clonedFields,
    );
  }

  @override
  String toString() => 'ObjectInstance(${classSymbol.name}#$id)';
}
