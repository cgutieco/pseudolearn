enum AstConstruct {
  conditional('condicional'),
  multipleSelection('seleccion-multiple'),
  conditionalLoop('bucle-condicional'),
  postConditionalLoop('bucle-condicional-posterior'),
  countedLoop('bucle-contado'),
  arrayDeclaration('arreglo'),
  subprogram('subprograma'),
  classDeclaration('clase');

  final String slug;

  const AstConstruct(this.slug);

  static AstConstruct? fromSlug(String slug) {
    for (final construct in values) {
      if (construct.slug == slug) return construct;
    }
    return null;
  }
}
