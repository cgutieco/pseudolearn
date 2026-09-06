import '../symbols/scope.dart';
import '../symbols/symbol.dart';
import 'class_hierarchy_provider.dart';

final class ScopeClassHierarchyProvider implements ClassHierarchyProvider {
  final SourceUnitScope rootScope;

  const ScopeClassHierarchyProvider(this.rootScope);

  @override
  bool isSubclassOf(String subclass, String superclass) {
    ClassSymbol? subSym;
    final direct = rootScope.lookup(subclass);
    if (direct is ClassSymbol) {
      subSym = direct;
    } else {
      for (final s in rootScope.symbols.values) {
        if (s is ClassSymbol &&
            s.name.toLowerCase() == subclass.toLowerCase()) {
          subSym = s;
          break;
        }
      }
    }
    if (subSym == null) return false;
    var current = subSym.superclass;
    while (current != null) {
      if (current.name.toLowerCase() == superclass.toLowerCase()) return true;
      current = current.superclass;
    }
    return false;
  }
}
