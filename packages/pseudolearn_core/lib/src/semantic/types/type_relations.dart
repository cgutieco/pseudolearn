import 'class_hierarchy_provider.dart';
import 'semantic_type.dart';

final class TypeRelations {
  const TypeRelations._();

  static bool areIdentical(SemanticType a, SemanticType b) {
    if (identical(a, b)) return true;
    if (a is PrimitiveSemanticType && b is PrimitiveSemanticType) {
      return a.primitive == b.primitive;
    }
    if (a is ClassSemanticType && b is ClassSemanticType) {
      return a.className == b.className;
    }
    if (a is ArraySemanticType && b is ArraySemanticType) {
      return a.dimensions == b.dimensions &&
          areIdentical(a.elementType, b.elementType);
    }
    if (a is VoidSemanticType && b is VoidSemanticType) return true;
    if (a is IndeterminateSemanticType && b is IndeterminateSemanticType) {
      return true;
    }
    if (a is ErrorSemanticType && b is ErrorSemanticType) return true;
    return false;
  }

  static bool isConvertibleTo(
    SemanticType from,
    SemanticType to, {
    ClassHierarchyProvider? hierarchy,
  }) {
    if (from is ErrorSemanticType || to is ErrorSemanticType) return true;
    if (from is IndeterminateSemanticType || to is IndeterminateSemanticType) {
      return true;
    }
    if (areIdentical(from, to)) return true;
    if (from.isInteger && to.isReal) return true;
    if (from is ClassSemanticType && to is ClassSemanticType) {
      return hierarchy?.isSubclassOf(from.className, to.className) ?? false;
    }
    return false;
  }

  static bool areComparable(
    SemanticType a,
    SemanticType b, {
    ClassHierarchyProvider? hierarchy,
  }) {
    if (a is ErrorSemanticType || b is ErrorSemanticType) return true;
    if (a is IndeterminateSemanticType || b is IndeterminateSemanticType) {
      return true;
    }
    return isConvertibleTo(a, b, hierarchy: hierarchy) ||
        isConvertibleTo(b, a, hierarchy: hierarchy);
  }

  static bool isAssignable(
    SemanticType from,
    SemanticType to, {
    ClassHierarchyProvider? hierarchy,
  }) =>
      isConvertibleTo(from, to, hierarchy: hierarchy);
}
