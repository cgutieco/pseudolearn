abstract interface class ClassHierarchyProvider {
  bool isSubclassOf(String subclass, String superclass);
}

final class EmptyClassHierarchyProvider implements ClassHierarchyProvider {
  const EmptyClassHierarchyProvider();

  @override
  bool isSubclassOf(String subclass, String superclass) => false;
}
